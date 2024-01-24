resource "aws_vpc" "fe_vpc" {
    cidr_block = "${var.network_address_space}"
    tags = {
        Name = "${var.env_name}_fe_vpc"
    }
}


resource "aws_subnet" "fe_sub1" {
    cidr_block              = "10.0.1.0/24"
    vpc_id                  = "${aws_vpc.fe_vpc.id}"
    availability_zone       = "us-east-2a"
    map_public_ip_on_launch = true
    tags = {
        Name = "${var.env_name}_fe_sub_1"
    }
}

resource "aws_subnet" "fe_sub2" {
    cidr_block              = "10.0.2.0/24" 
    vpc_id                  = "${aws_vpc.fe_vpc.id}"
    map_public_ip_on_launch = true
    availability_zone       = "us-east-2b"
    tags = {
        Name = "${var.env_name}_fe_sub_2"
    }
}

resource "aws_internet_gateway" "fe_gw" {
    vpc_id = "${aws_vpc.fe_vpc.id}"
    tags = {
        Name = "${var.env_name}_fe_gw"
    }
}

resource "aws_route" "internet_access" {
    route_table_id          = aws_vpc.fe_vpc.main_route_table_id
    destination_cidr_block  = "0.0.0.0/0"
    gateway_id              = aws_internet_gateway.fe_gw.id
}

resource "aws_eip" "demo-eip-gateway-01" {
    domain          = "vpc"
    depends_on      = [aws_internet_gateway.fe_gw]
    tags = {
        Name = "demo-eip-fe-gw"
    }
}

