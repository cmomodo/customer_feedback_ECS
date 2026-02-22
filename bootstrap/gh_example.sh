#!/bin/bash
# Example script for setting up GitHub repository secrets for AWS OIDC and Terraform state
# Replace placeholder values with your actual configuration before running

# Configuration - Update these values for your environment
AWS_ACCOUNT_ID="<YOUR_AWS_ACCOUNT_ID>"
AWS_REGION="<YOUR_AWS_REGION>"
TF_STATE_BUCKET="<YOUR_TERRAFORM_STATE_BUCKET>"
TF_STATE_KEY="<YOUR_TERRAFORM_STATE_KEY>"
TF_STATE_REGION="<YOUR_TERRAFORM_STATE_REGION>"
GITHUB_REPO="<YOUR_GITHUB_REPO>"  # e.g., username/repo-name

# Set GitHub secrets for AWS OIDC authentication and Terraform state backend
gh secret set AWS_ROLE_ARN --body "arn:aws:iam::${AWS_ACCOUNT_ID}:role/github_oidc_role" --repo "${GITHUB_REPO}"
gh secret set AWS_REGION --body "${AWS_REGION}" --repo "${GITHUB_REPO}"
gh secret set BOOTSTRAP_TF_STATE_BUCKET --body "${TF_STATE_BUCKET}" --repo "${GITHUB_REPO}"
gh secret set BOOTSTRAP_TF_STATE_KEY --body "${TF_STATE_KEY}" --repo "${GITHUB_REPO}"
gh secret set BOOTSTRAP_TF_STATE_REGION --body "${TF_STATE_REGION}" --repo "${GITHUB_REPO}"

echo "GitHub secrets configured successfully for ${GITHUB_REPO}"
