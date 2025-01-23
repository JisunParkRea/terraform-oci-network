terraform {
  required_version = "~> 1.5.0"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "6.21.0"
    }
  }
}

provider "oci" {
  region = var.region
}

resource "oci_identity_compartment" "main" {
  compartment_id = var.compartment_ocid
  name           = var.compartment_name
  description    = var.compartment_description
}

resource "oci_core_vcn" "main" {
  compartment_id = oci_identity_compartment.main.id

  cidr_blocks  = var.vcn_cidr_blocks
  dns_label    = var.vcn_name
  display_name = var.vcn_name
}

resource "oci_core_internet_gateway" "main" {
  compartment_id = oci_identity_compartment.main.id
  vcn_id         = oci_core_vcn.main.id

  enabled      = true
  display_name = "internet-gateway"
}

resource "oci_core_route_table" "public" {
  compartment_id = oci_identity_compartment.main.id
  vcn_id         = oci_core_vcn.main.id

  display_name = "public-route-table"

  route_rules {
    network_entity_id = oci_core_internet_gateway.main.id

    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
  }
}

resource "oci_core_route_table" "private" {
  compartment_id = oci_identity_compartment.main.id
  vcn_id         = oci_core_vcn.main.id

  display_name = "private-route-table"
}

resource "oci_core_security_list" "public" {
  compartment_id = oci_identity_compartment.main.id
  vcn_id         = oci_core_vcn.main.id

  display_name = "public-security-list"

  # egress 모든 트래픽 허용
  egress_security_rules {
    protocol         = "all"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
  }

  # 인그레스 규칙 (HTTP, HTTPS, SSH 허용)
  ingress_security_rules {
    protocol    = "6" # TCP
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    protocol    = "6" # TCP
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    tcp_options {
      min = 443
      max = 443
    }
  }

  ingress_security_rules {
    protocol    = "6" # TCP
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    tcp_options {
      min = 22
      max = 22
    }
  }
}

resource "oci_core_security_list" "private" {
  compartment_id = oci_identity_compartment.main.id
  vcn_id         = oci_core_vcn.main.id

  display_name = "private-security-list"

  # egress 모든 트래픽 허용
  egress_security_rules {
    protocol         = "all"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
  }

  # ingress VCN 내부 통신 허용
  dynamic "ingress_security_rules" {
    for_each = toset(var.vcn_cidr_blocks)

    content {
      protocol    = "all"
      source      = ingress_security_rules.key
      source_type = "CIDR_BLOCK"
    }
  }
}

resource "oci_core_subnet" "public" {
  count = length(var.public_subnet_cidr_blocks)

  compartment_id             = oci_identity_compartment.main.id
  vcn_id                     = oci_core_vcn.main.id
  cidr_block                 = var.public_subnet_cidr_blocks[count.index]
  display_name               = var.public_subnet_display_names[count.index]
  dns_label                  = var.public_subnet_display_names[count.index]
  prohibit_public_ip_on_vnic = false
  route_table_id             = oci_core_route_table.public.id
  security_list_ids          = [oci_core_security_list.public.id]
}

resource "oci_core_subnet" "private" {
  count = length(var.private_subnet_cidr_blocks)

  compartment_id             = oci_identity_compartment.main.id
  vcn_id                     = oci_core_vcn.main.id
  cidr_block                 = var.private_subnet_cidr_blocks[count.index]
  display_name               = var.private_subnet_display_names[count.index]
  dns_label                  = var.private_subnet_display_names[count.index]
  prohibit_public_ip_on_vnic = true
  route_table_id             = oci_core_route_table.private.id
  security_list_ids          = [oci_core_security_list.private.id]
}
