#!/bin/bash

# Wait for environment to be ready before running tests
# Usage: ./scripts/wait-for-environment.sh [url] [timeout]

set -e

URL="${1:-http://localhost:5001}"
TIMEOUT="${2:-300}"
INTERVAL=5

echo "⏳ Waiting for $URL to be ready (timeout: ${TIMEOUT}s)..."

start_time=$(date +%s)

while true; do
  current_time=$(date +%s)
  elapsed=$((current_time - start_time))
  
  if [ $elapsed -ge $TIMEOUT ]; then
    echo "❌ Timeout waiting for $URL to be ready after ${TIMEOUT}s"
    exit 1
  fi
  
  # Test the connection and capture the HTTP status
  http_status=$(curl -s --max-time 10 -w "%{http_code}" -o /dev/null "$URL" 2>/dev/null || echo "000")
  
  # Clean up any extra characters that might be in the status
  http_status=$(echo "$http_status" | tail -c 4)
  
  # Consider 2xx and 3xx as success, 4xx as "up but may need auth", 5xx or connection failures as not ready
  case "$http_status" in
    2*|3*)
      echo "✅ $URL is ready! (HTTP $http_status)"
      exit 0
      ;;
    4*)
      echo "✅ $URL is responding! (HTTP $http_status - may require authentication)"
      exit 0
      ;;
    000)
      echo "⏳ Connection failed... (${elapsed}s elapsed)"
      ;;
    5*)
      echo "⏳ Server error (HTTP $http_status)... (${elapsed}s elapsed)"
      ;;
    *)
      echo "⏳ Unexpected response (HTTP $http_status)... (${elapsed}s elapsed)"
      ;;
  esac
  
  sleep $INTERVAL
done