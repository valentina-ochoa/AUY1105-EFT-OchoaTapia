provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "../modules/vpc"

  project_name        = "AUY1105-Tapia-Ochoa"
  vpc_cidr            = "10.1.0.0/16"
  public_subnet_cidrs = ["10.1.1.0/24"]
  availability_zones  = ["us-east-1a"]
  log_retention_days  = 365

  ingress_rules = [
    {
      description = "Allow SSH from internal networks only"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/8"]
    }
  ]

  tags = {
    Environment = "dev"
    Project     = "AUY1105-Tapia-Ochoa"
    ManagedBy   = "Terraform"
  }
}

module "ec2" {
  source = "../modules/ec2"

  project_name        = "AUY1105-Tapia-Ochoa"
  subnet_id           = module.vpc.subnet_ids[0]
  security_group_ids  = [module.vpc.security_group_id]
  instance_type       = "t3.large"
  associate_public_ip = false
  root_volume_type    = "gp3"
  root_volume_size    = 20

  tags = {
    Environment = "dev"
    Project     = "AUY1105-Tapia-Ochoa"
    ManagedBy   = "Terraform"
  }
}

output "instance_id" { value = module.ec2.instance_id }
output "instance_ip" { value = module.ec2.instance_ip }
output "vpc_id"      { value = module.vpc.vpc_id }