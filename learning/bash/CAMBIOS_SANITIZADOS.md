# Cambios Realizados en el Sistema - Guía para Nueva Instalación

**Fecha:** [[2026-03-13]]
**Distribución:** Fedora Linux
**Usuario:** julicc

---

## 📋 ÍNDICE

1. [Archivos Gestionados con Stow (dotfiles)](#1-archivos-gestionados-con-stow-dotfiles)
2. [Configuraciones del Sistema (requieren backup manual)](#2-configuraciones-del-sistema-requieren-backup-manual)
3. [Paquetes Instalados](#3-paquetes-instalados)
4. [Eliminados / Cambios Deshechos](#4-eliminados--cambios-deshechos)
5. [Scripts de Backup y Restauración](#5-scripts-de-backup-y-restauración)

---

## 1. ARCHIVOS GESTIONADOS CON STOW (dotfiles)

Estos archivos **ya están versionados** en `/home/julicc/dotfiles/` y se aplican con `stow`:

### Estructura actual de dotfiles:

```
dotfiles/
├── bash/.bashrc           → ~/.bashrc
├── fzf/.config/fzf/       → ~/.config/fzf/
├── git/.config/git/       → ~/.config/git/
├── nvim/init.lua          → ~/.config/nvim/init.lua (bootstrap LazyVim)
├── oh-my-zsh/.config/     → ~/.config/oh-my-zsh/
│   ├── custom/aliases.zsh
│   └── themes/spaceship-prompt/
├── tmux/.config/tmux/     → ~/.config/tmux/tmux.conf
└── zsh/.config/zsh/       → ~/.config/zsh/.zshrc
```

### Para aplicar en nueva instalación:

```bash
cd /home/julicc/dotfiles
stow bash      # Enlaza .bashrc
stow fzf       # Enlaza .config/fzf/
stow git       # Enlaza .config/git/
stow nvim      # Enlaza init.lua
stow oh-my-zsh # Enlaza .config/oh-my-zsh/
stow tmux      # Enlaza .config/tmux/
stow zsh       # Enlaza .config/zsh/
```

### Configuraciones clave en dotfiles:

| Archivo | Contenido principal |
|---------|---------------------|
| `bash/.bashrc` | Prompt personalizado, aliases básicos, historia, Git branch |
| `zsh/.config/zsh/.zshrc` | Oh My Zsh, plugins (git, sudo, z, extract), prompt zen |
| `oh-my-zsh/custom/aliases.zsh` | Alias personalizados (eza, bat, claude, ssh) |
| `tmux/.config/tmux/tmux.conf` | Catppuccin theme, prefix C-space, pane navigation |
| `nvim/init.lua` | Bootstrap LazyVim |
| `fzf/.config/fzf/` | Configuración fzf con preview |

---

## 2. CONFIGURACIONES DEL SISTEMA (requieren backup manual)

⚠️ **ESTAS NO ESTÁN EN DOTFILES** - debes extraerlas manualmente:

### /etc/ - Configuración de Superusuario

| Archivo | Descripción | Comando para extraer |
|---------|-------------|---------------------|
| `/etc/dracut.conf.d/nvidia.conf` | Módulos NVIDIA en initramfs | `sudo cp /etc/dracut.conf.d/nvidia.conf ~/backup/` |
| `/etc/fstab` | Puntos de montaje | `sudo cp /etc/fstab ~/backup/` |
| `/etc/modprobe.d/legion_laptop.conf` | Config módulo Lenovo Legion | `sudo cp /etc/modprobe.d/legion_laptop.conf ~/backup/` |
| `/etc/sysctl.conf` | Parámetros del kernel | `sudo cp /etc/sysctl.conf ~/backup/` |
| `/etc/udev/rules.d/99-power-management.rules` | Reglas energía | `sudo cp /etc/udev/rules.d/99-power-management.rules ~/backup/` |
| `/etc/yum.repos.d/brave-browser.repo` | Repo Brave | `sudo cp /etc/yum.repos.d/brave-browser.repo ~/backup/` |
| `/etc/pki/ca-trust/extracted/openssl/iescierva.crt` | Certificado CA | `sudo cp /etc/pki/ca-trust/extracted/openssl/iescierva.crt ~/backup/` |
| `/etc/systemd/system/ollama.service.d/override.conf` | Override ollama | `sudo cp -r /etc/systemd/system/ollama.service.d/ ~/backup/` |
| `/etc/systemd/system/tuned-monitor-system.service` | Servicio tuned | `sudo cp /etc/systemd/system/tuned-monitor-system.service ~/backup/` |
| `/etc/tuned/` | Perfiles tuned (legion-*) | `sudo cp -r /etc/tuned/ ~/backup/` |

### /usr/ y /lib/ - Scripts del Sistema

| Archivo | Descripción | Comando |
|---------|-------------|---------|
| `/lib/systemd/system-sleep/mt7921-fix` | Fix WiFi MediaTek | `sudo cp /lib/systemd/system-sleep/mt7921-fix ~/backup/` |
| `/lib/systemd/system-sleep/reinit-network` | Reinit red | `sudo cp /lib/systemd/system-sleep/reinit-network ~/backup/` |
| `/lib/dkms/mok.pub` | Clave MOK | `sudo cp /lib/dkms/mok.pub ~/backup/` |
| `/usr/local/bin/power-profile.sh` | Script perfiles energía | `sudo cp /usr/local/bin/power-profile.sh ~/backup/` |
| `/usr/local/bin/legiond` | Daemon Legion | `sudo cp /usr/local/bin/legiond ~/backup/` |

### ~/.config/ - No gestionados por stow

| Archivo | Descripción |
|---------|-------------|
| `~/.config/kitty/kitty.conf` | Configuración terminal kitty (font_size 18.0) |
| `~/.config/systemd/user/power-monitor.service` | Servicio usuario |
| `~/.config/autostart/gnome_power_monitor.sh` | Autoinicio |
| `~/.ssh/id_ed25519*` | Claves SSH |

---

## 3. PAQUETES INSTALADOS

### Repositorios a añadir:

```bash
# RPM Fusion (free y non-free)
sudo dnf install -y \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Brave Browser
sudo curl -o /etc/yum.repos.d/brave-browser.repo \
    https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
```

### Instalación de paquetes:

```bash
# Base y utilidades
sudo dnf install -y \
    neovim kitty zsh fastfetch \
    eza bat fzf ripgrep \
    git tmux \
    brave-browser \
    remmina

# Multimedia
sudo dnf group install -y multimedia sound-and-video
sudo dnf install -y ffmpeg-libs libva libva-utils
sudo dnf swap mesa-va-drivers mesa-va-drivers-freeworld
sudo dnf swap mesa-vdpau-drivers mesa-vdpau-drivers-freeworld

# Virtualización
sudo dnf install -y @virtualization edk2-ovmf swtpm virtio-win
sudo systemctl enable --now libvirtd

# NVIDIA (si hay GPU dedicada)
sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda

# Desarrollo
sudo dnf groupinstall -y "Development Tools"
sudo dnf install -y \
    kernel-headers kernel-devel \
    dmidecode lm_sensors \
    python3-PyQt6 python3-yaml python3-pip \
    dkms openssl mokutil akmods

# Lenovo Legion (solo Legion)
git clone https://github.com/johnfanv2/LegionLinux /tmp/LegionLinux
cd /tmp/LegionLinux
sudo python3 setup.py install
```

### Servicios a habilitar:

```bash
# Secure Boot para módulos kernel
sudo kmodgenca -a
sudo mokutil --import /etc/pki/akmods/certs/public_key.der
# REINICIAR y completar MOK enrollment

# Servicios systemd
sudo systemctl enable --now libvirtd
sudo systemctl enable --now ollama  # si se usa
sudo systemctl enable --now legiond # si es Lenovo Legion
sudo grubby --update-kernel=ALL --args="nvidia-drm.modeset=1"
sudo systemctl disable NetworkManager-wait-online.service
sudo timedatectl set-local-rtc 0

# Regenerar initramfs
sudo dracut --force
```

---

## 4. SCRIPTS DE BACKUP Y RESTAURACIÓN

### Backup (ejecutar en instalación actual):

```bash
#!/bin/bash
# backup-sistema.sh

BACKUP_DIR="$HOME/backup-fedora-$(date +%Y%m%d)"
mkdir -p "$BACKUP_DIR"/{etc,usr,lib,config,ssh}

# Archivos de /etc
sudo cp /etc/dracut.conf.d/nvidia.conf "$BACKUP_DIR/etc/" 2>/dev/null
sudo cp /etc/fstab "$BACKUP_DIR/etc/"
sudo cp /etc/modprobe.d/legion_laptop.conf "$BACKUP_DIR/etc/" 2>/dev/null
sudo cp /etc/sysctl.conf "$BACKUP_DIR/etc/"
sudo cp /etc/udev/rules.d/99-power-management.rules "$BACKUP_DIR/etc/" 2>/dev/null
sudo cp /etc/yum.repos.d/brave-browser.repo "$BACKUP_DIR/etc/"
sudo cp /etc/pki/ca-trust/extracted/openssl/iescierva.crt "$BACKUP_DIR/etc/" 2>/dev/null
sudo cp -r /etc/systemd/system/ollama.service.d/ "$BACKUP_DIR/etc/" 2>/dev/null
sudo cp /etc/systemd/system/tuned-monitor-system.service "$BACKUP_DIR/etc/" 2>/dev/null
sudo cp -r /etc/tuned/ "$BACKUP_DIR/etc/" 2>/dev/null

# Scripts de sistema
sudo cp /lib/systemd/system-sleep/mt7921-fix "$BACKUP_DIR/lib/" 2>/dev/null
sudo cp /lib/systemd/system-sleep/reinit-network "$BACKUP_DIR/lib/" 2>/dev/null
sudo cp /lib/dkms/mok.pub "$BACKUP_DIR/lib/" 2>/dev/null
sudo cp /usr/local/bin/power-profile.sh "$BACKUP_DIR/usr/" 2>/dev/null
sudo cp /usr/local/bin/legiond "$BACKUP_DIR/usr/" 2>/dev/null

# Configuración de usuario
cp -r ~/.config/kitty "$BACKUP_DIR/config/"
cp -r ~/.config/systemd "$BACKUP_DIR/config/" 2>/dev/null
cp -r ~/.config/autostart "$BACKUP_DIR/config/" 2>/dev/null
cp -r ~/.ssh/ "$BACKUP_DIR/ssh/" 2>/dev/null

# Exportar paquetes instalados
dnf list --installed > "$BACKUP_DIR/installed-packages.txt"

# Guardar estructura de stow
ls -la ~/dotfiles/ > "$BACKUP_DIR/dotfiles-structure.txt"

echo "✅ Backup completado en: $BACKUP_DIR"
```

### Restauración (en nueva instalación):

```bash
#!/bin/bash
# restore-sistema.sh

SOURCE_DIR="$1"
if [ -z "$SOURCE_DIR" ]; then
    echo "Uso: $0 <directorio-backup>"
    exit 1
fi

# Restaurar /etc
sudo cp "$SOURCE_DIR/etc/nvidia.conf" /etc/dracut.conf.d/ 2>/dev/null
sudo cp "$SOURCE_DIR/etc/fstab" /etc/
sudo cp "$SOURCE_DIR/etc/legion_laptop.conf" /etc/modprobe.d/ 2>/dev/null
sudo cp "$SOURCE_DIR/etc/sysctl.conf" /etc/
sudo cp "$SOURCE_DIR/etc/99-power-management.rules" /etc/udev/rules.d/ 2>/dev/null
sudo cp "$SOURCE_DIR/etc/brave-browser.repo" /etc/yum.repos.d/
sudo cp "$SOURCE_DIR/etc/iescierva.crt" /etc/pki/ca-trust/extracted/openssl/ 2>/dev/null
sudo cp -r "$SOURCE_DIR/etc/ollama.service.d/" /etc/systemd/system/ 2>/dev/null
sudo cp "$SOURCE_DIR/etc/tuned-monitor-system.service" /etc/systemd/system/ 2>/dev/null
sudo cp -r "$SOURCE_DIR/etc/tuned/" /etc/ 2>/dev/null

# Restaurar scripts
sudo cp "$SOURCE_DIR/lib/mt7921-fix" /lib/systemd/system-sleep/ 2>/dev/null
sudo chmod +x /lib/systemd/system-sleep/mt7921-fix
sudo cp "$SOURCE_DIR/lib/reinit-network" /lib/systemd/system-sleep/ 2>/dev/null
sudo chmod +x /lib/systemd/system-sleep/reinit-network
sudo cp "$SOURCE_DIR/lib/mok.pub" /lib/dkms/ 2>/dev/null
sudo cp "$SOURCE_DIR/usr/power-profile.sh" /usr/local/bin/ 2>/dev/null
sudo chmod +x /usr/local/bin/power-profile.sh
sudo cp "$SOURCE_DIR/usr/legiond" /usr/local/bin/ 2>/dev/null
sudo chmod +x /usr/local/bin/legiond

# Restaurar config de usuario
cp -r "$SOURCE_DIR/config/kitty" ~/.config/
cp -r "$SOURCE_DIR/config/systemd" ~/.config/ 2>/dev/null
cp -r "$SOURCE_DIR/config/autostart" ~/.config/ 2>/dev/null
cp -r "$SOURCE_DIR/ssh/"* ~/.ssh/ 2>/dev/null
chmod 600 ~/.ssh/id_ed25519 2>/dev/null
chmod 644 ~/.ssh/id_ed25519.pub 2>/dev/null

# Aplicar stow para dotfiles
cd ~/dotfiles && stow bash fzf git nvim oh-my-zsh tmux zsh

# Recargar sistema
sudo dracut --force
sudo systemctl daemon-reload
sudo sysctl -p

echo "✅ Restauración completada. REINICIA para aplicar cambios."
```

---

## ⚠️ NOTAS IMPORTANTES

### Hardware específico:

| Componente | Configuración | Solo para |
|------------|---------------|-----------|
| NVIDIA GPU | `nvidia.conf`, `akmod-nvidia` | Sistemas con GPU dedicada |
| Lenovo Legion | `legion_laptop.conf`, `legiond` | Lenovo Legion |
| MediaTek MT7921 | `mt7921-fix` | WiFi MediaTek |
| Certificado IES | `iescierva.crt` | Entornos con CA custom |

### Secure Boot:

Los módulos firmados (NVIDIA, legion_laptop) requieren **MOK enrollment** en el primer boot después de instalar.

### Stow packages:

Para nueva instalación, asegúrate de clonar/copy tu `dotfiles`:

```bash
# En nueva instalación
git clone <tu-repo-dotfiles> ~/dotfiles
# O copiar desde backup
cp -r /path/backup/dotfiles ~/
cd ~/dotfiles
stow bash fzf git nvim oh-my-zsh tmux zsh
```

---

## 📊 RESUMEN

| Categoría | Cantidad |
|-----------|----------|
| Dotfiles (stow) | 7 paquetes |
| Config sistema (/etc) | ~12 archivos |
| Scripts sistema (/usr, /lib) | ~5 archivos |
| Config usuario (~/.config) | ~4 archivos |
| Paquetes instalados | ~50+ |
| Servicios systemd | 5 activos |

---

*Generado desde cambios.txt - Listo para aplicar en nueva instalación*
