variable "region" {}

variable "compartment_ocid" {}

variable "compartment_name" {
  type    = string
  default = "jisun-poc"
}

variable "compartment_description" {
  type    = string
  default = "child compartment for oci poc"
}

variable "vcn_cidr_blocks" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}

variable "vcn_name" {
  type    = string
  default = "vcn1"
}

variable "public_subnet_cidr_blocks" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnet_display_names" {
  type    = list(string)
  default = ["publicsub1", "publicsub2"]
}

variable "private_subnet_cidr_blocks" {
  type    = list(string)
  default = ["10.0.11.0/24", "10.0.22.0/24"]
}

variable "private_subnet_display_names" {
  type    = list(string)
  default = ["privatesub1", "privatesub2"]
}
