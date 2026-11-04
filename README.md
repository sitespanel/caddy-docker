# Production-Ready Caddy Docker Image with Essential Plugins

> **SitesPanel image source.** SitesPanel builds this image with Google Cloud Build and serves it from Artifact Registry (`europe-docker.pkg.dev/PROJECT/sitespanel-images/caddy`); see [CLOUDBUILD.md](CLOUDBUILD.md). Replace `PROJECT` with SitesPanel's Google Cloud project.


This repository contains the build instructions for a customized [Caddy](https://caddyserver.com/) Docker image — a high-performance **reverse proxy** and **web server** with **automatic HTTPS** via Let's Encrypt. It includes the standard Caddy features plus a selection of commonly used plugins for DNS validation, caching, web application firewalling, rate limiting, and more.

The image is built by Google Cloud Build and published to SitesPanel's Artifact Registry (see [CLOUDBUILD.md](CLOUDBUILD.md)).

## ✨ Why This Image?

| Feature | Official `caddy` | This Image |
|---------|-----------------|------------|
| **Brotli compression** | ❌ | ✅ |
| **HTTP caching** | ❌ | ✅ Souin (Redis, Otter, SimpleFS) |
| **Web application firewall** | ❌ | ✅ OWASP Coraza + Core Rule Set (compiled in) |
| **Rate limiting** | ❌ | ✅ Sliding-window, per-IP/header/host |
| **IP range blocking** | ❌ | ✅ Defender (AI crawlers, cloud provider ranges) |
| **DNS challenge** | Requires custom build | ✅ 6 providers built-in |
| **Production ready** | Needs custom build | ✅ Ready to deploy |

## Quick Start

To get started, you need a `Caddyfile` for your configuration.

```sh
docker run -d --name caddy \
    -p 80:80 \
    -p 443:443 \
    -p 443:443/udp \
    -v /path/to/your/Caddyfile:/etc/caddy/Caddyfile:ro \
    -v caddy_data:/data \
    -v caddy_config:/config \
    europe-docker.pkg.dev/PROJECT/sitespanel-images/caddy:latest
```

### Persistent Data

This command uses Docker named volumes to persist important data:

*   **`caddy_data`**: Stores TLS certificates and other persistent data. Caddy will create this automatically.
*   **`caddy_config`**: Stores any JSON config changes made via the admin API.

## Configuration

Your primary method of configuration is by providing a `Caddyfile`. Mount your local `Caddyfile` to `/etc/caddy/Caddyfile` inside the container as shown in the command above.

For more advanced use cases, you can use the [Caddy Admin API](https://caddyserver.com/docs/api).

## Versioning

This image is tagged with two schemes:

*   `europe-docker.pkg.dev/PROJECT/sitespanel-images/caddy:latest`: Always points to the most recently built image from the `master` branch.
*   `europe-docker.pkg.dev/PROJECT/sitespanel-images/caddy:<version>`: (e.g., `europe-docker.pkg.dev/PROJECT/sitespanel-images/caddy:2.11.7`) A specific version tag corresponding to the version of Caddy used in the build.

It is recommended to use a specific version tag in production environments for stability.

## Included Plugins

This image extends the official Caddy image with the following plugins:

*   **Web Application Firewall (Coraza)**: `github.com/corazawaf/coraza-caddy/v2` (v2.6.2)
    *   OWASP Coraza is ModSecurity/SecLang compatible. The OWASP Core Rule Set is
        compiled into the binary — use `load_owasp_crs` and the `@`-prefixed include
        paths, with no rule files to download or mount.
*   **IP Range Blocking (Defender)**: `pkg.jsn.cam/caddy-defender` (v0.10.1)
    *   Blocks, drops, or garbles requests from embedded IP range lists — AI crawlers
        (OpenAI, Anthropic, Perplexity), cloud providers (AWS, GCP, Azure), VPN exits —
        plus your own CIDRs. Note the module path is the vanity import
        `pkg.jsn.cam/caddy-defender`, not the GitHub path.
*   **Rate Limiting**: `github.com/mholt/caddy-ratelimit` (v0.1.0)
    *   Sliding-window rate limiting with multiple zones, keyed on any request
        placeholder (client IP, host, header). Sets `Retry-After` automatically.
*   **Brotli Compression**: `github.com/dunglas/caddy-cbrotli` (v1.0.1)
*   **HTTP Caching (Souin)**: `github.com/darkweak/souin/plugins/caddy` (v1.7.9)
    *   Storage backends:
        *   `github.com/darkweak/storages/go-redis/caddy` (Redis, v0.0.20)
        *   `github.com/darkweak/storages/otter/caddy` (in-memory, v0.0.20)
        *   `github.com/darkweak/storages/simplefs/caddy` (file-based, v0.0.20)
*   **DNS Providers for ACME TLS**:
    *   `github.com/caddy-dns/vultr` (v0.0.0-20250723121531)
    *   `github.com/caddy-dns/azure` (v0.6.0)
    *   `github.com/caddy-dns/googleclouddns` (v1.1.0)
    *   `github.com/caddy-dns/digitalocean` (v0.0.0-20250606074528)
    *   `github.com/caddy-dns/cloudflare` (v0.2.4)
    *   `github.com/caddy-dns/route53` (v1.6.2)

Every plugin is pinned to an explicit version in the `Dockerfile` (the versions above are those built on 2026-10-10), so a rebuild never picks up a newer plugin by accident. `caddy list-modules --versions` prints them from inside the image.

## Tools in the image

Besides the `caddy` binary: `gosu` (start as root, drop to another user) and `acl` (`setfacl`, `getfacl`), on top of the official Alpine-based image. The binary keeps the file capability `cap_net_bind_service=ep`, so a container that drops all capabilities must add `NET_BIND_SERVICE` back.

## ❓ FAQ

**Q: How do I add more plugins?**
A: Fork this repository and add your desired plugins to the `xcaddy build` command in the `Dockerfile`, then rebuild. Caddy plugins are Go modules compiled directly into the binary.

**Q: How do I use DNS challenge for wildcard certificates?**
A: All six DNS providers (Cloudflare, Route53, DigitalOcean, Vultr, Azure, Google Cloud DNS) are pre-compiled. Set the appropriate environment variables for your provider's API credentials and configure the `tls` directive in your `Caddyfile`.

**Q: How does caching work with this image?**
A: The Souin cache handler is pre-installed with three storage backends: `simplefs` (file-based, zero config), `go-redis` (distributed), and `otter` (in-memory). Configure caching in your `Caddyfile` via the `cache` directive.

**Q: How do I turn the WAF on?**
A: Add `order coraza_waf first` to your global options, then a `coraza_waf` block to
the site. `load_owasp_crs` is what makes the `@` paths resolvable — without it Caddy
fails at startup with `open @coraza.conf-recommended: no such file or directory`.

```caddy
{
    order coraza_waf first
}

example.com {
    coraza_waf {
        load_owasp_crs
        directives `
            Include @coraza.conf-recommended
            Include @crs-setup.conf.example
            Include @owasp_crs/*.conf
            SecRuleEngine DetectionOnly
        `
    }
    reverse_proxy localhost:8080
}
```

Start at `SecRuleEngine DetectionOnly`, watch the logs for false positives, write your
exclusions, and only then switch to `On`. CRS in blocking mode will otherwise break
application admin panels — WordPress's `/wp-admin` in particular.

**Q: How do I rate limit login endpoints?**
A: `rate_limit` is ordered before `basic_auth` by default, so no `order` directive is
needed. Matchers go inside the zone's `match` block:

```caddy
example.com {
    rate_limit {
        zone login {
            match {
                path /wp-login.php /xmlrpc.php
            }
            key    {http.request.remote.host}
            events 5
            window 1m
        }
    }
    reverse_proxy localhost:8080
}
```

`window` and `events` are both required. A key containing a placeholder allocates one
limiter per distinct value — here, per client IP. A static key (no placeholder) means one
limiter for the whole zone. `Retry-After` is set automatically on the 429.

**Q: How do I block AI crawlers?**
A: `defender` matches the client IP against embedded range lists, refreshed with the
module rather than fetched at runtime:

```caddy
example.com {
    defender block {
        ranges aws azurepubliccloud deepseek gcloud githubcopilot openai
    }
    reverse_proxy localhost:8080
}
```

Those six are also the default if you omit `ranges`. Custom CIDRs can be listed alongside
the predefined keys. Responders: `block` (403), `drop`, `garbage`, `tarpit`, `custom`
(needs `message`), `redirect` (needs `url`), and `ratelimit`, which hands the request to
the rate limit module above rather than rejecting it outright.

Matching is by IP range, so this catches declared crawler infrastructure — not a scraper
that spoofs a user agent from a residential address.

**Q: Can I use this image with FrankenPHP?**
A: This is a standalone Caddy image. For a pre-configured Caddy+PHP setup, use the [europe-docker.pkg.dev/PROJECT/sitespanel-images/frankenphp](https://github.com/sitespanel/frankenphp-docker) image instead, which bundles this same Caddy plugin stack with PHP.

---

---

## Related Images & Tools

<!-- BEGIN GENERATED: related (from images.yaml in the org .github repository; do not edit by hand) -->
Every image is built by Google Cloud Build and published to SitesPanel's Artifact Registry (`europe-docker.pkg.dev/PROJECT/sitespanel-images`), with SLSA provenance and an SBOM per image.

| Repository | Images | Description |
|---|---|---|
| [frankenphp-docker](https://github.com/sitespanel/frankenphp-docker) | `sitespanel-images/frankenphp` | Caddy + PHP app server in one container |
| [php-docker](https://github.com/sitespanel/php-docker) | `sitespanel-images/php` | Traditional PHP-FPM & CLI images |
| [nginx-docker](https://github.com/sitespanel/nginx-docker) | `sitespanel-images/nginx` | nginx with ModSecurity 3, Brotli, zstd & GeoIP2 |
| [apache-docker](https://github.com/sitespanel/apache-docker) | `sitespanel-images/apache` | Apache as a static server or php-fpm application server, no PHP inside |
<!-- END GENERATED: related -->

---

## Feedback and Issues

If you have suggestions or find a bug, please [open an issue](https://github.com/sitespanel/caddy-docker/issues) on the GitHub repository.

---

⭐ **If this project helps you, consider giving it a star!**
