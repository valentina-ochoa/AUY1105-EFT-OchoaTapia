# Módulo VPC

Módulo de red que crea una VPC funcional en AWS, con subnets públicas, un Security Group parametrizable, y registro de tráfico (VPC Flow Logs) hacia CloudWatch.

## Recursos que crea

- `aws_vpc` — VPC principal, con soporte DNS habilitado.
- `aws_default_security_group` — Security Group por defecto de la VPC, restringido (sin ingress ni egress) por buenas prácticas de seguridad.
- `aws_subnet` (múltiples) — Subnets públicas, una por cada CIDR en `public_subnet_cidrs`.
- `aws_security_group` — Security Group principal, con reglas de ingress configurables dinámicamente y egress abierto por defecto.
- `aws_kms_key` — Key dedicada para cifrar los logs de CloudWatch.
- `aws_cloudwatch_log_group` — Grupo de logs donde se almacenan los VPC Flow Logs, cifrado con la KMS key anterior.
- `aws_flow_log` — Flow Log que captura todo el tráfico (`ALL`) de la VPC hacia CloudWatch.

## Uso básico

```hcl
module "vpc" {
  source = "./modules/vpc"

  project_name         = "mi-proyecto"
  vpc_cidr             = "10.1.0.0/16"
  public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24"]
  availability_zones   = ["us-east-1a", "us-east-1b"]

  ingress_rules = [
    {
      description = "Allow SSH from internal networks"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/8"]
    }
  ]

  log_retention_days = 365

  tags = {
    Environment = "dev"
    Owner       = "valentina-ochoa"
  }
}
```

## Variables de entrada

| Nombre | Tipo | Default | Descripción |
|---|---|---|---|
| `project_name` | `string` | *(requerida)* | Prefijo usado en el nombre de todos los recursos. No puede estar vacío. |
| `vpc_cidr` | `string` | `"10.1.0.0/16"` | Bloque CIDR de la VPC. Debe ser un CIDR válido. |
| `public_subnet_cidrs` | `list(string)` | `["10.1.1.0/24"]` | Lista de bloques CIDR para las subnets públicas. |
| `availability_zones` | `list(string)` | `[]` | AZs a usar. Debe coincidir en cantidad con `public_subnet_cidrs`. |
| `sg_description` | `string` | `"Security Group gestionado por el modulo VPC"` | Descripción del Security Group principal. |
| `ingress_rules` | `list(object)` | Ver default (SSH desde `10.0.0.0/8`) | Reglas de ingress. Cada objeto requiere `description`, `from_port`, `to_port`, `protocol`, `cidr_blocks`. |
| `log_retention_days` | `number` | `365` | Días de retención de los Flow Logs. |
| `tags` | `map(string)` | `{}` | Etiquetas adicionales aplicadas a todos los recursos. |

## Outputs

| Nombre | Descripción |
|---|---|
| `vpc_id` | ID de la VPC creada. |
| `vpc_cidr` | Bloque CIDR de la VPC. |
| `subnet_ids` | Lista de IDs de las subnets públicas. |
| `subnet_cidrs` | Lista de bloques CIDR de las subnets públicas. |
| `security_group_id` | ID del Security Group principal — se usa como input en `modules/ec2`. |
| `security_group_name` | Nombre del Security Group principal. |
| `flow_log_id` | ID del VPC Flow Log. |
| `cloudwatch_log_group_name` | Nombre del grupo de logs de CloudWatch. |

## Dependencias

- Requiere el rol `LabRole` preexistente en la cuenta AWS (usado para publicar los Flow Logs en CloudWatch). Estándar en AWS Academy Learner Lab.
- No depende de otros módulos de este repositorio — es la base sobre la que se despliega `modules/ec2`.

## Seguridad

- El Security Group por defecto de la VPC queda completamente restringido.
- El Security Group principal solo permite el ingress definido explícitamente.
- Los logs se cifran con una KMS key dedicada, con rotación automática habilitada.
- El tráfico queda auditado vía VPC Flow Logs con retención configurable.