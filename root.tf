##############################################################################################################
# Microsoft Azure Storage Account for storage of Terraform state file 
# Workaround for some commands like output:
# https://github.com/hashicorp/terraform/issues/15761
##############################################################################################################

terraform {
  required_version = ">= 0.11"

  backend "azurerm" {}
}
