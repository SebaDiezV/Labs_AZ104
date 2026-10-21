# 🎓 AZ-104 — Cheat Sheet Final (Azure CLI / PowerShell)

Repaso rápido organizado por dominio. Incluye comandos clave, conceptos que más se confunden en el examen, y lecciones de los errores reales que encontraste en los laboratorios.

---

## Dominio 1 — Identidades y gobernanza (20-25%)

### Comandos clave

```powershell
# Grupos de recursos
az group create --name RG-X --location eastus
az group update --name RG-X --set tags.Entorno=Prod

# Grupos de seguridad Entra ID
az ad group create --display-name "Nombre" --mail-nickname "alias"

# RBAC con scope acotado
az role assignment create `
    --assignee-object-id $GROUP_ID `
    --assignee-principal-type Group `
    --role "Contributor" `
    --scope "/subscriptions/$sub/resourceGroups/RG-X"

az role assignment list --scope "/subscriptions/$sub/resourceGroups/RG-X" -o table

# Locks
az lock create --name Lock1 --resource-group RG-X --lock-type CanNotDelete
az lock delete --name Lock1 --resource-group RG-X

# Policy (usar .name, NO .id, para --policy)
az policy definition list --query "[?displayName=='Nombre'].name" -o tsv
az policy assignment create --name Asig1 --scope "..." --policy $policyName --params '{...}'
```

### Conceptos que más se confunden

| Concepto A | vs | Concepto B |
|---|---|---|
| **RBAC** — quién puede hacer qué | vs | **Policy** — qué configuraciones son válidas |
| **CanNotDelete** — bloquea borrado, permite modificar | vs | **ReadOnly** — bloquea todo, incluso metadatos internos |
| **Audit** — reporta incumplimiento | vs | **Deny** — bloquea la creación |
| Owner > Contributor > Reader | | Solo Owner / User Access Admin tocan permisos |

### 🔧 Lecciones de troubleshooting real
- `--policy` espera el campo **`.name`** (GUID corto), no `.id` (ruta completa) — pasar `.id` causa `PolicyDefinitionNotFound` con traceback de `NoneType`.
- RBAC es **aditivo** (nunca "el más restrictivo gana") y **deny by default** si no hay asignación explícita.

---

## Dominio 2 — Almacenamiento (15-20%)

### Comandos clave

```powershell
az storage account create --sku Standard_LRS --kind StorageV2 --access-tier Hot

# SAS — Service (clave de cuenta)
az storage container generate-sas --permissions rw --expiry $exp --auth-mode key

# SAS — User Delegation (Entra ID, sobrevive rotación de claves)
az storage container generate-sas --auth-mode login --as-user --expiry $exp

# Stored Access Policy (⚠️ SOLO admite --auth-mode key, nunca login)
az storage container policy create --permissions rw --expiry $exp --auth-mode key

# Soft delete + versioning
az storage account blob-service-properties update `
    --enable-delete-retention true --delete-retention-days 7 --enable-versioning true

az storage blob undelete --name archivo.txt   # recupera borrado (y sobrescritura, vía versioning)
az storage blob list --include dv -o table    # d=deleted, v=versions

# Lifecycle management (JSON externo, siempre)
az storage account management-policy create --policy "@lifecycle-policy.json"

# Migración masiva
azcopy copy "origen" "destino?<SAS>" --recursive
```

### Redundancia — memorizar la escalera

```
LRS (1 datacenter) → ZRS (zonas) → GRS (región secundaria) → GZRS (zonas + región secundaria)
RA- = permite LECTURA desde la región secundaria (RA-GRS, RA-GZRS)
```

### Tiers — memorizar el trade-off

```
Hot (frecuente) → Cool (30+ días) → Cold (90+ días) → Archive (180+ días, requiere REHIDRATACIÓN de horas)
```

### Conceptos que más se confunden

| Concepto A | vs | Concepto B |
|---|---|---|
| **Soft delete** — recupera algo **borrado** | vs | **Versioning** — recupera algo **sobrescrito** |
| **Service SAS** — firmado con clave de cuenta | vs | **User Delegation SAS** — firmado con Entra ID |
| **Service Endpoint** — IP pública restringida a tu VNet | vs | **Private Endpoint** — IP privada real dentro de tu subred |
| **AzCopy** — CLI, migraciones masivas | vs | **Storage Explorer** — GUI, uso puntual |
| **Azure Data Box** — offline, volúmenes enormes (TB+) con poco ancho de banda | | |

### 🔧 Lecciones de troubleshooting real
- `az storage container policy create/delete` **solo acepta `--auth-mode key`** — es de las pocas operaciones de Storage que no soporta Entra ID (`login`), porque actúa sobre el ACL clásico del contenedor.
- Con **versioning + soft delete activos a la vez**, el `undelete` sigue funcionando, pero el blob borrado puede no aparecer marcado igual que con soft delete solo — no te fíes únicamente del flag `--include d`.
- `az storage blob delete` no imprime nada en éxito — el silencio **es** la confirmación, no un fallo.

---

## Dominio 3 — Recursos de proceso (20-25%)

### Comandos clave

```powershell
# VM sin IP pública (buena práctica de seguridad)
az vm create ... --public-ip-address ""

