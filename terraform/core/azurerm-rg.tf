resource "azurerm_resource_group" "main" {
  name     = "rg-nt542-g13-sea"
  location = var.location

  tags = {
    environment = "Lab"
    managed_by  = "terraform"
  }
}