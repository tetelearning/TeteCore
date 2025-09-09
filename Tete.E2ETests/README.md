# E2E Environment Validation Tests

This directory contains end-to-end tests that validate the complete TeteCore application stack from frontend to database.

## EnvironmentValidationTests

The `EnvironmentValidationTests` class provides comprehensive validation of a running TeteCore environment:

### What it tests:
1. **Health Check** - Verifies the application is responding
2. **API Endpoints** - Tests core API endpoints are accessible
3. **Frontend Loading** - Validates Angular app loads properly
4. **Authentication Flow** - Tests user registration and login
5. **Authenticated Access** - Verifies protected resources work
6. **Database Connectivity** - Ensures database operations succeed
7. **Error Handling** - Validates graceful error responses

### Test Flow:
1. Creates a unique test user
2. Registers the user through the UI
3. Logs in with the created user
4. Accesses authenticated resources
5. Tests API calls with authentication
6. Validates database operations

## Usage

### Quick Start
```bash
# Test local environment
./scripts/run-e2e-validation.sh local

# Test local Kubernetes environment
./scripts/run-e2e-validation.sh local-k8s

# Test with visible browser (for debugging)
./scripts/run-e2e-validation.sh local --headed
```

### Environment Configuration

Set the target environment using the `TETE_BASE_URL` environment variable:

```bash
export TETE_BASE_URL="http://localhost:8080"
dotnet test --filter "TestFixture=EnvironmentValidationTests"
```

### Available Environments

| Environment | URL | Description |
|-------------|-----|-------------|
| `local` | http://localhost:5001 | Local development |
| `local-k8s` | http://localhost:8080 | Local Kubernetes via port-forward |
| `dev` | https://dev.tetelearning.com | Development environment |
| `staging` | https://staging.tetelearning.com | Staging environment |
| `prod` | https://tetelearning.com | Production environment |

### Manual Test Execution

Run tests directly with dotnet:

```bash
cd Tete.E2ETests

# Test specific environment
export TETE_BASE_URL="http://localhost:5001"
dotnet test --filter "TestFixture=EnvironmentValidationTests"

# Run with detailed output
dotnet test --filter "TestFixture=EnvironmentValidationTests" --logger "console;verbosity=detailed"

# Run single test
dotnet test --filter "TestMethod=ValidateHealthEndpoint"
```

### CI/CD Integration

The tests are designed to run in headless mode by default, making them suitable for CI/CD pipelines:

```yaml
# Example GitHub Actions step
- name: Run Environment Validation
  run: |
    ./scripts/wait-for-environment.sh ${{ env.BASE_URL }} 300
    ./scripts/run-e2e-validation.sh ${{ env.ENVIRONMENT }}
```

### Configuration Options

Environment variables that control test behavior:

- `TETE_BASE_URL`: Target application URL (required)
- `TETE_HEADLESS`: Run browser in headless mode (default: true)
- `TETE_TIMEOUT`: Test timeout in seconds (default: 300)

### Troubleshooting

**Browser Issues:**
- Ensure Chrome/Chromium is installed
- For Linux servers, install: `apt-get install -y chromium-browser`
- Use `--headed` flag to see browser interactions

**Connection Issues:**
- Verify the target URL is accessible
- Check if authentication is required
- Ensure all necessary ports are open

**Test Failures:**
- Check application logs for errors
- Verify database connectivity
- Ensure all required services are running

### Adding Custom Validations

To add environment-specific validations:

1. Add new test methods to `EnvironmentValidationTests`
2. Use the `[Test, Order(N)]` attribute to control execution order
3. Follow the existing pattern of checking multiple conditions
4. Use descriptive assertion messages

Example:
```csharp
[Test, Order(11)]
public void ValidateCustomFeature()
{
    // Your validation logic here
    Assert.That(condition, Is.True, "Custom feature should work");
}
```