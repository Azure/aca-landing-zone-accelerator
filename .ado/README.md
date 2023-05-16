# Azure Pipeline Deployment

If you'd like to use an Azure Pipeline to deploy the ACA Landing Zone Accelerator, you will need:

- A fork of the ACA Landing Zone repository
- An Azure DevOps project
- A [service connection](https://learn.microsoft.com/azure/devops/pipelines/library/service-endpoints?view=azure-devops&tabs=yaml) available for your pipeline that connects to your Azure subscription
- A variable group called "ACA-LZA" that contains the following variables:
  - location: The location of where you want the Azure resources deployed
  - azureServiceConnection: the name of the service connection you created in the previous step

## Create your pipeline

After you've created the items in the previous step, follow these instructions for creating your pipeline.

1. Navigate into your Azure DevOps projects and click on Pipelines on the left sidebar.
1. Click *New Pipeline* in the upper right hand corner of the window or the *create pipeline* button in the middle if this is your first pipeline.
1. Select *GitHub* as the source for your YAML.
1. Select your repository in GitHub. If you don't already have the Azure Pipeline app installed in your GitHub repository, it will prompt you to enable that and redirect you back to this creation screen.
1. Select *Existing Azure Pipelines YAML file*, select the main branch and the file *lza-deployment-bicep.yaml*.
1. Once you select the file, hit next and then click *Run* in the upper right hand corner of the *Review* tab. If you don't want to run it immediately, you can click the dropdown on the *Run* button and choose to save it.

### Note

When you first run your pipeline, you may need to give the pipeline permission to access the service connection and the variable group. This will only occur the first time you run the pipeline.
