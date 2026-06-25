module "vpc" {
  source = "./modules/vpc"

  project_name        = var.project_name
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  availability_zones  = var.availability_zones
  sg_description      = "Security Group gestionado por modulo VPC - ${var.project_name}"
  log_retention_days  = var.log_retention_days

  ingress_rules = [
    {
      description = "Allow SSH from internal networks only"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/8"]
    }
  ]

  tags = var.tags
}

module "ec2" {
  source = "./modules/ec2"

  project_name        = var.project_name
  subnet_id           = module.vpc.subnet_ids[0]
  security_group_ids  = [module.vpc.security_group_id]
  instance_type       = var.instance_type
  associate_public_ip = false
  root_volume_type    = "gp3"
  root_volume_size    = 20

  tags = var.tags
}