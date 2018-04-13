##############################################################################################################
#  _                         
# |_) _  __ __ _  _     _| _ 
# |_)(_| |  | (_|(_ |_|(_|(_|
#                                                    
# Terraform configuration for Blue/Green deployment: Barracuda CloudGen Firewall
#
##############################################################################################################

resource "azurerm_resource_group" "resourcegroupcgf" {
  name     = "${var.prefix}-RG-NGF"
  location = "${var.location}"
}

resource "azurerm_availability_set" "cgfavset" {
  name                = "${var.prefix}-NGF-AVSET"
  location            = "${var.location}"
  managed             = true
  resource_group_name = "${azurerm_resource_group.resourcegroupcgf.name}"
}

resource "azurerm_public_ip" "cgflbpip" {
  name                         = "${var.prefix}-LB-NGF-PIP"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.resourcegroupcgf.name}"
  public_ip_address_allocation = "static"
  domain_name_label            = "${format("%s%s", lower(var.prefix), "-cgf-pip")}"
}

resource "azurerm_lb" "cgflb" {
  name                = "${var.prefix}-LB-NGF"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.resourcegroupcgf.name}"

  frontend_ip_configuration {
    name                 = "${var.prefix}-LB-NGF-PIP"
    public_ip_address_id = "${azurerm_public_ip.cgflbpip.id}"
  }
}

resource "azurerm_lb_backend_address_pool" "cgflbbackend" {
  resource_group_name = "${azurerm_resource_group.resourcegroupcgf.name}"
  loadbalancer_id     = "${azurerm_lb.cgflb.id}"
  name                = "BackEndAddressPool"
}

resource "azurerm_lb_probe" "cgflbprobe" {
  resource_group_name = "${azurerm_resource_group.resourcegroupcgf.name}"
  loadbalancer_id     = "${azurerm_lb.cgflb.id}"
  name                = "TINA-TCP-PROBE"
  port                = 691
}

resource "azurerm_lb_rule" "cgflbruletinatcp" {
  resource_group_name            = "${azurerm_resource_group.resourcegroupcgf.name}"
  loadbalancer_id                = "${azurerm_lb.cgflb.id}"
  name                           = "TINA-TCP"
  protocol                       = "Tcp"
  frontend_port                  = 691
  backend_port                   = 691
  frontend_ip_configuration_name = "${var.prefix}-LB-NGF-PIP"
  probe_id                       = "${azurerm_lb_probe.cgflbprobe.id}"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.cgflbbackend.id}"
}

resource "azurerm_lb_rule" "cgflbruletinaudp" {
  resource_group_name            = "${azurerm_resource_group.resourcegroupcgf.name}"
  loadbalancer_id                = "${azurerm_lb.cgflb.id}"
  name                           = "TINA-UDP"
  protocol                       = "Udp"
  frontend_port                  = 691
  backend_port                   = 691
  frontend_ip_configuration_name = "${var.prefix}-LB-NGF-PIP"
  probe_id                       = "${azurerm_lb_probe.cgflbprobe.id}"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.cgflbbackend.id}"
}

resource "azurerm_lb_rule" "cgflbruleipsecike" {
  resource_group_name            = "${azurerm_resource_group.resourcegroupcgf.name}"
  loadbalancer_id                = "${azurerm_lb.cgflb.id}"
  name                           = "IPSEC-IKE"
  protocol                       = "Udp"
  frontend_port                  = 500
  backend_port                   = 500
  frontend_ip_configuration_name = "${var.prefix}-LB-NGF-PIP"
  probe_id                       = "${azurerm_lb_probe.cgflbprobe.id}"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.cgflbbackend.id}"
}

resource "azurerm_lb_rule" "cgflbruleipsecnatt" {
  resource_group_name            = "${azurerm_resource_group.resourcegroupcgf.name}"
  loadbalancer_id                = "${azurerm_lb.cgflb.id}"
  name                           = "IPSEC-NATT"
  protocol                       = "Udp"
  frontend_port                  = 4500
  backend_port                   = 4500
  frontend_ip_configuration_name = "${var.prefix}-LB-NGF-PIP"
  probe_id                       = "${azurerm_lb_probe.cgflbprobe.id}"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.cgflbbackend.id}"
}

resource "azurerm_public_ip" "cgfpipa" {
  name                         = "${var.prefix}-VM-NGF-A-PIP"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.resourcegroupcgf.name}"
  public_ip_address_allocation = "static"
}

resource "azurerm_network_interface" "cgfifca" {
  name                 = "${var.prefix}-VM-NGF-A-IFC"
  location             = "${azurerm_resource_group.resourcegroupcgf.location}"
  resource_group_name  = "${azurerm_resource_group.resourcegroupcgf.name}"
  enable_ip_forwarding = true

  ip_configuration {
    name                                    = "interface1"
    subnet_id                               = "${azurerm_subnet.subnet1.id}"
    private_ip_address_allocation           = "static"
    private_ip_address                      = "${var.cgf_a_ipaddress}"
    public_ip_address_id                    = "${azurerm_public_ip.cgfpipa.id}"
    load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.cgflbbackend.id}"]
  }
}

resource "azurerm_virtual_machine" "cgfvma" {
  name                  = "${var.prefix}-VM-NGF-A"
  location              = "${azurerm_resource_group.resourcegroupcgf.location}"
  resource_group_name   = "${azurerm_resource_group.resourcegroupcgf.name}"
  network_interface_ids = ["${azurerm_network_interface.cgfifca.id}"]
  vm_size               = "${var.cgf_vmsize}"
  availability_set_id   = "${azurerm_availability_set.cgfavset.id}"

  storage_image_reference {
    publisher = "barracudanetworks"
    offer     = "barracuda-ng-firewall"
    sku       = "byol"
    version   = "latest"
  }

  plan {
    publisher = "barracudanetworks"
    product   = "barracuda-ng-firewall"
    name      = "byol"
  }

  storage_os_disk {
    name              = "${var.prefix}-VM-NGF-A-OSDISK"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.prefix}-VM-NGF-A"
    admin_username = "azureuser"
    admin_password = "${var.password}"
    custom_data    = "${base64encode("#!/bin/bash\n\nCCSECRET=${var.ccSecret}\n\nCCIP=${var.ccIpAddress}\n\nCCRANGEID=${var.ccRangeId}\n\nCCCLUSTERNAME=${var.ccClusterName}\n\nCGFNAME=${var.cgfVmName}\n\n${file("${path.module}/provisioncgf.sh")}")}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags {
    environment = "staging"
  }
}