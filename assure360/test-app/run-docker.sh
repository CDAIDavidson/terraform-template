#!/bin/bash

# Assure360 Test App Docker Runner
# This script runs the test app in a Docker container locally

set -e

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

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed!"
        echo "Please install Docker from: https://www.docker.com/get-started"
        exit 1
    fi
    
    # Check if Docker Compose is installed
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not installed!"
        echo "Please install Docker Compose from: https://docs.docker.com/compose/install/"
        exit 1
    fi
    
    # Check if Docker is running
    if ! docker info &> /dev/null; then
        print_error "Docker is not running!"
        echo "Please start Docker Desktop or Docker daemon"
        exit 1
    fi
    
    print_success "All prerequisites are available"
}

# Build and run with Docker Compose
run_with_compose() {
    print_status "Building and running with Docker Compose..."
    
    # Build and start the container
    docker-compose up --build
    
    print_success "Container started successfully!"
}

# Build and run with Docker directly
run_with_docker() {
    print_status "Building Docker image..."
    
    # Build the image
    docker build -f app/Dockerfile.local -t assure360-test-app-local ./app
    
    print_success "Docker image built successfully!"
    
    print_status "Starting container..."
    
    # Run the container
    docker run -d \
        --name assure360-test-app \
        -p 8080:8080 \
        -e ENVIRONMENT=development \
        -e AWS_REGION=ap-southeast-2 \
        assure360-test-app-local
    
    print_success "Container started successfully!"
    
    # Wait for container to be ready
    print_status "Waiting for container to be ready..."
    sleep 5
    
    # Check if container is running
    if docker ps | grep -q assure360-test-app; then
        print_success "Container is running!"
        echo ""
        echo "🚀 Test app is available at: http://localhost:8080"
        echo ""
        echo "Available endpoints:"
        echo "  Health:  http://localhost:8080/health"
        echo "  Hello:   http://localhost:8080/hello"
        echo "  Time:    http://localhost:8080/time"
        echo "  Status:  http://localhost:8080/status"
        echo "  Info:    http://localhost:8080/info"
        echo "  Test:    http://localhost:8080/test"
        echo "  Docs:    http://localhost:8080/docs"
        echo ""
        echo "To test:"
        echo "  curl http://localhost:8080/health"
        echo "  curl http://localhost:8080/hello"
        echo ""
        echo "To stop:"
        echo "  docker stop assure360-test-app"
        echo "  docker rm assure360-test-app"
    else
        print_error "Container failed to start"
        echo "Check logs with: docker logs assure360-test-app"
        exit 1
    fi
}

# Test the running container
test_container() {
    print_status "Testing container..."
    
    # Wait a bit for the app to start
    sleep 3
    
    # Test health endpoint
    if curl -f http://localhost:8080/health > /dev/null 2>&1; then
        print_success "Health endpoint test passed"
    else
        print_warning "Health endpoint test failed (container might still be starting)"
    fi
    
    # Test hello endpoint
    if curl -f http://localhost:8080/hello > /dev/null 2>&1; then
        print_success "Hello endpoint test passed"
    else
        print_warning "Hello endpoint test failed (container might still be starting)"
    fi
}

# Show container logs
show_logs() {
    print_status "Showing container logs..."
    echo ""
    docker logs assure360-test-app
}

# Stop and clean up
cleanup() {
    print_status "Stopping and cleaning up..."
    
    # Stop container
    docker stop assure360-test-app 2>/dev/null || true
    
    # Remove container
    docker rm assure360-test-app 2>/dev/null || true
    
    print_success "Cleanup complete!"
}

# Main function
main() {
    echo "🐳 Assure360 Test App Docker Runner"
    echo "==================================="
    echo ""
    
    # Check prerequisites
    check_prerequisites
    
    # Parse command line arguments
    case "${1:-run}" in
        "run")
            run_with_docker
            test_container
            ;;
        "compose")
            run_with_compose
            ;;
        "logs")
            show_logs
            ;;
        "cleanup")
            cleanup
            ;;
        "help")
            echo "Usage: $0 [run|compose|logs|cleanup|help]"
            echo ""
            echo "Commands:"
            echo "  run      - Build and run with Docker (default)"
            echo "  compose  - Build and run with Docker Compose"
            echo "  logs     - Show container logs"
            echo "  cleanup  - Stop and remove container"
            echo "  help     - Show this help message"
            ;;
        *)
            print_error "Unknown command: $1"
            echo "Use '$0 help' for available commands"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
