.#!/bin/bash



tput setaf 3
echo -e "*******************************************************************************************************************"
echo -e "Deploy Gitlab"
echo -e "*******************************************************************************************************************"




tput setaf 6
echo -e "\n \n*******************************************************************************************************************"
echo -e "Step 1: Deploy mariaDb"
echo -e "*******************************************************************************************************************"
tput setaf 2
echo -e "$ kubectl create ns gitlab"
tput setaf 3
kubectl create ns gitlab



kubectl get secret ca-key-pair \
-n cert-manager -o json | jq -r '.data["tls.crt"]' \
| base64 -d > tls.crt


kubectl create secret generic  internal-ca --from-file=. -n gitlab

cd gitlab
kubectl create secret generic gitlab-oidc --from-file=. -n gitlab

helm repo add gitlab https://charts.gitlab.io
helm install gitlab gitlab/gitlab -n gitlab -f gitlab-values.yaml


kubectl edit ingress -n gitlab
# change 

kubectl get secret gitlab-gitlab-initial-root-password -o json -n gitlab | jq -r '.data.password' | base64 -d
