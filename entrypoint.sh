#!/bin/bash
set -e

NGINX_CONF=/etc/nginx/nginx.conf
PORT_BASE=5000
COUNT=0

echo "Generating nginx.conf..."

# Start the base nginx config with a universal rewrite to strip trailing slashes and keep port
cat > $NGINX_CONF <<EOF
worker_processes 1;

events {
    worker_connections 1024;
}

http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;

    server {
        listen 80;

        # Global: remove trailing slash on ANY url, preserve port
        if (\$request_uri ~ ^(.+)/+$) {
            return 301 \$scheme://\$host:\$server_port\$1;
        }
EOF

# For each API, install requirements and add nginx location block
for dir in ./*-api; do
    if [ -d "$dir" ]; then
        echo "Processing $dir"

        if [ -f "$dir/requirements.txt" ]; then
            echo "Installing requirements for $dir"
            pip install --no-cache-dir -r "$dir/requirements.txt"
        fi

        PORT=$((PORT_BASE + COUNT))
        COUNT=$((COUNT + 1))

        LOCATION="/v$COUNT"

        echo "Adding nginx route $LOCATION -> localhost:$PORT"
        cat >> $NGINX_CONF <<EOF
        location $LOCATION {
            proxy_pass http://localhost:$PORT/;
            proxy_set_header Host \$host;
        }
EOF

        echo "Starting $dir/app.py on port $PORT"
        python "$dir/app.py" -p "$PORT" &
    fi
done

# Close the nginx config
cat >> $NGINX_CONF <<EOF
    }
}
EOF

# Start nginx
echo "Starting nginx with generated config..."
nginx

echo "All apps and nginx started. Waiting for processes."
wait
