resource "aws_customer_gateway" "customer_gw" {
  bgp_asn = 65000
  ip_address = var.vpn_ip
  type = "ipsec.1"
  tags       = {
      "Name" = "${var.name}-vpn-gw"
  }
}

resource "aws_vpn_connection" "vpn-conn" {
  vpn_gateway_id      = var.vpn_gw_id
  customer_gateway_id = aws_customer_gateway.customer_gw.id
  type                = "ipsec.1"
  static_routes_only  = false

  tags = {
    Name = "${var.name}-vpn"
  }

  lifecycle {
    prevent_destroy = true
    ################# this is due to aws bug that after changing a tunnel ###############
    ################# once the tunnelOptions always show even if default ###############
    ignore_changes = [tunnel1_phase1_dh_group_numbers,tunnel1_phase1_encryption_algorithms,
                      tunnel1_phase1_integrity_algorithms,tunnel1_phase2_dh_group_numbers,tunnel1_ike_versions,
                      tunnel1_phase2_encryption_algorithms, tunnel1_phase2_integrity_algorithms,
                      tunnel2_phase1_dh_group_numbers,tunnel2_phase1_encryption_algorithms,
                      tunnel2_phase1_integrity_algorithms,tunnel2_phase2_dh_group_numbers,tunnel2_ike_versions,
                      tunnel2_phase2_encryption_algorithms, tunnel2_phase2_integrity_algorithms]
    ################# this is due to aws bug that after changing a tunnel ###############
    ################# once the tunnelOptions always show even if default ###############
  }
}
