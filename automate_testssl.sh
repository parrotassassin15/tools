#!/bin/bash

# Check if ip.txt exists
if [[ ! -f "ip.txt" ]]; then
    echo "Error: ip.txt not found!"
    exit 1
fi

# Iterate through each line in ip.txt and pass it to testsshl.sh
while IFS= read -r ip; do
    if [[ -n "$ip" ]]; then
        echo "Testing SSH on $ip..."
        ./testsshl.sh "$ip"
    fi
done < "ip.txt"

echo "All tests completed."
