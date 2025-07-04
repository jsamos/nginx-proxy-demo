# NGINX App Server Proxy Demo

A flexible Docker-based demo that automatically discovers and proxies multiple Python API applications through NGINX with SSL termination.

## Overview

This project demonstrates a scalable approach to running multiple API services behind a single NGINX reverse proxy. The system automatically:

- Discovers all `*-api` directories containing Python applications
- Starts each API on successive ports (5000, 5001, 5002, etc.)
- Configures NGINX to proxy requests to each API with versioned routes (`/v1`, `/v2`, etc.)
- Provides SSL termination with a self-signed development certificate
- Exposes everything through a single HTTPS endpoint

## Features

- **Auto-discovery**: Automatically finds and starts all `*-api` directories
- **Port management**: Assigns sequential ports starting from 5000
- **SSL termination**: Includes self-signed certificate for HTTPS testing
- **Versioned routing**: Each API gets a `/v{n}` route based on discovery order
- **Dependency management**: Automatically installs `requirements.txt` for each API
- **Health checks**: Each API includes a `/health` endpoint

## Project Structure

```
nginx-proxy/
├── docker-compose.yml      # Docker Compose configuration
├── Dockerfile              # Container definition
├── entrypoint.sh          # Auto-discovery and startup script
├── data/                  # Persistent data directory
├── v1-api/               # Example API v1
│   ├── app.py
│   └── requirements.txt
└── v2-api/               # Example API v2
    ├── app.py
    └── requirements.txt
```

## Quick Start

1. **Clone and navigate to the project:**
   ```bash
   cd nginx-proxy
   ```

2. **Build and start the containers:**
   ```bash
   docker-compose up --build
   ```

3. **Test the APIs:**
   ```bash
   # Test v1 API
   curl -k https://localhost:8443/v1
   
   # Test v2 API
   curl -k https://localhost:8443/v2
   
   # Health checks
   curl -k https://localhost:8443/v1/health
   curl -k https://localhost:8443/v2/health
   ```

## Adding New APIs

To add a new API service:

1. **Create a new directory** with the pattern `{name}-api`:
   ```bash
   mkdir my-new-api
   ```

2. **Add your Python application** with the following structure:
   ```
   my-new-api/
   ├── app.py              # Your Flask/FastAPI application
   └── requirements.txt    # Python dependencies (optional)
   ```

3. **Ensure your app.py accepts a port argument:**
   ```python
   import argparse
   
   if __name__ == '__main__':
       parser = argparse.ArgumentParser()
       parser.add_argument('-p', '--port', type=int, default=5000)
       args = parser.parse_args()
       
       app.run(host='0.0.0.0', port=args.port)
   ```

4. **Rebuild and restart:**
   ```bash
   docker-compose up --build
   ```

Your new API will automatically be available at `https://localhost:8443/v{n}` where `n` is the discovery order.

## API Requirements

Each API directory should contain:

- **`app.py`**: Main application file (required)
- **`requirements.txt`**: Python dependencies (optional)

The `app.py` file must:
- Accept a `-p` or `--port` argument for the port number
- Bind to `0.0.0.0` to accept external connections
- Include a root route (`/`) for basic functionality

## Port Mapping

- **HTTP**: `localhost:8080` → Container port 80
- **HTTPS**: `localhost:8443` → Container port 443
- **Internal API ports**: 5000, 5001, 5002, etc. (auto-assigned)

## SSL Certificate

The project includes a self-signed SSL certificate for development purposes. The certificate is automatically generated during container build and is valid for `localhost`.

**Note**: Use `-k` flag with curl to ignore SSL certificate warnings in development.

## Example API Responses

### v1 API
```json
{
  "message": "Hello World from API v1!"
}
```

### v2 API
```json
{
  "message": "Hello World from API v2!"
}
```

### Health Check
```json
{
  "status": "healthy",
  "version": "v1"
}
```

## Development

### Local Development
For local development without Docker:

1. **Install dependencies:**
   ```bash
   pip install -r v1-api/requirements.txt
   pip install -r v2-api/requirements.txt
   ```

2. **Start APIs manually:**
   ```bash
   python v1-api/app.py -p 5000
   python v2-api/app.py -p 5001
   ```

3. **Configure NGINX locally** (see `entrypoint.sh` for configuration)

### Customizing NGINX Configuration

The NGINX configuration is generated dynamically in `entrypoint.sh`. To modify the proxy behavior, edit the location blocks in the script.

## Troubleshooting

1. **SSL certificate warnings**: Normal for self-signed certificates, use `-k` with curl

### Debugging

1. **View container logs:**
   ```bash
   docker-compose logs app-server
   ```

2. **Access container shell:**
   ```bash
   docker-compose exec app-server bash
   ```

3. **Check NGINX configuration:**
   ```bash
   docker-compose exec app-server nginx -t
   ```

## License

This project is provided as-is for demonstration purposes. 