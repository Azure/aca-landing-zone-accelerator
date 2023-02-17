# Create a self signed pfx certificate 


- First, we'll create a password protected private key. 
  ```
    openssl genrsa -des3 -out appgwcert.key 2048
  ```

- If we want our certificate signed, we need a certificate signing request (CSR). The CSR includes the public key and some additional information (such as organization and country). Pay attention to the **Common Name (e.g. server FQDN or YOUR name)**, this must much your domain name, i.e. www.microsoft.com
```
    openssl req -key appgwcert.key -new -out appgwcert.csr
    # FQDN: acahello.demoapp.com
```

- Creating a Self-Signed Certificate. A self-signed certificate is a certificate that's signed with its own private key. It can be used to encrypt data just as well as CA-signed certificates, but our users will be shown a warning that says the certificate isn't trusted. Let's create a self-signed certificate (domain.crt) with our existing private key and CSR
```
    openssl x509 -signkey appgwcert.key -in appgwcert.csr -req -days 365 -out appgwcert.crt
```

- Convert PEM to PKCS12. PKCS12 files, also known as PFX files, are usually used for importing and exporting certificate chains in Microsoft IIS. We'll use the following command to take our private key and certificate, and then combine them into a PKCS12 file
```
    openssl pkcs12 -inkey appgwcert.key -in appgwcert.crt -export -out appgwcert.pfx
```

## Create a keyvault

```shell

# Set your Azure Subscription
SUBSCRIPTION=0a52391c-0d81-434e-90b4-d04f5c670e8a

az account set --subscription "$SUBSCRIPTION"

az keyvault create --name "kv-apimpoc-NE-dev" --resource-group "rg-apimPoc-NE-dev-002" --location "northeurope"

```