#!/bin/bash
echo "🔍 To find your Issuer ID:"
echo "1. Visit: https://appstoreconnect.apple.com/access/api"
echo "2. Look for 'Issuer ID' at the top (UUID format)"
echo "3. Copy it and paste when prompted"
echo ""
read -p "Enter your Issuer ID: " issuer_id

cat > api_key_config.rb << RBEOF
# App Store Connect API Key Configuration
# Generated: $(date)

def app_store_connect_api_key_config
  {
    key_id: "T9L7G79827",
    issuer_id: "${issuer_id}",
    key_filepath: "#{Dir.home}/private_keys/AuthKey_T9L7G79827.p8",
    duration: 1200,
    in_house: false
  }
end
RBEOF

echo ""
echo "✅ Configuration saved to: fastlane/api_key_config.rb"
echo ""
echo "Next, run: bash fastlane/check_rejections.sh"
