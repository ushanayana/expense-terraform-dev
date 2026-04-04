#!/bin/bash

# user data will get sudo access
# dnf install ansible -y
# ansible-pull -U https://github.com/ushanayana/expense-ansible-roles.git main.yaml -e component=backend 
# cd /tmp
# git clone https://github.com/ushanayana/expense-ansible-roles.git
# cd expense-ansible-roles
# ansible-playbook main.yaml -e component=backend -e login_password=ExpenseApp1
# ansible-playbook main.yaml -e component=frontend



component=$1
dnf install ansible -y

cd /home/ec2-user
git clone https://github.com/ushanayana/expense-ansible-roles.git

cd expense-ansible-roles
git pull
ansible-playbook -e component=$component  main.yaml

