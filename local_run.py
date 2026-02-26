#!/usr/bin/env python3
"""
Local runner for the ECS v1 project.
Replicates what the GitHub Actions workflows do (bootstrap → build → infra).

Usage:
    python local_run.py bootstrap   # run bootstrap terraform only
    python local_run.py build       # build & push docker image only
    python local_run.py infra       # run main infra terraform only
    python local_run.py all         # bootstrap → build → infra in order
"""

import argparse
import json
import os
import subprocess
import sys

# ── Config ────────────────────────────────────────────────────────────────────
# Bootstrap state backend (same values as secrets/vars in CI)
BOOTSTRAP_STATE_BUCKET = os.environ.get("BOOTSTRAP_TF_STATE_BUCKET", "my-27-state-bucket")
BOOTSTRAP_STATE_KEY    = os.environ.get("BOOTSTRAP_TF_STATE_KEY",    "bootstrap/terraform.tfstate")
AWS_REGION             = os.environ.get("AWS_REGION", "us-east-1")
BOOTSTRAP_VARS_FILE    = os.environ.get("BOOTSTRAP_VARS_FILE", "boot.tfvars")

BOOTSTRAP_DIR = "bootstrap"
INFRA_DIR     = "infra"
APP_DIR       = "app/fider-main"
# ──────────────────────────────────────────────────────────────────────────────


def run(cmd: list[str], cwd: str | None = None, env: dict | None = None) -> str:
    """Run a command, stream output, and return stdout. Exits on failure."""
    merged_env = {**os.environ, **(env or {})}
    print(f"\n$ {' '.join(cmd)}" + (f"  (cwd={cwd})" if cwd else ""))
    result = subprocess.run(cmd, cwd=cwd, env=merged_env)
    if result.returncode != 0:
        print(f"\nERROR: command exited with code {result.returncode}")
        sys.exit(result.returncode)
    return ""


def run_capture(cmd: list[str], cwd: str | None = None) -> str:
    """Run a command and return its stdout (no streaming). Exits on failure."""
    result = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True)
    if result.returncode != 0:
        print(result.stderr)
        sys.exit(result.returncode)
    return result.stdout.strip()


def check_prerequisites():
    print("=== Checking prerequisites ===")
    for tool in ["terraform", "aws", "docker"]:
        path = subprocess.run(["which", tool], capture_output=True, text=True).stdout.strip()
        if not path:
            print(f"ERROR: '{tool}' not found in PATH")
            sys.exit(1)
        print(f"  ✓ {tool}: {path}")

    # Verify AWS credentials work
    result = subprocess.run(
        ["aws", "sts", "get-caller-identity"],
        capture_output=True, text=True
    )
    if result.returncode != 0:
        print("ERROR: AWS credentials not configured. Run 'aws configure' or set AWS_* env vars.")
        sys.exit(1)
    identity = json.loads(result.stdout)
    print(f"  ✓ AWS identity: {identity['Arn']}")


def bootstrap_init():
    run([
        "terraform", "init", "-reconfigure",
        f"-backend-config=bucket={BOOTSTRAP_STATE_BUCKET}",
        f"-backend-config=key={BOOTSTRAP_STATE_KEY}",
        f"-backend-config=region={AWS_REGION}",
        "-backend-config=encrypt=true",
        "-backend-config=use_lockfile=true",
    ], cwd=BOOTSTRAP_DIR)


def step_bootstrap():
    print("\n=== Bootstrap: creating S3 state bucket + ECR repo ===")
    bootstrap_init()
    run(["terraform", "validate"], cwd=BOOTSTRAP_DIR)
    run(
        [
            "terraform", "plan",
            "-var-file", BOOTSTRAP_VARS_FILE,
            "-lock-timeout=5m",
            "-out=tfplan",
        ],
        cwd=BOOTSTRAP_DIR,
    )
    run(
        [
            "terraform", "apply",
            "-auto-approve",
            "-lock-timeout=5m",
            "tfplan",
        ],
        cwd=BOOTSTRAP_DIR,
    )
    print("\nBootstrap outputs:")
    run(["terraform", "output", "ecr_repository_name"], cwd=BOOTSTRAP_DIR)
    run(["terraform", "output", "state_bucket_name"],   cwd=BOOTSTRAP_DIR)


