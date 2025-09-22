# App Service Plan Block
resource "azurerm_service_plan" "asp" {
  name                = "${var.project_name}-asp"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "P1v3"
  tags                = local.tags
}

# Linux Web App Block
resource "azurerm_linux_web_app" "lwa" {
  name                = "${var.project_name}-lwa"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.asp.id
  https_only          = true
  tags                = local.tags
  identity {
    type = "SystemAssigned"
  }
  virtual_network_subnet_id = azurerm_subnet.app_snet.id
  site_config {
    always_on  = true
    ftps_state = "Disabled"
    #linux_fx_version = "DOCKER|ailevate.azurecr.io/echo:${var.image_tag}"
    application_stack {
      # This points to the image built and pushed by the pipeline
      docker_image_name   = "echo:${var.image_tag}"
      docker_registry_url = "https://ailevate.azurecr.io"
    }
  }
  app_settings = {
    DOCKER_REGISTRY_SERVER_URL      = "https://${data.azurerm_container_registry.acr.login_server}"
    DOCKER_REGISTRY_SERVER_USERNAME = azurerm_container_registry.acr.admin_username
    DOCKER_REGISTRY_SERVER_PASSWORD = azurerm_container_registry.acr.admin_password
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
  principal_id         = azurerm_linux_web_app.lwa.identity[0].principal_id
}