#!/bin/bash
# Script to create the ECS service for the Config Server

set -e

# Configuration
CLUSTER_NAME="TalentRadar-Cluster"
SERVICE_NAME="TalentRadar-ConfigServer-Service"
TASK_DEFINITION_FAMILY="talentradar-config-server"
CONTAINER_NAME="config-server"
DESIRED_COUNT=1
AWS_REGION="eu-west-1"

# Check if the AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "AWS CLI is not installed. Please install it first."
    exit 1
fi

echo "Creating ECS service for TalentRadar Config Server"

# Get VPC and subnet IDs from Terraform outputs
echo "Fetching network configuration from Terraform..."
cd ../terraform
PRIVATE_SUBNET_IDS=$(terraform output -json private_subnet_ids | jq -r '.[]' | tr '\n' ',' | sed 's/,$//')
SECURITY_GROUP_ID=$(terraform output -json ecs_security_group_id | jq -r '.')
cd - > /dev/null

if [ -z "$PRIVATE_SUBNET_IDS" ] || [ -z "$SECURITY_GROUP_ID" ]; then
    echo "Failed to get network configuration from Terraform outputs"
    exit 1
fi

# Register the initial task definition
echo "Registering initial task definition..."
TASK_DEF_ARN=$(aws ecs register-task-definition \
    --region $AWS_REGION \
    --cli-input-json file://.aws/task-definition.json \
    --query 'taskDefinition.taskDefinitionArn' \
    --output text)

echo "Task definition registered: $TASK_DEF_ARN"

# Check if the service already exists
SERVICE_EXISTS=$(aws ecs describe-services \
    --region $AWS_REGION \
    --cluster $CLUSTER_NAME \
    --services $SERVICE_NAME \
    --query 'services[?status!=`INACTIVE`].status' \
    --output text)

if [ -n "$SERVICE_EXISTS" ]; then
    echo "Service $SERVICE_NAME already exists. Updating service..."
    
    aws ecs update-service \
        --region $AWS_REGION \
        --cluster $CLUSTER_NAME \
        --service $SERVICE_NAME \
        --task-definition $TASK_DEF_ARN \
        --force-new-deployment
else
    echo "Creating new service $SERVICE_NAME..."
    
    aws ecs create-service \
        --region $AWS_REGION \
        --cluster $CLUSTER_NAME \
        --service-name $SERVICE_NAME \
        --task-definition $TASK_DEF_ARN \
        --desired-count $DESIRED_COUNT \
        --launch-type FARGATE \
        --platform-version LATEST \
        --network-configuration "awsvpcConfiguration={subnets=[$PRIVATE_SUBNET_IDS],securityGroups=[$SECURITY_GROUP_ID],assignPublicIp=DISABLED}" \
        --health-check-grace-period-seconds 120
fi

echo "Service deployment complete!"
echo "You can check the status using:"
echo "aws ecs describe-services --cluster $CLUSTER_NAME --services $SERVICE_NAME"

exit 0
