locals {
  name   = "demo"
  region = "ap-southeast-2"
}

data "http" "my_public_ip" {
  url = "http://ifconfig.me/ip"
}

data "aws_availability_zones" "available" {}

data "aws_ami" "amzn2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }
}

data "aws_ami" "amzn2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "vpc" {
  source = "tfstack/vpc/aws"

  region             = local.region
  vpc_name           = local.name
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = data.aws_availability_zones.available.names

  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  eic_private_subnet = "10.0.5.0/24"
  eic_subnet         = "private"

  jumphost_instance_create = false
  jumphost_ingress_cidrs   = ["${data.http.my_public_ip.response_body}/32"]
  create_igw               = true
  ngw_type                 = "single"
}

resource "aws_instance" "amzn2023" {
  ami                    = data.aws_ami.amzn2023.id
  instance_type          = "t3.micro"
  subnet_id              = module.vpc.private_subnet_ids[0]
  vpc_security_group_ids = [module.vpc.eic_security_group_id]
  user_data_base64       = base64encode(file("${path.module}/external/cloud-init.yaml"))

  tags = {
    Name = "${local.name}-amzn2023"
  }
}

resource "aws_instance" "amzn2" {
  ami                    = data.aws_ami.amzn2.id
  instance_type          = "t3.micro"
  subnet_id              = module.vpc.private_subnet_ids[1]
  vpc_security_group_ids = [module.vpc.eic_security_group_id]
  user_data_base64       = base64encode(file("${path.module}/external/cloud-init.yaml"))

  tags = {
    Name = "${local.name}-amzn2"
  }
}

resource "aws_instance" "ubuntu" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = module.vpc.private_subnet_ids[2]
  vpc_security_group_ids = [module.vpc.eic_security_group_id]
  user_data_base64       = base64encode(file("${path.module}/external/cloud-init.yaml"))

  tags = {
    Name = "${local.name}-ubuntu"
  }
}
