# Running Services inside minikube

## List of services
 
| Service           | Port          |
| ----------------- |:-------------:|
| Localstack UI     | 30100         |
| secretsmanager    | 30110         |
| cloudformation    | 30120         |
| dynamodb          | 30130         |
| redis             | 31100         |
| postgres          | 31200         |
| sonar             | 31210         |

# Local Makefile

This directory contains local development and deployment targets.

## Location
`core-config/local/makefile`

## Prerequisites
- Homebrew for package installation

## Available Targets

### Setup and Installation
- `init` - Install and configure Minikube with Docker driver
- `install-kvm` - Install KVM virtualization
- `install-minikube` - Install Minikube and dependencies
- `install-localstack` - Install Localstack using Homebrew

### Kubernetes Deployments
- `deploy-localstack` - Deploy Localstack to Minikube
- `deploy-redis` - Deploy Redis to Minikube
- `deploy-pv` - Deploy persistent volumes
- `deploy-postgres` - Deploy PostgreSQL to Minikube

### Development
- `local-build` - Build core-config locally
- `local-test` - Run local tests

### Utilities
- `ip` - Show current IP address
- `info` - Show available targets


## Installation Order
1. Run `make install-kvm` (if needed)
2. Run `make install-minikube`
3. Run `make init`
4. Run `make install-localstack` (if needed)
5. Deploy required services using deploy-* targets