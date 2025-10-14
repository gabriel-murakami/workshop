#!/bin/bash

DOCKER_USERNAME="gabrielmurakami"
IMAGE_NAME="workshop"
TAG="latest"

docker build -t $DOCKER_USERNAME/$IMAGE_NAME:$TAG .
docker login -u $DOCKER_USERNAME
docker push $DOCKER_USERNAME/$IMAGE_NAME:$TAG
