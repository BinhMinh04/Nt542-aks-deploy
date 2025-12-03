# Apply Kyverno policies using kubectl
resource "null_resource" "apply_policies" {
  provisioner "local-exec" {
    command = <<-EOT
      az aks get-credentials --resource-group ${azurerm_resource_group.main.name} --name ${azurerm_kubernetes_cluster.aks.name} --overwrite-existing
      kubectl apply -f ${path.module}/../polices/disallow-privileged.yaml
      kubectl apply -f ${path.module}/../polices/disallow-host-pid.yaml
      kubectl apply -f ${path.module}/../polices/disallow-default-namespace.yaml
    EOT
  }
  
  depends_on = [
    helm_release.kyverno,
    azurerm_kubernetes_cluster.aks
  ]
}