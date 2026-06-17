# Traefik operator drop-in directory

This directory is a **generic operator extension point** for Traefik dynamic
configuration. It is bind-mounted **read-only** into the Traefik container at
`/etc/traefik/dynamic` and is loaded by Traefik's **file provider**, which runs
alongside the product `consul` and `docker` providers (issue #1340).

Drop `*.yml`, `*.yaml`, or `*.toml` files here to extend Traefik with your own
**routers, middlewares, redirects, headers, services, or TLS options** —
**without modifying the product templates**. Traefik watches this directory and
**hot-reloads** changes (`--providers.file.watch=true`); no restart is needed.

> **Empty by default.** A clean install ships this directory empty, so the file
> provider loads nothing and product behaviour is unchanged. Your drop-in files
> are **preserved on upgrade** — the installer never wipes this directory.

## What goes here vs. what does not

- **Operator / site-specific config** → here. Custom hostnames, vanity
  redirects, extra middlewares, your own routers. This is YOUR config; it is
  never overwritten by an upgrade.
- **Product routing** → NOT here. The proxy's own routers/middlewares are
  configured via Docker labels on the proxy service and TLS options via Consul
  KV. Do not duplicate those here.

> Files in this directory are dynamic (runtime) config only. They **cannot**
> change Traefik static config (entrypoints, providers, ACME resolvers) — those
> live in the compose `command:` flags.

## Worked example — custom router + middleware (redirect)

Create `docker/traefik-dynamic/my-redirect.yml` (any name ending in `.yml`):

```yaml
# Permanently (308) redirect requests for an old hostname to a new one.
# This is the kind of site-specific config that must NOT live in the product
# templates — drop it here instead.
http:
  middlewares:
    old-host-to-new:
      redirectRegex:
        regex: "^https?://old.example.com/(.*)"
        replacement: "https://new.example.com/${1}"
        permanent: true # 308 Permanent Redirect

  routers:
    old-host-redirect:
      rule: "Host(`old.example.com`)"
      entryPoints:
        - websecure
      middlewares:
        - old-host-to-new
      service: noop@internal # built-in: never reached; the middleware redirects first
      tls:
        certResolver: cloudflare # reuse the product ACME resolver (TLS deployments)
```

Save the file. Traefik picks it up within a second (watch mode). Verify it
loaded:

```bash
docker compose -f docker/docker-compose.yml logs traefik | grep -i "Configuration loaded from file"
curl -sSI https://old.example.com/ | grep -i location
```

References:

- Traefik file provider: <https://doc.traefik.io/traefik/providers/file/>
- redirectRegex middleware: <https://doc.traefik.io/traefik/middlewares/http/redirectregex/>
- See `docs/tls-setup.md` for the full operator guide.
