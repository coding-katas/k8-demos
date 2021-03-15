.#!/bin/bash


tput setaf 3
echo -e "*******************************************************************************************************************"
echo -e "Deploy openunison for authentification to interact securely with Kubernetes"
echo -e "*******************************************************************************************************************"


tput setaf 6
echo -e "\n \n*******************************************************************************************************************"
echo -e "Step 1: Deploy mariaDb"
echo -e "*******************************************************************************************************************"
tput setaf 2
echo -e "$ kubectl apply  -f openunison/mariadb.yaml"
tput setaf 3
kubectl apply  -f openunison/mariadb.yaml

echo -e "\n \n*******************************************************************************************************************"
echo -e "Step 2: deploy the SMTP black hole"
echo -e "*******************************************************************************************************************"
tput setaf 2
echo -e "$ kubectl create ns blackhole"
tput setaf 3
kubectl create ns blackhole
tput setaf 2
echo -e "$ kubectl create deployment blackhole --image=tremolosecurity/smtp-blackhole -n blackhole"
tput setaf 3
kubectl create deployment blackhole --image=tremolosecurity/smtp-blackhole -n blackhole
tput setaf 2
echo -e "$ kubectl expose deployment/blackhole --type=ClusterIP --port 1025 --target-port=1025 -n blackhole"
tput setaf 3
kubectl expose deployment/blackhole --type=ClusterIP --port 1025 --target-port=1025 -n blackhole

#exit

tput setaf 5
echo -e "\n \n*******************************************************************************************************************"
echo -e "Step 3: deploy openunison from https://github.com/OpenUnison/openunison-k8s-login-saml2"
echo -e "*******************************************************************************************************************"
tput setaf 2
#echo -e "$ helm delete orchestra --namespace openunison"
tput setaf 3
#helm delete orchestra --namespace openunison
#helm delete openunison --namespace openunison

tput setaf 5
echo -e "\n \n*******************************************************************************************************************"
echo -e "Step 3: deploy the dashboard"
echo -e "*******************************************************************************************************************"
tput setaf 2
echo -e "$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml

tput setaf 5
echo -e "\n \n*******************************************************************************************************************"
echo -e "Step 4: Add Tremolo Security's Helm Repo & update (see https://artifacthub.io/packages/helm/tremolo/openunison-k8s-saml2)"
echo -e "*******************************************************************************************************************"
tput setaf 2
echo -e "$ helm repo add tremolo https://nexus.tremolo.io/repository/Helm/ && helm repo update"
helm repo add tremolo https://nexus.tremolo.io/repository/Helm/
helm repo update

tput setaf 5
echo -e "\n \n*******************************************************************************************************************"
echo -e "Step 5: deploy openunison "
echo -e "*******************************************************************************************************************"
tput setaf 2
echo -e "$ kubectl create ns openunison"
kubectl create ns openunison
echo -e "$ helm install openunison tremolo/openunison-operator --namespace openunison"
helm install openunison tremolo/openunison-operator --namespace openunison


tput setaf 5
echo -e "\n \n*******************************************************************************************************************"
echo -e "Step 6: Wait for pod openunison-operator to be in running state"
echo -e "*******************************************************************************************************************"
kubectl get pods --namespace openunison
kubectl wait --for=condition=ready pod -l app=openunison-operator --namespace openunison
kubectl get pods --namespace openunison

tput setaf 5
echo -e "\n \n*******************************************************************************************************************"
echo -e "Step 7: create the secret"
echo -e "*******************************************************************************************************************"
tput setaf 2
echo -e "$ kubectl create -f openunison/secret.yaml"
kubectl create -f openunison/secret.yaml


tput setaf 5
echo -e "\n \n*******************************************************************************************************************"
echo -e "Step 8: deploy openunison with all values cert"
echo -e "*******************************************************************************************************************"
tput setaf 2
echo -e "$ helm install orchestra tremolo/openunison-k8s-saml2 --namespace openunison -f ./openunison/values.yaml"
helm install orchestra tremolo/openunison-k8s-saml2 --namespace openunison -f openunison/values.yaml


tput setaf 5
echo -e "\n \n*******************************************************************************************************************"
echo -e "Step 6: Wait for pod openunison-orchestra to be in running state"
echo -e "*******************************************************************************************************************"
kubectl get pods --namespace openunison
kubectl wait --for=condition=ready pod -l app=openunison-orchestra --namespace openunison
kubectl get pods --namespace openunison


tput setaf 5
echo -e "\n \n*******************************************************************************************************************"
echo -e "Step 6: Wait for pods"
echo -e "*******************************************************************************************************************"
kubectl wait --for=condition=ready pod -l app=openunison --namespace openunison



echo -e "\n \n*******************************************************************************************************************"
echo -e "Step 7: Wait until openunison is running"
echo -e "*******************************************************************************************************************"
tput setaf 2
echo -e "$ kubectl get pods -n openunison"
kubectl get pods -n openunison

#docker.io/tremolosecurity/openunison- k8s-login-saml2:latest to 
#docker.io/tremolosecurity/openunison-k8s-saml2:latest







echo -e "\n \n*******************************************************************************************************************"
echo -e "Step 9: remove ou-tls-certificate"
echo -e "*******************************************************************************************************************"
tput setaf 2
echo -e "$ kubectl get pods -n openunison"

kubectl edit openunison orchestra -n openunison
#REMOVE:
#- create_data: ca_cert: true key_size: 2048
#server_name: k8sou.apps.192-168-2-114.nip.io sign_by_k8s_ca: false subject_alternative_names:
#- k8sdb.apps.192-168-2-114.nip.io
#- k8sapi.apps.192-168-2-114.nip.io import_into_ks: certificate
#name: unison-ca
#tls_secret_name: ou-tls-certificate


kubectl delete secret ou-tls-certificate -n openunison

kubectl edit ingress -n openunison
#add to annotations--> cert-manager.io/cluster-issuer: ca-issuer 

# Test the indentity provider
curl --insecure https://k8sou.apps.172-18-0-1.nip.io/auth/forms/saml2_rp_metadata.jsp