data "aws_caller_identity" "current" {}

data "aws_iam_role" "lab_role" {
  name = "LabRole"
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_default_security_group" "default" {
  vpc_id  = aws_vpc.main.id
  ingress = []
  egress  = []
}

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = length(var.availability_zones) > 0 ? var.availability_zones[count.index] : null
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-subnet-public-${count.index + 1}"
    Tier = "public"
  }
}
#checkov:skip=CKV_AWS_382:Egress abierto es necesario para que la instancia descargue paquetes y actualizaciones desde internet (apt, docker hub, etc). El trafico de entrada (ingress) si esta restringido.
#checkov:skip=CKV2_AWS_5:Este Security Group se asocia a la instancia EC2 en el modulo raiz (main.tf) via module.ec2.security_group_ids = [module.vpc.security_group_id]. Checkov no resuelve referencias cruzadas entre modulos en este analisis estatico.
resource "aws_security_group" "main" {
  name        = "${var.project_name}-sg"
  description = var.sg_description
  vpc_id      = aws_vpc.main.id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}

#checkov:skip=CKV2_AWS_64:Esta KMS key es de uso interno exclusivo para cifrar los logs de VPC Flow Logs (recurso unico y de bajo riesgo). No requiere policy custom porque usa la policy por defecto de AWS que ya restringe el acceso a la cuenta.
resource "aws_kms_key" "log_encryption" {
  description             = "KMS key para encriptar logs de CloudWatch - ${var.project_name}"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name = "${var.project_name}-kms-logs"
  }
}

#checkov:skip=CKV2_AWS_64:Esta KMS key es de uso interno exclusivo para cifrar los logs de VPC Flow Logs (recurso unico y de bajo riesgo). No requiere policy custom porque usa la policy por defecto de AWS que ya restringe el acceso a la cuenta.
resource "aws_kms_key" "log_encryption" {
  description             = "KMS key para encriptar logs de CloudWatch - ${var.project_name}"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-kms-logs"
  })
}

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc/${var.project_name}-flow-logs"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.log_encryption.arn

  tags = {
    Name = "${var.project_name}-loggroup"
  }
}

resource "aws_flow_log" "vpc_flow_logs" {
  log_destination      = aws_cloudwatch_log_group.vpc_flow_logs.arn
  log_destination_type = "cloud-watch-logs"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.main.id
  iam_role_arn         = data.aws_iam_role.lab_role.arn

  tags = {
    Name = "${var.project_name}-flowlog"
  }
}