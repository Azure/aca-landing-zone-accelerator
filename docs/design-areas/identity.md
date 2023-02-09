# Identity and access management considerations for ACA landing zone accelerator

This article provides design considerations and recommendations for identity and access management that you can apply when you use the Azure Container Apps (ACA) landing zone accelerator. Authentication and app configuration are some of the considerations that this article discusses.

## Design considerations

When you use the landing zone accelerator to deploy an Azure Container Apps solution, there are some key considerations for key identity and access management:

- Determine the level of security and isolation required for the app and its data. Public access allows anyone with the app URL to access the app, while private access restricts access to only authorized users and networks.

- Determine the type of authentication and authorization needed for your Azure Container App solution: anonymous, internal corporate users, social accounts, or a combination of these types.

- Determine whether to use system-assigned or user-assigned [managed identity](https://learn.microsoft.com/en-us/azure/container-apps/managed-identity) when your Azure Container App solution connects to back-end resources that are protected by Azure Active Directory (Azure AD).

- Consider creating [custom roles](https://learn.microsoft.com/en-us/azure/active-directory/roles/custom-create), following the principle of least privilege when out-of-box roles require modifications to existing permissions.

- Avoid using priviledge containers, if your program attempts to run a process that requires root access, the application inside the container experiences a runtime error.

- Choose enhanced-security storage for keys, secrets, certificates, and application configuration.
    - Use [app configuration](https://learn.microsoft.com/en-us/azure/architecture/solution-ideas/articles/appconfig-key-vault) to share common configuration values that aren't passwords, secrets, or keys between applications, microservices, and serverless applications. 
    - Use [Azure Key Vault](https://learn.microsoft.com/en-us/azure/key-vault/general/overview). It provides enhanced-security storage of passwords, connection strings, keys, secrets, and certificates. You can use Key Vault to store your secrets and then access them from your Container App via the associated managed identity or using [Dapr secret store reference components](https://learn.microsoft.com/en-us/azure/container-apps/dapr-overview?tabs=bicep1%2Cyaml#using-a-dapr-secret-store-component-reference). By doing so, you can help keep your secrets secure while still providing access to them from your application as needed.
    
## Design recommendations

You should incorporate the following best practices into your Container Apps deployments:

- A Container Apps environment provides a security boundary around a group of container apps. A single container app typically represents a microservice, which is composed of container apps made up of one or more containers.

- If the Container Apps solution requires authentication, Container Apps can save you time and effort by providing out-of-the-box authentication with federated identity providers, allowing you to focus on the rest of your application.
  - If access to the entire Container App needs to be restricted to authenticated users, register your identity provider and set the "Restrict access" to "Require authentication".
  - Use the [built-in authentication and authorization](https://learn.microsoft.com/en-us/azure/container-apps/authentication) capabilities of Container Apps instead of writing your own authentication and authorization code.
  - Use separate [application registrations](https://learn.microsoft.com/en-us/azure/active-directory/develop/quickstart-register-app) for separate environments.
  - If the Container App solution is intended for internal users only, use client certificate authentication for increased security.
  - If the Container App solution is intended for external users, use [Azure AD B2C](https://learn.microsoft.com/en-us/azure/active-directory-b2c/overview) to authenticate to social accounts and Azure AD accounts.

- Use [Azure built-in roles](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#all) whenever possible. These roles are designed to provide a set of permissions that are commonly needed for specific scenarios, like the Reader role for users who need read-only access and the Contributor role for users who need to be able to create and manage resources.
    - If built-in roles don't meet your needs, you can create custom roles by combining the permissions from one or more built-in roles. By doing so, you can grant the exact set of permissions that your users need while still following the principle of least privilege.
    - Monitor your Container App resources regularly to ensure that they're being used in accordance with your security policies. Doing so can help you identify any unauthorized access or changes and take appropriate actions.

- Use the principle of least privilege when you assign permissions to users, groups, and services. This principle states that you should grant only the minimum permissions that are required to perform the specific task, and no more. Following this guidance can help you reduce the risk of accidental or malicious changes to your resources.

- Use system-assigned [managed identities](https://learn.microsoft.com/en-us/azure/container-apps/managed-identity) to access, with enhanced security, back-end resources that are protected by Azure AD. Doing so allows you to control which resources the Container App solution has access to and what permissions it has for those resources.
    - Using managed identities in scale rules isn't supported. You'll still need to include the connection string or key in the secretRef of the scaling rule.

- For automated deployment, set up a [service principal](https://learn.microsoft.com/en-us/azure/active-directory/develop/app-objects-and-service-principals) that has the minimum required permissions to deploy from the CI/CD pipeline.

- Enable diagnostic logging ContainerAppConsoleLogs and ContainerAppSystemLogs access logs for Container App. You can use these detailed logs to diagnose problems with your app and monitor access requests. Enabling these logs also provides an Azure Monitor activity log that gives you insight into subscription-level events.

- Follow the recommendations outlined in the [Identity management](TBD) and [Privileged access](TBD) sections of the Azure security baseline for Container App.

The goal of identity and access management for the landing zone accelerator is to help ensure that the deployed app and its associated resources are secure and can be accessed only by authorized users. Doing so can help you protect sensitive data and prevent misuse of the app and its resources.