---
categories:
  - "[[Ciber]]"
tags:
  - networking
  - ccna
  - vlans
---
show vlan brief
name "vlan"
switchport mode access
switchport access vlan "vlan"
switchport mode trunk
switchport trunk ?
show int trunk


2 methods of configuring the native vlan on a router:
- encapsulation dot1q vlan-id native
- configure the ip address for the native vlan on the router's physical interface

Multilayer switches are capable of both switching and routing:
- asign ip addresses to its interfaces, create virtual interfaces for each vlan and assign ip addresses to those interfaces, configure routes on it and can be used for inter-vlan routing
SVI: Virtual interfaces you can assign ip addresses to in a ml switch
- configure each pc to use the svi as their gateway address 
- the switch route the traffic
(in router)
no interface
default interface
(in switch)
ip routing
no switchport
ip route 0.0.0.0 0.0.0.0 "ip" para redirigir todas las ips a la ip del router
 interface vlan 10
ip address
no shutdown


Show int switchport configuration:
show interfaces "interface" switchport


# Step by step guide of 18th day lab

## Step 1:
Removing subinterfaces from R1 in order to replace ROAS with point-to-point connection
- ### Removing an interface configuration
	no int "interface"
- ### Enabling layer 3 capabilities on Multilayer Switch
	no switchport
	ip add ...
	ip routing
	**Setting the default route:**ip add 0.0.0.0 0.0.0.0 "router address"
## Step 2:
Configure SVI on SW2, one for each VLAN
- ### Creating the interfaces and setting up addresses
	interface vlan "vlan id"
	ip add "add" (in this case the last usable address)
	no shutdown
	
