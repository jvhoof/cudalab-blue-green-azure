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

PLAN="terraform.tfplan"
PLANATM="terraform-atm.tfplan"
ANSIBLEINVENTORYDIR="ansible/inventory"
ANSIBLEWAFINVENTORYDIR="ansible-waf/inventory"
ANSIBLEINVENTORY="$ANSIBLEINVENTORYDIR/all"
ANSIBLEWEBINVENTORY="$ANSIBLEINVENTORYDIR/web"
ANSIBLESQLINVENTORY="$ANSIBLEINVENTORYDIR/sql"
ANSIBLEWAFINVENTORY="$ANSIBLEWAFINVENTORYDIR/waf"

while getopts "a:b:c:d:p:s:v:w:x:y:z:" option; do
    case "${option}" in
        a) ANSIBLEOPTS="$OPTARG" ;;
        b) BACKEND_ARM_ACCESS_KEY="$OPTARG" ;;
        c) CCSECRET="$OPTARG" ;;
        d) DB_PASSWORD="$OPTARG" ;;
        p) PASSWORD="$OPTARG" ;;
        s) SSH_KEY_DATA="$OPTARG" ;;
        v) AZURE_CLIENT_ID="$OPTARG" ;;
        w) AZURE_CLIENT_SECRET="$OPTARG" ;;
        x) AZURE_SUBSCRIPTION_ID="$OPTARG" ;;
        y) AZURE_TENANT_ID="$OPTARG" ;;
        z) DEPLOYMENTCOLOR="$OPTARG"; ;;
    esac
done

echo ""
echo "==> Deployment of the [$DEPLOYMENTCOLOR] environment"
echo ""
SUMMARY="summary-$DEPLOYMENTCOLOR.out"

echo ""
echo "==> Verifying SSH key location and permissions"
echo ""
chmod 700 `dirname $DOWNLOADSECUREFILE1_SECUREFILEPATH`
chmod 600 $DOWNLOADSECUREFILE1_SECUREFILEPATH

echo ""
echo "==> Starting Terraform deployment"
echo ""
cd terraform/

echo ""
echo "==> Terraform init"
echo ""
terraform init \
  -backend-config="storage_account_name=$BACKEND_STORAGE_ACCOUNT_NAME" \
  -backend-config="container_name=$BACKEND_CONTAINER_NAME" \
  -backend-config="key=$BACKEND_KEY_COLOR" \
  -backend-config="access_key=$BACKEND_ARM_ACCESS_KEY" \

echo ""
echo "==> Terraform workspace [$DEPLOYMENTCOLOR]"
echo ""
terraform workspace list
terraform workspace select $DEPLOYMENTCOLOR || terraform workspace new $DEPLOYMENTCOLOR

echo ""
echo "==> Terraform plan"
echo ""
terraform plan --out "$PLAN" \
                -var "CCSECRET=$CCSECRET" \
                -var "PASSWORD=$PASSWORD" \
                -var "SSH_KEY_DATA=$SSH_KEY_DATA" \
                -var "DB_PASSWORD=$DB_PASSWORD" \
                -var "AZURE_CLIENT_ID=$AZURE_CLIENT_ID" \
                -var "AZURE_CLIENT_SECRET=$AZURE_CLIENT_SECRET" \
                -var "AZURE_SUBSCRIPTION_ID=$AZURE_SUBSCRIPTION_ID" \
                -var "AZURE_TENANT_ID=$AZURE_TENANT_ID" \
                -var "DEPLOYMENTCOLOR=$DEPLOYMENTCOLOR" 

echo ""
echo "==> Terraform apply"
echo ""
terraform apply "$PLAN"

echo ""
echo "==> Terraform graph"
echo ""
terraform graph | dot -Tsvg > "../output/graph-$DEPLOYMENTCOLOR.svg"

echo ""
echo "==> Creating inventory directories for Ansible"
echo ""
mkdir -p "../$ANSIBLEINVENTORYDIR"
mkdir -p "../$ANSIBLEWAFINVENTORYDIR"

echo ""
echo "==> Terraform output to Ansible inventory"
echo ""
terraform output ansible_inventory > "../$ANSIBLEINVENTORY"

echo ""
echo "==> Terraform output deployment summary"
echo ""
terraform output deployment_summary > "../output/$SUMMARY"

cd ../
echo ""
echo "==> Ansible configuration"
echo ""
ansible-playbook ansible/all.yml $ANSIBLEOPTS -i "$ANSIBLEINVENTORY" 

echo ""
echo "==> Connectivity verification $DEPLOYMENTCOLOR environment"
echo ""

cd terraform-atm/
echo ""
echo "==> Switch to $DEPLOYMENTCOLOR environment"
echo ""
echo ""
echo "==> Terraform init"
echo ""
echo "BACKEND_STORAGE_ACCOUNT_NAME: [$BACKEND_STORAGE_ACCOUNT_NAME]"
terraform init \
  -backend-config="storage_account_name=$BACKEND_STORAGE_ACCOUNT_NAME" \
  -backend-config="container_name=$BACKEND_CONTAINER_NAME" \
  -backend-config="key=$BACKEND_KEY_TM" \
  -backend-config="access_key=$BACKEND_ARM_ACCESS_KEY" 

echo ""
echo "==> Terraform plan"
echo ""
terraform plan --out "$PLANATM" \
                -var "CCSECRET=$CCSECRET" \
                -var "PASSWORD=$PASSWORD" \
                -var "SSH_KEY_DATA=$SSH_KEY_DATA" \
                -var "AZURE_CLIENT_ID=$AZURE_CLIENT_ID" \
                -var "AZURE_CLIENT_SECRET=$AZURE_CLIENT_SECRET" \
                -var "AZURE_SUBSCRIPTION_ID=$AZURE_SUBSCRIPTION_ID" \
                -var "AZURE_TENANT_ID=$AZURE_TENANT_ID" \
                -var "DEPLOYMENTCOLOR=$DEPLOYMENTCOLOR"

echo ""
echo "==> Terraform apply"
echo ""
terraform apply "$PLANATM"
