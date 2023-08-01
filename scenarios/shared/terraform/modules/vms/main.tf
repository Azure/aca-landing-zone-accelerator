resource "azurerm_network_interface" "vmNic" {
  name                = var.nicName
  resource_group_name = var.vnetResourceGroupName
  location            = var.location

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnetId
    private_ip_address_allocation = "Dynamic"
  }
}

resource "random_password" "password" {
  count            = var.adminPassword == null ? 2 : 0
  length           = 16
  special          = true
  override_special = "!#$%&*?"
}

resource "azurerm_linux_virtual_machine" "linuxVm" {
  count = var.osType == "Linux" ? 1 : 0

  name                = var.vmName
  resource_group_name = var.resourceGroupName
  location            = var.location

  admin_username                  = var.adminUsername
  admin_password                  = var.adminPassword == null ? random_password.password.0.result : var.adminPassword
  disable_password_authentication = false
  size                            = var.size

  network_interface_ids = [
    azurerm_network_interface.vmNic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_windows_virtual_machine" "windowsVm" {
  count = var.osType == "Windows" ? 1 : 0

  name                = var.vmName
  resource_group_name = var.resourceGroupName
  location            = var.location

  admin_username = var.adminUsername
  admin_password = var.adminPassword
  size           = var.size

  network_interface_ids = [
    azurerm_network_interface.vmNic
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_virtual_machine_extension" "vm_extension_linux" {
  count                = var.osType == "Linux" ? 1 : 0
  name                 = "vm-extension-linux"
  virtual_machine_id   = azurerm_linux_virtual_machine.linuxVm.0.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"
  settings             = <<SETTINGS
    {
      "script": "${filebase64("${path.module}/scripts/jumpbox-setup-cli-tools.sh")}"
    }
SETTINGS
}

resource "azurerm_virtual_machine_extension" "vm_extension_windows" {
  count                = var.osType == "Windows" ? 1 : 0
  name                 = "vm-extension-windows"
  virtual_machine_id   = azurerm_windows_virtual_machine.windowsVm.0.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"
  settings              = <<SETTINGS
    {
      "script": "${filebase64("${path.module}/scripts/jumpbox-setup-cli-tools.ps1")}"
    }
SETTINGS
}
