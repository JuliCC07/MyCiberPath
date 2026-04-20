---
categories:
  - "[[ASIR]]"
tags:
  - networking
  - ccna
  - protocols
  - OSPF
  - RIP
created: 2026-03-24
rating:
---
# RIP
## Conceptos clave
- **Tipo:** Protocolo de Enrutamiento Dinámico de **Vector de Distancia**.
    
- **Métrica:** **Conteo de Saltos**. El mejor camino es el que tiene menos routers entre origen y destino.
    
- **Límite:** Máximo **15 saltos**. Si llega a 16, la red se considera inalcanzable (infinito).
    
- **Actualizaciones:** Envía su tabla completa cada **30 segundos**.
    
- **RIPv1 vs RIPv2 (CRÍTICO):**  
	- **v1:** Con clase (no admite VLSM/subredes), usa Broadcast (255.255.255.255).
    
    - **v2:** Sin clase (admite VLSM), usa Multicast (224.0.0.9) y soporta autenticación.

## Configuración de RIP (comandos):
```
router rip      # Entra al modo de configuración RIP
version 2       # Cambia a la versión 2 (para subredes)
no auto-summary # Evitar que resuma redes (mantiene las subredes)
# Anunciar las redes que tiene el router conectadas directamente
network 192.168.1.0
network 10.0.0.0
```
## Verificación

- `show ip route`: Busca las rutas marcadas con una **"R"**. Esa "R" significa que la ha aprendido por RIP.
    
- `show ip protocols`: Te dice qué versión usas, cada cuánto envía updates y qué redes estás anunciando.
    
- `debug ip rip`: (Úsalo solo si algo falla) Te muestra en tiempo real cómo se envían y reciben las actualizaciones.
## Extra: Redundancia y Trace

El vídeo destaca la **Redundancia**. RIP detecta si un enlace cae y, tras esperar los tiempos de convergencia, calculará la nueva ruta por el camino alternativo.

- Para ver esto en acción usa `traceroute` (en Cisco) o `tracert` (en Windows) para ver por qué routers exactos está pasando tu paquete.

# OSPF
## La lógica OSPF (Diferencias con RIP)

- **RIP:** Mira saltos. Máximo 15.
    
- **OSPF:** Mira el ancho de banda (coste). Es jerárquico (Áreas).
    
- **Wildcard Mask:** Es lo opuesto a la máscara de subred. Si tu máscara es `255.255.255.0`, tu Wildcard es `0.0.0.255`. (Cálculo rápido: 255 menos cada octeto).

```
router ospf 1
id 1.1.1.1 # Identificador único
network 192.168.19.0 0.0.0.255 area 0
network 200.0.18.0 0.0.0.3 area 0
network 200.0.18.8 0.0.0.3 area 0
```
## Verificación de "Pentester" (Troubleshooting)

Si el ping falla entre routers, usa este orden:

1. `show ip ospf neighbor`: ¿Ves a los otros routers? Si no los ves, revisa los cables o que el área sea la misma (todos deben ser `area 0`).
    
2. `show ip ospf interface`: Para ver si la interfaz está enviando paquetes "Hello".
    
3. `show ip route ospf`: Para ver solo las rutas aprendidas por este protocolo.