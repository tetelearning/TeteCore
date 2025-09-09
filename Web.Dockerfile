FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build-env
WORKDIR /app

# Install Node.js 20 (LTS) - compatible with Angular 18
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# Verify Node.js and npm versions
RUN node --version && npm --version

# Copy package files first for better Docker layer caching
COPY Tete.Web/ClientApp/package*.json ./Tete.Web/ClientApp/

# Install npm dependencies first
WORKDIR /app/Tete.Web/ClientApp
RUN npm install --omit=dev --no-audit --no-fund

# Copy everything else
WORKDIR /app
COPY . ./

# Create build info
RUN bash markbuild.sh

# Build the .NET application (this will also build Angular via MSBuild)
RUN dotnet publish -c Release -o out Tete.Web/Tete.Web.csproj

# Build runtime image
FROM mcr.microsoft.com/dotnet/aspnet:8.0
EXPOSE 80 443 
WORKDIR /app
COPY --from=build-env /app/out .

# Configure ASP.NET Core to listen on port 80 and disable HTTPS redirect for development
ENV ASPNETCORE_URLS=http://+:80
ENV ASPNETCORE_ENVIRONMENT=Development

# Add healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:80/ || exit 1

ENTRYPOINT ["dotnet", "Tete.Web.dll"]