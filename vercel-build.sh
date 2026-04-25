#!/usr/bin/env bash
set -euo pipefail

FLUTTER_CHANNEL="${FLUTTER_VERSION:-stable}"
FLUTTER_DIR="${VERCEL_CACHE_DIR:-$PWD/.vercel-cache}/flutter"

if ! command -v flutter >/dev/null 2>&1; then
  if [ ! -d "$FLUTTER_DIR/.git" ]; then
    rm -rf "$FLUTTER_DIR"
    git clone https://github.com/flutter/flutter.git "$FLUTTER_DIR" \
      --depth 1 \
      --branch "$FLUTTER_CHANNEL"
  fi

  export PATH="$FLUTTER_DIR/bin:$PATH"
fi

flutter --version
flutter config --enable-web
flutter pub get

DART_DEFINES=()

if [ -n "${SUPABASE_URL:-}" ]; then
  DART_DEFINES+=(--dart-define="SUPABASE_URL=$SUPABASE_URL")
fi

if [ -n "${SUPABASE_PUBLISHABLE_KEY:-}" ]; then
  DART_DEFINES+=(--dart-define="SUPABASE_PUBLISHABLE_KEY=$SUPABASE_PUBLISHABLE_KEY")
fi

if [ -n "${SUPABASE_ANON_KEY:-}" ]; then
  DART_DEFINES+=(--dart-define="SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY")
fi

flutter build web --release --base-href / "${DART_DEFINES[@]}"
