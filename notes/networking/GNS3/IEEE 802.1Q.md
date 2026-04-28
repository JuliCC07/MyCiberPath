---
categories:
  - "[[Ciber]]"
  - "[[ASIR]]"
tags:
  - networking
  - vlans
  - 802.1q
  - trunking
  - estándar
  - ccna
created: 2026-04-23
---
# IEEE 802.1Q

**IEEE 802.1Q** es el estándar internacional para el **etiquetado de tramas Ethernet** que permite transportar tráfico de múltiples [[VLANs]] a través de un único enlace físico (**trunk**).

---

## ¿Cómo funciona?

Cuando una trama Ethernet necesita cruzar un enlace trunk, el switch inserta una **etiqueta de 4 bytes** (tag) en la cabecera de la trama original. Esta etiqueta contiene, entre otros campos, el **VLAN ID** que identifica a qué VLAN pertenece la trama.

### Estructura de la trama etiquetada

```
┌──────────────┬──────────────┬──────────────┬──────────────┬─────────┬─────┐
│  Dest MAC    │  Source MAC  │  802.1Q Tag  │  EtherType   │ Payload │ FCS │
│  (6 bytes)   │  (6 bytes)   │  (4 bytes)   │  (2 bytes)   │         │     │
└──────────────┴──────────────┴──────┬───────┴──────────────┴─────────┴─────┘
                                     │
                              ┌──────┴──────┐
                              │  TPID (2B)  │  → 0x8100 (identifica 802.1Q)
                              │  TCI  (2B)  │
                              │   ├ PCP (3b)│  → Priority (QoS)
                              │   ├ DEI (1b)│  → Drop Eligible
                              │   └ VID(12b)│  → VLAN ID (0-4095)
                              └─────────────┘
```

| Campo | Tamaño | Descripción |
|-------|--------|-------------|
| **TPID** (Tag Protocol Identifier) | 2 bytes | Siempre `0x8100`, indica que es una trama 802.1Q |
| **PCP** (Priority Code Point) | 3 bits | Prioridad para QoS (0-7) |
| **DEI** (Drop Eligible Indicator) | 1 bit | Indica si la trama puede ser descartada en congestión |
| **VID** (VLAN Identifier) | 12 bits | Identifica la VLAN (rango 0-4095, usables 1-4094) |

> El tag de 4 bytes aumenta el tamaño máximo de la trama de **1518 bytes** a **1522 bytes**.

---

## Native VLAN

La **Native VLAN** es la VLAN cuyo tráfico se envía **sin etiquetar** por un enlace trunk.

- Por defecto es la **VLAN 1** en dispositivos Cisco
- Ambos extremos del trunk **deben tener la misma Native VLAN**
- Si no coinciden, se produce un **Native VLAN mismatch** → problemas de seguridad y conectividad

### Buenas prácticas de seguridad

```cisco
! Cambiar la Native VLAN a una VLAN no usada
switchport trunk native vlan 999

! O forzar que se etiquete incluso la native VLAN
vlan dot1q tag native
```

---

## 802.1Q vs ISL

| Característica | IEEE 802.1Q | Cisco ISL |
|----------------|-------------|-----------|
| **Tipo** | Estándar abierto | Propietario de Cisco |
| **Encapsulación** | Inserta tag dentro de la trama | Encapsula la trama completa |
| **Overhead** | 4 bytes | 30 bytes |
| **Native VLAN** | Sí (tráfico sin etiquetar) | No (todo etiquetado) |
| **Estado** | Vigente, universal | **Obsoleto** |

> En la actualidad, **802.1Q es el único estándar en uso**. ISL ya no se soporta en equipos modernos.

---

## Relación con otros conceptos

- **[[VLANs]]:** 802.1Q permite que las VLANs crucen enlaces entre switches
- **[[DTP & VTP|DTP]]:** Protocolo de Cisco que negocia automáticamente el modo trunk (usando 802.1Q)
- **[[Router on a Stick]]:** Usa subinterfaces con `encapsulation dot1q` para inter-VLAN routing
- **[[VLANs en MikroTik]]:** MikroTik usa 802.1Q con su modelo de Bridge + VLAN Filtering

---

## Notas Relacionadas

- [[VLANs]] — Concepto general de redes virtuales
- [[DTP & VTP]] — Protocolos de negociación y gestión de trunks
- [[Router on a Stick]] — Enrutamiento inter-VLAN con subinterfaces 802.1Q
- [[VLANs en MikroTik]] — Implementación de 802.1Q en MikroTik
- [[VLANs - Interoperabilidad MikroTik y Cisco]] — Multi-vendor con 802.1Q
- [[STP Toolkit]] — STP protege la topología en redes con trunks
- [[Curso GNS3]] — Curso donde se practican todas estas configuraciones
