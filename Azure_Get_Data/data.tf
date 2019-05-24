resource "azurerm_network_security_group" "NSG" {
    name                = "Azure-NSG"
    location            = "northeurope"
    resource_group_name = "${data.azurerm_resource_group.baseRG.name}"
    
    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags {
        environment = "Terraform Demo"
    }
}

resource "azurerm_public_ip" "PIP" {
    count                        = 3
    name                         = "Azure-PIP${count.index}"
    location                     = "northeurope"
    resource_group_name          = "${data.azurerm_resource_group.baseRG.name}"
    allocation_method            = "Dynamic"

    tags {
        environment = "Terraform Demo"
    }
}

resource "azurerm_public_ip" "lbPIP" {
    name                         = "lbPIP"
    location                     = "northeurope"
    resource_group_name          = "${data.azurerm_resource_group.baseRG.name}"
    allocation_method            = "Dynamic"

    tags {
        environment = "Terraform Demo"
    }
}

resource "azurerm_network_interface" "NIC" {
    count               = 3
    name                = "NIC${count.index}"
    location            = "northeurope"
    resource_group_name = "${data.azurerm_resource_group.baseRG.name}"
    network_security_group_id = "${element(azurerm_network_security_group.NSG.*.id, count.index)}"
    

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = "${data.azurerm_subnet.baseSubnet.id}"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = "${element(azurerm_public_ip.PIP.*.id, count.index)}"
        load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.Azure-LB-AP.id}"]
    }

    tags {
        environment = "Terraform Demo"
    }
}

resource "azurerm_virtual_machine" "Azure-VM" {
    count                 = 3
    name                  = "Azure-VM${count.index}"
    location              = "northeurope"
    resource_group_name   = "${data.azurerm_resource_group.baseRG.name}"
    network_interface_ids = ["${element(azurerm_network_interface.NIC.*.id, count.index)}"]
    vm_size               = "Standard_B1ms"
    availability_set_id   = "${azurerm_availability_set.Azure-AS.id}"

    storage_os_disk {
        name              = "AzureOsDisk${count.index}"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "Azure-VM${count.index}"
        admin_username = "azureuser"
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/azureuser/.ssh/authorized_keys"
            key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/loFdLgNMVS5xbaZubYj/0EBhQxq/MlqsgcoJpjDiXYyDsDrmMqPBCR3n0516DBJfYXG5wXeKik6h60vJscDp27z1DNkAHBxgLUYErOvMkftEyHnb+KeoI3AtmKvpn9wozENHP9VqmSmbv+h0zASK0MJjkxQxsZVAZTPNDJIdW9cFBgx9KRLD4Xct7c+VhToQeaWG/ChQszsyC7uT7YAsIQVAVBpRPiiQ1H4+nrj43KwrtAYSSNcRhEppsZCS0QVzrgBJ98DrvLfv2qDLuFGZ34AyzNtS7ZVrii+NU6n0a80pIYMFy/dZUbnwRP4tKuq8eyF/uBlk+I7NyvDeEZcN henry@linux-3.home"
        }
    }

    tags {
        environment = "Terraform Demo"
    }
}

resource "azurerm_lb" "Azure-LB" {
  name                = "Azure-LB"
  location            = "northeurope"
  resource_group_name = "${data.azurerm_resource_group.baseRG.name}"

  frontend_ip_configuration {
    name                 = "Azure-LB-PIP"
    public_ip_address_id = "${azurerm_public_ip.lbPIP.id}"
  }
}

resource "azurerm_lb_backend_address_pool" "Azure-LB-AP" {
  resource_group_name = "${data.azurerm_resource_group.baseRG.name}"
  loadbalancer_id     = "${azurerm_lb.Azure-LB.id}"
  name                = "BackEndAddressPool"
}

resource "azurerm_lb_rule" "Azure-LB-Rule" {
  resource_group_name            = "${data.azurerm_resource_group.baseRG.name}"
  loadbalancer_id                = "${azurerm_lb.Azure-LB.id}"
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 3389
  backend_port                   = 3389
  frontend_ip_configuration_name = "Azure-LB-PIP"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.Azure-LB-AP.id}"
}

resource "azurerm_availability_set" "Azure-AS" {
  name                = "Azure-AS"
  location            = "northeurope"
  resource_group_name = "${data.azurerm_resource_group.baseRG.name}"
  managed             = "true"
}