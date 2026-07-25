# Planora Android persistence fix

## What was fixed
Android did not implement the `planora/storage` MethodChannel. Because of that, all save/read calls from the Flutter controller failed silently and data reset after closing the app.

`MainActivity.kt` now saves and reads every Planora storage key through Android SharedPreferences.

Also added the missing `assets/icons/` folder referenced by `pubspec.yaml`, which removes the build warning.

## Install
Replace your current project with this fixed source, then run:

```bash
cd ~/Developer/planora_flutter_mvp_v1
flutter clean
flutter pub get
flutter build apk --debug
```

## Test
1. Install the newly built APK (uninstall the old app first for a clean test).
2. Add a payment, expense, or change a setting.
3. Fully close Planora from recent apps.
4. Open it again. Your data should still be present.
