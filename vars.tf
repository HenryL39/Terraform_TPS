variable "regions" {
    type = "list"
    default = ["eastus","westus"]
}

variable "subnet_Name" {
    type = "list"
    default = ["Subnet1","Subnet2"]
}

variable "ressource_Group_Name" {
    type = "list"
    default = ["ressourceGRP1","ressourceGRP2"]
}

variable "NSG_Name" {
    type = "list"
    default = ["NSG1","NSG2"]
}

variable "vnet_Name" {
    type = "list"
    default = ["vNet1","vNet2"]
}

variable "PIP_Name" {
    type = "list"
    default = ["JenkinsPIP","NexusPIP","DockerPIP","KubernetesPIP","MongoPIP"]
}

variable "ports" {
    type = "list"
    default = ["22","8081","8080"]
}

variable "ssh_port" {}
variable "nexus_port" {}
variable "jenkins_port" {}

variable "NIC_Name" {
    type = "list"
    default = ["JenkinsNIC","NexusNIC","DockerNIC","KubernetesNIC","MongoNIC"]
}

variable "VM_Name" {
    type = "list"
    default = ["JenkinsVM","NexusVM","DockerVM","KubernetesVM","MongoVM"]
}

variable "sub_addresses" {
    type = "list"
    default = [ "10.0.2.0/24", "10.1.2.0/24"]
}

variable "vnet_addresses" {
    type = "list"
    default = [ "10.0.0.0/16", "10.1.0.0/16"]
}

variable "storage_Name" {
    type = "list"
    default = ["myOsDisk1","myOsDisk2","myOsDisk3","myOsDisk4","myOsDisk5"]
}