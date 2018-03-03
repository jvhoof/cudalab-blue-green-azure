resource "azurerm_resource_group" "resourcegroupwaf" {
  name     = "${var.prefix}-RG-WAF"
  location = "${var.location}"
}

resource "azurerm_availability_set" "wafavset" {
  name                = "${var.prefix}-WAF-AVSET"
  location            = "${var.location}"
  managed             = true
  resource_group_name = "${azurerm_resource_group.resourcegroupwaf.name}"
}

resource "azurerm_public_ip" "waflbpip" {
  name                         = "${var.prefix}-LB-WAF-PIP"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.resourcegroupwaf.name}"
  public_ip_address_allocation = "static"
  domain_name_label            = "${format("%s%s", lower(var.prefix), "-waf-pip")}"
}

resource "azurerm_lb" "waflb" {
  name                = "${var.prefix}-LB-WAF"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.resourcegroupwaf.name}"

  frontend_ip_configuration {
    name                 = "${var.prefix}-LB-WAF-PIP"
    public_ip_address_id = "${azurerm_public_ip.waflbpip.id}"
  }
}

resource "azurerm_lb_backend_address_pool" "waflbbackend" {
  resource_group_name = "${azurerm_resource_group.resourcegroupwaf.name}"
  loadbalancer_id     = "${azurerm_lb.waflb.id}"
  name                = "BackEndAddressPool"
}

resource "azurerm_lb_probe" "waflbprobe" {
  resource_group_name = "${azurerm_resource_group.resourcegroupwaf.name}"
  loadbalancer_id     = "${azurerm_lb.waflb.id}"
  name                = "HTTP-PROBE"
  port                = 80
}

resource "azurerm_lb_rule" "waflbrulehttp" {
  resource_group_name            = "${azurerm_resource_group.resourcegroupwaf.name}"
  loadbalancer_id                = "${azurerm_lb.waflb.id}"
  name                           = "HTTP"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "${var.prefix}-LB-WAF-PIP"
  probe_id                       = "${azurerm_lb_probe.waflbprobe.id}"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.waflbbackend.id}"
}

resource "azurerm_lb_rule" "waflbrulehttps" {
  resource_group_name            = "${azurerm_resource_group.resourcegroupwaf.name}"
  loadbalancer_id                = "${azurerm_lb.waflb.id}"
  name                           = "HTTPS"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "${var.prefix}-LB-WAF-PIP"
  probe_id                       = "${azurerm_lb_probe.waflbprobe.id}"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.waflbbackend.id}"
}

resource "azurerm_lb_nat_rule" "wafmgmthttpa" {
  resource_group_name = "${azurerm_resource_group.resourcegroupwaf.name}"
  loadbalancer_id = "${azurerm_lb.waflb.id}"
  name = "MGMThttpA"
  protocol = "Tcp"
  frontend_port = 8000
  backend_port = 8000
  frontend_ip_configuration_name = "${var.prefix}-LB-WAF-PIP"
}

resource "azurerm_lb_nat_rule" "wafmgmthttpsa" {
  resource_group_name = "${azurerm_resource_group.resourcegroupwaf.name}"
  loadbalancer_id = "${azurerm_lb.waflb.id}"
  name = "MGMThttpsA"
  protocol = "Tcp"
  frontend_port = 8443
  backend_port = 8443
  frontend_ip_configuration_name = "${var.prefix}-LB-WAF-PIP"
}

resource "azurerm_lb_nat_rule" "wafmgmthttpb" {
  resource_group_name = "${azurerm_resource_group.resourcegroupwaf.name}"
  loadbalancer_id = "${azurerm_lb.waflb.id}"
  name = "MGMThttpB"
  protocol = "Tcp"
  frontend_port = 8001
  backend_port = 8000
  frontend_ip_configuration_name = "${var.prefix}-LB-WAF-PIP"
}

