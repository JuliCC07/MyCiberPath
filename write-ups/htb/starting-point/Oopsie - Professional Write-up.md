---
categories:
  - "[[Ciber]]"
tags:
  - vms
  - pentesting
  - starting-point
  - burp-suite
  - idor
  - suid
  - linux
created: 2026-04-21
---
## 1. Información General

- **Máquina:** [[Oopsie]]
- **IP:** 10.129.90.91
- **SO:** Linux (Ubuntu)
- **Dificultad:** Muy fácil
- **Fecha:** 21/04/2026

## 2. Resumen Ejecutivo

Se comprometió un servidor Linux que ejecutaba un sitio web Apache con un panel de administración oculto. Mediante web crawling pasivo con Burp Suite se descubrió una página de login. El reconocimiento reveló SSH y HTTP como servicios expuestos.

## 3. Enumeración (Reconocimiento)

### 3.1 Escaneo de Red

**Comando utilizado:** `nmap -sV -sC 10.129.90.91`

```
┌──(julicc㉿diavlo)-[~]
└─$ nmap -sV -sC 10.129.90.91
Starting Nmap 7.98 ( https://nmap.org ) at 2026-04-21 12:06 +0200
Nmap scan report for megacorp.com (10.129.90.91)
Host is up (0.22s latency).
Not shown: 998 closed tcp ports (reset)
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 7.6p1 Ubuntu 4ubuntu0.3 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey:
|   2048 61:e4:3f:d4:1e:e2:b2:f1:0d:3c:ed:36:28:36:67:c7 (RSA)
|   256 24:1d:a4:17:d4:e3:2a:9c:90:5c:30:58:8f:60:77:8d (ECDSA)
|_  256 78:03:0e:b4:a1:af:e5:c2:f9:8d:29:05:3e:29:c9:f2 (ED25519)
80/tcp open  http    Apache httpd 2.4.29 ((Ubuntu))
|_http-title: Welcome
|_http-server-header: Apache/2.4.29 (Ubuntu)
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 13.43 seconds
```

| **Puerto** | **Servicio** | **Versión** | **Estado** |
|---|---|---|---|
| 22 | SSH | OpenSSH 7.6p1 Ubuntu 4ubuntu0.3 | Abierto |
| 80 | HTTP | Apache httpd 2.4.29 (Ubuntu) | Abierto |

### 3.2 Análisis del Servicio Web

Los enlaces de la página principal no parecen llevar a ningún sitio, sin embargo si hacemos scroll encontramos una pista de que los servicios pueden ser accedidos tras hacer login. Según esta información, el sitio debería tener una página de login.

Antes de proceder con la enumeración de directorios y páginas, podemos intentar mapear el sitio web usando **Burp Suite** como proxy para realizar un web crawling pasivo.

> **Concepto clave — Web Crawler:** Un web crawler (también conocido como web spider o web robot) es un programa o script automatizado que recorre la World Wide Web de forma metódica y automatizada. Si tunelizas el tráfico web a través de Burp Suite (sin interceptar los paquetes), por defecto puede hacer spider pasivo del sitio web, actualizar el site map con todo el contenido solicitado y así crear un árbol de archivos y directorios sin enviar ninguna petición adicional.

## 4. Próximos Pasos — *Pendiente de completar*

> [!IMPORTANT]
> Este write-up está basado en los apuntes de reconocimiento realizados. La explotación completa (IDOR, subida de web shell, escalada de privilegios local) queda pendiente de documentar tras repetir la máquina.

- [ ] Descubrir la ruta de login mediante el crawling pasivo de Burp Suite
- [ ] Explotar la vulnerabilidad IDOR para escalar privilegios en la aplicación web
- [ ] Subir una web shell PHP y obtener acceso como `www-data`
- [ ] Escalada de privilegios local a root

## 5. Remediación y Conclusiones

- **Criticidad:** Alta

**Recomendaciones:**

1. **Controles de acceso del lado del servidor:** Implementar verificación de autorización en cada endpoint, validando que el usuario autenticado tiene permisos para acceder al recurso solicitado, en lugar de depender únicamente de parámetros del lado del cliente.
2. **Eliminar paneles de administración expuestos:** Las rutas de login de administración deberían estar protegidas por autenticación multifactor o restringidas por IP.
3. **Principio de mínimo privilegio:** La funcionalidad de subida de archivos no debería estar disponible para todos los roles de usuario.
4. **Validación de archivos subidos:** Implementar listas blancas de extensiones permitidas, verificar el MIME type real del archivo y almacenar los uploads fuera del webroot.
