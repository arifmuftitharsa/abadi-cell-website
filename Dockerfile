# Dockerfile — Abadi Cell & Elektrik (service PUBLIK: nginx-proxy)
#
# Ini adalah reverse proxy sungguhan: menerima semua request dari internet,
# lalu meneruskannya ke service "app" (privat) lewat jaringan internal
# Railway. Di sinilah gzip compression, security headers, dan rate
# limiting diterapkan — sebelum request sampai ke server file statis.

FROM nginx:1.27-alpine

RUN rm /etc/nginx/conf.d/default.conf

# Copy konfigurasi reverse proxy kustom
COPY nginx/proxy.conf /etc/nginx/conf.d/default.conf

# Nginx berjalan di port 80 (public-facing)
EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
