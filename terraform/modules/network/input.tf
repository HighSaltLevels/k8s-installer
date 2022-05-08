variable "compartment_id" {
  type        = string
  description = "The compartment Id to deploy the network to"
}

variable "vcn_cidr" {
  type        = string
  description = "The CIDR range to allocate for a VCN"
}
