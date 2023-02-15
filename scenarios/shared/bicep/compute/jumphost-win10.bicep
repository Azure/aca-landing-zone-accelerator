//TODO: needs some expansion to have less hardcoded things tt20230214

@description('Name of the resource Virtual Network (The name must begin with a letter or number, end with a letter, number or underscore, and may contain only letters, numbers, underscores, periods, or hyphens)')
@minLength(2)
@maxLength(64)
param name string

@description('Name of the windows PC. Optional, by default gets automatically constructed by the resource name. Use it to give more meaningful names, or avoid conflicts')
@minLength(2)
@maxLength(15)
param computerWindowsName string = ''

@description('Azure Region where the resource will be deployed in')
param location string

@description('key-value pairs as tags, to identify the resource')
param tags object

@description('The subnet where the VM will be attached to')
param subnetId string

@description('optional, default value is azureuser')
param adminUsername string = 'azureuser'

@description('mandatory, the password of the admin user')
@secure()
param adminPassword string

var vmNameMaxLength = 64
var vmName = length(name) > vmNameMaxLength ? substring(name, 0, vmNameMaxLength) : name

var computerNameLength = 15
var computerNameValid = replace( replace(name, '-', ''), '_', '')
var computerName = length(computerNameValid) > computerNameLength ? substring(computerNameValid, 0, computerNameLength) : computerNameValid

module jumphostNic '../network/nic.private.dynamic.bicep' = {
  name: 'jumphostNicDeployment'
  params: {
    name: 'nic-${vmName}'
    subnetId: subnetId
    location: location
    tags: tags
  }
}

resource jumphost 'Microsoft.Compute/virtualMachines@2022-08-01' = {
  name: vmName
  location: location
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v3'
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsDesktop'
        offer: 'Windows-10'
        sku: 'win10-21h2-pro'
        version: 'latest'
      }
      osDisk: {
        osType: 'Windows'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    osProfile: {
      computerName: empty(computerWindowsName) ? computerName : computerWindowsName
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
        patchSettings: {
          patchMode: 'AutomaticByOS'
          assessmentMode: 'ImageDefault'
          enableHotpatching: false
        }
        enableVMAgentPlatformUpdates: true
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: jumphostNic.outputs.nicId
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}
