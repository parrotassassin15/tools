#!/bin/bash

# Ensure the script is executed with the required file
IP_FILE="ip.txt"
SCRIPT="os-detection.lua"
OUTPUT_FILE="os_scan_results.txt"

# Check if the IP file exists
if [[ ! -f "$IP_FILE" ]]; then
    echo "Error: $IP_FILE not found!"
    exit 1
fi

# Check if the os-detection.lua script exists
if [[ ! -f "$SCRIPT" ]]; then
    echo "Error: $SCRIPT not found!"
    exit 1
fi

# Clear the output file
echo "Starting OS detection..." > "$OUTPUT_FILE"

# Loop through each IP in the file
while IFS= read -r IP; do
    if [[ -n "$IP" ]]; then
        echo "Scanning $IP..."
        nmap --script="$SCRIPT" -O "$IP" >> "$OUTPUT_FILE"
        echo "----------------------------" >> "$OUTPUT_FILE"
    fi
done < "$IP_FILE"

echo "Scan completed. Results saved in $OUTPUT_FILE."
