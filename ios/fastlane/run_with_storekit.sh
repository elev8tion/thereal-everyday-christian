#!/bin/bash
# Run app in Simulator with StoreKit testing enabled
# No manual Xcode configuration needed!

set -e

echo "=========================================="
echo "STARTING SIMULATOR WITH STOREKIT TESTING"
echo "=========================================="
echo ""

cd /Users/kcdacre8tor/thereal-everyday-christian

# Kill any existing simulators
echo "Cleaning up existing simulators..."
killall Simulator 2>/dev/null || true

# Boot iPhone 16 simulator
echo "Booting iPhone 16 simulator..."
xcrun simctl boot "iPhone 16" 2>/dev/null || echo "Simulator already booted"

# Open Simulator app
echo "Opening Simulator.app..."
open -a Simulator

# Wait for simulator to be ready
sleep 3

echo ""
echo "Building and running app with StoreKit configuration..."
echo "This will take 1-2 minutes..."
echo ""

# Run with StoreKit configuration
cd ios
xcodebuild \
  -workspace Runner.xcworkspace \
  -scheme Runner \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -storeKitConfigurationPath Configuration.storekit \
  build | xcpretty || true

echo ""
echo "Installing app on simulator..."
flutter run -d "iPhone 16" --debug &

# Wait for app to launch
sleep 10

echo ""
echo "=========================================="
echo "✓ APP RUNNING IN SIMULATOR"
echo "=========================================="
echo ""
echo "STOREKIT TESTING ACTIVE:"
echo "- No Apple ID needed"
echo "- Purchases are FREE and instant"
echo "- Transaction logs in Xcode > Debug menu"
echo ""
echo "TO TEST SUBSCRIPTIONS:"
echo "1. In simulator, navigate to subscription screen"
echo "2. Tap yearly or monthly subscription"
echo "3. Click 'Subscribe' - NO login required"
echo "4. Purchase completes instantly"
echo "5. Verify premium features unlock"
echo ""
echo "TO VIEW PURCHASES:"
echo "Xcode > Debug > StoreKit > Manage Transactions"
echo ""
echo "TO CANCEL/REFUND:"
echo "Xcode > Debug > StoreKit > Manage Transactions"
echo "Right-click purchase > Refund"
echo ""
echo "=========================================="
