# Automatización y Parcheo de Kernel (CachyOS)

## Contexto del Problema
Al intentar compilar el kernel `linux-cachyos-bore` con una serie de parches personalizados para solucionar problemas de firmware sobre el TSC (Time Stamp Counter), el proceso de compilación (`makepkg`) fallaba durante la fase `prepare()`.

Los problemas detectados fueron dos:
1. **Conflicto en el código fuente (Obsoleto):** El parche `0017` intentaba modificar la función `tsc_setup` en `arch/x86/kernel/tsc.c`. El código fuente más reciente había refactorizado la variable `tsc_as_watchdog` a `tsc_watchdog` y eliminado el uso de llaves `{ ... }` en sentencias condicionales simples. Esto provocaba que el segundo "hunk" del parche fallara al no encontrar coincidencias exactas en el código.
2. **Doble aplicación de parches:** En el `PKGBUILD`, los parches se introducían en el array `source=( ... )`, lo que hace que el bucle predeterminado de `makepkg` los aplique automáticamente. Sin embargo, al final de la función `prepare()` había comandos manuales (`patch -Np1 -i ...`) que intentaban aplicar los mismos parches por segunda vez, generando errores por parche ya aplicado o creando archivos duplicados si no se ejecutaba una compilación limpia (`-C`).

## La Solución

### 1. Corrección del Parche
Se modificó manualmente el archivo de parche `.patch` para que el contexto del código a reemplazar (las líneas antes y después del signo `+`) coincida exactamente con la nueva estructura del archivo `.c` en el kernel de destino.

### 2. Uso Eficiente del PKGBUILD
La manera correcta de gestionar parches en Arch Linux / CachyOS es **incluirlos todos en el array `source`** y dejar que el script los procese automáticamente, eliminando las líneas manuales al final de `prepare()`.
Al modificar el array `source`, es fundamental ejecutar `updpkgsums` para recalcular las firmas y evitar errores de validación (sha256/b2sums).

### 3. El Script de Automatización
Para no repetir el proceso manualmente cada vez que el kernel se actualiza (ej. mediante un `git pull` desde el repositorio upstream), creamos el siguiente script en la raíz del proyecto para automatizar la inyección y compilación:

```bash
#!/bin/bash
set -e

# Configuración de rutas
PROJECT_DIR="/home/julicc/Projects/linux-cachyos"
BORE_DIR="$PROJECT_DIR/linux-cachyos-bore"
PATCHES_DIR="$PROJECT_DIR/tsc_patches"

echo "=== Iniciando automatización para compilar linux-cachyos-bore con parches TSC ==="

# 1. Asegurarnos de tener el repositorio limpio y actualizado
cd "$BORE_DIR"
git checkout -- PKGBUILD || true
git pull origin master || true

# 2. Copiar los parches personalizados (alojados de forma aislada)
cp "$PATCHES_DIR/"*.patch .

# 3. Inyectar los parches en el array 'source' del PKGBUILD (usando sed)
if ! grep -q "0017-x86-implement-tsc-directsync-for-systems-without-IA3.patch" PKGBUILD; then
    sed -i 's/"config"/"config"\n    "0017-x86-implement-tsc-directsync-for-systems-without-IA3.patch"\n    "0018-x86-touch-clocksource-watchdog-after-syncing-TSCs.patch"\n    "0019-x86-save-restore-TSC-counter-value-during-sleep-wake.patch"\n    "0020-x86-only-restore-TSC-if-we-have-IA32_TSC_ADJUST-or-d.patch"\n    "0021-x86-don-t-check-for-random-warps-if-using-direct-syn.patch"\n    "0022-x86-export-tsc_khz-to-userspace.patch"/g' PKGBUILD
fi

# 4. Actualizar las sumas de control
updpkgsums

# 5. Lanzar la compilación limpia (-C) e instalación (-i)
makepkg -C -si
```

## Lecciones Aprendidas
* Siempre usar `makepkg -C` (Clean Build) cuando hayamos tenido errores de parcheo en ejecuciones anteriores. Si no, `patch` creerá que los archivos creados previamente (ej. `bore.h`) son colisiones o que el parche ya ha sido aplicado.
* Centralizar los parches `.patch` modificados/arreglados en una carpeta externa aislada (ej. `tsc_patches`) evita que un `git reset` o un `git pull` en el repositorio original nos elimine nuestras correcciones.
* La inyección programática con `sed` permite tener el código del sistema actualizado (upstream) manteniendo nuestros añadidos personalizados sobre la marcha.
