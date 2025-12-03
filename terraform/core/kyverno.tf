resource "helm_release" "kyverno" {
  name             = "kyverno"
  repository       = "https://kyverno.github.io/kyverno/"
  chart            = "kyverno"
  namespace        = "kyverno"
  create_namespace = true
  version          = "3.1.0"

  # Chờ AKS tạo xong
  depends_on = [azurerm_kubernetes_cluster.aks]
}

