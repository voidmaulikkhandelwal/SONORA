<div align="center">
  <img src="icons/sonora.png" alt="SONORA" width="140"/>
  <h1>SONORA</h1>
  <p><strong>A liquid glass music player for Windows</strong></p>
</div>

---

SONORA streams music from YouTube Music with a liquid glass interface, and mirrors
the feature set of the mobile app: search, home feed, charts and moods, queue,
synced lyrics, favourites, history, playlists, downloads, Spotify playlist import,
equalizer, sleep timer, backup & restore, and local file playback.

Developed by **Maulik Khandelwal**.

## Build (GitHub Actions)

1. Push this repository to GitHub.
2. Open **Actions → Build SONORA for Windows → Run workflow**.
3. Download `SONORA-Windows-Setup` (installer) from the run's artifacts.

## Build locally

```powershell
flutter pub get
flutter build windows --release
```

## License

GPL-3.0 — see `LICENSE` and `NOTICE.md` (SONORA is derived from Echo Music).
