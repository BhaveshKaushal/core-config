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

#=========================================================================================== 
# Docker and minikube
#===========================================================================================

.PHONY: install-minikube install-docker init install-localstack

install-docker:
	@if ! command -v docker &> /dev/null; then \
		brew install --cask docker; \
		echo "Docker Desktop installed successfully. Please start Docker Desktop application."; \
	else \
		echo "Docker Desktop is already installed"; \
	fi

install-minikube:
	@echo "Installing kubectl and minikube..."
	@if ! command -v kubectl &> /dev/null; then \
		brew install kubectl; \
		echo "kubectl installed successfully"; \
	else \
		echo "kubectl is already installed"; \
	fi
	@if ! command -v minikube &> /dev/null; then \
		brew install minikube; \
		echo "minikube installed successfully"; \
	else \
		echo "minikube is already installed"; \
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
	@echo "Installing Minikube and Docker..."
	@if ! command -v docker &> /dev/null; then \
		brew install --cask docker; \
		echo "Docker Desktop installed successfully. Please start Docker Desktop application."; \
	else \
		echo "Docker Desktop is already installed"; \
	fi
	@if ! command -v minikube &> /dev/null; then \
		brew install minikube; \
		echo "Minikube installed successfully"; \
	else \
		echo "Minikube is already installed"; \
	fi
	@echo "Starting Minikube with Docker driver..."
	@minikube start --driver=docker || true
	@echo "Minikube is ready"
	$(eval miniIP := $(shell minikube ip))

install-localstack:
	@if ! command -v localstack &> /dev/null; then \
		brew install localstack; \
		echo "Localstack installed successfully"; \
	else \
		echo "Localstack is already installed"; \
	fi