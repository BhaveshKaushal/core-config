# All the targets have been tested on ubuntu system
#-------------------------------------------------------------------------------------------
# VARIABLES
#-------------------------------------------------------------------------------------------
APP ?= core-config
.DEFAULT_GOAL = help
TIMEOUT ?= 30
DIR ?= ./...
POST_USER ?= postgres

# Only set IP variables if minikube is installed and running
IP := $(shell ifconfig | grep 'inet ' | grep -v '127.0.0.1' | head -n1 | awk '{print $$2}')
miniIP := $(shell minikube status >/dev/null 2>&1 && minikube ip 2>/dev/null || echo "minikube not running")

#-------------------------------------------------------------------------------------------
# INCLUDE LOCAL MAKEFILE
#-------------------------------------------------------------------------------------------
LOCAL_MAKEFILE := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))../local/makefile

ifneq (,$(wildcard $(LOCAL_MAKEFILE)))
include $(LOCAL_MAKEFILE)
endif

#---------------------------------------------------------------------------------------
# INFORMATION RELATED COMMANDS
#---------------------------------------------------------------------------------------

help:
	@echo "Common targets:"
	@echo " info                     Information about the Application"
	@echo " redis                    Run redis client for redis deployed in minikube"
	@echo " ddb-Admin                Run dynamodb for dynamodb deployed in minikube"
	@echo " secrets-list             List available secrets in deployed secretsmanager"
	@echo " clean                    Remove out folder"
	@echo " build                    build go package"
	@echo " build-exec               buiding an excutable"
	@echo " test                     Run tests"
	@echo " test-cover               Run tests with coverage"
	@echo " ports                    List of deployed service in minikube"
	@echo ""
	@echo "Local targets:"
	@if [ -f $(dir $(abspath $(lastword $(MAKEFILE_LIST))))../local/makefile ]; then \
		$(MAKE) -C $(dir $(abspath $(lastword $(MAKEFILE_LIST))))../local help; \
	fi


info:
	@echo "APP: $(APP)"
	@echo "TIMEOUT: $(TIMEOUT)"
	@echo "DIR: $(DIR)"
	@echo "IP: $(IP)"
	@echo "MINIKUBE IP: $(miniIP)"

#---------------------------------------------------------------------------------------
# REDIS
#---------------------------------------------------------------------------------------

redis:

	@eval $$(minikube service list -n redis | grep http | sed 's/^.*http:\/\/\([^:]*\):\([0-9]*\).*/redis-cli -h \1 -p \2/')


.PHONY: redis

#---------------------------------------------------------------------------------------
# DDB Admin
# Prerequisite: Install Dynamodb admin and deploy local stack
#---------------------------------------------------------------------------------------

ddb:

	@eval $$(minikube service list -n localstack | grep dynamodb | sed 's/^.*http:\/\/\([^:]*\):\([0-9]*\).*/DYNAMO_ENDPOINT=\1:\2 dynamodb-admin/')


.PHONY: ddb


#--------------------------------------------------------------------------------------
# secrets-manager
# Prerequisite: 
# 1. Create aws profile named 'localstack' with dummy values for key and secret key.
# 2. Deploy local stack
#---------------------------------------------------------------------------------------

secrets-list:

	@eval $$(minikube service list -n localstack | grep secretsmanager | sed 's/^.*http:\/\/\([^:]*\):\([0-9]*\).*/aws secretsmanager list-secrets --profile localstack --endpoint-url http:\/\/\1:\2/')

create-secret:

	@eval $$(minikube service list -n localstack | grep secretsmanager | sed 's/^.*http:\/\/\([^:]*\):\([0-9]*\).*/aws secretsmanager list-secrets --profile localstack --endpoint-url http:\/\/\1:\2/')

.PHONY: secrets-list

#---------------------------------------------------------------------------------------
# Postgres
# Prerequisite: 
# 1. install psql
#---------------------------------------------------------------------------------------

postgres:

	@eval $$(minikube service list -n database | grep postgres | sed 's/^.*http:\/\/\([^:]*\):\([0-9]*\).*/psql -h \1 -p \2 -U $(POST_USER)/')


.PHONY: postgres

#---------------------------------------------------------------------------------------
# Go repo specific target
#---------------------------------------------------------------------------------------

clean:
	@rm -rf out

#build go package 
build: info
	@go build ./... 

#buiding an excutable
build-exec: info
	@go build -o ./out ./... 

#run go application
run:
	@echo "Running ${APP}"
	@go run main.go


test: info
	@go test --timeout $(TIMEOUT)s $(DIR) -v

test-cover: info
	@go test --timeout $(TIMEOUT)s --cover $(DIR) -v

ports:
	@minikube service list

	

