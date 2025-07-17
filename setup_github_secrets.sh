#!/bin/bash

# Script to set up GitHub secrets for AWS deployment
# This script uses the GitHub CLI (gh) to add AWS credentials to your repository

# Exit on any error
set -e

# Define repository
REPO="AmaliTech-Training-Academy/talentradar-devops"

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo "GitHub CLI (gh) is not installed. Please install it first."
    echo "Visit https://cli.github.com/ for installation instructions."
    exit 1
fi

# Check if the user is authenticated with GitHub CLI
if ! gh auth status &> /dev/null; then
    echo "You are not authenticated with GitHub CLI. Please run 'gh auth login' first."
    exit 1
fi

echo "Setting up GitHub secrets for repository: $REPO"

# Add AWS credentials as GitHub secrets
echo "Adding AWS_ACCESS_KEY_ID..."
# For security, we'll use a predefined value from the environment if available
# Otherwise we'll prompt for it
if [ -z "${AWS_ACCESS_KEY_ID}" ]; then
    echo -n "Enter AWS Access Key ID: "
    read -r AWS_ACCESS_KEY_ID
fi
gh secret set AWS_ACCESS_KEY_ID --body="${AWS_ACCESS_KEY_ID}" --repo="${REPO}"

echo "Adding AWS_SECRET_ACCESS_KEY..."
if [ -z "${AWS_SECRET_ACCESS_KEY}" ]; then
    echo -n "Enter AWS Secret Access Key: "
    read -rs AWS_SECRET_ACCESS_KEY
    echo "" # Add a newline after the hidden input
fi
gh secret set AWS_SECRET_ACCESS_KEY --body="${AWS_SECRET_ACCESS_KEY}" --repo="${REPO}"

# Add other necessary secrets
echo "Adding AWS_REGION..."
AWS_REGION=${AWS_REGION:-us-east-1}
echo "Using AWS Region: $AWS_REGION"
gh secret set AWS_REGION --body="${AWS_REGION}" --repo="${REPO}"

echo "Adding ECR_REPOSITORY..."
ECR_REPOSITORY=${ECR_REPOSITORY:-talentradar-config-server}
echo "Using ECR Repository: $ECR_REPOSITORY"
gh secret set ECR_REPOSITORY --body="${ECR_REPOSITORY}" --repo="${REPO}"

echo "Adding ECS_CLUSTER..."
ECS_CLUSTER=${ECS_CLUSTER:-talentradar-cluster}
echo "Using ECS Cluster: $ECS_CLUSTER"
gh secret set ECS_CLUSTER --body="${ECS_CLUSTER}" --repo="${REPO}"

echo "Adding ECS_SERVICE..."
ECS_SERVICE=${ECS_SERVICE:-config-server-service}
echo "Using ECS Service: $ECS_SERVICE"
gh secret set ECS_SERVICE --body="${ECS_SERVICE}" --repo="${REPO}"

echo "Adding ECS_TASK_DEFINITION..."
ECS_TASK_DEFINITION=${ECS_TASK_DEFINITION:-talentradar-config-server-task}
echo "Using ECS Task Definition: $ECS_TASK_DEFINITION"
gh secret set ECS_TASK_DEFINITION --body="${ECS_TASK_DEFINITION}" --repo="${REPO}"

# Confirm success
echo "GitHub secrets have been successfully set for the repository."
echo "You can now use these secrets in your GitHub Actions workflow."
