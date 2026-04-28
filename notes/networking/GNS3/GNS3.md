---
categories:
  - "[[Ciber]]"
  - "[[ASIR]]"
tags:
  - networking
  - gns3
  - emulador
  - laboratorio
created: 2026-04-23
---
# GNS3 (Graphical Network Simulator-3)

**GNS3** es un **emulador de redes de código abierto** que permite diseñar, construir y probar topologías de red complejas en un entorno virtual. A diferencia de un simulador (como [[Cisco IOS en GNS3|Packet Tracer]]), GNS3 ejecuta el **software real** de los fabricantes (Cisco IOS, [[MikroTik en GNS3|MikroTik RouterOS]], etc.).

---

## Emulación vs Simulación

| Característica | Emulación (GNS3) | Simulación (Packet Tracer) |
|----------------|-------------------|----------------------------|
| **Software** | Ejecuta el IOS/RouterOS **real** | Usa una imitación del software |
| **Fidelidad** | Comportamiento idéntico al hardware real | Aproximación, puede tener limitaciones |
| **Recursos** | Requiere más RAM/CPU | Ligero |
| **Imágenes** | Necesitas obtener las imágenes del fabricante | Incluidas en la instalación |
| **Uso ideal** | Certificaciones avanzadas, entornos de producción | Aprendizaje básico (CCNA) |

---

## Componentes Principales

- **GNS3 GUI (Cliente):** Interfaz gráfica donde diseñas la topología arrastrando dispositivos.
- **GNS3 Server:** Motor que ejecuta la emulación. Puede correr localmente o en la **GNS3 VM**.
- **GNS3 VM:** Máquina virtual (VMware/VirtualBox) que ejecuta el servidor. **Recomendada** para mejor rendimiento y compatibilidad.

### Motores de emulación

| Motor | Uso |
|-------|-----|
| **Dynamips** | Routers Cisco clásicos (c3725, c7200) |
| **QEMU/KVM** | Imágenes modernas (vIOS, MikroTik CHR, firewalls) |
| **Docker** | Contenedores ligeros (servidores, herramientas) |
| **VPCS** | PCs virtuales simples para pruebas de conectividad |
| **IOU/IOL** | Cisco IOS on Unix (ligero, sin GUI) |

---

## Alternativas

| Herramienta | Tipo | Notas |
|-------------|------|-------|
| **Packet Tracer** | Simulador | Gratuito, limitado a Cisco, ideal para CCNA |
| **EVE-NG** | Emulador | Basado en web, similar a GNS3 |
| **CML (Cisco Modeling Labs)** | Emulador | Oficial de Cisco, de pago |

---

## Notas Relacionadas

- [[Curso GNS3]] — Curso completo de GNS3 desde cero
- [[GNS3 - Instalación en Ubuntu]] — Guía de instalación
- [[MikroTik en GNS3]] — Cómo añadir routers MikroTik
- [[Cisco IOS en GNS3]] — Cómo añadir routers/switches Cisco
