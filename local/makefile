# All the targets have been tested on ubuntu system
#=========================================================================================== 
# VARIABLES
#===========================================================================================

APP 				?= bk-config
.DEFAULT_GOAL 		=  info
MAKEFILE_DIRECTORY 	:= $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
IP					:= $(shell ip addr | grep 'inet ' | grep -v 127.0.0.1 | head -1 | cut -d' ' -f6 | cut -d'/' -f1)
#=========================================================================================== 
# Info on available targets
#===========================================================================================

info:
	@echo "Available targets"
	@echo "	install-kvm 			installs kvm"
	@echo "	install-minikube 		installs minikube"
	@echo "	deploy-localstack		deploys localstack inside minikube"

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