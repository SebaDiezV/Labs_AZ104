# Laboratorios prácticos AZ-104: Administrador de Microsoft Azure

Laboratorios que hice mientras me preparaba para la certificación **Microsoft Certified: Azure Administrator Associate (AZ-104)**, que ya aprobé. Complementan los labs oficiales de Microsoft Learn: aquí el foco está en construir cada escenario por línea de comandos y documentar los errores reales que aparecieron en el camino.

> Proyecto personal e independiente. No es un curso oficial de Microsoft.

## Qué encontrarás aquí

Cinco laboratorios, uno por cada dominio del examen, ejecutados con **Azure CLI en PowerShell** (más Bicep y archivos JSON de configuración). Cada uno parte de un escenario de oficina (una empresa ficticia, "Contoso Logística") y explica el porqué de cada paso, no solo el comando.

| Lab | Dominio del examen | Qué practiqué |
|---|---|---|
| [01 Gobernanza](./01-gobernanza) | Identidades y gobernanza | Grupos de recursos, tags, RBAC con scope acotado, resource locks, Azure Policy |
| [02 Compute](./02-compute) | Recursos de proceso | VNet, NSG, VM por CLI y por **Bicep**, exportar un grupo de recursos y decompilar a Bicep |
| [03 Storage](./03-storage) | Almacenamiento | Los 3 tipos de SAS, stored access policy, soft delete vs versioning, lifecycle management |
| [04 Redes](./04-redes) | Redes virtuales | VNet peering, VM sin IP pública, **Azure Bastion**, Service Endpoint vs Private Endpoint |
| [05 Monitoreo](./05-monitoreo) | Supervisión y mantenimiento | Log Analytics, Data Collection Rule, KQL, alertas con Action Group, Azure Backup |

Además: [`az104-cheatsheet.md`](./az104-cheatsheet.md) con comandos clave por dominio, los conceptos que más se confunden y las lecciones de troubleshooting.

## Problemas reales que resolví

Esta es la parte que más me enseñó. Los errores no fueron de copy-paste: cada uno obligó a entender cómo funciona el servicio por debajo.

| Lab | Síntoma | Causa real | Solución |
|---|---|---|---|
| 01 | `PolicyDefinitionNotFound` al asignar una policy built-in | `--policy` recibió el `.id` completo y la CLI resolvió mal el identificador | Capturar el campo `.name` (GUID corto) en lugar de `.id` |
| 02 | `connection timeout` por SSH a la VM | La regla del NSG nunca se había creado | Verificar con `az network nsg rule list` antes de asumir un problema de red más profundo |
| 02 | `cannot boot Hypervisor Generation '1'` en el despliegue Bicep | Un tamaño de VM de serie nueva exige imagen Gen2 y el SKU de imagen era Gen1 | Cambiar el SKU de la imagen a la variante `-gen2` |
| 02 | `unrecognized arguments: --output-file` en `az group export` | Ese comando no tiene el flag, la salida va por stdout | Redirigir con `Out-File` o `>` |
| 03 | `'login' is not a valid value for '--auth-mode'` | Las stored access policies actúan sobre el ACL clásico del contenedor, que solo admite clave de cuenta | Usar `--auth-mode key` |
| 03 | `--include d` no mostraba el blob borrado | Con versioning y soft delete activos a la vez, el rastro del borrado no se ve igual que con soft delete solo | Verificar con `blob show` y `undelete`, y listar con `--include dv` |
| 04 | `az network bastion ssh` fallaba | Faltaba la extensión `ssh` y el SKU Basic no admite Native Client | `az extension add -n ssh` y subir Bastion a Standard con native client |
| 05 | Error de parseo al crear la DCR con JSON inline | El escapado de comillas y paréntesis en PowerShell rompe el string | Mover el JSON a un archivo y usar `--rule-file` |
| 05 | `PathNotFoundError` al consultar con KQL | `az monitor log-analytics query` exige el `customerId` (GUID), no el resource ID ARM | Obtener el valor con `--query customerId` |

## Requisitos

- Una suscripción de Azure que puedas usar para pruebas
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) (y `az bicep install`)
- PowerShell (los comandos usan backtick `` ` `` para continuar línea, no `\`)
- Cliente SSH
- Iniciar sesión con `az login`

## Costos y limpieza

Estos laboratorios crean recursos reales que cuestan dinero. Los más caros por hora son **Azure Bastion** (Lab 04) y las VMs serie D (Labs 02, 04 y 05). Cada laboratorio termina con una sección de limpieza. Antes de cerrar la sesión, comprueba que no quede nada corriendo:

```powershell
az group list --output table
```

Un detalle del Lab 05: el Recovery Services Vault no se puede borrar mientras proteja una VM, así que hay que deshabilitar la protección con `--delete-backup-data true` antes de eliminar el grupo de recursos.

## Seguridad de este repositorio

Los archivos de ejemplo usan placeholders (`<SUBSCRIPTION-ID>`, `tu-correo@ejemplo.com`, `REEMPLAZAR_WORKSPACE_ID`). Reemplázalos con tus propios valores al ejecutar, y no subas a un repositorio público IDs de suscripción reales, llaves privadas ni exports sin revisar.

## Próximos pasos

Mi ruta hacia Cloud Engineer, en orden: **Linux**, **Docker**, **Terraform sobre Azure** (el provider `azurerm`, rehaciendo estos mismos laboratorios de forma declarativa) y profundización en Azure con identidad avanzada (Entra ID, Conditional Access, PIM).

## Referencias

- [Guía de estudio oficial AZ-104](https://learn.microsoft.com/es-es/credentials/certifications/resources/study-guides/az-104)
- [Certificación Azure Administrator Associate](https://learn.microsoft.com/es-es/credentials/certifications/azure-administrator/)
