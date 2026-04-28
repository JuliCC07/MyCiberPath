---
categories:
  - "[[Ciber]]"
  - "[[ASIR]]"
tags:
  - networking
  - nat
  - pat
  - firewall
  - ccna
created: 2026-04-23
---
# NAT (Network Address Translation)

**NAT** es una técnica que traduce direcciones IP privadas a direcciones IP públicas (y viceversa) para permitir que dispositivos de una red interna accedan a Internet.

---

## Tipos de NAT

| Tipo | Descripción | Uso |
|------|-------------|-----|
| **Static NAT** | Mapeo 1:1 (una IP privada ↔ una IP pública) | Servidores accesibles desde Internet |
| **Dynamic NAT** | Mapeo N:N (pool de IPs públicas) | Redes con múltiples IPs públicas |
| **NAT Overload (PAT)** | Mapeo N:1 (muchas privadas → una pública, diferenciadas por puerto) | **El más común**. Redes domésticas y empresariales |

---

## Terminología

| Término | Significado |
|---------|-------------|
| **Inside Local** | IP privada del dispositivo interno (ej. `192.168.10.5`) |
| **Inside Global** | IP pública que representa al dispositivo interno |
| **Outside Local** | IP del destino vista desde la red interna |
| **Outside Global** | IP pública real del destino (ej. `8.8.8.8`) |

---

## Configuración en Cisco (PAT / NAT Overload)

```cisco
! Definir interfaces inside/outside
interface GigabitEthernet0/0
  ip nat inside
  exit
interface GigabitEthernet0/1
  ip nat outside
  exit

! ACL para identificar tráfico a traducir
access-list 1 permit 192.168.10.0 0.0.0.255

! NAT Overload (PAT)
ip nat inside source list 1 interface GigabitEthernet0/1 overload

! Verificar
show ip nat translations
show ip nat statistics
```

## Configuración en MikroTik (Masquerade)

```routeros
# Masquerade = equivalente a PAT en Cisco
/ip firewall nat add chain=srcnat out-interface=ether1 action=masquerade

# Verificar
/ip firewall nat print
```

> **Masquerade** es una variante de Source NAT que utiliza automáticamente la IP de la interfaz de salida. Es ideal cuando la IP WAN se asigna por [[DHCP]].

---

## NAT y Seguridad

- NAT **no es un firewall**, pero proporciona una capa básica de protección al ocultar las IPs internas
- Las conexiones **iniciadas desde Internet hacia la red interna** son bloqueadas por defecto (no hay traducción inversa)
- Para permitir acceso entrante se necesita **Port Forwarding** (DNAT / dst-nat)

---

## Notas Relacionadas

- [[MikroTik - DHCP y Acceso a Internet]] — NAT Masquerade en MikroTik
- [[Router on a Stick]] — NAT Overload con subinterfaces Cisco
- [[DHCP]] — Se configura junto con NAT
- [[VLANs en MikroTik]] — NAT con múltiples VLANs
- [[Curso GNS3]] — Laboratorios prácticos con NAT
