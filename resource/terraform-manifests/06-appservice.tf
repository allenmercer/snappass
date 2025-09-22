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
    application_stack {
      # This points to the image built and pushed by the pipeline
      docker_image_name = "ailevate.azurecr.io/echo:$(Build.BuildId)"
    }
  }
}