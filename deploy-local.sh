#!/bin/bash
echo "
##############################################################################################################
#  _                         
# |_) _  __ __ _  _     _| _ 
# |_)(_| |  | (_|(_ |_|(_|(_|
#
# Local deployment tests
#
##############################################################################################################
"

# Terraform state file in Azure Storage
BACKEND_ARM_ACCESS_KEY='AGeNHL5JEBQFomT5W+YazJGmzYJIu2JAMg1twOsic6La7Ccg0dlmeQdQZQuQ8SlXhl4BtF8hM+v71H1CcFWhLA=='
BACKEND_CONTAINER_NAME='cudalab-blue'
BACKEND_KEY='cudalabcicd-blue.tfstate'
BACKEND_STORAGE_ACCOUNT_NAME='cudalabcicd'

# Passwords
CCSECRET='Q1w2e34567890--'
DB_PASSWORD='Q1w2e34567890--'
PASSWORD='Q1w2e34567890--'
SSH_KEY_DATA='ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCv+GS5/x2zYlcGPkksiJCxyn8xKBSsPTljoHRHDINq9v/ADn92hXWudOPh07CTEgzdMVHKLSCmt7vtIY2oVdd2k8Q4Fej/cYw9el4shF6SNG8/68nuTkxn2Y6FyNTPjiblOKDv+DMQZPxddfkRx33HEFUwR1ClT0og2IoCxw1CaYN3CblZ2YHHeGRI7vZQ2//tn53IG3wtYMxCAKevrE8W6P1gC+qg+A7cUVsIyNT16JOkKJUT5Wsh/Epr7NyeFRbomnYVJEVZnFQsj84RbQvhCMxIHytcuBYlJ0sHfWwiksLGnP3MGPWtTZnpqiL134kzn94ng/Tb4hSAfhJmw4aT jvhoof@sarango'

# Deployment namingprefix
TF_VAR_prefix='JVH102'

# CGF CC data
TF_VAR_CCCLUSTERNAME='jvanhoof'
TF_VAR_CCIPADDRESS='64.235.148.20'
TF_VAR_CCRANGEID='98'
TF_VAR_CCFGVMNAME='CLOUD-AZURE-BLUE-CGF-A'

# Azure Credentials
TF_VAR_client_id='f693b7e5-b39a-44e1-8078-64d686ac2fc1'
TF_VAR_client_secret='9828a5f8-8d61-4e7b-a6fd-75a7dd8ae81a'
TF_VAR_subscription_id='31de56f1-2378-43ae-bdf7-2c229adf2f7f'
TF_VAR_tenant_id='4c2cee7c-97ca-4f42-88ea-6acf44978369'

# WAF License tokens
TF_VAR_waf_license_tokens='[ "613AE-2TX48-P5254", "AYCA3-19XA4-79XG3" ]'

# Secure files locations
DOWNLOADSECUREFILE1_SECUREFILEPATH='~/.ssh/cudalab/id_rsa_az'
DOWNLOADSECUREFILE2_SECUREFILEPATH='~/.ssh/cudalab/ssl/star_cudalab_eu.pfx'

echo ""
echo "==> Terraform init"
echo ""
terraform init \
  -backend-config="storage_account_name=$BACKEND_STORAGE_ACCOUNT_NAME" \
  -backend-config="container_name=$BACKEND_CONTAINER_NAME" \
  -backend-config="key=$BACKEND_KEY" \
  -backend-config="access_key=$BACKEND_ARM_ACCESS_KEY" \
  terraform-blue/

echo ""
echo "==> Terraform plan"
echo ""
terraform plan --out "$PLAN" -var "CCSECRET=$CCSECRET" -var "PASSWORD=$PASSWORD" -var "SSH_KEY_DATA=$SSH_KEY_DATA" terraform-blue/

echo ""
echo "==> Terraform apply"
echo ""
terraform apply "$PLAN"

echo ""
echo "==> Terraform graph"
echo ""
terraform graph terraform-blue/ | dot -Tsvg > blue-graph.svg

echo ""
echo "==> Creating inventory directories for Ansible"
echo ""
mkdir -p $ANSIBLEINVENTORYDIR
mkdir -p $ANSIBLEWAFINVENTORYDIR

echo ""
echo "==> Terraform output to Ansible web inventory"
echo ""
terraform output web_ansible_inventory > "$ANSIBLEWEBINVENTORY"

echo ""
echo "==> Terraform output to Ansible sql inventory"
echo ""
terraform output sql_ansible_inventory > "$ANSIBLESQLINVENTORY"

echo ""
echo "==> Terraform output to Ansible waf inventory"
echo ""
terraform output waf_ansible_inventory > "$ANSIBLEWAFINVENTORY"

echo ""
echo "==> Ansible configuration web server"
echo ""
#ansible-playbook ansible-blue/deploy.yml $ANSIBLEOPTS -i "$ANSIBLEWEBINVENTORY"

echo ""
echo "==> Ansible configuration sql server"
echo ""
#ansible-playbook ansible-blue/deploy.yml $ANSIBLEOPTS -i "$ANSIBLESQLINVENTORY" --extra-vars "db_password=$DB_PASSWORD"

echo ""
echo "==> Ansible bootstrap waf server"
echo ""
ansible-playbook ansible-blue-waf/bootstrap.yml $ANSIBLEOPTS -i "$ANSIBLEWAFINVENTORY"

echo ""
echo "==> Ansible configuration waf server"
echo ""
ansible-playbook ansible-blue-waf/deploy.yml $ANSIBLEOPTS -i "$ANSIBLEWAFINVENTORY" --extra-vars "waf_password=$PASSWORD"
