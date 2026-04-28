---
categories:
  - "[[Ciber]]"
  - "[[ASIR]]"
tags:
  - networking
  - gns3
  - vlans
  - mikrotik
  - cisco
  - trunk
  - interoperabilidad
  - 802.1q
created: 2026-04-23
source: "https://youtu.be/tWl-4_FtQjA"
---
# VLANs — Interoperabilidad MikroTik y Cisco

> 📹 **Fuente:** [[Curso GNS3]] — Vídeo #6: *VLANs entre MikroTik y Cisco | Trunk, Tagged y Untagged*

Configuración de [[VLANs]] en un entorno **multi-vendor** donde un router [[MikroTik en GNS3|MikroTik]] y un switch [[Cisco IOS en GNS3|Cisco]] deben trabajar juntos usando el estándar [[IEEE 802.1Q]].

---

## Concepto: ¿Por qué funciona?

Ambos fabricantes implementan el estándar **[[IEEE 802.1Q]]** para el etiquetado de tramas. Esto garantiza la interoperabilidad siempre que:

1. Los **VLAN IDs** sean idénticos en ambos dispositivos
2. El enlace entre ellos esté configurado como **trunk** (tagged) en ambos lados
3. Ambos usen la misma **encapsulación** (802.1Q es el estándar universal)

### Terminología equivalente

| MikroTik | Cisco | Significado |
|----------|-------|-------------|
| **Tagged** | **Trunk** | Puerto que transporta múltiples VLANs con etiquetas |
| **Untagged** | **Access** | Puerto que pertenece a una sola VLAN |
| **PVID** | **Native VLAN** | VLAN por defecto para tráfico sin etiquetar |
| **Bridge VLAN Table** | **VLAN Database** | Base de datos de VLANs |
| **VLAN Filtering** | (Implícito) | Procesamiento de etiquetas 802.1Q |

---

## Topología del Laboratorio

```
                    TRUNK (802.1Q)
[MikroTik] ether2 ←————————————→ Gi0/0 [Cisco Switch]
  (Router)                                  |
  ether1 → Internet                    Gi0/1 (Access VLAN 10) → [PC1]
                                       Gi0/2 (Access VLAN 20) → [PC2]
```

---

## Configuración del Switch Cisco (Capa 2)

### 1. Crear las VLANs

```cisco
enable
configure terminal

vlan 10
  name DATOS
  exit

vlan 20
  name VOZ
  exit
```

### 2. Configurar puertos de acceso (Untagged)

```cisco
! Puerto para PC de VLAN 10
interface GigabitEthernet0/1
  switchport mode access
  switchport access vlan 10
  no shutdown
  exit

! Puerto para PC de VLAN 20
interface GigabitEthernet0/2
  switchport mode access
  switchport access vlan 20
  no shutdown
  exit
```

### 3. Configurar el puerto trunk hacia MikroTik

```cisco
interface GigabitEthernet0/0
  switchport mode trunk
  switchport trunk encapsulation dot1q
  switchport trunk allowed vlan 10,20
  no shutdown
  exit
```

### 4. Verificar la configuración

```cisco
show vlan brief
show interfaces trunk
show interfaces GigabitEthernet0/0 switchport
```

---

## Configuración del Router MikroTik

### 1. Crear las interfaces VLAN sobre la interfaz trunk

```routeros
# Crear VLANs sobre ether2 (conectada al switch Cisco)
/interface vlan add name=vlan10 vlan-id=10 interface=ether2
/interface vlan add name=vlan20 vlan-id=20 interface=ether2
```

> **Nota:** En este escenario, las VLANs se crean directamente sobre la interfaz física `ether2` (sin bridge), ya que el MikroTik actúa como **router** inter-VLAN, no como switch.

### 2. Asignar IPs (Gateway de cada VLAN)

```routeros
/ip address add address=192.168.10.1/24 interface=vlan10
/ip address add address=192.168.20.1/24 interface=vlan20
```

### 3. Configurar DHCP para cada VLAN

```routeros
# DHCP VLAN 10
/ip pool add name=pool10 ranges=192.168.10.10-192.168.10.254
/ip dhcp-server network add address=192.168.10.0/24 gateway=192.168.10.1 dns-server=8.8.8.8
/ip dhcp-server add name=dhcp10 interface=vlan10 address-pool=pool10 disabled=no

# DHCP VLAN 20
/ip pool add name=pool20 ranges=192.168.20.10-192.168.20.254
/ip dhcp-server network add address=192.168.20.0/24 gateway=192.168.20.1 dns-server=8.8.8.8
/ip dhcp-server add name=dhcp20 interface=vlan20 address-pool=pool20 disabled=no
```

### 4. NAT Masquerade para acceso a Internet

```routeros
/ip firewall nat add chain=srcnat out-interface=ether1 action=masquerade
```

---

## Verificación End-to-End

### En el Switch Cisco

```cisco
show vlan brief              ! Verificar VLANs creadas
show interfaces trunk        ! Verificar que el trunk está activo
show mac address-table       ! Ver MACs aprendidas por VLAN
```

### En el Router MikroTik

```routeros
/interface vlan print         # Ver interfaces VLAN
/ip address print             # Verificar IPs por VLAN
/ip dhcp-server lease print   # Ver leases DHCP activos
/ping 192.168.10.x            # Probar conectividad
```

### Desde los VPCS/PCs

```
dhcp                ! Obtener IP por DHCP
show ip             ! Verificar IP asignada y gateway
ping 192.168.10.1   ! Ping al gateway (MikroTik)
ping 8.8.8.8        ! Ping a Internet
ping 192.168.20.x   ! Ping inter-VLAN (funcionará si no hay firewall)
```

---

## Troubleshooting

| Problema | Causa probable | Solución |
|----------|---------------|----------|
| VPCS no recibe IP por DHCP | Puerto de acceso mal configurado | Verificar `switchport access vlan X` |
| Trunk no funciona | Encapsulación incorrecta | Asegurar `dot1q` en ambos lados |
| VLAN IDs no coinciden | Configuración inconsistente | Los IDs deben ser **idénticos** |
| No hay acceso a Internet | Falta regla NAT | Añadir `masquerade` en MikroTik |
| Ping inter-VLAN falla | Firewall bloqueando | Revisar `/ip firewall filter print` |

---

## Notas Relacionadas

- [[VLANs]] — Conceptos generales de VLANs
- [[VLANs en MikroTik]] — VLANs solo en MikroTik (Bridge model)
- [[IEEE 802.1Q]] — Estándar de etiquetado
- [[DTP & VTP]] — Protocolos de trunking Cisco
- [[Cisco IOS en GNS3]] — Instalación de dispositivos Cisco
- [[MikroTik en GNS3]] — Instalación de MikroTik
- [[Router on a Stick]] — Alternativa: inter-VLAN solo con Cisco
- [[Curso GNS3]] — Índice del curso
