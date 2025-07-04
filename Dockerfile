FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y python3 python3-pip nginx && \
    ln -s /usr/bin/python3 /usr/bin/python

WORKDIR /app

COPY . .

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
