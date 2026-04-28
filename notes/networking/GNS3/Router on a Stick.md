---
categories:
  - "[[Ciber]]"
  - "[[ASIR]]"
tags:
  - networking
  - gns3
  - cisco
  - vlans
  - roas
  - nat
  - subinterfaces
  - inter-vlan
  - ccna
created: 2026-04-23
source: "https://youtu.be/iHi4avmmCrk"
---
# Router on a Stick (ROAS)

> 📹 **Fuente:** [[Curso GNS3]] — Vídeo #7: *VLANs in Cisco | Router on a Stick, NAT and Internet Access*

**Router on a Stick (ROAS)** es un método de **enrutamiento inter-VLAN** que utiliza **un solo enlace físico** entre un router y un switch, dividido en múltiples **subinterfaces** lógicas, una por cada [[VLANs|VLAN]].

---

## ¿Cómo funciona?

```
                    TRUNK (802.1Q)
[Cisco Router] Gi0/0 ←————————————→ Gi0/0 [Cisco Switch]
   Gi0/0.10 → VLAN 10                     |
   Gi0/0.20 → VLAN 20                Gi0/1 (Access VLAN 10) → [PC1]
   Gi0/1 → Internet (NAT)            Gi0/2 (Access VLAN 20) → [PC2]
```

1. El switch envía tráfico de todas las VLANs por un **trunk** [[IEEE 802.1Q]]
2. El router recibe las tramas etiquetadas en su interfaz física
3. Cada **subinterfaz** del router procesa el tráfico de una VLAN específica
4. El router **enruta** entre las subinterfaces (inter-VLAN routing)

---

## Configuración del Switch Cisco

### 1. Crear las VLANs

```cisco
enable
configure terminal

vlan 10
  name DATOS
  exit
vlan 20
  name GESTION
  exit
```

### 2. Puertos de acceso para los PCs

```cisco
interface GigabitEthernet0/1
  switchport mode access
  switchport access vlan 10
  no shutdown
  exit

interface GigabitEthernet0/2
  switchport mode access
  switchport access vlan 20
  no shutdown
  exit
```

### 3. Puerto trunk hacia el router

```cisco
interface GigabitEthernet0/0
  switchport mode trunk
  switchport trunk encapsulation dot1q
  switchport trunk allowed vlan 10,20
  no shutdown
  exit
```

---

## Configuración del Router Cisco

### 1. Activar la interfaz física (sin IP)

```cisco
enable
configure terminal

interface GigabitEthernet0/0
  no shutdown
  exit
```

> **Importante:** La interfaz física **no lleva dirección IP**. Las IPs van en las subinterfaces.

### 2. Crear las subinterfaces

```cisco
! Subinterfaz para VLAN 10
interface GigabitEthernet0/0.10
  encapsulation dot1q 10
  ip address 192.168.10.1 255.255.255.0
  exit

! Subinterfaz para VLAN 20
interface GigabitEthernet0/0.20
  encapsulation dot1q 20
  ip address 192.168.20.1 255.255.255.0
  exit
```

> **`encapsulation dot1q <vlan-id>`** le dice al router qué etiqueta [[IEEE 802.1Q]] corresponde a esa subinterfaz.

### 3. Configurar la interfaz WAN (hacia Internet)

```cisco
interface GigabitEthernet0/1
  ip address dhcp
  no shutdown
  exit
```

---

## Configuración de [[NAT]] (Acceso a Internet)

Para que los dispositivos de las VLANs accedan a Internet, se configura **NAT Overload (PAT)**:

### 1. Definir interfaces NAT

```cisco
! Las subinterfaces son "inside" (red interna)
interface GigabitEthernet0/0.10
  ip nat inside
  exit

interface GigabitEthernet0/0.20
  ip nat inside
  exit

! La interfaz WAN es "outside" (hacia Internet)
interface GigabitEthernet0/1
  ip nat outside
  exit
```

