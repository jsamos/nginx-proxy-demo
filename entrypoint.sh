#!/bin/bash
set -e

PORT_BASE=5000
COUNT=0

echo "Finding API directories and installing dependencies..."

for dir in ./*-api; do
    if [ -d "$dir" ]; then
        echo "Found API directory: $dir"
        
        if [ -f "$dir/requirements.txt" ]; then
            echo "Installing requirements for $dir"
            pip install --no-cache-dir -r "$dir/requirements.txt"
        else
            echo "No requirements.txt in $dir, skipping pip install."
        fi

        PORT=$((PORT_BASE + COUNT))
        COUNT=$((COUNT + 1))

        echo "Starting $dir/app.py on port $PORT"
        python "$dir/app.py" -p "$PORT" &
    fi
done

echo "All apps started. Waiting for processes to complete."
wait