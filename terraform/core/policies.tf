# CIS 4.2.1: Disallow privileged containers
resource "kubernetes_manifest" "disallow_privileged" {
  manifest = yamldecode(file("${path.module}/../polices/disallow-privileged.yaml"))
  
  depends_on = [helm_release.kyverno]
}

# CIS 4.2.2: Disallow host PID
resource "kubernetes_manifest" "disallow_host_pid" {
  manifest = yamldecode(file("${path.module}/../polices/disallow-host-pid.yaml"))
  
  depends_on = [helm_release.kyverno]
}

# CIS 4.6.3: Disallow default namespace
resource "kubernetes_manifest" "disallow_default_ns" {
  manifest = yamldecode(file("${path.module}/../polices/disallow-default-namespace.yaml"))
  
  depends_on = [helm_release.kyverno]
}