data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "aks" {
  name                       = "kv-${var.environment}-${var.group}-${var.short_location}"
  location                   = var.location
  resource_group_name        = azurerm_resource_group.main.name
  tenant_id                  = var.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  # CIS: Enable RBAC for Key Vault
  enable_rbac_authorization = true

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }
}

# Grant AKS managed identity access to Key Vault secrets
resource "azurerm_role_assignment" "aks_kv_secrets_user" {
  scope                = azurerm_key_vault.aks.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_kubernetes_cluster.aks.key_vault_secrets_provider[0].secret_identity[0].object_id
}

# Store Slack Webhook in Key Vault
resource "azurerm_key_vault_secret" "slack_webhook" {
  name         = "slack-webhook-url"
  value        = var.slack_webhook_url
  key_vault_id = azurerm_key_vault.aks.id

  depends_on = [azurerm_role_assignment.aks_kv_secrets_user]
}
