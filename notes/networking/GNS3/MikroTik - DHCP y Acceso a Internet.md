---
categories:
  - "[[Ciber]]"
  - "[[ASIR]]"
tags:
  - networking
  - gns3
  - mikrotik
  - dhcp
  - nat
  - masquerade
  - configuración
created: 2026-04-23
source: "https://youtu.be/X8g2BCC7tq4"
---
# MikroTik — DHCP y Acceso a Internet

> 📹 **Fuente:** [[Curso GNS3]] — Vídeo #3: *MikroTik Router Configuration, DHCP and Internet Access*

Configuración práctica de un router [[MikroTik en GNS3|MikroTik CHR]] en [[GNS3]] como servidor [[DHCP]] con salida a Internet mediante [[NAT]] Masquerade.

---

## Topología del Laboratorio

```
[Internet/Cloud] ---- ether1 [MikroTik CHR] ether2 ---- [VPCS/PCs]
                       (WAN - DHCP Client)    (LAN - DHCP Server)
```

- **ether1 (WAN):** Conectada al nodo NAT/Cloud de GNS3 → obtiene IP por DHCP automáticamente
- **ether2 (LAN):** Red interna donde los dispositivos recibirán IP del servidor DHCP

---

## Paso 1: Asignar IP a la Interfaz LAN

Antes de configurar el DHCP Server, la interfaz LAN necesita una dirección IP estática:

### Vía CLI (RouterOS)

```routeros
/ip address add address=192.168.10.1/24 interface=ether2
```

### Vía Winbox

1. Ir a **IP > Addresses**
2. Clic en **"+"**
3. **Address:** `192.168.10.1/24`
4. **Interface:** `ether2`
5. **Apply > OK**

---

## Paso 2: Configurar el Servidor DHCP

MikroTik incluye un asistente que simplifica todo el proceso.

### Vía CLI

```routeros
# Crear el pool de direcciones
/ip pool add name=pool-lan ranges=192.168.10.10-192.168.10.254

# Configurar la red DHCP
/ip dhcp-server network add address=192.168.10.0/24 gateway=192.168.10.1 dns-server=8.8.8.8,8.8.4.4

# Crear el servidor DHCP
/ip dhcp-server add name=dhcp-lan interface=ether2 address-pool=pool-lan disabled=no
```

### Vía Winbox (Asistente DHCP Setup)

1. Ir a **IP > DHCP Server**
2. Clic en **"DHCP Setup"**
3. **DHCP Server Interface:** `ether2`
4. **DHCP Address Space:** `192.168.10.0/24` (se detecta automáticamente)
5. **Gateway for DHCP Network:** `192.168.10.1`
6. **Addresses to Give Out:** `192.168.10.10-192.168.10.254`
7. **DNS Servers:** `8.8.8.8, 8.8.4.4`
8. **Lease Time:** `00:10:00` (10 minutos, adecuado para laboratorio)

---

## Paso 3: Configurar NAT Masquerade (Acceso a Internet)

Para que los dispositivos de la LAN puedan acceder a Internet, el router debe traducir las IPs privadas a la IP pública de la interfaz WAN ([[NAT]] con **masquerade**).

### Vía CLI

```routeros
/ip firewall nat add chain=srcnat out-interface=ether1 action=masquerade
```

### Vía Winbox

1. Ir a **IP > Firewall > NAT**
2. Clic en **"+"**
3. Pestaña **General:**
   - **Chain:** `srcnat`
   - **Out. Interface:** `ether1` (interfaz WAN)
4. Pestaña **Action:**
   - **Action:** `masquerade`
5. **Apply > OK**

### ¿Qué hace masquerade?

| Concepto | Descripción |
|----------|-------------|
| **srcnat** | Source NAT: traduce la IP de origen del paquete |
| **masquerade** | Variante de srcnat que usa automáticamente la IP de la interfaz de salida |
| **Efecto** | Los PCs con IP `192.168.10.x` salen a Internet con la IP WAN del router |

---

## Paso 4: Verificar la Ruta por Defecto

Si la interfaz WAN (`ether1`) obtiene IP por DHCP, la ruta por defecto se crea automáticamente. Verificar:

```routeros
# Ver la tabla de rutas
/ip route print

# Debería aparecer algo como:
# 0.0.0.0/0  gateway=10.0.0.1  (ruta por defecto hacia Internet)
```

### Vía Winbox

- Ir a **IP > Routes** y confirmar que existe una entrada `0.0.0.0/0` con gateway.

---

## Paso 5: Verificación de Conectividad

### Desde el router MikroTik

```routeros
/ping 8.8.8.8
```

### Desde el VPCS/PC cliente

```
# Obtener IP por DHCP
dhcp

# Probar conectividad a Internet
ping 8.8.8.8

# Probar resolución DNS
ping google.com
```

---

## Comandos de Referencia

| Comando RouterOS | Descripción |
|------------------|-------------|
| `/ip address add address=X interface=Y` | Asigna IP a una interfaz |
| `/ip address print` | Muestra IPs asignadas |
| `/ip pool add name=X ranges=Y` | Crea pool de direcciones para DHCP |
| `/ip dhcp-server network add ...` | Define la red DHCP |
| `/ip dhcp-server add ...` | Crea el servidor DHCP |
| `/ip dhcp-server lease print` | Muestra las concesiones DHCP activas |
| `/ip firewall nat add chain=srcnat action=masquerade` | Habilita NAT masquerade |
| `/ip firewall nat print` | Muestra reglas NAT |
| `/ip route print` | Muestra la tabla de rutas |
| `/ip dns print` | Muestra configuración DNS |
| `/ping 8.8.8.8` | Prueba de conectividad |

---

## Notas Relacionadas

- [[MikroTik en GNS3]] — Paso previo: instalar MikroTik en GNS3
- [[Curso GNS3]] — Índice completo del curso
- [[DHCP]] — Protocolo DHCP en detalle
- [[NAT]] — Network Address Translation
- [[VLANs en MikroTik]] — Siguiente: configurar VLANs
- [[GNS3]] — Entorno de laboratorio
