#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "🚀 Starting Flutter Web Build Process for Vercel..."

# Prevent git from prompting for credentials (important in CI)
export GIT_TERMINAL_PROMPT=0

# 1. Environment Variable Management
# Create .env from Vercel secrets
if [ ! -f ".env" ]; then
  echo "📝 Generating .env from environment variables..."
  touch .env
  if [ -z "$GEMINI_API_KEY" ]; then
    echo "⚠️ Warning: GEMINI_API_KEY is not set in environment variables."
  else
    echo "GEMINI_API_KEY=$GEMINI_API_KEY" > .env
    echo "✅ .env generated successfully."
  fi
fi

# 2. Flutter SDK Setup
# Vercel build environment doesn't have Flutter. We download the stable version.
if [ ! -d "flutter" ]; then
  echo "📥 Cloning Flutter SDK (stable)..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1
else
  echo "📦 Flutter SDK already exists, skipping clone."
fi

# Add Flutter to the path
export PATH="$PATH:`pwd`/flutter/bin"

# 3. Flutter Configuration
echo "⚙️ Configuring Flutter..."
flutter config --enable-web --suppress-analytics

# 4. Dependency Management
echo "📦 Installing project dependencies..."
flutter pub get

# 5. Build Process
echo "🏗️ Building Flutter Web (Release Mode)..."
# Note: --web-renderer was removed in Flutter 3.22+. CanvasKit is now the default.
flutter build web --release --base-href "/" --suppress-analytics

echo "✅ Build Process Completed Successfully!"
echo "📁 Output directory: build/web"
