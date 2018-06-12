#!/bin/bash

echo ""
echo "==> Ansible configuration"
echo ""
ansible-playbook ansible-waf/deploy.yml -vvv -i ansible-waf/inventory/waf
