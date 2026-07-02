# 1. Configura??o oficial do escopo de DNS corporativo (DHCP Options)
resource "aws_vpc_dhcp_options" "corp_dns_policy" {
  domain_name          = "loki.dtc"
  domain_name_servers  = ["10.0.2.50", "1.1.1.1"] # AD na Nuvem + Cloudflare de conting?ncia

  tags = {
    Name = "dhcp-options-loki-dtc"
  }
}

# 2. Associa essa pol?tica de DNS automaticamente ? nossa VPC do projeto
resource "aws_vpc_dhcp_options_association" "dns_resolver_assoc" {
  vpc_id          = aws_vpc.fintech_vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.corp_dns_policy.id
}
