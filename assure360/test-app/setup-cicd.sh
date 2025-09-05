#!/bin/bash

# Setup CI/CD for Test App
# This script copies the GitHub Actions workflow to the main repository

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

# Check if we're in the right directory
check_directory() {
    if [ ! -f ".github/workflows/deploy-test-app.yml" ]; then
        print_error "GitHub Actions workflow not found!"
        echo "Please run this script from the test-app directory"
        exit 1
    fi
    print_success "GitHub Actions workflow found"
}

# Copy workflow to main repository
copy_workflow() {
    print_status "Copying GitHub Actions workflow to main repository..."
    
    # Get the main repository directory (parent of assure360)
    MAIN_REPO_DIR="../.."
    
    if [ ! -d "$MAIN_REPO_DIR/.github" ]; then
        print_status "Creating .github directory in main repository..."
        mkdir -p "$MAIN_REPO_DIR/.github/workflows"
    fi
    
    # Copy the workflow file
    cp .github/workflows/deploy-test-app.yml "$MAIN_REPO_DIR/.github/workflows/"
    
    print_success "Workflow copied to main repository"
}

# Show next steps
show_next_steps() {
    echo ""
    print_success "CI/CD setup complete!"
    echo ""
    echo "📋 Next steps:"
    echo "  1. Commit and push the workflow file:"
    echo "     git add .github/workflows/deploy-test-app.yml"
    echo "     git commit -m 'Add test app CI/CD workflow'"
    echo "     git push origin main"
    echo ""
    echo "  2. Verify GitHub Actions is enabled:"
    echo "     - Go to your repository on GitHub"
    echo "     - Click on 'Actions' tab"
    echo "     - You should see the 'Deploy Test App' workflow"
    echo ""
    echo "  3. Test the pipeline:"
    echo "     - Make a change to the test app"
    echo "     - Push to main branch"
    echo "     - Watch the workflow run in GitHub Actions"
    echo ""
    echo "  4. Check the deployment:"
    echo "     - Look for the API URL in the workflow output"
    echo "     - Test the endpoints with curl"
    echo ""
    echo "🎉 Your test app is now connected to CI/CD!"
}

# Main function
main() {
    echo "🚀 Test App CI/CD Setup"
    echo "======================="
    echo ""
    
    # Check directory
    check_directory
    
    # Copy workflow
    copy_workflow
    
    # Show next steps
    show_next_steps
}

# Run main function
main "$@"
