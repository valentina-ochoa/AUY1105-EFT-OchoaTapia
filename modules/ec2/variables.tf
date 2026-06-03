variable "project_name" {
  type        = string
  description = "Nombre del proyecto. Se usa como prefijo en todos los recursos creados por este módulo."

  validation {
    condition     = length(var.project_name) > 0
    error_message = "El nombre del proyecto no puede estar vacío."
  }
}

variable "subnet_id" {
  type        = string
  description = "ID de la subnet donde se desplegará la EC2. Proviene de module.vpc.subnet_ids[0]."
}

variable "security_group_ids" {
  type        = list(string)
  description = "IDs de Security Groups para la EC2. Proviene de module.vpc.security_group_id."
}

variable "instance_type" {
  type        = string
  description = "Tipo de instancia EC2. Por defecto t3.micro para cumplir políticas OPA."
  default     = "t3.micro"

  validation {
    condition     = can(regex("^[a-z][0-9][a-z]?\\.[a-z0-9]+$", var.instance_type))
    error_message = "El tipo de instancia debe tener formato válido (ej: t3.micro)."
  }
}

variable "ami_id" {
  type        = string
  description = "ID de AMI personalizada. Si está vacío usa Ubuntu 24.04 LTS automáticamente."
  default     = ""
}

variable "associate_public_ip" {
  type        = bool
  description = "Asignar IP pública a la instancia. Por defecto false por seguridad."
  default     = false
}

variable "root_volume_type" {
  type        = string
  description = "Tipo del volumen EBS raíz. Opciones: gp2, gp3, io1, io2."
  default     = "gp3"

  validation {
    condition     = contains(["gp2", "gp3", "io1", "io2"], var.root_volume_type)
    error_message = "El tipo de volumen debe ser uno de: gp2, gp3, io1, io2."
  }
}

variable "root_volume_size" {
  type        = number
  description = "Tamaño en GiB del volumen EBS raíz."
  default     = 20

  validation {
    condition     = var.root_volume_size >= 8
    error_message = "El volumen raíz debe tener al menos 8 GiB."
  }
}

variable "iam_policy_arns" {
  type        = list(string)
  description = "ARNs de políticas IAM adicionales para adjuntar al rol EC2."
  default     = []
}

variable "user_data" {
  type        = string
  description = "Script de User Data al iniciar la instancia. Dejar vacío para no usar."
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "Etiquetas adicionales para todos los recursos del módulo."
  default     = {}
}