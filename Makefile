# Makefile
# Using this as part command alias and traditional Makefile

default: help

# Variables
TARGET=web  # or EXECUTABLE
PROJECT := $(shell gcloud config get-value project) 
PROJECT_ID := $(strip $(PROJECT))
IMAGE_REPO_NAME=crystal-helloworld
IMAGE_TAG=0.1
IMAGE_TAG ?= latest
IMAGE_URI="gcr.io/$(PROJECT_ID)/$(IMAGE_REPO_NAME):$(IMAGE_TAG)"
# Should switch to Artifact Registry over GCR in future

# Rules

.PHONY: all
## Build and deploy the container 
all: build/cloud deploy

.PHONY: watch
## Recompile upon any file change in src
watch:
	./dev/watch.sh $(TARGET)

.PHONY: deploy
## Deploy container to Cloud Run
deploy:
	@echo "======================"
	@echo "Deploying to Cloud Run"
	@echo "======================"
	gcloud run deploy $(TARGET) --image $(IMAGE_URI) \
		--platform managed --allow-unauthenticated

.PHONY: build/local
## Compiles source using shards command
build/local:
	@shards build $(TARGET)

.PHONY: build/cloud
## Build docker container in Cloud
build/cloud:
	@echo "======================"
	@echo "Building container via Cloud Build"
	@echo "======================"
	gcloud builds submit --tag $(IMAGE_URI)

deps:
	@which docker

## Build docker container locally
build/docker: deps
	@docker -f Dockerfile build -t $(IMAGE_URI) ./

## Configures Docker to authenticate to GCR
docker/login:
	# gcloud auth configure-docker us-central1-docker.pkg.dev
	gcloud auth configure-docker

.PHONY: logs
## Examine the logs from the Cloud container
logs:
	gcloud beta run services logs read $(TARGET) \
		--limit=20 --project $(PROJECT_ID)

.PHONY: logs/stream
## Stream Cloud Run logs
logs/stream:
	gcloud beta run services logs tail $(TARGET) --project $(PROJECT_ID)

.PHONY: clean/cloud
## Delete Cloud Run service and container
clean/cloud:
	@echo "Stopping and deleting Cloud Run service"
	gcloud run services delete $(TARGET)
	@echo "Deleting container image from GCR"
	gcloud container images delete $(IMAGE_URI) --force-delete-tags
# gcloud artifacts repositories delete
	
## clean up debugging symbol files
.PHONY: clean
clean:
	rm -f bin/*.dwarf

## This help screen
help:
				@printf "Available targets:\n\n"
				@awk '/^[a-zA-Z\-\_0-9%:\\]+/ { \
          helpMessage = match(lastLine, /^## (.*)/); \
          if (helpMessage) { \
            helpCommand = $$1; \
            helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
      gsub("\\\\", "", helpCommand); \
      gsub(":+$$", "", helpCommand); \
            printf "  \x1b[32;01m%-35s\x1b[0m %s\n", helpCommand, helpMessage; \
          } \
        } \
        { lastLine = $$0 }' $(MAKEFILE_LIST) | sort -u
				@printf "\n"
