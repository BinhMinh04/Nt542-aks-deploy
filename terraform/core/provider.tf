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
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}

