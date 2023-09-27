#!/bin/bash

# Function to create a commit
create_commit() {
    local start=$1
    local end=$2
    local retries=10
    local counter_file="$3"

    for ((j=start; j<end; j++)); do
        hex_value=$(openssl rand -hex 16)
        for ((r=0; r<retries; r++)); do
            git commit --allow-empty -m "$hex_value" &> /dev/null && break
            sleep 1
        done
        # Atomically update the commit count
        flock "$counter_file" -c "echo \$((\$(cat $counter_file) + 1)) > $counter_file"
    done
}

repo_path="."
num_processes=100
num_commits=10000000
chunk_size=$((num_commits / num_processes))
touch "$repo_path/.commit_lock"

# Create a counter file to keep track of commits created
counter_file="$repo_path/.commit_counter"
echo "0" > "$counter_file"

# Initialize a timer to show progress every 10 seconds
interval=5
start_time=$(date +%s)

for ((i=0; i<num_processes; i++)); do
    start=$((i * chunk_size))
    end=$((start + chunk_size))
    create_commit "$start" "$end" "$counter_file" &
done

# Continuously display progress every 10 seconds
while true; do
    current_time=$(date +%s)
    elapsed_time=$((current_time - start_time))
    final_commit_count=$(cat "$counter_file")
    echo "Created $final_commit_count commits in $elapsed_time seconds"
    sleep $interval
done
