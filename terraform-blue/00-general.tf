##############################################################################################################
#  _                         
# |_) _  __ __ _  _     _| _ 
# |_)(_| |  | (_|(_ |_|(_|(_|
#                                                    
# Terraform configuration for Blue/Green deployment: Variables
#
##############################################################################################################

# Prefix for all resources created for this deployment in Microsoft Azure
variable "prefix" {
  description = "The shortened abbreviation to represent deployment that will go on the front of some resources."
}

# SSH key used for the backend web and sql server
variable "ssh_key_data" {}

# Static password used for CGF, WAF and SQL database
variable "password" {}

# Barracuda Firewall Control Center Secret for deployment
variable "ccSecret" {
  description = "Barracuda Firewall Control Center Secret"
}

# Barracuda Firewall Control Center Public IP to fetch the configuration PAR file
variable "ccIpAddress" {
  description = "Barracuda Firewall Control Center IP Address"
}

# Barracuda Firewall Control Center Range identifier
variable "ccRangeId" {
  description = "Barracuda Firewall Control Center Range ID"
}

# Barracuda Firewall Control Center Cluster identifier
#  description = "Barracuda Firewall Control Center Cluster Name"
variable "ccClusterName" {}

# Barracuda Firewall Control Center Firewall identifier
variable "cgfVmName" {
  description = "CloudGen Firewall Name"
}

##############################################################################################################
# Microsoft Azure Service Principle information for deployment
##############################################################################################################

variable "SUBSCRIPTION_ID" {}
variable "CLIENT_ID" {}
variable "CLIENT_SECRET" {}
variable "TENANT_ID" {}

provider "azurerm" {
  subscription_id = "${var.SUBSCRIPTION_ID}"
  client_id       = "${var.CLIENT_ID}"
  client_secret   = "${var.CLIENT_SECRET}"
  tenant_id       = "${var.TENANT_ID}"
}

##############################################################################################################
# Static variables
##############################################################################################################

variable "location" {
  description = "The name of the resource group in which to create the virtual network."
  default     = "East US 2"
}

variable "vnet" {
  description = ""
  default     = "172.30.100.0/22"
}

variable "subnet_cgf" {
  description = ""
  default     = "172.30.100.0/24"
}

variable "subnet_waf" {
  description = ""
  default     = "172.30.101.0/24"
}

variable "subnet_web" {
  description = ""
  default     = "172.30.102.0/24"
}

variable "subnet_db" {
  description = ""
  default     = "172.30.103.0/24"
}

variable "cgf_a_ipaddress" {
  description = ""
  default     = "172.30.100.10"
}

variable "cgf_subnetmask" {
  description = ""
  default     = "24"
}

variable "cgf_defaultgateway" {
  description = ""
  default     = "172.30.100.1"
}

variable "cgf_vmsize" {
  description = ""
  default     = "Standard_DS1"
}

variable "waf_ip_addresses" {
  default = [
    "172.30.101.10",
    "172.30.101.11",
  ]
}

variable "waf_subnetmask" {
  description = ""
  default     = "24"
}

variable "waf_defaultgateway" {
  description = ""
  default     = "172.30.101.1"
}

variable "waf_vmsize" {
  description = ""
  default     = "Standard_DS1"
}

variable "web_ipaddress" {
  description = ""
  default     = "172.30.102.10"
}

variable "sql_ipaddress" {
  description = ""
  default     = "172.30.103.10"
}

##############################################################################################################