resource "azurerm_lb_nat_rule" "wafmgmthttpsb" {
  resource_group_name = "${azurerm_resource_group.resourcegroupwaf.name}"
  loadbalancer_id = "${azurerm_lb.waflb.id}"
  name = "MGMThttpsB"
  protocol = "Tcp"
  frontend_port = 8444
  backend_port = 8443
  frontend_ip_configuration_name = "${var.prefix}-LB-WAF-PIP"
}

resource "azurerm_network_interface" "wafifca" {
  name                  = "${var.prefix}-VM-WAF-A-IFC"
  location              = "${azurerm_resource_group.resourcegroupwaf.location}"
  resource_group_name   = "${azurerm_resource_group.resourcegroupwaf.name}"

  ip_configuration {
    name                                    = "interface1"
    subnet_id                               = "${azurerm_subnet.subnet2.id}"
    private_ip_address_allocation           = "static"
    private_ip_address                      = "${var.waf_a_ipaddress}"
    load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.waflbbackend.id}"]
    load_balancer_inbound_nat_rules_ids = ["${azurerm_lb_nat_rule.wafmgmthttpa.id}", "${azurerm_lb_nat_rule.wafmgmthttpsa.id}" ]
  }
}

resource "azurerm_network_interface" "wafifcb" {
  name                  = "${var.prefix}-VM-WAF-B-IFC"
  location              = "${azurerm_resource_group.resourcegroupwaf.location}"
  resource_group_name   = "${azurerm_resource_group.resourcegroupwaf.name}"

  ip_configuration {
    name                                    = "interface1"
    subnet_id                               = "${azurerm_subnet.subnet2.id}"
    private_ip_address_allocation           = "static"
    private_ip_address                      = "${var.waf_b_ipaddress}"
    load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.waflbbackend.id}"]
    load_balancer_inbound_nat_rules_ids = ["${azurerm_lb_nat_rule.wafmgmthttpb.id}", "${azurerm_lb_nat_rule.wafmgmthttpsb.id}" ]
  }
}

resource "azurerm_virtual_machine" "wafvma" {
  name                  = "${var.prefix}-VM-WAF-A"
  location              = "${azurerm_resource_group.resourcegroupwaf.location}"
  resource_group_name   = "${azurerm_resource_group.resourcegroupwaf.name}"
  network_interface_ids = ["${azurerm_network_interface.wafifca.id}"]
  vm_size               = "${var.waf_vmsize}"
  availability_set_id   = "${azurerm_availability_set.wafavset.id}"

  storage_image_reference {
    publisher = "barracudanetworks"
    offer     = "waf"
    sku       = "byol"
    version   = "latest"
  }

  plan {
    publisher = "barracudanetworks"
    product   = "waf"
    name      = "byol"
  }

  storage_os_disk {
    name              = "${var.prefix}-VM-WAF-A-OSDISK"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.prefix}-VM-WAF-B"
    admin_username = "azureuser"
    admin_password = "${var.password}"
  }

  os_profile_linux_config { 
    disable_password_authentication = false 
  }

  tags {
    environment = "staging"
  }
}

resource "azurerm_virtual_machine" "wafvmb" {
  name                  = "${var.prefix}-VM-WAF-B"
  location              = "${azurerm_resource_group.resourcegroupwaf.location}"
  resource_group_name   = "${azurerm_resource_group.resourcegroupwaf.name}"
  network_interface_ids = ["${azurerm_network_interface.wafifcb.id}"]
  vm_size               = "${var.waf_vmsize}"
  availability_set_id   = "${azurerm_availability_set.wafavset.id}"

  storage_image_reference {
    publisher = "barracudanetworks"
    offer     = "waf"
    sku       = "byol"
    version   = "latest"
  }

  plan {
    publisher = "barracudanetworks"
    product   = "waf"
    name      = "byol"
  }

  storage_os_disk {
    name              = "${var.prefix}-VM-WAF-B-OSDISK"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.prefix}-VM-WAF-B"
    admin_username = "azureuser"
    admin_password = "${var.password}"
  }

  os_profile_linux_config { 
    disable_password_authentication = false 
  }

  tags {
    environment = "staging"
  }
}