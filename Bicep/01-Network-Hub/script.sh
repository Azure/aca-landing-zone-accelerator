#!/bin/bash
#############################
# Script Definition
#############################
logpath=/var/log/deploymentscriptlog

#############################
# Upgrading Linux Distribution
#############################
echo "#############################" >> $logpath
echo "Upgrading Linux Distribution" >> $logpath
echo "#############################" >> $logpath
sudo apt-get update >> $logpath
sudo apt-get -y upgrade >> $logpath
echo " " >> $logpath

#############################
#Install Azure CLI
#############################
echo "#############################" >> $logpath
echo "Installing Azure CLI" >> $logpath
echo "#############################" >> $logpath
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

#############################
#Install Docker
#############################
echo "#############################" >> $logpath
echo "Installing Docker" >> $logpath
echo "#############################" >> $logpath
wget -qO- https://get.docker.com/ | sh >> $logpath
sudo usermod -aG docker $1
echo " " >> $logpath
