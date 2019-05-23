data "azurerm_network_interface" "test" {
  name                = "azure-vm527"
  resource_group_name = "Azure_Data"
}

output "network_interface_id" {
  value = "${data.azurerm_network_interface.test.location}"
}