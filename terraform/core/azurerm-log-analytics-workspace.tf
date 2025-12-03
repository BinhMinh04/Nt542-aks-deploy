resource "azurerm_log_analytics_workspace" "law" {
  name                = "$law-${azurerm_kubernetes_cluster.aks.name}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}
