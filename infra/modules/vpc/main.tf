# Crear la VPC
resource "aws_vpc" "this" {
  cidr_block           = var.cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = { Name = "${var.name}-vpc" }
}

# Crear el Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.name}-igw" }
}

# Crear Elastic IP para la NAT Gateway
resource "aws_eip" "nat_eip" {
  # Asociamos la Elastic IP a la VPC
}

# Crear NAT Gateway en una subred pública
resource "aws_nat_gateway" "nat_gateway" {
  subnet_id     = values(aws_subnet.public)[0].id  # Usamos la primera subred pública del map
  allocation_id = aws_eip.nat_eip.id                # Asociamos la Elastic IP a la NAT Gateway
}

# Crear las subredes públicas
resource "aws_subnet" "public" {
  for_each = toset(var.public_subnets)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value
  availability_zone       = element(var.azs, index(var.public_subnets, each.value))
  map_public_ip_on_launch = true
  tags = { Name = "${var.name}-public-${index(var.public_subnets, each.value)}" }
}

# Crear las subredes privadas
resource "aws_subnet" "private" {
  for_each = toset(var.private_subnets)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value
  availability_zone       = element(var.azs, index(var.private_subnets, each.value))
  tags = { Name = "${var.name}-private-${index(var.private_subnets, each.value)}" }
}

# Crear la tabla de rutas para las subredes públicas
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.name}-public-rt" }
}

# Crear la ruta hacia Internet Gateway para las subredes públicas
resource "aws_route" "public_inet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Asociar las subredes públicas a la tabla de rutas
resource "aws_route_table_association" "public_assoc" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Crear la tabla de rutas para las subredes privadas (con acceso a Internet a través de NAT Gateway)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.name}-private-rt" }
}

# Ruta hacia NAT Gateway para las subredes privadas
resource "aws_route" "private_route_to_nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}

# Asociar las subredes privadas a la tabla de rutas (con NAT Gateway)
resource "aws_route_table_association" "private_assoc" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

