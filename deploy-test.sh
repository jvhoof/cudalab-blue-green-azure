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

echo "Agent.BuildDirectory: [$(Agent.BuildDirectory)]"
echo "Agent.WorkFolder: [$(Agent.WorkFolder)]"
echo "Build.BuildId: [$(Build.BuildId)]"
echo "BACKEND_STORAGE_ACCOUNT_NAME: [$BACKEND_STORAGE_ACCOUNT_NAME]"
echo "BACKEND_CONTAINER_NAME: [$BACKEND_CONTAINER_NAME]"
echo "BACKEND_KEY_COLOR: [$BACKEND_KEY_COLOR]"