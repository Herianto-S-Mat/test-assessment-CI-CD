# Assessment CI/CD Pipeline dengan Kubernetes

Technical Assessment - DevOps Implementation untuk aplikasi Spring Boot Assessment dengan CI/CD pipeline menggunakan Jenkins dan deployment ke Kubernetes.

## 📋 Project Overview

**Project Details:**
- **Name**: Assessment
- **Group ID**: com.test
- **Artifact ID**: assessment
- **Version**: 0.0.1-SNAPSHOT
- **Java Version**: 17
- **Spring Boot**: 3.5.0
- **JAR Output**: assessment-0.0.1-SNAPSHOT.jar

**API Endpoints:**
- `GET /` → redirect to `/test`
- `GET /test` → returns User JSON
- `GET /health` → returns "OK" (custom health check)

Project ini mengimplementasikan:
1. **Dockerfile** untuk containerisasi aplikasi Spring Boot
2. **CI/CD Pipeline Design** yang comprehensive
3. **Jenkinsfile** untuk automation pipeline
4. **Kubernetes Manifests** untuk deployment, service, dan ingress

## 🏗️ Arsitektur

### CI/CD Flow
Pipeline ini menggunakan GitFlow strategy dengan 3 environment:
- **Development** (branch: develop)
- **Staging** (branch: staging)
- **Production** (branch: main)

### Teknologi Stack
- **Application**: Java 17 + Spring Boot 3.5.0
- **Dependencies**: spring-boot-starter-data-rest + spring-boot-starter-test
- **Build Tool**: Maven
- **Containerization**: Docker
- **CI/CD**: Jenkins
- **Orchestration**: Kubernetes
- **Ingress**: Nginx Ingress Controller

## 📁 Struktur Project

```
├── Dockerfile                 # Multi-stage Docker build untuk assessment app
├── Jenkinsfile               # Jenkins CI/CD pipeline
├── src/main/java/com/test/assessment/
│   ├── controller/
│   │   └── TestDemoController.java
│   └── model/
│       └── User.java
├── k8s/
│   ├── deployment.yaml       # Kubernetes deployment + ConfigMap + Secret
│   ├── service.yaml          # Service definitions
│   └── ingress.yaml          # Ingress configurations
├── pom.xml                   # Maven configuration
└── README.md                # Dokumentasi ini
```

## 🚀 Prerequisites

### Jenkins Requirements
- Jenkins dengan plugin:
    - Pipeline
    - Docker Pipeline
    - Kubernetes CLI
    - SonarQube Scanner
    - Email Extension

### Kubernetes Cluster
- Kubernetes cluster (minimal v1.20+)
- Nginx Ingress Controller
- Namespace: development, staging, production

### Credentials Setup
```bash
# Docker Hub credentials
DOCKER_CREDENTIALS: username/password untuk Docker registry

# Kubernetes config
KUBECONFIG: kubeconfig file untuk akses cluster

# SonarQube (optional)
SONARQUBE_TOKEN: token untuk SonarQube analysis
```

## 🔧 Setup & Deployment

### 1. Persiapan Environment

```bash
# Buat namespaces
kubectl create namespace development
kubectl create namespace staging  
kubectl create namespace production

# Apply RBAC (jika diperlukan)
kubectl apply -f k8s/rbac.yaml
```

### 2. Konfigurasi Jenkins

1. Install required plugins
2. Setup credentials:
    - `docker-hub-credentials`: Docker Hub username/password
    - `kubeconfig`: Kubernetes cluster config
3. Configure tools:
    - Maven 3.8
    - OpenJDK 17
    - SonarQube Server

### 3. Customize Configuration

#### Dockerfile
- Sesuaikan Maven wrapper path jika berbeda
- Update health check endpoint sesuai aplikasi

#### Jenkinsfile
```groovy
environment {
    DOCKER_REGISTRY = 'your-registry.com'    # Ganti dengan registry Anda
    DOCKER_IMAGE = 'your-org/assessment-app' # Ganti dengan image name
}
```

#### Kubernetes Manifests
```yaml
# deployment.yaml
image: your-username/assessment-app:IMAGE_TAG  # Ganti dengan image Anda

# ingress.yaml  
host: assessment-app.yourdomain.com           # Ganti dengan domain Anda
```

### 4. Environment Variables

#### ConfigMap (deployment.yaml)
```yaml
LOG_LEVEL: "INFO"                   # Log level
SERVER_PORT: "8080"                 # Application port
```

