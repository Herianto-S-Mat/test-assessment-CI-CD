# Multi-stage build untuk optimasi ukuran image
FROM openjdk:17-jdk-slim AS build

# Set working directory
WORKDIR /app

# Copy Maven wrapper dan pom.xml
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .

# Download dependencies (untuk caching layer)
RUN ./mvnw dependency:go-offline -B

# Copy source code
COPY src src

# Build aplikasi
RUN ./mvnw clean package -DskipTests

# Runtime stage
FROM openjdk:17-jre-slim

# Install curl untuk health check
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Create non-root user untuk security
RUN addgroup --system spring && adduser --system spring --ingroup spring

# Set working directory
WORKDIR /app

# Copy JAR file dari build stage (assessment-0.0.1-SNAPSHOT.jar)
COPY --from=build /app/target/assessment-*.jar app.jar

# Change ownership ke spring user
RUN chown spring:spring app.jar

# Switch ke non-root user
USER spring

# Expose port
EXPOSE 8080

# Health check - menggunakan custom endpoint
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

# Run aplikasi
ENTRYPOINT ["java", "-jar", "app.jar"]