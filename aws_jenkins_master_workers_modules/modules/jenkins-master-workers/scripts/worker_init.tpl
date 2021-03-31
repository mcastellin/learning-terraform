#!/bin/bash

# ------------------------------------------------
# cloud-init script for Jenkins worker node
# ------------------------------------------------
yum update -y
yum install -y git
amazon-linux-extras install -y ansible2

yum install -y https://s3.${region}.amazonaws.com/amazon-ssm-${region}/latest/linux_amd64/amazon-ssm-agent.rpm
systemctl enable --now amazon-ssm-agent; true

# ansible pull configuration form my playbook repository
ansible-pull \
    -o -C main -U git://github.com/mcastellin/ansible-playbooks \
    --connection=local \
    --inventory 127.0.0.1, \
    --extra-vars "master_ip=${master_ip}" \
    jenkins/cloud-init/worker/playbook.yaml