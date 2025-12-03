terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.35.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.1.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.38.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-nt542-g13-sea"
    storage_account_name = "nt542statestorage"
    container_name       = "terraformstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}

  use_oidc        = true
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}

provider "helm" {
  kubernetes {
    host                   = try(azurerm_kubernetes_cluster.aks.kube_config.0.host, "")
    client_certificate     = try(base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate), "")
    client_key             = try(base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key), "")
    cluster_ca_certificate = try(base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate), "")
  }
}

provider "kubernetes" {
  host                   = try(azurerm_kubernetes_cluster.aks.kube_config.0.host, "")
  client_certificate     = try(base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate), "")
  client_key             = try(base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key), "")
  cluster_ca_certificate = try(base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate), "")
}
