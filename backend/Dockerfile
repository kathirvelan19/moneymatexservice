# ========================================================
# MoneyMateX Service - Multi-Stage Dockerfile (Backend Root)
# Optimized for Render deployment when Root Directory is set to 'backend'
# ========================================================

# Stage 1: Build Spring Boot Application
FROM maven:3.9.6-eclipse-temurin-17 AS builder
WORKDIR /workspace

# Pre-cache Maven dependencies
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source code and build executable JAR
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Lightweight JRE 17 Runtime
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Run as non-privileged service user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# Copy built application jar
COPY --from=builder /workspace/target/*.jar app.jar

# Render supplies the PORT environment variable (default fallback 8080)
ENV PORT=8080
EXPOSE ${PORT}

# Liveness probe
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://127.0.0.1:${PORT}/health || exit 1

# Launch Spring Boot with dynamic port binding
ENTRYPOINT ["sh", "-c", "java -Dserver.port=${PORT} -Dserver.address=0.0.0.0 -jar app.jar"]
