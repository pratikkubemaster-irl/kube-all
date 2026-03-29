# Hello World Spring Boot App

A simple Spring Boot application designed as a basic building block for testing Kubernetes features on AKS.

## 📋 Features

- **Simple REST API** - Multiple endpoints for testing
- **Health Checks** - Liveness and readiness probes configured
- **Resource Limits** - CPU and memory limits defined
- **Security Context** - Non-root user and security best practices
- **ConfigMap Integration** - Externalized configuration
- **Multi-stage Docker Build** - Optimized image size
- **Kubernetes Ready** - Complete manifests included

## 🚀 Getting Started

### Prerequisites
- Java 17
- Maven 3.9+
- Docker (for building images)
- kubectl configured for AKS cluster

### Build Locally

```bash
# Navigate to the app directory
cd spring-boot-app

# Build with Maven
mvn clean package

# Run the application
java -jar target/hello-world-app-1.0.0.jar
```

The app will run on `http://localhost:8080`

### Available Endpoints

- `GET /` - Welcome message
- `GET /hello/{name}` - Personalized greeting
- `GET /info` - Application information
- `GET /health` - Spring Boot actuator health
- `GET /actuator/health/liveness` - Kubernetes liveness check
- `GET /actuator/health/readiness` - Kubernetes readiness check
- `GET /actuator/metrics` - Metrics endpoint

## 🐳 Docker Build and Push

### Build Docker Image

```bash
# Build the image
docker build -t hello-world-app:1.0.0 .

# Or tag for your registry (e.g., ACR)
docker build -t <your-registry>.azurecr.io/hello-world-app:1.0.0 .

# Push to registry
docker push <your-registry>.azurecr.io/hello-world-app:1.0.0
```

### Build Script (Windows)

```powershell
# Run the build-and-push script
.\build-docker.ps1
```

## ☸️ Deploy to Kubernetes

### Prerequisites
- Update image reference in `k8s/deployment.yaml` if using a custom registry

### Deploy

```bash
# Create ConfigMap
kubectl apply -f k8s/configmap.yaml

# Deploy application
kubectl apply -f k8s/deployment.yaml

# Create service
kubectl apply -f k8s/service.yaml

# Or apply all at once
kubectl apply -f k8s/
```

### Verify Deployment

```bash
# Check pods
kubectl get pods -l app=hello-world

# Check pod details
kubectl describe pod <pod-name>

# Check logs
kubectl logs -f <pod-name>

# Check services
kubectl get svc hello-world-app

# Check deployment
kubectl get deployment hello-world-app
```

### Test the Application

```bash
# Port forward to access the service
kubectl port-forward svc/hello-world-app 8080:80

# In another terminal, test endpoints
curl http://localhost:8080/
curl http://localhost:8080/hello/Kubernetes
curl http://localhost:8080/info
curl http://localhost:8080/actuator/health
```

## 🧪 Testing Kubernetes Features

This app can be used to test:

### Scaling
```bash
# Scale replicas
kubectl scale deployment hello-world-app --replicas=3
```

### Rolling Updates
```bash
# Update image (e.g., deploy new version)
kubectl set image deployment/hello-world-app \
  hello-world-app=hello-world-app:1.1.0
```

### Resource Management
```bash
# Check resource usage
kubectl top pod
kubectl describe node
```

### Health Probes
```bash
# The deployment includes:
# - Liveness probe: /actuator/health/liveness
# - Readiness probe: /actuator/health/readiness
# Monitor probe behavior with:
kubectl get events
kubectl describe pod <pod-name>
```

### Logs and Debugging
```bash
# View logs
kubectl logs <pod-name>

# Follow logs
kubectl logs -f <pod-name>

# Get shell access
kubectl exec -it <pod-name> -- sh
```

## 📊 Monitoring

The app exposes metrics on `/actuator/metrics`. You can:

```bash
# View all available metrics
curl http://localhost:8080/actuator/metrics

# View specific metric
curl http://localhost:8080/actuator/metrics/jvm.memory.used
```

## 🔧 Customization

### Update Configuration
Edit `src/main/resources/application.yml` to customize:
- Application name and version
- Server port
- Management endpoints
- Actuator configuration

### Update ConfigMap
Edit `k8s/configmap.yaml` to change:
- Application name and version
- Environment variables
- Any other configuration

## 📝 Project Structure

```
spring-boot-app/
├── src/
│   └── main/
│       ├── java/com/example/hello/
│       │   ├── HelloWorldApplication.java
│       │   └── HelloController.java
│       └── resources/
│           └── application.yml
├── k8s/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── configmap.yaml
├── Dockerfile
├── pom.xml
└── README.md
```

## 🛠️ Troubleshooting

### Pods not starting
```bash
# Check pod status
kubectl describe pod <pod-name>

# View logs
kubectl logs <pod-name>
```

### Image pull errors
```bash
# Ensure image exists or update image reference
# Check image availability
docker images | grep hello-world-app
```

### Connection refused
```bash
# Check if service is running
kubectl get svc hello-world-app

# Check pod IP
kubectl get pods -o wide

# Test connectivity
kubectl exec -it <pod-name> -- curl localhost:8080/
```

## 📚 References

- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Docker Multi-stage Builds](https://docs.docker.com/build/building/multi-stage/)
- [AKS Documentation](https://learn.microsoft.com/en-us/azure/aks/)

## 📄 License

This project is part of the CKA Exam Preparation materials.
