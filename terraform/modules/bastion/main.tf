data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

resource "oci_core_instance" "bastion" {
  compartment_id      = var.compartment_id
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  # OCI free tier only lets me use Arm
  shape = "VM.Standard.A1.Flex"
  create_vnic_details {
    display_name           = "bastion-vnic"
    skip_source_dest_check = true
    subnet_id              = var.subnet_id
    assign_public_ip       = true
  }
  display_name = "bastion"
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
    user_data           = "${base64encode(file("./scripts/bastion_cloud_init.sh"))}"
  }
  preserve_boot_volume = false
}
