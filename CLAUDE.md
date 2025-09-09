# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

TeteCore is the core services and applications that drive the TeteLearning platform. This is a .NET 8.0 web application with an Angular frontend for language learning services.

## Architecture

The solution follows a layered architecture with clear separation of concerns:

- **Tete.Web**: Main ASP.NET Core web application (net8.0) with Angular SPA frontend
- **Tete.Models**: Domain models and data structures
- **Tete.Tests**: Unit tests using NUnit, Moq, and Coverlet for code coverage
- **Tete.E2ETests**: End-to-end tests

### Technology Stack
- **Backend**: ASP.NET Core 8.0, Entity Framework Core 3.1, SQL Server
- **Frontend**: Angular 10.2.x with TypeScript, Bootstrap 4
- **Testing**: NUnit, Moq, Jasmine/Karma for Angular tests
- **Deployment**: Kubernetes with Tilt for local development

## Development Commands

### Building and Running
```bash
# Clean the solution
dotnet clean

# Build the main web project
dotnet build Tete.Web/Tete.Web.csproj

# Build the entire solution
dotnet build

# Run the application locally (use Tilt for K8s deployment)
tilt up

# Initialize database schema and seed data (after tilt up is running)
curl http://localhost:8080/Init/Migrate   # Create database schema
curl http://localhost:8080/Init/Populate  # Add base data (admin user, languages, topics)
```

### Health Monitoring
```bash
# Check application and database health
curl http://localhost:8080/health | jq .

# Expected response when healthy:
# {
#   "status": "healthy",
#   "timestamp": "2025-09-09T20:50:48.358Z", 
#   "application": "Tete Web API",
#   "database": {
#     "status": "connected",
#     "message": "Database connection successful"
#   }
# }
```

### Testing
```bash
# Run all unit tests with coverage
dotnet test -p:CollectCoverage=true -p:CoverletOutputFormat="opencover,lcov" -p:CoverletOutput=coverage/lcov

# Run tests for specific project
dotnet test Tete.Tests/Tete.Tests.csproj

# Angular frontend tests
cd Tete.Web/ClientApp
npm test
npm run e2e
```

### Frontend Development
```bash
# Navigate to Angular app
cd Tete.Web/ClientApp

# Install dependencies
npm install

# Start Angular dev server
npm start

# Build Angular app
npm run build

# Lint Angular code
npm run lint
```

### Local Kubernetes Development
The project uses Tilt for local Kubernetes development:

```bash
# Create local kind cluster
kind create cluster --name tete-local

# Deploy with Tilt (includes hot-reloading)
tilt up

# Tear down
tilt down
```

## Project Structure

### Backend Services (Tete.Web/Services/)
- **Authentication/**: LoginService for user authentication
- **Config/**: Settings and feature flags management
- **Content/**: Topic and link management services
- **Localization/**: Language and user language preference services
- **Logging/**: Application logging service
- **Relationship/**: Mentorship and user relationship services
- **Users/**: User management and profile services

### API Controllers (Tete.Web/Controllers/)
- **V1/**: Versioned API controllers for various domains
- RESTful endpoints for user management, content, settings, etc.

### Frontend (Tete.Web/ClientApp/)
- Angular SPA with standard Angular CLI structure
- Bootstrap 4 for styling
- Angular 10.2.x with TypeScript

### Database
- Entity Framework Core with SQL Server
- Database migrations in Tete.Web/Migrations/
- Main context: MainContext.cs

## Key Development Notes

- The web project includes automatic npm dependency installation and Angular build steps
- Entity Framework migrations are managed within the Tete.Web project
- The solution uses coverlet for .NET code coverage reporting
- Angular tests use Jasmine/Karma with code coverage reporting
- Authentication uses custom JWT implementation with user blocking features
- The application supports multiple languages through the localization services

## VSCode Integration

The project includes VSCode tasks for common operations:
- `build-web`: Build the main web project
- `unit-test`: Run tests with coverage
- `buildDockerDb`: Docker database setup
- `runInContainers`: Run in container environment