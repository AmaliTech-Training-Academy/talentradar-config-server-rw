# AWS ECS "Service Unavailable" Error Fixes

## Overview

This document outlines the comprehensive fixes implemented to address "Service Unavailable" errors and improve deployment reliability for the TalentRadar Config Server AWS ECS deployment.

## Root Causes Addressed

### 1. AWS Service Reliability Issues

- **Problem**: AWS ECS API experiencing temporary outages or high load
- **Solution**: Enhanced retry logic with exponential backoff and adaptive retry mode

### 2. Insufficient AWS Permissions

- **Problem**: Missing or incorrect IAM permissions causing deployment failures
- **Solution**: Pre-deployment AWS permissions testing

### 3. Rate Limiting

- **Problem**: GitHub Actions hitting AWS API rate limits
- **Solution**: Proper retry mechanisms with increased wait times

### 4. Task Definition Parameter Validation

- **Problem**: AWS CLI failing due to invalid task definition parameters
- **Solution**: Removed problematic `tags: []` field and enhanced JSON validation

## Implemented Solutions

### 1. Enhanced AWS Retry Configuration

```yaml
env:
  AWS_RETRY_MODE: adaptive
  AWS_MAX_ATTEMPTS: 5
```

### 2. Comprehensive Permissions Testing

New step added to verify all required AWS permissions before deployment:

- STS (Security Token Service) access
- ECR repository access
- ECS cluster and service access
- IAM permissions for task definitions

### 3. Improved Task Definition Format

- Removed empty `tags: []` field that caused AWS CLI parameter validation errors
- Enhanced JSON validation using `jq empty`
- Proper error handling for task definition registration

### 4. Multi-Layer Retry Logic

#### ECR Push Retries

- 5 attempts with 30-second intervals
- Enhanced error reporting

#### Task Definition Registration

- 5 attempts with exponential backoff (30s, 60s, 90s, 120s, 150s)
- Comprehensive error logging

#### Service Update Retries

- 5 attempts with exponential backoff (60s, 120s, 180s, 240s, 300s)
- Service status monitoring between attempts

#### Service Stabilization

- 3 attempts with 120-second intervals
- 15-minute timeout per attempt
- Enhanced monitoring and debugging

### 5. AWS CLI Fallback Enhancement

When GitHub Actions fail, the AWS CLI fallback now includes:

- Pre-deployment service availability checks
- Enhanced error handling and debugging
- Comprehensive retry logic for all operations
- Detailed service status reporting

### 6. Improved Monitoring and Debugging

- Detailed service status verification
- Task information display
- Health status monitoring
- Enhanced error reporting

## Configuration Details

### Environment Variables

Based on the `.env.example` file:

```bash
SPRING_CLOUD_CONFIG_SERVER_GIT_URI=https://github.com/AmaliTech-Training-Academy/talentradar-config-repo-rw
SPRING_CLOUD_CONFIG_SERVER_GIT_DEFAULT_LABEL=main
SERVER_PORT=8085
```

### Task Definition Structure

```json
{
  "family": "TalentRadar-config-server",
  "executionRoleArn": "arn:aws:iam::323135480621:role/TalentRadar-ECSTaskExecutionRole",
  "taskRoleArn": "arn:aws:iam::323135480621:role/TalentRadar-ECSTaskRole",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "containerDefinitions": [...]
}
```

**Note**: Removed the problematic `tags: []` field that was causing AWS CLI parameter validation errors.

### Health Check Configuration

```json
{
  "command": [
    "CMD-SHELL",
    "curl -f http://localhost:8085/actuator/health || exit 1"
  ],
  "interval": 30,
  "timeout": 5,
  "retries": 3,
  "startPeriod": 60
}
```

## Deployment Flow

1. **Permissions Testing**: Verify all AWS permissions before deployment
2. **Image Build**: Build and push Docker image with unique tags
3. **Primary Deployment**: Attempt deployment using GitHub Actions with enhanced retry
4. **Fallback Deployment**: If primary fails, use comprehensive AWS CLI fallback
5. **Verification**: Detailed service and task status verification

## Error Handling

### Common Scenarios Addressed

- AWS API temporary unavailability
- Rate limiting from AWS services
- Network connectivity issues
- Task definition validation errors
- Service update failures
- Deployment timeout issues

### Retry Strategies

- **Immediate retry**: For transient network issues
- **Exponential backoff**: For rate limiting and service overload
- **Adaptive mode**: AWS SDK handles retry logic based on error types

## Monitoring and Debugging

### Service Health Verification

- Running vs. desired task counts
- Service status (ACTIVE/INACTIVE)
- Task health status
- Deployment history

### Enhanced Logging

- Detailed error messages
- Service state information
- Task execution details
- Timeline of deployment steps

## Best Practices Implemented

1. **Idempotent Operations**: All operations can be safely retried
2. **Graceful Degradation**: Fallback to AWS CLI if GitHub Actions fail
3. **Comprehensive Logging**: Detailed information for troubleshooting
4. **Resource Cleanup**: Automatic cleanup of old ECR images
5. **Security**: Non-root container execution and proper IAM roles

## Troubleshooting Guide

### If Deployment Still Fails

1. Check AWS Service Health Dashboard
2. Verify IAM permissions are correctly configured
3. Ensure ECR repository exists and is accessible
4. Confirm ECS cluster and service are properly configured
5. Check CloudWatch logs for container-specific errors

### Required AWS Permissions

The deployment requires the following IAM permissions:

- `sts:GetCallerIdentity`
- `ecr:*` (for ECR operations)
- `ecs:*` (for ECS operations)
- `logs:*` (for CloudWatch logs)

This comprehensive approach should significantly reduce "Service Unavailable" errors and improve overall deployment reliability.
