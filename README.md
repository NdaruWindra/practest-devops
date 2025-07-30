# practest-devops

# Proyek DevOps Technical Test: Web Server Nginx dengan CI/CD

Proyek ini mendemonstrasikan kemampuan membangun dan mendeploy aplikasi web sederhana menggunakan Docker, Nginx, dan mengimplementasikan pipeline CI/CD dengan GitHub Actions.

## Daftar Isi
1.  [Gambaran Umum Proyek](#1-gambaran-umum-proyek)
2.  [Instruksi Menjalankan Proyek (Lokal)](#2-instruksi-menjalankan-proyek-lokal)
3.  [Penjelasan Pipeline CI/CD dengan GitHub Actions](#3-penjelasan-pipeline-ci-cd-dengan-github-actions)
4.  [Asumsi yang Dibuat](#4-asumsi-yang-dibuat)

---

## 1. Gambaran Umum Proyek

Proyek ini bertujuan untuk memenuhi technical test DevOps yang meliputi:
* Pembuatan Dockerfile untuk aplikasi web Nginx sederhana.
* Konfigurasi Nginx untuk menyajikan file HTML.
* Implementasi pipeline CI/CD menggunakan GitHub Actions untuk otomatisasi proses build, push image Docker ke Docker Hub, dan deployment container.
* Verifikasi fungsionalitas container yang di-deploy.

Aplikasi yang digunakan adalah file HTML statis sederhana yang akan disajikan oleh Nginx.

---

## 2. Instruksi Menjalankan Proyek (Lokal)

Bagian ini menjelaskan cara menjalankan aplikasi web Nginx menggunakan Docker di lingkungan lokal Anda.

**Prasyarat:**
* Docker Desktop / Docker Engine terinstal dan berjalan.

**Langkah-langkah:**

1.  **Clone Repositori:**
    Clone repositori ini ke mesin lokal Anda.
    ```bash
    git clone https://github.com/NdaruWindra/practest-devops.git
    cd practest-devops
    ```

2.  **Siapkan File Aplikasi dan Konfigurasi:**
    Pastikan Anda memiliki file `practest.html`, `nginx.conf`, dan `Dockerfile` di direktori proyek. File `practest.html` harus berisi teks `<h1>Hello, saya [Nama_Anda]</h1>`.

3.  **Build Image Docker:**
    Gunakan `Dockerfile` untuk membangun image Docker dari direktori proyek Anda.
    ```bash
    docker build -t practest-local:latest .
    ```

4.  **Jalankan Container Docker:**
    Jalankan container dari image yang baru saja Anda build. Petakan port 8080 host Anda ke port 80 di dalam container (tempat Nginx berjalan).
    ```bash
    docker run -d --name practest-container-local -p 8080:80 practest-local:latest
    ```

5.  **Verifikasi Container Berjalan:**
    Periksa apakah container Anda aktif menggunakan perintah Docker.
    ```bash
    docker ps
    ```
    Anda akan melihat `practest-container-local` dengan status `Up`.

6.  **Akses Web Server:**
    Buka browser web Anda dan kunjungi URL lokal untuk mengakses halaman HTML.
    `http://localhost:8080/practest.html`
    Anda juga bisa memverifikasi menggunakan `curl` dari terminal.
    ```bash
    curl http://localhost:8080/practest.html
    ```

7.  **Hentikan dan Hapus Container (Opsional, untuk Cleanup):**
    Setelah selesai pengujian, hentikan dan hapus container lokal Anda.
    ```bash
    docker stop practest-container-local
    docker rm practest-container-local
    ```

---

## 3. Penjelasan Pipeline CI/CD dengan GitHub Actions

Pipeline CI/CD ini diimplementasikan menggunakan GitHub Actions dan didefinisikan dalam file `.github/workflows/main.yml`. Pipeline ini otomatis terpicu setiap kali ada *push* ke *branch* `main` repositori.

**Prasyarat Konfigurasi GitHub:**
* Anda perlu membuat GitHub Secrets bernama `DOCKER_USERNAME` (dengan nilai username Docker Hub Anda, yaitu `ndaruwindra`) dan `DOCKER_PASSWORD` (dengan nilai Personal Access Token Docker Hub Anda) di pengaturan repositori GitHub Anda (`Settings` -> `Secrets and variables` -> `Actions`).

Pipeline terdiri dari dua tahap (Jobs):

### a. `build_push` Job
* **Tujuan:** Membangun image Docker dari aplikasi dan mendorongnya ke Docker Hub.
* **Proses:**
    * Mengambil kode sumber dari repositori GitHub.
    * Melakukan otentikasi ke Docker Hub menggunakan GitHub Secrets.
    * Mengganti placeholder nama `[Nama_Anda]` di `practest.html` dengan nama yang telah ditentukan (yaitu, `ndaruwindra`).
    * Membangun image Docker berdasarkan `Dockerfile` yang ada di root proyek.
    * Mendorong image yang telah di-build ke Docker Hub (`docker.io/ndaruwindra/practest-webserver:latest`).

### b. `deploy` Job
* **Tujuan:** Menjalankan container menggunakan image yang sudah ada di Docker Hub dan melakukan verifikasi deployment.
* **Ketergantungan:** Job ini hanya akan berjalan setelah `build_push` job berhasil diselesaikan.
* **Lingkungan Runtime:** Menggunakan *runner* `ubuntu-latest` yang disediakan GitHub dan layanan `docker:dind` (Docker-in-Docker) untuk menjalankan perintah Docker di dalamnya.
* **Proses:**
    * Melakukan otentikasi ulang ke Docker Hub untuk menarik image.
    * Menarik image Docker (`ndaruwindra/practest-webserver:latest`) dari Docker Hub.
    * Menghentikan dan menghapus *container* lama dengan nama `practest-ndaruwindra` jika ada, untuk memastikan *deployment* yang bersih.
    * Menjalankan *container* baru dengan nama `practest-ndaruwindra` dalam mode *detached* dan memetakan *port* eksternal `8081` ke *port* internal `80` di *container*.
    * **Verifikasi Otomatis:**
        * Menjalankan perintah `docker ps` untuk mengkonfirmasi *container* `practest-ndaruwindra` sedang berjalan.
        * Menjalankan `curl http://localhost:8081/practest.html` untuk memverifikasi bahwa *web server* di dalam *container* dapat diakses dan merespons dengan konten `practest.html` yang diharapkan.

---

## 4. Asumsi yang Dibuat

* Koneksi internet tersedia untuk GitHub Actions *runner* untuk mengakses Docker Hub.
* Kredensial Docker Hub yang diberikan melalui GitHub Secrets adalah valid dan memiliki izin *push* ke repositori Docker Hub Anda.
* Base *image* `alpine:3.17.0` dan *image* `docker:dind` tersedia di Docker Hub.

---


