#!/bin/bash

# Assure360 Test App Local Development Script
# This script runs the test app locally for development

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
    
    # Check if Python is installed
    if ! command -v python3 &> /dev/null; then
        print_error "Python 3 is not installed!"
        echo "Please install Python 3.11 or later"
        exit 1
    fi
    
    # Check Python version
    python_version=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
    if [[ "$python_version" < "3.11" ]]; then
        print_warning "Python version $python_version detected. Python 3.11+ recommended."
    fi
    
    print_success "Prerequisites check complete"
}

# Install dependencies
install_dependencies() {
    print_status "Installing dependencies..."
    
    cd app
    
    # Create virtual environment if it doesn't exist
    if [ ! -d "venv" ]; then
        print_status "Creating virtual environment..."
        python3 -m venv venv
    fi
    
    # Activate virtual environment
    print_status "Activating virtual environment..."
    source venv/bin/activate
    
    # Install dependencies
    print_status "Installing Python dependencies..."
    pip install -r requirements.txt
    
    print_success "Dependencies installed successfully!"
    
    cd ..
}

# Run the application
run_app() {
    print_status "Starting local development server..."
    
    cd app
    
    # Activate virtual environment
    source venv/bin/activate
    
    # Set environment variables
    export ENVIRONMENT="development"
    export AWS_REGION="ap-southeast-2"
    
    print_success "Starting FastAPI server..."
    echo ""
    echo "🚀 Server starting at: http://localhost:8080"
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
    echo "Press Ctrl+C to stop the server"
    echo ""
    
    # Run the application
    python3 app.py
    
    cd ..
}

# Main function
main() {
    echo "🏠 Assure360 Test App Local Development"
    echo "======================================="
    echo ""
    
    # Check prerequisites
    check_prerequisites
    
    # Install dependencies
    install_dependencies
    
    # Run the application
    run_app
}

# Run main function
main "$@"
