.#!/bin/bash


tput setaf 3
echo -e "*******************************************************************************************************************"
echo -e "Deploy cert-manager & Container registry"
echo -e "*******************************************************************************************************************"


tput setaf 5
echo -e "\n \n*******************************************************************************************************************"
echo -e "Step 1: Deploy the cert-manager manifests "
echo -e "*******************************************************************************************************************"
tput setaf 2
echo -e "kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.16.1/cert-manager.yaml"
tput setaf 3
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.16.1/cert-manager.yaml


tput setaf 5
echo -e "\n \n*******************************************************************************************************************"
echo -e "Step 1(2): Check pods "
echo -e "*******************************************************************************************************************"
tput setaf 2
echo -e "kubectl get pods -n cert-manager"
kubectl get pods -n cert-manager
sleep 15


tput setaf 5
echo -e "\n \n*******************************************************************************************************************"
echo -e "Step 1(2): Check pods "
echo -e "*******************************************************************************************************************"
tput setaf 2
echo -e "kubectl get pods -n cert-manager"
kubectl get pods -n cert-manager

tput setaf 5
echo -e "\n \n*******************************************************************************************************************"
echo -e "Step 3: Generate the certificate"
echo -e "*******************************************************************************************************************"
tput setaf 3
cd cert-manager
sh ./makeca.sh
cd ssl
kubectl create secret tls ca-key-pair --key=./tls.key --cert=./tls.crt -n cert-manager


tput setaf 5
echo -e "\n \n*******************************************************************************************************************"
echo -e "Step 3: Create the ClusterIssuer object so that all of our Ingress objects can have properly minted certificates"
echo -e "*******************************************************************************************************************"
tput setaf 3
cd ..
sleep 5
kubectl create -f ./certmanager-ca.yaml


echo -e "\n \n*******************************************************************************************************************"
echo -e "Step 4: Import our certificate into both our worker and nodes"
echo -e "*******************************************************************************************************************"
cd ~/
kubectl get secret ca-key-pair -n cert-manager -o json | jq -r '.data["tls.crt"]' | base64 -d > internal-ca.crt
docker cp internal-ca.crt cluster01-worker:/usr/local/share/ca-certificates/internal-ca.crt
docker exec -ti cluster01-worker update-ca-certificates 
docker restart cluster01-worker
docker cp internal-ca.crt cluster01-control-plane:/usr/local/share/ca-certificates/internal-ca.crt
docker exec -ti cluster01-control-plane update-ca-certificates
docker restart cluster01-control-plane

tput setaf 7
cd ~/k8-demos
kubectl create -f ./docker-registry.yaml 
echo -e "\n \n*******************************************************************************************************************"
echo -e "cert-manager & docker registry deployments complete \n"
echo -e "******************************************************************************************************************* \n"
