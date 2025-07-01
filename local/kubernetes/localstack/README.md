# LocalStack Kubernetes Setup

This directory contains Kubernetes configurations for running LocalStack in a local development environment.

## Overview

LocalStack provides a local AWS cloud stack for development and testing. This setup includes:
- Persistent volume storage for data retention
- Single edge port (4566) for all AWS services
- Support for multiple AWS services (secretsmanager, cloudformation, dynamodb)
- Resource limits and health monitoring

## Prerequisites

- Kubernetes cluster (Minikube/Docker Desktop)
- kubectl CLI tool
- At least 1GB of available memory
- 500m CPU cores

## Installation

Deploy LocalStack using the existing make target:
```bash
make deploy-localstack
```

To remove LocalStack:
```bash
make clean-localstack
```

## Accessing LocalStack

Since LocalStack is running inside Minikube, you need to use the Minikube IP to access it:

```bash
# Get the Minikube IP
minikube ip
```

Then access LocalStack at:
- Main endpoint: `http://<minikube-ip>:30100`
- Health check: `http://<minikube-ip>:30100/_localstack/health`

Alternatively, you can get the URL directly using:
```bash
minikube service localstack --url
```

## AWS CLI Configuration

Configure AWS CLI to use LocalStack (replace <minikube-ip> with actual IP):
```bash
aws configure set aws_access_key_id test
aws configure set aws_secret_access_key test
aws configure set region us-east-1

# Example command using Minikube IP
aws --endpoint-url=http://<minikube-ip>:30100 s3 ls
```

## Available Services

The following AWS services are enabled:
- Secrets Manager
- CloudFormation
- DynamoDB

To enable additional services, update the `SERVICES` environment variable in the deployment configuration.

## Persistence

Data is persisted using a PersistentVolume mounted at `/var/lib/localstack`. The volume size is 5GB.

## Troubleshooting

1. Check pod status:
```bash
kubectl describe pod -l app=localstack
```

2. View logs:
```bash
kubectl logs -l app=localstack
```

3. Common issues:
   - If pod fails to start, check resource limits
   - If services are unreachable, verify the NodePort is accessible
   - For persistence issues, check PV/PVC status

## Resource Management

The deployment is configured with the following resource limits:
- Memory: 512Mi (request) / 1Gi (limit)
- CPU: 500m (request) / 1000m (limit)

Adjust these values in the deployment configuration if needed.

## Cleanup

To remove the LocalStack deployment:
```bash
kubectl delete -f deployment.yaml
```

## Version Information

- LocalStack Image: 3.0
- Last Updated: [Current Date] 