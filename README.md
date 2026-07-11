<div align="center">

<img src="assets/logo.png" alt="PageTurn logo" width="96" />

# 📖 PageTurn

**A cozy, premium reading companion built with Flutter.**

Ebooks, audiobooks, reading clubs, and AI-powered insights — wrapped in a warm, bookish UI with buttery-smooth UX.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.12-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS-lightgrey)]()
[![License](https://img.shields.io/badge/license-TBD-lightgrey)]()

</div>

---

## ✨ Overview

PageTurn is a book app concept designed around a **cozy, bookish aesthetic** paired with modern mobile interaction patterns — a glassmorphic floating bottom nav, Lottie-animated splash, curated home feed, and a distraction-free reader. It's built with a clean, layered architecture (`domain` / `data` / `presentation`) so features can grow from UI prototypes into fully wired, backend-connected screens without a rewrite.

## 🔥 Features

**Reading Experience**
- Distraction-free ebook reader with theme picker (light, dark, sepia), font settings, chapter list, dictionary lookup, and highlight/note tools
- Continue-reading progress tracking and a personal library organized into custom shelves

**Audiobooks & Narration**
- Full audio player with scrubber, speed picker, sleep timer, and voice selector
- Text-to-speech and "read-along" mode that syncs narration with the page
- Podcast-style episode browsing for serialized audio content

**Community**
- Reading clubs — join, create, and discuss books with a moderator, rules, and an activity feed
- Book reviews, ratings, and a trending leaderboard
- Quote Studio for turning highlights into shareable, templated quote cards

**AI-Powered**
- Chat with a book to ask questions about its content
- One-tap AI-generated chapter and book summaries

**Personalization**
- Onboarding flow with animated badges and waveform visuals
- Reading goals, streak calendars, and stats dashboards
- Custom drawer, downloads manager, and a quick-add FAB for books and clubs (catalog quick-add or custom entry)

**Design**
- Suspended glassmorphic bottom navigation (Telegram-inspired) with backdrop blur, content scrolling fully behind it
- Rich home page: Book of the Day, continue-reading strip, trending shelves, and curated spotlights (incl. African Spotlight)

## 🧱 Architecture

PageTurn follows a **Clean Architecture** layout, separating concerns into three layers:

```
lib/
├── domain/            # Business logic — entities, repository interfaces, use cases
│   ├── entities/
│   ├── repositories/
│   └── usecases/       # ai/, audio/, book/, highlights/, library/
├── data/               # Implementation — models, repositories, data sources
│   ├── models/
│   ├── repositories/
│   └── sources/         # local/ (Hive, Isar) · remote/ (Supabase, book API, AI)
├── presentation/       # UI — feature-first screens, providers, and widgets
│   ├── home/ library/ explore/ profile/
│   ├── reader/ audio_player/ audiobooks/ ebooks/
│   ├── reading_clubs/ explore/clubs/ explore/quote_studio/
│   ├── ai/ search/ onboarding/ splash/ settings/ help/
│   └── common/          # shared widgets & layouts
├── core/               # Theming, routing, constants, error types, utils
├── services/           # Cross-cutting services (audio, TTS, sync, notifications, payments, analytics, downloads)
├── config/             # Environment & Supabase configuration
└── app.dart, routes.dart, main.dart
```

State is currently managed with lightweight `ChangeNotifier` singletons (e.g. `LibraryProvider`, `ReadingClubProvider`) consumed via `ListenableBuilder`/`ValueListenable`, keeping the UI reactive without a heavier state-management dependency.

> **Status:** the presentation layer is fully built out screen-by-screen against mock data (see `mock_books.dart`). The data layer's remote/local sources (Supabase, Hive, Isar, AI) are scaffolded and being wired up incrementally.

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart ^3.12.2)
- Android Studio / Xcode for platform toolchains, or a connected device/emulator

### Install & run

```bash
git clone https://github.com/Qharny/PageTurn.git
cd PageTurn
flutter pub get
flutter run
```

### Useful commands

```bash
flutter analyze     # static analysis / lints
flutter test        # run the test suite
flutter build apk    # build an Android release APK
flutter build ios    # build an iOS release (requires macOS/Xcode)
```

## 🛠️ Tech Stack

| | |
|---|---|
| **Framework** | Flutter & Dart |
| **Animations** | [Lottie](https://pub.dev/packages/lottie) |
| **Persistence** | `shared_preferences`, with Hive/Isar local sources in progress |
| **Backend** | Supabase (in progress) |
| **Icons** | `flutter_launcher_icons`, Material Icons |
| **Linting** | `flutter_lints` |

## 🗺️ Roadmap

- [ ] Wire up Supabase remote data source (auth, books, clubs, sync)
- [ ] Persist library/clubs/highlights locally via Hive or Isar
- [ ] Connect AI chat & summary features to a live model backend
- [ ] Real TTS + audio streaming integration
- [ ] Payments/premium tier wiring

## 🤝 Contributing

This project is under active, solo development. Issues and pull requests are welcome — feel free to open one to discuss a change before submitting a PR for anything non-trivial.

## 📄 License

License to be determined.
