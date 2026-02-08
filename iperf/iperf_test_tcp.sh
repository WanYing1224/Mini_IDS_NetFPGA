#!/bin/bash

# =======================================================
# CONFIGURATION
# =======================================================
PASS="rvkKVu1ckm31"   
SSH_OPTS="-o StrictHostKeyChecking=no -o ConnectTimeout=5"

TARGET_IP="10.0.1.3"  # Node 1 (Receiver)

TIME=30

# The Pattern that causes the IDS to DROP the packet
BAD_PATTERN="ABCDEFG"

LOG_FILE="logfile_results_tcp.txt"

echo "=========================================================="
echo " Starting TCP Test (Clients: Node 2 & 3 -> Server: Node 1)"
echo " Saving results to: $LOG_FILE"
echo "=========================================================="

echo "Test Date: $(date)" > $LOG_FILE
echo "Test Type: Hardware Routing & IDS Test (TCP Mode)" >> $LOG_FILE
echo "----------------------------------------------------------" >> $LOG_FILE

# Node 2 (GOOD TRAFFIC)
# Removed -u (UDP) and -b (Bandwidth)
echo "Starting Node 2 (Good TCP Traffic)..." | tee -a $LOG_FILE
sshpass -p "$PASS" ssh $SSH_OPTS node0@nf3 "iperf -c $TARGET_IP -l 512 -t $TIME -p 6000" 2>&1 | sed 's/\[  3\]/[n2-Good]/g' | tee -a $LOG_FILE &
PID2=$!

# Node 3 (BAD TRAFFIC)
# Removed -u and -b. Kept -I (Pattern)
echo "Starting Node 3 (Bad TCP Traffic with Pattern)..." | tee -a $LOG_FILE
sshpass -p "$PASS" ssh $SSH_OPTS node0@nf4 "iperf -c $TARGET_IP -l 512 -t $TIME -p 6000 -I $BAD_PATTERN" 2>&1 | sed 's/\[  3\]/[n3-BAD ]/g' | tee -a $LOG_FILE &
PID3=$!

# -------------------------------------------------------
# WAIT
# -------------------------------------------------------
echo ""
echo "Tests running... Output is being saved to $LOG_FILE"
wait $PID2 $PID3

echo "==========================================================" >> $LOG_FILE
echo "Test Finished." | tee -a $LOG_FILE
echo "=========================================================="

# =======================================================
# INSTRUCTIONS FOR SERVER (NODE 1)
# =======================================================
# 1. On Node 1 (Server Window), run this command:
#    iperf -s -p 6000 -i 1
#
# 2. Run this script in the control window:
#    ./iperf_test_tcp.sh
#
# 3. View results:
#    cat logfile_results_tcp.txt