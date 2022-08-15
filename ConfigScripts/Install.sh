#!/bin/bash

echo "hello world"

# redirect output to log file
# exec >/tmp/k3s-server-install-debug.log 2>&1

# capture argumants into usable variables

# admin user/pw
AdminUser=$1
AdminPW=$2

#RHEL subscription user/pw
RHEL_Sub_user=$3
RHEL_Sub_PW=$4

K3sRole=$5
MasterCount=$6
K3s_Token=$7

K3s_Cluster_IP=$8

# # add user to file so no password required to sudo
# echo "$AdminUser ALL=(ALL) NOPASSWD ALL" | sudo EDITOR='tee -a' visudo -S

# # register with RHEL subscription and update 
echo $AdminPW | sudo -S subscription-manager register --username $RHEL_Sub_user --password $RHEL_Sub_PW --auto-attach
echo $AdminPW | sudo -S yum update -y

# create folder for SSH Key
# mkdir -p /home/$AdminUser/.ssh

# if [[ $K3sRole -eq "master" ]]; then
#     # install master

#     if [[ $MasterCount -eq 0 ]]; then
#         echo "New Custer"
#         curl -sfL https://get.k3s.io | sh -s server --cluster-init --token $K3s_Token
#     else 
#         echo "Adding to cluster"
#         curl -sfL https://get.k3s.io | K3S_TOKEN=$K3s_Token sh -s server --server https://$K3s_Cluster_IP:6443
#     fi

    
# else
#     echo "Worker nodes"
# fi