# Cambiar tamaño (deallocate si el nuevo tamaño no está en el clúster actual)
az vm deallocate --name VM-X --resource-group RG-X
az vm resize --name VM-X --resource-group RG-X --size Standard_D2s_v3

# Bicep
az deployment group create --template-file main.bicep --parameters clave=valor
az group export --name RG-X --output json > exportado.json   # ⚠️ NO existe --output-file
az bicep decompile --file exportado.json
```

### Conceptos que más se confunden

| Concepto A | vs | Concepto B |
|---|---|---|
| **Availability Set** — protege de falla de rack/hardware, 1 datacenter | vs | **Availability Zone** — protege de falla de todo un datacenter |
| **ACI** — 1 contenedor simple, sin autoescalado | vs | **Container Apps** — microservicios, autoescala a 0 |
| Mover VM entre **RG/suscripción** — soportado directo | vs | Mover VM entre **regiones** — NO directo (Resource Mover / redeploy / Site Recovery) |
| **Encryption at Host** — cifra disco temporal y caché del host físico | vs | Cifrado estándar de disco — solo el disco administrado |

### 🔧 Lecciones de troubleshooting real
- **Hypervisor Generation**: una serie de VM nueva (ej. `Dv7`) puede requerir imagen **Gen2** (`sku: '22_04-lts-gen2'`); si usas el SKU Gen1 de la imagen con una VM que solo soporta Gen2 → `BadRequest: cannot boot Hypervisor Generation '1'`.
- `az vm create --image Ubuntu2204` (alias corto) resuelve la generación compatible automáticamente; en Bicep, tú controlas el `imageReference` explícito, así que debes acertar la variante tú mismo.

---

## Dominio 4 — Redes virtuales (15-20%)

### Comandos clave

```powershell
# Peering (bidireccional, dos comandos)
az network vnet peering create --vnet-name VNet-A --remote-vnet $vnetBId --allow-vnet-access true
az network vnet peering create --vnet-name VNet-B --remote-vnet $vnetAId --allow-vnet-access true

# NSG
az network nsg rule create --priority 100 --direction Inbound --access Allow --protocol Tcp --destination-port-ranges 22

# Bastion (requiere Standard/Premium para Native Client / az network bastion ssh)
az network bastion create --sku Standard   # Basic solo permite conexión por navegador
az extension add -n ssh                     # requerida para az network bastion ssh
az network bastion ssh --target-resource-id $vmId --auth-type ssh-key --username usr --ssh-key "ruta"

# Private Endpoint (requiere deshabilitar políticas de red primero)
az network vnet subnet update --disable-private-endpoint-network-policies true
az network private-endpoint create --group-id blob --private-connection-resource-id $storageId
```

### Conceptos que más se confunden

| Concepto A | vs | Concepto B |
|---|---|---|
| VNet Peering **NO es transitivo** | | Se necesita peering directo o NVA con "allow forwarded traffic" |
| NSG en subred **+** NSG en NIC | | Ambos deben permitir — funciona como **AND**, no OR |
| **Service Endpoint** — recurso conserva IP pública, solo restringe origen | vs | **Private Endpoint** — NIC con IP privada real en tu subred |
| **Load Balancer** — capa 4 (TCP/UDP) | vs | **Application Gateway** — capa 7 (HTTP, WAF, enrutamiento por URL) |
| IP especial de health probes: **`168.63.129.16`** — debe estar permitida en NSG | | |

### 🔧 Lecciones de troubleshooting real
- **"Connection timeout"** en SSH/RDP → casi siempre NSG o regla faltante (verifica primero que la regla existe con `nsg rule list`, y que el NSG está vinculado a la subred). "Connection refused" es distinto: el servicio ni siquiera escucha en ese puerto.
- Azure Bastion **Basic** solo permite conexión por navegador — `az network bastion ssh` (Native Client) exige **Standard o Premium** con `--enable-native-client true`.
- Private Endpoint necesita **dos pasos previos** en la subred: `--disable-private-endpoint-network-policies true` (prerrequisito técnico) — sin esto, la creación falla o se comporta mal.
- Para que el DNS normal (`cuenta.blob.core.windows.net`) resuelva a la IP privada del Private Endpoint, hace falta además una **Zona DNS Privada** vinculada — si no, el nombre sigue resolviendo a la IP pública aunque el Private Endpoint exista.

---

## Dominio 5 — Supervisión y mantenimiento (10-15%)

### Comandos clave

```powershell
# Log Analytics + agente + DCR (usar --rule-file JSON, nunca inline en PowerShell)
az monitor log-analytics workspace create --workspace-name LAW-X
az vm extension set --name AzureMonitorLinuxAgent --publisher Microsoft.Azure.Monitor
az monitor data-collection rule create --rule-file dcr.json

