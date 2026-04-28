---
categories:
  - "[[Ciber]]"
  - "[[ASIR]]"
tags:
  - networking
  - dhcp
  - protocolos
  - ccna
created: 2026-04-23
---
# DHCP (Dynamic Host Configuration Protocol)

**DHCP** es un protocolo de red que permite a los dispositivos obtener automáticamente una configuración IP (dirección IP, máscara de subred, gateway, servidores DNS) al conectarse a una red.

---

## Funcionamiento (DORA)

El proceso DHCP sigue 4 pasos conocidos como **DORA**:

| Paso | Mensaje | Dirección | Descripción |
|------|---------|-----------|-------------|
| **D** | **Discover** | Cliente → Broadcast (`255.255.255.255`) | El cliente busca un servidor DHCP |
| **O** | **Offer** | Servidor → Cliente | El servidor ofrece una IP disponible |
| **R** | **Request** | Cliente → Broadcast | El cliente acepta la oferta |
| **A** | **Acknowledge** | Servidor → Cliente | El servidor confirma la asignación |

---

## Conceptos Clave

- **Lease (Concesión):** Tiempo durante el cual el cliente puede usar la IP asignada. Al expirar, debe renovar.
- **Pool:** Rango de direcciones IP disponibles para asignar.
- **Relay Agent (ip helper-address):** Permite reenviar solicitudes DHCP entre subredes (ya que DHCP usa broadcast y los routers no reenvían broadcast).
- **Reservación:** Asignar siempre la misma IP a una MAC específica.

---

## Puertos

| Puerto | Protocolo | Uso |
|--------|-----------|-----|
| **67/UDP** | DHCP Server | Escucha peticiones |
| **68/UDP** | DHCP Client | Envía peticiones |

---

## Configuración en Cisco

```cisco
! Crear el pool DHCP
ip dhcp pool RED_LAN
  network 192.168.10.0 255.255.255.0
  default-router 192.168.10.1
  dns-server 8.8.8.8 8.8.4.4
  lease 0 8 0

! Excluir IPs del pool (gateway, servidores, etc.)
ip dhcp excluded-address 192.168.10.1 192.168.10.9

! Verificar
show ip dhcp binding
show ip dhcp pool
```

## Configuración en MikroTik (RouterOS)

```routeros
# Crear pool
/ip pool add name=pool-lan ranges=192.168.10.10-192.168.10.254

# Configurar red DHCP
/ip dhcp-server network add address=192.168.10.0/24 gateway=192.168.10.1 dns-server=8.8.8.8

# Crear servidor DHCP
/ip dhcp-server add name=dhcp-lan interface=ether2 address-pool=pool-lan disabled=no

# Verificar
/ip dhcp-server lease print
```

> Para configuración detallada en GNS3, ver [[MikroTik - DHCP y Acceso a Internet]]

---

## Notas Relacionadas

- [[MikroTik - DHCP y Acceso a Internet]] — DHCP en MikroTik paso a paso
- [[VLANs en MikroTik]] — DHCP Server por VLAN
- [[NAT]] — Normalmente se configura junto con DHCP
- [[Curso GNS3]] — Laboratorios prácticos con DHCP
