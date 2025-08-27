# https://docs.microsoft.com/en-us/sql/linux/quickstart-install-connect-docker?view=sql-server-ver15&pivots=cs1-bash
# TODO: Update password process.
# TODO: Create an app account to use instead of SA.

export teteDBPassword="tetePassword!"

# stop existing container
docker stop tete-db

# remove existing container
docker rm tete-db

# build docker image
# docker build -f Db.Dockerfile -t tete-db-img .

# run docker image
#cmd //c "docker run -dit --name tete-db -p 1433:1433 -v ${PWD}/DB:/var/opt/mssql -e ACCEPT_EULA=Y -e MSSQL_PID=Express -e SA_PASSWORD=$teteDBPassword mcr.microsoft.com/mssql/server:2017-CU8-ubuntu"
docker run -dit --name tete-db -p 1433:1433 -e ACCEPT_EULA=Y -e MSSQL_PID=Express -e SA_PASSWORD=$teteDBPassword mcr.microsoft.com/mssql/server:2017-CU8-ubuntu

# create database migration
# cd Tete.Web && dotnet-ef migrations add build

# ./run-db.sh