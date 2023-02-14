// Parameters
param keyVaultName            string
param managedIdentity         object
param location                string
param appGatewayFQDN          string
@secure()
param certPassword            string
param appGatewayCertType      string

// Variables
var secretName = replace(appGatewayFQDN,'.', '-')
var subjectName='CN=${appGatewayFQDN}'

var certData = appGatewayCertType == 'selfsigned' ? 'null' : loadFileAsBase64('../app-gw/appgw.pfx')
var certPwd = appGatewayCertType == 'selfsigned' ? 'null' : certPassword == '' ? 'nullnopass' : certPassword

// Giving Access to Key Vault (Using AppGW Identity)
resource accessPolicyGrant 'Microsoft.KeyVault/vaults/accessPolicies@2019-09-01' = {
  name: '${keyVaultName}/add'
  properties: {
    accessPolicies: [
      {
        objectId: managedIdentity.properties.principalId
        tenantId: managedIdentity.properties.tenantId
        permissions: {
          secrets: [
            'get'
            'list'
          ]
          certificates: [
            'import'
            'get'
            'list'
            'update'
            'create'
          ]
        }
      }
    ]
  }
}

// Generating/Loading Certificate for Application Gateway using deployment Scripts (It will temporaly give access to the Deployment Script ACI at the Key Vault Firewall so it can push the certificate to Key Vault)
resource appGatewayCertificate 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: '${secretName}-certificate'
  dependsOn: [
    accessPolicyGrant
  ]
  location: location
  kind: 'AzurePowerShell'
  properties: {
    azPowerShellVersion: '6.6'
    arguments: ' -vaultName ${keyVaultName} -certificateName ${secretName} -subjectName ${subjectName} -certPwd ${certPwd} -certDataString ${certData} -certType ${appGatewayCertType} -subscriptionId ${subscription().subscriptionId}'
    scriptContent: '''
      param(
      [string] [Parameter(Mandatory=$true)] $vaultName,
      [string] [Parameter(Mandatory=$true)] $certificateName,
      [string] [Parameter(Mandatory=$true)] $subjectName,
      [string] [Parameter(Mandatory=$true)] $certPwd,
      [string] [Parameter(Mandatory=$true)] $certDataString,
      [string] [Parameter(Mandatory=$true)] $certType,
      [string] [Parameter(Mandatory=$true)] $subscriptionId
      )

      $ErrorActionPreference = 'Stop'
      $DeploymentScriptOutputs = @{}
      Login-AzAccount -Identity -SubscriptionId $subscriptionId

      Write-Host "Adding the current public ip to the key vault allow list"
      $arrDomains = @(
          "http://ifconfig.me",
          "http://checkip.amazonaws.com/",
          "http://ipecho.net/plain",
          "http://icanhazip.com",
          "http://ipinfo.io/ip",
          "http://ipinfo.io/ip",
          "http://wtfismyip.com/text",
          "http://ipv4.icanhazip.com/",
          "http://ifconfig.co",
          "http://api.ipify.org"
      )

      foreach ($domain in $arrDomains) {
          try {
              $publicIp = "$((Invoke-RestMethod $domain -UserAgent "curl/7.83.1").trim())"
              if ($publicIp.Contains(".")) {
                  $publicIp = $publicIp + "/32"
              }
              else {
                  $publicIp = $publicIp + "/128"
              }
              Add-AzKeyVaultNetworkRule -VaultName $vaultName -IpAddressRange $publicIp -SubscriptionId $subscriptionId
              break
          }
          catch {
              continue
          }
      }

      if ($certType -eq 'selfsigned') {
        $policy = New-AzKeyVaultCertificatePolicy -SubjectName $subjectName -IssuerName Self -ValidityInMonths 12 -Verbose

        # private key is added as a secret that can be retrieved in the ARM template
        Add-AzKeyVaultCertificate -VaultName $vaultName -Name $certificateName -CertificatePolicy $policy -Verbose

        $newCert = Get-AzKeyVaultCertificate -VaultName $vaultName -Name $certificateName

        # it takes a few seconds for KeyVault to finish
        $tries = 0
        do {
          Write-Host 'Waiting for certificate creation completion...'
          Start-Sleep -Seconds 10
          $operation = Get-AzKeyVaultCertificateOperation -VaultName $vaultName -Name $certificateName
          $tries++

          if ($operation.Status -eq 'failed')
          {
          throw 'Creating certificate $certificateName in vault $vaultName failed with error $($operation.ErrorMessage)'
          }

          if ($tries -gt 120)
          {
          throw 'Timed out waiting for creation of certificate $certificateName in vault $vaultName'
          }
        } while ($operation.Status -ne 'completed')
      }
      else {

        $bytesFromFileBase64 = [System.Convert]::FromBase64String($certDataString)
        $filePath = Join-Path -Path (Get-Location).Path -ChildPath cert.pfx
        [IO.File]::WriteAllBytes($filePath, $bytesFromFileBase64)

        #Import-AzKeyVaultCertificate -Name $certificateName -VaultName $vaultName -CertificateString $certDataString -Password $ss

        if($certPwd -eq 'nullnopass'){
          Import-AzKeyVaultCertificate -Name $certificateName -VaultName $vaultName -FilePath $filePath
        }
        else{
          $ss = Convertto-SecureString -String $certPwd -AsPlainText -Force;
          Import-AzKeyVaultCertificate -Name $certificateName -VaultName $vaultName -FilePath $filePath -Password $ss
        }
      }

      Write-Host "Removing current public ip address from allow list"
      Remove-AzKeyVaultNetworkRule -VaultName $vaultName -IpAddressRange $publicIp -SubscriptionId $subscriptionId
      '''
    retentionInterval: 'P1D'
    cleanupPreference: 'OnSuccess'
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '/subscriptions/${managedIdentity.subscriptionId}/resourceGroups/${managedIdentity.resourceGroupName}/providers/${managedIdentity.resourceId}': {}
    }
  }
}

// Generate Secret URI URL
module appGatewaySecretsUri 'certificate-secret.bicep' = {
  name: '${secretName}-certificate'
  dependsOn: [
    appGatewayCertificate
  ]
  params: {
    keyVaultName: keyVaultName
    secretName: secretName
  }
}

// Outputs
output secretUri string = appGatewaySecretsUri.outputs.secretUri
