# candle

A new Flutter project.

REQUIRES or builds only with flutter 3.16.9

## Full Android build

```sh
flutter --version
  Flutter 3.16.9 • channel stable • https://github.com/flutter/flutter.git
  Framework • revision 41456452f2 (8 months ago) • 2024-01-25 10:06:23 -0800
  Engine • revision f40e976bed
  Tools • Dart 3.2.6 • DevTools 2.28.5
```

```sh
dart pub cache clean  

flutter clean
flutter pub get
# flutter build apk --release   
flutter build appbundle --release

```

## Dull Apple Build

```sh

flutter build ios --release


```

## Run in Debug Mode

```sh
flutter devices

```