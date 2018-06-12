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
PLAN="terraform.tfplan"
PLANATM="terraform-atm.tfplan"
ANSIBLEINVENTORYDIR="ansible/inventory"
ANSIBLEWAFINVENTORYDIR="ansible-waf/inventory"
ANSIBLEWEBINVENTORY="$ANSIBLEINVENTORYDIR/web"
ANSIBLESQLINVENTORY="$ANSIBLEINVENTORYDIR/sql"
ANSIBLEWAFINVENTORY="$ANSIBLEWAFINVENTORYDIR/waf"

while getopts "a:b:c:d:p:s:z:" option; do
    case "${option}" in
        a) ANSIBLEOPTS="$OPTARG" ;;
        b) BACKEND_ARM_ACCESS_KEY="$OPTARG" ;;
        c) CCSECRET="$OPTARG" ;;
        d) DB_PASSWORD="$OPTARG" ;;
        p) PASSWORD="$OPTARG" ;;
        s) SSH_KEY_DATA="$OPTARG" ;;
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
echo "==> Terraform workspace [$DEPLOYMENTCOLOR]"
echo ""
terraform workspace list
terraform workspace select $DEPLOYMENTCOLOR || terraform workspace new $DEPLOYMENTCOLOR

echo ""
echo "==> Terraform init"
echo ""
terraform init \
  -backend-config="storage_account_name=$BACKEND_STORAGE_ACCOUNT_NAME" \
  -backend-config="container_name=$BACKEND_CONTAINER_NAME" \
  -backend-config="key=$BACKEND_KEY_COLOR" \
  -backend-config="access_key=$BACKEND_ARM_ACCESS_KEY" \
#  terraform/

echo ""
echo "==> Terraform plan"
echo ""
terraform plan --out "$PLAN" -var "CCSECRET=$CCSECRET" -var "PASSWORD=$PASSWORD" -var "SSH_KEY_DATA=$SSH_KEY_DATA" -var "DEPLOYMENTCOLOR=$DEPLOYMENTCOLOR" 
#terraform/

echo ""
echo "==> Terraform apply"
echo ""
terraform apply "$PLAN"

echo ""
echo "==> Terraform graph"
echo ""
terraform graph | dot -Tsvg > "../graph-$DEPLOYMENTCOLOR.svg"
#terraform graph terraform/ > "dot-$DEPLOYMENTCOLOR.dot"

echo ""
echo "==> Creating inventory directories for Ansible"
echo ""
mkdir -p $ANSIBLEINVENTORYDIR
mkdir -p $ANSIBLEWAFINVENTORYDIR

echo ""
echo "==> Terraform output to Ansible web inventory"
echo ""
terraform output web_ansible_inventory > "../$ANSIBLEWEBINVENTORY"

echo ""
echo "==> Terraform output to Ansible sql inventory"
echo ""
terraform output sql_ansible_inventory > "../$ANSIBLESQLINVENTORY"

echo ""
echo "==> Terraform output to Ansible waf inventory"
echo ""
terraform output waf_ansible_inventory > "../$ANSIBLEWAFINVENTORY"

echo ""
echo "==> Terraform output deployment summary"
echo ""
terraform output deployment_summary > "../$SUMMARY"

cd ../
echo ""
echo "==> Ansible configuration web server"
echo ""
echo "ansible-playbook ansible/web.yml $ANSIBLEOPTS -i \"$ANSIBLEWEBINVENTORY\""
ansible-playbook ansible/web.yml $ANSIBLEOPTS -i "$ANSIBLEWEBINVENTORY"

echo ""
echo "==> Ansible configuration sql server"
echo ""
ansible-playbook ansible/sql.yml $ANSIBLEOPTS -i "$ANSIBLESQLINVENTORY" --extra-vars "db_password=$DB_PASSWORD"

echo ""
echo "==> Ansible bootstrap waf server"
echo ""
ansible-playbook ansible-waf/bootstrap.yml $ANSIBLEOPTS -i "$ANSIBLEWAFINVENTORY"

echo ""
echo "==> Ansible configuration waf server"
echo ""
ansible-playbook ansible-waf/deploy.yml $ANSIBLEOPTS -i "$ANSIBLEWAFINVENTORY" --extra-vars "waf_password=$PASSWORD"

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
  -backend-config="access_key=$BACKEND_ARM_ACCESS_KEY" \

echo ""
echo "==> Terraform plan"
echo ""
terraform plan --out "$PLANATM" -var "CCSECRET=$CCSECRET" -var "PASSWORD=$PASSWORD" -var "SSH_KEY_DATA=$SSH_KEY_DATA" -var "DEPLOYMENTCOLOR=$DEPLOYMENTCOLOR"

echo ""
echo "==> Terraform apply"
echo ""
terraform apply "$PLANATM"
