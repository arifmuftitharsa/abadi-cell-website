# Dockerfile — Abadi Cell & Elektrik (service PUBLIK: nginx-proxy)
#
# Ini adalah reverse proxy sungguhan: menerima semua request dari internet,
# lalu meneruskannya ke service "app" (privat) lewat jaringan internal
# Railway. Di sinilah gzip compression, security headers, dan rate
# limiting diterapkan — sebelum request sampai ke server file statis.

FROM nginx:1.27-alpine

RUN rm /etc/nginx/conf.d/default.conf

# Copy konfigurasi reverse proxy sebagai TEMPLATE: image nginx resmi
# otomatis menjalankan envsubst pada file *.template saat start, mengganti
# ${PORT} dengan env var dari Railway (pola yang sama seperti setup lama).
COPY nginx/proxy.conf /etc/nginx/templates/default.conf.template

# Default kalau Railway tidak meng-inject PORT (mis. saat dijalankan lokal/CI)
ENV PORT=8080
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:$PORT/health || exit 1

CMD ["nginx", "-g", "daemon off;"]
