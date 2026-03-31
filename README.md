# LLAP — The Tactical LLM API Proxy for Secure Orchestration

[![Version](https://img.shields.io/badge/version-0.0.7-blue)](https://github.com/LLM-API-Proxy/llap/releases/tag/v0.0.7)
[![License](https://img.shields.io/badge/license-Apache--2.0-green)](LICENSE)
[![Website](https://img.shields.io/badge/website-llm--api--proxy.com-informational)](https://llm-api-proxy.com)

**LLAP** is a multi-tenant LLM API proxy that centralises credential management, enforces RBAC, and provides observability across all LLM traffic — without touching your application code.

> Release **v0.0.7** · 2026-03-31T20:42:56Z · `0108922`

---

## Quick Start — Installer

The fastest path to a running LLAP instance:

```bash
curl -fsSL https://llm-api-proxy.com/install.sh | bash
```

GitHub-backed fallback (no CDN dependency):

```bash
curl -fsSL https://github.com/LLM-API-Proxy/llap/releases/download/v0.0.7/install.sh | bash
```

The installer detects your platform, pulls the correct container images, writes a `docker-compose.yml` and `config.toml`, and starts the stack.

---

## Quick Start — Docker Compose

Manual compose setup:

```bash
curl -fsSL https://raw.githubusercontent.com/LLM-API-Proxy/llap/main/docker-compose.yml -o docker-compose.yml
curl -fsSL https://raw.githubusercontent.com/LLM-API-Proxy/llap/main/config.example.toml -o config.toml
docker compose up -d
```

Edit `config.toml` before starting for production deployments. See [Configuration](#configuration) below.

---

## Quick Start — CLI Binary

Pre-built binaries are available for all supported platforms:

| Platform | Download |
|---|---|
| Linux x86-64 | [llap-linux-x86_64](https://github.com/LLM-API-Proxy/llap/releases/download/v0.0.7/llap-linux-x86_64) |
| Linux ARM64 | [llap-linux-aarch64](https://github.com/LLM-API-Proxy/llap/releases/download/v0.0.7/llap-linux-aarch64) |
| macOS x86-64 | [llap-darwin-x86_64](https://github.com/LLM-API-Proxy/llap/releases/download/v0.0.7/llap-darwin-x86_64) |
| macOS ARM64 (Apple Silicon) | [llap-darwin-aarch64](https://github.com/LLM-API-Proxy/llap/releases/download/v0.0.7/llap-darwin-aarch64) |

Verify the checksum after downloading:

```bash
# Download the checksum file
curl -fsSL https://github.com/LLM-API-Proxy/llap/releases/download/v0.0.7/llap-SHA256SUMS -o llap-SHA256SUMS

# Verify (Linux / macOS with sha256sum)
sha256sum --check --ignore-missing llap-SHA256SUMS

# Verify (macOS with shasum)
shasum -a 256 --check --ignore-missing llap-SHA256SUMS
```

Make the binary executable and move it onto your `PATH`:

```bash
chmod +x llap-linux-x86_64
sudo mv llap-linux-x86_64 /usr/local/bin/llap
```

---

## Container Images

All images are published to the GitHub Container Registry:

| Image | Tag |
|---|---|
| `ghcr.io/llm-api-proxy/server:0.0.7` | Proxy server |
| `ghcr.io/llm-api-proxy/cli:0.0.7` | Management CLI |
| `ghcr.io/llm-api-proxy/backup:0.0.7` | Restic backup agent |

### Tag Conventions

| Tag | Meaning |
|---|---|
| `latest` | Most recent stable release |
| `0.0.7` | Exact version (e.g. `1.2.3`) |
| `X.Y` | Latest patch for this minor (e.g. `1.2`) |
| `X` | Latest minor for this major (e.g. `1`) |

Pull a specific version to avoid unexpected upgrades:

```bash
docker pull ghcr.io/llm-api-proxy/server:0.0.7
```

---

## Compose Overlays

The base `docker-compose.yml` can be extended with purpose-built overlay files:

| File | Purpose |
|---|---|
| `docker-compose.yml` | Base stack — server, TimescaleDB, Consul, Traefik |
| `docker-compose.prod.yml` | Production-grade configuration with bridge networking |
| `docker-compose.hardened.yml` | Resource limits and `security_opt` hardening |
| `docker-compose.waf.yml` | ModSecurity WAF in front of the proxy |
| `docker-compose.monitoring.yml` | Prometheus and Grafana observability stack |
| `docker-compose.backup.yml` | Restic backup agent for database snapshots |
| `docker-compose.no-mdns.yml` | Docker Desktop compatibility (no host networking) |
| `docker-compose.tls.yml` | Traefik TLS termination with ACME (Let's Encrypt) |

Combine overlays with `-f` flags:

```bash
# Production with monitoring, hardening, and TLS
docker compose \
  -f docker-compose.yml \
  -f docker-compose.prod.yml \
  -f docker-compose.hardened.yml \
  -f docker-compose.monitoring.yml \
  -f docker-compose.tls.yml \
  up -d
```

---

## Configuration

Copy and edit the example configuration before first run:

```bash
cp config.example.toml config.toml
$EDITOR config.toml
```

[`config.example.toml`](config.example.toml) documents all available settings. Key sections:

- **`[server]`** — listen address, port, TLS settings
- **`[database]`** — TimescaleDB connection string and pool settings
- **`[kek]`** — Key Encryption Key source (env var, HashiCorp Vault, or cloud KMS)
- **`[providers]`** — LLM provider credentials and account stacking policy
- **`[auth]`** — JWT secret, token TTLs, invite settings
- **`[observability]`** — tracing, metrics export, log level

---

## Links

| Resource | URL |
|---|---|
| Website | https://llm-api-proxy.com |
| Documentation | https://llm-api-proxy.com/docs |
| License | [Apache-2.0](LICENSE) |

---

## License

Copyright (c) 2024–2026 LLM-API-Proxy Contributors.
Licensed under the [Apache License, Version 2.0](LICENSE).

Built from [LLM-API-Proxy/core](https://github.com/LLM-API-Proxy/core).
