#!/bin/bash

# Script Definition
logpath=/var/log/deploymentscriptlog

# Upgrading Linux Distribution
echo "#############################" >> $logpath
echo "Upgrading Linux Distribution" >> $logpath
echo "#############################" >> $logpath
sudo apt-get update >> $logpath
sudo apt-get -y upgrade >> $logpath
echo " " >> $logpath

# Install Azure CLI
echo "#############################" >> $logpath
echo "Installing Azure CLI" >> $logpath
echo "#############################" >> $logpath
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install Docker
echo "#############################" >> $logpath
echo "Installing Docker" >> $logpath
echo "#############################" >> $logpath
wget -qO- https://get.docker.com/ | sh >> $logpath
sudo usermod -aG docker $1
echo " " >> $logpath


# install Terraform CLI
# https://learn.hashicorp.com/tutorials/terraform/install-cli
echo "#############################" >> $logpath
echo "Installing Terraform" >> $logpath
echo "#############################" >> $logpath

wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

terraform version