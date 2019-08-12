FROM mcr.microsoft.com/dotnet/core/sdk:2.2 AS build-env
WORKDIR /app

RUN apt-get update
RUN apt-get -y install curl gnupg
RUN curl -sL https://deb.nodesource.com/setup_11.x  | bash -
RUN apt-get install nodejs -y

# Copy everything else and build
COPY . ./

RUN dotnet publish -c Release -o out Tete.Web/Tete.Web.csproj

# Build runtime image
FROM mcr.microsoft.com/dotnet/core/aspnet:2.2
EXPOSE 5000
EXPOSE 5001
WORKDIR /app
COPY --from=build-env /app/Tete.Web/out .
ENTRYPOINT ["dotnet", "Tete.Web.dll"]