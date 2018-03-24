variable "location" {
  description = "The name of the resource group in which to create the virtual network."
  default     = "East US 2"
}

variable "prefix" {
  description = "The shortened abbreviation to represent your resource group that will go on the front of some resources."
  default     = "JVH100"
}

variable "vnet" {
  description = ""
  default     = "172.30.100.0/22"
}

variable "subnet_ngf" {
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

variable "ngf_a_ipaddress" {
  description = ""
  default     = "172.30.100.10"
}

/*
variable "ngf_b_ipaddress" {
    description = ""
    default = "172.30.100.11"
}
*/

variable "ngf_subnetmask" {
  description = ""
  default     = "24"
}

variable "ngf_defaultgateway" {
  description = ""
  default     = "172.30.100.1"
}

variable "ngf_vmsize" {
  description = ""
  default     = "Standard_DS1"
}

variable "waf_a_ipaddress" {
  description = ""
  default     = "172.30.101.10"
}

variable "waf_b_ipaddress" {
  description = ""
  default     = "172.30.101.11"
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

variable "admin_password" {
  description = "administrator password"
  default     = "Q1w2e34567890--"
}

variable "ccSecret" {
  description = "Next Gen Control Center Secret"
  default     = "Q1w2e34567890--"
}

variable "ccIpAddress" {
  description = "Next Gen Control Center IP Address"
  default     = "64.235.148.20"
}

variable "ccRangeId" {
  description = "Next Gen Control Center Range ID"
  default     = "98"
}

variable "ccClusterName" {
  description = "Next Gen Control Center Cluster Name"
  default     = "jvanhoof"
}

variable "fwVmName" {
  description = "NextGen Firewall F-Series Name"
  default     = "CUDALAB-NGF"
}

variable "web_ipaddress" {
  description = ""
  default     = "172.30.102.10"
}

variable "web_ipaddress2" {
  description = ""
  default     = "172.30.102.11"
}

variable "web_ipaddress3" {
  description = ""
  default     = "172.30.102.12"
}

variable "web_ipaddress4" {
  description = ""
  default     = "172.30.102.13"
}

variable "sql_ipaddress" {
  description = ""
  default     = "172.30.103.10"
}

variable "SUBSCRIPTION_ID" {}
variable "CLIENT_ID" {}
variable "CLIENT_SECRET" {}
variable "TENANT_ID" {}
