#Resource Group
resource "azurerm_resource_group" "myterraformgroup" {
    count    = 2
    name     = "${element(var.ressource_Group_Name, count.index)}"
    location = "${element(var.regions, count.index)}"

    tags {
        environment = "Terraform Demo"
    }
}

#Vnet containing 3 VM
resource "azurerm_virtual_network" "Vnet" {
    count               = 2
    name                = "${element(var.vnet_Name, count.index)}"
    address_space       = ["${element(var.vnet_addresses, count.index)}"]
    location            = "${element(var.regions, count.index)}"
    resource_group_name = "${element(azurerm_resource_group.myterraformgroup.*.name, count.index)}"

    tags {
        environment = "Terraform Demo"
    }
}

// #Vnet containing 2 VM
// resource "azurerm_virtual_network" "Vnet2" {
//     name                = "${var.vnet2_Name}"
//     address_space       = ["10.1.0.0/16"]
//     location            = "${var.region_wus}"
//     resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"

//     tags {
//         environment = "Terraform Demo"
//     }
// }

#Subnet for Vnet1
resource "azurerm_subnet" "Subnet" {
    count                = 2
    name                 = "${element(var.subnet_Name, count.index)}"
    resource_group_name  = "${element(azurerm_resource_group.myterraformgroup.*.name, count.index)}"
    virtual_network_name = "${element(azurerm_virtual_network.Vnet.*.name, count.index)}"
    address_prefix       = "${element(var.sub_addresses, count.index)}"
}

// #Subnet for Vnet2
// resource "azurerm_subnet" "Subnet2" {
//     name                 = "${var.subnet2_Name}"
//     resource_group_name  = "${azurerm_resource_group.myterraformgroup.name}"
//     virtual_network_name = "${azurerm_virtual_network.Vnet2.name}"
//     address_prefix       = "10.1.2.0/24"
// }

#Jenkins public IP
resource "azurerm_public_ip" "PIP" {
    count                        = 5
    name                         = "${element(var.PIP_Name, count.index)}"
    location                     = "${element(var.regions, count.index)}"
    resource_group_name          = "${element(azurerm_resource_group.myterraformgroup.*.name, count.index)}"
    allocation_method            = "Dynamic"

    tags {
        environment = "Terraform Demo"
    }
}

// #Nexus public IP
// resource "azurerm_public_ip" "NexusPIP" {
//     name                         = "${var.nexus_PIP_Name}"
//     location                     = "${var.region_eus}"
//     resource_group_name          = "${azurerm_resource_group.myterraformgroup.name}"
//     allocation_method            = "Dynamic"

//     tags {
//         environment = "Terraform Demo"
//     }
// }

// #Docker public IP
// resource "azurerm_public_ip" "DockerPIP" {
//     name                         = "${var.docker_PIP_Name}"
//     location                     = "${var.region_eus}"
//     resource_group_name          = "${azurerm_resource_group.myterraformgroup.name}"
//     allocation_method            = "Dynamic"

//     tags {
//         environment = "Terraform Demo"
//     }
// }

// #Kubernetes public ip
// resource "azurerm_public_ip" "K8sPIP" {
//     name                         = "${var.kub_PIP_Name}"
//     location                     = "${var.region_wus}"
//     resource_group_name          = "${azurerm_resource_group.myterraformgroup.name}"
//     allocation_method            = "Dynamic"

//     tags {
//         environment = "Terraform Demo"
//     }
// }

// #MongoDB public ip
// resource "azurerm_public_ip" "MongoPIP" {
//     name                         = "${var.mongo_PIP_Name}"
//     location                     = "${var.region_wus}"
//     resource_group_name          = "${azurerm_resource_group.myterraformgroup.name}"
//     allocation_method            = "Dynamic"

//     tags {
//         environment = "Terraform Demo"
//     }
// }

#Global SSH security group
resource "azurerm_network_security_group" "NSG" {
    count               = 2
    name                = "${element(var.NSG_Name, count.index)}"
    location            = "${element(var.regions, count.index)}"
    resource_group_name = "${element(azurerm_resource_group.myterraformgroup.*.name, count.index)}"
    
    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "${var.ssh_port}"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "NEXUS"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "${var.nexus_port}"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "JENKINS"
        priority                   = 1003
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "${var.jenkins_port}"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags {
        environment = "Terraform Demo"
    }
}

