# TalentRadar Config Server AWS ECS Deployment

This document explains how the TalentRadar Config Server is automatically deployed to AWS ECS environments.

## Deployment Workflow

The deployment is fully automated using GitHub Actions. When code is merged into one of the following branches, it triggers an automatic deployment:

- `development` branch → Development environment
- `staging` branch → Staging environment
- `production` branch → Production environment

No manual intervention is required. The GitHub Actions workflow handles:

1. Building the Spring Boot application
2. Building a Docker image
3. Pushing the image to Amazon ECR
4. Deploying the updated task definition to ECS
5. Ensuring service stability after deployment

## Environment-Specific Configurations

Each environment (development, staging, production) has its own:

- Task definition with appropriate resource allocations
- ECS service and cluster
- Environment variables via Spring profiles
- CloudWatch log groups
- Container resource allocations (CPU/memory)

## Required GitHub Repository Secrets

The following secrets need to be set in the GitHub repository:

- `AWS_ROLE_TO_ASSUME`: The ARN of the IAM role with permissions to deploy to ECR/ECS

## Infrastructure Management

The AWS infrastructure is managed by Terraform in the talentradar-devops repository. The workflow uses resources created and managed by this Terraform configuration.

## Manual Deployment

In case a manual deployment is needed, you can use the "Run workflow" button in the GitHub Actions UI and select the target environment.
