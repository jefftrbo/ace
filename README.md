# ACE Local Development Environment

IBM App Connect Enterprise (ACE) running locally in Podman for UPMC integration experimentation.

## Container Details

| Item | Value |
|---|---|
| Image | `docker.io/ibmcom/ace:latest` |
| ACE Version | 11.0.0.9 |
| Container Name | `ace-server` |
| Platform | `linux/amd64` (emulated on Apple Silicon via libkrun) |

## Ports

| Port | Purpose |
|---|---|
| `7600` | ACE Admin / Web Console (REST Admin HTTP) |
| `7800` | HTTP listener — deployed flows receive requests here |
| `7843` | HTTPS listener |

## Start / Stop

```bash
# Start the container
podman start ace-server

# Stop the container
podman stop ace-server

# View logs
podman logs ace-server

# Remove and recreate from scratch
podman rm -f ace-server
podman run --name ace-server \
  --platform linux/amd64 \
  -p 7600:7600 \
  -p 7800:7800 \
  -p 7843:7843 \
  -e LICENSE=accept \
  -d \
  docker.io/ibmcom/ace:latest
```

## Useful Endpoints

- **Web Console:** http://localhost:7600
- **Flow HTTP endpoint:** http://localhost:7800

## Working with Bob

With this environment running, Bob can help you:
- Write and deploy ESQL / Java transformation logic
- Build and test REST API flows
- Deploy BAR files to this local server
- Simulate UPMC integration scenarios with real payloads
