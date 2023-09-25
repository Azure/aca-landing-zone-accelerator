# Azure Container Apps Jobs
Azure Container Apps Jobs jobs allow you to run containerized tasks that execute for a given duration and complete. You can use jobs to run tasks such as data processing, machine learning, or any scenario where on-demand processing is required. For more information, see the following tutorials:

- [Create a job with Azure Container Apps](https://learn.microsoft.com/en-us/azure/container-apps/jobs-get-started-cli?pivots=container-apps-job-manual): In this tutorial, you create a manual or scheduled job.
- [Deploy an event-driven job with Azure Container Apps](https://learn.microsoft.com/en-us/azure/container-apps/tutorial-event-driven-jobs): shows how to create a job whose execution is triggered by each message that is sent to an Azure Storage Queue.
- [Deploy self-hosted CI/CD runners and agents with Azure Container Apps jobs](https://learn.microsoft.com/en-us/azure/container-apps/tutorial-ci-cd-runners-jobs?tabs=bash&pivots=container-apps-jobs-self-hosted-ci-cd-github-actions) shows how to run a [GitHub Actions self-hosted runner](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/about-self-hosted-runners) as an event-driven Azure Container Apps Job.

## Job trigger types
A job's trigger type determines how the job is started. The following trigger types are available:

### Manual jobs
Manual jobs are triggered on-demand using the Azure CLI, through the Azure portal or a request to the Azure Resource Manager API.

Examples of manual jobs include:
One-time processing tasks such as migrating data from one system to another.
An e-commerce site running as a container app starts a job execution to process inventory when an order is placed.

### Scheduled Jobs
Scheduled jobs are triggered at specific times and can run repeatedly. Azure Container Apps Jobs use Cron expressions to define schedules. They support the standard cron expression format with five fields for minute, hour, day of month, month, and day of week. Cron expressions in scheduled jobs are evaluated in Universal Time Coordinated (UTC).  The following are examples of cron expressions:

| Expression | Description |
|------------|-------------|
| ```0 */2 * * *```| Runs every two hours |
| ```0 0 * * *```  | Runs every day at midnight. |
| ```0 0 * * 0```  | Runs every Sunday at midnight. |
| ```0 0 1 * *```  | Runs on the first day of every month at midnight. |

### Event driven jobs 
Event-driven jobs
Event-driven jobs are triggered by events from supported custom scalers. Examples of event-driven jobs include: 
- A job that runs when a new message is added to a queue, such as Azure Service Bus, Azure Event Hubs, Apache Kafka, or RabbitMQ.
- A self-hosted GitHub Actions runner or Azure DevOps agent that runs when a new job is queued in a workflow or pipeline.
 
Container apps and event-driven jobs use KEDA scalers. They both evaluate scaling rules on a polling interval to measure the volume of events for an event source, but the way they use the results is different.

In an app, each replica continuously processes events and a scaling rule determines the number of replicas to run to meet demand. In event-driven jobs, each job typically processes a single event, and a scaling rule determines the number of jobs to run.

## Jobs Sample Container App
The purpose of this sample app is to demonstrate the usage of the [Jobs feature](https://learn.microsoft.com/en-us/azure/container-apps/jobs?tabs=azure-cli) within the context of the Azure Container Apps Landing Zone accelerator. The solution deploys all 3 different [types](https://learn.microsoft.com/en-us/azure/container-apps/jobs?tabs=azure-cli#job-trigger-types) of Jobs, a manual triggered, a schedule triggered and an event trigered one with basic functionality of calculating the Fibonacci number for a given range of numbers.

## Architecture
![a](../../../../../docs/media/acaInternal/aca-jobs.png)

### Prerequisites
 - An active Azure Container Apps Landing Zone deployment
 - [Visual Studio Code](https://code.visualstudio.com/) installed on one of the supported platforms along with the [Bicep extension](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-bicep).
 - Azure CLI version 2.49.0 or later installed. To install or upgrade, see [Install Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli).

### Jobs source code implementation
The Jobs used are implemented as a single dotnet console application which can be found under the src directory of the sample application. 
The behavior of the dotnet console application is controlled at runtime through the ```WORKEROLE``` application setting. So you can run a:

- Sender job: 
  
  by setting the ```WORKEROLE``` to the value ```sender``` this implementation sends a configurable amount of messages to the input queue in the Azure Service Bus namespace. The payload of each message contains a random positive integer number comprised in a configurable range.
- Processor job: 
  
  by setting the ```WORKEROLE``` to the value ```processor``` this implementation reads the messages from the input queue in the Azure Service Bus namespace, calculates the [Fibonacci number](https://en.wikipedia.org/wiki/Fibonacci_sequence) for the actual parameter, and writes the result in the output queue in the same namespace.
- Receiver job: 
  
  by setting the ```WORKEROLE``` to the value ```receiver``` this implementation reads the result messages from the output queue and logs it at the console.

Bellow you can find all the available configuration options for the jobs implementation:

**Environment variables**

| Name | Description | Sample value |
|------|-------------|--------------|
|```SETTINGS__SERVICEBUSNAMESPACE```|The service bus namespace fully qualified url| jobstest.servicebus.windows.net,
|```SETTINGS__INPUTQUEUENAME```|The name of the queue the sender job is going to be pushing messages to and the processing job is going to be reading from.| inputqueue,
|```SETTINGS__OUTPUTQUEUENAME```|The name of the queue the proccessing job is going to be pushing messages to| outputqueue,
|```SETTINGS__MINNUMBER```|The minimum number from which to pick from for the Fibonacci calcluation| 1,
|```SETTINGS__MAXNUMBER```|The maximum number from which to pick from for the Fibonacci calculation| 10,
|```SETTINGS__MESSAGECOUNT```|The number of selections, calculations, messages the sender is going to be sending fot the processor job to calculate| 20,
|```SETTINGS__FETCHCOUNT```|The number of messages to be fetched in one go| 10,
|```SETTINGS__MAXWAITTIME```|The allowed maximum wait time for messages to be delivered by the queues| 1,
|```SETTINGS__SENDTYPE```|The way messages are being posted to service bus queues| list/batch,
|```SETTINGS__WORKERROLE```|Defines the role of the job| sender/precessor/receiver

### Jobs bicep implementation
The sample is deployed to Azure using a bicep template found at the root directory and named ```main.bicep```. This, besides deploying the Service Bus namespace, it deploys:

- The Manual Container Apps Job
  
  To deploy a manual triggered job in bicep you need to define a [manualTriggerConfig](https://learn.microsoft.com/en-us/azure/templates/microsoft.app/jobs?pivots=deployment-language-bicep#jobconfiguration) at the configuration section of the container app and set the ```triggerType``` to 'Manual'.
  ```bicep
  resource job 'Microsoft.App/jobs@2023-04-01-preview' = {
    name: toLower(name)
    location: location
    tags: tags
    properties: {
        configuration: {
            manualTriggerConfig: {
                replicaCompletionCount: replicaCompletionCount
                parallelism: parallelism
            }
            triggerType: 'Manual'
    ...
  ```

- The Scheduled Container Apps Job

  Similarly to the manual triggered job to deploy a scheduled one you need to define a [scheduleTriggerConfig](https://learn.microsoft.com/en-us/azure/templates/microsoft.app/jobs?pivots=deployment-language-bicep#jobconfiguration) at the configuration section of the container app and set the ```triggerType``` to 'Schedule'
    ```bicep
  resource job 'Microsoft.App/jobs@2023-04-01-preview' = {
    name: toLower(name)
    location: location
    tags: tags
    properties: {
        configuration: {
            scheduleTriggerConfig: {
                cronExpression: cronExpression
                replicaCompletionCount: replicaCompletionCount
                parallelism: parallelism
            }
            triggerType: 'Schedule'
    ...
  ```

- The Event triggered Container Apps Job
  
  To deploy an event triggered job in bicep you need to define a [eventTriggerCongig](https://learn.microsoft.com/en-us/azure/templates/microsoft.app/jobs?pivots=deployment-language-bicep#jobconfiguration) at the configuration section of the container app and set the ```triggerType``` to 'Event'.
  ```bicep
  resource job 'Microsoft.App/jobs@2023-04-01-preview' = {
    name: toLower(name)
    location: location
    tags: tags
    properties: {
        configuration: {
            eventTriggerConfig: {
            replicaCompletionCount: replicaCompletionCount
            parallelism: parallelism
            scale: {
                maxExecutions: maxExecutions
                minExecutions: minExecutions
                pollingInterval: pollingInterval
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
            triggerType: 'Event'
    ...
  ```
## Deployment

1. Login to the VM using Bastion
  
    Since the Container Apps Environment is completely internal and the Container registry is not available through the internet, you will need to perform the deployment steps for the container image steps through the VM jumphost at the Spoke virtual network for which the ACR is available.

    ![bastion](../../../../../docs/media/acaInternal/bastion-login.png)

2. Install pre-reqs azure CLI, Docker client
    Unfortunatelly the jump host doesn't have the required tools installed. So, you would have to install them.

    - [az cli](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt)
        ```bash
        curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
        ```
    - [docker client](https://docs.docker.com/engine/install/ubuntu/)
        ```bash
        # Add Docker's official GPG key:
        sudo apt-get update
        sudo apt-get install ca-certificates curl gnupg
        sudo install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        sudo chmod a+r /etc/apt/keyrings/docker.gpg

        # Add the repository to Apt sources:
        echo \
        "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update
        ```
3. git clone repository
4. git checkout feature/jobs
4. docker build to acr
5. Deploy jobs to container apps environment

az deployment group create --resource-group rg-lzaaca-udr-spoke-dev-neu --name jobs-deployment --template-file main.bicep --parameters workloadName=lzaacajobs containerAppsEnvironmentName='cae-lzaaca-udr-dev-neu' acrName=crlzaacaudr6dnqbdevneu managedIdentityName='id-crlzaacaudr6dnqbdevneu-AcrPull' workspaceId='/subscriptions/c3caea05-d40f-4cd5-a694-68a5bef3904d/resourcegroups/rg-lzaaca-udr-spoke-dev-neu/providers/microsoft.operationalinsights/workspaces/log-lzaaca-udr-dev-neu' spokeVNetName='vnet-lzaaca-udr-dev-neu-spoke' spokePrivateEndpointsSubnetName='snet-pep' hubVNetId='/subscriptions/c3caea05-d40f-4cd5-a694-68a5bef3904d/resourceGroups/rg-lzaaca-udr-hub-dev-neu/providers/Microsoft.Network/virtualNetworks/vnet-dev-neu-hub'