# TalentRadar Config Server

Spring Cloud Config Server for the TalentRadar application.

## AWS Deployment Setup

This repository is configured to automatically build and deploy to AWS ECS when changes are pushed to the main branch.

### Prerequisites

1. AWS infrastructure set up using the Terraform configuration in the `talentradar-devops` repository
2. IAM role configured for GitHub Actions (see [AWS IAM Setup](./aws-iam-setup.md))
3. ECS service created in the TalentRadar cluster

### Deployment Process

1. **Manual Setup (One-time)**:

   - Follow the instructions in [AWS IAM Setup](./aws-iam-setup.md) to create the IAM role
   - Run the `setup-github-secrets.sh` script to set up the GitHub repository secrets:
     ```bash
     ./setup-github-secrets.sh
     ```

2. **Automatic Deployment**:

   - When changes are pushed to the main branch, the GitHub Actions workflow will:
     - Build the Java application
     - Build a Docker image
     - Push the image to Amazon ECR
     - Update the ECS task definition
     - Deploy the new task definition to the ECS service

3. **Manual Deployment**:
   - You can also manually trigger the deployment from the GitHub Actions tab
   - Navigate to Actions → "Deploy Config Server to AWS ECS" → "Run workflow"

## Docker Image

The Docker image uses a multi-stage build process for efficiency:

1. **Build stage**: Uses Maven to compile the application and prepare layers
2. **Runtime stage**: Uses a minimal JRE image for the final container

The container exposes port 8085 and includes a health check endpoint at `/actuator/health`.

## Local Development

To run the service locally:

```bash
# Build the application
./mvnw clean package

# Run the application
java -jar target/config-server-*.jar
```

To build and run the Docker image locally:

```bash
# Build Docker image
docker build -t talentradar/config-server .

# Run Docker container
docker run -p 8085:8085 talentradar/config-server
```

## Monitoring

The service exposes Spring Boot Actuator endpoints for monitoring:

- Health check: `/actuator/health`
- Info: `/actuator/info`
- Metrics: `/actuator/metrics`

## Configuration

The service uses the following environment variables:

- `SPRING_PROFILES_ACTIVE`: Set to `production` for deployment
- `SERVER_PORT`: Default is 8085
