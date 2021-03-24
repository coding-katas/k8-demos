.#!/bin/bash




tput setaf 2
echo -e "*******************************************************************************************************************"
echo -e "Menu "
echo -e "*******************************************************************************************************************"


tput setaf 3
PS3='Please enter your choice: '
options=("create one cluster with kind (CNI=calico/ingress nginx)" "deploy cert-mnanager/docker registry" "deploy OpenUnison" "deploy Gitlab" "deploy Tekton" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "create one cluster with kind (CNI=calico/ingress nginx)")
            ./create-cluster.sh
            echo "you chose choice 1"
            ;;
        "deploy cert-mnanager/docker registry")
            echo "you chose choice 2"
            ./deploy-cert-manager.sh            
            ;;
        "deploy OpenUnison")
            echo "you chose choice 3"
            ./deploy-openunison.sh
            ;;
        "deploy Gitlab")
            echo "you chose choice 4"
            ./deploy-gitlab.sh
            ;;
        "deploy Tekton")
            echo "you chose choice 5"
            ./deploy-gitlab.sh
            ;;
        "Quit")
            break
            ;;
        *) echo invalid option;;
    esac
done