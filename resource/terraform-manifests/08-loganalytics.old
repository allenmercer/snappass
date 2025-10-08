# Log Analytics Blocks

data "azurerm_log_analytics_workspace" "internal_monitoring" {
  name                = "internal-monitoring"
  provider            = azurerm.internal_monitoring
  resource_group_name = "internal-monitoring"
}

resource "azurerm_monitor_diagnostic_setting" "amds_asp" {
  name               = "${var.rg_name}-amds-aps"
  target_resource_id = azurerm_service_plan.asp.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.internal_monitoring.id

  enabled_metric {
    category = "AllMetrics"
  }
}

resource "azurerm_monitor_diagnostic_setting" "amds_lwa" {
  name               = "${var.rg_name}-amds-lwa"
  target_resource_id = azurerm_linux_web_app.lwa.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.internal_monitoring.id

enabled_log {
    category = "AppServiceHTTPLogs"
  }

  enabled_log {
    category = "AppServiceAppLogs"
  }

  enabled_log {
    category = "AppServiceAuditLogs"
  }

  enabled_log {
    category = "AppServicePlatformLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

# Diagnostic setting for the Redis Cache
resource "azurerm_monitor_diagnostic_setting" "amds_redis" {
  name                       = "${var.rg_name}-amds-redis"
  target_resource_id         = azurerm_redis_cache.redis.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.internal_monitoring.id
  enabled_log {
    category = "ConnectedClientList"
  }
  enabled_metric {
    category = "AllMetrics"
  }
}