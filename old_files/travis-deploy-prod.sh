#!/bin/bash
echo "$DOCKER_TOKEN" | docker login -u "$DOCKER_USERNAME" --password-stdin
echo "$KUBERNETES_CLUSTER_CERTIFICATE" | base64 --decode > cert.crt

docker tag tete-web-img:latest puremunky/tete-web:prod-$TRAVIS_BUILD_NUMBER

docker push puremunky/tete-web:prod-$TRAVIS_BUILD_NUMBER

sudo apt-get update && sudo apt-get install -y apt-transport-https gnupg2
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl

envsubst <./deployments/do-prod.yml >./deployments/do-prod.yml.out
mv ./deployments/do-prod.yml.out ./deployments/do-prod.yml
kubectl --kubeconfig=/dev/null --token=$KUBERNETES_TOKEN --server=$KUBERNETES_SERVER --certificate-authority=cert.crt apply -f ./deployments/do-prod.yml
