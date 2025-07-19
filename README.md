# TalentRadar Config Server

This repository contains the Config Server for the TalentRadar application, which serves configuration properties to all microservices in the TalentRadar ecosystem.

## Technologies

- Java 21
- Spring Boot 3.2
- Spring Cloud Config Server
- Docker

## ⚠️ Configuration Caching

This config server implements caching to improve performance and reduce load on the remote Git repository:

- **Cache Duration**: 5 minutes (300 seconds)
- **Cache Type**: Caffeine (in-memory)
- **Cache Specification**: Maximum 1000 entries, expire after write
- **Git Refresh Rate**: 300 seconds

**Important**: Configuration changes in the remote repository will not be reflected immediately. There may be up to a 5-minute delay before changes are served to client applications. For immediate configuration updates, restart the config server or wait for the cache to expire.

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
