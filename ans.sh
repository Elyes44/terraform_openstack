#!/bin/bash


#nano /etc/ansible/host.ini
#nano /etc/ansible/ansible.cfg


# Run the Ansible playbook
ansible-playbook -i /etc/ansible/hosts.ini playbook.yaml
