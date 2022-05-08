locals {
  # Use half of the VCN for nodes, a quarter
  # of the VCN for the bastion, and the last
  # quarter unallocated
  node_subnet_cidr    = cidrsubnet(var.vcn_cidr, 1, 0)
  bastion_subnet_cidr = cidrsubnet(cidrsubnet(var.vcn_cidr, 1, 1), 1, 0)

  # Protocol acronyms to their corresponding number
  ICMP   = "1"
  TCP    = "6"
  UDP    = "17"
  ICMPv6 = "58"

  # Ports
  SSH      = 22
  HTTP     = 80
  HTTPS    = 443
  KUBE_API = 6443
}

resource "oci_core_vcn" "vcn" {
  compartment_id = var.compartment_id

  cidr_blocks  = [var.vcn_cidr]
  display_name = "cluster_vcn"
}

# Create an IGW for the Load Balancer subnet
resource "oci_core_internet_gateway" "node_igw" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  enabled        = true
  display_name   = "node_igw"
}

resource "oci_core_security_list" "node" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "node_sl"

  egress_security_rules {
    destination      = "0.0.0.0/0"
    protocol         = local.TCP
    description      = "Allow egress everywhere for internet connectivity"
    destination_type = "CIDR_BLOCK"
  }

  # This also allows communication between the nodes
  ingress_security_rules {
    protocol    = local.TCP
    source      = var.vcn_cidr
    description = "Allow ingress from anywhere in the VCN"
    source_type = "CIDR_BLOCK"
  }

  # In case you want to use loadbalancers, allow ingress
  # on HTTP and HTTPS ports
  ingress_security_rules {
    protocol    = local.TCP
    source      = "0.0.0.0/0"
    description = "Allow ingress on port 80"
    source_type = "CIDR_BLOCK"
    tcp_options {
      min = local.HTTP
      max = local.HTTP
    }
  }

  ingress_security_rules {
    protocol    = local.TCP
    source      = "0.0.0.0/0"
    description = "Allow ingress on port 443"
    source_type = "CIDR_BLOCK"
    tcp_options {
      min = local.HTTPS
      max = local.HTTPS
    }
  }

  ingress_security_rules {
    protocol    = local.TCP
    source      = local.bastion_subnet_cidr
    description = "Allow ingress from the bastion subnet"
    source_type = "CIDR_BLOCK"
    tcp_options {
      min = local.SSH
      max = local.SSH
    }
  }
}

resource "oci_core_security_list" "bastion" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "bastion_sl"

  egress_security_rules {
    destination      = local.node_subnet_cidr
    protocol         = local.TCP
    description      = "Allow SSH egress to the node subnet"
    destination_type = "CIDR_BLOCK"
    tcp_options {
      min = local.SSH
      max = local.SSH
    }
  }

  egress_security_rules {
    destination      = local.node_subnet_cidr
    protocol         = local.TCP
    description      = "Allow egress to the node subnet for Kube API port"
    destination_type = "CIDR_BLOCK"
    tcp_options {
      min = local.KUBE_API
      max = local.KUBE_API
    }
  }

  egress_security_rules {
    destination      = "0.0.0.0/0"
    protocol         = local.TCP
    description      = "Allow HTTPS egress everywhere for installations"
    destination_type = "CIDR_BLOCK"
    tcp_options {
      min = local.HTTPS
      max = local.HTTPS
    }
  }

  ingress_security_rules {
    protocol    = local.TCP
    source      = "0.0.0.0/0"
    description = "Allow ingress from the internet"
    source_type = "CIDR_BLOCK"
    tcp_options {
      min = local.SSH
      max = local.SSH
    }
  }
}

resource "oci_core_route_table" "node" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "node_rt"
  route_rules {
    network_entity_id = oci_core_internet_gateway.node_igw.id
    description       = "Internet Gateway"
    destination_type  = "CIDR_BLOCK"
    destination       = "0.0.0.0/0"
  }
}

resource "oci_core_subnet" "node" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  cidr_block     = local.node_subnet_cidr
  display_name   = "node"
  # Don't allow public IPs for nodes
  prohibit_public_ip_on_vnic = true
  route_table_id             = oci_core_route_table.node.id
  security_list_ids          = [oci_core_security_list.node.id]
}

resource "oci_core_subnet" "bastion" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  cidr_block     = local.bastion_subnet_cidr
  display_name   = "bastion"
  # Allow public IPs for the bastion subnet
  prohibit_public_ip_on_vnic = false
  # Re-use the same route table as the node so that we don't have to create
  # 2 internet gateways
  route_table_id    = oci_core_route_table.node.id
  security_list_ids = [oci_core_security_list.bastion.id]
}
