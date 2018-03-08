#!/bin/bash
cat << "EOF"
##############################################################################################################
#  ____                                      _       
# | __ )  __ _ _ __ _ __ __ _  ___ _   _  __| | __ _ 
# |  _ \ / _` | `__| `__/ _` |/ __| | | |/ _` |/ _` |
# | |_) | (_| | |  | | | (_| | (__| |_| | (_| | (_| |
# |____/ \__,_|_|  |_|  \__,_|\___|\__,_|\__,_|\__,_|
#                                                    
# Deployment of CUDALAB EU configuration in Microsoft Azure using Terraform and Ansible
#
##############################################################################################################
EOF

# Stop running when command returns error
set -e

#SECRET="/ssh/secrets.tfvars"
STATE="/tmp/terraform.tfstate"
ANSIBLEWEBINVENTORY="/data/ansible/inventory/web"

TODAY=`date +"%Y-%m-%d"`

echo "TF_VAR_ccsecret: $TF_VAR_ccsecret"
echo "Hello World"
echo "AGENT_WORKFOLDER is $AGENT_WORKFOLDER"
echo "AGENT_WORKFOLDER contents:"
ls -1 $AGENT_WORKFOLDER
echo "AGENT_BUILDDIRECTORY is $AGENT_BUILDDIRECTORY"
echo "AGENT_BUILDDIRECTORY contents:"
ls -1 $AGENT_BUILDDIRECTORY
echo "BUILD_SOURCESDIRECTORY is $BUILD_SOURCESDIRECTORY"
echo "BUILD_SOURCESDIRECTORY contents:"
ls -1 $BUILD_SOURCESDIRECTORY
echo "Over and out."

echo ""
echo "==> Terraform init"
echo ""
terraform init /data/terraform

#echo ""
#echo "==> Terraform plan"
#echo ""
#docker run --rm -itv $PWD:/data -v terraform-run:/.terraform/ -v ~/.ssh:/ssh/ jvhoof/ansible-docker terraform plan -state="$STATE" -var-file="$SECRET" /data/terraform

#echo ""
#echo "==> Terraform apply"
#echo ""
#docker run --rm -itv $PWD:/data -v terraform-run:/.terraform/ -v ~/.ssh:/ssh/ jvhoof/ansible-docker terraform apply -state="$STATE" -var-file="$SECRET" /data/terraform 

#echo ""
#echo "==> Terraform output to Ansible inventory"
#echo ""
#docker run --rm -itv $PWD:/data -v terraform-run:/.terraform/ -v ~/.ssh:/ssh/ jvhoof/ansible-docker sh -c "terraform output -state=\"$STATE\" ansible_web_inventory > \"$ANSIBLEWEBINVENTORY\""

#echo ""
#echo "==> Ansible configuration"
#echo ""
#docker run --rm -itv $PWD:/data -v ~/.ssh:/ssh/ jvhoof/ansible-docker ansible-playbook /data/ansible/deploy-docker.yml -vvv -i /data/ansible/inventory/web
