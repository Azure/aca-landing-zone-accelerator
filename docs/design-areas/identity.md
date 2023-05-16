# Azure Container Apps Landing Zone Accelerator - Identity & Access Management

---
## Design Area Considerations

- Depending on your needs, the application running on Azure Container Apps may have public access (anyone can use it), private access (a user needs to login), or a mix of these (some parts are public). 

- Authentication and authorization may be provided by an identity provider such as Azure AD or Azure AD B2C.

- When connecting to other resources from your Azure Container Apps application, consider using a [managed identity](https://learn.microsoft.com/azure/container-apps/managed-identity) instead of a service principal. This negates the need for managing credentials. [Azure offers](https://learn.microsoft.com/azure/active-directory/managed-identities-azure-resources/overview) _System-assigned Managed Identities_, which share a lifecycle with an Azure resource such as a Container App, or a _User-assigned managed identity_, which is a standalone Azure resource and can be used by multiple applications.

---
## Design Area Recommendations

- If authentication is required, use Azure AD or Azure AD B2C as an identity provider

- Use separate app registrations for the application environments (dev, test, production, etc)

- Use system-assigned managed identities unless there is a strong requirement for using user-managed identities

- Use Azure [built-in roles](https://learn.microsoft.com/azure/role-based-access-control/built-in-roles#web-plan-contributor) to assign least privilege permissions to resources and users.

- Ensure that access to production environments is limited. Ideally, no one has standing access to production environment, instead relying on automation to handle deployments and [Privileged Identity Management](https://learn.microsoft.com/azure/active-directory/privileged-identity-management/pim-configure) for emergency access.