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

echo "Agent.BuildDirectory: [$(AGENT_BUILDDIRECTORY)]"
echo "Agent.WorkFolder: [$(AGENT_WORKFOLDER)]"
echo "Build.BuildId: [$(BUILD_BUILDID)]"

set