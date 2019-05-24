#Resource Group
resource "azurerm_resource_group" "3tResourceGroup" {
    name     = "3tResourceGroup"
    location = "eastasia"

    tags {
        environment = "Dev"
    }
}

#Vnet containing 3 VM
resource "azurerm_virtual_network" "3tVnet" {
    count               = 3
    name                = "Vnet-${count.index}"
    address_space       = ["${element(var.vnet_addresses, count.index)}"]
    location            = "eastasia"
    resource_group_name = "${azurerm_resource_group.3tResourceGroup.name}"

    tags {
        environment = "Dev"
        type        = "${element(var.type, count.index)}"
    }
}

#Subnet for Vnet1
resource "azurerm_subnet" "3tSubnet-Tech" {
    name                 = "Subnet-0"
    resource_group_name  = "${azurerm_resource_group.3tResourceGroup.name}"
    virtual_network_name = "${element(azurerm_virtual_network.3tVnet.*.name, 0)}"
    address_prefix       = "${element(var.sub_addresses, 0)}"
    network_security_group_id = "${element(azurerm_network_security_group.3tSubnet-NSGT.*.id, 0)}"
}

#Subnet for Vnet2
resource "azurerm_subnet" "3tSubnet-Apps" {
    name                 = "Subnet-1"
    resource_group_name  = "${azurerm_resource_group.3tResourceGroup.name}"
    virtual_network_name = "${element(azurerm_virtual_network.3tVnet.*.name, 1)}"
    address_prefix       = "${element(var.sub_addresses, 1)}"
    network_security_group_id = "${element(azurerm_network_security_group.3tSubnet-NSGA.*.id, 0)}"
}

#Subnet for Vnet3
resource "azurerm_subnet" "3tSubnet-Data" {
    name                 = "Subnet-2"
    resource_group_name  = "${azurerm_resource_group.3tResourceGroup.name}"
    virtual_network_name = "${element(azurerm_virtual_network.3tVnet.*.name, 2)}"
    address_prefix       = "${element(var.sub_addresses, 2)}"
    network_security_group_id = "${element(azurerm_network_security_group.3tSubnet-NSGD.*.id, 0)}"
}

#3t public IP
resource "azurerm_public_ip" "3tPIP" {
    count                        = 4
    name                         = "PIP-${count.index}"
    location                     = "eastasia"
    resource_group_name          = "${azurerm_resource_group.3tResourceGroup.name}"
    allocation_method            = "Dynamic"

    tags {
        environment = "Dev"
        type        = "${element(var.type, count.index)}"
    }
}

