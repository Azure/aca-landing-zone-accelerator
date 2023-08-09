output "vmId" {
  value = var.osType == "Linux" ? azurerm_linux_virtual_machine.linuxVm[0].id: azurerm_windows_virtual_machine.windowsVm[0].id
}