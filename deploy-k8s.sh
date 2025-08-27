export teteDBPassword=$(</dev/urandom tr -dc '12345!@#$%qwertQWERTasdfgASDFGzxcvbZXCVB' | head -c16; echo "aA!")

# kubectl delete -f tete-deployment.yml

# stop existing container
docker stop tete-web

# remove existing container
docker rm tete-web

# clean the dotnet build files
dotnet clean

# build a new version of core
# docker build -f Web.Dockerfile -t tete-web-img .

# docker tag tete-web-img:latest puremunky/tete-web:latest

# docker push puremunky/tete-web:latest

# Deployment steps
kubectl create namespace tete-local
echo -n ${teteDBPassword} > ./secrets/db-password.txt
echo -n "Server=tete-db-svc; Database=Tete; User ID=sa; Password=${teteDBPassword};" > ./secrets/connection-string.txt
echo -n "tetePassword!" > ./secrets/cert-password.txt
kubectl apply secret generic db-credentials -n tete-local --from-file=password=./secrets/db-password.txt --from-file=connection-string=./secrets/connection-string.txt
kubectl apply secret generic cert-credentials -n tete-local --from-file=cert-password=./secrets/cert-password.txt
kubectl apply -f ./deployments/local.yml


# cd ~/.kube && kubectl --kubeconfig="tete-dev-k8s-1-15-2-do-0-sfo2-1565698757269-kubeconfig.yaml" delete --all pods -n=tete
# cd ~/.kube && kubectl --kubeconfig="tete-dev-k8s-1-15-2-do-0-sfo2-1565698757269-kubeconfig.yaml" log tete-api-966fdcb4f-9hlk8 -n=tete
# ./deploy.sh