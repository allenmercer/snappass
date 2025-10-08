# DNS Blocks
# An "asuid" TXT record is used in Azure App Service to verify custom domain ownership.
resource "azurerm_dns_txt_record" "domain_verification" {
  name                = "asuid.${var.custom_subdomain}"
  provider            = azurerm.sre_dns
  zone_name           = "ailevate.com"
  resource_group_name = "sre-dns"
  ttl                 = 300
  tags = local.tags

  record {
    value = azurerm_linux_web_app.lwa.custom_domain_verification_id
  }
}

resource "azurerm_dns_cname_record" "cname_record" {
  name                = var.custom_subdomain
  provider            = azurerm.sre_dns
  zone_name           = "ailevate.com"
  resource_group_name = "sre-dns"
  ttl                 = 300
  record              = azurerm_linux_web_app.lwa.default_hostname
  tags = local.tags

  depends_on = [azurerm_dns_txt_record.domain_verification]
}

# Certificate and Binding Blocks
resource "azurerm_app_service_custom_hostname_binding" "hostname_binding" {
  hostname            = "${var.custom_subdomain}.ailevate.com"
  app_service_name    = azurerm_linux_web_app.lwa.name
  resource_group_name = var.rg_name

  depends_on = [azurerm_dns_cname_record.cname_record, azurerm_dns_txt_record.domain_verification]
}

resource "azurerm_app_service_managed_certificate" "managed_cert" {
  custom_hostname_binding_id = azurerm_app_service_custom_hostname_binding.hostname_binding.id
}

resource "azurerm_app_service_certificate_binding" "cert_binding" {
  hostname_binding_id = azurerm_app_service_custom_hostname_binding.hostname_binding.id
  certificate_id      = azurerm_app_service_managed_certificate.managed_cert.id
  ssl_state           = "SniEnabled"
}