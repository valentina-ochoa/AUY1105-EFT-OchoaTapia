# Módulo EC2

Módulo de cómputo que crea una instancia EC2 con su rol IAM asociado, siguiendo buenas prácticas de seguridad (disco cifrado, IMDSv2 obligatorio, sin IP pública por defecto).

## Recursos que crea

- `aws_iam_instance_profile` — Instance Profile que conecta el rol `LabRole` con la instancia EC2.
- `aws_instance` — La instancia EC2, con AMI de Ubuntu 24.04 LTS por defecto (o una AMI personalizada si se especifica).

## Uso básico

```hcl
module "ec2" {
  source = "./modules/ec2"

  project_name        = "mi-proyecto"
  subnet_id           = module.vpc.subnet_ids[0]
  security_group_ids  = [module.vpc.security_group_id]

  instance_type        = "t3.micro"
  associate_public_ip  = false
  root_volume_type     = "gp3"
  root_volume_size     = 20

  tags = {
    Environment = "dev"
    Owner       = "valentina-ochoa"
  }
}
```

> **Importante:** este módulo depende de `modules/vpc` — necesitas pasarle `subnet_id` y `security_group_ids` que provienen de sus outputs.

## Variables de entrada

| Nombre | Tipo | Default | Descripción |
|---|---|---|---|
| `project_name` | `string` | *(requerida)* | Prefijo usado en el nombre de todos los recursos. No puede estar vacío. |
| `subnet_id` | `string` | *(requerida)* | ID de la subnet donde se despliega la EC2. Normalmente `module.vpc.subnet_ids[0]`. |
| `security_group_ids` | `list(string)` | *(requerida)* | Security Groups a asociar. Normalmente `[module.vpc.security_group_id]`. |
| `instance_type` | `string` | `"t3.micro"` | Tipo de instancia. El valor por defecto cumple con la política OPA `ec2.rego`. |
| `ami_id` | `string` | `""` | AMI personalizada. Si se deja vacío, usa Ubuntu 24.04 LTS más reciente. |
| `associate_public_ip` | `bool` | `false` | Asigna IP pública. Desactivado por defecto por seguridad. |
| `root_volume_type` | `string` | `"gp3"` | Tipo de volumen EBS raíz. |
| `root_volume_size` | `number` | `20` | Tamaño en GiB del volumen raíz. Mínimo 8 GiB. |
| `iam_policy_arns` | `list(string)` | `[]` | ARNs de políticas IAM adicionales (reservado para extensión futura). |
| `user_data` | `string` | `""` | Script de arranque (user data). |
| `tags` | `map(string)` | `{}` | Etiquetas adicionales aplicadas a la instancia. |

## Outputs

| Nombre | Descripción |
|---|---|
| `instance_id` | ID de la instancia EC2. |
| `instance_ip` | IP privada de la instancia. |
| `instance_public_ip` | IP pública (`null` si `associate_public_ip = false`). |
| `instance_arn` | ARN de la instancia. |
| `instance_state` | Estado actual de la instancia. |
| `ami_id` | ID de la AMI utilizada. |
| `iam_role_arn` | ARN del rol IAM (`LabRole`) asociado. |
| `iam_role_name` | Nombre del rol IAM asociado. |
| `instance_profile_name` | Nombre del Instance Profile IAM creado. |

## Dependencias

- **`modules/vpc`**: requiere `subnet_id` y `security_group_ids` provenientes de este módulo.
- Requiere el rol `LabRole` preexistente en la cuenta AWS.

## Seguridad

- Volumen raíz cifrado (`encrypted = true`) por defecto.
- IMDSv2 obligatorio (`http_tokens = "required"`).
- Monitoreo detallado y optimización EBS habilitados por defecto.
- Sin IP pública por defecto.
- El `instance_type` por defecto cumple con la política OPA que restringe el tipo de instancia.
