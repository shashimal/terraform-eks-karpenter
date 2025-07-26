#!/bin/bash

# Docker Build, Tag and Push Script for SMS Application
# This script builds all services and pushes them to Docker Hub

set -e  # Exit on any error

# Configuration
DOCKER_USERNAME="shashimald"
VERSION="v1.0.0"
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker and try again."
        exit 1
    fi
    print_success "Docker is running"
}

# Function to login to Docker Hub
docker_login() {
    print_status "Logging into Docker Hub..."
    if ! docker login; then
        print_error "Failed to login to Docker Hub"
        exit 1
    fi
    print_success "Successfully logged into Docker Hub"
}

# Function to build, tag and push a service
build_and_push() {
    local service_name=$1
    local service_dir=$2
    local image_name=$3
    
    print_status "Building $service_name..."
    
    # Change to service directory
    cd "$BASE_DIR/$service_dir"
    
    # Build the image
    if docker build -t "$image_name:$VERSION" -t "$image_name:latest" .; then
        print_success "Successfully built $service_name"
    else
        print_error "Failed to build $service_name"
        exit 1
    fi
    
    # Push versioned tag
    print_status "Pushing $image_name:$VERSION to Docker Hub..."
    if docker push "$image_name:$VERSION"; then
        print_success "Successfully pushed $image_name:$VERSION"
    else
        print_error "Failed to push $image_name:$VERSION"
        exit 1
    fi
    
    # Push latest tag
    print_status "Pushing $image_name:latest to Docker Hub..."
    if docker push "$image_name:latest"; then
        print_success "Successfully pushed $image_name:latest"
    else
        print_error "Failed to push $image_name:latest"
        exit 1
    fi
    
    # Return to base directory
    cd "$BASE_DIR"
}

# Main execution
main() {
    print_status "Starting Docker build and push process..."
    print_status "Base directory: $BASE_DIR"
    print_status "Docker username: $DOCKER_USERNAME"
    print_status "Version: $VERSION"
    
    # Check if Docker is running
    check_docker
    
    # Login to Docker Hub
    docker_login
    
    # Build and push all services
    print_status "Building and pushing all services..."
    
    # Student Service
    build_and_push "Student Service" "student-service" "$DOCKER_USERNAME/student-service"
    
    # Course Service
    build_and_push "Course Service" "course-service" "$DOCKER_USERNAME/course-service"
    
    # Auth Service
    build_and_push "Auth Service" "auth-service" "$DOCKER_USERNAME/auth-service"
    
    # Frontend Service
    build_and_push "Frontend Service" "frontend" "$DOCKER_USERNAME/frontend-service"
    
    print_success "All services have been successfully built and pushed to Docker Hub!"
    
    # Display summary
    echo ""
    print_status "Summary of pushed images:"
    echo "  • $DOCKER_USERNAME/student-service:$VERSION"
    echo "  • $DOCKER_USERNAME/student-service:latest"
    echo "  • $DOCKER_USERNAME/course-service:$VERSION"
    echo "  • $DOCKER_USERNAME/course-service:latest"
    echo "  • $DOCKER_USERNAME/auth-service:$VERSION"
    echo "  • $DOCKER_USERNAME/auth-service:latest"
    echo "  • $DOCKER_USERNAME/frontend-service:$VERSION"
    echo "  • $DOCKER_USERNAME/frontend-service:latest"
}

# Help function
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -v, --version  Set custom version (default: $VERSION)"
    echo "  -u, --username Set Docker Hub username (default: $DOCKER_USERNAME)"
    echo ""
    echo "Examples:"
    echo "  $0                           # Build and push with default settings"
    echo "  $0 -v v2.0.0                # Build and push with version v2.0.0"
    echo "  $0 -u myusername -v v1.1.0   # Build and push with custom username and version"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--version)
            VERSION="$2"
            shift 2
            ;;
        -u|--username)
            DOCKER_USERNAME="$2"
            shift 2
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Run main function
main