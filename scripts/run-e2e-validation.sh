#!/bin/bash

# Environment validation E2E test runner script
# Usage: ./scripts/run-e2e-validation.sh [environment] [options]
# Example: ./scripts/run-e2e-validation.sh local-k8s --headless

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
E2E_PROJECT="$PROJECT_ROOT/Tete.E2ETests"

# Default values
ENVIRONMENT="local"
HEADLESS="true"
TIMEOUT="300"
HELP=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -e|--environment)
      ENVIRONMENT="$2"
      shift 2
      ;;
    --headed)
      HEADLESS="false"
      shift
      ;;
    --headless)
      HEADLESS="true"
      shift
      ;;
    -t|--timeout)
      TIMEOUT="$2"
      shift 2
      ;;
    -h|--help)
      HELP=true
      shift
      ;;
    *)
      ENVIRONMENT="$1"
      shift
      ;;
  esac
done

if [ "$HELP" = true ]; then
  echo "Usage: $0 [environment] [options]"
  echo ""
  echo "Arguments:"
  echo "  environment    Target environment (local, local-k8s, dev, staging, prod)"
  echo ""
  echo "Options:"
  echo "  --headed       Run browser in headed mode (visible)"
  echo "  --headless     Run browser in headless mode (default)"
  echo "  -t, --timeout  Test timeout in seconds (default: 300)"
  echo "  -h, --help     Show this help message"
  echo ""
  echo "Examples:"
  echo "  $0 local                    # Test local environment"
  echo "  $0 local-k8s --headed      # Test local k8s with visible browser"
  echo "  $0 dev --timeout 600       # Test dev environment with 10min timeout"
  exit 0
fi

echo "🚀 Running environment validation tests"
echo "Environment: $ENVIRONMENT"
echo "Headless: $HEADLESS"
echo "Timeout: ${TIMEOUT}s"
echo ""

# Set environment variables based on configuration
case $ENVIRONMENT in
  local)
    BASE_URL="http://localhost:5001"
    ;;
  local-k8s)
    BASE_URL="http://localhost:8080"
    ;;
  dev)
    BASE_URL="https://dev.tetelearning.com"
    ;;
  staging)
    BASE_URL="https://staging.tetelearning.com"
    ;;
  prod)
    BASE_URL="https://tetelearning.com"
    ;;
  *)
    echo "❌ Unknown environment: $ENVIRONMENT"
    echo "Available environments: local, local-k8s, dev, staging, prod"
    exit 1
    ;;
esac

# Export environment variables for the test
export TETE_BASE_URL="$BASE_URL"
export TETE_HEADLESS="$HEADLESS"
export TETE_TIMEOUT="$TIMEOUT"

echo "🔗 Testing against: $BASE_URL"

# Check if the target URL is accessible
echo "🔍 Checking if $BASE_URL is accessible..."
if command -v curl >/dev/null 2>&1; then
  http_status=$(curl -s --max-time 10 -w "%{http_code}" -o /dev/null "$BASE_URL" 2>/dev/null || echo "000")
  
  # Clean up the status code
  http_status=$(echo "$http_status" | tail -c 4)
  
  case "$http_status" in
    000)
      echo "❌ Error: Cannot connect to $BASE_URL"
      echo "   Make sure the application is running and accessible"
      echo "   For local-k8s: ensure 'kubectl port-forward service/tete-web 8080:80 -n tete-local' is running"
      echo "   For local: ensure the application is running on port 5001"
      exit 1
      ;;
    4*|5*)
      echo "⚠️  Warning: $BASE_URL returned HTTP $http_status"
      echo "   This might be normal if authentication is required"
      ;;
    2*|3*)
      echo "✅ $BASE_URL is accessible (HTTP $http_status)"
      ;;
    *)
      echo "⚠️  Unexpected HTTP status: $http_status"
      ;;
  esac
else
  echo "⚠️  curl not found, skipping accessibility check"
fi

# Navigate to E2E test project
cd "$E2E_PROJECT"

# Restore packages if needed
echo "📦 Restoring NuGet packages..."
dotnet restore

# Run the environment validation tests
echo "🧪 Running environment validation tests..."
echo ""

# Set test timeout
export DOTNET_CLI_TEST_TIMEOUT="$TIMEOUT"

if dotnet test --filter "TestFixture=EnvironmentValidationTests" --logger "console;verbosity=detailed"; then
  echo ""
  echo "✅ Environment validation tests passed!"
  echo "🎉 Environment $ENVIRONMENT appears to be healthy"
else
  echo ""
  echo "❌ Environment validation tests failed!"
  echo "🔧 Check the test output above for specific issues"
  exit 1
fi