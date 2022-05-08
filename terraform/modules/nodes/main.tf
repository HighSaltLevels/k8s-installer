data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

resource "oci_core_instance" "master_node" {
  compartment_id      = var.compartment_id
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  # OCI free tier only lets me use Arm
  shape = "VM.Standard.A1.Flex"
  create_vnic_details {
    display_name           = "master-node-vnic"
    skip_source_dest_check = true
    subnet_id              = var.subnet_id
    assign_public_ip       = false
  }
  display_name = "master-node"
  source_details {
    source_id   = var.base_image_id
    source_type = "image"
  }
  shape_config {
    memory_in_gbs = 6
    ocpus         = 1
  }
  metadata = {
    ssh_authorized_keys = var.ssh_pub_key
  }
  preserve_boot_volume = false
}

resource "oci_core_instance" "worker1" {
  compartment_id = var.compartment_id
  # If AD2 exists, use AD2. Otherwise, use AD1
  availability_domain = length(data.oci_identity_availability_domains.ads.availability_domains) > 1 ? data.oci_identity_availability_domains.ads.availability_domains[1].name : data.oci_identity_availability_domains.ads.availability_domains[0].name
  # OCI free tier only lets me use Arm
  shape = "VM.Standard.A1.Flex"
  create_vnic_details {
    display_name           = "worker1-vnic"
    skip_source_dest_check = true
    subnet_id              = var.subnet_id
    assign_public_ip       = false
  }
  display_name = "worker1"
  source_details {
    source_id   = var.base_image_id
    source_type = "image"
  }
  shape_config {
    memory_in_gbs = 6
    ocpus         = 1
  }
  metadata = {
    ssh_authorized_keys = var.ssh_pub_key
  }
  preserve_boot_volume = false
}

resource "oci_core_instance" "worker2" {
  compartment_id = var.compartment_id
  # If AD3 exists, use AD3. Otherwise, use AD1
  availability_domain = length(data.oci_identity_availability_domains.ads.availability_domains) > 2 ? data.oci_identity_availability_domains.ads.availability_domains[2].name : data.oci_identity_availability_domains.ads.availability_domains[0].name
  # OCI free tier only lets me use Arm
  shape = "VM.Standard.A1.Flex"
  create_vnic_details {
    display_name           = "worker2-vnic"
    skip_source_dest_check = true
    subnet_id              = var.subnet_id
    assign_public_ip       = false
  }
  display_name = "worker2"
  source_details {
    source_id   = var.base_image_id
    source_type = "image"
  }
  shape_config {
    memory_in_gbs = 6
    ocpus         = 1
  }
  metadata = {
    ssh_authorized_keys = var.ssh_pub_key
  }
  preserve_boot_volume = false
}
