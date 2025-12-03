resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-${var.environment}-${var.group}-${var.short_location}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "aks-${var.environment}-${var.group}-${var.short_location}-dns"

  # CIS 5.2.1: Enable private cluster (disabled for lab access)
  private_cluster_enabled = false

  # Restrict API server access to specific IPs
  api_server_access_profile {
    authorized_ip_ranges = var.authorized_ip_ranges
  }

  default_node_pool {
    name           = "nodepool"
    node_count     = var.node_count
    vm_size        = var.vm_size
    vnet_subnet_id = azurerm_subnet.aks.id
  }

  identity {
    type = "SystemAssigned"
  }

  # CIS 5.2.2: Enable RBAC with Azure AD
  role_based_access_control_enabled = true

  azure_active_directory_role_based_access_control {
    azure_rbac_enabled = true
  }

  # CIS 5.2.3: Enable Azure Policy
  azure_policy_enabled = true

  # CIS 5.2.4: Enable Defender for Containers
  microsoft_defender {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "standard"
  }

  # CIS 5.2.7: Enable monitoring
  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  }

  # CIS 5.2.8: Enable Key Vault Secrets Provider
  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

  tags = {
    Environment = var.environment
    Group       = var.group
    Location    = var.location
  }
}
