# stop existing container
docker stop tete-db

# remove existing container
docker rm tete-db

# clean the project
dotnet clean

# build docker image
docker build -f Db.Dockerfile -t tete-db-img .

# run docker image
docker run -dit --name tete-db -p 1433:1433 tete-db-img

# ./run.sh