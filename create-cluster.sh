#!/bin/bash


# need version 0.10.0 instead of default 0.7.0
sudo cp ~/kind /usr/lib/google-cloud-sdk/bin

tput setaf 3
echo -e "*******************************************************************************************************************"
echo -e "Creating KinD Cluster"
echo -e "*******************************************************************************************************************"

#sudo snap install kubectl --classic

tput setaf 5
#install helm and jq
#echo -e "\n \n*******************************************************************************************************************"
#echo -e "Step 2: Install Helm3 and jq"
#echo -e "*******************************************************************************************************************"
#tput setaf 3
#sudo snap install helm --classic
#sudo snap install jq --classic

tput setaf 5
#Create KIND Cluster calle cluster01 using config cluster01-kind.yaml
echo -e "\n \n*******************************************************************************************************************"
echo -e "Step 1: Create KinD Cluster using cluster01-kind.yaml configuration"
echo -e "*******************************************************************************************************************"
tput setaf 2
echo -e "$ kind create cluster --name cluster01 --config cluster01-kind.yaml"
tput setaf 3
kind create cluster --name cluster01 --config cluster01-kind.yaml

tput setaf 5
#Install Calico
echo -e "\n \n*******************************************************************************************************************"
echo -e "Step 2: deploy Calico (CNI instead of kindnet using 10.240.0.0/16 as the pod CIDR)"
echo -e "*******************************************************************************************************************"
tput setaf 2
echo -e "$ kubectl apply -f calico.yaml"
tput setaf 3
kubectl apply -f calico.yaml

#Deploy NGINX
tput setaf 5
echo -e "\n \n*******************************************************************************************************************"
echo -e "Step 3: Deploy NGINX Ingress Controller"
echo -e "*******************************************************************************************************************"
tput setaf 2
echo -e "$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-0.28.0/deploy/static/mandatory.yaml"
echo -e "$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-0.28.0/deploy/static/mandatory.yaml"
tput setaf 3
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-0.28.0/deploy/static/mandatory.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-0.27.0/deploy/static/provider/baremetal/service-nodeport.yaml

#Patch NGINX for to forward 80 and 443
tput setaf 5
echo -e "\n \n*******************************************************************************************************************"
echo -e "Step 4: Patch NGINX deployment to expose pod on HOST ports 81 ad 443"
echo -e "*******************************************************************************************************************"
tput setaf 3
kubectl patch deployments -n ingress-nginx nginx-ingress-controller -p '{"spec":{"template":{"spec":{"containers":[{"name":"nginx-ingress-controller","ports":[{"containerPort":80,"hostPort":81},{"containerPort":443,"hostPort":443}]}]}}}}'

#Find IP address of Docker Host
tput setaf 3
hostip=$(hostname  -I | cut -f1 -d' ')
echo -e "\n \n*******************************************************************************************************************"
echo -e "Cluster Creation Complete.  Please see the summary below:"
echo -e "*******************************************************************************************************************"

tput setaf 7
echo -e "\n \n*******************************************************************************************************************"
echo -e "Your Kind Cluster Information: \n"
echo -e "Ingress Domain: $hostip.nip.io \n"
echo -e "Ingress rules will need to use the IP address of your Linux Host in the Domain name \n"
echo -e "Example:  You have a web server you want to expose using a host called ordering."
echo -e "          Your ingress rule would use the hostname: ordering.$hostip.nip.io"
echo -e "******************************************************************************************************************* \n"
docker ps


#kind delete cluster --name cluster01 