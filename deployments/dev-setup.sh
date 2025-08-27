# export teteDBPassword=$(</dev/urandom tr -dc '12345!@#$%qwertQWERTasdfgASDFGzxcvbZXCVB' | head -c16; echo "aA!")

kubectl --kubeconfig="tete-dev-k8s-1-18-8-do-0-sfo2-1599658100409-kubeconfig.yaml" create namespace tete-dev
# echo -n ${teteDBPassword} > ./dev-secrets/dev-db-password.txt
# echo -n "Server=tete-db-svc; Database=Tete; User ID=sa; Password=${teteDBPassword};" > ./dev-secrets/dev-connection-string.txt
# echo -n "tetePassword!" > ./dev-secrets/dev-cert-password.txt
kubectl --kubeconfig="tete-dev-k8s-1-18-8-do-0-sfo2-1599658100409-kubeconfig.yaml" create secret generic db-credentials -n tete-dev --from-file=password=./dev-secrets/dev-db-password.txt --from-file=connection-string=./dev-secrets/dev-connection-string.txt
kubectl --kubeconfig="tete-dev-k8s-1-18-8-do-0-sfo2-1599658100409-kubeconfig.yaml" create secret generic cert-credentials -n tete-dev --from-file=cert-password=./dev-secrets/dev-cert-password.txt
kubectl --kubeconfig="tete-dev-k8s-1-18-8-do-0-sfo2-1599658100409-kubeconfig.yaml" apply -f ./do-dev.yml