.#!/bin/bash




tput setaf 2
echo -e "*******************************************************************************************************************"
echo -e "Menu "
echo -e "*******************************************************************************************************************"


tput setaf 3
PS3='Please enter your choice: '
options=("create one cluster with kind (calico/nginx)" "deploy cert-mnanager/docker registry" "deploy OpenUnison" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "create one cluster with kind (calico/nginx)")
            ./create-cluster.sh
            echo "you chose choice 1"
            ;;
        "deploy cert-mnanager/docker registry")
            echo "you chose choice 2"
            ;;
        "deploy OpenUnison")
            echo "you chose choice 3"
            ;;
        "Quit")
            break
            ;;
        *) echo invalid option;;
    esac
done