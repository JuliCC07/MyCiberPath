---
categories:
  - "[[Ciber]]"
tags:
  - vms
  - pentesting
  - starting-point
created: 2026-02-13
---
## 1. Información General

- **Máquina:** Meow

- **IP:** 10.129.3.234

- **SO:** Linux

- **Dificultad:** Very Easy

- **Fecha:** 13/02/2026
    

## 2. Resumen Ejecutivo

Se comprometió el servidor al detectar un servicio Telnet expuesto en el puerto 23 que permitía el acceso directo como administrador (root) sin requerir credenciales de autenticación.

## 3. Enumeración (Reconocimiento)

### 3.1 Escaneo de Red

- **Comando utilizado:** `nmap -sC -sV 10.129.3.234`
    
- **Puertos Abiertos:**

| **Puerto** | **Servicio** | **Versión**  | **Estado** |
| ---------- | ------------ | ------------ | ---------- |
| 23         | telnet       | Linuxtelnetd | Abierto    |

### 3.2 Análisis de Servicios

- **Tecnologías Detectadas:** Telnet

	- **Hallazgos Clave:** El usuario root no tiene contraseña, ofrece acceso directo.
    

## 4. Análisis de Vulnerabilidades

- **Vulnerabilidad Principal:** Uso de telnet y además sin autenticación para el usuario administrador
        
## 5. Post-Explotación (Escalada de Privilegios)

Ya tenemos los máximos privilegios pues hemos accedido con el usuario root
    
- **Prueba de Compromiso (Flags):**
    
    - 🚩 **Root Flag:** `b40abdfe23665f766f9c61ecba8a4c19`

## 6. Remediación y Conclusiones

- **Criticidad:** [
    
- **Recomendaciones:**
    
    1. **Parcheo:** Cerrar completamente el puerto telnet y configurar un servicio ssh.
    2. Implementar políticas de contraseñas robustas para todos los usuarios.
    3. Configurar SSH para impedir el inicio de sesión directo como root (`PermitRootLogin no`).