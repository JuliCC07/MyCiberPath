#!/bin/bash
# Battery Profile & Script installation for my LL5Pro Gen 8

set -e
# DIR of the script
DIR="$(cd "$(dirname "$0")" && pwd)"

echo "╔══════════════════════════════════════╗"
echo "║legion-battery-configs — install.sh   ║"
echo "╚══════════════════════════════════════╝"
echo ""

# Checking missing packages
MISSING=0
for cmd in tuned-adm gdbus gnome-monitor-config; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "  Missing: $cmd"
    MISSING=1
  fi
done
if [ "$MISSING" = "1" ]; then
  echo ""
  echo "  Install the missing packages before continuing"
  echo "  sudo dnf install gnome-monitor-config"
  echo "  sudo dnf copr enable mrduarte/LenovoLegionLinux && sudo dnf install LenovoLegionLinux"
  exit 1
fi
echo "   OK"

echo "  Installing tuned profiles"
for profile in legion-powersave legion-balanced legion-balanced-battery legion-performance; do
  sudo cp -r "$DIR/tuned-profiles/$profile" /usr/lib/tuned/profiles/
  echo " $profile imported"
done

echo "  Importing tuned configs"
sudo cp "$DIR/tuned-configs/tuned-main.conf" /etc/tuned/tuned-main.conf
sudo cp "$DIR/tuned-configs/ppd.conf" /etc/tuned/ppd.conf
echo "  Imported successfully"

echo "  Installing system services"
sudo install -Dm755 "$DIR/tuned-scripts/tuned-monitor-system.sh" /usr/local/bin/tuned-monitor-system.sh
sudo install -Dm644 "$DIR/tuned-services/tuned-monitor-system.service" /etc/systemd/system/tuned-monitor-system.service
sudo systemctl daemon-reload
sudo systemctl enable --now tuned-monitor-system.service
echo "  Installed successfully"

echo "  Installing user services"
install -Dm755 "$DIR/tuned-scripts/tuned-monitor-user.sh" "$HOME/.local/bin/tuned-monitor-user.sh"
install -Dm644 "$REPO_DIR/tuned-services/power-monitor.service" "$HOME/.config/systemd/user/power-monitor.service"
systemctl --user daemon-reload
systemctl --user enable --now power-monitor.service
echo "  Installed successfully"

echo "  Restarting tuned services"
sudo systemctl restart tuned
sudo systemctl restart tuned-ppd
echo "  Done"
