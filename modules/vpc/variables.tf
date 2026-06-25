variable "project_name" {
  type        = string
  description = "Nombre del proyecto. Se usa como prefijo en todos los recursos creados por este módulo."

  validation {
    condition     = length(var.project_name) > 0
    error_message = "El nombre del proyecto no puede estar vacío."
  }
}

variable "vpc_cidr" {
  type        = string
  description = "Bloque CIDR de la VPC. Ejemplo: '10.1.0.0/16'."
  default     = "10.1.0.0/16"

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "El valor de vpc_cidr debe ser un bloque CIDR válido."
  }
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Lista de bloques CIDR para las subnets públicas."
  default     = ["10.1.1.0/24"]
}

variable "availability_zones" {
  type        = list(string)
  description = "Lista de Availability Zones. Debe coincidir en cantidad con public_subnet_cidrs."
  default     = []
}

variable "sg_description" {
  type        = string
  description = "Descripcion del Security Group principal del modulo."
  default     = "Security Group gestionado por el modulo VPC"
}

variable "ingress_rules" {
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  description = "Lista de reglas de ingress para el Security Group."
  default = [
    {
      description = "Allow SSH from internal networks"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/8"]
    }
  ]
}

variable "log_retention_days" {
  type        = number
  description = "Dias de retencion para los VPC Flow Logs en CloudWatch."
  default     = 365

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_days)
    error_message = "El valor debe ser uno de los valores permitidos por CloudWatch."
  }
}

variable "tags" {
  type        = map(string)
  description = "Etiquetas adicionales para todos los recursos del modulo."
  default     = {}
}