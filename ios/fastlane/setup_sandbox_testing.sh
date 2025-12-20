#!/bin/bash
# Setup Sandbox Testing Helper
# Opens App Store Connect pages and provides step-by-step instructions

echo "=========================================="
echo "SANDBOX TESTING SETUP HELPER"
echo "=========================================="
echo ""

# Step 1: Create Sandbox Account
echo "STEP 1: CREATE SANDBOX TEST ACCOUNT"
echo "------------------------------------"
echo "Opening App Store Connect Sandbox Testers page..."
sleep 2
open "https://appstoreconnect.apple.com/access/testers"

echo ""
echo "In the browser that just opened:"
echo "1. Click 'Sandbox' tab at the top"
echo "2. Click '+' button"
echo "3. Fill in:"
echo "   - First Name: Test"
echo "   - Last Name: User"
echo "   - Email: testuser+everyday1@gmail.com"
echo "   - Password: TestPass123!"
echo "   - Region: United States"
echo "4. Click 'Invite'"
echo ""
echo "Press ENTER when you've created the account..."
read -r

# Step 2: Verify Subscriptions
echo ""
echo "STEP 2: VERIFY SUBSCRIPTIONS ARE READY"
echo "---------------------------------------"
echo "Opening Subscriptions page..."
sleep 1
open "https://appstoreconnect.apple.com/apps/6754500922/appstore/ios/iap/subscriptions"

echo ""
echo "Verify both subscriptions show:"
echo "✓ everyday_christian_ios_yearly_sub - Ready for Sale"
echo "✓ everyday_christian_ios_monthly_sub - Ready for Sale"
echo ""
echo "Press ENTER to continue..."
read -r

# Step 3: Testing Instructions
echo ""
echo "STEP 3: TESTING ON DEVICE"
echo "-------------------------"
echo ""
echo "ON YOUR iPHONE:"
echo "1. Settings > App Store > Tap your Apple ID > Sign Out"
echo "   (ONLY sign out of App Store, NOT iCloud!)"
echo ""
echo "2. Open TestFlight app"
echo ""
echo "3. Install 'Everyday Christian' build 2"
echo ""
echo "4. Open the app and go to Subscriptions"
echo ""
echo "5. Tap a subscription plan"
echo ""
echo "6. When prompted for Apple ID, enter:"
echo "   Email: testuser+everyday1@gmail.com"
echo "   Password: TestPass123!"
echo ""
echo "7. You should see 'Environment: Sandbox' banner"
echo ""
echo "8. Complete the purchase (no real charge)"
echo ""
echo "9. Verify subscription activates in app"
echo ""
echo "=========================================="
echo ""
echo "SANDBOX ACCOUNT CREDENTIALS:"
echo "Email: testuser+everyday1@gmail.com"
echo "Password: TestPass123!"
echo ""
echo "Save these credentials for testing!"
echo "=========================================="
echo ""
echo "Need help? See: ios/fastlane/SANDBOX_TESTING_GUIDE.md"
