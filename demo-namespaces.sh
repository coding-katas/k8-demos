#!/bin/bash

tput setaf 3
echo -e "*******************************************************************************************************************"
echo -e "Demo namespaces"
echo -e "*******************************************************************************************************************"


tput setaf 5
echo -e "\n \n*******************************************************************************************************************"
echo -e "Step 1: Create namespace for dev "
echo -e "*******************************************************************************************************************"
tput setaf 3
kubectl create namespace guestbook-dev
kubectl create namespace guestbook-qualif
kubectl get namespaces



kubectl apply -n guestbook-dev -f https://k8s.io/examples/application/guestbook/mongo-deployment.yaml
kubectl apply -n guestbook-dev -f https://k8s.io/examples/application/guestbook/mongo-service.yaml
kubectl apply -n guestbook-dev -f https://k8s.io/examples/application/guestbook/frontend-deployment.yaml
kubectl apply -n guestbook-dev -f https://k8s.io/examples/application/guestbook/frontend-service.yaml

kubectl port-forward svc/frontend 8080:80 -n guestbook-dev


tput setaf 7
echo -e "\n \n*******************************************************************************************************************"
echo -e "Now launch your frontend at port 80 \n"
echo -e "******************************************************************************************************************* \n"
