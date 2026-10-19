#!/bin/bash

# Args Check
if [ -z "$1" ]; then
  echo "Use: $0 <ip address/url>"
  exit 1
fi

# Creating directories
mkdir -p "$1"/{nmap,content,exploits}

# Initial scan (ports)
sudo nmap -sS -T5 -p- -Pn "$1" -oG "$1"/nmap/all_ports.txt

ports=$(grep -oP '\d+(?=/open)' "$1/nmap/all_ports.txt" | paste -sd, -)

if [ -z "$ports" ]; then
  echo "There's no open ports. Closing..."
  rm -rf "$1"
  exit 1
fi

printf "Detected ports: %s\n\n" "$ports"

# Web scan
if [[ ",$ports," == *",80,"* || ",$ports," == *",443,"* ]]; then
  echo "[+] Web port detected! Running fuzzing..."

  # Dir scanning
  ffuf -w /usr/share/dirbuster/wordlists/directory-list-2.3-small.txt -u http://"$1"/FUZZ -o "$1"/content/ffuf_dirs.txt

  # Checking default index size (filtering false positives on vhosts)
  default_size=$(curl -s -o /dev/null -w "%{size_download}" http://"$1")
  echo "[+] Default page size is $default_size bytes. Filtering from vhost scan..."

  # Vhosts scanning
  ffuf -w /usr/share/wordlists/seclists/Discovery/DNS/bitquark-subdomains-top100000.txt -H "Host: FUZZ.$1" -u http://"$1" -fs "$default_size" -o "$1"/content/ffuf_vhosts.txt
fi

# Version scan
sudo nmap -sC -sV -p"$ports" "$1" -oN "$1/nmap/version_scan.txt"

echo "Scan completed. Results in $1/nmap"
