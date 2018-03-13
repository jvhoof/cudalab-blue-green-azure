#!/bin/bash

echo ""
echo "==> Ansible configuration"
echo ""
ansible-playbook ansible-waf/bootstrap.yml -vvv -i ansible-waf/inventory/waf
