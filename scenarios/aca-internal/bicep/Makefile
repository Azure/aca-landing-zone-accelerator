# Global variables
LOCATION=westeurope

CERT_LOCATION=./06-application-gateway/configuration

default:
	@echo 'Makefile action should be specified. Aborting ...'

all : deploy-hub deploy-shared deploy-spoke 

deploy-hub:

	@echo 'Creating hub ...'
	@az deployment sub create --template-file ./01-hub/main.bicep --location $(LOCATION) --parameters ./01-hub/parameters-main.json # --no-wait

deploy-shared:
	@echo 'Creating shared ...'
	@az deployment sub create --template-file ./02-shared/main.bicep --location $(LOCATION) --parameters ./02-shared/parameters-shared.json # --no-wait

deploy-spoke:
	@echo 'Creating spoke ...'
	@az deployment sub create --template-file ./03-spoke/main.bicep --location $(LOCATION) --parameters ./03-spoke/parameters-spoke.json # --no-wait

clean:
	@echo 'Deleting ...'
# # TODO : Resolve name to delete resource group
# RESOURCE_GROUP_NAME = cat ./01-hub/parameters-main.json | jq -r '.parameters.workloadName.value'
# RESOURCE_GROUP_NAME = cat ./01-hub/parameters-main.json | jq -r '.parameters.environment.value'
# RESOURCE_GROUP_NAME = cat ./01-hub/parameters-main.json | jq -r '.parameters.workloadName.value'

	@az group delete --name 'rg-eslz-hub-dev-westeurope'

appgw-create-selfsignedcert:
	@echo 'Create certificate request ...'
	openssl \
        req \
        -nodes \
        -newkey rsa:2048 \
        -keyout $(CERT_LOCATION)/acahello.demoapp.com.key \
        -out $(CERT_LOCATION)/acahello.demoapp.com.csr \
        -subj "/C=FR/ST=ESS/L=Paris/O=LZA/OU=LZA/CN=acahello.demoapp.com/emailAddress=lza@microsoft.com"
	@echo @echo 'Create certificate request ...'
	openssl x509 -signkey $(CERT_LOCATION)/acahello.demoapp.com.key -in $(CERT_LOCATION)/acahello.demoapp.com.csr -req -days 365 -out $(CERT_LOCATION)/acahello.demoapp.com.crt
	@echo 'Create certificate request ...'
	openssl pkcs12 -inkey $(CERT_LOCATION)/acahello.demoapp.com.key -in $(CERT_LOCATION)/acahello.demoapp.com.crt -export -out $(CERT_LOCATION)/acahello.demoapp.com.pfx
