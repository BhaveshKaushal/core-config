# All the targets have been tested on ubuntu system
#-------------------------------------------------------------------------------------------
# VARIABLES
#-------------------------------------------------------------------------------------------
APP ?= bk-config
.DEFAULT_GOAL = help
TIMEOUT ?= 30
IP					:= $(shell ip addr | grep 'inet ' | grep -v 127.0.0.1 | head -1 | cut -d' ' -f6 | cut -d'/' -f1)
miniIP              := $(shell minikube ip)
#---------------------------------------------------------------------------------------
# INFORMATION RELATED COMMANDS
#---------------------------------------------------------------------------------------

help:
	@echo "Available targets"

info:
	@echo "APP: $(APP)"

#---------------------------------------------------------------------------------------
# REDIS
#---------------------------------------------------------------------------------------

redis:

	@eval $$(minikube service list -n redis | grep http | sed 's/^.*http:\/\/\([^:]*\):\([0-9]*\).*/redis-cli -h \1 -p \2/')


.PHONY: redis

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
	@go test --timeout $(TIMEOUT)s ./... -v

ports:
	@minikube service list

	

