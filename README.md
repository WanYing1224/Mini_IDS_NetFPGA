# Mini_IDS_NetFPGA
This project implements a hardware-accelerated Intrusion Detection System (IDS) on the NetFPGA platform. The design modifies the Reference Router to scan packet payloads in real-time and drop packets containing a specific malicious pattern (e.g., a "virus" signature) at line rate.

## 🚀 Project Overview

The core of this project is a custom Verilog module integrated into the NetFPGA user data path. It inspects every packet passing through the router. If a packet's payload matches a configurable 8-byte hex pattern, the packet is dropped before it reaches the output queues.

**Key Features:**
* **Line-Rate Filtering:** Scans and drops packets directly in hardware (FPGA) without software intervention.
* **Configurable Pattern:** The "virus" string is programmable via software registers (`idsreg`).
* **Match Counter:** A hardware counter tracks exactly how many malicious packets have been blocked.
* **Protocol Agnostic:** Works on both UDP and TCP traffic.
