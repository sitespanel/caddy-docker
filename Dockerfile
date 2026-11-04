FROM caddy:2.11.7-builder AS builder

RUN apk add --no-cache build-base brotli-dev

RUN CGO_ENABLED=1 \
    XCADDY_GO_BUILD_FLAGS="-ldflags='-w -s' -tags=nobadger,nomysql,nopgx" \
    xcaddy build \
    --with github.com/corazawaf/coraza-caddy/v2@v2.6.2 \
    --with pkg.jsn.cam/caddy-defender@v0.10.1 \
    --with github.com/mholt/caddy-ratelimit@v0.1.0 \
    --with github.com/dunglas/caddy-cbrotli@v1.0.1 \
    --with github.com/caddy-dns/vultr@v0.0.0-20250723121531-55bf3e9768be \
    --with github.com/caddy-dns/azure@v0.6.0 \
    --with github.com/caddy-dns/googleclouddns@v1.1.0 \
    --with github.com/caddy-dns/digitalocean@v0.0.0-20250606074528-04bde2867106 \
    --with github.com/caddy-dns/cloudflare@v0.2.4 \
    --with github.com/caddy-dns/route53@v1.6.2 \
    --with github.com/darkweak/souin/plugins/caddy@v1.7.9 \
    --with github.com/darkweak/storages/go-redis/caddy@v0.0.20 \
    --with github.com/darkweak/storages/otter/caddy@v0.0.20 \
    --with github.com/darkweak/storages/simplefs/caddy@v0.0.20

FROM caddy:2.11.7

LABEL org.opencontainers.image.title="caddy" \
      org.opencontainers.image.description="Caddy with Coraza WAF, rate limiting, IP blocking, Brotli, Souin cache and 6 DNS providers" \
      org.opencontainers.image.source="https://github.com/sitespanel/caddy-docker" \
      org.opencontainers.image.licenses="MIT"

RUN apk add --no-cache acl brotli-libs gosu
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
