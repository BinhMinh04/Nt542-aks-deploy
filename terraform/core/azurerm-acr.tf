resource "azurerm_container_registry" "acr" {
  name                = "acr-${var.environment}-${var.group}-${var.short_location}"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  sku                 = "Standard"

  admin_enabled = false

  tags = {
    Environment = var.environment
    Group       = var.group
    Location    = var.location
  }
}


# Role Assignment for AKS to pull images from ACR
resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.acr.id
}
