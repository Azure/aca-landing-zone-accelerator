targetScope = 'resourceGroup'

// ------------------
//    Deploys jobs into the azure container apps environment
// ------------------

// ------------------
//   Input parameters
// ------------------
@description('The location where the resources will be created.')
param location string = resourceGroup().location

@description('Optional. The tags to be assigned to the created resources.')
param tags object = {}

@description('The name of the container apps environment.')
param containerAppsEnvironmentName string

@description('The name of the azure container registry.')
param acrName string

@description('The name of the managed identity.')
param managedIdentityName string

@description('The log analytics workspace id.')
param workspaceId string

@description('Specifies the name of the parameters Azure Service Bus queue.')
param parametersServiceBusQueueName string = 'parameters'

@description('Specifies the name of the results Azure Service Bus queue.')
param resultsServiceBusQueueName string = 'results'

@description('The name of the workload that is being deployed. Up to 10 characters long.')
@minLength(2)
@maxLength(10)
param workloadName string

@description('Specifies the name of the sender job.')
param senderJobName string = '${toLower(workloadName)}-sender'

@description('Specifies the name of the processor job.')
param processorJobName string = '${toLower(workloadName)}-processor'

@description('Specifies the name of the receiver job.')
param receiverJobName string = '${toLower(workloadName)}-receiver'

@description('Specifies the name (e.g., sbsender) of the container image of the sender job.')
param senderImageName string = 'sbsender'

@description('Specifies the name (e.g., sbprocessor) of the container image of the processor job.')
param processorImageName string = 'sbprocessor'

@description('Specifies the name (e.g., sbreceiver) of the container image of the receiver job.')
param receiverImageName string = 'sbreceiver'

@description('Specifies the tag (e.g., v1) of the container image of the sender job.')
param senderImageTag string = 'v1'

@description('Specifies the tag (e.g., v1) of the container image of the processor job.')
param processorImageTag string = 'v1'

@description('Specifies the tag (e.g., v1) of the container image of the receiver job.')
param receiverImageTag string = 'v1'

@description('Maximum number of replicas of the sender job to run per execution.')
param senderParallelism int = 1

@description('Maximum number of replicas of the sender job to run per execution.')
param processorParallelism int = 5

@description('Maximum number of replicas of the sender job to run per execution.')
param receiverParallelism int = 5

@description('Specifies the minimum number of job executions to run per polling interval.')
param minExecutions int = 1

@description('Specifies the maximum number of job executions to run per polling interval.')
param maxExecutions int = 10

@description('Specifies the polling interval in seconds.')
param pollingInterval int = 30

@description('Specifies the maximum number of retries before the replica fails..')
param replicaRetryLimit int = 1

@description('Specifies the maximum number of seconds a replica can execute.')
param replicaTimeout int = 300

@description('Enable sending usage and telemetry feedback to Microsoft.')
param enableTelemetry bool = true

@description('The name of the spoke VNET.')
param spokeVNetName string

@description('The name of the subnet in the VNet to which the private endpoint will be connected.')
param spokePrivateEndpointsSubnetName string

@description('The resource ID of the Hub Virtual Network.')
param hubVNetId string

@description('The name of service bus\' private endpoint.')
param serviceBusPrivateEndpointName string

// Existing Resources
resource environment 'Microsoft.App/managedEnvironments@2023-05-01' existing = {
  name: containerAppsEnvironmentName
}

resource acr 'Microsoft.ContainerRegistry/registries@2023-06-01-preview' existing = {
  name: acrName
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: managedIdentityName
}

// Variables

var telemetryId = '9b4433d6-924a-4c07-b47c-7478619759c7-${location}-acajobs'

// Resources

// The service bus namespace used to pass messages between the jobs
module namespace 'modules/service-bus.bicep' = {
  name: 'sb-nsp-deployment'
  params: {
    location: location
    tags: tags
    serviceBusName: ''
    workspaceId: workspaceId
    spokePrivateEndpointsSubnetName: spokePrivateEndpointsSubnetName
    spokeVNetName: spokeVNetName
    hubVNetId: hubVNetId
    serviceBusPrivateEndpointName: serviceBusPrivateEndpointName
  }
}

