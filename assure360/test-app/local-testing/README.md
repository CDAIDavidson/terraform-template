# Local Testing with nektos/act

This folder contains files and scripts for testing the GitHub Actions pipeline locally using `nektos/act`.

## Files

- `event.json` - Pull request event payload for testing
- `push-event.json` - Push event payload for testing dev branch
- `test-pipeline.sh` - Script to run various pipeline tests locally

## Quick Start

```bash
# Navigate to the local-testing directory
cd assure360/test-app/local-testing

# Make the script executable (macOS/Linux/Git Bash)
chmod +x test-pipeline.sh

# Set your AWS SSO profile for this session (example)
export AWS_PROFILE=dev-assure360

# (Optional) Export temporary creds from your SSO profile to a secrets file for act
aws configure export-credentials --profile "$AWS_PROFILE" --format env > ./.secrets
echo "AWS_REGION=ap-southeast-2" >> ./.secrets

# Run the test script
./test-pipeline.sh
```

Note (Windows PowerShell): use Git Bash or WSL to run the script, or invoke via:
```powershell
bash ./test-pipeline.sh
```

## Manual Testing

### Test the test job (Python tests)
```bash
act pull_request -j test -e event.json
```

### Test the build-and-deploy job (requires AWS credentials)
```bash
act push -j build-and-deploy -e push-event.json
```

### Test the destroy job (manual workflow)
```bash
act workflow_dispatch -j destroy
```

## Prerequisites

- `nektos/act` installed (see main README for installation)
- Docker running
- AWS credentials configured (for build-and-deploy job)

## Event Files

- **event.json**: Simulates a pull request from `feature/test-branch` to `main`
- **push-event.json**: Simulates a push to `dev` branch

You can modify these files to test different scenarios.
