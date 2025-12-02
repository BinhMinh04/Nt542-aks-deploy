terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.35.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-nt542-s13-sea"
    storage_account_name = "nt542statestorage"
    container_name       = "terraformtfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}

  use_oidc        = true
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}

