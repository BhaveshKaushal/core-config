# Common Makefile

This directory contains the common Makefile targets shared across projects.

## Location
`core-config/make/common.mk`

## Usage
Include this in your project's Makefile:
```makefile
CONFIG_PATH ?= ../core-config
include $(CONFIG_PATH)/make/common.mk
```

## Available Targets

### Development
- `build` - Build go package
- `build-exec` - Build executable
- `test` - Run tests
- `test-cover` - Run tests with coverage
- `clean` - Remove out folder

### Services
- `redis` - Run redis client for redis in minikube
- `ddb` - Run DynamoDB admin for localstack
- `postgres` - Connect to PostgreSQL database
- `secrets-list` - List secrets in secretsmanager
- `create-secret` - Create new secret in secretsmanager

### Information
- `help` - Show available targets
- `info` - Show configuration information
- `ports` - List deployed services in minikube 