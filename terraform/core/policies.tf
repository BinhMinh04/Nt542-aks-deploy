# Apply all Kyverno policies
resource "null_resource" "apply_policies" {
  provisioner "local-exec" {
    command = <<-EOT
      az aks get-credentials --resource-group ${azurerm_resource_group.main.name} --name ${azurerm_kubernetes_cluster.aks.name} --overwrite-existing
      
      # Wait for Kyverno
      kubectl wait --for=condition=ready pod -l app.kubernetes.io/instance=kyverno -n kyverno --timeout=300s || true
      sleep 30
      
      # CIS 4.2.1: Disallow Privileged Containers
      kubectl apply -f ${path.module}/../policies/disallow-privileged.yaml
      
      # CIS 4.2.2: Disallow Host PID
      kubectl apply -f ${path.module}/../policies/disallow-host-pid.yaml
      
      # CIS 4.2.3: Disallow Host IPC
      kubectl apply -f ${path.module}/../policies/disallow-host-ipc.yaml
      
      # CIS 4.2.4: Disallow Host Network
      kubectl apply -f ${path.module}/../policies/disallow-host-network.yaml
      
      # CIS 4.2.5: Disallow Privilege Escalation
      kubectl apply -f ${path.module}/../policies/disallow-privilege-escalation.yaml
      
      # CIS 4.6.3: Disallow Default Namespace
      kubectl apply -f ${path.module}/../policies/disallow-default-namespace.yaml
      
      # CIS 4.1.5: Disallow Default Service Account
      kubectl apply -f ${path.module}/../policies/disallow-default-serviceaccount.yaml
      
      # CIS 4.1.6: Restrict Automount SA Token
      kubectl apply -f ${path.module}/../policies/restrict-automount-sa-token.yaml
      
      # CIS 4.6.2: Require Security Context
      kubectl apply -f ${path.module}/../policies/require-security-context.yaml
      
      # CIS 4.1.1: Restrict Cluster Admin
      kubectl apply -f ${path.module}/../policies/restrict-cluster-admin.yaml
      
      # CIS 4.1.2: Restrict Secret Access
      kubectl apply -f ${path.module}/../policies/restrict-secret-access.yaml
      
      # CIS 4.1.3: Restrict Wildcard RBAC
      kubectl apply -f ${path.module}/../policies/restrict-wildcard-rbac.yaml
      
      # CIS 4.1.4: Restrict Pod Create Access
      kubectl apply -f ${path.module}/../policies/restrict-pod-create-access.yaml
      
      # CIS 4.6.1: Require Namespace Boundaries
      kubectl apply -f ${path.module}/../policies/require-namespace-boundaries.yaml
      
      # CIS 5.4.4: Default Deny Network Policy
      kubectl apply -f ${path.module}/../policies/default-deny-network-policy.yaml
      
      echo "All CIS Kyverno policies applied!"
    EOT
  }

  depends_on = [
    helm_release.kyverno,
    azurerm_kubernetes_cluster.aks
  ]
}
