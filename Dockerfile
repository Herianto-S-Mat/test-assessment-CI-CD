# === Build Stage ===
FROM eclipse-temurin:17-jdk AS build

WORKDIR /app

# Salin file konfigurasi Maven
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .

# Unduh dependencies (caching step)
RUN ./mvnw dependency:go-offline -B

# Salin source code
COPY src src

# Build aplikasi
RUN ./mvnw clean package -DskipTests

# === Runtime Stage ===
FROM eclipse-temurin:17-jre

# Install curl (untuk health check)
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Buat user non-root
RUN addgroup --system spring && adduser --system spring --ingroup spring

WORKDIR /app

# Salin JAR dari stage sebelumnya
COPY --from=build /app/target/assessment-*.jar app.jar

# Ubah ownership ke user non-root
RUN chown spring:spring app.jar

USER spring

EXPOSE 8080

# Health check endpoint
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

ENTRYPOINT ["java", "-jar", "app.jar"]
