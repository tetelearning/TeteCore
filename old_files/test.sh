dotnet clean
dotnet test -p:CollectCoverage=true -p:CoverletOutputFormat=\"opencover,lcov\" -p:CoverletOutput=coverage/lcov