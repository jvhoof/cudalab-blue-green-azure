resource "azurerm_resource_group" "resourcegroupwaf" {
  name     = "${var.prefix}-RG"
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
  depends_on                     = ["azurerm_lb_probe.waflbprobe"]
}

resource "azurerm_lb_nat_rule" "waflbnatrulehttp" {
  name                           = "MGMT-HTTP-WAF-${count.index}"
  count                          = "${length(var.waf_ip_addresses)}"
  loadbalancer_id                = "${azurerm_lb.waflb.id}"
  resource_group_name            = "${azurerm_resource_group.resourcegroupwaf.name}"
  protocol                       = "tcp"
  frontend_port                  = "${count.index + 8000}"
  backend_port                   = 8000
  frontend_ip_configuration_name = "${var.prefix}-LB-WAF-PIP"
}

resource "azurerm_lb_nat_rule" "waflbnatrulehttps" {
  name                           = "MGMT-HTTPS-WAF-${count.index}"
  count                          = "${length(var.waf_ip_addresses)}"
  loadbalancer_id                = "${azurerm_lb.waflb.id}"
  resource_group_name            = "${azurerm_resource_group.resourcegroupwaf.name}"
  protocol                       = "tcp"
  frontend_port                  = "${count.index + 8443}"
  backend_port                   = 8443
  frontend_ip_configuration_name = "${var.prefix}-LB-WAF-PIP"
}

resource "azurerm_network_interface" "wafifc" {
  name                = "${var.prefix}-VM-WAF-IFC-${count.index}"
  count               = "${length(var.waf_ip_addresses)}"
  location            = "${azurerm_resource_group.resourcegroupwaf.location}"
  resource_group_name = "${azurerm_resource_group.resourcegroupwaf.name}"

  ip_configuration {
    name                                    = "interface1"
    subnet_id                               = "${azurerm_subnet.subnet2.id}"
    private_ip_address_allocation           = "static"
    private_ip_address                      = "${element(var.waf_ip_addresses, count.index)}"
    load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.waflbbackend.id}"]
    load_balancer_inbound_nat_rules_ids     = ["${element(azurerm_lb_nat_rule.waflbnatrulehttp.*.id, count.index)}", "${element(azurerm_lb_nat_rule.waflbnatrulehttps.*.id, count.index)}"]
  }
}

resource "azurerm_virtual_machine" "wafvm" {
  name                  = "${var.prefix}-VM-WAF-${count.index}"
  count                 = "${length(var.waf_ip_addresses)}"
  location              = "${azurerm_resource_group.resourcegroupwaf.location}"
  resource_group_name   = "${azurerm_resource_group.resourcegroupwaf.name}"
  network_interface_ids = ["${element(azurerm_network_interface.wafifc.*.id, count.index)}"]
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
    name              = "${var.prefix}-VM-WAF-OSDISK-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.prefix}-VM-WAF-${count.index}"
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

data "template_file" "ansible_host" {
  count    = "${length(var.waf_ip_addresses)}"
  template = "${file("${path.module}/ansible_host.tpl")}"

  vars {
    name      = "${var.prefix}-VM-WAF-${count.index}"
    arguments = " ansible_host=${element(var.waf_ip_addresses, count.index)} gather_facts=no"
  }

  depends_on = ["azurerm_virtual_machine.wafvm"]
}

data "template_file" "waf_ansible_inventory" {
  template = "${file("${path.module}/ansible_inventory_waf.tpl")}"

  vars {
    env       = "production"
    waf_hosts = "${join("\n",data.template_file.ansible_host.*.rendered)}"
  }

  depends_on = ["azurerm_virtual_machine.wafvm"]
}

output "waf_private_ip_address" {
  value = "${azurerm_network_interface.wafifc.*.private_ip_address}"
}

output "waf_ansible_inventory" {
  value = "${data.template_file.ansible_inventory_waf.rendered}"
}
