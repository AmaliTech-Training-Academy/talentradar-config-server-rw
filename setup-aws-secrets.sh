#!/bin/bash
# Script to set up GitHub secrets for talentradar-config-server-rw repository
# This script requires GitHub CLI (gh) to be installed and authenticated

set -e

# Repository name
REPO="AmaliTech-Training-Academy/talentradar-config-server-rw"

# Check if gh is installed
if ! command -v gh &> /dev/null; then
    echo "GitHub CLI (gh) is not installed. Please install it first."
    echo "Installation instructions: https://cli.github.com/manual/installation"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo "Please authenticate with GitHub CLI first by running 'gh auth login'"
    exit 1
fi

echo "Setting up GitHub secrets for $REPO"

# AWS Credentials
AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:-AKIAUWPDAEMWUYXIDHRO}
echo "Setting AWS_ACCESS_KEY_ID secret..."
gh secret set AWS_ACCESS_KEY_ID --repo $REPO --body "$AWS_ACCESS_KEY_ID"

AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY:-uO96Ht5tsEoZgK4pzUXkCy6QNBmR+7Tj+HZOa7TD}
echo "Setting AWS_SECRET_ACCESS_KEY secret..."
gh secret set AWS_SECRET_ACCESS_KEY --repo $REPO --body "$AWS_SECRET_ACCESS_KEY"

# AWS Configuration
AWS_REGION=${AWS_REGION:-eu-west-1}
echo "Setting AWS_REGION secret..."
gh secret set AWS_REGION --repo $REPO --body "$AWS_REGION"

AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID:-323135480621}
echo "Setting AWS_ACCOUNT_ID secret..."
gh secret set AWS_ACCOUNT_ID --repo $REPO --body "$AWS_ACCOUNT_ID"

# ECR Configuration
ECR_REPOSITORY=${ECR_REPOSITORY:-talentradar/config-server}
echo "Setting ECR_REPOSITORY secret..."
gh secret set ECR_REPOSITORY --repo $REPO --body "$ECR_REPOSITORY"

ECR_REGISTRY=${ECR_REGISTRY:-323135480621.dkr.ecr.eu-west-1.amazonaws.com}
echo "Setting ECR_REGISTRY secret..."
gh secret set ECR_REGISTRY --repo $REPO --body "$ECR_REGISTRY"

# ECS Configuration
ECS_CLUSTER=${ECS_CLUSTER:-TalentRadar-Cluster}
echo "Setting ECS_CLUSTER secret..."
gh secret set ECS_CLUSTER --repo $REPO --body "$ECS_CLUSTER"

ECS_SERVICE=${ECS_SERVICE:-TalentRadar-config-server}
echo "Setting ECS_SERVICE secret..."
gh secret set ECS_SERVICE --repo $REPO --body "$ECS_SERVICE"

# Container Configuration
CONTAINER_NAME=${CONTAINER_NAME:-config-server}
echo "Setting CONTAINER_NAME secret..."
gh secret set CONTAINER_NAME --repo $REPO --body "$CONTAINER_NAME"

echo ""
echo "✅ All secrets set successfully for $REPO:"
echo "- AWS_ACCESS_KEY_ID"
echo "- AWS_SECRET_ACCESS_KEY"
echo "- AWS_REGION"
echo "- AWS_ACCOUNT_ID"
echo "- ECR_REPOSITORY"
echo "- ECR_REGISTRY"
echo "- ECS_CLUSTER"
echo "- ECS_SERVICE"
echo "- CONTAINER_NAME"
echo ""
echo "Your GitHub Actions workflow can now authenticate with AWS and deploy to ECS!"

exit 0
