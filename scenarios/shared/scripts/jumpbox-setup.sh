#!/bin/bash

##########################################################
# Example of script to setup the jumpbox, build the images
# and push them to the container registry
##########################################################

sudo apt-get update
sudo apt-get upgrade

# Install Microsoft OpenJDK 17
ubuntu_release=`lsb_release -rs`
wget https://packages.microsoft.com/config/ubuntu/${ubuntu_release}/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
sudo apt-get install apt-transport-https
sudo apt-get update
sudo apt-get install msopenjdk-17 -y

# Install Maven
wget https://dlcdn.apache.org/maven/maven-3/3.9.1/binaries/apache-maven-3.9.1-bin.tar.gz -P /tmp
sudo tar xf /tmp/apache-maven-*.tar.gz -C /opt
sudo ln -s /opt/apache-maven-3.9.1 /opt/maven -s

echo "export JAVA_HOME=/usr/lib/jvm/msopenjdk-17-amd64" >> ~/.bashrc
echo "export M2_HOME=/opt/maven" >> ~/.bashrc
echo "export MAVEN_HOME=/opt/maven" >> ~/.bashrc
echo "export PATH=${M2_HOME}/bin:${PATH}" >> ~/.bashrc
exit

source ~/.bashrc

# Install Docker
sudo apt-get remove docker docker-engine docker.io containerd runc
sudo apt-get update
sudo apt-get install     ca-certificates     curl     gnupg     lsb-release -y
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
# TODO check this. Needed to run docker without sudo and to access the docker.sock
sudo chmod 666 /home/azureuser/.docker/config.json
sudo chmod 666 /var/run/docker.sock

# Install AZ CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Clone the repository and build it
cd ~
git clone https://github.com/Azure/java-aks-aca-dapr-workshop.git
cd ~/java-aks-aca-dapr-workshop
git checkout feature/e2e-flow
mvn clean package

# Setup container registry
VEHICLE_REGISTRATION_SERVICE="vehicle-registration-service"
FINE_COLLECTION_SERVICE="fine-collection-service"
TRAFFIC_CONTROL_SERVICE="traffic-control-service"
# TODO get the registry name and get the auto login
AZURE_CONTAINER_REGISTRY="<ADD_CONTAINER REGISTRY_NAME>"
AZURE_CONTAINER_REGISTRY_URL="<ADD_CONTAINER REGISTRY_NAME>.azurecr.io"
IMAGE_TAG="1.0"

# Login to Azure and AZ ACR
az login
sudo az acr login -n $AZURE_CONTAINER_REGISTRY

# Build Vehicle Registration Service Image
cd VehicleRegistrationService
mvn spring-boot:build-image -Dspring-boot.build-image.imageName=$AZURE_CONTAINER_REGISTRY_URL/$VEHICLE_REGISTRATION_SERVICE:$IMAGE_TAG
sudo docker push $AZURE_CONTAINER_REGISTRY_URL/$VEHICLE_REGISTRATION_SERVICE:$IMAGE_TAG

# Build Fine Collection Service Image
cd ../FineCollectionService
mvn spring-boot:build-image -Dspring-boot.build-image.imageName=$AZURE_CONTAINER_REGISTRY_URL/$FINE_COLLECTION_SERVICE:$IMAGE_TAG
sudo docker push $AZURE_CONTAINER_REGISTRY_URL/$FINE_COLLECTION_SERVICE:$IMAGE_TAG

# Build Traffic Control Service Image
cd ../TrafficControlService
mvn spring-boot:build-image -Dspring-boot.build-image.imageName=$AZURE_CONTAINER_REGISTRY_URL/$TRAFFIC_CONTROL_SERVICE:$IMAGE_TAG
sudo docker push $AZURE_CONTAINER_REGISTRY_URL/$TRAFFIC_CONTROL_SERVICE:$IMAGE_TAG

# Build Simulation Image
cd ../Simulation
mvn spring-boot:build-image -Dspring-boot.build-image.imageName=$AZURE_CONTAINER_REGISTRY_URL/simulation:$IMAGE_TAG
sudo docker push $AZURE_CONTAINER_REGISTRY_URL/simulation:$IMAGE_TAG
