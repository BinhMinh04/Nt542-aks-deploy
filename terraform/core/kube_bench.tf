# Create security namespace
resource "null_resource" "security_namespace" {
  provisioner "local-exec" {
    command = <<-EOT
      az aks get-credentials --resource-group ${azurerm_resource_group.main.name} --name ${azurerm_kubernetes_cluster.aks.name} --overwrite-existing
      kubectl create namespace security --dry-run=client -o yaml | kubectl apply -f -
      kubectl label namespace security pod-security.kubernetes.io/enforce=restricted --overwrite
      kubectl label namespace security pod-security.kubernetes.io/audit=restricted --overwrite
      kubectl label namespace security pod-security.kubernetes.io/warn=restricted --overwrite
    EOT
  }

  depends_on = [azurerm_kubernetes_cluster.aks]
}

# SecretProviderClass to mount Key Vault secrets
resource "null_resource" "slack_secret_provider" {
  provisioner "local-exec" {
    command = <<-EOT
      az aks get-credentials --resource-group ${azurerm_resource_group.main.name} --name ${azurerm_kubernetes_cluster.aks.name} --overwrite-existing
      kubectl apply -f - <<EOF
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: slack-webhook-secret
  namespace: security
spec:
  provider: azure
  parameters:
    usePodIdentity: "false"
    keyvaultName: ${azurerm_key_vault.aks.name}
    tenantId: ${var.tenant_id}
    objects: |
      array:
        - |
          objectName: slack-webhook-url
          objectType: secret
EOF
    EOT
  }

  depends_on = [
    null_resource.security_namespace,
    azurerm_key_vault_secret.slack_webhook,
    azurerm_kubernetes_cluster.aks
  ]
}

# Apply kube-bench cronjob
resource "null_resource" "kube_bench_cronjob" {
  provisioner "local-exec" {
    command = <<-EOT
      az aks get-credentials --resource-group ${azurerm_resource_group.main.name} --name ${azurerm_kubernetes_cluster.aks.name} --overwrite-existing
      
      # Replace cluster name in YAML
      sed "s/CLUSTER_NAME_PLACEHOLDER/${azurerm_kubernetes_cluster.aks.name}/g" ${path.module}/kube-bench-cronjob.yaml > /tmp/kube-bench-cronjob-${azurerm_kubernetes_cluster.aks.name}.yaml
      
      # Apply the cronjob
      kubectl apply -f /tmp/kube-bench-cronjob-${azurerm_kubernetes_cluster.aks.name}.yaml
      
      # Clean up temp file
      rm /tmp/kube-bench-cronjob-${azurerm_kubernetes_cluster.aks.name}.yaml
    EOT
  }

  depends_on = [
    null_resource.security_namespace,
    null_resource.slack_secret_provider,
    azurerm_kubernetes_cluster.aks
  ]
}

# Variables
