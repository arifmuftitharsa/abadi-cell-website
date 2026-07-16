# Dockerfile — Abadi Cell & Elektrik (service PUBLIK: reverse proxy)
#
# Memakai Caddy (bukan Nginx) karena Nginx base Alpine punya known issue
# gagal me-resolve hostname *.railway.internal di private networking
# Railway. Caddy re-resolve DNS di setiap request secara native.
#
# Alur traffic:
#   Internet --HTTPS(edge Railway)--> Caddy (proxy) --HTTP--> app.railway.internal:8080

FROM caddy:2-alpine

COPY Caddyfile /etc/caddy/Caddyfile

# Default kalau PORT tidak di-inject (mis. dijalankan lokal/CI)
ENV PORT=8080
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:$PORT/health || exit 1
