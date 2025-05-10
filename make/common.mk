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

## Display all available make targets with descriptions
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

## Clean build artifacts and temporary files
clean:
	@rm -rf out

## Build the application
build: info
	@go build ./...

#buiding an excutable
build-exec: info
	@go build -o ./out ./... 

#run go application
run:
	@echo "Running ${APP}"
	@go run main.go


## Run tests for the application
test: info
	@go test --timeout $(TIMEOUT)s $(DIR) -v

cover: info
	@go test --timeout $(TIMEOUT)s --cover $(DIR) -v


ports:
	@minikube service list

## Display available make targets without formatting (for scripting)
help-silent:
	@awk '/^[a-zA-Z0-9_-]+:/ { \
		if (match(lastLine, /^## (.*)/)) { \
			printf "%s\n", substr($$1, 1, length($$1)-1); \
		} \
	} { lastLine = $$0 }' $(MAKEFILE_LIST)


## Start the application in debug mode
debug:
	# ... existing code ...

## Stop the running application and clean up resources
stop:
	@echo "Stopping application..."
	@if [ -f .pid ]; then \
		pid=$$(cat .pid); \
		if ps -p $$pid > /dev/null; then \
			kill $$pid; \
			rm .pid; \
			echo "Application stopped (PID: $$pid)"; \
		else \
			echo "No running application found with PID: $$pid"; \
			rm .pid; \
		fi \
	else \
		echo "No .pid file found. Application might not be running."; \
	fi

## Deploy application to target environment
deploy:
	# ... existing code ...

# Print repository root (for debugging)
print-repo-root:
	@echo "Repository root: $(REPO_ROOT)"
	@echo "CONFIG_PATH: $(CONFIG_PATH)"
	@echo "PARENT_DIR: $(PARENT_DIR)"
	
## Display detailed test coverage by function (use FILE=path/to/file.go to filter)
cover-func: info
	@go test --timeout $(TIMEOUT)s -coverprofile=coverage.out $(DIR)
	@if [ -n "$(FILE)" ]; then \
		echo "Coverage for $(FILE):"; \
		go tool cover -func=coverage.out | grep "$(FILE)" || echo "No coverage data for $(FILE)"; \
	else \
		echo "Coverage by function:"; \
		go tool cover -func=coverage.out; \
	fi

## Generate HTML coverage report (use FILE=path/to/file.go to filter)
cover-html: info
	@go test --timeout $(TIMEOUT)s -coverprofile=coverage.out $(DIR)
	@if [ -n "$(FILE)" ]; then \
		echo "Filtering coverage for $(FILE)"; \
		echo "mode: set" > filtered.out; \
		grep -o ".*$(FILE):.*" coverage.out >> filtered.out || echo "No coverage data for $(FILE)"; \
		go tool cover -html=filtered.out -o coverage.html; \
	else \
		go tool cover -html=coverage.out -o coverage.html; \
	fi
	@echo "Coverage report generated: coverage.html"




