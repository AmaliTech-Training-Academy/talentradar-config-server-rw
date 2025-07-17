# TalentRadar Config Server

This repository contains the Config Server for the TalentRadar application, which serves configuration properties to all microservices in the TalentRadar ecosystem.

## Technologies

- Java 21
- Spring Boot 3.2
- Spring Cloud Config Server
- Docker

## Development

### Prerequisites

- JDK 21
- Maven
- Docker

### Building the Application

```bash
./mvnw clean package
```

### Running Locally

```bash
./mvnw spring-boot:run
```

Or with a specific profile:

```bash
./mvnw spring-boot:run -Dspring.profiles.active=development
```

### Building the Docker Image

```bash
docker build -t talentradar/config-server:latest .
```

### Running the Docker Container

```bash
docker run -p 8085:8085 talentradar/config-server:latest
```

## Deployment

The application is automatically deployed to AWS ECS when code is merged into environment-specific branches:

- `development` branch → Development environment
- `staging` branch → Staging environment
- `production` branch → Production environment

See [DEPLOYMENT.md](.github/DEPLOYMENT.md) for more details about the deployment process.
