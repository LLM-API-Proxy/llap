# LLAP — The Tactical LLM API Proxy for Secure Orchestration

[![Version](https://img.shields.io/badge/version-0.0.140-blue)](https://github.com/LLM-API-Proxy/llap/releases/tag/v0.0.140)
[![License](https://img.shields.io/badge/license-Apache--2.0-green)](LICENSE)
[![Website](https://img.shields.io/badge/website-llm--api--proxy.com-informational)](https://llm-api-proxy.com)

**LLAP** is a multi-tenant LLM API proxy that centralises credential management, enforces RBAC, and provides observability across all LLM traffic — without touching your application code.

> Release **v0.0.140** · 2026-08-14T07:25:57Z · `61ba9d9e1d0715d46eab7fce497eac88c2cf56a6`

---

## Quick Start — Installer

The installer is executed only after its exact bytes are bound to the signed
checksum and the pinned release key. This path requires `curl`, `gpg`, and either
`sha256sum` or `shasum`:

```bash
(
set -euo pipefail
install_dir="$(mktemp -d)"
verified_dir=""
cleanup_install() {
  local status=$?
  trap - EXIT
  exec 3<&- 4<&- 5<&- 6<&- 7<&- 8<&- 9<&- 10<&- 11<&- 12<&-
  rm -rf "$install_dir"
  [[ -z "$verified_dir" ]] || rm -rf "$verified_dir"
  return "$status"
}
trap cleanup_install EXIT
base_url="https://llm-api-proxy.com"
# GitHub fallback for this release:
# base_url="https://github.com/LLM-API-Proxy/llap/releases/download/v0.0.140"

command -v gpg >/dev/null 2>&1 || {
  printf '%s\n' 'Install GnuPG first (macOS: brew install gnupg; Linux: use your package manager).' >&2
  exit 1
}
if ! command -v sha256sum >/dev/null 2>&1 \
  && ! command -v shasum >/dev/null 2>&1; then
  printf '%s\n' 'sha256sum or shasum is required.' >&2
  exit 1
fi
command -v cp >/dev/null 2>&1 || { printf '%s\n' 'cp is required.' >&2; exit 1; }
command -v cmp >/dev/null 2>&1 || { printf '%s\n' 'cmp is required.' >&2; exit 1; }
[[ -r /dev/fd/0 ]] || { printf '%s\n' '/dev/fd is required.' >&2; exit 1; }
hash_file() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum -- "$1" | awk '{ print $1 }'
  else
    shasum -a 256 -- "$1" | awk '{ print $1 }'
  fi
}
assert_verified_bundle_unchanged() {
  [[ "${verified_dir}/install.sh" -ef /dev/fd/7 \
    && "${verified_dir}/install.sh" -ef /dev/fd/8 \
    && "${verified_dir}/install.sh" -ef /dev/fd/9 ]] || {
    printf '%s\n' 'Captured installer identity changed during verification.' >&2
    exit 1
  }
  [[ "$(hash_file "${verified_dir}/install.sh")" == "$captured_installer_hash" \
    && "$(hash_file "${verified_dir}/SHA256SUMS")" == "$captured_checksums_hash" \
    && "$(hash_file "${verified_dir}/SHA256SUMS.sig")" == "$captured_signature_hash" \
    && "$(hash_file "${verified_dir}/release-signing.pub.asc")" == "$captured_key_hash" ]] || {
    printf '%s\n' 'Captured installer bundle changed during verification.' >&2
    exit 1
  }
  for artifact in install.sh SHA256SUMS SHA256SUMS.sig release-signing.pub.asc; do
    cmp -s "${install_dir}/${artifact}" "${verified_dir}/${artifact}" || {
      printf '%s\n' "${artifact} changed during verification." >&2
      exit 1
    }
  done
}

for artifact in install.sh SHA256SUMS SHA256SUMS.sig release-signing.pub.asc; do
  curl --disable -fsSL "${base_url}/${artifact}" -o "${install_dir}/${artifact}"
done

verified_dir="$(mktemp -d)"
exec 3< "${install_dir}/install.sh"
exec 4< "${install_dir}/SHA256SUMS"
exec 5< "${install_dir}/SHA256SUMS.sig"
exec 6< "${install_dir}/release-signing.pub.asc"
cp /dev/fd/3 "${verified_dir}/install.sh"
cp /dev/fd/4 "${verified_dir}/SHA256SUMS"
cp /dev/fd/5 "${verified_dir}/SHA256SUMS.sig"
cp /dev/fd/6 "${verified_dir}/release-signing.pub.asc"
exec 3<&- 4<&- 5<&- 6<&-
captured_installer_hash="$(hash_file "${verified_dir}/install.sh")"
captured_checksums_hash="$(hash_file "${verified_dir}/SHA256SUMS")"
captured_signature_hash="$(hash_file "${verified_dir}/SHA256SUMS.sig")"
captured_key_hash="$(hash_file "${verified_dir}/release-signing.pub.asc")"
exec 7< "${verified_dir}/install.sh"
exec 8< "${verified_dir}/install.sh"
exec 9< "${verified_dir}/install.sh"
exec 10< "${verified_dir}/SHA256SUMS"
exec 11< "${verified_dir}/SHA256SUMS"
exec 12< "${verified_dir}/SHA256SUMS.sig"

release_fingerprint="4F2BBCD92F7AEC826BF4C156D6443D2B4B6AB71F"
actual_fingerprint="$(
  gpg --batch --no-autostart --show-keys --with-colons \
    "${verified_dir}/release-signing.pub.asc" 2>/dev/null \
    | awk -F: '$1 == "fpr" { print toupper($10); exit }'
)"
[[ "$actual_fingerprint" == "$release_fingerprint" ]]

gpg_home="${verified_dir}/gnupg"
mkdir -m 0700 "$gpg_home"
printf 'no-autostart\n' > "${gpg_home}/common.conf"
gpg --batch --no-autostart --homedir "$gpg_home" \
  --import "${verified_dir}/release-signing.pub.asc" >/dev/null
signature_status="$(
  gpg --batch --no-autostart --homedir "$gpg_home" --status-fd 1 \
    --verify /dev/fd/12 /dev/fd/10 \
    2>/dev/null
)"
valid_fingerprint="$(awk '$1 == "[GNUPG:]" && $2 == "VALIDSIG" { print toupper($3); exit }' <<< "$signature_status")"
primary_fingerprint="$(awk '$1 == "[GNUPG:]" && $2 == "VALIDSIG" { print toupper($NF); exit }' <<< "$signature_status")"
[[ "$valid_fingerprint" == "$release_fingerprint" || "$primary_fingerprint" == "$release_fingerprint" ]]

checksum_record="$(awk 'NF == 2 && $2 == "install.sh" { count++; hash = $1 } END { print count + 0, hash }' /dev/fd/11)"
entry_count="${checksum_record%% *}"
expected_hash="${checksum_record#* }"
[[ "$entry_count" == "1" && "$expected_hash" =~ ^[[:xdigit:]]{64}$ ]]
actual_hash="$(hash_file /dev/fd/7)"
[[ "$(printf '%s' "$actual_hash" | tr 'A-F' 'a-f')" == \
  "$(printf '%s' "$expected_hash" | tr 'A-F' 'a-f')" ]]
assert_verified_bundle_unchanged

if [[ $EUID -ne 0 ]]; then
  command -v sudo >/dev/null 2>&1 || {
    printf '%s\n' 'sudo is required for a non-root installation.' >&2
    exit 1
  }
  printf '%s\n' 'Installer verified. Authenticating for privileged installation...'
  sudo -v || {
    printf '%s\n' 'Privilege authentication failed; installer was not executed.' >&2
    exit 1
  }
  # Authentication can prompt and yield control. Recheck every mutable path and
  # the captured installer inode before executing the already-verified FDs.
  assert_verified_bundle_unchanged
fi
exec 7<&- 10<&- 11<&- 12<&-
rm -rf "$verified_dir"
verified_dir=""
installer_status=0
SCRIPT_PATH=/dev/fd/9 bash /dev/fd/8 || installer_status=$?
exec 8<&- 9<&-
exit "$installer_status"
)
```

The installer detects your platform, pulls the correct container images, writes
a `docker-compose.yml` and `config.toml`, and starts the stack. Piped execution
is rejected because already-executing stdin bytes cannot be authenticated before
execution.

---

## Quick Start — Docker Compose

Manual compose setup:

```bash
curl --disable -fsSL https://raw.githubusercontent.com/LLM-API-Proxy/llap/main/docker-compose.yml -o docker-compose.yml
curl --disable -fsSL https://raw.githubusercontent.com/LLM-API-Proxy/llap/main/config.example.toml -o config.toml
docker compose up -d
```

Edit `config.toml` before starting for production deployments. See [Configuration](#configuration) below.

---

## Quick Start — CLI Binary

Pre-built binaries are available for all supported platforms:

| Platform | Download |
|---|---|
| Linux x86-64 | [llap-linux-amd64](https://github.com/LLM-API-Proxy/llap/releases/download/v0.0.140/llap-linux-amd64) |
| Linux ARM64 | [llap-linux-arm64](https://github.com/LLM-API-Proxy/llap/releases/download/v0.0.140/llap-linux-arm64) |
| macOS x86-64 | [llap-darwin-amd64](https://github.com/LLM-API-Proxy/llap/releases/download/v0.0.140/llap-darwin-amd64) |
| macOS ARM64 (Apple Silicon) | [llap-darwin-arm64](https://github.com/LLM-API-Proxy/llap/releases/download/v0.0.140/llap-darwin-arm64) |

Verify the checksum after downloading:

```bash
# Download the checksum file
curl --disable -fsSL https://github.com/LLM-API-Proxy/llap/releases/download/v0.0.140/llap-SHA256SUMS -o llap-SHA256SUMS

# Verify (Linux / macOS with sha256sum)
sha256sum --check --ignore-missing llap-SHA256SUMS

# Verify (macOS with shasum)
shasum -a 256 --check --ignore-missing llap-SHA256SUMS
```

Make the binary executable and move it onto your `PATH`:

```bash
chmod +x llap-linux-amd64
sudo mv llap-linux-amd64 /usr/local/bin/llap
```

---

## Container Images

All images are published to the GitHub Container Registry:

| Image | Tag |
|---|---|
| `ghcr.io/llm-api-proxy/server:0.0.140` | Proxy server |
| `ghcr.io/llm-api-proxy/cli:0.0.140` | Management CLI |
| `ghcr.io/llm-api-proxy/backup:0.0.140` | Restic backup agent |

### Tag Conventions

| Tag | Meaning |
|---|---|
| `latest` | Most recent stable release |
| `0.0.140` | Exact version (e.g. `1.2.3`) |
| `X.Y` | Latest patch for this minor (e.g. `1.2`) |
| `X` | Latest minor for this major (e.g. `1`) |

Pull a specific version to avoid unexpected upgrades:

```bash
docker pull ghcr.io/llm-api-proxy/server:0.0.140
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

## Cache-Effectiveness Observability

LLAP tracks prompt-cache efficiency for every key and model combination. Three
circuit breakers detect when caching degrades — at the session level (Breaker A),
when clients create sessions too rapidly (Breaker B), or fleet-wide across all
keys for a model (Breaker C). Operators can inspect fleet state, acknowledge
incidents, and tune thresholds without restarting the proxy:

```bash
# Fleet summary
llap cache-health status

# Investigate one key/model pair
llap cache-health explain <key_id> <model>

# Acknowledge a known-good regression
llap cache-health ack <key_id> <model> --reason "prompt warm-up"

# Force-reset after recovery
llap cache-health force-reset <key_id> <model>

# Tune thresholds per model or per key
llap cache-health config set claude-opus-4-5 --fleet-open-hit-rate 0.15

# All commands support --json for pipeline integration
llap cache-health status --json | jq '.fleet_drift_breakers[] | select(.state == "open")'
```

Full operator workflow and threshold tuning guide: [`docs/reference/cache-effectiveness-runbook.md`](https://github.com/LLM-API-Proxy/core/blob/main/docs/reference/cache-effectiveness-runbook.md).

---

## Supported Providers

| Provider | Auth | Models | Wire Format |
|---|---|---|---|
| Anthropic | OAuth, API key | Claude model family | Anthropic Messages API |
| OpenAI | API key | GPT model family | OpenAI Chat Completions |
| OpenRouter | API key | 200+ models via unified gateway | OpenAI Chat Completions |
| Ollama | None / API key | Local LLMs | OpenAI Chat Completions |

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
