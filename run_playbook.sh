#!/bin/bash

if [ ! -f hosts ] ; then
    echo "Error:"
    echo "-------------------------------------------------------------------------"
    echo "Please supply a hosts file. You can find an example one in this project's"
    echo "directory called 'example_hosts'. Use that as a template to fill out a"
    echo "list of your master and worker nodes. Name that file 'hosts' and keep it"
    echo "in this project directory for ansible-playbook to find it."
    exit 1
fi

ansible-playbook -i hosts k8s.yml
