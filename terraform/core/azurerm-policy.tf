data "azurerm_policy_set_definition" "cis" {
  display_name = "Azure Kubernetes Service Baseline Policies"
}

resource "azurerm_resource_policy_assignment" "cis_assign" {
  name                     = "assign-cis-aks"
  resource_id              = azurerm_kubernetes_cluster.aks.id
  policy_definition_id     = data.azurerm_policy_set_definition.cis.id

  identity {
    type = "SystemAssigned"
  }
}
