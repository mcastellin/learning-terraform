#!/bin/bash

# ------------------------------------------------
# cloud-init script for Jenkins master node
# ------------------------------------------------
yum update -y
yum install -y git
amazon-linux-extras install -y ansible2

# ansible pull configuration form my playbook repository
ansible-pull \
    -o -C main -U git://github.com/mcastellin/ansible-playbooks \
    --connection=local \
    --inventory 127.0.0.1, \
    jenkins/cloud-init/master/playbook.yaml