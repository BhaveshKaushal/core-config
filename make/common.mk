# All the targets have been tested on ubuntu system
#-------------------------------------------------------------------------------------------
# VARIABLES
#-------------------------------------------------------------------------------------------
APP ?= bk-config
.DEFAULT_GOAL = help
TIMEOUT ?= 30
#---------------------------------------------------------------------------------------
# INFORMATION RELATED COMMANDS
#---------------------------------------------------------------------------------------

help:
	@echo "Available targets"

info:
	@echo "APP: $(APP)"

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

