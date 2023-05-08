<!-- markdownlint-disable -->
## Contents
<!-- markdownlint-restore -->

- [Contents](#contents)
- [Contributing](#contributing)
- [GitHub Operations, Conventions and other Standards](#github-operations-conventions-and-other-standards)
  - [GitHub Basics](#github-basics)
  - [Folder Structure and Naming Conventions](#folder-structure-and-naming-conventions)
  - [Forking the Repository](#forking-the-repository)
  - [Branch Naming Standards](#branch-naming-standards)
  - [Commit Standards (optional)](#commit-standards-optional)
- [Style Guide and coding conventions](#style-guide-and-coding-conventions)
  - [Bicep Best Practices and Conventions](#bicep-best-practices-and-conventions)
  - [Terraform Best Practices and Conventions](#terraform-best-practices-and-conventions)
- [Issue Tracker](#issue-tracker)
- [Pull Request Process](#pull-request-process)

---

## Contributing

This project welcomes contributions and suggestions. Most contributions require you to agree to a Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us the rights to use your contribution. For details, visit <https://cla.opensource.microsoft.com>.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the Microsoft Open Source Code of Conduct. For more information see the Code of Conduct FAQ or contact <opencode@microsoft.com> with any additional questions or comments.

The rest of this document outlines a few important notes/guidelines to help us to start contributing to this *Landing Zone Accelerator* project effectively.

## GitHub Operations, Conventions and other Standards

### GitHub Basics

The following guides provide basic knowledge for understanding Git command usage and the workflow of GitHub.

- [Introduction to version control with Git](https://learn.microsoft.com/learn/paths/intro-to-vc-git/)
- [Git Cheat Sheet](https://education.github.com/git-cheat-sheet-education.pdf)
- [GitHub Flow](https://guides.github.com/introduction/flow/)

### Folder Structure and Naming Conventions

- Github uses ASCII for ordering files and folders. For consistent ordering create all files and folders in **lowercase**. The only exception to this guideline is the *common supporting files* such as README.md, CONTRIBUTING.md etc files, that should be in the format **UPPERCASE.lowercase**. Remember that there are operating systems that handle files with different casing as distinct files, so we need to avoid these kind of conflicts.
- Avoid **camelCase** for files and folders consisting of two or more words. Use only lowercase and append words with dashes, i.e. **`folder-name-one`** and **not** `folderNameOne`

> NOTE: the aforementioned rules can be overridden, if any Language Coding Styles or Guidelines instruct the usage of different conventions

Below you can see the selected folder structure for the project. The main folders and a brief description of their purpose is as follows:
- **docs**
  The *docs* folder contains two subfolders; **design-areas** and **media**.
  - The **design-areas** subfolder contains the relevant documentation.
  - The **media** subfolder  will contain images or other media file types used in the README.md files. Folder structure inside that subfolder is optional and free to the grouping desires of every author. For instance if you create the README.md file describing the architecture of the *scenario1* scenario, and *scenario1* sub-folder may be created to group all supporting media files together. In the same context, if the *Design Area* documents (as described above) need some supporting media material, we can add them in this subfolder or create a new subfolder, named *design-areas* and add them all there, for grouping purposes
  
- **scenarios**
  This folder can contain one or more scenarios. Each scenario has the following (minimum) folder structure
  - (scenario1)\bicep
    Stores Azure Bicep related deployment scripts and artifacts for the given scenario. Contains also a README.md file that gives detailed instructions on how to use the specific IaC artifacts and scripts, to help end users parameterize and deploy successfully the LZA scenario
  - (scenario1)\terraform
    Stores terraform related deployment scripts and artifacts (if any) for the given scenario. Contains also a README.md file that gives detailed instructions on how to use the specific IaC artifacts and scripts, to help end users parameterize and deploy successfully the LZA scenario
  - (scenario1)\README.md
    Outlines the details of the specific scenario (architecture, resources to be deployed, business case scenarios etc) for the given scenario
  - (scenario1)\sample-apps
    This folder may contain one or more subfolders, depending on the selected sample applications that will be created to serve as smoke tests or best-practices examples using the specific Landing Zone Accelerator artifacts. Folder structure inside each sample application sub-folder is free.
  - *shared*
    To avoid duplication of code modules/artifacts, we store all scripts, modules or coding artifacts in general, in this subfolder. This folder can have more depth, i.e. one folder for every deployment method (i.e. bicep, terraform etc) as shown below in the sample folder structure. Contains also a README.md file that gives details of the shared modules/scripts to help end-users understand their functionality.

``` bash
docs
├── design-areas
│   ├── **/*.md
├── media
|   ├── scenario1
│   |   ├── **/*.png
│   |   ├── **/*.vsdx
scenarios
├── scenario1
│   ├── bicep
│   │   ├── modules
│   |   ├── **/*.azcli
│   |   ├── **/*.bicep
│   |   ├── **/*.json
│   |   ├── README.md
│   │   ├── sample-apps
│   │   |   ├── sample-app1
│   |   │   |   ├── **/*.azcli
│   |   │   |   ├── **/*.bicep
│   |   │   |   ├── **/*.json
│   │   |   ├── sample-app2 
│   ├── terraform
│   ├── README.md
├── scenario2
│   ├── bicep
│   │   ├── modules
│   |   ├── **/*.azcli
│   |   ├── **/*.bicep
│   |   ├── **/*.json
│   |   ├── README.md
│   │   ├── sample-apps
│   │   |   ├── sample-app1
│   │   |   ├── sample-app2 
│   ├── terraform
│   ├── README.md
├── shared
│   ├── bicep
│   │   ├── modules
│   ├── terraform
│   │   ├── modules
│   ├── vm-script.ps1
README.md
CONTIBUTING.md
.gitignore
```

### Forking the Repository

Unless you are working with multiple contributors on the same file, we ask that you fork the repository and submit your pull request from there. The following guide explains how to fork a GitHub repo.

- [Contributing to GitHub projects](https://guides.github.com/activities/forking/).

### Branch Naming Standards

For branches, use the following prefixes depending on which is most applicable to the work being done:
| Prefix    | Purpose |
|-------------|-----------|
|fix/|Any task related to a bug or minor fix|
|feat/|Any task related to a new feature of the codebase|
|chore/|Any basic task that involves minor updates that are not bugs|
|docs/|Any task pertaining to documentation|
|ci/|Any task pertaining to workflow changes |
|test/|Any task pertaining to testing updates |

### Commit Standards (optional)

Prefixing the commits as described below, is **optional**, however is **highly encouraged**.  
For commits, use the following prefixes depending on which is most applicable to the changes:
| Prefix    | Purpose |
|-------------|-----------|
|fix:|Update to code base or bug|
|feat:|New feature added to code base|
|chore:|Basic task to update formatting or versions, etc.|
|docs:|New documentations or updates to documentation in Markdown file(s) |
|ci:|New workflow or updates to workflow(s) |
|test:|New tests or updates to testing framework(s) |

## Style Guide and coding conventions

A guide outlining the coding conventions and style guidelines that should be followed when contributing code to the repository is outlined below:

### Bicep Best Practices and Conventions

- The starting point for any deployment should be named **main.bicep**. This (usually) should be the main deployment file, scoped at *subscription* level, and it would call several sub-deployments, usually at the resource group scope.
  - The **main.bicep** file should be accompanied with a parameter file named **main.parameters.jsonc**. The benefit of the `*.jsonc` file extension is that you can use  inline comments (either `//` or `/* ... */`) in Visual Studio Code (otherwise you will get an error message saying "*Comments not permitted in JSON*"). [Bicep Parameter Files](https://learn.microsoft.com/azure/azure-resource-manager/bicep/parameter-files)
  - Details of using the deployment should be given in the README.md file. However if we need extra scripts to either deploy the bicep files or other functionality use a naming convention as the following
    - deploy.main.sh: for bash-based script deploying the main.bicep
    - deploy.main.ps1: for PowerShell-based script deploying the main.bicep

- Do not include compiled versions of the bicep files (i.e. no `main.json` files)

- Follow the best practices as defined in [Best practices for Bicep](https://learn.microsoft.com/azure/azure-resource-manager/bicep/best-practices).

- Use strictly `camelCasing` for all elements like parameters, variables, resources, modules and outputs, and avoid prepending those elements in a [Hungarian Notation](https://en.wikipedia.org/wiki/Hungarian_notation) style.
  - Put always the resource type identifier in front accompanied, where applicable, from some context, like hub or spoke. For example, `vnetHubName` is better than `vnetName` or `hubVNetName`.
  - Use only well known abbreviations like *Url, Fqdn, Vnet*, adhering to the CamelCasing rule.
  - Each parameter, variable or resource identifier should be descriptive and pronounceable. For example, `vmName` is better than `vmnm`.
  - Outputs should also be descriptive. Do not output just `name` or `id` but prefer to output as `<resourceType>Name` and `<resourceType>Id` to avoid confusion, especially in the case where a module outputs many different resources. For example, use `storageAccountName`  and `storageAccountId`, which is better than just `name` and `id`.
  - All parameters and outputs should be documented using the `@description` decorator.
  - Use id instead of resourceId in the name of the parameter or variable. For example, `subnetId` is better than `subnetResourceId`.
  - If you split a resource id into tokens, use explicit names for the tokens. For example:
  
    ```bicep
    var virtualNetworkHubResourceIdsSplitTokens = !empty(virtualNetworkHubRessourceId) ? split(virtualNetworkHubRessourceId, '/') : array('')
    var hubSubscriptionId = virtualNetworkHubResourceIdsSplitTokens[2]
    var hubResourceGroupName = virtualNetworkHubResourceIdsSplitTokens[4]
    var hubVnetName = virtualNetworkHubResourceIdsSplitTokens[8]
    ```

- If naming of Azure resources is chosen to be done manually, follow some best practices as defined in:
  - [Define your naming convention](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
  - Use abbreviations of resource type as proposed in [Abbreviation examples for Azure resources](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations) document
  - Always take into consideration [naming rules and restrictions for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
  
  **Bad practice examples that should be avoided:**

  ```bicep
  \\ BAD PRACTICE param EXAMPLES
  param parVmSubnetAddressPrefix string
  param strVmSubnetAddressPrefix string
  param appGwName string
  param fineColServFQDN string

  \\ GOOD PRACTICE param EXAMPLES
  param applicationGatewayName string
  param fineCollectionServiceFqdn string

  \\ BAD PRACTICE variable EXAMPLES
  var varAppGwDeploymentName = 'xyz'

  \\ GOOD PRACTICE variable EXAMPLES
  var applicationGatewayDeploymentName = 'xyz'  

  \\ BAD PRACTICE output EXAMPLES
  output name string = containerRegistry.name
  output id string = containerRegistry.id
  output outAcrId string = containerRegistry.id
  output strAcrId string = containerRegistry.id
  output outStrAcrId string = containerRegistry.id

  \\ GOOD PRACTICE output EXAMPLES
  output containerRegistryName string = containerRegistry.name
  output containerRegistryId string = containerRegistry.id
  ```

- Bicep is a declarative language, which means the elements can appear in any order. In reality you can put parameter declarations anywhere in the template file, and the same you can do for resources, variables and outputs. However it is highly recommended that any bicep template file to adhere to the following order `Parameters > Variables > Resources/Modules > Outputs` as shown in the code snippet.

  ```bicep
  targetScope = 'subscription'

  // ------------------
  //    PARAMETERS
  // ------------------

  @description('suffix that will be used to name the resources in a pattern similar to <resourceAbbreviation>-<applicationName>.')
  param applicationName string

  @description('Required. The environment for which the deployment is being executed.')
  @allowed([
    'dev'
    'uat'
    'prod'
    'dr'
  ])
  param environment string

  @description('Optional. The tags to be assigned to the created resources.')
  param tags object = {}

  // ------------------
  // VARIABLES
  // ------------------

  var tags = union({
    applicationName: applicationName
    environment: environment
  }, tags)

  // ------------------
  // RESOURCES
  // ------------------

  resource resourceGroupSpoke 'Microsoft.Resources/resourceGroups@2022-09-01' = {
    name: resourceGroupSpokeName
    location: location
    tags: tags
  }

  // ------------------
  // OUTPUTS
  // ------------------

  @description('The name of the spoke resource group.')
  output spokeResourceGroupName string = resourceGroupSpoke.name

  ```

- Use [parameter decorators](https://learn.microsoft.com/azure/azure-resource-manager/bicep/parameters#decorators) to ensure integrity of user inputs are complete and therefore enable successful deployment
  - Use the [`@secure()` parameter decorator](https://learn.microsoft.com/azure/azure-resource-manager/bicep/parameters#secure-parameters) **ONLY** for inputs. Never for outputs as this is not stored securely and will be stored/shown as plain-text!
  - All parameters should have a meaningful `@description` decorator
  - Use constraints where possible, allowed values, min/max, but Use the `@allowed` decorator sparingly, as it can mistakenly result in blocking valid deployments
  - If more than one parameter decorators are present, the `@description` decorator should always come first.
  - Avoid prompting for parameter value at runtime. Parameters should either be initialized in the bicep template file and/or in the accompanying parameter file.

- `targetScope` should always be indicated at the beginning of the bicep template file

- Use variables for values that are used multiple times throughout a template or for creating complex expressions
- Remove all unused variables from all templates

- Parameters and variables should be named according to their use on specific properties where applicable.  For example a parameter used for the name property on a Storage Account would be named `storageAccountName` rather than simple `name` or `storageAccount`. A parameter used for the size of a VM should be `vmSize` rather than `size`.  As well, parameters, variables and outputs that related to a specific resource should use the resource's symbolic name as a prefix.
  
- Consider sanitizing names of resources to avoid deployment errors. For example consider the name limitations for a storage account (all lowercase, less than 24 characters long, no dashes etc).

  ```bicep
  var maxStorageNameLength = 24
  var storageName = take( toLower(substring(replace(name, '-', ''), 0, maxStorageNameLength)), maxStorageNameLength)
  ```

- Use bicep **parameter** files for giving the end user the ability to parametrize the deployed resources. (i.e. to select CIDR network spaces, to select SKUs for given resources etc). As a rule of thumb, avoid using the parameter file for *naming resources*, unless there is a really good reason for that. Naming resources should be handled centrally (preferably with variables), following specific rules (as already described). Try not to overuse parameters in the template, because this creates a burden on your template users, since they need to understand the values to use for each resource, and the impact of setting each parameter. Consider using the [t-shirt sizing pattern](https://learn.microsoft.com/azure/azure-resource-manager/bicep/patterns-configuration-set#solution)

- Avoid using `dependsOn` in the bicep template files. Bicep is building [implicit dependencies](https://learn.microsoft.com/azure/azure-resource-manager/bicep/resource-dependencies#implicit-dependency) for us, as long as we follow some good practices rules. For instance a resource A depends on a Resource B (i.e. a storage Account) chances are that in resource A you need somehow to pass data of the Resource B(i.e. name, ID etc.). In that case, avoid passing the resource name as string, but pass the property Name of the resource instead (i.e. `myStorage.Name`)

``` bicep
var storageName='ttst20230301'

resource resourceModuleA 'module/someResource' = {
  name: 'myResource'

  //This is wrong, does NOT build implicit dependency
  //storageAccountName: storageName

   //This is OK, does build implicit dependency
  storageAccountName: storage.name
}

resource storage 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: storageName
  location: location
  kind: kind
  sku: {
    name: skuName
  }
  tags: union(tags, {
    displayName: storageName
  })
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
  }
}
```
 

**More details for the aforementioned guidelines you may find at:**

- [Bicep Best Practices](https://learn.microsoft.com/azure/azure-resource-manager/bicep/best-practices)
- [Deployment Scripts in Bicep](https://learn.microsoft.com/azure/azure-resource-manager/bicep/deployment-script-bicep)
- [Configuration Map Pattern and t-shirt sizing](https://learn.microsoft.com/azure/azure-resource-manager/bicep/patterns-configuration-set): Can be used to provide a smaller set of parameters
- [Logical Parameters](https://learn.microsoft.com/azure/azure-resource-manager/bicep/patterns-logical-parameter)
- [Azure Resource Naming Convention](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- [Azure Resource Abbreviations](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)

### Terraform Best Practices and Conventions

- Use modules: Terraform modules allow you to reuse and share code across different projects and teams. This helps to reduce duplication of effort and increases consistency
- Use Terraform variables: Use Terraform variables to provide input values and make your code more flexible and easier to maintain.
- Use Terraform outputs: Use Terraform outputs to extract information about your infrastructure for later use.
- Use comments to explain the purpose and context of your code. This helps other people who are reviewing your code and makes it easier to maintain in the future.
- Use Terraform format: Format your Terraform code using the `terraform fmt` command to ensure consistency and readability.
- Use separate Terraform files for each resource: Terraform can manage multiple resources in a single Terraform file. However, it's better to split the resources into multiple Terraform files for better organization and maintainability.
- Check the Hashicorp [Terraform Style Convention](https://developer.hashicorp.com/terraform/language/syntax/style)
- Use [snake_case](https://en.wikipedia.org/wiki/Snake_case) (lowercase with underscore character) for all Terraform resource or object names.
- Declare all variable blocks for a module in **variables.tf**, including a description and type
- Provide no defaults defined in **variables.tf** with all variable arguments being provided in **terraform.tfvars**
- Declare all outputs in **outputs.tf**, including a description
- Modules must always include the following files, even if empty: **main.tf**, **variables.tf**, and **outputs.tf**









## Issue Tracker
> TODO: Instructions on how to use the issue tracker, including how to submit bugs and feature requests.

## Pull Request Process
> TODO: A description of the pull request process, including the criteria that pull requests will be reviewed against and the steps that will be taken to merge a pull request.
