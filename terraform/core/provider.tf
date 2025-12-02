terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.35.0"
    }
  }
}

provider "azurerm" {
  features {}

  use_oidc        = true
  subscription_id = "b8c602f1-c47f-45f3-bfc3-3ac4c0072bbf"
  tenant_id       = "7dc2e42d-5de4-4e86-bca3-c5ed9ad61d56"
}

