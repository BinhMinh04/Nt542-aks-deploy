resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-${var.environment}-${var.group}-${var.short_location}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "aks-${var.environment}-${var.group}-${var.short_location}-dns"

  # CIS 5.4.2: Private Cluster
  private_cluster_enabled = false

  # CIS 5.4.1: Restrict Control Plane
  api_server_access_profile {
    authorized_ip_ranges = ["10.0.0.0/8"]
  }

  # CIS 5.5.2: Azure RBAC
  azure_active_directory_role_based_access_control {
    azure_rbac_enabled = true
  }

  # CIS 5.4.4: Network Policy
  network_profile {
    network_plugin = "azure"
    network_policy = "calico"
  }

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = var.vm_size
  }

  identity {
    type = "SystemAssigned"
  }
}