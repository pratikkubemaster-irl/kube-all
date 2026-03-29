@echo off
REM Build and Push Docker Image Script (Windows Batch)
REM Usage: build-docker.bat [registry-url] [tag]

setlocal enabledelayedexpansion

if "%1"=="" (
    set ImageName=hello-world-app:1.0.0
) else if "%2"=="" (
    set ImageName=%1:1.0.0
) else (
    set ImageName=%1:%2
)

echo Building Docker image: !ImageName!
docker build -t !ImageName! .

if %ERRORLEVEL% EQU 0 (
    echo ✓ Docker image built successfully
    
    REM Check if registry URL is provided
    if not "%1"=="hello-world-app" (
        echo Pushing image to registry...
        docker push !ImageName!
        
        if %ERRORLEVEL% EQU 0 (
            echo ✓ Image pushed successfully
        ) else (
            echo ✗ Failed to push image
            exit /b 1
        )
    )
) else (
    echo ✗ Failed to build Docker image
    exit /b 1
)

echo.
echo Next steps:
echo 1. Update image reference in k8s/deployment.yaml if needed
echo 2. Deploy: kubectl apply -f k8s/
echo 3. Verify: kubectl get pods -l app=hello-world
