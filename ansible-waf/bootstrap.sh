#!/bin/bash

echo ""
echo "==> Ansible configuration"
echo ""
ansible-playbook bootstrap.yml -vvv -i inventory/waf
