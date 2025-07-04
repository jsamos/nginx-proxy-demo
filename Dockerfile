FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y python3 python3-pip nginx openssl && \
    ln -s /usr/bin/python3 /usr/bin/python

WORKDIR /app

COPY . .

RUN mkdir -p /etc/nginx/certs && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/certs/dev.key \
    -out /etc/nginx/certs/dev.crt \
    -subj "/CN=localhost"

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
