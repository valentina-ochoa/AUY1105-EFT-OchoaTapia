output "vpc_id" {
  description = "ID de la VPC creada por el modulo VPC."
  value       = module.vpc.vpc_id
}

output "subnet_ids" {
  description = "IDs de las subnets publicas creadas."
  value       = module.vpc.subnet_ids
}

output "security_group_id" {
  description = "ID del Security Group principal."
  value       = module.vpc.security_group_id
}

output "cloudwatch_log_group_name" {
  description = "Nombre del Log Group de VPC Flow Logs."
  value       = module.vpc.cloudwatch_log_group_name
}

output "instance_id" {
  description = "ID de la instancia EC2 creada."
  value       = module.ec2.instance_id
}

output "instance_ip" {
  description = "IP privada de la instancia EC2."
  value       = module.ec2.instance_ip
}

output "iam_role_name" {
  description = "Nombre del rol IAM asociado a la EC2."
  value       = module.ec2.iam_role_name
}