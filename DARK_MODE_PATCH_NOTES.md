# Planora Dark Mode Patch

This patch focuses on the contrast/layout issues visible in the supplied dark-mode screenshots.

Changes include:
- Added reusable dark/light semantic surface colors in `AppThemeColors`.
- Added dark `InputDecorationTheme` defaults for input labels, prefixes and borders.
- Changed the app shell so the bottom navigation no longer overlays page content (`extendBody: false`).
- Made Dashboard shortcut, salary-tip, tracking, warning and alert surfaces dark-mode aware.
- Made payment form text, dropdown text, icons and borders dark-mode aware.
- Made calendar day/event/payment text and empty-state surfaces dark-mode aware.
- Made analysis warning/success cards dark-mode aware.
- Made Payments search/filter/list foregrounds dark-mode aware.
- Made reusable `PlanoraEmptyState` and progress tracks dark-mode aware.

Validation note:
The execution environment used to prepare this archive does not include the Dart/Flutter SDK, so `dart format` and `flutter analyze` could not be run here. Run these locally before the Xcode test:

```bash
dart format lib
flutter analyze
```

Then test both Light and Dark themes on the physical iPhone.
