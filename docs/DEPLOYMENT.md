# Laporan Deployment: Abadi Cell & Elektrik

**Mata Kuliah**: Jaringan Komputer — CS4 2025
**Nama**: Arif Mufti Tharsa
**NIM**: _(isi)_
**Universitas**: Universitas Pertamina
**Tanggal Pengumpulan**: _(isi)_
**URL Website**: _(isi setelah domain aktif)_
**Repository GitHub**: _(isi link repo)_

---

## 1. Identitas & Deskripsi Website

Website ini dibuat untuk **Abadi Cell & Elektrik**, sebuah toko elektronik
dan pulsa di Sukabumi milik keluarga penulis. Website berfungsi sebagai
**profil digital toko**, menampilkan layanan yang tersedia (pulsa & isi
saldo, aksesoris HP, elektronik rumah tangga, jasa servis), informasi
lokasi, dan kontak untuk pelanggan.

Di luar konteks tugas ini, website menjadi langkah awal dari rencana
digitalisasi toko yang lebih besar (fase berikutnya: sistem pencatatan
digital dan analitik penjualan).

## 2. Infrastruktur yang Digunakan

_(Isi sesuai provider VPS final yang didapat — Oracle Cloud / GitHub
Student Pack+DigitalOcean / lainnya)_

| Komponen | Detail |
|---|---|
| Provider VPS | _(isi)_ |
| Spesifikasi VM | _(isi: CPU, RAM, storage)_ |
| Sistem Operasi | Ubuntu _(versi)_ |
| Domain/Subdomain | _(isi, misal abadicell.duckdns.org)_ |
| Web Server | Nginx (reverse proxy) + Nginx (container aplikasi) |
| Containerization | Docker & Docker Compose |
| Sertifikat SSL | Let's Encrypt (Certbot) |
| CI/CD | GitHub Actions |
| Monitoring | Uptime Kuma |

## 3. Tahapan Deployment

### 3.1 Provisioning VPS
_(Screenshot proses pembuatan instance VPS, isi step-by-step yang
dilakukan)_

### 3.2 Konfigurasi Server Awal
_(Update sistem, setup user non-root, firewall dasar/UFW, install Docker)_

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install docker.io docker-compose-plugin -y
sudo usermod -aG docker $USER
```

### 3.3 Clone Repository & Build Container
```bash
git clone <url-repo-github>
cd abadi-cell-website
docker compose up -d --build web
```
_(Screenshot output build & container running — `docker ps`)_

### 3.4 Setup Domain
_(Screenshot pengaturan DNS di penyedia domain/DuckDNS, arahkan ke IP VPS)_

### 3.5 Konfigurasi Nginx Reverse Proxy
_(Jelaskan isi `nginx/reverse-proxy.conf`, kenapa proxy_pass ke
127.0.0.1:8081, penjelasan pemisahan tanggung jawab)_

### 3.6 Aktivasi HTTPS dengan Certbot
```bash
sudo apt install certbot python3-certbot-nginx -y
sudo certbot --nginx -d <domain>
```
_(Screenshot output sertifikat berhasil diterbitkan)_

### 3.7 Setup CI/CD dengan GitHub Actions
_(Jelaskan isi `.github/workflows/deploy.yml`, screenshot Actions run
berhasil, screenshot Secrets yang dikonfigurasi — TANPA menampilkan
isi private key)_

### 3.8 Setup Monitoring
_(Screenshot dashboard Uptime Kuma menampilkan status "up" untuk
website)_

## 4. Bukti Running

_(Screenshot website diakses via HTTPS dari browser, tunjukkan ikon
gembok/secure di address bar, dan URL final)_

## 5. Hambatan dan Solusi

| Hambatan | Solusi |
|---|---|
| _(isi hambatan nyata yang dialami)_ | _(isi solusinya)_ |

## 6. Refleksi

_(Tulis pemahaman pribadi: apa yang dipelajari soal HTTP/HTTPS,
DNS, containerization, reverse proxy, dan bagaimana ini terhubung
ke materi Application Layer yang sudah dipelajari di kelas)_
