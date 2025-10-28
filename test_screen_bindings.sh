#!/bin/bash
# Screen Binding Verification Test Runner
# Runs comprehensive tests to verify all UI → Backend bindings work correctly

set -e

echo "════════════════════════════════════════════════"
echo "🧪 SCREEN BINDING VERIFICATION TEST"
echo "════════════════════════════════════════════════"
echo ""

# Check if device argument provided
if [ -z "$1" ]; then
    echo "📱 Detecting available devices..."
    flutter devices
    echo ""
    echo "⚠️  Please specify a device ID:"
    echo "Usage: ./test_screen_bindings.sh <device-id>"
    echo ""
    echo "Example:"
    echo "  ./test_screen_bindings.sh \"iPhone 16\""
    echo "  ./test_screen_bindings.sh emulator-5554"
    exit 1
fi

DEVICE_ID="$1"

echo "🎯 Target Device: $DEVICE_ID"
echo ""

echo "📦 Step 1: Getting dependencies..."
flutter pub get

echo ""
echo "🧹 Step 2: Cleaning build artifacts..."
flutter clean

echo ""
echo "🔨 Step 3: Running integration tests on device..."
flutter test integration_test/app_test.dart --device-id="$DEVICE_ID"

echo ""
echo "════════════════════════════════════════════════"
echo "✅ SCREEN BINDING TESTS COMPLETE"
echo "════════════════════════════════════════════════"
