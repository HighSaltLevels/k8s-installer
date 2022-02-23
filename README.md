# Kubernetes Installer

This simple project is a quick playbook I threw together to install kubernetes since I got tired of going through these steps manually every time I wanted to add a node or create another cluster of Raspberry Pis. Thus this project was born.

## Limitations to This Project

 - This project was hastily put together and has paths relative to my own user naming convention. Until I get the time to fix this, you'll likely have to change some paths in the task files.
 - This project only supports debian based hosts on `arm` and `x86_64`. When I get the time, I'll add support for rpm based distros.

## Using the Installer

Did you skip straight to this section? That's ok, that's what I normally do too. But please read the section above this one to see the current project limitations or else this project won't work correctly on your environment.

First, you need to install ansible. See [Ansible's docs](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) for installation instructions.

Then, you need to create an ansible inventory. [Ansible's inventory file docs](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html) are a great resource for creating one. Or if you want a quick start, you can check out the example hosts file in this project's root directory called [example_hosts](exampl_hosts).

You're all set. You can run the playbook now using:
```
ansible-playbook -i <your-inventory-file> k8s.yml
```

## Contributing

Feel free to raise a PR if you want to help me fix the Limitations listed above. I also realize that there are probably several other better ansible playbooks out there. But to re-iterate, this was something _I_ wanted to do for my own setup at home. But I'm always open to contributions :)
