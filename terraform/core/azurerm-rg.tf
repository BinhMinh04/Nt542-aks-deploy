resource "azurerm_resource_group" "main" {
  name     = "rg-${var.environment}-${var.group}-${var.short_location}"
  location = var.location

  tags = {
    environment = "Lab"
    managed_by  = "terraform"
  }
}

import {
  to = azurerm_resource_group.main
  id = "/subscriptions/b8c602f1-c47f-45f3-bfc3-3ac4c0072bbf/resourceGroups/rg-nt542-g13-sea"
}