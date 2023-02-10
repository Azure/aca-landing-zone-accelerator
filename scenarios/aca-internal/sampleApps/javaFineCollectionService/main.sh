#!/bin/bash
red='\e[1;31m%s\e[0m\n'
green='\e[1;32m%s\e[0m\n'
blue='\e[1;34m%s\e[0m\n'

if [ -z "$RESOURCE_GROUP" ]
then
      printf "$red" "RESOURCE_GROUP variable is empty. Please use export RESOURCE_GROUP=\"resource-group-name\""
      exit 1

fi

# create container apps and dependencies

printf "$blue" "Creating fine collector service apps in resourge group ($RESOURCE_GROUP)..."
az deployment group create \
    --resource-group $RESOURCE_GROUP \
    --template-file ./bicep/deploy-sampleapp-main.bicep \
    --parameters ./bicep/deploy-sampleapp-parameters.json


if [ $? -eq 0 ] 
      then 
      printf "$green" "Solution deploy completed"
      exit 0 
      else 
      printf "$red" "Could not create all solution resources" >&2 
      exit 1 
      fi
