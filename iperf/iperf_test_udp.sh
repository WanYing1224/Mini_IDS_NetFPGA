#!/bin/bash

# =======================================================
# CONFIGURATION
# =======================================================
PASS="rvkKVu1ckm31"   
SSH_OPTS="-o StrictHostKeyChecking=no -o ConnectTimeout=5"

TARGET_IP="10.0.1.3"  

TIME=30


BAD_PATTERN="ABCDEFG"


LOG_FILE="logfile_results_udp.txt"

echo "=========================================================="
echo " Starting Test (Clients: Node 2 & 3 -> Server: Node 1)"
echo " Saving results to: $LOG_FILE"
echo "=========================================================="

echo "Test Date: $(date)" > $LOG_FILE
echo "Test Type: Hardware Routing & IDS Test" >> $LOG_FILE
echo "----------------------------------------------------------" >> $LOG_FILE

echo "Starting Node 2 (Good Traffic)..." | tee -a $LOG_FILE
sshpass -p "$PASS" ssh $SSH_OPTS node0@nf3 "iperf -c $TARGET_IP -u -b 1G -l 512 -t $TIME -p 6000" 2>&1 | sed 's/\[  3\]/[n2-Good]/g' | tee -a $LOG_FILE &
PID2=$!

echo "Starting Node 3 (Bad Traffic with Pattern)..." | tee -a $LOG_FILE
sshpass -p "$PASS" ssh $SSH_OPTS node0@nf4 "iperf -c $TARGET_IP -u -b 1G -l 512 -t $TIME -p 6000 -I $BAD_PATTERN" 2>&1 | sed 's/\[  3\]/[n3-BAD ]/g' | tee -a $LOG_FILE &
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
