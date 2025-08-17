#!/bin/bash

# Build script for SMS application Docker images
# Builds all services with buildx for linux/amd64 platform

set -e

# ECR registry configuration
ECR_REGISTRY="793209430381.dkr.ecr.ap-southeast-1.amazonaws.com"
PLATFORM="linux/amd64"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Starting Docker image builds for SMS application...${NC}"

# Function to build and tag image
build_service() {
    local service_name=$1
    local dockerfile_path=$2
    local tag="${ECR_REGISTRY}/${service_name}:latest"
    
    echo -e "${YELLOW}Building ${service_name}...${NC}"
    
    if docker buildx build \
        --platform ${PLATFORM} \
        --tag ${tag} \
        --load \
        ${dockerfile_path}; then
        echo -e "${GREEN}✓ Successfully built ${service_name}${NC}"
        echo -e "  Tagged as: ${tag}"
    else
        echo -e "${RED}✗ Failed to build ${service_name}${NC}"
        exit 1
    fi
    echo ""
}

# Build all services
echo -e "${YELLOW}Building services with platform: ${PLATFORM}${NC}"
echo ""

build_service "auth-service" "application/sms/auth-service"
build_service "student-service" "application/sms/student-service"
build_service "course-service" "application/sms/course-service"
build_service "frontend" "application/sms/frontend"

echo -e "${GREEN}All images built successfully!${NC}"
echo ""
echo -e "${YELLOW}Built images:${NC}"
echo "  ${ECR_REGISTRY}/auth-service:latest"
echo "  ${ECR_REGISTRY}/student-service:latest"
echo "  ${ECR_REGISTRY}/course-service:latest"
echo "  ${ECR_REGISTRY}/frontend:latest"
echo ""
echo -e "${YELLOW}To push images to ECR, run:${NC}"
echo "  docker push ${ECR_REGISTRY}/auth-service:latest"
echo "  docker push ${ECR_REGISTRY}/student-service:latest"
echo "  docker push ${ECR_REGISTRY}/course-service:latest"
echo "  docker push ${ECR_REGISTRY}/frontend:latest"