# Caddy — Production-Ready Web Server with Essential Plugins

**Maintained by [morsalin1342](https://hub.docker.com/u/morsalin1342)** · [GitHub](https://github.com/morsalin1342/caddy-docker)

[![Docker Pulls](https://img.shields.io/docker/pulls/morsalin1342/caddy?style=for-the-badge&logo=docker)](https://hub.docker.com/r/morsalin1342/caddy)
[![Image Size](https://img.shields.io/docker/image-size/morsalin1342/caddy/latest?style=for-the-badge&logo=docker)](https://hub.docker.com/r/morsalin1342/caddy/tags)
[![GitHub Stars](https://img.shields.io/github/stars/morsalin1342/caddy-docker?style=for-the-badge&logo=github)](https://github.com/morsalin1342/caddy-docker)
[![License](https://img.shields.io/github/license/morsalin1342/caddy-docker?style=for-the-badge)](https://github.com/morsalin1342/caddy-docker/blob/master/LICENSE)

A custom Caddy build with the OWASP Coraza WAF, rate limiting, AI-crawler blocking, Brotli compression, HTTP caching, and 6 DNS challenge providers for automatic HTTPS.

## ✨ Why This Image?

| Feature | Official image | This image |
|---|---|---|
| **Brotli compression** | ❌ | ✅ cbrotli |
| **HTTP caching** | ❌ | ✅ Souin — Redis, Otter, SimpleFS |
| **Web application firewall** | ❌ | ✅ OWASP Coraza, Core Rule Set compiled in |
| **Rate limiting** | ❌ | ✅ Sliding-window, per IP / header / host |
| **IP range blocking** | ❌ | ✅ Defender — AI crawlers, cloud ranges |
| **DNS challenge** | Needs a custom build | ✅ 6 providers built in |

## Quick Start

```bash
docker run -d --name caddy \
    -p 80:80 -p 443:443 -p 443:443/udp \
    -v $(pwd)/Caddyfile:/etc/caddy/Caddyfile:ro \
    -v caddy_data:/data \
    morsalin1342/caddy:latest
```

## Example Caddyfile

```caddy
{
    order coraza_waf first
}

example.com {
    encode zstd gzip
    cache
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

`load_owasp_crs` is required for the `@` include paths to resolve. Start in
`DetectionOnly`, tune out false positives, then switch to `On`.

## What's Included

| Category | Plugins |
|----------|---------|
| Security | Coraza WAF (SecLang/ModSecurity compatible, OWASP CRS compiled in) |
| Rate limiting | Sliding-window, multi-zone, keyed on any request placeholder |
| Bot / IP blocking | Defender — embedded AI-crawler and cloud-provider IP ranges |
| Compression | cbrotli (Brotli) |
| Caching | Souin with Redis, Otter, and SimpleFS backends |
| DNS/ACME | Cloudflare, Route53, DigitalOcean, Vultr, Azure, Google Cloud DNS |

## Available Tags

`latest`, `2.11.7` — version-tagged for production stability.

## ❓ FAQ

**Q: How do I turn the WAF on?**
A: Add `order coraza_waf first` to the global options, then a `coraza_waf` block with `load_owasp_crs`. Without `load_owasp_crs` the `@` include paths do not resolve and Caddy fails at startup. Start at `SecRuleEngine DetectionOnly`.

**Q: How do I get a wildcard certificate?**
A: All six DNS providers are pre-compiled. Set your provider's credentials and use the `tls` directive with `dns <provider>`.

**Q: Can I use this with PHP?**
A: Use [frankenphp](https://hub.docker.com/r/morsalin1342/frankenphp) for Caddy and PHP in one container, or pair this with [php](https://hub.docker.com/r/morsalin1342/php) over FastCGI.

---

### 🔗 Related Images & Tools

<!-- BEGIN GENERATED: related (from images.yaml in the org .github repository; do not edit by hand) -->
| Image / Tool | Description |
|--------------|-------------|
| [morsalin1342/frankenphp](https://hub.docker.com/r/morsalin1342/frankenphp) | Caddy + PHP app server in one container |
| [morsalin1342/php](https://hub.docker.com/r/morsalin1342/php) | Traditional PHP-FPM & CLI images |
| [morsalin1342/nginx](https://hub.docker.com/r/morsalin1342/nginx) | nginx with ModSecurity 3, Brotli, zstd & GeoIP2 |
| [morsalin1342/apache](https://hub.docker.com/r/morsalin1342/apache) | Apache as a static server or php-fpm application server, no PHP inside |
| [easydigital/caddy](https://hub.docker.com/r/easydigital/caddy) | Same image, organization namespace |
<!-- END GENERATED: related -->

---

⭐ **If this image helps you, consider giving it a star on [GitHub](https://github.com/morsalin1342/caddy-docker)!**