# Consultar métricas (no necesita agente, viene del hipervisor)
az monitor metrics list --resource $vmId --metric "Percentage CPU" --interval PT5M

# Consultar logs KQL — ⚠️ usar customerId (GUID corto), NO el resource ID largo
$workspaceGuid = az monitor log-analytics workspace show --query customerId -o tsv
az monitor log-analytics query --workspace $workspaceGuid --analytics-query "Heartbeat | ..."

# Alertas
az monitor action-group create --action email Admin correo@x.com
az monitor metrics alert create --condition "avg Percentage CPU > 85" --action AG-X

# Backup
az backup vault create --name RSV-X
az backup protection enable-for-vm --policy-name DefaultPolicy
az backup protection disable --delete-backup-data true --yes   # ⚠️ obligatorio antes de borrar el RG
```

### Conceptos que más se confunden

| Concepto A | vs | Concepto B |
|---|---|---|
| **Métricas** — numéricas, tiempo real, del hipervisor | vs | **Logs** — estructurados, vía agente, consultados con KQL |
| **Alert Rule** — la condición | vs | **Action Group** — qué hacer | vs | **Alert Processing Rule** — suprimir/modificar alertas ya generadas |
| **IP Flow Verify** — diagnóstico puntual bajo demanda | vs | **Connection Monitor** — monitoreo continuo |
| **Azure Backup** — recupera datos de un punto en el tiempo (RPO en horas) | vs | **Site Recovery** — continuidad ante falla de región completa (RPO en minutos) |

### 🔧 Lecciones de troubleshooting real
- El **Resource ID (ARM)** y el **Workspace ID / customerId** de Log Analytics son cosas distintas: `--rule-file`/asociaciones usan el Resource ID largo; `az monitor log-analytics query --workspace` exige el **customerId** (GUID corto) → confundirlos da `PathNotFoundError`.
- JSON complejo (DCRs, policies) inline en PowerShell es frágil por el escapado de comillas/paréntesis — **siempre preferir un archivo `.json` externo** (`--rule-file`, `--policy "@archivo.json"`) en vez de strings embebidos.
- El Recovery Services Vault tiene un "candado" intencional: no se puede borrar el grupo de recursos mientras haya protección de backup activa — primero `backup protection disable --delete-backup-data true`.

---

## 🧠 Reglas generales de PowerShell + Azure CLI (aprendidas en los labs)

- Continuación de línea: usa **` ` `** (backtick), nunca `\` (eso es sintaxis de Bash).
- Captura de variables: `$var = az comando --query "..." -o tsv` (no `$()` embebido en strings).
- JSON complejo → siempre archivo externo, nunca inline con comillas escapadas a mano.
- IDs de recursos built-in (policies) → usar `.name`, no `.id`, al pasarlos como parámetro.
- Comandos que no imprimen nada en éxito (`blob delete`, etc.) → verificar el resultado con un `show`/`list` después, no asumir que "sin output" significa error.

---

## ⏱️ Repaso de último momento (15 minutos antes del examen)

1. Los 3 tipos de SAS y cuál sobrevive a la rotación de claves (User Delegation).
2. Soft delete (borrado) vs Versioning (sobrescritura).
3. Backup (punto en el tiempo) vs Site Recovery (región completa).
4. RBAC (quién) vs Policy (qué) vs Locks (impide acción específica).
5. Service Endpoint (IP pública restringida) vs Private Endpoint (IP privada real).
6. NSG en subred + NIC = AND. Peering no transitivo.
