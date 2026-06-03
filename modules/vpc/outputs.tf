output "vpc_id" {
  description = "ID de la VPC creada por este módulo."
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "Bloque CIDR de la VPC."
  value       = aws_vpc.main.cidr_block
}

output "subnet_ids" {
  description = "Lista de IDs de las subnets públicas creadas."
  value       = aws_subnet.public[*].id
}

output "subnet_cidrs" {
  description = "Lista de bloques CIDR de las subnets públicas."
  value       = aws_subnet.public[*].cidr_block
}

output "security_group_id" {
  description = "ID del Security Group principal."
  value       = aws_security_group.main.id
}

output "security_group_name" {
  description = "Nombre del Security Group principal."
  value       = aws_security_group.main.name
}

output "kms_key_arn" {
  description = "ARN de la llave KMS para cifrado de logs."
  value       = aws_kms_key.logs_key.arn
}

output "flow_log_id" {
  description = "ID del VPC Flow Log configurado."
  value       = aws_flow_log.vpc_flow_logs.id
}

output "cloudwatch_log_group_name" {
  description = "Nombre del grupo de logs de CloudWatch."
  value       = aws_cloudwatch_log_group.vpc_flow_logs.name
}