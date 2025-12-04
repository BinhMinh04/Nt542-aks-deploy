resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-${var.environment}-${var.group}-${var.short_location}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "aks-${var.environment}-${var.group}-${var.short_location}-dns"

  # CIS 5.4.2: Private Cluster - Enable Private Endpoint and Disable Public Access
  private_cluster_enabled             = true
  private_cluster_public_fqdn_enabled = false

  # CIS 5.4.1: Restrict Access to the Control Plane Endpoint
  api_server_access_profile {
    authorized_ip_ranges = var.authorized_ip_ranges
  }

  # CIS 5.5.2: Use Azure RBAC for Kubernetes Authorization
  azure_active_directory_role_based_access_control {
    azure_rbac_enabled     = true
    tenant_id              = var.tenant_id
    admin_group_object_ids = var.admin_group_object_ids
  }

  # CIS 5.4.4: Network Policy is Enabled
  # CIS 5.4.3: Private Nodes
  network_profile {
    network_plugin    = "azure"
    network_policy    = "calico"
    load_balancer_sku = "standard"
    outbound_type     = "loadBalancer"
  }

  # CIS 2.1.1: Enable Audit Logs via Azure Monitor
  oms_agent {
    log_analytics_workspace_id      = azurerm_log_analytics_workspace.law.id
    msi_auth_for_monitoring_enabled = true
  }

  # Microsoft Defender for Containers
  microsoft_defender {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  }

  default_node_pool {
    name                 = "default"
    node_count           = var.node_count
    vm_size              = var.vm_size
    vnet_subnet_id       = azurerm_subnet.aks.id
    
    # CIS 5.4.3: Ensure clusters are created with Private Nodes
    node_public_ip_enabled = false
    
    os_disk_type    = "Managed"
    os_disk_size_gb = 128

    upgrade_settings {
      max_surge = "10%"
    }
  }

  # CIS 5.2.1: Prefer using dedicated AKS Service Accounts
  identity {
    type = "SystemAssigned"
  }

  # Enable Key Vault Secrets Provider
  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

  # Enable Azure Policy for Kubernetes
  azure_policy_enabled = true

  # Enable workload identity
  workload_identity_enabled = true
  oidc_issuer_enabled       = true

  # Image cleaner
  image_cleaner_enabled        = true
  image_cleaner_interval_hours = 48

  # Automatic upgrade
  automatic_upgrade_channel = "patch"

  # Local account disabled - forces AAD authentication
  local_account_disabled = true

  # SKU tier
  sku_tier = "Standard"

  tags = {
    Environment      = var.environment
    Group            = var.group
    ManagedBy        = "terraform"
    CIS_Compliant    = "true"
  }
}

# CIS 2.1.1: Enable Diagnostic Settings for audit logging
resource "azurerm_monitor_diagnostic_setting" "aks" {
  name                       = "diag-${azurerm_kubernetes_cluster.aks.name}"
  target_resource_id         = azurerm_kubernetes_cluster.aks.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  enabled_log {
    category = "kube-apiserver"
  }

  enabled_log {
    category = "kube-audit"
  }

  enabled_log {
    category = "kube-audit-admin"
  }

  enabled_log {
    category = "kube-controller-manager"
  }

  enabled_log {
    category = "kube-scheduler"
  }

  enabled_log {
    category = "cluster-autoscaler"
  }

  enabled_log {
    category = "guard"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
