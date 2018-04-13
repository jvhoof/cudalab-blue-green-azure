##############################################################################################################
#  _                         
# |_) _  __ __ _  _     _| _ 
# |_)(_| |  | (_|(_ |_|(_|(_|
#                                                    
# Terraform configuration for Blue/Green deployment: Networking
#
##############################################################################################################

resource "azurerm_resource_group" "resourcegroupvnet" {
  name     = "${var.PREFIX}-RG-VNET"
  location = "${var.location}"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.PREFIX}-VNET"
  address_space       = ["${var.vnet}"]
  location            = "${azurerm_resource_group.resourcegroupvnet.location}"
  resource_group_name = "${azurerm_resource_group.resourcegroupvnet.name}"
}

resource "azurerm_subnet" "subnet1" {
  name                 = "${var.PREFIX}-SUBNET-CGF"
  resource_group_name  = "${azurerm_resource_group.resourcegroupvnet.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_PREFIX       = "${var.subnet_cgf}"
}

resource "azurerm_subnet" "subnet2" {
  name                 = "${var.PREFIX}-SUBNET-WAF"
  resource_group_name  = "${azurerm_resource_group.resourcegroupvnet.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_PREFIX       = "${var.subnet_waf}"
  route_table_id       = "${azurerm_route_table.wafroute.id}"
}

resource "azurerm_subnet" "subnet3" {
  name                 = "${var.PREFIX}-SUBNET-WEB"
  resource_group_name  = "${azurerm_resource_group.resourcegroupvnet.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_PREFIX       = "${var.subnet_web}"
  route_table_id       = "${azurerm_route_table.webroute.id}"
}

resource "azurerm_subnet" "subnet4" {
  name                 = "${var.PREFIX}-SUBNET-DB"
  resource_group_name  = "${azurerm_resource_group.resourcegroupvnet.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_PREFIX       = "${var.subnet_db}"
  route_table_id       = "${azurerm_route_table.dbroute.id}"
}

resource "azurerm_route_table" "webroute" {
  name                = "${var.PREFIX}-RT-WEB"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.resourcegroupvnet.name}"

  route {
    name                   = "${var.PREFIX}-WebToInternet"
    address_PREFIX         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.cgf_a_ipaddress}"
  }

  route {
    name                   = "${var.PREFIX}-WebToWAF"
    address_PREFIX         = "172.30.101.0/24"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.cgf_a_ipaddress}"
  }

  route {
    name                   = "${var.PREFIX}-WebToDB"
    address_PREFIX         = "172.30.103.0/24"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.cgf_a_ipaddress}"
  }
}

resource "azurerm_route_table" "wafroute" {
  name                = "${var.PREFIX}-RT-WAF"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.resourcegroupvnet.name}"

  route {
    name                   = "${var.PREFIX}-WAFToWEB"
    address_PREFIX         = "172.30.102.0/24"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.cgf_a_ipaddress}"
  }

  route {
    name                   = "${var.PREFIX}-WAFToDB"
    address_PREFIX         = "172.30.103.0/24"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.cgf_a_ipaddress}"
  }
}

resource "azurerm_route_table" "dbroute" {
  name                = "${var.PREFIX}-RT-DB"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.resourcegroupvnet.name}"

  route {
    name                   = "${var.PREFIX}-DBToInternet"
    address_PREFIX         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.cgf_a_ipaddress}"
  }

  route {
    name                   = "${var.PREFIX}-DBToWAF"
    address_PREFIX         = "172.30.101.0/24"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.cgf_a_ipaddress}"
  }

  route {
    name                   = "${var.PREFIX}-DBToWEB"
    address_PREFIX         = "172.30.102.0/24"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.cgf_a_ipaddress}"
  }
}
