data "azurerm_resource_group" "baseRG" {
  name = "Azure_Data"
}

data "azurerm_virtual_network" "baseVnet" {
  name                = "Azure_Data-vnet"
  resource_group_name = "${data.azurerm_resource_group.baseRG.name}"
}

data "azurerm_subnet" "baseSubnet" {
  name                 = "default"
  virtual_network_name = "${data.azurerm_virtual_network.baseVnet.name}"
  resource_group_name  = "${data.azurerm_resource_group.baseRG.name}"
}