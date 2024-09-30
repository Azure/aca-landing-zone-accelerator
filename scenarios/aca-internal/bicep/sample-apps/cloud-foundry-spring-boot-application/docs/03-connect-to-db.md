# Connect Container Apps with MySql Flexible Server

After create the Azure Container Apps and MySql Flexible Server, they are ready to be connected and work together. Since all these workloads are deployed inside a Virtual Network environment, all the operation to them should be finished inside the Virtual Network. Fortunately, we can use the jumbox we created before to operate these resources.

## Expected results
All the container apps can successfully connect to the MySql Flexible Server.

## Steps
1. Login to the VM using Bastion
  
    The username and password can be retrieved or set in [deploy.spoke.parameters.jsonc](../../../modules/02-spoke/deploy.spoke.parameters.jsonc), view `vmAdminUsername` and `vmAdminPassword`.

    ![bastion](../../../../../../docs/media/acaInternal/bastion-login.png)

1. Install pre-reqs Azure CLI, Docker client
    
    Unfortunatelly the jump host doesn't have the required tools installed. So, you would have to install them.

    - [az cli](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt)
        ```bash
        curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
        ```
    - Add necessary extensions
        ```bash
        az extension add --name containerapp
        az extension add --name serviceconnector-passwordless --upgrade
        ```

1. Login the Azure CLI and select current subscription. The subscription id can be retrieved from the Virtual Machine's overview blade.

    ```bash
    az login --use-device-code
    az account set -s <your-subscription-id>
    ```

1. Retrieve the environments

    ```bash
    RESOURCENAME_RESOURCEGROUP_SPOKE=$(az deployment sub show -n acalza01-spokenetwork --query properties.outputs.spokeResourceGroupName.value -o tsv)
    RESOURCEID_GATEWAY=$(az deployment group show -n acalza01-appplat-java -g $RESOURCENAME_RESOURCEGROUP_SPOKE --query properties.outputs.apiGatewayId.value -o tsv)
    RESOURCEID_CUSTOMERSERVICE=$(az deployment group show -n acalza01-appplat-java -g $RESOURCENAME_RESOURCEGROUP_SPOKE --query properties.outputs.customerServiceId.value -o tsv)
    RESOURCEID_VISITSSERVICE=$(az deployment group show -n acalza01-appplat-java -g $RESOURCENAME_RESOURCEGROUP_SPOKE --query properties.outputs.visitsServiceId.value -o tsv)
    RESOURCEID_VETSSERVICE=$(az deployment group show -n acalza01-appplat-java -g $RESOURCENAME_RESOURCEGROUP_SPOKE --query properties.outputs.vetsServiceId.value -o tsv)
    RESOURCEID_MYSQL_DATABASE=$(az deployment group show -n acalza01-appplat-java -g $RESOURCENAME_RESOURCEGROUP_SPOKE --query properties.outputs.databaseId.value -o tsv)
    RESOURCEID_MYSQL_USERASSIGNEDIDENTITY_CLIENTID=$(az deployment group show -n acalza01-appplat-java -g $RESOURCENAME_RESOURCEGROUP_SPOKE --query properties.outputs.userAssignedIdentityClientId.value -o tsv)
    RESOURCEID_MYSQL_USERASSIGNEDIDENTITY=$(az deployment group show -n acalza01-appplat-java -g $RESOURCENAME_RESOURCEGROUP_SPOKE --query properties.outputs.userAssignedIdentity.value -o tsv)
    SUBSCRIPTION_ID=$(az account show --query id -o tsv)

    echo RESOURCENAME_RESOURCEGROUP_SPOKE=$RESOURCENAME_RESOURCEGROUP_SPOKE && \
    echo RESOURCEID_GATEWAY=$RESOURCEID_GATEWAY && \
    echo RESOURCEID_CUSTOMERSERVICE=$RESOURCEID_CUSTOMERSERVICE && \
    echo RESOURCEID_VISITSSERVICE=$RESOURCEID_VISITSSERVICE && \
    echo RESOURCEID_VETSSERVICE=$RESOURCEID_VETSSERVICE && \
    echo RESOURCEID_MYSQL_DATABASE=$RESOURCEID_MYSQL_DATABASE && \
    echo RESOURCEID_MYSQL_USERASSIGNEDIDENTITY_CLIENTID=$RESOURCEID_MYSQL_USERASSIGNEDIDENTITY_CLIENTID && \
    echo RESOURCEID_MYSQL_USERASSIGNEDIDENTITY=$RESOURCEID_MYSQL_USERASSIGNEDIDENTITY && \
    echo SUBSCRIPTION_ID=$SUBSCRIPTION_ID
    ```

1. Create Service Connector for Azure Container Apps and MySql Flexible Server. The below commands create users in the database and these user will be used by Azure Container Apps to connect to database.

    ```bash
    az containerapp connection create mysql-flexible --connection mysql_api_gateway \
        --source-id ${RESOURCEID_GATEWAY} \
        --target-id ${RESOURCEID_MYSQL_DATABASE} \
        --client-type springBoot \
        --user-identity \
            client-id=${RESOURCEID_MYSQL_USERASSIGNEDIDENTITY_CLIENTID} \
            subs-id=${SUBSCRIPTION_ID} \
            mysql-identity-id=${RESOURCEID_MYSQL_USERASSIGNEDIDENTITY} \
        -c api-gateway
    az containerapp connection create mysql-flexible --connection mysql_customer_service \
        --source-id ${RESOURCEID_CUSTOMERSERVICE} \
        --target-id ${RESOURCEID_MYSQL_DATABASE} \
        --client-type springBoot \
        --user-identity \
            client-id=${RESOURCEID_MYSQL_USERASSIGNEDIDENTITY_CLIENTID} \
            subs-id=${SUBSCRIPTION_ID} \
            mysql-identity-id=${RESOURCEID_MYSQL_USERASSIGNEDIDENTITY} \
        -c customer-service
    az containerapp connection create mysql-flexible --connection mysql_visits_service \
        --source-id ${RESOURCEID_VISITSSERVICE} \
        --target-id ${RESOURCEID_MYSQL_DATABASE} \
        --client-type springBoot \
        --user-identity \
            client-id=${RESOURCEID_MYSQL_USERASSIGNEDIDENTITY_CLIENTID} \
            subs-id=${SUBSCRIPTION_ID} \
            mysql-identity-id=${RESOURCEID_MYSQL_USERASSIGNEDIDENTITY} \
        -c visits-service
    az containerapp connection create mysql-flexible --connection mysql_vets_service \
        --source-id ${RESOURCEID_VETSSERVICE} \
        --target-id ${RESOURCEID_MYSQL_DATABASE} \
        --client-type springBoot \
        --user-identity \
            client-id=${RESOURCEID_MYSQL_USERASSIGNEDIDENTITY_CLIENTID} \
            subs-id=${SUBSCRIPTION_ID} \
            mysql-identity-id=${RESOURCEID_MYSQL_USERASSIGNEDIDENTITY} \
        -c vets-service
    ```

## Next step

:arrow_forward: [Deploy the Container Apps](./04-deploy-apps.md)
