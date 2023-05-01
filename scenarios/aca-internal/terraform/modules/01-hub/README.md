# Hub

If you haven't yet, clone the repo and cd to the appropriate folder
``` bash
git clone https://github.com/Azure/ACA-Landing-Zone-Accelerator
```

The following will be created:

* Resource Group for Hub Networking
* Hub VNET
* Azure Bastion Host (Optional)
* Windows or Linux Virtual Machine (Optional)

![Hub](./media/hub.png)

Review the `terraform.tfvars` file and update the parameter values if required according to your needs. Pay attention to VNET address prefixes and subnets so it doesn't overlap with the Spoke VNET in further steps. Also, please pay attention to update Subnet prefix for ACA environment in Spoke VNET in the further steps to be planned and update in this file.

> TODO: Add VM AAD joined (needs bastion Standard)

Note: `terraform.tfvars` file contains the username and password for the virtual machine. These can be changed in the parameters file for the VM, however these are the default values:

```
Username: azureuser
Password: Password123
```

Once the files are updated, deploy using the Terraform CLI.

```PowerShell
terraform init
terraform plan -out tfplan
terraform apply tfplan 
```



:arrow_forward: [Spoke](../02-spoke)
