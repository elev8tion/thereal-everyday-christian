#!/bin/bash
# Query App Store Connect for Everyday Christian app info

echo "🔍 Querying App Store Connect..."
echo "================================"
echo ""

# Check if .env exists
if [ ! -f "fastlane/.env" ]; then
    echo "❌ Error: fastlane/.env not found!"
    echo ""
    echo "Run this first:"
    echo "  cd /Users/kcdacre8tor/thereal-everyday-christian/ios/fastlane"
    echo "  bash setup_credentials.sh"
    exit 1
fi

cd "$(dirname "$0")/.."

echo "📱 Local App Info:"
echo "-----------------"
VERSION=$(fastlane run get_version_number xcodeproj:"Runner.xcodeproj" 2>/dev/null | grep "Result:" | awk '{print $2}')
BUILD=$(fastlane run get_build_number xcodeproj:"Runner.xcodeproj" 2>/dev/null | grep "Result:" | awk '{print $2}')
echo "Version: $VERSION"
echo "Build: $BUILD"
echo "Bundle ID: com.elev8tion.everydaychristian"
echo ""

echo "☁️  Fetching App Store Connect Data..."
echo "--------------------------------------"

# Download current metadata
echo ""
echo "1️⃣  Downloading app metadata..."
fastlane deliver download_metadata --force 2>&1 | grep -E "Successfully|Error|Version|Build|Status" || echo "Download failed - check credentials"

echo ""
echo "2️⃣  Checking TestFlight builds..."
fastlane run latest_testflight_build_number app_identifier:"com.elev8tion.everydaychristian" 2>&1 | grep -E "Result:|Error|Build" || echo "No TestFlight builds found"

echo ""
echo "3️⃣  Getting app info..."
fastlane run app_store_build_number app_identifier:"com.elev8tion.everydaychristian" 2>&1 | grep -E "Result:|Error|Version" || echo "App not yet published"

echo ""
echo "✅ Query complete!"
echo ""
echo "📁 Downloaded metadata saved to: fastlane/metadata/"
echo ""
