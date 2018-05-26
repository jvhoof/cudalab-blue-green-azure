#!/bin/bash
echo "
##############################################################################################################
#  _                         
# |_) _  __ __ _  _     _| _ 
# |_)(_| |  | (_|(_ |_|(_|(_|
#
# Deployment of CUDALAB EU configuration in Microsoft Azure using Terraform and Ansible
#
##############################################################################################################
"

# Stop running when command returns error
set -e

#SECRET="/ssh/secrets.tfvars"
#STATE="terraform.tfstate"

while getopts "b:" option; do
    case "${option}" in
        b) BACKEND_ARM_ACCESS_KEY="$OPTARG" ;;
    esac
done

echo ""
echo "==> Terraform init"
echo ""
echo "BACKEND_STORAGE_ACCOUNT_NAME: [$BACKEND_STORAGE_ACCOUNT_NAME]"
#terraform init -backend-config=terraform-blue/backend-blue.tfvars -backend_config="access_key=$BACKEND_ARM_ACCESS_KEY" terraform-blue/
terraform init \
  -backend-config="storage_account_name=$BACKEND_STORAGE_ACCOUNT_NAME" \
  -backend-config="container_name=$BACKEND_CONTAINER_NAME" \
  -backend-config="key=$BACKEND_KEY" \
  -backend-config="access_key=$BACKEND_ARM_ACCESS_KEY" \
  terraform-blue/

echo ""
echo "==> Terraform destory"
echo ""
terraform destroy terraform-blue/
