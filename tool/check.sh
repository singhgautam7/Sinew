#!/usr/bin/env bash
# What CI runs. Must pass before a phase is called done.
set -euo pipefail
cd "$(dirname "$0")/.."

flutter pub get
dart run build_runner build --delete-conflicting-outputs
# Generated code must be committed and current.
git diff --exit-code -- '*.g.dart' '*.freezed.dart' || {
  echo "Generated files are stale: run build_runner and commit." >&2
  exit 1
}
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
