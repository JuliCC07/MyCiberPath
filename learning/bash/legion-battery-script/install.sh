#!/bin/bash
# Battery Profile & Script installation for my LL5Pro Gen 8

set -e
# DIR of the script
DIR="$(cd "$(dirname "$0")" && pwd)"

echo "╔══════════════════════════════════════╗"
echo "║legion-battery-configs — install.sh   ║"
echo "╚══════════════════════════════════════╝"
echo ""

echo "  Installing tuned profiles"
for profile in legion-powersave legion-balanced legion-balanced-battery legion-performance; do
  sudo cp -r "$DIR/tuned-profiles/$profile" /usr/lib/tuned/profiles/
  echo " $profile imported"
done

echo "  Importing tuned configs"
sudo cp "$DIR/tuned-configs/tuned-main.conf" /etc/tuned/tuned-main.conf
sudo cp "$DIR/tuned-configs/ppd.conf" /etc/tuned/ppd.conf
echo "  Imported successfully"


echo "  Restarting tuned services"
sudo systemctl restart tuned
sudo systemctl restart tuned-ppd
echo "  Done"
