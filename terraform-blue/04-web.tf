##############################################################################################################
#  _                         
# |_) _  __ __ _  _     _| _ 
# |_)(_| |  | (_|(_ |_|(_|(_|
#                                                    
# Terraform configuration for Blue/Green deployment: Web Server
#
##############################################################################################################

resource "azurerm_resource_group" "resourcegroupweb" {
  name     = "${var.PREFIX}-RG-WEB"
  location = "${var.location}"
}

resource "azurerm_network_interface" "webifc" {
  name                 = "${var.PREFIX}-VM-WEB-IFC"
  location             = "${azurerm_resource_group.resourcegroupweb.location}"
  resource_group_name  = "${azurerm_resource_group.resourcegroupweb.name}"
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "interface1"
    subnet_id                     = "${azurerm_subnet.subnet3.id}"
    private_ip_address_allocation = "static"
    private_ip_address            = "${var.web_ipaddress}"
  }
}

resource "azurerm_virtual_machine" "webvm" {
  name                  = "${var.PREFIX}-VM-WEB"
  location              = "${azurerm_resource_group.resourcegroupweb.location}"
  resource_group_name   = "${azurerm_resource_group.resourcegroupweb.name}"
  network_interface_ids = ["${azurerm_network_interface.webifc.id}"]
  vm_size               = "Standard_DS1"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.PREFIX}-VM-WEB-OSDISK"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.PREFIX}-VM-WEB"
    admin_username = "azureuser"
    admin_password = "${var.PASSWORD}"
  }

  os_profile_linux_config {
    disable_password_authentication = false

    ssh_keys {
      path     = "/home/azureuser/.ssh/authorized_keys"
      key_data = "${var.ssh_key_data}"
    }
  }

  tags {
    environment = "staging"
  }
}

data "template_file" "web_ansible" {
  count    = 1
  template = "${file("${path.module}/ansible_host.tpl")}"

  vars {
    name      = "${var.PREFIX}-VM-WEB"
    arguments = "ansible_host=${element(split(",",azurerm_network_interface.webifc.private_ip_address),count.index)} gather_facts=no"
  }

  depends_on = ["azurerm_virtual_machine.webvm"]
}

data "template_file" "web_ansible_inventory" {
  template = "${file("${path.module}/ansible_inventory_web.tpl")}"

  vars {
    env       = "production"
    web_hosts = "${join("\n",data.template_file.web_ansible.*.rendered)}"
  }

  depends_on = ["azurerm_virtual_machine.webvm"]
}

output "web_private_ip_address" {
  value = "${azurerm_network_interface.webifc.private_ip_address}"
}

output "web_ansible_inventory" {
  value = "${data.template_file.web_ansible_inventory.rendered}"
}
