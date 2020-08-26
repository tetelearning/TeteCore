# stop existing container
docker stop tete-api
docker stop tete-web

# remove existing container
docker rm tete-api
docker rm tete-web

# clean the dotnet build files
dotnet clean

# build a new version of core
docker build -f Db.Dockerfile -t tete-db-img .
docker build -f Web.Dockerfile -t tete-web-img .

docker tag tete-db-img:latest puremunky/tete-db:latest
docker tag tete-web-img:latest puremunky/tete-web:latest

docker push puremunky/tete-db:latest
docker push puremunky/tete-web:latest

# Deployment steps
# kubectl create namespace tete
# echo -n 'testingEXamplePass!234' > ./password.txt
# kubectl create secret generic db-credentials -n tete --from-file=password=./password.txt
# TODO: Add tete-web ENV secret
# kubectl apply -f tete-deployment.yml


# cd ~/.kube && kubectl --kubeconfig="tete-dev-k8s-1-15-2-do-0-sfo2-1565698757269-kubeconfig.yaml" delete --all pods -n=tete
# cd ~/.kube && kubectl --kubeconfig="tete-dev-k8s-1-15-2-do-0-sfo2-1565698757269-kubeconfig.yaml" log tete-api-966fdcb4f-9hlk8 -n=tete
# ./deploy.sh