# Relayit

An offline, Android-only SMS relay app that forwards incoming text messages to WhatsApp, Email, or another phone number based on the jobs you configure.

The Flutter project lives entirely under [`app/`](app); the rest of the repository is reserved for tooling, CI, and documentation.

## Repository Layout

```
.
├── .github/workflows/   GitHub Actions: Android validation + APK/AAB builds
├── app/                 Flutter project (pubspec, lib, test, android, scripts)
└── PROMPT.md            Product/architecture spec for the app
```

## Development

Install [pre-commit](https://pre-commit.com/) and its hooks once:

```sh
pip install pre-commit
pre-commit install
```

Hooks run light hygiene checks; the optional `flutter format` / `flutter analyze` / `flutter test` hooks are commented out and can be enabled locally. Keep the Flutter SDK (and its bundled `dart`) on your `PATH`.

Run the basic local checks before opening a pull request:

```sh
cd app
flutter pub get
flutter analyze
flutter test
```

Build Android APKs locally with:

```sh
cd app
flutter build apk --release --split-per-abi
```

## Distribution Builds

Android distribution artifacts are produced by GitHub Actions; binaries are never committed to the repository.

- Branch pushes and pull requests run the `Android` workflow's `validate` job (`flutter pub get`, `dart format --set-exit-if-changed`, `flutter analyze`, `flutter test`).
- Tag pushes matching `v*` build split APKs (`Android` workflow) and an `.aab` (`Play Store` workflow) automatically.
- Non-tag APK builds can also be triggered manually via the `Android` workflow's "Run workflow" button.

Artifacts are attached to the workflow run under the names `relayit-android-apks` and `relayit-playstore-aab`.

## Note

This app is not yet available on the Google Play Store. To try it out, download the APK artifact from a tagged or manually run GitHub Actions workflow.
