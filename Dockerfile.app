# Dockerfile.app — Abadi Cell & Elektrik (service PRIVAT)
#
# Service ini HANYA menyajikan file statis, TIDAK terekspos ke publik.
# Diakses hanya oleh service "nginx-proxy" lewat jaringan privat Railway
# (app.railway.internal). Tetap pakai Nginx sebagai web server karena ringan
# dan konsisten dengan skill yang sudah dipelajari di kelas.

FROM nginx:1.27-alpine

# Hapus konfigurasi default supaya tidak konflik
RUN rm /etc/nginx/conf.d/default.conf

# Config sederhana: cuma serve file statis, TANPA gzip/security header
# (itu semua ditangani oleh nginx-proxy di depan, bukan di sini)
COPY nginx/app.conf /etc/nginx/conf.d/default.conf

# Copy source website statis
COPY app/ /usr/share/nginx/html/

# PENTING: bind ke IPv6 (::) supaya bisa diakses lewat private network Railway
# (private network Railway pakai IPv6, config ini diatur di nginx/app.conf)

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:8080/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
