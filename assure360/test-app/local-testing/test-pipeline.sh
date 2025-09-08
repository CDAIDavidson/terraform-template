#!/bin/bash

# Local Testing Script for GitHub Actions Pipeline
# This script ONLY tests the build-and-deploy job using nektos/act

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."

    if ! command -v act &> /dev/null; then
        print_error "nektos/act is not installed!"
        echo "Install via Scoop: scoop install act, or see README"
        exit 1
    fi

    if ! docker info &> /dev/null; then
        print_error "Docker is not running! Start Docker Desktop first."
        exit 1
    fi

    # Optional: verify AWS creds available for this job
    if ! aws sts get-caller-identity &> /dev/null; then
        print_warning "AWS credentials not configured. The job will fail at the AWS step."
        echo "Configure with 'aws configure' or 'export AWS_PROFILE=your-profile'"
    fi

    print_success "Prerequisites check passed"
}

refresh_aws_creds() {
    # Regenerate fresh temporary creds into .secrets for act
    if [ -z "$AWS_PROFILE" ]; then
        print_warning "AWS_PROFILE is not set; using default credential chain."
        return 0
    fi

    print_status "Refreshing AWS session for profile: $AWS_PROFILE"
    # If profile is SSO-based, this will refresh; ignore errors if not SSO
    aws sso login --profile "$AWS_PROFILE" >/dev/null 2>&1 || true

    print_status "Exporting temporary credentials to .secrets"
    SCRIPT_DIR_LOCAL="$(cd "$(dirname "$0")" && pwd)"
    if ! aws configure export-credentials --profile "$AWS_PROFILE" --format env > "$SCRIPT_DIR_LOCAL/.secrets"; then
        print_warning "Could not export credentials for profile $AWS_PROFILE. Continuing without .secrets."
        return 0
    fi
    # Ensure region is present for AWS SDK/CLI
    if ! grep -q '^AWS_REGION=' "$SCRIPT_DIR_LOCAL/.secrets"; then
        echo "AWS_REGION=${AWS_REGION:-ap-southeast-2}" >> "$SCRIPT_DIR_LOCAL/.secrets"
    fi
    print_success "Wrote fresh credentials to $SCRIPT_DIR_LOCAL/.secrets"
}

main() {
    echo "🧪 Local test: build-and-deploy"
    echo "================================"
    echo ""

    check_prerequisites

    # Move to repo root (this script is in assure360/test-app/local-testing)
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

    print_status "Repo root: $REPO_ROOT"
    cd "$REPO_ROOT"

    # Refresh creds for local run (ensures .secrets is current)
    refresh_aws_creds

    # Run only build-and-deploy from deploy-test-app.yml as a push to dev
    print_status "Running build-and-deploy (push to dev) via act..."
    # If a .secrets file exists (exported from SSO), pass it to act
    SECRETS_ARG=""
    if [ -f "$SCRIPT_DIR/.secrets" ]; then
      SECRETS_ARG="--secret-file $SCRIPT_DIR/.secrets"
      print_status "Using secrets from $SCRIPT_DIR/.secrets"
    fi

    act push \
      -W .github/workflows/deploy-test-app.yml \
      -j build-and-deploy \
      -e assure360/test-app/local-testing/push-event.json \
      $SECRETS_ARG

    print_success "Finished running build-and-deploy"
}

main "$@"
