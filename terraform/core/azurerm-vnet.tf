resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.environment}-${var.group}-${var.short_location}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.0.0.0/8"]
}

resource "azurerm_subnet" "aks" {
  name                 = "snet-aks-${var.environment}-${var.group}-${var.short_location}"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.240.0.0/16"]
}
