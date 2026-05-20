# IGP
Used to share routes within a single autonomous system, which is a single orgnization
![[Pasted image 20260506232410.png]]
## Algorithm type
### Distance Vector
Operate by sending their knwon destination networks and their metric to reach their known destination networks (routing by rumor)
The router doesn't know about the network beyond its neighbors.
#### [[Routing Protocols#RIP|RIP]]
#### EIGRP
Enhanced Interior Gateway Routing Protocol
### Link State
Every routers create a connectivity map of the network. To allow this each router advertises info about its interfaces to its neighbours. These are passed along to other routers until they develop the same map of the network. 
They use this map to calculate the best routes to each destination.
Link state protocols use more resources on the router because more info is shared, but tend to be faster in reacting to changes in the network.

##### ECMP (Equal Cost Multi-Path)
![[Pasted image 20260506232130.png]]
#### [[Routing Protocols#OSPF|OSPF]]
#### IS-IS
Intermediate System to Intermediate System
![[Pasted image 20260506234610.png]]![[Pasted image 20260506234616.png]]
# EGP
used to share routes between different autonomous systems
### Algorithm type: Path Vector
Border Gateway Protocol (BGP)
