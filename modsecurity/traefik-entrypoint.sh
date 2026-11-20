#!/bin/sh
# Preserve the selected Compose command (including TLS options).
# Keep the original upstream module: its maxBodySize bounds buffered copies.
exec /entrypoint.sh "$@" \
    --experimental.plugins.modsecurity.moduleName=github.com/acouvreur/traefik-modsecurity-plugin \
    --experimental.plugins.modsecurity.version=v1.3.0
