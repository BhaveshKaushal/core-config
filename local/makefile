# All the targets have been tested on macOS system
#=========================================================================================== 
# VARIABLES
#===========================================================================================

APP 				?= bk-config
.DEFAULT_GOAL 		=  info
LOCAL_MAKEFILE := $(lastword $(MAKEFILE_LIST))
LOCAL_MAKEFILE_PATH := $(realpath $(LOCAL_MAKEFILE))
MAKEFILE_DIRECTORY := $(dir $(LOCAL_MAKEFILE_PATH))

#=========================================================================================== 
# Info on available targets
#===========================================================================================

## Display local targets help
local-help:
	@echo "Available targets:\n"
	@echo "Local targets:"
	@awk -F':' '/^[a-zA-Z0-9_-]+:/ { \
		if (match(lastLine, /^## (.*)/)) { \
			target = substr($$1, 1); \
			desc = substr(lastLine, 4); \
			printf "    %-20s %s\n", target, desc; \
		} \
	} { lastLine = $$0 }' $(MAKEFILE_LIST)

## Display targets without formatting (for scripting)
local-help-silent:
	@awk -F':' '/^[a-zA-Z0-9_-]+:/ { \
		if (match(lastLine, /^## (.*)/)) { \
			target = substr($$1, 1); \
			printf "    %s\n", target; \
		} \
	} { lastLine = $$0 }' $(MAKEFILE_LIST)

#=========================================================================================== 
# Docker and minikube
#===========================================================================================

.PHONY: install-minikube install-docker init install-localstack clean-localstack

## Show information about the Application
localinfo:
	@echo "$$HELP_MESSAGE"

## Install Docker Desktop for macOS
install-docker:
	@if ! command -v docker &> /dev/null; then \
		brew install --cask docker; \
		echo "Docker Desktop installed successfully"; \
	else \
		echo "Docker Desktop is already installed"; \
	fi

## Install Minikube and required dependencies
install-minikube:
	@if ! command -v kubectl &> /dev/null; then \
		brew install kubectl; \
	fi
	@if ! command -v minikube &> /dev/null; then \
		brew install minikube; \
	fi

## Start Minikube cluster with Docker driver
start-minikube:
	@if command -v minikube &> /dev/null; then \
		echo "Starting Minikube with Docker driver..."; \
		minikube start --driver=docker \
			--cpus=4 \
			--memory=7168 \
			--disk-size=20g || (echo "Error: Failed to start Minikube" && exit 1); \
		echo "Enabling addons..."; \
		minikube addons enable ingress; \
		minikube addons enable metrics-server; \
		echo "Minikube is ready!"; \
	else \
		echo "Minikube is not installed. Please run 'make install-minikube' first."; \
	fi

## Display host machine IP address
ip:
	@ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}'

#===========================================================================================
# Deploy: localstack
#===========================================================================================	

## Deploy LocalStack services to Kubernetes cluster
deploy-localstack:
	@echo "Deploying LocalStack..."
	@kubectl apply -k $(MAKEFILE_DIRECTORY)kubernetes/localstack
	@echo "LocalStack deployment complete"

#===========================================================================================
# Deploy: redis
#===========================================================================================	

## Deploy Redis to Kubernetes cluster
deploy-redis:
	@kubectl apply -k $(MAKEFILE_DIRECTORY)kubernetes/redis

#===========================================================================================
# Deploy: persistent volume
#===========================================================================================	

## Deploy persistent volumes to Kubernetes cluster
deploy-pv:
	@kubectl apply -k $(MAKEFILE_DIRECTORY)kubernetes/pv

#===========================================================================================
# Deploy: postgres
#===========================================================================================	

## Deploy PostgreSQL to Kubernetes cluster
deploy-postgres:
	@kubectl apply -k $(MAKEFILE_DIRECTORY)kubernetes/postgres


## Initialize development environment with Docker and Minikube
init: install-docker install-minikube
	@echo "Checking prerequisites..."
	@if [ ! -d "/Applications/Docker.app" ]; then \
		echo "Docker Desktop is not installed. Installing..."; \
		brew install --cask docker; \
	else \
		echo "Docker Desktop is already installed."; \
	fi
	@echo "Starting Docker Desktop..."
	@if ! docker info > /dev/null 2>&1; then \
		if [ -d "/Applications/Docker.app" ]; then \
			open /Applications/Docker.app; \
			echo "Waiting for Docker to start..."; \
			for i in {1..30}; do \
				if docker info > /dev/null 2>&1; then \
					echo "Docker is running!"; \
					break; \
				fi; \
				echo "Still waiting... ($$i/30)"; \
				sleep 2; \
			done; \
			if ! docker info > /dev/null 2>&1; then \
				echo "Docker failed to start within 60 seconds"; \
				exit 1; \
			fi; \
		else \
			echo "Error: Docker Desktop is not found in /Applications."; \
			echo "Please ensure Docker Desktop is installed correctly."; \
			exit 1; \
		fi; \
	fi
	@echo "Docker is running, proceeding with Minikube..."
	@if ! command -v minikube &> /dev/null; then \
		brew install minikube; \
	fi
	@echo "Starting Minikube..."
	@minikube start \
		--cpus=4 \
		--memory=7168 \
		--disk-size=20g || (echo "Error: Failed to start Minikube" && exit 1)
	@echo "Enabling addons..."
	@minikube addons enable ingress
	@minikube addons enable metrics-server
	@echo "Setup complete! Minikube is ready."
	$(eval miniIP := $(shell minikube ip))


## Remove LocalStack deployment and clean up resources
clean-localstack:
	@echo "Cleaning up LocalStack..."
	@kubectl delete -k $(MAKEFILE_DIRECTORY)kubernetes/localstack
	@echo "LocalStack cleanup complete"

# You can verify the path with:
debug-path:
	@echo "Local Makefile: $(LOCAL_MAKEFILE)"
	@echo "Full path: $(LOCAL_MAKEFILE_PATH)"
	@echo "Directory: $(MAKEFILE_DIRECTORY)"

## Get LocalStack URL and status
localstack-status:
	@echo "Checking LocalStack status..."
	@echo "Pod status:"
	@kubectl get pods -n localstack -l app=localstack
	@echo "\nService status:"
	@kubectl get svc localstack -n localstack
	@echo "\nLocalStack URL:"
	@echo "http://$(shell minikube ip):30100"
	@echo "\nPod logs:"
	@kubectl logs -l app=localstack -n localstack --tail=20


## Portforwarding for localstack
localstack-portforward:
	@kubectl port-forward svc/localstack 4566:4566 -n localstack