#Jenkins Network Interface
resource "azurerm_network_interface" "NIC" {
    count               = 5
    name                = "${element(var.NIC_Name, count.index)}"
    location            = "${element(var.regions, count.index)}"
    resource_group_name = "${element(azurerm_resource_group.myterraformgroup.*.name, count.index)}"
    network_security_group_id = "${element(azurerm_network_security_group.NSG.*.id, count.index)}"

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = "${element(azurerm_subnet.Subnet.*.id, count.index)}"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = "${element(azurerm_public_ip.PIP.*.id, count.index)}"
    }

    tags {
        environment = "Terraform Demo"
    }
}

// #Nexus Network Interface
// resource "azurerm_network_interface" "NexusNIC" {
//     name                = "${var.nexus_NIC_Name}"
//     location            = "${var.region_eus}"
//     resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"
//     network_security_group_id = "${azurerm_network_security_group.myterraformnsg.id}"

//     ip_configuration {
//         name                          = "myNicConfiguration2"
//         subnet_id                     = "${azurerm_subnet.Subnet1.id}"
//         private_ip_address_allocation = "Dynamic"
//         public_ip_address_id          = "${azurerm_public_ip.NexusPIP.id}"
//     }

//     tags {
//         environment = "Terraform Demo"
//     }
// }

// #Docker Network Interface
// resource "azurerm_network_interface" "DockerNIC" {
//     name                = "${var.docker_NIC_Name}"
//     location            = "${var.region_eus}"
//     resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"
//     network_security_group_id = "${azurerm_network_security_group.myterraformnsg.id}"

//     ip_configuration {
//         name                          = "myNicConfiguration4"
//         subnet_id                     = "${azurerm_subnet.Subnet1.id}"
//         private_ip_address_allocation = "Dynamic"
//         public_ip_address_id          = "${azurerm_public_ip.DockerPIP.id}"
//     }

//     tags {
//         environment = "Terraform Demo"
//     }
// }

// #MongoDB Network Interface
// resource "azurerm_network_interface" "MongoNIC" {
//     name                = "${var.mongo_NIC_Name}"
//     location            = "${var.region_wus}"
//     resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"
//     network_security_group_id = "${azurerm_network_security_group.myterraformnsg.id}"

//     ip_configuration {
//         name                          = "myNicConfiguration5"
//         subnet_id                     = "${azurerm_subnet.Subnet2.id}"
//         private_ip_address_allocation = "Dynamic"
//         public_ip_address_id          = "${azurerm_public_ip.MongoPIP.id}"
//     }

//     tags {
//         environment = "Terraform Demo"
//     }
// }

// #Kubernetes Network Interface
// resource "azurerm_network_interface" "KubernetesNIC" {
//     name                = "${var.kub_NIC_Name}"
//     location            = "${var.region_wus}"
//     resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"
//     network_security_group_id = "${azurerm_network_security_group.myterraformnsg.id}"

//     ip_configuration {
//         name                          = "myNicConfiguration6"
//         subnet_id                     = "${azurerm_subnet.Subnet2.id}"
//         private_ip_address_allocation = "Dynamic"
//         public_ip_address_id          = "${azurerm_public_ip.K8sPIP.id}"
//     }

//     tags {
//         environment = "Terraform Demo"
//     }
// }

#Random ID
resource "random_id" "randomId" {
    count       = 2
    keepers {
		resource_group = "${element(azurerm_resource_group.myterraformgroup.*.name, count.index)}"
	}
    
    byte_length = 8
}

