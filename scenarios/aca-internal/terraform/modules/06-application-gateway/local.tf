locals {
  appGatewayCertificate = filebase64("${path.module}/${var.appGatewayCertificatePath}")
}