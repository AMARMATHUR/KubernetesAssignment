#!/bin/bash

echo "Cleaning up Employee Service deployment..."

# Delete all resources
kubectl delete -f k8s/ingress.yaml
kubectl delete -f k8s/api-deployment.yaml
kubectl delete -f k8s/postgres-deployment.yaml
kubectl delete -f k8s/postgres-pv.yaml
kubectl delete -f k8s/secret.yaml
kubectl delete -f k8s/configmap.yaml
kubectl delete -f k8s/namespace.yaml

echo "Cleanup completed!"
