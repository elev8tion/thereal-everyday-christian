#!/bin/bash
# Quick action script to open all necessary pages

echo "🔧 Opening App Store Connect for subscription localization fix..."
echo ""
echo "Opening pages in browser..."
echo ""

# Open App Store Connect
open "https://appstoreconnect.apple.com/apps"

echo "✅ App Store Connect opened"
echo ""
echo "📋 TODO:"
echo "1. Click 'Everyday Christian'"
echo "2. Go to: Features → In-App Purchases → Subscriptions tab"
echo "3. Edit BOTH subscriptions (yearly and monthly)"
echo "4. Update localization fields with required text"
echo "5. Click 'Resubmit for Review'"
echo ""
echo "📖 See detailed instructions in:"
echo "   ios/SUBSCRIPTION_LOCALIZATION_FIX.md"
echo ""
echo "⏱️  Time needed: ~10-15 minutes"
echo ""
