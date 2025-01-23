output "compartment_id" {
  value = oci_identity_compartment.main.id
}

output "vcn_id" {
  value = oci_core_vcn.main.id
}

output "internet_gateway_id" {
  value = oci_core_internet_gateway.main.id
}

output "public_route_table" {
  value = oci_core_route_table.public.id
}

output "private_route_table" {
  value = oci_core_route_table.private.id
}

output "public_security_list" {
  value = oci_core_security_list.public.id
}

output "private_security_list" {
  value = oci_core_security_list.private.id
}

output "public_subnet_ids" {
  value = oci_core_subnet.public[*].id
}

output "private_subnet_ids" {
  value = oci_core_subnet.private[*].id
}
