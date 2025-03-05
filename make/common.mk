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
	@echo "Available targets:"
	@echo ""
	@echo "Common targets:"
	@awk '/^[a-zA-Z0-9_-]+:/ { \
		if (match(lastLine, /^## (.*)/)) { \
			printf "  %-20s %s\n", substr($$1, 1, length($$1)-1), substr(lastLine, 4); \
		} \
	} { lastLine = $$0 }' $(MAKEFILE_LIST)
	@if [ -f $(LOCAL_MAKEFILE) ]; then \
		echo ""; \
		echo "Local targets:"; \
		$(MAKE) -f $(LOCAL_MAKEFILE) local-help-silent; \
	fi

## Show information about the Application
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

	

