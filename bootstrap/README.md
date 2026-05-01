# Terraform Bootstrap

This directory contains the Terraform configuration to bootstrap the remote state backend. It implements the "chicken and egg" principle by creating the foundational resources required for the main infrastructure deployment.

## Purpose

- **Remote State**: Creates the S3 bucket and DynamoDB table for Terraform state locking.
- **Secrets Management**: Provides scripts to automate the setup of GitHub Action secrets.
- **Initial Configuration**: Sets up the environment required for the `infra/` directory to function correctly.

## Usage

Refer to the main `README.md` in the root directory for detailed execution steps.
