.#!/bin/bash



tput setaf 3
echo -e "*******************************************************************************************************************"
echo -e "Deploy ArgoCD"
echo -e "*******************************************************************************************************************"






tput setaf 6
echo -e "\n \n*******************************************************************************************************************"
echo -e "Step 1: Deploy ArgoCD"
echo -e "*******************************************************************************************************************"
tput setaf 2
echo -e "$ kubectl create ns gitlab"
tput setaf 3
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -n argocd -f argocd0/argocd-ingress.yaml


kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2

kubectl edit deployment -n argocd
#spec:
#containers:
#-	command:
#-	argocd-server
#-	--staticassets
#-	/shared/app
#-	--repo-server
#-	argocd-repo-server:8081
#-	--insecure


VERSION=$(curl --silent "https://api.github.com/repos/argoproj/argo-cd/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
sudo curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/v1.8.7/argocd-linux-amd64
sudo chmod +x /usr/local/bin/argocd


kubectl --namespace argocd \
    get pods \
    --selector app.kubernetes.io/name=argocd-server \
    --output name \
    | cut -d'/' -f 2


kubectl \
    --namespace argocd \
    get secret argocd \
    --output jsonpath="{.data.password}" \
    | base64 --decode

curl -sLO https://github.com/argoproj/argo/releases/download/v3.0.0-rc8/argo-linux-amd64.gz
gunzip argo-linux-amd64.gz
chmod +x argo-linux-amd64
sudo mv ./argo-linux-amd64 /usr/local/bin/argo
argo version






exit
cd argocd-production

export REGISTRY_SERVER=https://index.docker.io/v1/

# Replace `[...]` with the registry username
export REGISTRY_USER=tajouria
export REGISTRY_PASS=fitality
export REGISTRY_EMAIL=anis.tajouri@gmail.com


kubectl create namespace workflows
kubectl --namespace workflows \
    create secret \
    docker-registry regcred \
    --docker-server=$REGISTRY_SERVER \
    --docker-username=$REGISTRY_USER \
    --docker-password=$REGISTRY_PASS \
    --docker-email=$REGISTRY_EMAIL

export ARGO_WORKFLOWS_HOST=argo-workflows.172.18.0.1.xip.io


cd argo
cat argo-workflows/base/ingress_patch.json \
    | sed -e "s@acme.com@$ARGO_WORKFLOWS_HOST@g" \
    | tee argo-workflows/overlays/production/ingress_patch.json

kustomize build \
    argo-workflows/overlays/production \
    | kubectl apply --filename -

kubectl --namespace argo \
    rollout status \
    deployment argo-server \
    --watch


cd ../argo-workflows-demo


cd argo-workflows-demo

cat workflows/silly.yaml

cat workflows/parallel.yaml

cat workflows/dag.yaml

#############
# Templates #
#############

cat workflows/cd-mock.yaml

cat workflow-templates/container-image.yaml

kubectl --namespace workflows apply \
    --filename workflow-templates/container-image.yaml

kubectl --namespace workflows \
    get clusterworkflowtemplates

########################
# Submitting workflows #
########################

argo --namespace workflows submit \
    workflows/cd-mock.yaml

argo --namespace workflows list

argo --namespace workflows \
    get @latest

argo --namespace workflows \
    logs @latest \
    --follow