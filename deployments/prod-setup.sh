# export teteDBPassword=$(</dev/urandom tr -dc '12345!@#$%qwertQWERTasdfgASDFGzxcvbZXCVB' | head -c16; echo "aA!")

kubectl --kubeconfig="tete-prod-k8s-1-18-8-do-1-sfo2-1602065310385-kubeconfig.yaml" create namespace tete-prod
# echo -n ${teteDBPassword} > ./prod-secrets/prod-db-password.txt
# echo -n "Server=tete-db-svc; Database=Tete; User ID=sa; Password=${teteDBPassword};" > ./prod-secrets/prod-connection-string.txt
# echo -n "tetePassword!" > ./prod-secrets/prod-cert-password.txt
kubectl --kubeconfig="tete-prod-k8s-1-18-8-do-1-sfo2-1602065310385-kubeconfig.yaml" create secret generic db-credentials -n tete-prod --from-file=password=./prod-secrets/prod-db-password.txt --from-file=connection-string=./prod-secrets/prod-connection-string.txt
kubectl --kubeconfig="tete-prod-k8s-1-18-8-do-1-sfo2-1602065310385-kubeconfig.yaml" create secret generic cert-credentials -n tete-prod --from-file=cert-password=./prod-secrets/prod-cert-password.txt
kubectl --kubeconfig="tete-prod-k8s-1-18-8-do-1-sfo2-1602065310385-kubeconfig.yaml" apply -f ./do-prod.yml