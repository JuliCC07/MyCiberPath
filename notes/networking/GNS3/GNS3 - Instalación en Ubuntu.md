---
categories:
  - "[[Ciber]]"
  - "[[ASIR]]"
tags:
  - networking
  - gns3
  - instalación
  - ubuntu
  - linux
created: 2026-04-23
source: "https://youtu.be/tN29xyAPiAM"
---
# GNS3 — Instalación en Ubuntu

> 📹 **Fuente:** [[Curso GNS3]] — Vídeo #1: *How to Install GNS3 on Ubuntu*

Guía paso a paso para instalar [[GNS3]] de forma nativa en Ubuntu, obteniendo el mejor rendimiento para laboratorios de redes.

---

## Requisitos Previos

- **Sistema Operativo:** Ubuntu (20.04 LTS o superior recomendado)
- **RAM:** Mínimo 8 GB (16 GB recomendado según la cantidad de dispositivos)
- **CPU:** Soporte de virtualización activado en BIOS (**VT-x** / **AMD-V**)
- **Disco:** Espacio suficiente para las imágenes de los dispositivos

---

## Instalación del Cliente y Servidor

### 1. Añadir el repositorio oficial

```bash
sudo add-apt-repository ppa:gns3/ppa
sudo apt update
```

### 2. Instalar GNS3

```bash
sudo apt install gns3-gui gns3-server
```

> Durante la instalación, el sistema preguntará si los usuarios no-root pueden ejecutar GNS3. Seleccionar **Sí** para evitar problemas de permisos.

### 3. Añadir el usuario al grupo necesario

```bash
sudo usermod -aG ubridge,libvirt,kvm,wireshark $(whoami)
```

> **Reiniciar la sesión** después de este paso para que los cambios surtan efecto.

---

## Soporte IOU (Cisco I/O Unix)

**IOU** permite ejecutar imágenes de Cisco de forma más ligera que Dynamips. Para habilitarlo:

```bash
sudo dpkg --add-architecture i386
sudo apt update
sudo apt install gns3-iou
```

> Las imágenes IOU requieren un archivo de licencia (`iourc`) para funcionar. Este archivo se coloca en `~/.iourc`.

---

## Configuración Inicial (Setup Wizard)

Al abrir GNS3 por primera vez:

1. **Setup Wizard** → Seleccionar **"Run appliances on my local computer"** (o GNS3 VM si la tienes configurada)
2. Verificar la conexión al **servidor local** (host: `127.0.0.1`, puerto: `3080`)
3. El servidor aparecerá con un indicador **verde** si la conexión es correcta

---

## Verificación de la Instalación

Para comprobar que todo funciona:

1. Crear un **nuevo proyecto** (`File > New blank project`)
2. Arrastrar un nodo **NAT Cloud** al espacio de trabajo
3. Arrastrar un **VPCS** (Virtual PC)
4. Conectar el VPCS al NAT Cloud
5. Iniciar los nodos y ejecutar:

```
# En la consola del VPCS
dhcp
ping 8.8.8.8
```

Si el ping responde, la instalación es correcta y el VPCS tiene acceso a Internet a través del nodo NAT.

---

## Comandos de Referencia

| Comando | Descripción |
|---------|-------------|
| `sudo add-apt-repository ppa:gns3/ppa` | Añade el repo oficial de GNS3 |
| `sudo apt install gns3-gui gns3-server` | Instala cliente + servidor |
| `sudo apt install gns3-iou` | Instala soporte para imágenes IOU |
| `sudo usermod -aG ubridge,libvirt,kvm,wireshark $USER` | Permisos necesarios |
| `gns3` | Lanza la interfaz gráfica |

---

## Notas Relacionadas

- [[GNS3]] — ¿Qué es GNS3? Componentes y motores de emulación
- [[Curso GNS3]] — Índice completo del curso
- [[MikroTik en GNS3]] — Siguiente paso: instalar MikroTik
- [[Cisco IOS en GNS3]] — Instalar routers y switches Cisco
