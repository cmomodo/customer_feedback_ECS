# Customer Feedback Ecosystem (ECS v1)

[![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)
[![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)](https://github.com/features/actions)

An automated, scalable deployment of the open-source **Customer Feedback App** (based on Fider) on AWS ECS. This project leverages Terraform for Infrastructure as Code (IaC) and GitHub Actions for continuous integration and delivery.

---

## Overview

The **Customer Feedback App** is a powerful tool designed to streamline customer feedback and enhance user experience. This repository provides a production-ready infrastructure to deploy the application with high availability, security, and automation.

**Live Demo:** 
- Sign Up: [https://ceedev.co.uk/signup](https://ceedev.co.uk/signup)
- Health Check: [https://ceedev.co.uk/_health](https://ceedev.co.uk/_health)

---

## System Architecture

The architecture is designed for scalability and security, utilizing AWS best practices:

![System Design Diagram](./Images/system_design.png)

### Key Components:
- **Compute**: AWS ECS (Elastic Container Service) with Fargate.
- **Network**: VPC with public/private subnets and an Application Load Balancer (ALB).
- **Storage**: Amazon RDS for persistent data and ECR for container images.
- **Security**: ACM for SSL/TLS, Secrets Manager for credentials, and IAM for least-privilege access.

---

## Project Structure

```text
.
├── .github/workflows/      # CI/CD pipeline definitions
│   ├── bootstrap.yaml      # Environment initialization
│   ├── build.yaml          # Docker build and push
│   ├── clean.yaml          # Resource teardown
│   └── terra.yaml          # Infrastructure deployment
├── app/                    # Application source code
├── bootstrap/              # Initial S3/DynamoDB setup for Terraform state
└── infra/                  # Core Infrastructure (Terraform)
    ├── modules/            # Reusable TF modules (VPC, ALB, ECS, etc.)
    ├── policies/           # IAM and security policies
    ├── main.tf             # Root module configuration
    └── variables.tf        # Infrastructure inputs
```

---

## Getting Started

### Prerequisites
- AWS CLI configured with appropriate permissions.
- Terraform v1.0+ installed.
- GitHub repository secrets configured for CI/CD.

### Initial Setup (Bootstrap)
Before deploying the main infrastructure, initialize the remote backend and ECR repositories:

```bash
# Initialize and apply bootstrap configuration
terraform -chdir=bootstrap init -reconfigure
terraform -chdir=bootstrap apply -var-file=terraform.tfvars
```

---

## CI/CD Pipelines

We utilize four primary GitHub Action workflows for complete lifecycle management:

### 1. Bootstrap Workflow
Creates the initial ECR repository and foundational resources.
![Bootstrap Workflow](./Images/bootstrap.png)

### 2. Docker Workflow (Build & Push)
Builds and pushes the Docker image for `linux/arm64`. Includes a **Trivy** security scan.
![Docker Workflow](./Images/docker_deploy.png)

### 3. Infrastructure Workflow (Deploy)
Deploys the application using Terraform. It automatically updates the ECS task definition to the latest image tag.
![Infrastructure Workflow](./Images/terraform_deploy.png)

### 4. Clean Up Workflow
Deletes all provisioned resources to optimize costs when the environment is not in use.
![Clean Up Workflow](./Images/cleanup.png)

---

## Security & Optimization

- **Vulnerability Scanning**: Integrated **Trivy** scanning in the CI/CD pipeline.
![Trivy Scan](./Images/trivy_scan.png)
- **High Performance**: Optimized Docker multi-stage builds, reducing build time from **30 minutes to 2 minutes**.
- **Secure Runtime**: Containerized application runs as a non-root user.
- **HTTPS/SSL**: Automated certificate management via ACM.
![HTTPS Confirmation](./Images/https.png)
- **Health Monitoring**: Continuous health checks via the Load Balancer.
![Health Check Confirmation](./Images/health_check.png)

---

## Roadmap & Future Enhancements

- [ ] **Cognito Integration**: Implementing robust authentication and authorization (`feature/cognito`).
- [ ] **Email Notifications**: Integrating AWS SES for automated user communication.
- [ ] **Enhanced Monitoring**: Adding CloudWatch dashboards and automated alerting.


