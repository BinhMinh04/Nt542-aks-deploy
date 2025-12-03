data "azurerm_policy_set_definition" "cis" {
  display_name = "Azure Kubernetes Service Baseline Policies"
}

resource "azurerm_policy_assignment" "cis_assign" {
  name                     = "assign-cis-aks"
  scope                    = azurerm_kubernetes_cluster.aks.id
  policy_set_definition_id = data.azurerm_policy_set_definition.cis.id
  location                 = var.location

  identity {
    type = "SystemAssigned"
  }
}
