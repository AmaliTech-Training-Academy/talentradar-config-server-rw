# AWS IAM Role Setup for GitHub Actions

This document describes how to set up the IAM role that GitHub Actions will use to deploy to AWS.

## 1. Create an OpenID Connect Provider for GitHub

If you haven't already set up GitHub as an OIDC provider in your AWS account:

1. Go to the IAM console
2. Navigate to Identity Providers
3. Click "Add Provider"
4. Select "OpenID Connect"
5. For the Provider URL, enter `https://token.actions.githubusercontent.com`
6. For the "Audience", enter `sts.amazonaws.com`
7. Click "Add provider"

## 2. Create the IAM Role

1. Go to the IAM console
2. Click "Roles" and then "Create role"
3. Select "Web identity" as the trusted entity type
4. Select the GitHub identity provider you just created
5. For the "Audience", select `sts.amazonaws.com`
6. Add a condition to limit access to your repository:
   - Field: `token.actions.githubusercontent.com:sub`
   - Operator: `StringEquals`
   - Value: `repo:AmaliTech-Training-Academy/talentradar-config-server-rw:ref:refs/heads/main`
7. Click "Next"
8. Attach the following policies:
   - `AmazonECR-FullAccess` (or a custom policy with more limited permissions)
   - `AmazonECS-FullAccess` (or a custom policy with more limited permissions)
9. Name the role `GitHubActionsECSDeployRole` or similar
10. Click "Create role"
11. Copy the role ARN for use in the GitHub secrets setup

## 3. Set up the ECS Service

Ensure that the ECS service is created in the correct cluster:

1. Go to the ECS console
2. Navigate to the `TalentRadar-Cluster` cluster
3. Create a new service named `TalentRadar-ConfigServer-Service`
4. Use the task definition that will be created by the GitHub workflow
5. Configure the service with the appropriate networking settings:
   - Use the private subnets from the Terraform configuration
   - Use the security group from the Terraform configuration
   - Configure service discovery as needed

## 4. Run the Setup Script

After completing these steps, run the `setup-github-secrets.sh` script to set up the GitHub repository with the role ARN.

```bash
./setup-github-secrets.sh
```

Enter the role ARN when prompted.
