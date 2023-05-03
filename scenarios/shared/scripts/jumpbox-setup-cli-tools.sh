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

# Install Microsoft OpenJDK 17
ubuntu_release=`lsb_release -rs`
wget https://packages.microsoft.com/config/ubuntu/${ubuntu_release}/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
sudo apt-get install apt-transport-https
sudo apt-get update
sudo apt-get install msopenjdk-17 -y

# Install Maven
wget https://dlcdn.apache.org/maven/maven-3/3.8.7/binaries/apache-maven-3.8.7-bin.tar.gz -P /tmp
sudo tar xf /tmp/apache-maven-*.tar.gz -C /opt
sudo ln -s /opt/apache-maven-3.8.7 /opt/maven

echo "export JAVA_HOME=/usr/lib/jvm/msopenjdk-17-amd64" >> ~/.bashrc
echo "export M2_HOME=/opt/maven" >> ~/.bashrc
echo "export MAVEN_HOME=/opt/maven" >> ~/.bashrc
echo "export PATH=${M2_HOME}/bin:${PATH}" >> ~/.bashrc
exit

source ~/.bashrc


# install Terraform CLI
# https://learn.hashicorp.com/tutorials/terraform/install-cli
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common

wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg

gpg --no-default-keyring \
    --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    --fingerprint

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/hashicorp.list

# install Terraform
sudo apt-get install -y terraform

terraform version
