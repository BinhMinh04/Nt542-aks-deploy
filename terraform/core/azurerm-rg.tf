resource "azurerm_resource_group" "main" {
  name     = "rg-${var.environment}-${var.group}-${var.short_location}"
  location = var.location

  tags = {
    environment = "Lab"
    managed_by  = "terraform"
  }
}