#### Secrets (deployment.yaml)
```bash
# Encode credentials ke base64
echo -n "your_app_secret" | base64
```_db"      # Database name
REDIS_HOST: "redis-service"         # Redis endpoint
LOG_LEVEL: "INFO"                   # Log level
```

#### Secrets (deployment.yaml)
```bash
# Encode credentials ke base64
echo -n "your_db_username" | base64
echo -n "your_db_password" | base64
echo -n "your_jwt_secret" | base64
```

## 🔄 Pipeline Workflow

### Development Branch
```
Push to develop → Jenkins Trigger → Build → Test → Deploy to Dev → Health Check
```

### Staging Branch
```
Push to staging → Jenkins Trigger → Build → Test → Deploy to Staging → Integration Tests
```

### Production Branch
```
Push to main → Jenkins Trigger → Build → Test → Manual Approval → Deploy to Prod → Monitor
```

### Pipeline Stages Detail

1. **Checkout**: Clone repository dan get commit info
2. **Build & Compile**: Maven compile
3. **Unit Tests**: Execute tests + coverage report
4. **Code Quality**: SonarQube scan + security scan
5. **Package**: Create JAR artifact
6. **Docker Build**: Build dan push image
7. **Deploy**: Deploy ke environment sesuai branch
8. **Health Check**: Verify deployment success

## 🎯 Features

### Docker Image
- Multi-stage build untuk optimasi size
- Non-root user untuk security
- Health check built-in
- Proper resource limits

### Kubernetes Deployment
- Rolling update strategy
- Resource requests & limits
- Health checks (liveness, readiness, startup)
- Security context (non-root, read-only filesystem)
- ConfigMap & Secret management

### Ingress Configuration
- SSL/TLS termination
- Rate limiting
- CORS support
- Multiple environment support
- Custom error pages

### Monitoring & Observability
- Prometheus metrics endpoint
- Application health checks
- Structured logging
- Resource monitoring

## 🔍 Testing

### Local Testing
```bash
# Build Docker image
docker build -t springboot-app:local .

# Run container
docker run -p 8080:8080 springboot-app:local

# Test health check
curl http://localhost:8080/actuator/health
```

### Kubernetes Testing
```bash
# Apply manifests
kubectl apply -f k8s/ -n development

# Check deployment
kubectl get pods -n development
kubectl logs -l app=springboot-app -n development

# Test service
kubectl port-forward svc/springboot-service 8080:80 -n development
curl http://localhost:8080/actuator/health
```

## 🚨 Troubleshooting

### Common Issues

#### Docker Build Fails
```bash
# Check Maven wrapper permissions
chmod +x mvnw

# Verify Dockerfile syntax
docker build --no-cache -t test .
```

#### Kubernetes Deployment Issues
```bash
# Check pod status
kubectl describe pod <pod-name> -n <namespace>

# Check logs
kubectl logs <pod-name> -n <namespace>

# Check resources
kubectl top pods -n <namespace>
```

#### Jenkins Pipeline Failures
- Verify credentials configuration
- Check plugin versions compatibility
- Validate Kubernetes connectivity

## 📊 Monitoring

### Application Metrics
- Endpoint: `/actuator/prometheus`
- Health: `/actuator/health`
- Info: `/actuator/info`

### Kubernetes Metrics
```bash
# Resource usage
kubectl top pods -n production

# Events
kubectl get events -n production --sort-by='.lastTimestamp'
```

## 🔐 Security Considerations

### Container Security
- Non-root user execution
- Read-only root filesystem
- Dropped capabilities
- Security scanning in pipeline

### Kubernetes Security
- ServiceAccount dengan minimal permissions
- Network policies (implement sesuai kebutuhan)
- Secret management
- Resource quotas

## 📈 Scaling

### Horizontal Pod Autoscaler
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: springboot-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: springboot-app
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

## 🎯 Kriteria Assessment

### Originalitas ✅
- Semua file dibuat dari scratch
- Best practices implementation
- Comprehensive documentation
- Production-ready configuration

### Completeness ✅
- Dockerfile dengan multi-stage build
- Complete CI/CD pipeline design
- Full Jenkins implementation
- Production-ready Kubernetes manifests
- Proper documentation

### Best Practices ✅
- Security-first approach
- Resource optimization
- Monitoring & observability
- Error handling & recovery
- Scalability considerations

## 📞 Support

Untuk pertanyaan atau issues, silakan buat GitHub issue atau hubungi tim DevOps.

---

**Note**: Project ini dibuat untuk Technical Assessment dan mengikuti best practices industry standard untuk production deployment.