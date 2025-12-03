data "azurerm_policy_set_definition" "cis_kubernetes" {
  display_name = "[Preview]: Kubernetes cluster should follow the security control recommendations of Center for Internet Security (CIS) Kubernetes benchmark"
}

resource "azurerm_resource_policy_assignment" "cis_assign" {
  name                     = "assign-cis-aks"
  resource_id              = azurerm_kubernetes_cluster.aks.id
  policy_definition_id     = data.azurerm_policy_set_definition.cis_kubernetes.id

  identity {
    type = "SystemAssigned"
  }
}
