# PRODUCTION.md

This document captures the steps to deploy your production multi-API service behind nginx with Let's Encrypt SSL.

---

## 🚀 1. Install dependencies on the server

```bash
sudo apt-get update && sudo apt-get install -y python3 python3-pip nginx openssl && sudo ln -s /usr/bin/python3 /usr/bin/python
```

Install certbot (via snap):

```bash
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot
```

---

## 🚀 2. Clone the project

```bash
cd /
git clone git@github.com:jsamos/nginx-proxy-demo.git
mv nginx-proxy-demo app
cd app
```

---

## 🚀 3. Install Python dependencies and start APIs

```bash
pip install --no-cache-dir -r ./v1-api/requirements.txt
pip install --no-cache-dir -r ./v2-api/requirements.txt

cd /app/v1-api
gunicorn --bind 0.0.0.0:5000 --workers 2 --timeout 120 app:app &

cd /app/v2-api
gunicorn --bind 0.0.0.0:5001 --workers 2 --timeout 120 app:app &
```

---

## 🚀 4. Set up nginx site configuration

Create `/etc/nginx/sites-available/rockres.tech.conf`:

```nginx
server {
    listen 80;
    server_name api.rockres.tech;

    if ($request_uri ~ ^(.+)/+$) {
        return 301 $scheme://$host$1;
    }

    location /v1 {
        proxy_pass http://localhost:5000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /v2 {
        proxy_pass http://localhost:5001/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Enable the site:

```bash
sudo ln -s /etc/nginx/sites-available/rockres.tech.conf /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl reload nginx
```

---

## 🚀 5. Obtain Let's Encrypt SSL certificate

```bash
sudo certbot --nginx -d api.rockres.tech
sudo systemctl reload nginx
```

---

## ✅ Testing

```bash
curl -v http://api.rockres.tech/v1
curl -v https://api.rockres.tech/v1
curl -v https://api.rockres.tech/v1/some/path/
```

Ensure trailing slashes are removed, HTTP redirects to HTTPS, and your app receives correct headers.

---

## 🚀 Notes

- Apps run via `gunicorn` on ports `5000`, `5001`.
- nginx proxies requests and handles SSL termination.
- Certbot automatically sets up HTTPS and renewals.

Done 🚀
