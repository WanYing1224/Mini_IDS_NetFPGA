#!/bin/bash

# =======================================================
# CONFIGURATION
# =======================================================
PASS="rvkKVu1ckm31"  
SSH_OPTS="-o StrictHostKeyChecking=no -o ConnectTimeout=5"
TARGET_IP="10.0.0.3" # Node 0 (The Receiver)
TIME=30

# File to save results
LOG_FILE="logfile_results.txt"

echo "=========================================================="
echo " Starting Many-to-One Test (3 Clients -> 1 Server)"
echo " Saving results to: $LOG_FILE"
echo "=========================================================="

# Create/Clear the log file and add a header
echo "Test Date: $(date)" > $LOG_FILE
echo "Test Type: Many-to-One (Congestion Test)" >> $LOG_FILE
echo "----------------------------------------------------------" >> $LOG_FILE

# -------------------------------------------------------
# START CLIENTS
# -------------------------------------------------------
# We use 'tee -a $LOG_FILE' to show output on screen AND save to file at the same time.

# Node 1
echo "Starting Node 1..." | tee -a $LOG_FILE
sshpass -p "$PASS" ssh $SSH_OPTS node0@nf2 "iperf -c $TARGET_IP -u -b 1G -l 512 -t $TIME -p 6000" 2>&1 | sed 's/\[  3\]/[n1]/g' | tee -a $LOG_FILE &
PID1=$!

# Node 2
echo "Starting Node 2..." | tee -a $LOG_FILE
sshpass -p "$PASS" ssh $SSH_OPTS node0@nf3 "iperf -c $TARGET_IP -u -b 1G -l 512 -t $TIME -p 6000" 2>&1 | sed 's/\[  3\]/[n2]/g' | tee -a $LOG_FILE &
PID2=$!

# Node 3
echo "Starting Node 3..." | tee -a $LOG_FILE
sshpass -p "$PASS" ssh $SSH_OPTS node0@nf4 "iperf -c $TARGET_IP -u -b 1G -l 512 -t $TIME -p 6000" 2>&1 | sed 's/\[  3\]/[n3]/g' | tee -a $LOG_FILE &
PID3=$!

# -------------------------------------------------------
# WAIT
# -------------------------------------------------------
echo ""
echo "Tests running... Output is being saved to $LOG_FILE"
wait $PID1 $PID2 $PID3

echo "==========================================================" >> $LOG_FILE
echo "Test Finished." | tee -a $LOG_FILE
echo "=========================================================="

# Node0 is the server, and node 1-3 is the client.
# Run "iperf -s -u -p 6000 -i 1" in the server window.
# Run "./iperf_test.sh" in the control window.
# Node 0 will show the recieved data and after finsih running it will generate a logfile results.
# Enter "cat logfile_results.txt" in the controller window then you can see the result file.
