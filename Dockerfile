# Build stage: Compile the application
FROM maven:3.9-eclipse-temurin-21 AS builder

WORKDIR /build

# Copy pom.xml first for better caching
COPY pom.xml .
# Download dependencies (will be cached if pom.xml doesn't change)
RUN mvn dependency:go-offline -B

# Copy source code
COPY src ./src/

# Build the application
RUN mvn package -DskipTests

# Runtime stage: Setup the actual runtime environment
FROM bellsoft/liberica-openjre-debian:21-cds

# Add metadata
LABEL maintainer="AmaliTech Training Academy" \
    description="TalentRadar Config Server" \
    version="1.0"

# Set environment variables
ENV SPRING_PROFILES_ACTIVE=production
ENV SPRING_CLOUD_CONFIG_SERVER_GIT_URI=https://github.com/AmaliTech-Training-Academy/talentradar-config-repo-rw.git
ENV SPRING_CLOUD_CONFIG_SERVER_GIT_DEFAULT_LABEL=development
ENV SERVER_PORT=8085
# Cache configuration - cache for 5 minutes (300 seconds)
ENV SPRING_CLOUD_CONFIG_SERVER_GIT_REFRESH_RATE=300
ENV SPRING_CACHE_CACHE_NAMES=config
ENV SPRING_CACHE_TYPE=caffeine
ENV SPRING_CACHE_CAFFEINE_SPEC=maximumSize=1000,expireAfterWrite=300s

# Create a non-root user
RUN useradd -r -u 1001 -g root configserver

WORKDIR /application

# Copy the extracted layers from the build stage
COPY --from=builder --chown=configserver:root /build/target/*.jar ./application.jar

# Configure container
USER 1001
EXPOSE 8085

# Use the standard JAR execution
ENTRYPOINT ["java", "-XX:+UseContainerSupport", "-XX:MaxRAMPercentage=75.0", "-Djava.security.egd=file:/dev/./urandom", "-jar", "application.jar"]
