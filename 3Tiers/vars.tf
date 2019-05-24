variable "sub_addresses" {
    type = "list"
    default = [ "10.0.2.0/24", "10.1.2.0/24", "10.2.2.0/24"]
}

variable "vnet_addresses" {
    type = "list"
    default = [ "10.0.0.0/16", "10.1.0.0/16", "10.2.0.0/16"]
}

variable "type" {
    type = "list"
    default = [ "Tech", "Apps", "Data"]
}