#!/bin/bash

# Simple GitHub Repository Secrets Setup Script
# This script ONLY sets up GitHub repository secrets from .env file

# set -e  # Exit on any error - commented out to prevent early exit

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

# Load environment variables from .env file
load_env() {
    if [ -f .env ]; then
        print_status "Loading environment variables from .env file..."
        set -a  # automatically export all variables
        source .env
        set +a
        print_success "Environment variables loaded from .env file"
    else
        print_error "No .env file found!"
        echo "Please copy env.example to .env and update with your values:"
        echo "  cp env.example .env"
        echo "  # Edit .env with your actual values"
        exit 1
    fi
}

# Function to check if GitHub CLI is installed
check_gh_cli() {
    if ! command -v gh &> /dev/null; then
        print_error "GitHub CLI (gh) is not installed!"
        echo "Please install it from: https://cli.github.com/"
        exit 1
    fi
    print_success "GitHub CLI is installed"
}

# Function to check if user is authenticated
check_gh_auth() {
    # Set GitHub profile if specified
    if [ -n "$GITHUB_PROFILE" ]; then
        print_status "Using GitHub profile: $GITHUB_PROFILE"
        export GH_PROFILE="$GITHUB_PROFILE"
    fi
    
    if ! gh auth status &> /dev/null; then
        print_error "Not authenticated with GitHub CLI!"
        echo "Please run: gh auth login"
        if [ -n "$GITHUB_PROFILE" ]; then
            echo "Or switch to profile: gh auth switch --user $GITHUB_PROFILE"
        fi
        exit 1
    fi
    
    # Show current authentication status
    local current_user=$(gh api user --jq .login 2>/dev/null || echo "unknown")
    print_success "Authenticated with GitHub CLI as: $current_user"
}

# Function to set up secrets for a repository
setup_repo_secrets() {
    local repo="$1"
    
    print_status "Setting up secrets for $repo..."
    
    # Check if repository exists and is accessible
    if ! gh repo view "$repo" &> /dev/null; then
        print_error "Repository $repo not found or not accessible"
        echo "Please check:"
        echo "  1. Repository name is correct"
        echo "  2. You have access to the repository"
        echo "  3. You are authenticated with GitHub CLI"
        return 1
    fi
    
    # Set development role ARN
    print_status "Setting AWS_ROLE_ARN_DEV secret..."
    if echo "$AWS_ROLE_ARN_DEV" | gh secret set AWS_ROLE_ARN_DEV --repo "$repo"; then
        print_success "AWS_ROLE_ARN_DEV secret set for $repo"
    else
        print_error "Failed to set AWS_ROLE_ARN_DEV secret for $repo"
        return 1
    fi
    
    # Set production role ARN
    print_status "Setting AWS_ROLE_ARN_PROD secret..."
    if echo "$AWS_ROLE_ARN_PROD" | gh secret set AWS_ROLE_ARN_PROD --repo "$repo"; then
        print_success "AWS_ROLE_ARN_PROD secret set for $repo"
    else
        print_error "Failed to set AWS_ROLE_ARN_PROD secret for $repo"
        return 1
    fi
    
    print_success "All secrets configured for $repo"
}

# Function to verify secrets were set
verify_secrets() {
    local repo="$1"
    
    print_status "Verifying secrets for $repo..."
    
    # List secrets and check if our secrets are there
    local secrets=$(gh secret list --repo "$repo" 2>/dev/null || echo "")
    
    if echo "$secrets" | grep -q "AWS_ROLE_ARN_DEV"; then
        print_success "AWS_ROLE_ARN_DEV found in $repo"
    else
        print_warning "AWS_ROLE_ARN_DEV not found in $repo"
    fi
    
    if echo "$secrets" | grep -q "AWS_ROLE_ARN_PROD"; then
        print_success "AWS_ROLE_ARN_PROD found in $repo"
    else
        print_warning "AWS_ROLE_ARN_PROD not found in $repo"
    fi
}

# Main function
main() {
    echo "🔐 GitHub Repository Secrets Setup"
    echo "=================================="
    echo ""
    
    # Load environment variables
    load_env
    
    # Check prerequisites
    check_gh_cli
    check_gh_auth
    
    # Check if required variables are set
    if [ -z "$AWS_ROLE_ARN_DEV" ] || [ -z "$AWS_ROLE_ARN_PROD" ]; then
        print_error "Missing required environment variables!"
        echo "Please ensure your .env file contains:"
        echo "  AWS_ROLE_ARN_DEV=your-dev-role-arn"
        echo "  AWS_ROLE_ARN_PROD=your-prod-role-arn"
        exit 1
    fi
    
    print_success "Using role ARNs from environment variables:"
    echo "  Dev Role:  $AWS_ROLE_ARN_DEV"
    echo "  Prod Role: $AWS_ROLE_ARN_PROD"
    
    # Define repositories from environment or default
    if [ -n "$GITHUB_REPOS" ]; then
        # Split comma-separated list
        IFS=',' read -ra REPOS <<< "$GITHUB_REPOS"
    else
        # Default repositories
        REPOS=(
            "CDAIDavidson/terraform-template"
            "CDAIDavidson/scaffold_aws_bda_doc_parser"
        )
    fi
    
    echo ""
    print_status "Setting up secrets for ${#REPOS[@]} repositories..."
    echo ""
    
    # Set up secrets for each repository
    local success_count=0
    local total_count=${#REPOS[@]}
    
    for repo in "${REPOS[@]}"; do
        echo "----------------------------------------"
        if setup_repo_secrets "$repo"; then
            verify_secrets "$repo"
            ((success_count++))
        else
            print_error "Failed to set up secrets for $repo"
        fi
        echo ""
    done
    
    # Summary
    echo "=================================="
    if [ $success_count -eq $total_count ]; then
        print_success "All repositories configured successfully! ($success_count/$total_count)"
        echo ""
        echo "🎉 Secrets setup complete!"
        echo ""
        echo "Next steps:"
        echo "  1. Test the pipeline with a sample PR"
        echo "  2. Monitor deployments in GitHub Actions"
    else
        print_warning "Some repositories failed to configure ($success_count/$total_count)"
        echo ""
        echo "Please check the errors above and try again."
    fi
}

# Run main function
main "$@"
