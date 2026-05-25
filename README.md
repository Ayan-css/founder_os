# Founder OS

Personal Founder Operating System — Your daily execution cockpit.

## Features
- Today Screen (tasks, focus timer, streak)
- Quick Capture (brain dump)
- Focus Mode (fullscreen pomodoro)
- Daily Reflection (evening prompts)
- Content Pipeline (kanban)
- Client Tracker (minimal CRM)

## Install on Android WITHOUT a PC

### Method 1 — Codemagic (Easiest, Free)
1. Create a free GitHub account → github.com
2. Create a new repository called `founder-os`
3. Upload all these project files to GitHub
4. Go to codemagic.io → Sign up free with GitHub
5. Add your app → select the repo
6. Set Flutter version to 3.x
7. Click "Start build"
8. Download the APK from the build artifacts
9. Open APK on your phone → tap Install

### Method 2 — FlutLab (Browser-based IDE)
1. Go to flutlab.io
2. Create account → New Project
3. Upload the source files
4. Click Build → Android APK
5. Download and install on phone

### Method 3 — GitHub Actions (Automated)
Add this file as `.github/workflows/build.yml` in your repo:

```yaml
name: Build APK
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
      - run: flutter pub get
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v3
        with:
          name: founder-os.apk
          path: build/app/outputs/flutter-apk/app-release.apk
```

Then download the APK from the Actions tab on GitHub.

## Before Installing APK on Android
1. Go to Settings → Apps → Special app access → Install unknown apps
2. Allow your browser or file manager to install APKs
3. Open the downloaded APK → Install

## Tech Stack
- Flutter 3.x
- Riverpod 2.x (state management)
- SQLite (local storage)
- Google Fonts (Inter + JetBrains Mono)