#Tech Security Group
resource "azurerm_network_security_group" "3tNSGT" {
    name                = "NSG-Tech"
    location            = "eastasia"
    resource_group_name = "${azurerm_resource_group.3tResourceGroup.name}"
    
    security_rule {
        name                       = "SSH"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "WEB"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "APPIN"
        priority                   = 120
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "7050"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "APPOUT"
        priority                   = 130
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "7050"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags {
        environment = "Dev"
        type        = "${element(var.type, 0)}"
    }
}

#Apps Security Group
resource "azurerm_network_security_group" "3tNSGA" {
    name                = "NSG-Apps"
    location            = "eastasia"
    resource_group_name = "${azurerm_resource_group.3tResourceGroup.name}"
    
    security_rule {
        name                       = "SSH"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "APPIN"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "7050"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "APPOUT"
        priority                   = 120
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "7050"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "DATAIN"
        priority                   = 130
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "1251"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "DATAOUT"
        priority                   = 140
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "1251"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags {
        environment = "Dev"
        type        = "${element(var.type, 1)}"
    }
}

#Data Security Group
resource "azurerm_network_security_group" "3tNSGD" {
    name                = "NSG-Data"
    location            = "eastasia"
    resource_group_name = "${azurerm_resource_group.3tResourceGroup.name}"
    
    security_rule {
        name                       = "SSH"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "DATAIN"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "1251"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "DATAOUT"
        priority                   = 120
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "1251"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "EXT"
        priority                   = 130
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "445"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "EXTALLDENY"
        priority                   = 140
        direction                  = "Outbound"
        access                     = "Deny"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags {
        environment = "Dev"
        type        = "${element(var.type, 2)}"
    }
}

#Tech Subnet Security Group
resource "azurerm_network_security_group" "3tSubnet-NSGT" {
    name                = "Sub-NSG-Tech"
    location            = "eastasia"
    resource_group_name = "${azurerm_resource_group.3tResourceGroup.name}"

    security_rule {
        name                       = "SSH"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "WEB"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "APPIN"
        priority                   = 120
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "${element(var.sub_addresses, 1)}"
        destination_address_prefix = "${element(var.sub_addresses, 0)}"
    }

    security_rule {
        name                       = "APPOUT"
        priority                   = 130
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "${element(var.sub_addresses, 0)}"
        destination_address_prefix = "${element(var.sub_addresses, 1)}"
    }

    tags {
        environment = "Dev"
        type        = "${element(var.type, 0)}"
    }
}

#Apps Subnet Security Group
resource "azurerm_network_security_group" "3tSubnet-NSGA" {
    name                = "Sub-NSG-Apps"
    location            = "eastasia"
    resource_group_name = "${azurerm_resource_group.3tResourceGroup.name}"

    security_rule {
        name                       = "SSH"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "APPIN"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "${element(var.sub_addresses, 0)}"
        destination_address_prefix = "${element(var.sub_addresses, 1)}"
    }

    security_rule {
        name                       = "APPOUT"
        priority                   = 120
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "${element(var.sub_addresses, 1)}"
        destination_address_prefix = "${element(var.sub_addresses, 0)}"
    }

    security_rule {
        name                       = "DATAIN"
        priority                   = 130
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "${element(var.sub_addresses, 2)}"
        destination_address_prefix = "${element(var.sub_addresses, 1)}"
    }

    security_rule {
        name                       = "DATAOUT"
        priority                   = 140
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "${element(var.sub_addresses, 1)}"
        destination_address_prefix = "${element(var.sub_addresses, 2)}"
    }

    tags {
        environment = "Dev"
        type        = "${element(var.type, 0)}"
    }
}

#Data Subnet Security Group
resource "azurerm_network_security_group" "3tSubnet-NSGD" {
    name                = "Sub-NSG-Data"
    location            = "eastasia"
    resource_group_name = "${azurerm_resource_group.3tResourceGroup.name}"

    security_rule {
        name                       = "DATAIN"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "${element(var.sub_addresses, 1)}"
        destination_address_prefix = "${element(var.sub_addresses, 2)}"
    }

    security_rule {
        name                       = "DATAOUT"
        priority                   = 110
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "${element(var.sub_addresses, 2)}"
        destination_address_prefix = "${element(var.sub_addresses, 1)}"
    }

    security_rule {
        name                       = "SSH"
        priority                   = 120
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }    

    security_rule {
        name                       = "EXT"
        priority                   = 130
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "445"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "EXTALLDENY"
        priority                   = 140
        direction                  = "Outbound"
        access                     = "Deny"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags {
        environment = "Dev"
        type        = "${element(var.type, 0)}"
    }
}

#Jenkins Network Interface
resource "azurerm_network_interface" "3tNICT" {
    count               = 2
    name                = "NIC-Tech-${count.index}"
    location            = "eastasia"
    resource_group_name = "${azurerm_resource_group.3tResourceGroup.name}"
    network_security_group_id = "${element(azurerm_network_security_group.3tNSGT.*.id, count.index)}"

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = "${element(azurerm_subnet.3tSubnet-Tech.*.id, 0)}"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = "${element(azurerm_public_ip.3tPIP.*.id, count.index)}"
        load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.Azure-LB-AP.id}"]
    }

    tags {
        environment = "Dev"
        type        = "${element(var.type, 0)}"
    }
}

#Jenkins Network Interface
resource "azurerm_network_interface" "3tNICA" {
    name                = "NIC-Apps"
    location            = "eastasia"
    resource_group_name = "${azurerm_resource_group.3tResourceGroup.name}"
    network_security_group_id = "${element(azurerm_network_security_group.3tNSGA.*.id, count.index)}"

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = "${element(azurerm_subnet.3tSubnet-Apps.*.id, 1)}"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = "${element(azurerm_public_ip.3tPIP.*.id, 2)}"
    }

    tags {
        environment = "Dev"
        type        = "${element(var.type, 1)}"
    }
}

#Jenkins Network Interface
resource "azurerm_network_interface" "3tNICD" {
    name                = "NIC-Data"
    location            = "eastasia"
    resource_group_name = "${azurerm_resource_group.3tResourceGroup.name}"
    network_security_group_id = "${element(azurerm_network_security_group.3tNSGD.*.id, count.index)}"

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = "${element(azurerm_subnet.3tSubnet-Data.*.id, 2)}"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = "${element(azurerm_public_ip.3tPIP.*.id, 3)}"
    }

    tags {
        environment = "Dev"
        type        = "${element(var.type, 2)}"
    }
}

