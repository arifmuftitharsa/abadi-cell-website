# Abadi Cell & Elektrik — Website Toko

Website profil toko elektronik & pulsa "Abadi Cell & Elektrik" di Sukabumi.
Dibuat sebagai tugas tambahan mata kuliah **Jaringan Komputer** (CS4 2025,
Universitas Pertamina) — deploy website ke cloud hosting dengan konfigurasi
web server, containerization, reverse proxy, CI/CD, dan monitoring.

Laporan lengkap proses deployment ada di
[`docs/Laporan_Deployment_AbadiCell_ArifMuftiTharsa.pdf`](docs/Laporan_Deployment_AbadiCell_ArifMuftiTharsa.pdf).

## Arsitektur

```
                         Internet
                            |
                            | HTTPS (domain kustom, TLS dikelola Railway)
                            v
              +-----------------------------+
              |  Railway - service publik   |
              |  Caddy (reverse proxy)      |
              +-----------------------------+
                            |
                            | Railway Private Networking
                            | (app.railway.internal:8080)
                            v
              +-----------------------------+
              |  Railway - service app      |
              |  Nginx + file statis        |
              |  (tidak punya domain publik)|
              +-----------------------------+

              +-----------------------------+
              |  GitHub Actions             |
              |  validasi build Docker &    |
              |  validasi Caddyfile         |
              +-----------------------------+
                            |
                            | push ke branch main
                            v
                Railway auto-deploy
                (source-based, langsung dari repo GitHub)
```

Website di-deploy di **Railway**, sebuah platform cloud hosting
(Platform-as-a-Service). Bukan VPS yang dikonfigurasi sendiri dari awal.
Ini disebutkan secara terbuka di sini dan di laporan PDF, karena
memengaruhi cara membaca arsitektur di bawah.

## Kenapa Ada 2 Service Terpisah?

1. **Service `app` tidak pernah langsung terekspos ke internet.** Service
   ini cuma bisa diakses lewat jaringan privat Railway
   (`app.railway.internal`), bukan lewat domain publik. Kalau ada yang
   mau menyerang service ini langsung dari luar, itu tidak mungkin
   dilakukan karena memang tidak ada jalur publik ke situ.
2. **Caddy dipakai di service publik, bukan Nginx.** Percobaan pertama
   pakai Nginx sebagai reverse proxy sempat gagal karena masalah resolusi
   DNS internal Railway. Ceritanya lebih lengkap ada di laporan PDF,
   bagian "Hambatan dan Solusi".
3. **HTTPS dikelola otomatis oleh Railway di levelnya sendiri**, bukan
   dipasang manual pakai Certbot. Ini konsekuensi dari memakai PaaS,
   bukan VPS mentah.

## Struktur Folder

```
abadi-cell-website/
├── app/                  Kode website statis (HTML, CSS, JS, logo)
├── nginx/
│   ├── app.conf           Konfigurasi Nginx di service app (serve file statis)
│   └── proxy.conf         Konfigurasi Nginx lama untuk proxy, sudah digantikan
│                          Caddy, disimpan sebagai referensi
├── Caddyfile              Konfigurasi Caddy untuk service publik
├── Dockerfile             Image untuk service publik (Caddy)
├── Dockerfile.app         Image untuk service app (Nginx + file statis)
├── railway.app.json       Config-as-code untuk service app di Railway
├── .github/workflows/
│   └── deploy.yml         CI: validasi build Docker & Caddyfile tiap push
└── docs/
    └── Laporan_Deployment_AbadiCell_ArifMuftiTharsa.pdf   Laporan lengkap proses deployment
```

## Menjalankan Secara Lokal

```bash
# Build dan jalankan service app (static file server) secara lokal
docker build -f Dockerfile.app -t abadicell-app .
docker run -p 8080:8080 abadicell-app

# Akses di http://localhost:8080
```

## Deployment ke Railway (Ringkasan)

Langkah lengkap dengan penjelasan tiap konfigurasi ada di laporan PDF:
[`docs/Laporan_Deployment_AbadiCell_ArifMuftiTharsa.pdf`](docs/Laporan_Deployment_AbadiCell_ArifMuftiTharsa.pdf).
Ringkasannya:

1. Hubungkan repository GitHub ke Railway
2. Hubungkan domain `.my.id` dari Hostinger lewat DNS record (TXT, CNAME, ALIAS)
3. Setup GitHub Actions untuk validasi build tiap push ke branch main
4. Pisahkan arsitektur jadi 2 service: `app` (privat) dan proxy (publik, Caddy),
   terhubung lewat Railway Private Networking
5. Setup monitoring eksternal dengan UptimeRobot

## Stack yang Dipakai dan Alasannya

| Komponen | Pilihan | Alasan |s
|---|---|---|
| Hosting | Railway (PaaS) | Deploy cepat, private networking bawaan, tidak perlu kelola OS manual |
| Web server service app | Nginx (alpine) | Ringan, image kecil, cocok untuk file statis |
| Web server service publik | Caddy 2 | DNS lookup ulang otomatis tiap request, cocok dipakai di private networking Railway |
| Containerization | Docker, 2 Dockerfile terpisah | Setiap service punya tanggung jawab dan image sendiri |
| CI/CD | GitHub Actions | Validasi build dan config sebelum Railway auto-deploy |
| Domain & DNS | Hostinger | Domain `.my.id`, DNS record dikonfigurasi manual ke Railway |
| Monitoring | UptimeRobot | Gratis, eksternal, tidak perlu hosting/kelola sendiri |

## Refleksi & Hambatan

Cerita lengkap soal debugging error 502 Bad Gateway, kesalahan membuat
service di project Railway yang berbeda, dan proses berpindah dari Nginx
ke Caddy, ada di laporan PDF bagian "Hambatan dan Solusi" dan "Refleksi
Pembelajaran".
