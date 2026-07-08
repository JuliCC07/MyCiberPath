This write-up details the exploitation of the **Principal** machine from HackTheBox. The attack path involves identifying a Java web application vulnerable to an authentication bypass via pac4j-jwt (CVE-2026-29000). By forging an unsigned JSON Web Token (JWT), we gain administrative access, enumerate users, and gain SSH access. Finally, we abuse a misconfigured OpenSSH Certificate Authority setup to sign a certificate granting root access.

## Reconnaissance

### Port Scanning

We begin our enumeration with an Nmap scan to identify open ports and services:

```bash
$ nmap -sC -sV 10.129.244.220
```

The scan identifies two open ports:
- **22/tcp (SSH):** OpenSSH 9.6p1
- **8080/tcp (HTTP-Proxy):** Jetty web server

### Web Enumeration

Connecting to port 8080, we are redirected to `/login`, finding the "Principal Internal Platform" login page. The server headers and error messages confirm it is running Jetty and relies on `pac4j-jwt/6.0.3`.

To understand the authentication flow, we analyze the client-side JavaScript (`app.js`):

```bash
$ curl -s http://10.129.244.220:8080/static/js/app.js
```

The source code provides critical details about the authentication mechanism:
- Tokens are JSON Web Encryption (JWE) tokens encrypted using RSA-OAEP-256 + A128GCM.
- The inner JWT is signed with RS256.
- The Public Key is available at `/api/auth/jwks` for verification.
- Roles include `ROLE_ADMIN`, `ROLE_MANAGER`, and `ROLE_USER`.

We query the JWKS endpoint to retrieve the public key:

```bash
$ curl -s http://10.129.244.220:8080/api/auth/jwks | jq
```

This returns an RSA public key with `kid: enc-key-1`. While the encryption key is exposed, the signing key remains separate. 

## Vulnerability Discovery & Exploitation

Given the use of `pac4j-jwt/6.0.3`, we investigate known vulnerabilities and identify **CVE-2026-29000** – a critical authentication bypass vulnerability in pac4j-jwt.

We utilize a public exploit for CVE-2026-29000 (`https://github.com/yasirr10/CVE-2026-29000`):

```bash
$ python3 exploit.py
```

We provide the target base URL and the JWKS endpoint. The exploit fetches the RSA public key and generates an unsigned "PlainJWT" (setting the algorithm to `none`), forging an authentication token with `admin` privileges.

With our forged token, we can access authenticated endpoints. We query the `/api/users` endpoint to enumerate active accounts:

```bash
$ curl -H "Authorization: Bearer <FORGED_TOKEN>" http://10.129.244.220:8080/api/users
```

This reveals several users, including a service account:
- `svc-deploy`: "Service account for automated deployments via SSH certificate auth."

![[Pasted image 20260628160031.png]]

![[Pasted image 20260628160103.png]]
![[Pasted image 20260628160321.png]]
![[Pasted image 20260628160336.png]]

## Foothold

*(Assuming we obtained the credentials for `svc-deploy` through further enumeration of the web application dashboard using our forged admin token.)*

We connect via SSH using the `svc-deploy` account:

```bash
ssh svc-deploy@10.129.244.220
```

This grants us an initial shell on the machine.

## Privilege Escalation

Enumerating the system as `svc-deploy`, we search for directories accessible to our groups:

```bash
svc-deploy@principal:~$ find / -type d -group deployers -perm -g=r 2>/dev/null
/opt/principal/ssh
```

We discover the `/opt/principal/ssh` directory, which contains an SSH Certificate Authority (CA) private key. 

OpenSSH on this system is configured to trust certificates signed by this CA (`TrustedUserCAKeys`). Crucially, there is no `AuthorizedPrincipalsFile` configured. This misconfiguration means that OpenSSH will accept any certificate signed by the trusted CA and will allow login as whichever user is specified as the "principal" in the certificate.

While `PermitRootLogin prohibit-password` is set (blocking password-based root logins), certificate-based authentication is still allowed.

Since we have read access to the CA private key, we can sign our own SSH public key and specify `root` as the principal:

```bash
svc-deploy@principal:/opt/principal/ssh$ ssh-keygen -s /opt/principal/ssh/ca -I "pwn-root" -n root -V +1h /tmp/pwn.pub
Signed user key /tmp/pwn-cert.pub: id "pwn-root" serial 0 for root valid from 2026-06-28T14:25:00 to 2026-06-28T15:26:33
```

This generates a signed certificate (`pwn-cert.pub`) valid for the `root` user. By utilizing this certificate, we can authenticate as root over SSH and fully compromise the system.

## Conclusion

The Principal machine demonstrates advanced authentication mechanisms and how subtle configuration flaws can break them. It highlights the severity of the `none` algorithm vulnerability in JWT implementations (CVE-2026-29000). Furthermore, it underscores the importance of correctly configuring OpenSSH Certificate Authorities; failing to enforce `AuthorizedPrincipalsFile` when trusting a CA can trivially lead to root compromise if the CA key is exposed.