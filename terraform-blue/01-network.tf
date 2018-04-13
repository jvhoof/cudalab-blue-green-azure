##############################################################################################################
#  _                         
# |_) _  __ __ _  _     _| _ 
# |_)(_| |  | (_|(_ |_|(_|(_|
#                                                    
# Terraform configuration for Blue/Green deployment: Networking
#
##############################################################################################################

resource "azurerm_resource_group" "resourcegroupvnet" {
  name     = "${var.prefix}-RG-VNET"
  location = "${var.location}"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-VNET"
  address_space       = ["${var.vnet}"]
  location            = "${azurerm_resource_group.resourcegroupvnet.location}"
  resource_group_name = "${azurerm_resource_group.resourcegroupvnet.name}"
}

resource "azurerm_subnet" "subnet1" {
  name                 = "${var.prefix}-SUBNET-CGF"
  resource_group_name  = "${azurerm_resource_group.resourcegroupvnet.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix       = "${var.subnet_cgf}"
}

resource "azurerm_subnet" "subnet2" {
  name                 = "${var.prefix}-SUBNET-WAF"
  resource_group_name  = "${azurerm_resource_group.resourcegroupvnet.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix       = "${var.subnet_waf}"
  route_table_id       = "${azurerm_route_table.wafroute.id}"
}

resource "azurerm_subnet" "subnet3" {
  name                 = "${var.prefix}-SUBNET-WEB"
  resource_group_name  = "${azurerm_resource_group.resourcegroupvnet.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix       = "${var.subnet_web}"
  route_table_id       = "${azurerm_route_table.webroute.id}"
}

resource "azurerm_subnet" "subnet4" {
  name                 = "${var.prefix}-SUBNET-DB"
  resource_group_name  = "${azurerm_resource_group.resourcegroupvnet.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix       = "${var.subnet_db}"
  route_table_id       = "${azurerm_route_table.dbroute.id}"
}

resource "azurerm_route_table" "webroute" {
  name                = "${var.prefix}-RT-WEB"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.resourcegroupvnet.name}"

  route {
    name                   = "${var.prefix}-WebToInternet"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.cgf_a_ipaddress}"
  }

  route {
    name                   = "${var.prefix}-WebToWAF"
    address_prefix         = "172.30.101.0/24"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.cgf_a_ipaddress}"
  }

  route {
    name                   = "${var.prefix}-WebToDB"
    address_prefix         = "172.30.103.0/24"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.cgf_a_ipaddress}"
  }
}

resource "azurerm_route_table" "wafroute" {
  name                = "${var.prefix}-RT-WAF"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.resourcegroupvnet.name}"

  route {
    name                   = "${var.prefix}-WAFToWEB"
    address_prefix         = "172.30.102.0/24"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.cgf_a_ipaddress}"
  }

  route {
    name                   = "${var.prefix}-WAFToDB"
    address_prefix         = "172.30.103.0/24"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.cgf_a_ipaddress}"
  }
}

resource "azurerm_route_table" "dbroute" {
  name                = "${var.prefix}-RT-DB"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.resourcegroupvnet.name}"

  route {
    name                   = "${var.prefix}-DBToInternet"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.cgf_a_ipaddress}"
  }

  route {
    name                   = "${var.prefix}-DBToWAF"
    address_prefix         = "172.30.101.0/24"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.cgf_a_ipaddress}"
  }

  route {
    name                   = "${var.prefix}-DBToWEB"
    address_prefix         = "172.30.102.0/24"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.cgf_a_ipaddress}"
  }
}
