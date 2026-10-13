# Caddy — Enterprise Web Server

**Published by [easydigital](https://hub.docker.com/u/easydigital)** · [GitHub](https://github.com/morsalin1342/caddy-docker)

[![Docker Pulls](https://img.shields.io/docker/pulls/easydigital/caddy?style=for-the-badge&logo=docker)](https://hub.docker.com/r/easydigital/caddy)
[![Image Size](https://img.shields.io/docker/image-size/easydigital/caddy/latest?style=for-the-badge&logo=docker)](https://hub.docker.com/r/easydigital/caddy/tags)
[![GitHub Stars](https://img.shields.io/github/stars/morsalin1342/caddy-docker?style=for-the-badge&logo=github)](https://github.com/morsalin1342/caddy-docker)
[![License](https://img.shields.io/github/license/morsalin1342/caddy-docker?style=for-the-badge)](https://github.com/morsalin1342/caddy-docker/blob/master/LICENSE)

Enterprise Caddy build with production-ready plugins. Same image as `morsalin1342/caddy` — published here for organizational deployments.

## ✨ Why This Image?

| Feature | Official image | This image |
|---|---|---|
| **Brotli compression** | ❌ | ✅ cbrotli |
| **HTTP caching** | ❌ | ✅ Souin — Redis, Otter, SimpleFS |
| **Web application firewall** | ❌ | ✅ OWASP Coraza, Core Rule Set compiled in |
| **Rate limiting** | ❌ | ✅ Sliding-window, per IP / header / host |
| **IP range blocking** | ❌ | ✅ Defender — AI crawlers, cloud ranges |
| **DNS challenge** | Needs a custom build | ✅ 6 providers built in |

## Production Deployment

```yaml
# production.yml
services:
  caddy:
    image: easydigital/caddy:2.11.7
    restart: always
    ports:
      - "80:80"
      - "443:443"
      - "443:443/udp"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile:ro
      - caddy_data:/data
      - caddy_config:/config
    environment:
      CLOUDFLARE_API_TOKEN: ${CF_TOKEN}

volumes:
  caddy_data:
  caddy_config:
```

## DNS Challenge Example

```caddy
*.example.com {
    tls {
        dns cloudflare {env.CLOUDFLARE_API_TOKEN}
    }
    reverse_proxy localhost:8080
}
```

## Available Tags

`latest`, `2.11.7` — pin to a specific version for production.

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
| [easydigital/frankenphp](https://hub.docker.com/r/easydigital/frankenphp) | Caddy + PHP app server in one container |
| [easydigital/php](https://hub.docker.com/r/easydigital/php) | Traditional PHP-FPM & CLI images |
| [easydigital/nginx](https://hub.docker.com/r/easydigital/nginx) | nginx with ModSecurity 3, Brotli, zstd & GeoIP2 |
| [easydigital/apache](https://hub.docker.com/r/easydigital/apache) | Apache as a static server or php-fpm application server, no PHP inside |
| [morsalin1342/caddy](https://hub.docker.com/r/morsalin1342/caddy) | Same image, personal namespace |
<!-- END GENERATED: related -->

---

⭐ **If this image helps you, consider giving it a star on [GitHub](https://github.com/morsalin1342/caddy-docker)!**