module senderJob 'modules/container-apps-job.bicep' = {
  name: 'senderJob'
  params: {
    name: toLower(senderJobName)
    location: location
    managedIdentityId: managedIdentity.id
    containerImage: '${acr.properties.loginServer}/${senderImageName}:${senderImageTag}'
    triggerType: 'Manual'
    parallelism: senderParallelism
    replicaCompletionCount: senderParallelism
    replicaRetryLimit: replicaRetryLimit
    replicaTimeout: replicaTimeout
    environmentId: environment.id
    tags: tags
    registries: [
      {
        server: acr.properties.loginServer
        identity: managedIdentity.id
      }
    ]
    env: [
      {
        name: 'AZURE_CLIENT_ID'
        value: managedIdentity.properties.clientId
      }
      {
        name: 'FULLY_QUALIFIED_NAMESPACE'
        value: toLower('${namespace.outputs.serviceBusName}.servicebus.windows.net')
      }
      {
        name: 'INPUT_QUEUE_NAME'
        value: parametersServiceBusQueueName
      }
      {
        name: 'MIN_NUMBER'
        value: '1'
      }
      {
        name: 'MAX_NUMBER'
        value: '10'
      }
      {
        name: 'MESSAGE_COUNT'
        value: '100'
      }
      {
        name: 'SEND_TYPE'
        value: 'list'
      }
    ]
  }
}

module processorJob 'modules/container-apps-job.bicep' = {
  name: 'processorJob'
  params: {
    name: processorJobName
    location: location
    managedIdentityId: managedIdentity.id
    containerImage: '${acr.properties.loginServer}/${processorImageName}:${processorImageTag}'
    triggerType: 'Schedule'
    cronExpression: '*/5 * * * *'
    parallelism: processorParallelism
    replicaCompletionCount: processorParallelism
    replicaRetryLimit: replicaRetryLimit
    replicaTimeout: replicaTimeout
    environmentId: environment.id
    tags: tags
    registries: [
      {
        server: acr.properties.loginServer
        identity: managedIdentity.id
      }
    ]
    env: [
      {
        name: 'AZURE_CLIENT_ID'
        value: managedIdentity.properties.clientId
      }
      {
        name: 'FULLY_QUALIFIED_NAMESPACE'
        value: toLower('${namespace.outputs.serviceBusName}.servicebus.windows.net')
      }
      {
        name: 'INPUT_QUEUE_NAME'
        value: parametersServiceBusQueueName
      }
      {
        name: 'OUTPUT_QUEUE_NAME'
        value: resultsServiceBusQueueName
      }
      {
        name: 'MAX_MESSAGE_COUNT'
        value: '20'
      }
      {
        name: 'MAX_WAIT_TIME'
        value: '5'
      }
    ]
  }
}

module receiverJob 'modules/container-apps-job.bicep' = {
  name: 'receiverJob'
  params: {
    name: receiverJobName
    location: location
    managedIdentityId: managedIdentity.id
    containerImage: '${acr.properties.loginServer}/${receiverImageName}:${receiverImageTag}'
    triggerType: 'Event'
    maxExecutions: maxExecutions
    minExecutions: minExecutions
    pollingInterval: pollingInterval
    parallelism: receiverParallelism
    replicaCompletionCount: receiverParallelism
    replicaRetryLimit: replicaRetryLimit
    replicaTimeout: replicaTimeout
    environmentId: environment.id
    tags: tags
    registries: [
      {
        server: acr.properties.loginServer
        identity: managedIdentity.id
      }
    ]
    env: [
      {
        name: 'AZURE_CLIENT_ID'
        value: managedIdentity.properties.clientId
      }
      {
        name: 'FULLY_QUALIFIED_NAMESPACE'
        value: toLower('${namespace.outputs.serviceBusName}.servicebus.windows.net')
      }
      {
        name: 'OUTPUT_QUEUE_NAME'
        value: resultsServiceBusQueueName
      }
      {
        name: 'MAX_MESSAGE_COUNT'
        value: '20'
      }
      {
        name: 'MAX_WAIT_TIME'
        value: '5'
      }
    ]
    secrets: [
      {
        name: 'service-bus-connection-string'
        value: namespace.outputs.connectionString
      }
    ]
    rules: [
      {
        name: 'azure-servicebus-queue-rule'
        type: 'azure-servicebus'
        metadata: {
          messageCount: '5'
          namespace: namespace.outputs.serviceBusName
          queueName: resultsServiceBusQueueName
        }
        auth: [
          {
            secretRef: 'service-bus-connection-string'
            triggerParameter: 'connection'
          }
        ]
      }
    ]
  }
}

@description('Microsoft telemetry deployment.')
resource telemetrydeployment 'Microsoft.Resources/deployments@2021-04-01' = if (enableTelemetry) {
  name: telemetryId
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#'
      contentVersion: '1.0.0.0'
      resources: {}
    }
  }
}
