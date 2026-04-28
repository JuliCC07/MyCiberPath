---
categories:
  - "[[Ciber]]"
  - "[[ASIR]]"
tags:
  - networking
  - gns3
  - mikrotik
  - chr
  - winbox
  - instalación
created: 2026-04-23
source: "https://youtu.be/ugTBsWQImUg"
---
# MikroTik en GNS3

> 📹 **Fuente:** [[Curso GNS3]] — Vídeo #2: *How to Install MikroTik on GNS3 (CHR + Winbox)*

Guía para importar un router **MikroTik Cloud Hosted Router (CHR)** en [[GNS3]] y gestionarlo con **Winbox**.

---

## ¿Qué es MikroTik CHR?

**Cloud Hosted Router (CHR)** es una versión virtualizada de **RouterOS** de MikroTik, diseñada para ejecutarse sobre hipervisores (VMware, Hyper-V, QEMU/KVM). Es la forma ideal de usar MikroTik en entornos de laboratorio como GNS3.

- **RouterOS:** Sistema operativo de MikroTik basado en Linux
- **Licencia:** CHR es gratuito para uso con velocidad limitada (1 Mbps); suficiente para laboratorio
- **Winbox:** Herramienta GUI oficial para gestionar routers MikroTik

---

## Importar CHR en GNS3

### 1. Descargar la Appliance

- Ir al [GNS3 Marketplace](https://www.gns3.com/marketplace/appliances)
- Buscar **"MikroTik CHR"**
- Descargar el archivo `.gns3a` (appliance template)

### 2. Descargar la imagen de RouterOS

- Ir a [mikrotik.com/download](https://mikrotik.com/download)
- Sección **Cloud Hosted Router** → Descargar la imagen **Raw disk image** (`.img`)

### 3. Importar en GNS3

```
File > Import Appliance > Seleccionar el archivo .gns3a
```

- El asistente pedirá la imagen `.img` descargada
- Seleccionar **"Run this appliance on the GNS3 VM"** (recomendado)
- Confirmar la instalación

### 4. Verificar la importación

- El router MikroTik aparecerá en la barra lateral bajo la categoría **Routers**
- Arrastrar al espacio de trabajo para usarlo

---

## Acceso Inicial por Consola

Al iniciar el router CHR por primera vez:

```
MikroTik Login: admin
Password: (vacío, pulsar Enter)
```

### Comandos iniciales de verificación

```routeros
# Ver las interfaces disponibles
/interface print

# Ver la dirección IP asignada
/ip address print

# Ver los servicios activos (Winbox, SSH, etc.)
/ip service print

# Cambiar la contraseña del usuario admin
/user set admin password=TuContraseña
```

---

## Acceso con Winbox

**Winbox** es la herramienta gráfica oficial de MikroTik para gestionar sus routers.

### Requisitos

1. Descargar Winbox desde [mikrotik.com/download](https://mikrotik.com/download) (sección Winbox)
2. El router MikroTik debe estar conectado a una red accesible desde el host

### Configurar la conectividad en GNS3

1. Añadir un nodo **Cloud** al espacio de trabajo
2. Conectar una interfaz del CHR (ej. `ether1`) al nodo Cloud
3. Configurar el Cloud para usar la interfaz del host que permite comunicación (host-only adapter de la GNS3 VM)

### Conexión por Winbox

1. Abrir Winbox en el equipo host
2. Ir a la pestaña **Neighbors**
3. Winbox descubrirá el router automáticamente vía **MAC address**
4. Hacer clic en el router descubierto
5. Introducir credenciales: `admin` / (la contraseña configurada)
6. Clic en **Connect**

> **Troubleshooting:** Si no aparece en Neighbors, verificar que el modo promiscuo ("Promiscuous Mode: Allow All") esté habilitado en el adaptador de red de la VM.

---

## Comandos de Referencia

| Comando RouterOS | Descripción |
|------------------|-------------|
| `/interface print` | Lista todas las interfaces |
| `/ip address print` | Muestra las IPs asignadas |
| `/ip service print` | Muestra servicios activos (Winbox, SSH, API) |
| `/user print` | Lista los usuarios del sistema |
| `/user set admin password=X` | Cambia la contraseña de admin |
| `/system identity set name=R1` | Cambia el hostname del router |
| `/system reboot` | Reinicia el router |

---

## Notas Relacionadas

- [[GNS3]] — Emulador de redes donde se ejecuta el CHR
- [[Curso GNS3]] — Índice completo del curso
- [[GNS3 - Instalación en Ubuntu]] — Paso previo: instalar GNS3
- [[MikroTik - DHCP y Acceso a Internet]] — Siguiente paso: configurar DHCP y NAT
- [[VLANs en MikroTik]] — Configurar VLANs en MikroTik
