#!/bin/bash
echo "=== Deploying Census Analytics to Kubernetes ==="
echo ""

echo "1. Building Docker image..."
docker build -t census-analytics -f ../docker/Dockerfile ../

echo ""
echo "2. Applying Kubernetes manifests..."
kubectl apply -f .

echo ""
echo "3. Checking deployment..."
kubectl get deployments
kubectl get pods

echo ""
echo "4. Running test job..."
kubectl apply -f test-job.yaml
sleep 5
kubectl logs job/census-test-run --tail=20

echo ""
echo "=== Deployment Complete ==="
echo "To view pods: kubectl get pods"
echo "To view logs: kubectl logs -l app=census-analytics"
echo "To delete: kubectl delete -f ."