export teteDBUser="sa"
export teteDBPassword=$(</dev/urandom tr -dc '12345!@#$%qwertQWERTasdfgASDFGzxcvbZXCVB' | head -c16; echo "aA!")
export teteDBServer="tete-db"

# stop existing container
docker stop tete-web
docker stop tete-db

# remove existing container
docker rm tete-web
docker rm tete-db

# clean the dotnet build
dotnet clean

# build a new version of core
docker build -f Web.Dockerfile -t tete-web-img .

# run core app
docker run -dit --name tete-db -p 1433:1433 -e ACCEPT_EULA=Y -e MSSQL_PID=Developer -e SA_PASSWORD=$teteDBPassword mcr.microsoft.com/mssql/server:2017-CU8-ubuntu
docker run -dit --name tete-web -p 80:80 -p 443:443 --link tete-db --env ASPNETCORE_URLS="https://+:443;http://+:80" --env ConnectionStrings__DefaultConnection="Server=$teteDBServer; Database=Tete; User ID=$teteDBUser; Password=$teteDBPassword" --env ASPNETCORE_Kestrel__Certificates__Default__Path="./Tete.Web.pfx" --env ASPNETCORE_Kestrel__Certificates__Default__Password="tetePassword!" tete-web-img

#dotnet run --project Tete.Web/Tete.Web.csproj

# ./run.sh