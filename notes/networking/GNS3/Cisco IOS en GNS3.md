---
categories:
  - "[[Ciber]]"
  - "[[ASIR]]"
tags:
  - networking
  - gns3
  - cisco
  - ios
  - dynamips
  - qemu
  - instalación
created: 2026-04-23
source: "https://youtu.be/XpfJgg_W2ak"
---
# Cisco IOS en GNS3

> 📹 **Fuente:** [[Curso GNS3]] — Vídeo #4: *Cómo Instalar Router y Switch Cisco (IOS)*

Guía para importar y configurar **routers y switches Cisco** en [[GNS3]] usando imágenes IOS reales.

---

## Tipos de Imágenes Cisco en GNS3

| Tipo | Motor | Uso | Peso |
|------|-------|-----|------|
| **IOS clásico** (.bin/.image) | Dynamips | Routers legacy (c3725, c7200) | Ligero (~60 MB) |
| **vIOS Router** (.qcow2) | QEMU | Router moderno virtualizado | Medio (~150 MB) |
| **vIOS L2 Switch** (.qcow2) | QEMU | Switch L2/L3 moderno | Medio (~100 MB) |
| **IOU/IOL** (.bin) | IOU | Cisco IOS on Unix (sin GUI) | Muy ligero (~30 MB) |

> **Recomendación:** Para laboratorios CCNA, usar **vIOS L2** para switches (comportamiento más fiel que EtherSwitch).

---

## Método 1: Importar Router Cisco (Dynamips)

### Paso a paso

1. Ir a `Edit > Preferences`
2. Seleccionar **Dynamips > IOS routers**
3. Clic en **New**
4. Seleccionar **"Run this IOS router on the GNS3 VM"** (recomendado)
5. Buscar y seleccionar la imagen IOS (`.bin` o `.image`)
6. Configurar la **RAM** según el modelo:
   - c3725: 256 MB
   - c7200: 512 MB
7. Configurar **Slots e Interfaces:**
   - Para switching: añadir módulo **NM-16ESW** (16 puertos Ethernet Switch)
8. Finalizar la configuración

### ⚠️ Idle-PC (CRÍTICO)

**Idle-PC** evita que la emulación consuma el **100% de la CPU** del host.

```
1. Arrastra el router al espacio de trabajo
2. Enciéndelo y espera a que arranque completamente
3. Clic derecho > "Idle-PC finder" o "Auto Idle-PC"
4. Seleccionar el valor marcado con asterisco (*)
```

> Si no configuras Idle-PC, cada router consumirá un núcleo completo de CPU.

---

## Método 2: Importar con Appliance (.gns3a)

### Paso a paso

1. Descargar el archivo `.gns3a` del [GNS3 Marketplace](https://www.gns3.com/marketplace/appliances)
2. `File > Import Appliance` > Seleccionar el `.gns3a`
3. El asistente pedirá la imagen correspondiente
4. Seleccionar ejecución en **GNS3 VM**
5. Completar la importación

---

## Router como Switch (EtherSwitch)

Si no tienes imágenes vIOS L2, puedes convertir un router Cisco clásico en un switch básico:

1. Al configurar el router (Dynamips), ir a la sección de **Slots**
2. Añadir el módulo **NM-16ESW** en un slot disponible
3. Este módulo proporciona **16 puertos FastEthernet** con capacidad de switching

> **Limitación:** EtherSwitch no soporta todas las funciones de un switch real (ej. algunas funciones STP avanzadas pueden no estar disponibles).

---

## Configuración Básica del Router Cisco

Una vez arrastrado y encendido el dispositivo, acceder a la CLI:

```cisco
! Entrar al modo privilegiado
enable

! Entrar al modo de configuración global
configure terminal

! Asignar un hostname
hostname R1

! Configurar una interfaz
interface GigabitEthernet0/0
  ip address 192.168.1.1 255.255.255.0
  no shutdown
  exit

! Guardar la configuración
end
write memory
```

---

## Configuración Básica del Switch Cisco

```cisco
enable
configure terminal

! Asignar un hostname
hostname SW1

! Crear una VLAN
vlan 10
  name DATOS
  exit

! Configurar un puerto de acceso
interface FastEthernet0/1
  switchport mode access
  switchport access vlan 10
  no shutdown
  exit

! Configurar un puerto trunk
interface FastEthernet0/0
  switchport mode trunk
  switchport trunk allowed vlan 10,20
  no shutdown
  exit

! Ver el estado de las VLANs
end
show vlan brief
```

---

## Comandos de Verificación

| Comando Cisco IOS | Descripción |
|-------------------|-------------|
| `show version` | Información del IOS y hardware |
| `show ip interface brief` | Estado rápido de todas las interfaces |
| `show interfaces status` | Estado de puertos del switch |
| `show running-config` | Configuración activa |
| `show vlan brief` | VLANs configuradas |
| `show interfaces trunk` | Puertos trunk activos |
| `copy running-config startup-config` | Guardar configuración |
| `write memory` | Guardar configuración (alias) |

---

## Notas Relacionadas

- [[GNS3]] — Entorno de emulación
- [[Curso GNS3]] — Índice completo del curso
- [[GNS3 - Instalación en Ubuntu]] — Instalación de GNS3
- [[Switch Interfaces]] — Comandos de interfaces de switch
- [[VLANs]] — Configuración de VLANs en Cisco
- [[Router on a Stick]] — Enrutamiento inter-VLAN con Cisco
- [[VLANs - Interoperabilidad MikroTik y Cisco]] — VLANs multi-vendor
