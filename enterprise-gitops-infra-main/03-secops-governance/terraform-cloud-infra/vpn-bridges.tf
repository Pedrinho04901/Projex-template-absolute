# 1. O Port?o de Entrada na AWS (Virtual Private Gateway)
resource "aws_vpn_gateway" "vpn_gw" {
  vpc_id = aws_vpc.fintech_vpc.id

  tags = {
    Name = "main-vpn-gateway"
  }
}

# 2. O Roteador F?sico de S?o Paulo (Customer Gateway)
resource "aws_customer_gateway" "office_sp_router" {
  bgp_asn    = 65000
  ip_address = "200.100.50.1" # IP P?blico simulado do link de SP
  type       = "ipsec.1"

  tags = {
    Name = "cgw-sao-paulo"
  }
}

# 3. O Roteador F?sico de Recife (Customer Gateway)
resource "aws_customer_gateway" "office_recife_router" {
  bgp_asn    = 65000
  ip_address = "200.200.150.1" # IP P?blico simulado do link de Recife
  type       = "ipsec.1"

  tags = {
    Name = "cgw-recife"
  }
}

# 4. A Ponte Criptografada: AWS <--> S?o Paulo
resource "aws_vpn_connection" "sp_vpn_link" {
  vpn_gateway_id      = aws_vpn_gateway.vpn_gw.id
  customer_gateway_id = aws_customer_gateway.office_sp_router.id
  type                = "ipsec.1"
  static_routes_only  = true

  tags = {
    Name = "vpn-link-sao-paulo"
  }
}

# 5. A Ponte Criptografada: AWS <--> Recife
resource "aws_vpn_connection" "recife_vpn_link" {
  vpn_gateway_id      = aws_vpn_gateway.vpn_gw.id
  customer_gateway_id = aws_customer_gateway.office_recife_router.id
  type                = "ipsec.1"
  static_routes_only  = true

  tags = {
    Name = "vpn-link-recife"
  }
}
