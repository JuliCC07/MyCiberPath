---
categories:
  - "[[Ciber]]"
tags:
  - networking
  - ccna
  - vlans
created: 2026-03-12
---
DTP

Cisco proprietary protocol to dynamically determine their interface status without manual configuration, enabled by default. DTP should be disabled

dynamic desirable: actively tries to form a trunk
dynamic auto: will not actively try to form a trunk

disable dtp negotiation with "switchport nonegotiate / switchport mode access"

VTP
Allows to configure [[VLANs|vlans]] on a central vtp server switch and other switches will synchronize their vlan database to the server, designed for large networks with many [[VLANs|vlans]], rarely used and recommended t not use it. versions from 1-3 
3 vtp modes:
- server (default)
- client
- transparent
VTP servers:
- Create/modify/delete [[VLANs|vlans]]
- Store vlan database in non-volatile ram (nvram)
- will increase the revision number every time vlan is changed
- advertise the latest version of the vlan databes on trunk interfaces 
- Also function as vtp clients synchronizing to another vtp server with higher revision number 
VTP Clients:
- Cannot c/m/d [[VLANs|vlans]]
- Not store in nvram (in v3 they do)
VTP Treansparent:
- Does not sync database
- maintain its own database in nVRAM
- Will forward VTP advertisements that are in the same domain as it

## Notas Relacionadas

- [[VLANs]] — Configuración general de VLANs
- [[IEEE 802.1Q]] — Estándar de etiquetado de tramas
- [[VLANs en MikroTik]] — VLANs con Bridge + VLAN Filtering
- [[VLANs - Interoperabilidad MikroTik y Cisco]] — Trunking multi-vendor
- [[Router on a Stick]] — Enrutamiento inter-VLAN con subinterfaces
- [[Cisco IOS en GNS3]] — Configuración de dispositivos Cisco
- [[Curso GNS3]] — Laboratorios prácticos