def read_bootstrap_outputs() -> dict:
    """Init bootstrap in read-only mode and return its outputs as a dict."""
    print("\n=== Reading bootstrap outputs ===")
    bootstrap_init()
    ecr_name = run_capture(["terraform", "output", "-raw", "ecr_repository_name"], cwd=BOOTSTRAP_DIR)
    ecr_url  = run_capture(["terraform", "output", "-raw", "ecr_repository_url"],  cwd=BOOTSTRAP_DIR)
    bucket   = run_capture(["terraform", "output", "-raw", "state_bucket_name"],   cwd=BOOTSTRAP_DIR)
    print(f"  ECR name : {ecr_name}")
    print(f"  ECR url  : {ecr_url}")
    print(f"  S3 bucket: {bucket}")
    return {"ecr_name": ecr_name, "ecr_url": ecr_url, "state_bucket": bucket}


def step_build(image_tag: str = "local"):
    outputs = read_bootstrap_outputs()
    ecr_url  = outputs["ecr_url"]
    ecr_name = outputs["ecr_name"]

    print(f"\n=== Docker: build & push ({ecr_name}:{image_tag}) ===")

    # ECR login
    registry = ecr_url.split("/")[0]
    token = run_capture([
        "aws", "ecr", "get-login-password", "--region", AWS_REGION
    ])
    login = subprocess.run(
        ["docker", "login", "--username", "AWS", "--password-stdin", registry],
        input=token, text=True, capture_output=True
    )
    if login.returncode != 0:
        print(login.stderr)
        sys.exit(1)
    print("  ✓ ECR login successful")

    full_tag    = f"{ecr_url}:{image_tag}"
    latest_tag  = f"{ecr_url}:latest"

    run(["docker", "build", "-t", full_tag, "-t", latest_tag, "."], cwd=APP_DIR)
    run(["docker", "push", full_tag])
    run(["docker", "push", latest_tag])
    print(f"\n  ✓ Pushed {full_tag}")
    return image_tag


def step_infra(image_tag: str = "latest"):
    outputs = read_bootstrap_outputs()

    print(f"\n=== Infra: terraform apply (image_tag={image_tag}) ===")
    run(["terraform", "init"], cwd=INFRA_DIR)
    run(["terraform", "validate"], cwd=INFRA_DIR)
    run(["terraform", "plan", "-lock-timeout=5m", "-out=tfplan"], cwd=INFRA_DIR,
        env={
            "TF_VAR_ecr_repository_name": outputs["ecr_name"],
            "TF_VAR_image_tag": image_tag,
        })
    run(["terraform", "apply", "-auto-approve", "-lock-timeout=5m", "tfplan"],
        cwd=INFRA_DIR,
        env={
            "TF_VAR_ecr_repository_name": outputs["ecr_name"],
            "TF_VAR_image_tag": image_tag,
        })


def main():
    parser = argparse.ArgumentParser(description="Local runner for ecs-v1")
    parser.add_argument(
        "step",
        choices=["bootstrap", "build", "infra", "all"],
        help="Which step to run"
    )
    parser.add_argument(
        "--image-tag",
        default="local",
        help="Docker image tag to use (default: local)"
    )
    parser.add_argument(
        "--skip-checks",
        action="store_true",
        help="Skip prerequisite checks"
    )
    args = parser.parse_args()

    if not args.skip_checks:
        check_prerequisites()

    if args.step == "bootstrap":
        step_bootstrap()

    elif args.step == "build":
        step_build(args.image_tag)

    elif args.step == "infra":
        step_infra(args.image_tag)

    elif args.step == "all":
        step_bootstrap()
        tag = step_build(args.image_tag)
        step_infra(tag)

    print("\n✓ Done.")


if __name__ == "__main__":
    main()
