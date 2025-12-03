#!/bin/bash

echo "Log generator started at $(date)"

counter=1
while true; do
    # Generate different types of logs
    case $((counter % 5)) in
        0)
            echo "[INFO] $(date '+%Y-%m-%d %H:%M:%S') - Processing request #$counter"
            ;;
        1)
            echo "[DEBUG] $(date '+%Y-%m-%d %H:%M:%S') - Debug message $counter - Memory usage: $((RANDOM % 100))%"
            ;;
        2)
            echo "[WARN] $(date '+%Y-%m-%d %H:%M:%S') - Warning: High latency detected - ${RANDOM}ms"
            ;;
        3)
            echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') - Error processing item $counter - Retrying..."
            ;;
        4)
            echo "[INFO] $(date '+%Y-%m-%d %H:%M:%S') - Successfully completed operation $counter"
            ;;
    esac
    
    counter=$((counter + 1))
    sleep 2
done