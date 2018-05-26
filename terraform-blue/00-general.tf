##############################################################################################################
#  _                         
# |_) _  __ __ _  _     _| _ 
# |_)(_| |  | (_|(_ |_|(_|(_|
#                                                    
# Terraform configuration for Blue/Green deployment: Variables
#
##############################################################################################################

# Prefix for all resources created for this deployment in Microsoft Azure
variable "PREFIX" {
  description = "The shortened abbreviation to represent deployment that will go on the front of some resources."
}

# SSH key used for the backend web and sql server
variable "SSH_KEY_DATA" {}

# Static password used for CGF, WAF and SQL database
variable "PASSWORD" {}

# Barracuda Firewall Control Center Secret for deployment
variable "CCSECRET" {
  description = "Barracuda Firewall Control Center Secret"
}

# Barracuda Firewall Control Center Public IP to fetch the configuration PAR file
variable "CCIPADDRESS" {
  description = "Barracuda Firewall Control Center IP Address"
}

# Barracuda Firewall Control Center Range identifier
variable "CCRANGEID" {
  description = "Barracuda Firewall Control Center Range ID"
}

# Barracuda Firewall Control Center Cluster identifier
#  description = "Barracuda Firewall Control Center Cluster Name"
variable "CCCLUSTERNAME" {}

# Barracuda Firewall Control Center Firewall identifier
variable "CGFVMNAME" {
  description = "CloudGen Firewall Name"
}

variable "WAF_LICENSE_TOKENS" {
  description = "Array of license tokens for CloudGen WAF"
  type        = "list"
}

##############################################################################################################
# Microsoft Azure Storage Account for storage of Terraform state file
##############################################################################################################

terraform {
  required_version = ">= 0.11"

  backend "azurerm" {}
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

variable "network_cudalab" {
  description = ""
  default     = "172.31.0.0/16"
}

variable "vnet" {
  description = ""
  default     = "172.30.104.0/24"
}

variable "subnet_cgf" {
  description = ""
  default     = "172.30.104.0/26"
}

variable "subnet_waf" {
  description = ""
  default     = "172.30.104.64/26"
}

variable "subnet_web" {
  description = ""
  default     = "172.30.104.128/26"
}

variable "subnet_db" {
  description = ""
  default     = "172.30.104.192/26"
}

variable "cgf_a_ipaddress" {
  description = ""
  default     = "172.30.104.10"
}

variable "cgf_subnetmask" {
  description = ""
  default     = "24"
}

variable "cgf_defaultgateway" {
  description = ""
  default     = "172.30.104.1"
}

variable "cgf_vmsize" {
  description = ""
  default     = "Standard_DS1"
}

variable "waf_ip_addresses" {
  default = [
    "172.30.104.70",
    "172.30.104.71",
  ]
}

variable "waf_subnetmask" {
  description = ""
  default     = "24"
}

variable "waf_defaultgateway" {
  description = ""
  default     = "172.30.104.65"
}

variable "waf_vmsize" {
  description = ""
  default     = "Standard_DS1"
}

variable "web_ipaddress" {
  description = ""
  default     = "172.30.104.132"
}

variable "sql_ipaddress" {
  description = ""
  default     = "172.30.104.196"
}

##############################################################################################################

