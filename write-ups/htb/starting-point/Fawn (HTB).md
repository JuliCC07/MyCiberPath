## 1. Información General

- **Máquina:** [Fawn]
    
- **IP:** [10.129.3.239]
    
- **SO:** [Linux]
    
- **Dificultad:** [Muy fácil]
    
- **Fecha:** [13/02/2026]
    

## 2. Resumen Ejecutivo

Se identificó un servidor FTP (vsftpd 3.0.3) mal configurado que permitía la autenticación anónima, exponiendo información confidencial del sistema.

## 3. Enumeración (Reconocimiento)

### 3.1 Escaneo de Red

- **Comando utilizado:** `nmap -sC -sV 10.129.3.239`
    
- **Puertos Abiertos:**
    
| **Puerto** | **Servicio** | **Versión**  | **Estado** |
| ---------- | ------------ | ------------ | ---------- |
| 21         | FTP          | vsftpd 3.0.3 | Abierto    |

### 3.2 Análisis de Servicios

_(Aquí es donde detallas lo que encontraste manualmente)_

- **Tecnologías Detectadas:** [FTP Anon]
    
- **Hallazgos Clave:** [FTP Anon está permitido y la flag.txt es accesible.]
    
## 4. Explotación (Gaining Access)

- **Razonamiento:** [La flag está disponible desde el usuario anonymous y sin necesidad de una contraseña.]
    
- **Pasos de Reproducción:**
    ![[Pasted image 20260213104625.png]]

## 5. Remediación y Conclusiones

- **Criticidad:** [Alta]
    
- **Recomendaciones:**
    
	1. **Parcheo:** Deshabilitar el acceso anónimo editando la linea "anonymous_enable=NO" en el archivo /etc/vsftpd.conf (reiniciar el servicio)
	2. Recomiendo actualizar el servicio a la última versión de SFTP si requiere compartir archivos en el entorno.