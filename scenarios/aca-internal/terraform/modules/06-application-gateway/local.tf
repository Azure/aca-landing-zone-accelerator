locals {
  appGatewayCertificate = var.enableAppGatewayCertificate ? filebase64("${path.module}/${var.appGatewayCertificatePath}") : null
}
