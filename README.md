# AUY1105-Ev1-Tapia-Ochoa

## Infraestructura como Código II — Evaluación Parcial N°2
**Implementación de Módulos Terraform**

---

## Objetivo

Repositorio que implementa módulos Terraform reutilizables para desplegar infraestructura en AWS. Los módulos están en `modules/` y son orquestados desde la raíz del repositorio.

## Integrantes
- Cristóbal Tapia
- Valentina Ochoa

---

## Estructura
AUY1105-Ev1-Tapia-Ochoa/
├── main.tf                  # Orquesta los módulos VPC y EC2
├── variables.tf             # Variables de alto nivel del proyecto
├── outputs.tf                # Outputs consolidados
├── versions.tf                # Versión de Terraform y provider AWS
├── modules/
│   ├── vpc/                   # Módulo de red (VPC, subnets, Security Group, KMS, CloudWatch, Flow Logs)
│   └── ec2/                   # Módulo de cómputo (EC2, IAM Role, Instance Profile)
├── policies/
│   ├── ec2.rego               # Política OPA: solo permite instancias t3.micro
│   └── ssh.rego               # Política OPA: bloquea SSH público (0.0.0.0/0)
├── examples/
│   └── main.tf                # Ejemplo funcional de uso de ambos módulos juntos
├── .github/workflows/
│   └── pipeline.yaml          # Pipeline CI: TFLint → Checkov → Terraform Validate + OPA
└── CHANGELOG.md               # Historial de versiones (semantic versioning)

## Módulos

### `modules/vpc`
Crea la red base: VPC, subnets públicas, Security Group, KMS, CloudWatch Logs y Flow Logs. Ver documentación detallada en [`modules/vpc/README.md`](modules/vpc/README.md).

### `modules/ec2`
Crea una instancia EC2 con su IAM Role e Instance Profile asociados. Ver documentación detallada en [`modules/ec2/README.md`](modules/ec2/README.md).

## Políticas de seguridad (OPA)

Este repositorio usa [Open Policy Agent](https://www.openpolicyagent.org/) para aplicar reglas de seguridad automáticas antes de aceptar cambios:

- **`ec2.rego`**: rechaza cualquier instancia EC2 que no sea `t3.micro`.
- **`ssh.rego`**: rechaza cualquier Security Group que exponga el puerto 22 (SSH) a `0.0.0.0/0`.

Estas políticas se evalúan automáticamente en cada Pull Request mediante el pipeline de GitHub Actions.

## Pipeline CI/CD

Cada Pull Request hacia `main` ejecuta 3 etapas en orden:

1. **TFLint** — análisis estático de sintaxis y buenas prácticas de Terraform.
2. **Checkov** — escaneo de vulnerabilidades y errores de configuración de seguridad.
3. **Terraform Validate + OPA** — valida la sintaxis y evalúa las políticas de seguridad (`policies/`) contra los cambios propuestos. Si alguna política se viola, el pipeline falla y bloquea el merge.

## Versionado

Este proyecto sigue [Semantic Versioning](https://semver.org/) (`MAJOR.MINOR.PATCH`). Ver historial completo en [`CHANGELOG.md`](CHANGELOG.md).

## Cómo usar

Ver ejemplo funcional completo en [`examples/main.tf`](examples/main.tf), donde se orquestan ambos módulos juntos.

## Requisitos

- Terraform >= (ver [`versions.tf`](versions.tf))
- Cuenta AWS con credenciales configuradas
- [OPA CLI](https://www.openpolicyagent.org/docs/latest/#running-opa) (para evaluar políticas localmente, opcional)