#!/bin/bash
# Script to set up GitHub repository secrets for the talentradar-config-server-rw repository

# Ensure GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo "GitHub CLI is not installed. Please install it first."
    echo "Installation instructions: https://cli.github.com/manual/installation"
    exit 1
fi

# Ensure user is authenticated with GitHub CLI
if ! gh auth status &> /dev/null; then
    echo "You are not authenticated with GitHub CLI. Please run 'gh auth login' first."
    exit 1
fi

# Repository details
REPO_OWNER="AmaliTech-Training-Academy"
REPO_NAME="talentradar-config-server-rw"

# AWS Role ARN to assume for deployments
# This role should have permissions to:
# - Push to ECR
# - Update ECS services
# - Read/write task definitions
AWS_ROLE_ARN="arn:aws:iam::323135480621:role/github-actions-deployment-role"

echo "Setting up secrets for $REPO_OWNER/$REPO_NAME..."

# Set AWS_ROLE_TO_ASSUME secret
echo "Setting AWS_ROLE_TO_ASSUME secret..."
gh secret set AWS_ROLE_TO_ASSUME --repo="$REPO_OWNER/$REPO_NAME" --body="$AWS_ROLE_ARN"

echo "Successfully set up GitHub repository secrets for $REPO_OWNER/$REPO_NAME."
echo "The following secrets are now available:"
echo "- AWS_ROLE_TO_ASSUME: IAM role for GitHub Actions to assume for AWS deployments"

echo "Make sure the role has the necessary permissions for ECR, ECS, and CloudWatch Logs."
