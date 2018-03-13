#!/bin/bash

echo ""
echo "==> Ansible configuration"
echo ""
docker run --rm -itv $PWD:/data -v ~/.ssh:/ssh/ jvhoof/ansible-docker ansible-playbook /data/deploy-test.yml -v -i /data/inventory/waf
