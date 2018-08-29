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

variable "DEPLOYMENTCOLOR" {
  description = "Selecting the correct deployment."
  default     = "blue"
}

variable "LOCATION" {
  description = "The name of the resource group in which to create the virtual network."
}

# SSH public key used for the backend web and sql server
variable "SSH_KEY_DATA" {}

# Static password used for CGF, WAF and SQL database
variable "PASSWORD" {}

# Static password used for SQL database
variable "DB_PASSWORD" {}

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
# Barracuda License type selection
##############################################################################################################

# This variable defined the type of CGF and billing used. For BYOL you can use pool licenses for repeated deployments.
variable "CGFIMAGESKU" {
  description = "Azure Marketplace Image SKU hourly (PAYG) or byol (Bring your own license)"
  default = "payg"
}

# This variable defined the type of WAF and billing used. For BYOL you can use pool licenses for repeated deployments.
variable "WAFIMAGESKU" {
  description = "Azure Marketplace Image SKU hourly (PAYG) or byol (Bring your own license)"
  default = "payg"
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

variable "AZURE_SUBSCRIPTION_ID" {}
variable "AZURE_CLIENT_ID" {}
variable "AZURE_CLIENT_SECRET" {}
variable "AZURE_TENANT_ID" {}

provider "azurerm" {
  subscription_id = "${var.AZURE_SUBSCRIPTION_ID}"
  client_id       = "${var.AZURE_CLIENT_ID}"
  client_secret   = "${var.AZURE_CLIENT_SECRET}"
  tenant_id       = "${var.AZURE_TENANT_ID}"
}

##############################################################################################################
# Static variables
##############################################################################################################

variable "network_cudalab" {
  description = ""
  default     = "172.31.0.0/16"
}

variable "vnet" {
  type        = "map"
  description = ""

  default = {
    "blue"  = "172.30.104.0/24"
    "green" = "172.30.105.0/24"
  }
}

variable "subnet_cgf" {
  type        = "map"
  description = ""

  default = {
    "blue"  = "172.30.104.0/26"
    "green" = "172.30.105.0/26"
  }
}

variable "subnet_waf" {
  type        = "map"
  description = ""

  default = {
    "blue"  = "172.30.104.64/26"
    "green" = "172.30.105.64/26"
  }
}

variable "subnet_web" {
  type        = "map"
  description = ""

  default = {
    "blue"  = "172.30.104.128/26"
    "green" = "172.30.105.128/26"
  }
}

variable "subnet_db" {
  type        = "map"
  description = ""

  default = {
    "blue"  = "172.30.104.192/26"
    "green" = "172.30.105.192/26"
  }
}

variable "cgf_a_ipaddress" {
  type        = "map"
  description = ""

  default = {
    "blue"  = "172.30.104.10"
    "green" = "172.30.105.10"
  }
}

variable "cgf_subnetmask" {
  type        = "map"
  description = ""

  default = {
    "blue"  = "24"
    "green" = "24"
  }
}

variable "cgf_defaultgateway" {
  type        = "map"
  description = ""

  default = {
    "blue"  = "172.30.104.10"
    "green" = "172.30.105.10"
  }
}

variable "cgf_vmsize" {
  type        = "map"
  description = ""

  default = {
    "blue"  = "Standard_DS1"
    "green" = "Standard_DS1"
  }
}

variable "waf_ip_addresses" {
  type        = "map"
  description = ""

  default = {
    "blue"  = ["172.30.104.70"]
    "green" = ["172.30.105.70"]
  }
}

variable "waf_subnetmask" {
  type        = "map"
  description = ""

  default = {
    "blue"  = ["24"]
    "green" = ["24"]
  }
}

variable "waf_defaultgateway" {
  type        = "map"
  description = ""

  default = {
    "blue"  = ["172.30.104.65"]
    "green" = ["172.30.105.65"]
  }
}

variable "waf_vmsize" {
  type        = "map"
  description = ""

  default = {
    "blue"  = "Standard_DS1"
    "green" = "Standard_DS1"
  }
}

variable "web_ipaddress" {
  type        = "map"
  description = ""

  default = {
    "blue"  = "172.30.104.132"
    "green" = "172.30.105.132"
  }
}

variable "sql_ipaddress" {
  type        = "map"
  description = ""

  default = {
    "blue"  = "172.30.104.196"
    "green" = "172.30.105.196"
  }
}

##############################################################################################################

