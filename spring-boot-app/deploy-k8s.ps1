# Deploy to Kubernetes Script (PowerShell)
# Usage: .\deploy-k8s.ps1 [namespace] [image]

param(
    [string]$Namespace = "default",
    [string]$Image = "hello-world-app:1.0.0"
)

Write-Host "Deploying to namespace: $Namespace" -ForegroundColor Green
Write-Host "Using image: $Image" -ForegroundColor Green

# Create namespace if needed
kubectl create namespace $Namespace --dry-run=client -o yaml | kubectl apply -f -

# Update deployment with correct image
$deploymentPath = "k8s/deployment.yaml"
$content = Get-Content $deploymentPath -Raw
$content = $content -replace 'image: hello-world-app:[^\s]+', "image: $Image"
Set-Content $deploymentPath $content

# Apply manifests
Write-Host "Applying ConfigMap..." -ForegroundColor Yellow
kubectl apply -n $Namespace -f k8s/configmap.yaml

Write-Host "Applying Deployment..." -ForegroundColor Yellow
kubectl apply -n $Namespace -f k8s/deployment.yaml

Write-Host "Applying Service..." -ForegroundColor Yellow
kubectl apply -n $Namespace -f k8s/service.yaml

Write-Host ""
Write-Host "✓ Deployment complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Check deployment status:" -ForegroundColor Yellow
Write-Host "kubectl get all -n $Namespace -l app=hello-world"
Write-Host ""
Write-Host "View logs:" -ForegroundColor Yellow
Write-Host "kubectl logs -n $Namespace -l app=hello-world -f"
Write-Host ""
Write-Host "Port forward:" -ForegroundColor Yellow
Write-Host "kubectl port-forward -n $Namespace svc/hello-world-app 8080:80"
