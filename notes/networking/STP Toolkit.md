---
categories:
  - "[[Ciber]]"
tags:
  - ccna
  - stp
  - ciber
  - networking
  - switch
  - tools
created: 2026-04-13
---
# PortFast
Bypass the Listening & Learning States (takes 30 seconds) of a port and it can send data right away.
There are two kinds of PortFast:
- edge
- network (not for CCNA)
When you should enable PortFast on a trunk port:
- A port connected to a virtualization server with VM in different [[VLANs|VLANS]]
- A port connected to a router via ROAS
- Only configured via interface config mode
### Commands
Interface config mode: `spanning-tree portfast`
Global config mode `spanning-tree portfast default` (all access ports)
# BPDU Guard
PortFast doesn't disable STP, the switch will continue sending BPDUs every 2 seconds. Portfast ports shouldn't receive BPDU's.
In an BPDU Guard-Enabled port, if it receives a BPDU, it will enter in a error-disabled state disabling the port.
**ErrDisable** is a cisco switch feature that disables a port under certain conditions.
### Commands
Interface config mode: `spanning-tree bpduguard enable`
Global config mode `spanning-tree portfast bpduguard default` (all portfast-enabled ports)
Re-enable a err-disable port:
- Manual: `shutdown` and `noshutdown`
- Automatic: `show errdisable recovery` -> `errdisable recovery interval "seconds"` / `errdisable recovery cause bpduguard`
# BPDU Filter
Sending BPDUs to a port not connected to a switch is unnecesssary and undesirable because:
- Use some bandwidth and processing power on the switch
- It contains information about the LAN's STP topology, which is matter for security concern 
BPDU Filter fixes these problem. It stops a port from sending BPDUs
### Solution
- Enable PortFast and BPDU Guard however you prefer.
- Only enable BPDU Filter by default unless you have a very good reason to enable it per-port.
BPDU Guard & BPDU Filter can be eneabled on the same port at the same time. If a port receives a BPDU:
- In **global config mode**: BPDU Filter will be disabled and BPDU Guard will be triggered (errdisable)
- In **interface config mode**: BPDU will be ignored and BPDU Guard will not be triggered.
## Commands
Interface config mode: `spanning-tree bpdufilter enable` (In effect, this disables STP on the port)
Global config mode `spanning-tree portfast bpdufilter default` (all portfast-enabled ports)

# Root Guard
Prevents a port from becoming a Root Port by disablig it if superior BPDUs are received, thereby enforcing the current Root Bridge
## Root Bridge Placement
Things you should consider:
- Optimal traffic flow
	- Minimize latency
	- Minimize congestion
- Stability and reliability
## Problem
A service provider offers a Metro Ethernet connection, each root bridge collides and then one of those becomes the root bridge of the whole network, affecting the STP topology.
## Solution
Root Guard can be configured to protect your STP topology by preventing your switches from accepting superior BPDUs from switches outside of your control. 
If a Root Guard-enabled port receives a BPDU, it will enter the Broken state, effectively disabling it.
- The port will not be able to forward data frames and will discard any frames it receives.
To re-enable a port disabled by Root Guard, you must solve the issue that disabled the port.
- The disabled port must stop receiving BPDUs.
- Tell the customer to increase the priority value of their switch.
### Commands
Interface config mode: `spanning-tree guard root`
# Loop Guard
Protects the network from loops by disabling a port if it unexpectedly stops receiving BPDUs, ensuring it does not mistakenly enter the Forwarding state. For example:
- A software bug preventing a switch from sending BPDUs
- Hardware issue causing an unidirectional link (data transmission occurs in only one direction)
If a Loop Guard-enabled port stops receiving BPDUs, it enters the Broken (Loop Inconsistent) state, effectively disabling the port. When it receives BPDUs again, it will be automatically re-enabled.

Loop Guard and Root Guard are mutually exclusive:
- If Loop Guard is configured on a port and you then configure Root Guard, Loop Guard will be disabled on the port (and vice-versa)
- If Loop Guard is enabled by default and you then configure Root Guard on a port, Loop Guard will be disabled on the port.
### Commands
Interface config mode: `spanning-tree guard loop/none`
Global config mode `spanning-tree loopguard default` (all portfast-enabled ports)