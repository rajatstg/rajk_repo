resource "aws_eip" "eip_addr" {
   count    = 2
   instance = "${element(aws_instance.devops-2021.*.id,count.index)}"
   vpc      = true
   depends_on = [aws_internet_gateway.igw,aws_instance.devops-2021]
}

###resource "aws_eip_association" "eip_assoc" {
#  count         = 2
#  instance_id   = "${aws_instance.devops-2021[count.index].id}"
#  allocation_id = aws_eip.eip_addr[count.index].id
#  depends_on = [aws_eip.eip_addr,aws_instance.devops-2021]
#}

resource "aws_security_group" "terraform_sg" {
  name        = "terraform_sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vpc_demo.id
  depends_on = [aws_vpc.vpc_demo]

  ingress {
    description      = "TLS from VPC"
    from_port        = 0
    to_port          = 65535
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow_tls"
  }
}

resource "aws_instance" "devops-2021" {
  ami           = var.ami_id
  instance_type = var.inst_type
  count = var.count_value
  key_name = "rajkey"
  associate_public_ip_address = true
  subnet_id   = aws_subnet.subnet_demo.id
  vpc_security_group_ids = [aws_security_group.terraform_sg.id]
  tags = {
    Name = "pradeep-terraform"
  }
}

#resource "aws_network_interface" "demo_interface" {
#  subnet_id   = aws_subnet.subnet_demo.id
#  private_ips = ["10.0.1.10"]
#  security_groups  = [aws_security_group.terraform_sg.id]
#  depends_on = [aws_subnet.subnet_demo, aws_security_group.terraform_sg]

#  tags = {
#    Name = "primary_network_interface"
#  }
#}

resource "aws_vpc" "vpc_demo" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "vpc-demo"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_demo.id
  depends_on = [aws_vpc.vpc_demo]
  
  tags = {
    Name = "demo-igw"
  }
}

resource "aws_default_route_table" "defroute_vpc_demo" {
  default_route_table_id = aws_vpc.vpc_demo.default_route_table_id

    route = [
    {
     cidr_block                = "0.0.0.0/0"
     egress_only_gateway_id    = ""
     gateway_id                = aws_internet_gateway.igw.id
     instance_id               = ""
     ipv6_cidr_block           = ""
     nat_gateway_id            = ""
     network_interface_id      = ""
     transit_gateway_id        = ""
     vpc_peering_connection_id = ""
     destination_prefix_list_id = ""
     vpc_endpoint_id = ""
    }
  ]

  tags = {
    Name = "defroute_vpc_demo"
  }
}

resource "aws_subnet" "subnet_demo" {
  vpc_id     = aws_vpc.vpc_demo.id
  cidr_block = "10.0.1.0/24"
  depends_on = [aws_vpc.vpc_demo]

  tags = {
    Name = "Demo Subnet"
  }
}

