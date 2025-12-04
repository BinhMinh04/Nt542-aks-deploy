# AKS CIS Compliance Automation

## Mô tả
Tự động triển khai Azure Kubernetes Service (AKS) tuân thủ chuẩn bảo mật CIS benchmark.

## Cấu trúc
```
terraform/core/     # Infrastructure as Code (AKS, ACR, KeyVault, Networks)
terraform/policies/ # 15+ Kyverno security policies 
terraform/manifests/# Kube-bench automated compliance scanning
```

## Tính năng CIS
- **Private Cluster** với authorized IP ranges
- **Azure RBAC** integration + AAD
- **Network Policies** (Calico)  
- **Audit Logging** + Monitoring
- **Pod Security Standards**
- **Automated Compliance Scanning**

## Yêu cầu
- Azure CLI, Terraform, kubectl
- Azure subscription với Contributor role

## Triển khai
```bash
# 1. Setup
cd terraform/core
terraform init

# 2. Deploy
terraform apply -var-file="dev.tfvars" -var-file="secrets.tfvars"

# 3. Configure kubectl
az aks get-credentials --resource-group <rg> --name <cluster>

# 4. Deploy policies
kubectl apply -f https://github.com/kyverno/kyverno/releases/latest/download/install.yaml
kubectl apply -f terraform/policies/
kubectl create namespace security
kubectl apply -f terraform/manifests/
```

## Kiểm tra
```bash
# CIS compliance scan results
kubectl logs -n security -l app=kube-bench

# Policy violations  
kubectl get events --field-selector reason=PolicyViolation
```