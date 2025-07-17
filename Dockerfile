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
RUN mvn package -DskipTests && \
    # Extract layers for better caching in final image
    java -Djarmode=tools -jar target/*.jar extract --layers --destination extracted

# Runtime stage: Setup the actual runtime environment
FROM bellsoft/liberica-openjre-debian:21-cds

# Add metadata
LABEL maintainer="AmaliTech Training Academy" \
    description="TalentRadar Config Server" \
    version="1.0"

# Set environment variables
ENV SPRING_PROFILES_ACTIVE=production
ENV SERVER_PORT=8085

# Create a non-root user
RUN useradd -r -u 1001 -g root configserver

WORKDIR /application

# Copy the extracted layers from the build stage
COPY --from=builder --chown=configserver:root /build/extracted/dependencies/ ./
COPY --from=builder --chown=configserver:root /build/extracted/spring-boot-loader/ ./
COPY --from=builder --chown=configserver:root /build/extracted/snapshot-dependencies/ ./
COPY --from=builder --chown=configserver:root /build/extracted/application/ ./

# Configure container
USER 1001
EXPOSE 8085

# Add health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
    CMD wget -q --spider http://localhost:8085/actuator/health || exit 1

# Set JVM options for containerized environments
ENTRYPOINT ["java", \
    "-XX:+UseContainerSupport", \
    "-XX:MaxRAMPercentage=75.0", \
    "-Djava.security.egd=file:/dev/./urandom", \
    "-jar", "application.jar"]