#!/bin/bash

# Args Check
if [ -z "$1" ]; then
  echo "Use: $0 <ip address>"
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

# Version scan
sudo nmap -sC -sV -p"$ports" "$1" -oN "$1/nmap/version_scan.txt"

echo "Scan completed. Results in $1/nmap"
