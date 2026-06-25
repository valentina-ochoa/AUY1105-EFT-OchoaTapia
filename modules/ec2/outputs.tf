output "instance_id" {
  description = "ID de la instancia EC2 creada."
  value       = aws_instance.ec2.id
}

output "instance_ip" {
  description = "Direccion IP privada de la instancia EC2."
  value       = aws_instance.ec2.private_ip
}

output "instance_public_ip" {
  description = "IP publica de la instancia (null si associate_public_ip es false)."
  value       = aws_instance.ec2.public_ip
}

output "instance_arn" {
  description = "ARN de la instancia EC2."
  value       = aws_instance.ec2.arn
}

output "instance_state" {
  description = "Estado actual de la instancia EC2."
  value       = aws_instance.ec2.instance_state
}

output "ami_id" {
  description = "ID de la AMI utilizada."
  value       = aws_instance.ec2.ami
}

output "iam_role_arn" {
  description = "ARN del rol IAM de la instancia EC2."
  value       = data.aws_iam_role.lab_role.arn
}

output "iam_role_name" {
  description = "Nombre del rol IAM de la instancia EC2."
  value       = data.aws_iam_role.lab_role.name
}

output "instance_profile_name" {
  description = "Nombre del Instance Profile IAM."
  value       = aws_iam_instance_profile.ec2_profile.name
}