locals {
  compartment_id = "ocid1.compartment.oc1..aaaaaaaaakcoqdzsuo2lwshkpc4vqn65tszdmrcsmgxsj57iw6ctqriycuwa"
  vcn_cidr       = "10.0.0.0/24"

  # See: https://docs.oracle.com/en-us/iaas/images/oracle-linux-cloud-developer-8x/
  # This is also assuming us-ashburn-1
  node_image_id = "ocid1.image.oc1.iad.aaaaaaaatw76yshzzwmu6l7rdpsv3kpfnanubwtdhjbrhelz4n7sz7ss5s6q"

  # See: https://docs.oracle.com/en-us/iaas/images/ubuntu-2004/
  # This is also assuming us-ashburn-1
  bastion_image_id = "ocid1.image.oc1.iad.aaaaaaaa47gahg22die2m27l2gdrv5yjlxor6nu5m7agyyy7k6zq52l6cura"

  node_ssh_pub_key    = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDCPWoeq8TiDcudKJESQZRRGDdX3wcwY+tdNpUFWudNcwY2dm3cuwu/mnY+EP+d0mKB9+yTaTTERjdudStwTBolH/ww7Y/YlddcIC6j2ibx55mLBsO/2s08GsFlSs8cS/1ZbV3FynBnXxgsnLel5auZCuaQp1byuffssF8mhpE/rHNEHHLM15FdBU+4uhf95LpaeykwCUQ3JC+6enjBDKK68tB4z13JReFpLVcMVGk8o4L5/aFVDM3DXCnN+OxRVFwtBJNEjzU10Gq+oxv/oV9i4ZLM1pLXZmGSu1f9L9CbJW9IIvDzlu6bEdN8OsWezlEwv42p1yiTd4CintgXwx227z+6WowTzsVAhAqxojus7Ux1A0cJyv8nONhnq+kbVZK2s9YBp0ilhTe6tYoqxW944s6LSqRNO8EGLcUkeKrVRDxEEN+kpgVj/psT9VMNIFJ0rKtCaDU/TNDajb6CQU0IAU+b2HUEiz1lTgizFLlze9ZSAkbhD374BCN5yp/LYqy2WYjS7cO2+Dy1MyDlJrkH/Rg+wqltNba3BLbg5GR96y46FFPWzHV8s5JaIoRFEyY9rva/cgEnGNx4y11idB2ddGvPCGNC5Khyfel7nun/N2yc3XLgP2v7EUVFa/+DqxTrY+HsK4NZQsra0KVlXKudZBu3hF8zGC7yncYWwtWhqQ=="
  bastion_ssh_pub_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDN/V8AWNTnI22rig/ToSNgLuJTyv6DMFHZWf6LyKPs7RopAuHhTAk1bBETkDnRUAC4/HCj8oODn0MLclCd6gM0Tl5C74NpYRuO8tRmntZL60pWeQvNrZ66wCTve9NI4sGjxYV9/bEc3HGwUziBPaevq5d1QRmHLi0fPOM2R1vx20ii/DY0iKWsnrGVZwBLN4qI+n8KT/8IVMyO32329joB/lMXEfDG/Jw9L1pnx111cwP6XzqZprUIpa+aTQVbHB8iRX8lryeM32lKXIV8B/S1KikRl2S/ASoAlxYNEELqfHx4M3g1LXZhwXHNdOr7ShOuv/8B/Bo2zBNgnFE/C8SFzOhb/jTmOZsJJq0MlkkRaWIbiDIGF2yFwrsvb6gxJLvyKfnH/WZZkkeeNLth8x6R1TbjKL97BV5CClGw1AoeHUh1dOjD9uCcWedeH9r8kU5UMcbpKcbIk4N3A94UI1ullDPs/LBKPWg0bMpGmaU23CEz9RLiTe3P4XxsTa1csDPY2nheVLcGiNdtRQf8giNKF0ARifOq0It7jopS31VMA2BvqImM0wD635AqmUInfua8y2k3Nk89N1Vh7Izd2Y+wyQS6DKCsW4C4PZZVLefAtMqQR+UOk1eUzwSQSNt4iGJ1yQ1koCCjSFu+N38+SddzbRBxuXOw6g+CucZLJSI/Jw=="
}

module "network" {
  source = "./modules/network"

  compartment_id = local.compartment_id
  vcn_cidr       = local.vcn_cidr
}

module "nodes" {
  source = "./modules/nodes"

  compartment_id = local.compartment_id
  subnet_id      = module.network.node_subnet_id
  base_image_id  = local.node_image_id
  ssh_pub_key    = local.node_ssh_pub_key
}

module "bastion" {
  source = "./modules/bastion"

  compartment_id = local.compartment_id
  subnet_id      = module.network.bastion_subnet_id
  base_image_id  = local.bastion_image_id
  ssh_pub_key    = local.bastion_ssh_pub_key
}

resource "local_file" "ansible_hosts" {
  content  = <<EOT
[master]
opc@${module.nodes.master_node_ip} ansible_ssh_private_key_file=~/.ssh/k8s_id_rsa
[master:vars]
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyCommand="ssh -i ~/.ssh/bastion_id_rsa -W %h:%p -q ubuntu@${module.bastion.bastion_ip}"'

[workers]
opc@${module.nodes.worker1_ip} ansible_ssh_private_key_file=~/.ssh/k8s_id_rsa
opc@${module.nodes.worker2_ip} ansible_ssh_private_key_file=~/.ssh/k8s_id_rsa
[workers:vars]
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyCommand="ssh -i ~/.ssh/bastion_id_rsa -W %h:%p -q ubuntu@${module.bastion.bastion_ip}"'
EOT
  filename = "../hosts"
}

resource "local_file" "bastion_ip" {
    content = "${module.bastion.bastion_ip}"
    filename = "../bastion_ip"
}
