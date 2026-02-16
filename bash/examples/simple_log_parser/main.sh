#!/usr/bin/env bash

log_dir="/var/log" # Location of the log folder

error_patterns=(
    "ERROR"
    "FATAL"
    "CRITICAL"  
)

echo "Analyzing log files"
echo "==================="

log_files=$(sudo find $log_dir -name "*.log" -mtime -1) # Log files that changed in the last 24 hrs
echo -e "\nList of log files updated in the last 24 hours:\n"
echo "$log_files"

for log_file in ${log_files[@]}; do

        for pattern in ${error_patterns[@]}; do

            pattern_count=$(sudo grep -c "$pattern" "$log_file")
            
            # Only show errors if they exist
            # ! "sudo grep" will always write to /var/log/auth.log. Those are false positives and indicate sudo execution. Consider removing auth.log from the script (below line) and use separate script for auth.log?
            #if [[ $pattern_count -gt 0 && $log_file != "/var/log/auth.log" ]]; then            
            if [[ $pattern_count -gt 0 ]]; then

                echo -e "\n"
                echo "=========================================================="
                echo "FILE: $log_file ($pattern: $pattern_count)"
                echo "=========================================================="

                sudo grep -i "$pattern" "$log_file"
            
            fi

        done

done