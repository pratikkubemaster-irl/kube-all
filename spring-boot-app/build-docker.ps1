# Build and Push Docker Image Script
# Usage: .\build-docker.ps1 [registry-url] [tag]

param(
    [string]$RegistryUrl = "hello-world-app",
    [string]$Tag = "1.0.0"
)

$ImageName = "$RegistryUrl`:$Tag"

Write-Host "Building Docker image: $ImageName" -ForegroundColor Green

# Build the image
docker build -t $ImageName .

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Docker image built successfully" -ForegroundColor Green
    
    # Optionally push to registry
    if ($RegistryUrl -ne "hello-world-app") {
        Write-Host "Pushing image to registry..." -ForegroundColor Green
        docker push $ImageName
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ Image pushed successfully" -ForegroundColor Green
        } else {
            Write-Host "✗ Failed to push image" -ForegroundColor Red
            exit 1
        }
    }
} else {
    Write-Host "✗ Failed to build Docker image" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Update image reference in k8s/deployment.yaml if needed"
Write-Host "2. Deploy: kubectl apply -f k8s/"
Write-Host "3. Verify: kubectl get pods -l app=hello-world"
