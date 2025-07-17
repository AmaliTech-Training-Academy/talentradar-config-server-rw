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

# AWS role ARN for GitHub Actions to assume
# This should be created beforehand in AWS IAM and have permissions for ECR and ECS
read -p "Enter AWS Role ARN for GitHub Actions (format: arn:aws:iam::<account-id>:role/<role-name>): " AWS_ROLE_ARN
if [ -z "$AWS_ROLE_ARN" ]; then
    echo "AWS Role ARN is required"
    exit 1
fi

# Set repository secrets
echo "Setting AWS_ROLE_TO_ASSUME secret..."
gh secret set AWS_ROLE_TO_ASSUME --repo $REPO --body "$AWS_ROLE_ARN"

echo ""
echo "Secrets set successfully for $REPO"
echo ""
echo "Make sure you have created the following IAM Role in AWS:"
echo "- Role: $AWS_ROLE_ARN"
echo "- Permissions: AmazonECR-FullAccess, AmazonECS-FullAccess"
echo "- Trust Relationship: Allow GitHub Actions (identity provider)"
echo ""
echo "You also need to ensure the ECS service exists: TalentRadar-ConfigServer-Service"
echo "It should be configured to use the task definition from this repository"

exit 0
