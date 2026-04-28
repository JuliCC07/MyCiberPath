---
categories:
  - "[[Ciber]]"
  - "[[ASIR]]"
tags:
  - networking
  - gns3
  - mikrotik
  - vlans
  - tagged
  - untagged
  - firewall
  - bridge
created: 2026-04-23
source: "https://youtu.be/MLUmsa72IA0"
---
# VLANs en MikroTik

> 📹 **Fuente:** [[Curso GNS3]] — Vídeo #5: *VLANs en MikroTik | Tagged, Untagged y Firewall*

Configuración práctica de [[VLANs]] en un router [[MikroTik en GNS3|MikroTik]] usando el modelo de **Bridge + VLAN Filtering**, incluyendo aislamiento entre VLANs con reglas de [[iptables_lab|firewall]].

---

## Conceptos Clave

### Tagged vs Untagged

| Concepto | Cisco Equivalente | Descripción |
|----------|-------------------|-------------|
| **Tagged** | Trunk | Puerto que transporta tráfico de **múltiples VLANs**. Cada trama lleva una etiqueta [[IEEE 802.1Q]] con el VLAN ID |
| **Untagged** | Access | Puerto que pertenece a **una sola VLAN**. El dispositivo final no conoce la VLAN; el switch/bridge etiqueta/desetiqueta |
| **PVID** | Native VLAN | VLAN por defecto asignada a un puerto para tráfico sin etiquetar |

### VLAN Filtering

Es la función en MikroTik que permite al **Bridge** procesar las etiquetas VLAN. Sin activar `vlan-filtering`, el bridge trata todas las tramas como tráfico normal sin distinción de VLANs.

> ⚠️ **Importante:** Activar `vlan-filtering` puede causar pérdida de conectividad si no has configurado correctamente los puertos. Configura primero todo el bridge y activa el filtrado al final.

---

## Configuración Paso a Paso

### Topología

```
[VPCS VLAN10] ---- ether2 [MikroTik] ether1 ---- [Internet/Cloud]
[VPCS VLAN20] ---- ether3     |
                          (Bridge1)
```

### 1. Crear el Bridge

```routeros
/interface bridge add name=bridge1
```

### 2. Añadir las interfaces físicas al Bridge

```routeros
/interface bridge port add bridge=bridge1 interface=ether2
/interface bridge port add bridge=bridge1 interface=ether3
```

### 3. Crear las interfaces VLAN

```routeros
/interface vlan add name=vlan10 vlan-id=10 interface=bridge1
/interface vlan add name=vlan20 vlan-id=20 interface=bridge1
```

### 4. Configurar los puertos del Bridge (Access/Untagged)

Asignar el **PVID** a cada puerto de acceso:

```routeros
# ether2 pertenece a VLAN 10
/interface bridge port set [find interface=ether2] pvid=10

# ether3 pertenece a VLAN 20
/interface bridge port set [find interface=ether3] pvid=20
```

### 5. Configurar la Bridge VLAN Table

Definir qué puertos son **tagged** y cuáles **untagged** para cada VLAN:

```routeros
# VLAN 10: bridge1 es tagged (para routing), ether2 es untagged (acceso)
/interface bridge vlan add bridge=bridge1 vlan-ids=10 tagged=bridge1 untagged=ether2

# VLAN 20: bridge1 es tagged (para routing), ether3 es untagged (acceso)
/interface bridge vlan add bridge=bridge1 vlan-ids=20 tagged=bridge1 untagged=ether3
```

### 6. Asignar direcciones IP a cada VLAN

```routeros
/ip address add address=192.168.10.1/24 interface=vlan10
/ip address add address=192.168.20.1/24 interface=vlan20
```

### 7. Configurar DHCP Server para cada VLAN

```routeros
# Pool VLAN 10
/ip pool add name=pool-vlan10 ranges=192.168.10.10-192.168.10.254
/ip dhcp-server network add address=192.168.10.0/24 gateway=192.168.10.1 dns-server=8.8.8.8
/ip dhcp-server add name=dhcp-vlan10 interface=vlan10 address-pool=pool-vlan10 disabled=no

# Pool VLAN 20
/ip pool add name=pool-vlan20 ranges=192.168.20.10-192.168.20.254
/ip dhcp-server network add address=192.168.20.0/24 gateway=192.168.20.1 dns-server=8.8.8.8
/ip dhcp-server add name=dhcp-vlan20 interface=vlan20 address-pool=pool-vlan20 disabled=no
```

### 8. Activar VLAN Filtering

> ⚡ Hacer esto **al final**, una vez todo esté configurado:

```routeros
/interface bridge set bridge1 vlan-filtering=yes
```

---

## Firewall: Aislamiento entre VLANs

Por defecto, al activar VLAN Filtering y tener las dos VLANs con IP, el router **permite** la comunicación entre VLAN 10 y VLAN 20 (porque él enruta). Para **bloquear** el tráfico inter-VLAN:

```routeros
# Bloquear tráfico de VLAN 10 a VLAN 20
/ip firewall filter add chain=forward in-interface=vlan10 out-interface=vlan20 action=drop

# Bloquear tráfico de VLAN 20 a VLAN 10
/ip firewall filter add chain=forward in-interface=vlan20 out-interface=vlan10 action=drop
```

> **Orden importa:** Las reglas de firewall en MikroTik se procesan de arriba a abajo. Coloca las reglas de `drop` **antes** de cualquier regla de `accept` general.

### Verificar las reglas

```routeros
/ip firewall filter print
```

---

## Verificación

| Comando RouterOS | Descripción |
|------------------|-------------|
| `/interface bridge print` | Ver configuración del bridge |
| `/interface bridge port print` | Ver puertos asignados y su PVID |
| `/interface bridge vlan print` | Ver la VLAN table (tagged/untagged) |
| `/interface vlan print` | Ver interfaces VLAN creadas |
| `/ip address print` | Verificar IPs por VLAN |
| `/ip dhcp-server lease print` | Ver concesiones DHCP activas |
| `/ip firewall filter print` | Ver reglas de firewall |
| `/ping 192.168.10.x` | Probar conectividad |

---

## Notas Relacionadas

- [[VLANs]] — Conceptos generales de VLANs
- [[IEEE 802.1Q]] — Estándar de etiquetado de tramas
- [[MikroTik en GNS3]] — Instalación de MikroTik en GNS3
- [[MikroTik - DHCP y Acceso a Internet]] — DHCP y NAT básico
- [[VLANs - Interoperabilidad MikroTik y Cisco]] — VLANs multi-vendor
- [[Curso GNS3]] — Índice del curso
- [[DTP & VTP]] — Protocolos de trunking Cisco (comparación)
