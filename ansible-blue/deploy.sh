#!/bin/bash

echo ""
echo "==> Ansible configuration"
echo ""
ansible-playbook deploy.yml -vvv -i inventory/waf
