## TL;DR
**IPs stay the same, MACs change at every hop.** 
## The Two Golden Rules of Routing 
1. **Layer 3 is End-to-End (Untouchable):** The original IP packet is never modified. The Source IP and Destination IP remain exactly the same from the sender to the final receiver. 
2. **Layer 2 is Hop-by-Hop (Disposable):** The Ethernet frame (MAC addresses) is destroyed and rebuilt by **every single router** along the path. 
	* *Process:* Router receives frame -> De-encapsulates (strips MACs) -> Reads Destination IP -> Checks Routing Table -> Re-encapsulates with new MACs (Next-Hop) -> Forwards. 
## Do Routers Store MAC Addresses? 
**Yes. It is mandatory.** Because routers must re-encapsulate packets into Layer 2 frames, they need to know the MAC address of the next hop. They use **ARP (Address Resolution Protocol)** to find it and store the result in their **ARP Cache**. Without this, physical transmission to the next node is impossible.

--- 
## 🛑 Offensive Security Takeaway: ARP Spoofing Limitations
Understanding the Hop-by-Hop nature of Layer 2 is critical for Man-in-the-Middle (MitM) attacks. 
* **The Limitation:** You can only perform ARP Spoofing within your **local subnet** (Layer 2 broadcast domain). 
* **The Reason:** Even if you successfully spoof a MAC address to intercept traffic, the moment that traffic crosses a router to reach another network, the router will strip your spoofed Layer 2 header and replace it with its own. 
* **Conclusion:** You cannot natively ARP spoof a target that is on a different subnet.