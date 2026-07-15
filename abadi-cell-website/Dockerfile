# Dockerfile — Abadi Cell & Elektrik website
#
# Menggunakan Nginx official image (alpine) sebagai web server.
# Website statis (HTML/CSS) di-copy langsung ke direktori serving Nginx.
# Alpine dipilih karena ukuran image kecil (~20MB), cocok untuk VPS
# dengan resource terbatas.

FROM nginx:1.27-alpine

# Hapus konfigurasi default Nginx supaya tidak konflik dengan konfigurasi kustom
RUN rm /etc/nginx/conf.d/default.conf

# Copy konfigurasi Nginx kustom (reverse-proxy-ready, gzip, security headers)
COPY nginx/default.conf /etc/nginx/conf.d/default.conf

# Copy source website statis
COPY app/ /usr/share/nginx/html/

# Nginx berjalan di port 80 di dalam container
EXPOSE 80

# Healthcheck: memastikan Nginx merespons, dipakai juga oleh monitoring
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