#Jenkins VM
resource "azurerm_virtual_machine" "JenkinsVM" {
    count                 = 5
    name                  = "${element(var.VM_Name, count.index)}"
    location              = "${element(var.regions, count.index)}"
    resource_group_name   = "${element(azurerm_resource_group.myterraformgroup.*.name, count.index)}"
    network_interface_ids = ["${element(azurerm_network_interface.NIC.*.id, count.index)}"]
    vm_size               = "Standard_B1ms"

    storage_os_disk {
        name              = "${element(var.storage_Name, count.index)}"
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
        computer_name  = "${element(var.VM_Name, count.index)}"
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

// #Nexus VM
// resource "azurerm_virtual_machine" "NexusVM" {
//     name                  = "${var.nexus_VM_Name}"
//     location              = "${var.region_eus}"
//     resource_group_name   = "${azurerm_resource_group.myterraformgroup.name}"
//     network_interface_ids = ["${azurerm_network_interface.NexusNIC.id}"]
//     vm_size               = "Standard_B1ms"

//     storage_os_disk {
//         name              = "myOsDisk2"
//         caching           = "ReadWrite"
//         create_option     = "FromImage"
//         managed_disk_type = "Premium_LRS"
//     }

//     storage_image_reference {
//         publisher = "Canonical"
//         offer     = "UbuntuServer"
//         sku       = "16.04.0-LTS"
//         version   = "latest"
//     }

//     os_profile {
//         computer_name  = "${var.nexus_VM_Name}"
//         admin_username = "azureuser"
//     }

//     os_profile_linux_config {
//         disable_password_authentication = true
//         ssh_keys {
//             path     = "/home/azureuser/.ssh/authorized_keys"
//             key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/loFdLgNMVS5xbaZubYj/0EBhQxq/MlqsgcoJpjDiXYyDsDrmMqPBCR3n0516DBJfYXG5wXeKik6h60vJscDp27z1DNkAHBxgLUYErOvMkftEyHnb+KeoI3AtmKvpn9wozENHP9VqmSmbv+h0zASK0MJjkxQxsZVAZTPNDJIdW9cFBgx9KRLD4Xct7c+VhToQeaWG/ChQszsyC7uT7YAsIQVAVBpRPiiQ1H4+nrj43KwrtAYSSNcRhEppsZCS0QVzrgBJ98DrvLfv2qDLuFGZ34AyzNtS7ZVrii+NU6n0a80pIYMFy/dZUbnwRP4tKuq8eyF/uBlk+I7NyvDeEZcN henry@linux-3.home"
//         }
//     }

//     tags {
//         environment = "Terraform Demo"
//     }
// }

// #Docker VM
// resource "azurerm_virtual_machine" "DockerVM" {
//     name                  = "${var.docker_VM_Name}"
//     location              = "${var.region_eus}"
//     resource_group_name   = "${azurerm_resource_group.myterraformgroup.name}"
//     network_interface_ids = ["${azurerm_network_interface.DockerNIC.id}"]
//     vm_size               = "Standard_B1ms"

//     storage_os_disk {
//         name              = "myOsDisk3"
//         caching           = "ReadWrite"
//         create_option     = "FromImage"
//         managed_disk_type = "Premium_LRS"
//     }

//     storage_image_reference {
//         publisher = "Canonical"
//         offer     = "UbuntuServer"
//         sku       = "16.04.0-LTS"
//         version   = "latest"
//     }

//     os_profile {
//         computer_name  = "${var.docker_VM_Name}"
//         admin_username = "azureuser"
//     }

//     os_profile_linux_config {
//         disable_password_authentication = true
//         ssh_keys {
//             path     = "/home/azureuser/.ssh/authorized_keys"
//             key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/loFdLgNMVS5xbaZubYj/0EBhQxq/MlqsgcoJpjDiXYyDsDrmMqPBCR3n0516DBJfYXG5wXeKik6h60vJscDp27z1DNkAHBxgLUYErOvMkftEyHnb+KeoI3AtmKvpn9wozENHP9VqmSmbv+h0zASK0MJjkxQxsZVAZTPNDJIdW9cFBgx9KRLD4Xct7c+VhToQeaWG/ChQszsyC7uT7YAsIQVAVBpRPiiQ1H4+nrj43KwrtAYSSNcRhEppsZCS0QVzrgBJ98DrvLfv2qDLuFGZ34AyzNtS7ZVrii+NU6n0a80pIYMFy/dZUbnwRP4tKuq8eyF/uBlk+I7NyvDeEZcN henry@linux-3.home"
//         }
//     }

//     tags {
//         environment = "Terraform Demo"
//     }
// }

// #Kubernetes VM
// resource "azurerm_virtual_machine" "KubernetesVM" {
//     name                  = "${var.kub_VM_Name}"
//     location              = "${var.region_wus}"
//     resource_group_name   = "${azurerm_resource_group.myterraformgroup.name}"
//     network_interface_ids = ["${azurerm_network_interface.KubernetesNIC.id}"]
//     vm_size               = "Standard_B1ms"

//     storage_os_disk {
//         name              = "myOsDisk4"
//         caching           = "ReadWrite"
//         create_option     = "FromImage"
//         managed_disk_type = "Premium_LRS"
//     }

//     storage_image_reference {
//         publisher = "Canonical"
//         offer     = "UbuntuServer"
//         sku       = "16.04.0-LTS"
//         version   = "latest"
//     }

//     os_profile {
//         computer_name  = "${var.kub_VM_Name}"
//         admin_username = "azureuser"
//     }

//     os_profile_linux_config {
//         disable_password_authentication = true
//         ssh_keys {
//             path     = "/home/azureuser/.ssh/authorized_keys"
//             key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/loFdLgNMVS5xbaZubYj/0EBhQxq/MlqsgcoJpjDiXYyDsDrmMqPBCR3n0516DBJfYXG5wXeKik6h60vJscDp27z1DNkAHBxgLUYErOvMkftEyHnb+KeoI3AtmKvpn9wozENHP9VqmSmbv+h0zASK0MJjkxQxsZVAZTPNDJIdW9cFBgx9KRLD4Xct7c+VhToQeaWG/ChQszsyC7uT7YAsIQVAVBpRPiiQ1H4+nrj43KwrtAYSSNcRhEppsZCS0QVzrgBJ98DrvLfv2qDLuFGZ34AyzNtS7ZVrii+NU6n0a80pIYMFy/dZUbnwRP4tKuq8eyF/uBlk+I7NyvDeEZcN henry@linux-3.home"
//         }
//     }

//     tags {
//         environment = "Terraform Demo"
//     }
// }

// #MongoDB VM
// resource "azurerm_virtual_machine" "MongoVM" {
//     name                  = "${var.mongo_VM_Name}"
//     location              = "${var.region_wus}"
//     resource_group_name   = "${azurerm_resource_group.myterraformgroup.name}"
//     network_interface_ids = ["${azurerm_network_interface.MongoNIC.id}"]
//     vm_size               = "Standard_B1ms"

//     storage_os_disk {
//         name              = "myOsDisk5"
//         caching           = "ReadWrite"
//         create_option     = "FromImage"
//         managed_disk_type = "Premium_LRS"
//     }

//     storage_image_reference {
//         publisher = "Canonical"
//         offer     = "UbuntuServer"
//         sku       = "16.04.0-LTS"
//         version   = "latest"
//     }

//     os_profile {
//         computer_name  = "${var.mongo_VM_Name}"
//         admin_username = "azureuser"
//     }

//     os_profile_linux_config {
//         disable_password_authentication = true
//         ssh_keys {
//             path     = "/home/azureuser/.ssh/authorized_keys"
//             key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/loFdLgNMVS5xbaZubYj/0EBhQxq/MlqsgcoJpjDiXYyDsDrmMqPBCR3n0516DBJfYXG5wXeKik6h60vJscDp27z1DNkAHBxgLUYErOvMkftEyHnb+KeoI3AtmKvpn9wozENHP9VqmSmbv+h0zASK0MJjkxQxsZVAZTPNDJIdW9cFBgx9KRLD4Xct7c+VhToQeaWG/ChQszsyC7uT7YAsIQVAVBpRPiiQ1H4+nrj43KwrtAYSSNcRhEppsZCS0QVzrgBJ98DrvLfv2qDLuFGZ34AyzNtS7ZVrii+NU6n0a80pIYMFy/dZUbnwRP4tKuq8eyF/uBlk+I7NyvDeEZcN henry@linux-3.home"
//         }
//     }

//     tags {
//         environment = "Terraform Demo"
//     }
// }