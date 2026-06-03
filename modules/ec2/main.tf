data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.project_name}-ec2-role"
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_role_policy_attachment" "extra_policies" {
  count      = length(var.iam_policy_arns)
  role       = aws_iam_role.ec2_role.name
  policy_arn = var.iam_policy_arns[count.index]
}

resource "aws_instance" "ec2" {
  ami           = var.ami_id != "" ? var.ami_id : data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  associate_public_ip_address = var.associate_public_ip

  monitoring    = true
  ebs_optimized = true

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  root_block_device {
    encrypted   = true
    volume_type = var.root_volume_type
    volume_size = var.root_volume_size
  }

  metadata_options {
    http_tokens = "required"
  }

  user_data = var.user_data != "" ? var.user_data : null

  tags = merge(var.tags, {
    Name = "${var.project_name}-ec2"
  })
}