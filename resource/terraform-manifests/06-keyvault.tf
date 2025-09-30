# Key Vault Block
#resource "azurerm_key_vault" "kv" {
#  name                        = "${var.project_name}-kv"
#  location                    = var.location
#  resource_group_name         = var.rg_name
#  tenant_id                   = data.azurerm_client_config.current.tenant_id
#  sku_name                    = "standard"
#  soft_delete_retention_days  = 7
#  purge_protection_enabled    = false
#  enable_rbac_authorization   = false
#  tags                        = local.tags
#}
data "azurerm_key_vault" "kv" {
  name                = "${var.project_name}-kv"
  resource_group_name = var.rg_name
}

# Key Blocks
# Use the 'random' provider to generate a strong secret key for the app
resource "random_string" "secret_key" {
  length  = 64
  special = true
}

# Terraform now creates the application secret key with the random value
resource "azurerm_key_vault_secret" "app_key" {
  name         = "ECHO-SECRET-KEY"
  value        = random_string.secret_key.result
  key_vault_id = data.azurerm_key_vault.kv.id
}

# Terraform now constructs the FULL Redis connection string and stores it
resource "azurerm_key_vault_secret" "redis_url" {
  name         = "REDIS-URL"
  key_vault_id = data.azurerm_key_vault.kv.id
  
  # This value is constructed dynamically after the Redis cache is created
  value        = "rediss://default:${azurerm_redis_cache.redis.primary_access_key}@${azurerm_redis_cache.redis.hostname}:6380/0"
  
  # This ensures the Redis cache is created before this secret is
  depends_on = [azurerm_redis_cache.redis]
}

# Access Policy Blocks
data "azurerm_client_config" "current" {}

## Access Policy for the Pipeline Service Principal
#resource "azurerm_key_vault_access_policy" "pipeline_policy" {
#  key_vault_id = data.azurerm_key_vault.kv.id
#  tenant_id    = data.azurerm_client_config.current.tenant_id
#  object_id    = data.azurerm_client_config.current.object_id
#  secret_permissions = [
#    "Get", "List", "Set", "Delete", "Purge"
#  ]
#}

# Access Policy for the App Service's Managed Identity
resource "azurerm_key_vault_access_policy" "app_service_policy" {
  key_vault_id = data.azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_linux_web_app.lwa.identity[0].principal_id
  secret_permissions = [
    "Get", "List"
  ]
}