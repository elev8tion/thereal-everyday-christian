#!/bin/bash
# Test In-App Purchases in iOS Simulator
# No Apple ID sign-out required!

echo "=========================================="
echo "IAP TESTING IN SIMULATOR (NO SIGN-OUT)"
echo "=========================================="
echo ""

cd /Users/kcdacre8tor/thereal-everyday-christian

echo "Step 1: Starting iOS Simulator..."
echo ""

# Open Xcode project with StoreKit configuration
open -a Xcode ios/Runner.xcworkspace

echo "Step 2: In Xcode that just opened:"
echo ""
echo "1. Click 'Runner' scheme at the top"
echo "2. Select 'Edit Scheme...'"
echo "3. Click 'Run' on left sidebar"
echo "4. Go to 'Options' tab"
echo "5. Under 'StoreKit Configuration':"
echo "   - Click dropdown"
echo "   - Select 'Configuration.storekit'"
echo "6. Click 'Close'"
echo ""
echo "Press ENTER when you've set up StoreKit configuration..."
read -r

echo ""
echo "Step 3: Run the app in Simulator"
echo ""
echo "Click the Play button in Xcode (or press Cmd+R)"
echo ""
echo "Press ENTER when app is running in simulator..."
read -r

echo ""
echo "Step 4: Test Subscriptions"
echo "============================="
echo ""
echo "In the Simulator app:"
echo "1. Navigate to subscription screen"
echo "2. Tap yearly or monthly subscription"
echo "3. Purchase dialog appears"
echo "4. Click 'Subscribe' - NO CREDENTIALS NEEDED"
echo "5. Purchase completes instantly"
echo "6. Verify subscription activates"
echo ""
echo "To view purchases:"
echo "- Xcode > Debug > StoreKit > Manage Transactions"
echo "- See all test purchases and renewals"
echo ""
echo "To test refund/cancellation:"
echo "- Xcode > Debug > StoreKit > Manage Transactions"
echo "- Right-click purchase > Refund"
echo ""
echo "=========================================="
echo "SIMULATOR TESTING BENEFITS:"
echo "- No Apple ID required"
echo "- No sign-out needed"
echo "- Instant purchases"
echo "- Full transaction control"
echo "- Can test edge cases easily"
echo "=========================================="
