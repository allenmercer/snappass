# App Service Plan Block
resource "azurerm_service_plan" "asp" {
  name                = "${var.rg_name}-asp"
  resource_group_name = var.rg_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "P1v3"
  tags                = local.tags
}

# Linux Web App Block
resource "azurerm_linux_web_app" "lwa" {
  name                = "${var.rg_name}-ailwa"
  resource_group_name = var.rg_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.asp.id
  https_only          = true
  #key_vault_reference_identity_id = azurerm_user_assigned_identity.app_identity.id
  tags                = local.tags
  identity {
    type = "SystemAssigned"
  }
  virtual_network_subnet_id = azurerm_subnet.app_snet.id
  site_config {
    always_on  = true
    ftps_state = "Disabled"
    health_check_path   = "/"
    health_check_eviction_time_in_min = 10
    container_registry_use_managed_identity = true
    application_stack {
      # This points to the image built and pushed by the pipeline
      docker_image_name   = "${var.image_name}:latest"
      docker_registry_url = "https://${data.azurerm_container_registry.acr.login_server}"
    }
  }
  app_settings = {
    "REDIS_URL"     = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.redis_url.id})"
    "SECRET_KEY"    = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.app_key.id})"
    "WEBSITES_PORT" = "5000"
    "REDIS_PREFIX"  = "ailevate"
    "DEBUG"         = "false"
    "NO_SSL"        = "false"
    "SNAPPASS_PORT" = "5000"
  }
}

data "azurerm_container_registry" "acr" {
  name                = "ailevate"
  resource_group_name = "sre-store"
}

# This resource creates a 30-second delay after the App Service is created.
resource "time_sleep" "wait_for_iam_propagation" {
  depends_on = [azurerm_linux_web_app.lwa]

  create_duration = "30s"
}

resource "azurerm_role_assignment" "app_to_acr" {
  depends_on = [time_sleep.wait_for_iam_propagation]

  scope                = data.azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_linux_web_app.lwa.identity[0].principal_id # or object id
}