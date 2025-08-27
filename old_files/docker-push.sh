docker stop tete-web

# remove existing container
docker rm tete-web

# clean the dotnet build files
dotnet clean

# build a new version of core
docker build -f Web.Dockerfile -t tete-web-img .

docker tag tete-web-img:latest puremunky/tete-web:latest

docker push puremunky/tete-web:latest