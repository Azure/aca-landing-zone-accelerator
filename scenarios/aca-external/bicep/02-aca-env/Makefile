DEP_LOCATION=westeurope
$(eval RG_NAME = $(shell jq .parameters.rgName.value ./parameters-main.json))

default: deploy

deploy:
	@echo 'Deploying $(RG_NAME) ...'
	@az deployment sub create --template-file main.bicep --location $(DEP_LOCATION) --parameters ./parameters-main.json

clean:
	@echo 'Deleting $(RG_NAME) ...'
	@az group delete --resource-group $(RG_NAME) --yes