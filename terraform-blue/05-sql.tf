resource "azurerm_resource_group" "resourcegroupsql" {
  name     = "${var.prefix}-RG-SQL"
  location = "${var.location}"
}

resource "azurerm_network_interface" "sqlifc" {
  name                 = "${var.prefix}-VM-SQL-IFC"
  location             = "${azurerm_resource_group.resourcegroupsql.location}"
  resource_group_name  = "${azurerm_resource_group.resourcegroupsql.name}"
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "interface1"
    subnet_id                     = "${azurerm_subnet.subnet4.id}"
    private_ip_address_allocation = "static"
    private_ip_address            = "${var.sql_ipaddress}"
  }
}

resource "azurerm_virtual_machine" "sqlvm" {
  name                  = "${var.prefix}-VM-SQL"
  location              = "${azurerm_resource_group.resourcegroupsql.location}"
  resource_group_name   = "${azurerm_resource_group.resourcegroupsql.name}"
  network_interface_ids = ["${azurerm_network_interface.sqlifc.id}"]
  vm_size               = "Standard_DS1"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.prefix}-VM-SQL-OSDISK"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.prefix}-VM-SQL"
    admin_username = "azureuser"
    admin_password = "${var.password}"
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

data "template_file" "sql_ansible" {
  count    = 1
  template = "${file("${path.module}/hostname.tpl")}"

  vars {
    index = "${count.index + 1}"
    name  = "sql"
    env   = "p"
    extra = " ansible_host=${element(split(",",azurerm_network_interface.sqlifc.private_ip_address),count.index)}"

    # extra = ""
  }

  depends_on = ["azurerm_virtual_machine.sqlvm"]
}

data "template_file" "sql_ansible_inventory" {
  template = "${file("${path.module}/ansible_sql_hosts.tpl")}"

  vars {
    env       = "production"
    sql_hosts = "${join("\n",data.template_file.sql_ansible.*.rendered)}"
  }

  depends_on = ["azurerm_virtual_machine.sqlvm"]
}

output "sql_private_ip_address" {
  value = "${azurerm_network_interface.sqlifc.private_ip_address}"
}

output "sql_ansible_inventory" {
  value = "${data.template_file.sql_ansible_inventory.rendered}"
}
