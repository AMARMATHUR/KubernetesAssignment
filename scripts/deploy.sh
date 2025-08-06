#!/bin/bash

echo "Deploying Employee Service to Kubernetes..."

# Apply namespace
echo "Creating namespace..."
kubectl apply -f k8s/namespace.yaml

# Apply ConfigMap and Secret
echo "Creating ConfigMap and Secret..."
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secret.yaml

# Apply Persistent Volume
echo "Creating Persistent Volume..."
kubectl apply -f k8s/postgres-pv.yaml

# Deploy PostgreSQL
echo "Deploying PostgreSQL..."
kubectl apply -f k8s/postgres-deployment.yaml

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/postgres-deployment -n employee-system

# Deploy API
echo "Deploying Employee API..."
kubectl apply -f k8s/api-deployment.yaml

# Wait for API to be ready
echo "Waiting for Employee API to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/employee-api-deployment -n employee-system

# Apply Ingress
echo "Creating Ingress..."
kubectl apply -f k8s/ingress.yaml

echo "Deployment completed!"
echo "You can check the status with:"
echo "kubectl get all -n employee-system"
