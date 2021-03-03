# All the targets have been tested on ubuntu system
#-------------------------------------------------------------------------------------------
# VARIABLES

APP ?= bk-config

#-------------------------------------------------------------------------------------------

# HELP on commands

help:
#    "${MAKEFLAGS} "
	@echo "Available targets"

#---------------------------------------------------------------------------------------
# Go repo specific target
#---------------------------------------------------------------------------------------

#build go package 
build: 
	@echo "Building ${APP}"
	@go build -o ./bin/$(APP) main.go

#run go application
run:
	@echo "Running ${APP}"
	@go run main.go


test:
	@echo "BuildiRunning Tests for ${APP}"
	@go test --timeout 30s

