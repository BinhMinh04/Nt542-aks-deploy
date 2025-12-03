# # CIS 4.2.1: Disallow privileged containers
# resource "kubernetes_manifest" "disallow_privileged" {
#   manifest = yamldecode(file("${path.module}/../polices/disallow-privileged.yaml"))
  
#   depends_on = [
#     helm_release.kyverno,
#     azurerm_kubernetes_cluster.aks
#   ]
# }

# # CIS 4.2.2: Disallow host PID
# resource "kubernetes_manifest" "disallow_host_pid" {
#   manifest = yamldecode(file("${path.module}/../polices/disallow-host-pid.yaml"))
  
#   depends_on = [
#     helm_release.kyverno,
#     azurerm_kubernetes_cluster.aks
#   ]
# }

# # CIS 4.6.3: Disallow default namespace
# resource "kubernetes_manifest" "disallow_default_ns" {
#   manifest = yamldecode(file("${path.module}/../polices/disallow-default-namespace.yaml"))
  
#   depends_on = [
#     helm_release.kyverno,
#     azurerm_kubernetes_cluster.aks
#   ]
# }

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
    kubernetes_manifest.disallow_privileged,
    kubernetes_manifest.disallow_host_pid,
    kubernetes_manifest.disallow_default_ns
  ]
}