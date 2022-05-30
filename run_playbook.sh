#!/bin/bash

if [ ! -f hosts ] ; then
    echo "Error:"
    echo "-------------------------------------------------------------------------"
    echo "If you're seeing this error, then you either didn't use terraform, or you"
    echo "may have ran terraform from a different directory."
    echo ""
    echo "You are missing the ansible hosts file. If you ran the terraform, then"
    echo "look for this file and put it here:"
    echo "$(pwd)/hosts"
    echo ""
    echo "Alternatively, you can create your own hosts file. There is an example"
    echo "ansible hosts file in this project's directory called 'example_hosts'."
    exit 1
fi

ansible-playbook -i hosts k8s.yml

if [ ! -f bastion_ip ] ; then
    echo "Warning:"
    echo "-------------------------------------------------------------------------"
    echo "Could not find 'bastion_ip' file. Terraform normally outputs this file,"
    echo "however it could be missing if you manually created your ansible"
    echo "inventory instead of using terraform. Since the bastion host is unknown,"
    echo "copying the kube config to the bastion will be skipped. If you want to"
    echo "utilize the kube config, it's currently located at '/tmp/kube_config'"
else
    ssh -i ~/.ssh/bastion_id_rsa ubuntu@$(cat bastion_ip) "mkdir ~/.kube"
    scp -i ~/.ssh/bastion_id_rsa /tmp/kube_config ubuntu@$(cat bastion_ip):~/.kube/config
fi
