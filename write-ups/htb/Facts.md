## General Info
Linux Machine
Rated as Easy in HTB

## Reconnaissance & Scanning 
```shell
nmap -sS -T5 -p- -Pn 10.129.24.48 -vvv
Discovered open port 22/tcp on 10.129.24.48
Discovered open port 80/tcp on 10.129.24.48
Discovered open port 54321/tcp on 10.129.24.48
nmap -sC -sV -p22,80,54321 facts.htb
PORT      STATE SERVICE VERSION
22/tcp    open  ssh     OpenSSH 9.9p1 Ubuntu 3ubuntu3.2 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey:
|   256 4d:d7:b2:8c:d4:df:57:9c:a4:2f:df:c6:e3:01:29:89 (ECDSA)
|_  256 a3:ad:6b:2f:4a:bf:6f:48:ac:81:b9:45:3f:de:fb:87 (ED25519)
80/tcp    open  http    nginx 1.26.3 (Ubuntu)
|_http-title: facts
|_http-server-header: nginx/1.26.3 (Ubuntu)
54321/tcp open  http    Golang net/http server
|_http-server-header: MinIO
| fingerprint-strings:
|   FourOhFourRequest:
|     HTTP/1.0 400 Bad Request
|     Accept-Ranges: bytes
|     Content-Length: 303
|     Content-Type: application/xml
|     Server: MinIO
|     Strict-Transport-Security: max-age=31536000; includeSubDomains
|     Vary: Origin
|     X-Amz-Id-2: dd9025bab4ad464b049177c95eb6ebf374d3b3fd1af9251148b658df7ac2e3e8
|     X-Amz-Request-Id: 18B994E15481DB82
|     X-Content-Type-Options: nosniff
|     X-Xss-Protection: 1; mode=block
|     Date: Tue, 16 Jun 2026 14:07:03 GMT
|     <?xml version="1.0" encoding="UTF-8"?>
```
facts.htb:54321 redirige a **facts.htb:9001**

En el source-code de facts.htb/admin:
```html
<link rel="stylesheet" href="[/assets/camaleon_cms/admin/admin-basic-manifest-](view-source:http://facts.htb/assets/camaleon_cms/admin/admin-basic-manifest-4a345527ab92050e4ecb0f7d9d30c6090c451165b9ffaf00266b2aa5231cda7f.css)
```
Camaleon CMS está compuesto en su mayoría por Ruby.
![[languages_images.png]]
The most common cookie models in Ruby on Rails CMS platforms include plain text cookies, signed cookies, and encrypted cookies.
GET response
```http
set-cookie: _factsapp_session=63DYSHMFi%2FMSsrK43NGzNsZQJHtEyiPnxW10rMX6GysdzM9qu8s0jO8ua67zOdUoa7uI6hqZ3qwQyx1jFvcr%2Fv%2FLzmv916dmMVkrN4LOBYxT05UZXp0GiHMwlP%2Fs3FhyZkeaiavkgNK%2BJ9ddHr1CkuG9Z%2FPiAvVLlb7S3u5G7Iy5RkD0tQtkDHadYqD2l7I8EYj0v4gY5r2ctFy6RPAn7kA7lpZQnMph0FZRgphyXYtsWq4s2hf%2FZHJ9Es%2Fwa4QuFuUapp7%2FEZ0A3e92j7DKSZR%2FdeT2JDU27Q%3D%3D--eCSsjGLnc4%2Biv83E--A6cCB832173NlnS8wguoqA%3D%3D; path=/; httponly; samesite=lax
```