#Tech VM
resource "azurerm_virtual_machine" "3tVM-Tech" {
    count                 = 2
    name                  = "VM-Tech-${count.index}"
    location              = "eastasia"
    resource_group_name   = "${azurerm_resource_group.3tResourceGroup.name}"
    network_interface_ids = ["${element(azurerm_network_interface.3tNICT.*.id, count.index)}"]
    vm_size               = "Standard_B1ms"

    storage_os_disk {
        name              = "myOsDisk${count.index}"
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
        computer_name  = "VM-Tech-${count.index}"
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
        environment = "Dev"
        type        = "${element(var.type, 0)}"
    }
}

#Apps VM
resource "azurerm_virtual_machine" "3tVM-Apps" {
    name                  = "VM-Apps"
    location              = "eastasia"
    resource_group_name   = "${azurerm_resource_group.3tResourceGroup.name}"
    network_interface_ids = ["${azurerm_network_interface.3tNICA.id}"]
    vm_size               = "Standard_B1ms"

    storage_os_disk {
        name              = "myOsDisk3"
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
        computer_name  = "VM-Apps"
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
        environment = "Dev"
        type        = "${element(var.type, 1)}"
    }
}

#Load balancer public IP
resource "azurerm_public_ip" "lbPIP" {
    name                         = "lbPIP"
    location                     = "eastasia"
    resource_group_name          = "${azurerm_resource_group.3tResourceGroup.name}"
    allocation_method            = "Dynamic"

    tags {
        environment = "Terraform Demo"
    }
}

#Load balancer
resource "azurerm_lb" "Azure-LB" {
  name                = "Azure-LB"
  location            = "eastasia"
  resource_group_name = "${azurerm_resource_group.3tResourceGroup.name}"

  frontend_ip_configuration {
    name                 = "Azure-LB-PIP"
    public_ip_address_id = "${azurerm_public_ip.lbPIP.id}"
  }
}

#Load balancer backend adress Pool
resource "azurerm_lb_backend_address_pool" "Azure-LB-AP" {
  resource_group_name = "${azurerm_resource_group.3tResourceGroup.name}"
  loadbalancer_id     = "${azurerm_lb.Azure-LB.id}"
  name                = "BackEndAddressPool"
}

#Load balancer rule
resource "azurerm_lb_rule" "Azure-LB-Rule" {
  resource_group_name            = "${azurerm_resource_group.3tResourceGroup.name}"
  loadbalancer_id                = "${azurerm_lb.Azure-LB.id}"
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 3389
  backend_port                   = 3389
  frontend_ip_configuration_name = "Azure-LB-PIP"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.Azure-LB-AP.id}"
}

#Load balancer availability set
resource "azurerm_availability_set" "Azure-AS" {
  name                = "Azure-AS"
  location            = "eastasia"
  resource_group_name = "${azurerm_resource_group.3tResourceGroup.name}"
  managed             = "true"
}

#Data VM
resource "azurerm_virtual_machine" "3tVM-Dev" {
    name                  = "VM-Data"
    location              = "eastasia"
    resource_group_name   = "${azurerm_resource_group.3tResourceGroup.name}"
    network_interface_ids = ["${azurerm_network_interface.3tNICD.id}"]
    vm_size               = "Standard_B1ms"

    storage_os_disk {
        name              = "myOsDisk4"
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
        computer_name  = "VM-Data"
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
        environment = "Dev"
        type        = "${element(var.type, 2)}"
    }
}
