# 🎬 YouTube Video & Audio Downloader

A premium, production-ready mobile application built with **Flutter** for downloading YouTube videos and audio streams. It features a custom **FastAPI Python backend** that handles metadata extraction (`yt-dlp`) and proxies media downloads to bypass YouTube's IP-locking mechanisms.

---

## 🏗️ Project Architecture & Workflow

```
                                      +------------------------+
                                      |     YouTube Servers    |
                                      +------------------------+
                                         ^                  |
                          Extract Info / |                  | Stream Media Bytes
                         Proxy Request   |                  v
                                      +------------------------+
                                      |     Python Backend     |
                                      |   (FastAPI + yt-dlp)   |
                                      +------------------------+
                                         ^                  |
                       Fetch Metadata /  |                  | Proxy Stream Bytes
                       Proxy Request     |                  v
                                      +------------------------+
                                      |   Flutter Mobile App   |
                                      |   (Android Device)     |
                                      +------------------------+
```

1. **Information Scraper**: The app queries the local FastAPI server at `/api/info` with the YouTube link. The backend invokes `yt-dlp` to parse metadata (title, duration, thumbnail, and stream links).
2. **CDN Streaming Proxy**: YouTube CDNs restrict access to the IP address that requested the metadata. To bypass this, the app routes downloading requests to `/api/proxy?url=...` on the PC backend. The PC downloads the stream and pipes the data over the local network (`adb reverse` or Wi-Fi) to the mobile app.
3. **Android Media Scanner Integration**: Standard file writes do not automatically register in Android's media gallery. Once the download completes, the app invokes a custom Kotlin Platform Channel `com.ytdownloader.yt_downloader/media_scanner` that triggers a `MediaScannerConnection` request. The downloaded video/audio shows up **instantly** in the user's Gallery, Google Photos, or default Music/Video Player.

---

## ✨ Features

### 🎵 Audio Downloader
* Presets: **64kbps, 128kbps, 192kbps, 320kbps**
* Formats: **MP3, M4A, OPUS, FLAC**
* Automated media database indexing so it shows up in music players instantly.

### 🎬 Video Downloader
* High-quality downloads (**360p, 480p, 720p, 1080p**)
* Formats: **MP4, WEBM, MKV**
* Bypasses Google CDN IP locks by proxying chunks of data dynamically.

### 📦 Bulk Downloader
* Supports up to **50 URLs** at once (one per line).
* Dedicated concurrent download queue.
* Real-time download cards displaying individual speed, percentage progress bar, and ETA.
* Dynamically detects and badges valid YouTube URLs as you type or paste.

### 📜 Download History & Search
* Local SQLite database (`sqflite`) storage.
* Full-text search and categorizations.
* State-isolated BLoC management to prevent UI stuttering/refreshing during active downloads.

---

## 🛠️ Prerequisites

* **Python** 3.13+
* **Flutter SDK** 3.38+
* **Android SDK** API 21+
* **ADB CLI tool** (Required for USB forwarding)

---

## 🚀 Step-by-Step Setup & Running

### 1. Run the Python Backend
Activate the virtual environment, install dependencies, and run the server:
```bash
cd backend
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
python main.py
```
The FastAPI server will launch on `http://localhost:8000`.

### 2. Forward the Server Port to your Phone
If you are debugging on a physical Android device connected via USB, run this command to route `localhost:8000` from the device to your PC backend:
```bash
adb reverse tcp:8000 tcp:8000
```

### 3. Run the Flutter App
Launch the app on your connected device:
```bash
cd flutter_app
flutter pub get
flutter run
```

---

## 📡 API Reference

| Endpoint | Method | Query Parameters | Response | Description |
|---|---|---|---|---|
| `/health` | `GET` | None | `{"status": "ok", ...}` | Health check |
| `/api/info` | `GET` | `url` | `JSON` metadata | Metadata & available stream links |
| `/api/proxy` | `GET` | `url` | Byte Stream | Proxies video/audio streams |

---

## 📁 Repository Structure

```
youtube video downloader/
├── backend/                    # FastAPI Server
│   ├── .venv/                  # Virtual Environment
│   ├── main.py                 # API endpoints & proxy stream generator
│   └── requirements.txt        # fastapi, uvicorn, yt-dlp, httpx
│
└── flutter_app/                # Flutter Mobile Application
    ├── android/app/src/main/   # Android Manifest and MainActivity.kt (MediaScanner channel)
    ├── lib/
    │   ├── main.dart           # App Bootstrapper
    │   ├── core/theme/         # Custom color palettes & dark mode config
    │   ├── data/               # SQLite and Download Repository (MethodChannel handler)
    │   └── presentation/       # BLoC Binders, Screen views, and widgets
    └── pubspec.yaml            # Dart dependencies
```
