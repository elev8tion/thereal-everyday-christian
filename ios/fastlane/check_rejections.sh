#!/bin/bash
# Check App Store rejection details

echo "🔍 Checking App Store Rejections..."
echo "===================================="
echo ""

cd "$(dirname "$0")/.."

# Check if API key config exists
if [ ! -f "fastlane/api_key_config.rb" ]; then
    echo "⚠️  API key not configured yet!"
    echo ""
    echo "Run this first:"
    echo "  cd /Users/kcdacre8tor/thereal-everyday-christian/ios/fastlane"
    echo "  bash get_issuer_id.sh"
    echo ""
    exit 1
fi

# Source the config to get issuer_id
source <(grep "issuer_id:" fastlane/api_key_config.rb | sed 's/.*issuer_id: "\(.*\)".*/ISSUER_ID=\1/')

echo "📱 App: Everyday Christian"
echo "📦 Bundle ID: com.elev8tion.everydaychristian"
echo "🔑 Key ID: T9L7G79827"
echo ""

# Get app info and rejections
echo "Querying App Store Connect..."
echo ""

fastlane run app_store_connect_api_key \
  key_id:"T9L7G79827" \
  issuer_id:"${ISSUER_ID}" \
  key_filepath:"${HOME}/private_keys/AuthKey_T9L7G79827.p8"

echo ""
echo "Getting app status and rejection details..."
fastlane run deliver \
  app_identifier:"com.elev8tion.everydaychristian" \
  api_key_path:"fastlane/api_key_config.rb" \
  skip_binary_upload:true \
  skip_screenshots:true \
  skip_metadata:true \
  force:true

echo ""
echo "✅ Check complete!"
