---
title: "Facts - Hack The Box"
target: "Facts"
os: "Linux"
difficulty: "Medium"
status: "Pwned"
vectors: "CMS Made Simple Authenticated SQLi & RCE, SUID Misconfiguration, Sudo Environment Hijacking"
tags:
  - ciber
  - htb
  - cmsms
  - sqli
  - suid
  - sudo
  - privesc
synced: "2026-11-02 12:08"
---

<p align="center">
  <img src="https://cdn.services-k8s.prod.aws.htb.systems/content/machines/avatar/a0efb09d-2937-4e7c-bd04-ba2e4386b8b1.png" alt="Facts Avatar" width="220">
</p>

## Operating System: Linux
![[Linux.png|70]]

## Machine Metadata

| Property | Value |
| :--- | :--- |
| **Machine ID** | 829 |
| **Machine Name** | Facts |
| **IP Address** | N/A |
| **Status** | In Progress |
| **Active on HTB** | ❌ |
| **User Flag** | ❌ |
| **Root Flag** | ❌ |
| **Difficulty** | Easy |
| **Stars** | ⭐️ 4.5 |
| **Created Note** | 2026-10-16 |
| **Release Date** | 2026-01-31 |
| **Tags** | #Web_Application #Vulnerability_Assessment #Cloud #Information_Disclosure #Misconfiguration #Weak_Permissions #Sensitive_Data_Exposure #Mass_Assignment #Ruby #Rails #SSH #CMS #NGINX #OpenSSH #Linux #Reconnaissance #Web_Site_Structure_Discovery #Configuration_Analysis #AWS_Enumeration #Bucket_Enumeration #System_Exploitation #Password_Cracking #SUDO_Exploitation #Privilege_Abuse #Parameter_Manipulation #Common_Applications #Software_&_OS_exploitation #Security_Tools #AWS #Puppet |

<p style="display:none">
id:: 829
active:: False
name:: Facts
os:: Linux
user_flag:: False
root_flag:: False
difficulty_text:: Easy
stars:: 4.5
created:: 2026-10-16
published:: 2026-01-31
avatar:: https://cdn.services-k8s.prod.aws.htb.systems/content/machines/avatar/a0efb09d-2937-4e7c-bd04-ba2e4386b8b1.png
tags:: #Web_Application #Vulnerability_Assessment #Cloud #Information_Disclosure #Misconfiguration #Weak_Permissions #Sensitive_Data_Exposure #Mass_Assignment #Ruby #Rails #SSH #CMS #NGINX #OpenSSH #Linux #Reconnaissance #Web_Site_Structure_Discovery #Configuration_Analysis #AWS_Enumeration #Bucket_Enumeration #System_Exploitation #Password_Cracking #SUDO_Exploitation #Privilege_Abuse #Parameter_Manipulation #Common_Applications #Software_&_OS_exploitation #Security_Tools #AWS #Puppet
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
  - item: "ENUM"
    user: "user"
    score: 5.2
  - item: "REAL"
    user: "user"
    score: 5.3
  - item: "CVE"
    user: "user"
    score: 6.1
  - item: "CUSTOM"
    user: "user"
    score: 3.9
  - item: "CTF"
    user: "user"
    score: 4.7
  - item: "ENUM"
    user: "author"
    score: 6
  - item: "REAL"
    user: "author"
    score: 3
  - item: "CVE"
    user: "author"
    score: 7
  - item: "CUSTOM"
    user: "author"
    score: 3
  - item: "CTF"
    user: "author"
    score: 7

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
  - folder: "PIECE OF CAKE"
    count: 1569
  - folder: "VERY EASY"
    count: 2346
  - folder: "EASY"
    count: 6512
  - folder: "NOT TOO EASY"
    count: 3877
  - folder: "MEDIUM"
    count: 1454
  - folder: "A BIT HARD"
    count: 402
  - folder: "HARD"
    count: 261
  - folder: "EXTREMELY HARD"
    count: 92
  - folder: "INSANE"
    count: 37
  - folder: "BRAINFUCK"
    count: 121

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

---

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

---

## Post-Engagement & Zettelkasten Notes

### Key Takeaways & Defense
- **MinIO & Secondary Service Exposure**: Non-standard high ports (54321, 9001) frequently run administration consoles that require segmentation.
- **Ruby on Rails Session Security**: Understand cookie signing and encryption mechanisms to identify potential session tampering or deserialization flaws.

### Atomic Notes to Extract
- [[Web - HTTP - Cookies & Session Management|Ruby on Rails Session Cookies]]
- [[Recon - Nmap - Port Scanning and Host Discovery|Nmap Scanning]]
