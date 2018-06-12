##############################################################################################################
#  _                         
# |_) _  __ __ _  _     _| _ 
# |_)(_| |  | (_|(_ |_|(_|(_|
#                                                    
# Terraform configuration for Blue/Green deployment: SQL Server
#
##############################################################################################################

data "template_file" "summary" {
  template = <<EOF
# CUDALAB Deployment [$${deploymentcolor}] in [$${location}]
cgf_lb_public_ip_address : $${cgf_lb_public_ip_address}
cgf_lb_domain_name_label : $${cgf_lb_domain_name_label}
cgf_a_public_ip_address  : $${cgf_a_public_ip_address}
cgf_private_ip_address   : $${cgf_a_private_ip_address}
waf_lb_public_ip_address : $${waf_lb_public_ip_address}
waf_lb_domain_name_label : $${waf_lb_domain_name_label}
waf_private_ip_address   : $${waf_private_ip_address}
web_private_ip_address   : $${web_private_ip_address}
sql_private_ip_address   : $${sql_private_ip_address}
EOF

  vars {
    deploymentcolor          = "${var.DEPLOYMENTCOLOR}"
    location                 = "${var.LOCATION}"
    cgf_lb_public_ip_address = "${data.azurerm_public_ip.cgflbpip.ip_address}"
    cgf_lb_domain_name_label = "${data.azurerm_public_ip.cgflbpip.domain_name_label}"
    cgf_a_public_ip_address  = "${data.azurerm_public_ip.cgfpipa.ip_address}"
    cgf_a_private_ip_address = "${azurerm_network_interface.cgfifca.private_ip_address}"
    waf_lb_public_ip_address = "${data.azurerm_public_ip.waflbpip.ip_address}"
    waf_lb_domain_name_label = "${data.azurerm_public_ip.waflbpip.domain_name_label}"
    waf_private_ip_address   = "${join(" - ",azurerm_network_interface.wafifc.*.private_ip_address)}"
    web_private_ip_address   = "${azurerm_network_interface.webifc.private_ip_address}"
    sql_private_ip_address   = "${azurerm_network_interface.sqlifc.private_ip_address}"
  }
}

output "deployment_summary" {
  value = "${data.template_file.summary.rendered}"
}
