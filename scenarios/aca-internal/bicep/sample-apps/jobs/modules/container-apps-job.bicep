// Parameters
@description('Specifies the name of the Azure Container Apps Job.')
param name string

@description('Specifies the location.')
param location string = resourceGroup().location

@description('Specifies the resource tags.')
param tags object

@description('Specifies the resource id of the user-defined managed identity.')
param managedIdentityId string

@description('Specifies the resource id of the Azure Container Apps Environment.')
param environmentId string

@description('Specifies a workload profile name to pin for container app execution.')
param workloadProfileName string = ''

@description('Specifies a list of volume definitions for the Container App.')
param volumes array = []

@description('Specifies the Collection of private container registry credentials used by a Container apps job. For more information, see https://learn.microsoft.com/en-us/azure/templates/microsoft.app/jobs?pivots=deployment-language-bicep#registrycredentials')
param registries array = []

@description('Specifies the maximum number of retries before failing the job.')
param replicaRetryLimit	int = 1

@description('Specifies the maximum number of seconds a Container Apps job replica is allowed to run.')
param replicaTimeout	int = 60

@description('Specifies the Collection of secrets used by a Container Apps job. For more information, see https://learn.microsoft.com/en-us/azure/templates/microsoft.app/jobs?pivots=deployment-language-bicep#secret')
param secrets	array = []

@description('Specified the trigger type for the Azure Container Apps Job.')
@allowed([
  'Event'
  'Manual'
  'Schedule'
])
param triggerType string = 'Manual'

@description('Specifies the Cron formatted repeating schedule ("* * * * *") of a Cron Job.')
param cronExpression	string = '* * * * *'

@description('Specifies the number of parallel replicas of a Container Apps job that can run at a given time.')
param parallelism	int = 1

@description('Specifies the minimum number of successful replica completions before overall Container Apps job completion.')
param replicaCompletionCount	int = 1

@description('Specifies the minimum number of job executions to run per polling interval.')
param minExecutions int = 1

@description('Specifies the maximum number of job executions to run per polling interval.')
param maxExecutions int = 10

@description('Specifies the polling interval in seconds.')
param pollingInterval int = 60

@description('Specifies the scaling rules. In event-driven jobs, each Container Apps job typically processes a single event, and a scaling rule determines the number of job replicas to run.')
param rules array = []

@description('Specifies the container start command arguments.')
param args array = []

@description('Specifies the container start command.')
param command array = []

@description('Specifies the container environment variables.')
param env array = []

@description('Specifies the container image.')
param containerImage	string

@description('Specifies the container name.')
param containerName	string = 'main'

@description('Specifies the Required CPU in cores, e.g. 0.5 for the first Azure Container Apps Job. Specify a decimal value as a string. For example, specify 0.5 for 1/2 core.')
param cpu string = '0.25'

@description('Specifies the Required memory in gigabytes for the second Azure Container Apps Job. E.g. 1.5 Specify a decimal value as a string. For example, specify 1.5 for 1.5 GB.')
param memory string = '0.5Gi'

@description('Specifies the container volume mounts.')
param volumeMounts array = []

// Resources
resource job 'Microsoft.App/jobs@2023-04-01-preview' = {
  name: toLower(name)
  location: location
  tags: tags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentityId}': {}
    }
  }
  properties: {
    configuration: {
      manualTriggerConfig: triggerType == 'Manual' ? {
        replicaCompletionCount: replicaCompletionCount
        parallelism: parallelism
      } : null
      scheduleTriggerConfig: triggerType == 'Schedule' ? {
        cronExpression: cronExpression
        replicaCompletionCount: replicaCompletionCount
        parallelism: parallelism
      } : null
      eventTriggerConfig: triggerType == 'Event' ? {
        replicaCompletionCount: replicaCompletionCount
        parallelism: parallelism
        scale: {
          maxExecutions: maxExecutions
          minExecutions: minExecutions
          pollingInterval: pollingInterval
          rules: rules
        }
      } : null
      registries: registries
      replicaRetryLimit: replicaRetryLimit
      replicaTimeout: replicaTimeout
      secrets: secrets
      triggerType: triggerType
    }
    environmentId: environmentId
    template: {
      containers: [
        {
          args: args
          command: command
          env: env
          image: containerImage
          name: containerName
          resources: {
            cpu: json(cpu)
            memory: memory
          }
          volumeMounts: volumeMounts
        }
      ]
      volumes: volumes
    }
    workloadProfileName: workloadProfileName
  }
}

// Outputs
output id string = job.id
output name string = job.name
