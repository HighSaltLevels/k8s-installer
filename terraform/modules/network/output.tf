output "vcn_id" {
  value = oci_core_vcn.vcn.id
}

output "igw_id" {
  value = oci_core_internet_gateway.node_igw.id
}

output "node_subnet_id" {
  value = oci_core_subnet.node.id
}

output "bastion_subnet_id" {
  value = oci_core_subnet.bastion.id
}
