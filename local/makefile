# All the targets have been tested on macOS system
#=========================================================================================== 
# VARIABLES
#===========================================================================================

APP 				?= bk-config
.DEFAULT_GOAL 		=  info
MAKEFILE_DIRECTORY 	:= $(dir $(realpath $(firstword $(MAKEFILE_LIST))))

#=========================================================================================== 
# Info on available targets
#===========================================================================================

local-help:
	@echo "Local targets:"
	@echo "	install-docker 			installs docker desktop"
	@echo "	install-minikube 		installs minikube"
	@echo "	deploy-localstack		deploys localstack inside minikube"
	@echo "	deploy-redis		  	deploys redis inside minikube"
	@echo "	deploy-pv		  	deploys persistent volume"
	@echo "	deploy-postgres		  	deploys postgres inside minikube"
	@echo "	local-build		  	builds core-config locally"
	@echo "	local-test		  	runs core-config tests"
	@echo "	init		  		installs and configures minikube"
	@echo "	install-localstack		installs localstack"

local-help-silent:
	@awk '/^[a-zA-Z0-9_-]+:/ { \
		if (match(lastLine, /^## (.*)/)) { \
			printf "  %-20s %s\n", substr($$1, 1, length($$1)-1), substr(lastLine, 4); \
		} \
	} { lastLine = $$0 }' $(MAKEFILE_LIST)

#=========================================================================================== 
# Docker and minikube
#===========================================================================================

.PHONY: install-minikube install-docker init install-localstack clean-localstack

## Install Docker Desktop for macOS
install-docker:
	@if ! command -v docker &> /dev/null; then \
		brew install --cask docker; \
		echo "Docker Desktop installed successfully"; \
	else \
		echo "Docker Desktop is already installed"; \
	fi

## Install Minikube and dependencies
install-minikube:
	@if ! command -v kubectl &> /dev/null; then \
		brew install kubectl; \
	fi
	@if ! command -v minikube &> /dev/null; then \
		brew install minikube; \
	fi

ip:
	@ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}'

#===========================================================================================
# Deploy: localstack
#===========================================================================================	

deploy-localstack:
	@kubectl apply -k $(MAKEFILE_DIRECTORY)kubernetes/localstack

#===========================================================================================
# Deploy: redis
#===========================================================================================	

deploy-redis:
	@kubectl apply -k $(MAKEFILE_DIRECTORY)kubernetes/redis

#===========================================================================================
# Deploy: persistent volume
#===========================================================================================	

deploy-pv:
	@kubectl apply -k $(MAKEFILE_DIRECTORY)kubernetes/pv

#===========================================================================================
# Deploy: postgres
#===========================================================================================	

deploy-postgres:
	@kubectl apply -k $(MAKEFILE_DIRECTORY)kubernetes/postgres

# Local targets specific to core-config

# local-build:
# 	@echo "Building core-config locally"
# 	@go build ./...

# local-test:
# 	@echo "Testing core-config locally"
# 	@go test ./... -v

init:
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
	@minikube start --driver=docker \
		--cpus=4 \
		--memory=7168 \
		--disk-size=20g || (echo "Error: Failed to start Minikube" && exit 1)
	@echo "Enabling addons..."
	@minikube addons enable ingress
	@minikube addons enable metrics-server
	@echo "Setup complete! Minikube is ready."
	$(eval miniIP := $(shell minikube ip))

install-localstack:
	@if ! command -v localstack &> /dev/null; then \
		brew install localstack; \
		echo "Localstack installed successfully"; \
	else \
		echo "Localstack is already installed"; \
	fi

clean-localstack:
	@echo "Cleaning up LocalStack..."
	@kubectl delete -f kubernetes/localstack/deployment.yaml --ignore-not-found
	@echo "LocalStack cleanup complete"