#!/bin/bash
#
# Find the top 10 processes by the number of open files on macOS.
# Uses lsof to count files per process and ps to get command names.

echo " PID   Count Command"
echo "----- ------- --------"

# Get PIDs and their open file counts, sorted numerically descending
# -n prevents DNS lookups, potentially speeding things up.
# awk 'NR>1 {print $2}' extracts the PID (2nd column), skipping the header.
# sort | uniq -c counts occurrences of each PID.
# sort -nr sorts numerically in reverse (highest count first).
# head -n 10 takes the top 10 results.
pids_counts=$(lsof -n | awk 'NR>1 {print $2}' | sort | uniq -c | sort -nr | head -n 10)

# Check if lsof produced any output
if [ -z "$pids_counts" ]; then
  echo "Could not retrieve process information. Try running with sudo?"
  exit 1
fi

# Iterate over the results (count pid) and get the command name for each PID
echo "$pids_counts" | while IFS= read -r line; do
  # Extract count and pid carefully, handling potential leading spaces from uniq -c
  count=$(echo "$line" | awk '{print $1}')
  pid=$(echo "$line" | awk '{print $2}')

  # Get command name using ps, suppressing errors if the process disappears.
  # -o comm= outputs only the command name without header.
  # head -n 1 ensures only one line is processed if ps outputs more.
  # awk -F/ '{print $NF}' extracts the base name if the command includes a path.
  command_name=$(ps -p "$pid" -o comm= 2>/dev/null | head -n 1 | awk -F/ '{print $NF}')

  # Handle cases where the command name couldn't be retrieved
  if [ -z "$command_name" ]; then
    command_name="<unknown/gone>"
  fi

  # Print formatted output: PID (5 chars wide), Count (7 chars wide), Command name
  printf "%5s %7s %s\n" "$pid" "$count" "$command_name"
done

exit 0
