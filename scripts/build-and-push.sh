#!/bin/bash

# Configuration
DOCKER_USERNAME="amarmathur"
IMAGE_NAME="employee-api"
TAG="latest"

echo "Building and pushing Employee API Docker image..."

# Navigate to the API directory
cd src/EmployeeService.API

# Build Docker image
echo "Building Docker image..."
docker build -t $DOCKER_USERNAME/$IMAGE_NAME:$TAG .

# Tag the image
docker tag $DOCKER_USERNAME/$IMAGE_NAME:$TAG $DOCKER_USERNAME/$IMAGE_NAME:$TAG

# Push to Docker Hub
echo "Pushing to Docker Hub..."
docker push $DOCKER_USERNAME/$IMAGE_NAME:$TAG

echo "Docker image build and push completed!"
echo "Image: $DOCKER_USERNAME/$IMAGE_NAME:$TAG"

# Go back to root directory
cd ../..
