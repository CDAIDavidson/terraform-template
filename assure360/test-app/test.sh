#!/bin/bash

# Assure360 Test App Testing Script
# This script tests the deployed test app

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

# Get API URL
get_api_url() {
    if [ -f "infrastructure/terraform.tfstate" ]; then
        API_URL=$(cd infrastructure && terraform output -raw api_url 2>/dev/null || echo "")
    fi
    
    if [ -z "$API_URL" ]; then
        print_error "Could not get API URL from Terraform output"
        print_status "Please ensure the infrastructure is deployed"
        exit 1
    fi
    
    print_status "API URL: $API_URL"
}

# Test endpoint
test_endpoint() {
    local endpoint="$1"
    local expected_status="$2"
    local description="$3"
    
    print_status "Testing $description..."
    
    local response
    local status_code
    
    if response=$(curl -s -w "%{http_code}" "$API_URL$endpoint" 2>/dev/null); then
        status_code="${response: -3}"
        response_body="${response%???}"
        
        if [ "$status_code" = "$expected_status" ]; then
            print_success "$description test passed (HTTP $status_code)"
            echo "  Response: $response_body"
        else
            print_error "$description test failed (HTTP $status_code)"
            echo "  Expected: HTTP $expected_status"
            echo "  Got: HTTP $status_code"
            echo "  Response: $response_body"
            return 1
        fi
    else
        print_error "$description test failed (connection error)"
        return 1
    fi
}

# Test with parameters
test_endpoint_with_params() {
    local endpoint="$1"
    local params="$2"
    local expected_status="$3"
    local description="$4"
    
    print_status "Testing $description..."
    
    local response
    local status_code
    
    if response=$(curl -s -w "%{http_code}" "$API_URL$endpoint?$params" 2>/dev/null); then
        status_code="${response: -3}"
        response_body="${response%???}"
        
        if [ "$status_code" = "$expected_status" ]; then
            print_success "$description test passed (HTTP $status_code)"
            echo "  Response: $response_body"
        else
            print_error "$description test failed (HTTP $status_code)"
            echo "  Expected: HTTP $expected_status"
            echo "  Got: HTTP $status_code"
            echo "  Response: $response_body"
            return 1
        fi
    else
        print_error "$description test failed (connection error)"
        return 1
    fi
}

# Run all tests
run_tests() {
    print_status "Running test suite..."
    echo ""
    
    local failed_tests=0
    
    # Test health endpoint
    if ! test_endpoint "/health" "200" "Health endpoint"; then
        ((failed_tests++))
    fi
    echo ""
    
    # Test hello endpoint
    if ! test_endpoint "/hello" "200" "Hello endpoint"; then
        ((failed_tests++))
    fi
    echo ""
    
    # Test hello endpoint with name parameter
    if ! test_endpoint_with_params "/hello" "name=TestUser" "200" "Hello endpoint with name parameter"; then
        ((failed_tests++))
    fi
    echo ""
    
    # Test time endpoint
    if ! test_endpoint "/time" "200" "Time endpoint"; then
        ((failed_tests++))
    fi
    echo ""
    
    # Test status endpoint
    if ! test_endpoint "/status" "200" "Status endpoint"; then
        ((failed_tests++))
    fi
    echo ""
    
    # Test info endpoint
    if ! test_endpoint "/info" "200" "Info endpoint"; then
        ((failed_tests++))
    fi
    echo ""
    
    # Test test endpoint
    if ! test_endpoint "/test" "200" "Test endpoint"; then
        ((failed_tests++))
    fi
    echo ""
    
    # Test root endpoint
    if ! test_endpoint "/" "200" "Root endpoint"; then
        ((failed_tests++))
    fi
    echo ""
    
    # Test 404 endpoint
    if ! test_endpoint "/nonexistent" "404" "404 error handling"; then
        ((failed_tests++))
    fi
    echo ""
    
    # Summary
    echo "================================"
    if [ $failed_tests -eq 0 ]; then
        print_success "All tests passed! (9/9)"
        echo ""
        echo "🎉 Test app is working correctly!"
        echo ""
        echo "You can also test manually:"
        echo "  curl $API_URL/health"
        echo "  curl $API_URL/hello"
        echo "  curl $API_URL/test"
        echo "  curl \"$API_URL/hello?name=YourName\""
    else
        print_error "Some tests failed ($failed_tests failed)"
        echo ""
        echo "Please check the errors above and ensure the app is deployed correctly."
        exit 1
    fi
}

# Main function
main() {
    echo "🧪 Assure360 Test App Testing"
    echo "============================="
    echo ""
    
    # Get API URL
    get_api_url
    
    # Run tests
    run_tests
}

# Run main function
main "$@"
