# Learning

Scripts I wrote while studying for ASIR and practising for HTB. They're small and practical; most started as a one-off for a lab or a challenge.

## Bash

| Script | What it does |
| :--- | :--- |
| [`nmap/recon.sh`](bash/nmap/recon.sh) | First-pass recon for a target: full TCP port scan, version/script scan on the open ports, then ffuf for directories and vhosts. Results go into a per-target folder. |
| [`user_provisioning.sh`](bash/user_provisioning.sh) | Creates department groups and numbered users (`systems01`...) in bulk for lab machines, skipping accounts that already exist. |
| [`iso_copy.sh`](bash/iso_copy.sh) | Copies an ISO image to one or more lab servers over `scp`, with `getopts` argument parsing. |
| [`legion-battery-script/`](bash/legion-battery-script/) | TuneD profiles for my Legion laptop (powersave, balanced, performance). They set CPU governor, platform profile and power limits, and switch the internal display's refresh rate under niri, detecting the eDP output at runtime instead of hardcoding it. |

## Python

| Script | What it does |
| :--- | :--- |
| [`bindshell.py`](python/bindshell.py) | Minimal threaded bind shell built on `socket` and `subprocess`, written to understand how bind shells work. |
| [`C2TcpConnection.py`](python/C2TcpConnection.py) | Context-managed TCP connection class (`with` statement) that sends a command and reads the reply. |
| [`html-parser-and-word-sorter.py`](python/html-parser-and-word-sorter.py) | Downloads a page, extracts the text with BeautifulSoup and counts word frequency, useful for building target-specific wordlists. |
| [`lab_network_topology.py`](python/lab_network_topology.py) | OOP practice: models switches, routers and firewalls with inheritance and shows MRO and introspection. |
| [`request_flood.py`](python/request_flood.py) | Solver for a picoCTF web challenge that only returns the flag under load: sends concurrent requests, then polls for the flag. |
