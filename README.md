# Mini_IDS_NetFPGA
This project implements a hardware-accelerated Intrusion Detection System (IDS) on the NetFPGA platform. The design modifies the Reference Router to scan packet payloads in real-time and drop packets containing a specific malicious pattern (e.g., a "virus" signature) at line rate.

## 👥 Authors
**USC EE533 Group 2 Members: [Kevelyn Lin](https://github.com/WanYing1224), [Yuxiang Luo](https://github.com/lllyxxxx), [Ian Chen](https://github.com/ichen522)**

## 🚀 Project Overview

The core of this project is a custom Verilog module integrated into the NetFPGA user data path. It inspects every packet passing through the router. If a packet's payload matches a configurable 8-byte hex pattern, the packet is dropped before it reaches the output queues.

**Key Features:**
* **Line-Rate Filtering:** Scans and drops packets directly in hardware (FPGA) without software intervention.
* **Configurable Pattern:** The "virus" string is programmable via software registers (`idsreg`).
* **Match Counter:** A hardware counter tracks exactly how many malicious packets have been blocked.
* **Protocol Agnostic:** Works on both UDP and TCP traffic.
## 📂 Repository Structure

```text
├── Bitfiles/
│   └── nf2_top_par_3.bit         # Compiled bitfile for the NetFPGA
│   └── ids_passthrough.bit       # Compiled bitfile for the NetFPGA
├── Verilog/
│   └── passthrough.v             # Verilog code for ids_passthrough bitfile
├── sw/
│   ├── idsreg_2                  # Perl/C script to read/write FPGA registers
├── iperf/
│   ├── iperf_test_udp.sh         # UDP Traffic generation script
│   ├── iperf_test_tcp.sh         # TCP Traffic generation script
│   └── iperf_test.sh             # Multi-client load testing script
├── src/
│   └── (Verilog source files for the IDS module)
└── README.md
```
## ⚙️ Setup & Installation

1. Load the Hardware - Flash the compiled bitfile to the NetFPGA card.
2. Start the Router Daemon - The rkd daemon handles the routing tables (ARP/LPM).

## 🛡️ Usage: Configuring the Firewalls

We use the idsreg_2 tool to communicate with the FPGA registers over the PCI bus.

1. Set the Virus Pattern Define the string you want to block (e.g., "ABCDEFG").
2. Reset the Drop Counter Clear any previous match stats.
3. Check Status Verify the register is working (should return 0 initially). If it shows "deadbeef", means that the IDS address inside the idsreg file does not match the address inside your bitfile.

## 🧪 Testing & Verification 

The repository includes automated scripts to generate traffic from multiple client nodes (Node 1, 2, 3) to a Server (Node 0).

**Test 1: iperf UDP testing (Packet Loss)**

* In this testing, we use node0 as the server, and node1-3 as the client. The 3 client will send the packet to node0 at the same time. The lost percentage of the packet will be shown at the end.

* Command: `./iperf_test.sh`

* Behavior::
* 
  * All package will be send and the average of the bandwidth and the drop will be shown in the control window.
  * Use `cat logfile_results.txt` to see the final result if it is not shown in the control window.

**Test 2: UDP Filtering (Packet Loss)**

* In UDP mode, "Bad" packets should simply disappear.

* Command: `./iperf_test_udp.sh`

* Behavior:

  * Client 1 & 2 (Good): High throughput (e.g., ~30Mbps).
  * Client 3 (Bad): 0.0 Mbps throughput. The server receives nothing.

**Test 3: TCP Filtering (Connection Hang)**

* In TCP mode, the 3-way handshake (SYN) passes (as it has no payload), but data packets are dropped.

* Command: `./iperf_test_tcp.sh`

* Behavior:

  * Client 3 (Bad): Connects successfully, but the transfer "hangs" or stalls immediately. Bandwidth drops to 0.0.

**Verification**

* After running the tests, query the hardware to confirm it was the FPGA that dropped the packets: `./scripts/idsreg_2 matches`

  > Success: Output should be a positive integer (e.g., 5423 matches).

## 📝 Register Map

| Register Name        | Address     | R/W | Description                           |
| ----------------     | ---------   | :-: | ------------------------------------- |
| `IDS_PATTERN_HI_REG` | `0x2000300` |  W  | Upper 32-bits of the match pattern    |
| `IDS_PATTERN_LO_REG` | `0x2000304` |  W  | Lower 32-bits of the match pattern    |
| `IDS_COMMAND_REG`    | `0x2000308` |  W  | Write any value to reset the counter  |
| `IDS_MATCHES_REG`    | `0x200030C` |  R  | Counter: Number of packets dropped    |
