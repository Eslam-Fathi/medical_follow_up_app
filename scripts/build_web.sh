#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "🚀 Starting Flutter Web Build Process for Vercel..."

# 1. Environment Variable Management
# Create .env from Vercel secrets if it doesn't exist
if [ ! -f ".env" ]; then
  echo "📝 Generating .env from environment variables..."
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
flutter config --no-analytics
flutter config --enable-web

# 4. Dependency Management
echo "📦 Installing project dependencies..."
flutter pub get

# 5. Build Process
echo "🏗️ Building Flutter Web (Release Mode)..."
# Using CanvasKit renderer for superior chart and animation performance
flutter build web --release --base-href / --web-renderer canvaskit

echo "✅ Build Process Completed Successfully!"
echo "📁 Output directory: build/web"
