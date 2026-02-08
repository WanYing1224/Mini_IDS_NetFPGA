#!/bin/bash

# =======================================================
# CONFIGURATION
# =======================================================
PASS="rvkKVu1ckm31"   
SSH_OPTS="-o StrictHostKeyChecking=no -o ConnectTimeout=5"

# SERVER IP (Node 0)
TARGET_IP="10.0.0.3"  

TIME=30
BAD_PATTERN="ABCDEFG"
BANDWIDTH="10M"  # Adjust to 1G if you want to stress test

LOG_FILE="logfile_results_udp.txt"

echo "=========================================================="
echo " Starting UDP Test (Clients: 1,2,3 -> Server: Node 0)"
echo " Saving results to: $LOG_FILE"
echo "=========================================================="

echo "Test Date: $(date)" > $LOG_FILE
echo "Type: 2 Good Clients + 1 Bad Client (UDP)" >> $LOG_FILE
echo "----------------------------------------------------------" >> $LOG_FILE

# -------------------------------------------------------
# CLIENT 1: Node 1 (GOOD TRAFFIC)
# -------------------------------------------------------
echo "Starting Client 1 on Node 1 (nf2) - GOOD..." | tee -a $LOG_FILE
sshpass -p "$PASS" ssh $SSH_OPTS node0@nf2 "iperf -c $TARGET_IP -u -b $BANDWIDTH -l 512 -t $TIME -p 6000" 2>&1 | sed 's/\[  3\]/[N1-Good]/g' | tee -a $LOG_FILE &
PID1=$!

# -------------------------------------------------------
# CLIENT 2: Node 2 (GOOD TRAFFIC)
# -------------------------------------------------------
echo "Starting Client 2 on Node 2 (nf3) - GOOD..." | tee -a $LOG_FILE
sshpass -p "$PASS" ssh $SSH_OPTS node0@nf3 "iperf -c $TARGET_IP -u -b $BANDWIDTH -l 512 -t $TIME -p 6000" 2>&1 | sed 's/\[  3\]/[N2-Good]/g' | tee -a $LOG_FILE &
PID2=$!

# -------------------------------------------------------
# CLIENT 3: Node 3 (BAD TRAFFIC - WITH VIRUS)
# -------------------------------------------------------
echo "Starting Client 3 on Node 3 (nf4) - BAD (Virus)..." | tee -a $LOG_FILE
sshpass -p "$PASS" ssh $SSH_OPTS node0@nf4 "iperf -c $TARGET_IP -u -b $BANDWIDTH -l 512 -t $TIME -p 6000 -I $BAD_PATTERN" 2>&1 | sed 's/\[  3\]/[N3-BAD ]/g' | tee -a $LOG_FILE &
PID3=$!

# -------------------------------------------------------
# WAIT
# -------------------------------------------------------
echo ""
echo "Tests running... Waiting for completion..."
wait $PID1 $PID2 $PID3

echo "==========================================================" >> $LOG_FILE
echo "Test Finished." | tee -a $LOG_FILE
echo "=========================================================="


# =======================================================
# INSTRUCTIONS FOR SERVER (NODE 1)
# =======================================================
# 1. On Node 1 (Server Window), run this command:
#    iperf -s -u -p 6000 -i 1
#
# 2. Run this script in the control window:
#    ./iperf_test_udp.sh
#
# 3. View results:
#    cat logfile_results_udp.txt
