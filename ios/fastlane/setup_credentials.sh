#!/bin/bash
# Interactive Fastlane Credentials Setup

echo "🔐 Fastlane Credentials Setup"
echo "=============================="
echo ""

# Check if .env already exists
if [ -f ".env" ]; then
    echo "⚠️  .env file already exists!"
    read -p "Overwrite? (y/N): " overwrite
    if [[ ! $overwrite =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
fi

echo "📧 Step 1: Apple ID"
echo "-------------------"
read -p "Enter your Apple ID email: " apple_id

echo ""
echo "🔑 Step 2: App-Specific Password"
echo "--------------------------------"
echo "You need to generate an app-specific password:"
echo "1. Visit: https://appleid.apple.com"
echo "2. Security → App-Specific Passwords"
echo "3. Generate new password named 'Fastlane'"
echo ""
read -p "Enter app-specific password (xxxx-xxxx-xxxx-xxxx): " app_password

echo ""
echo "🏢 Step 3: Team ID"
echo "-----------------"
echo "Get your Team ID from App Store Connect:"
echo "1. Visit: https://appstoreconnect.apple.com"
echo "2. Click your name → View Membership"
echo "3. Copy Team ID (10 digits)"
echo ""
read -p "Enter Team ID: " team_id

# Create .env file
cat > .env << ENVEOF
# Fastlane Environment Variables
# Generated: $(date)

# App Store Connect Credentials
FASTLANE_USER=$apple_id
FASTLANE_PASSWORD=$app_password
FASTLANE_ITC_TEAM_ID=$team_id
FASTLANE_TEAM_ID=$team_id

# App Information
FASTLANE_APP_IDENTIFIER=com.elev8tion.everydaychristian
ENVEOF

# Update Appfile
cat > Appfile << APPEOF
# App Store Connect credentials
apple_id("$apple_id")
itc_team_id("$team_id")
team_id("$team_id")
app_identifier("com.elev8tion.everydaychristian")
APPEOF

echo ""
echo "✅ Configuration complete!"
echo ""
echo "Files created/updated:"
echo "  - fastlane/.env"
echo "  - fastlane/Appfile"
echo ""
echo "🧪 Test your setup:"
echo "  cd /Users/kcdacre8tor/thereal-everyday-christian/ios"
echo "  bash fastlane/verify_setup.sh"
echo ""
echo "🚀 Or deploy immediately:"
echo "  fastlane beta"
echo ""