### 2. Crear la Access Control List (ACL)

```cisco
! Permitir las redes de las VLANs
access-list 1 permit 192.168.10.0 0.0.0.255
access-list 1 permit 192.168.20.0 0.0.0.255
```

> **`0.0.0.255`** es la **Wildcard Mask** (inversa de la máscara de subred `255.255.255.0`). Ver: [[Routing Protocols#OSPF|Wildcard Mask en OSPF]]

### 3. Activar NAT Overload

```cisco
ip nat inside source list 1 interface GigabitEthernet0/1 overload
```

| Elemento | Significado |
|----------|-------------|
| `source list 1` | Usa la ACL 1 para identificar el tráfico a traducir |
| `interface Gi0/1` | Usa la IP de esta interfaz como IP pública |
| `overload` | Permite múltiples traducciones simultáneas (PAT) |

---

## Configuración de la Native VLAN (Opcional)

Hay dos métodos para configurar la **native VLAN** en el router:

### Método 1: En la subinterfaz

```cisco
interface GigabitEthernet0/0.99
  encapsulation dot1q 99 native
  ip address 192.168.99.1 255.255.255.0
  exit
```

### Método 2: En la interfaz física

```cisco
interface GigabitEthernet0/0
  ip address 192.168.99.1 255.255.255.0
  exit
```

> El tráfico de la native VLAN se envía **sin etiquetar** por el trunk. Ver: [[VLANs#Notas Relacionadas|VLANs]]

---

## Verificación Completa

### En el Switch

```cisco
show vlan brief                    ! VLANs y puertos asignados
show interfaces trunk              ! Estado del trunk
show interfaces Gi0/0 switchport   ! Detalle del puerto trunk
```

### En el Router

```cisco
show ip interface brief            ! Estado de interfaces y subinterfaces
show ip route                      ! Tabla de rutas (redes connected)
show ip nat translations           ! Traducciones NAT activas
show ip nat statistics             ! Estadísticas de NAT
show running-config                ! Configuración completa
```

### Desde los PCs/VPCS

```
# Configurar gateway (o recibir por DHCP)
ip 192.168.10.10 255.255.255.0 192.168.10.1

# Probar conectividad
ping 192.168.10.1     # Gateway propio
ping 192.168.20.1     # Gateway otra VLAN (inter-VLAN routing)
ping 192.168.20.10    # PC en otra VLAN
ping 8.8.8.8          # Internet (requiere NAT configurado)
```

---

## ROAS vs Multilayer Switch

| Característica | Router on a Stick | Switch Multicapa (SVI) |
|----------------|-------------------|-----------------------|
| **Enlace físico** | Un solo cable (cuello de botella potencial) | Múltiples interfaces internas |
| **Rendimiento** | Limitado por el ancho de banda del trunk | Switching a velocidad de hardware |
| **Complejidad** | Simple, ideal para redes pequeñas | Requiere configurar SVIs e `ip routing` |
| **Uso ideal** | Labs, redes pequeñas, CCNA | Redes de producción, campus |

> Para la alternativa con SVI, ver [[VLANs#Multilayer switches|VLANs — Multilayer Switch]]

---

## Notas Relacionadas

- [[VLANs]] — Conceptos generales y configuración inter-VLAN con SVI
- [[IEEE 802.1Q]] — Estándar de etiquetado de tramas
- [[NAT]] — Network Address Translation
- [[Cisco IOS en GNS3]] — Instalar dispositivos Cisco en GNS3
- [[VLANs - Interoperabilidad MikroTik y Cisco]] — Alternativa multi-vendor
- [[Routing Protocols]] — Enrutamiento dinámico (wildcard masks)
- [[DTP & VTP]] — Protocolos de trunking
- [[Curso GNS3]] — Índice del curso
- [[Life of a packet]] — Cómo el tráfico cruza VLANs a nivel de paquete
