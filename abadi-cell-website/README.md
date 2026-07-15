# Abadi Cell & Elektrik — Website Toko

Website profil toko elektronik & pulsa "Abadi Cell & Elektrik" di Sukabumi.
Dibuat sebagai tugas tambahan mata kuliah **Jaringan Komputer** (CS4 2025,
Universitas Pertamina) — deploy website pada Cloud/VPS dengan konfigurasi
web server mandiri.

> Dokumentasi ini ditulis untuk menjelaskan **kenapa** setiap keputusan
> teknis diambil, bukan hanya **apa** yang dijalankan — karena tugas ini
> mensyaratkan pemahaman konfigurasi, bukan sekadar hasil akhir.

## Arsitektur

```
                    Internet
                       │
                       │ HTTPS (port 443)
                       ▼
        ┌──────────────────────────────┐
        │   VPS (Ubuntu)                │
        │                                │
        │   Nginx (reverse proxy)        │  <- install langsung di OS,
        │   - Terminasi SSL/TLS          │     bukan di container
        │   - Let's Encrypt certbot      │
        │                                │
        │        │ proxy_pass            │
        │        │ (HTTP, port 8081)     │
        │        ▼                       │
        │   ┌─────────────────────┐      │
        │   │ Docker container:    │      │
        │   │ web (Nginx + static  │      │
        │   │ HTML/CSS)             │      │
        │   └─────────────────────┘      │
        │                                │
        │   ┌─────────────────────┐      │
        │   │ Docker container:    │      │
        │   │ uptime-kuma           │      │
        │   │ (monitoring)          │      │
        │   └─────────────────────┘      │
        └──────────────────────────────┘
                       ▲
                       │ git pull + docker compose build/up
                       │
        ┌──────────────────────────────┐
        │  GitHub Actions (CI/CD)       │
        │  trigger: push ke branch main │
        └──────────────────────────────┘
```

## Kenapa Reverse Proxy Terpisah dari Container Aplikasi?

Ini keputusan desain yang sengaja dipilih, bukan default:

1. **Sertifikat HTTPS dikelola di level sistem operasi VPS**, bukan di dalam
   container. Ini membuat proses renewal sertifikat (Let's Encrypt, berlaku
   90 hari) tidak tergantung pada siklus hidup container aplikasi.
2. **Container aplikasi tidak pernah langsung terekspos ke internet** —
   hanya bisa diakses lewat `127.0.0.1:8081`, yang berarti port itu hanya
   bisa diakses dari VPS itu sendiri, diteruskan lewat Nginx reverse proxy.
   Ini mengurangi permukaan serangan (attack surface).
3. Nginx reverse proxy yang sama bisa meneruskan ke beberapa service
   sekaligus (aplikasi web + dashboard monitoring) tanpa perlu container
   aplikasi tahu-menahu soal itu.

## Struktur Folder

```
abadi-cell-website/
├── app/                      Kode website statis (HTML, CSS, logo)
├── nginx/
│   ├── default.conf          Konfigurasi Nginx DI DALAM container (serve static files)
│   └── reverse-proxy.conf    Konfigurasi Nginx DI VPS (HTTPS + reverse proxy)
├── Dockerfile                Definisi image container aplikasi
├── docker-compose.yml        Orkestrasi container web + monitoring
├── .github/workflows/
│   └── deploy.yml            Pipeline CI/CD (auto-deploy saat push ke main)
└── docs/
    └── DEPLOYMENT.md          Laporan proses deployment step-by-step (untuk PDF)
```

## Menjalankan Secara Lokal (Sebelum Deploy)

```bash
# Build dan jalankan container aplikasi saja, tanpa reverse proxy/HTTPS
docker compose up --build web

# Akses di http://localhost:8081
```

## Deployment ke VPS (Ringkasan)

Langkah lengkap dengan penjelasan tiap konfigurasi ada di
[`docs/DEPLOYMENT.md`](docs/DEPLOYMENT.md). Ringkasannya:

1. Provisioning VPS (Ubuntu), install Docker & Docker Compose
2. Install Nginx langsung di VPS sebagai reverse proxy
3. Arahkan domain/subdomain ke IP VPS (DNS A record)
4. Jalankan `docker compose up -d` untuk container aplikasi
5. Konfigurasi Nginx reverse proxy meneruskan ke container
6. Aktifkan HTTPS dengan Certbot (Let's Encrypt)
7. Setup GitHub Actions agar setiap `git push` otomatis deploy ulang

## Stack yang Dipakai dan Alasannya

| Komponen | Pilihan | Alasan |
|---|---|---|
| Web server aplikasi | Nginx (alpine) | Ringan, image kecil (~20MB), cocok untuk VPS spek kecil |
| Containerization | Docker + Docker Compose | Reproducible, mudah dipindah antar VPS, standar industri |
| Reverse proxy + HTTPS | Nginx (host) + Certbot | Pemisahan tanggung jawab, sertifikat dikelola independen dari container |
| CI/CD | GitHub Actions + SSH deploy | Otomatisasi deploy tanpa akses manual berulang ke VPS |
| Monitoring | Uptime Kuma | Ringan, self-hosted, dashboard visual untuk bukti uptime |

## Refleksi & Hambatan

*(Diisi setelah proses deployment aktual selesai — lihat `docs/DEPLOYMENT.md`
bagian "Hambatan dan Solusi" serta "Refleksi".)*
