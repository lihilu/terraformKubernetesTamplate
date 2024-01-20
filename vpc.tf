data "aws_region" "current" {}


# data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    "Name" = "VPC - ${var.default_tags}"
  }
}

# # SUBNETS
# resource "aws_subnet" "public" {
#   map_public_ip_on_launch = "true"
#   count                   = length(var.public_subnet_cidrs)
#   cidr_block              = var.public_subnet_cidrs[count.index]
#   vpc_id                  = aws_vpc.vpc.id
#   availability_zone       = data.aws_availability_zones.available.names[count.index]

#   tags = {
#     "Name"    = "public_subnet_${regex(".$", data.aws_availability_zones.available.names[count.index])}"
#     "purpose" = var.default_tags
#   }
# }

resource "aws_subnet" "private" {
  count                   = length(var.private_subnet_cidrs)
  cidr_block              = var.private_subnet_cidrs[count.index]
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = "false"
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    "Name"    = "private_subnet_${regex(".$", data.aws_availability_zones.available.names[count.index])}"
    "purpose" = var.default_tags
  }
}

# IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name"    = "IGW"
    "purpose" = var.default_tags
  }
}

# # EIPs (for nats)
# resource "aws_eip" "eip" {
#   count = length(var.public_subnet_cidrs)

#   tags = {
#     "Name"    = "NAT_elastic_ip_${regex(".$", data.aws_availability_zones.available.names[count.index])}"
#     "purpose" = var.default_tags
#   }
# }

# # NATs
# resource "aws_nat_gateway" "nat" {
#   count         = length(var.public_subnet_cidrs)
#   allocation_id = aws_eip.eip.*.id[count.index]
#   subnet_id     = aws_subnet.public.*.id[count.index]

#   tags = {
#     "Name"    = "NAT_${regex(".$", data.aws_availability_zones.available.names[count.index])}"
#     "purpose" = var.default_tags
#   }
# }

######################################################################
############################## ROUTING ##############################
######################################################################

resource "aws_route_table" "route_tables" {
  count  = length(var.route_tables_names)
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "RTB_${var.route_tables_names[count.index]}"
  }
}

# resource "aws_route_table_association" "public" {
#   count          = length(var.public_subnet_cidrs)
#   subnet_id      = aws_subnet.public.*.id[count.index]
#   route_table_id = aws_route_table.route_tables[0].id
# }

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private.*.id[count.index]
  route_table_id = aws_route_table.route_tables[count.index + 1].id
}

# resource "aws_route" "public" {
#   route_table_id         = aws_route_table.route_tables[0].id
#   destination_cidr_block = var.destination_cidr_block
#   gateway_id             = aws_internet_gateway.igw.id
# }

resource "aws_route" "private" {
  count                  = length(var.private_subnet_cidrs)
  route_table_id         = aws_route_table.route_tables.*.id[count.index + 1]
  destination_cidr_block = var.destination_cidr_block
  nat_gateway_id         = aws_nat_gateway.nat.*.id[count.index]
}