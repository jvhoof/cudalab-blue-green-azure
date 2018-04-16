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
STATE="terraform.tfstate"
PLAN="terraform.plan"
ANSIBLEWEBINVENTORY="ansible-blue/inventory/web"
ANSIBLESQLINVENTORY="ansible-blue/inventory/sql"
ANSIBLEWAFINVENTORY="ansible-waf/inventory/waf"

TODAY=`date +"%Y-%m-%d"`

while getopts c:d:p:s option; do
    case "${option}" in
        c) CCSECRET=$OPTARG ;;
        d) DB_PASSWORD=$OPTARG ;;
        p) PASSWORD=$OPTARG ;;
        s) SSH_KEY_DATA=$OPTARG ;;
    esac
done

echo "==> Checking key data: $SSH_KEY_DATA"
echo "$SSH_KEY_DATA" > /tmp/key
echo ""
echo "==> Terraform init"
echo ""
terraform init terraform-blue/

echo ""
echo "==> Terraform plan"
echo ""
terraform plan -state="$STATE" --out "$PLAN" -var "CCSECRET=$CCSECRET" -var "PASSWORD=$PASSWORD" -var "SSH_KEY_DATA=$SSH_KEY_DATA" terraform-blue/

echo ""
echo "==> Terraform apply"
echo ""
terraform apply "$PLAN"

echo ""
echo "==> Terraform output to Ansible web inventory"
echo ""
terraform output -state="$STATE" web_ansible_inventory > "$ANSIBLEWEBINVENTORY"

echo ""
echo "==> Terraform output to Ansible sql inventory"
echo ""
terraform output -state="$STATE" sql_ansible_inventory > "$ANSIBLESQLINVENTORY"

echo ""
echo "==> Terraform output to Ansible waf inventory"
echo ""
terraform output -state="$STATE" waf_ansible_inventory > "$ANSIBLEWAFINVENTORY"

echo ""
echo "==> Ansible configuration web server"
echo ""
ansible-playbook ansible-blue/deploy-docker.yml -i "$ANSIBLEWEBINVENTORY"

echo ""
echo "==> Ansible configuration sql server"
echo ""
ansible-playbook ansible-blue/deploy-docker.yml -i "$ANSIBLESQLINVENTORY" --extra-vars "db_password=$DB_PASSWORD"

echo ""
echo "==> Ansible bootstrap waf server"
echo ""
#ansible-playbook ansible-waf/bootstrap.yml -i "$ANSIBLESQLINVENTORY"

echo ""
echo "==> Ansible configuration waf server"
echo ""
#ansible-playbook ansible-waf/deploy.yml -i "$ANSIBLEWAFINVENTORY"
