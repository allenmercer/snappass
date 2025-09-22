# Azure Cache for Redis Block
resource "azurerm_redis_cache" "redis" {
  name                          = "${var.project_name}-redis"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  capacity                      = 1 # C1 Standard
  family                        = "C"
  sku_name                      = "Standard"
  enable_non_ssl_port           = false
  minimum_tls_version           = "1.2"
  public_network_access_enabled = false
  tags                          = local.tags
}
