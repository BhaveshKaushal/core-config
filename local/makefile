# All the targets have been tested on ubuntu system
#=========================================================================================== 
# VARIABLES
#===========================================================================================

APP 				?= bk-config
.DEFAULT_GOAL 		=  info
MAKEFILE_DIRECTORY 	:= $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
#=========================================================================================== 
# Info on available targets
#===========================================================================================

help:
	@echo "Available targets"
	@echo "	install-kvm 			installs kvm"
	@echo "	install-minikube 		installs minikube"
	@echo "	deploy-localstack		deploys localstack inside minikube"
	@echo "	deploy-redis		  	deploys redis inside minikube"

#=========================================================================================== 
#KVM and minikube
#===========================================================================================

# make sure vistualization is enabled, to enable virtualiztion go to BIOS --> System Configuration --> virtualization
# Verify if virtualization is enabled by running "egrep -c '(vmx|svm)' /proc/cpuinfo", if value is other than 0 then it's enabled
install-kvm:
	sudo apt-get update -y
	sudo apt install -y qemu qemu-kvm libvirt-daemon libvirt-clients bridge-utils virt-manager
	cat /etc/group | grep libvirt | awk -F':' {'print $1'} | xargs -n1 sudo adduser $USER
	sudo adduser $USER kvm
	exec su -l $USER id | grep libvirt

# Make sure kvm is installed  or run install-kvm target
# you might need to restart the system
install-minikube:
	curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && chmod +x kubectl && sudo mv kubectl /usr/bin/
	curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/
	sudo apt install libvirt-clients libvirt-daemon-system qemu-kvm
	curl -LO https://storage.googleapis.com/minikube/releases/latest/docker-machine-driver-kvm2 && sudo install docker-machine-driver-kvm2 /usr/local/bin/

ip:
	@echo $(IP)

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

local-build:
	@echo "Building core-config locally"
	@go build ./...

local-test:
	@echo "Testing core-config locally"
	@go test ./... -v


# Update init target in local makefile
init:
	@echo "Installing Minikube and Docker..."
	@if ! command -v docker &> /dev/null; then \
		brew install docker; \
		echo "Docker installed successfully"; \
	else \
		echo "Docker is already installed"; \
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

# Add localstack as a separate target
install-localstack:
	@if ! command -v localstack &> /dev/null; then \
		brew install localstack; \
		echo "Localstack installed successfully"; \
	else \
		echo "Localstack is already installed"; \
	fi