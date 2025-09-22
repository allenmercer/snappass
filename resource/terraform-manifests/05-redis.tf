# Azure Cache for Redis Block
resource "azurerm_redis_cache" "redis" {
  name                          = "${var.project_name}-redis"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  capacity                      = 1 # C1 Standard
  family                        = "C"
  sku_name                      = "Standard"
  non_ssl_port_enabled          = false
  minimum_tls_version           = "1.2"
  public_network_access_enabled = false
  tags                          = local.tags
}

# Private DNS Zone for Redis
resource "azurerm_private_dns_zone" "redis_pdz" {
  name                = "privatelink.redis.cache.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.tags
}

# VNet link for the Private DNS Zone
resource "azurerm_private_dns_zone_virtual_network_link" "redis_pdz_vnet_link" {
  name                  = "${var.project_name}-redis-pdz-vnet-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.redis_pdz.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

# Private Endpoint for Redis Cache
resource "azurerm_private_endpoint" "redis_pe" {
  name                = "${var.project_name}-redis-pe"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.pe_snet.id
  tags                = local.tags
  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.redis_pdz.id]
  }
  private_service_connection {
    name                           = "${var.project_name}-redis-psc"
    private_connection_resource_id = azurerm_redis_cache.redis.id
    is_manual_connection           = false
    subresource_names              = ["redisCache"]
  }
}