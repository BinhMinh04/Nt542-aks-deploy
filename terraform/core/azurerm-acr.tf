resource "azurerm_container_registry" "acr" {
  name                = "acr${var.environment}${var.group}${var.short_location}"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  sku                 = "Premium"

  # CIS 5.1.2: Minimize user access to ACR - Disable admin account
  admin_enabled = false

  # Enable content trust
  trust_policy_enabled = true

  # Quarantine policy
  quarantine_policy_enabled = true

  # Network rules
  network_rule_set {
    default_action = "Deny"
  }

  public_network_access_enabled = false
  zone_redundancy_enabled       = true
  anonymous_pull_enabled        = false
  data_endpoint_enabled         = true
  export_policy_enabled         = false

  tags = {
    Environment   = var.environment
    Group         = var.group
    CIS_Compliant = "true"
  }
}

# CIS 5.1.3: Minimize cluster access to read-only for ACR (AcrPull only)
resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.acr.id
}

# Diagnostic settings for ACR
# resource "azurerm_monitor_diagnostic_setting" "acr" {
#   name                       = "diag-${azurerm_container_registry.acr.name}"
#   target_resource_id         = azurerm_container_registry.acr.id
#   log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

#   enabled_log {
#     category = "ContainerRegistryRepositoryEvents"
#   }

#   enabled_log {
#     category = "ContainerRegistryLoginEvents"
#   }

#   metric {
#     category = "AllMetrics"
#     enabled  = true
#   }
# }
