output "master_node_id" {
  value = oci_core_instance.master_node.id
}

output "master_node_ip" {
  value = oci_core_instance.master_node.private_ip
}

output "worker1_id" {
  value = oci_core_instance.worker1.id
}

output "worker1_ip" {
  value = oci_core_instance.worker1.private_ip
}

output "worker2_id" {
  value = oci_core_instance.worker2.id
}

output "worker2_ip" {
  value = oci_core_instance.worker2.private_ip
}
