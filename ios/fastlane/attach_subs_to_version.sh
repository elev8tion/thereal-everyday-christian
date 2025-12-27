#!/bin/bash
# Attach subscriptions to app version using App Store Connect API

set -e

KEY_ID="T9L7G79827"
ISSUER_ID="e5761715-cdcf-42cb-b50e-09977a5c8279"
KEY_FILE="$HOME/private_keys/AuthKey_T9L7G79827.p8"

echo "🔐 Generating JWT token..."

# Generate JWT token using Python
TOKEN=$(python3 - <<EOF
import jwt
import time
from pathlib import Path

key_id = "$KEY_ID"
issuer_id = "$ISSUER_ID"
key_file = "$KEY_FILE"

with open(key_file, 'r') as f:
    private_key = f.read()

payload = {
    'iss': issuer_id,
    'exp': int(time.time()) + 1200,
    'aud': 'appstoreconnect-v1'
}

headers = {
    'kid': key_id,
    'typ': 'JWT'
}

token = jwt.encode(payload, private_key, algorithm='ES256', headers=headers)
print(token)
EOF
)

echo "✅ Token generated"

# Get app ID
echo "📱 Finding app..."
APP_RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN" \
  "https://api.appstoreconnect.apple.com/v1/apps?filter[bundleId]=com.elev8tion.everydaychristian")

APP_ID=$(echo $APP_RESPONSE | python3 -c "import sys, json; print(json.load(sys.stdin)['data'][0]['id'])")
echo "✅ App ID: $APP_ID"

# Get the editable app store version (Prepare for Submission)
echo "📦 Getting editable app version..."
VERSION_RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN" \
  "https://api.appstoreconnect.apple.com/v1/apps/$APP_ID/appStoreVersions?filter[appStoreState]=PREPARE_FOR_SUBMISSION")

echo "$VERSION_RESPONSE" | python3 - <<PYTHON_SCRIPT
import sys
import json

data = json.load(sys.stdin)

if not data['data']:
    print("❌ No version in 'Prepare for Submission' state found!")
    print("   Make sure you have an app version ready for submission.")
    sys.exit(1)

version = data['data'][0]
version_id = version['id']
version_string = version['attributes']['versionString']
state = version['attributes']['appStoreState']

print(f"✅ Found version: {version_string} ({state})")
print(f"   Version ID: {version_id}")

# Save version_id for next step
with open('/tmp/version_id.txt', 'w') as f:
    f.write(version_id)
PYTHON_SCRIPT

VERSION_ID=$(cat /tmp/version_id.txt)

# Get subscription groups
echo ""
echo "🔍 Getting subscriptions..."
GROUPS_RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN" \
  "https://api.appstoreconnect.apple.com/v1/apps/$APP_ID/subscriptionGroups")

echo "$GROUPS_RESPONSE" | python3 - <<'PYTHON_SCRIPT'
import sys
import json
import os
import subprocess

token = os.environ['TOKEN']
version_id = os.environ['VERSION_ID']
data = json.load(sys.stdin)

subscription_ids = []

for group in data['data']:
    group_id = group['id']
    group_name = group['attributes']['referenceName']
    print(f"\n📦 Subscription Group: {group_name}")

    # Get subscriptions
    subs_cmd = f'curl -s -H "Authorization: Bearer {token}" "https://api.appstoreconnect.apple.com/v1/subscriptionGroups/{group_id}/subscriptions"'
    subs_response = subprocess.check_output(subs_cmd, shell=True)
    subs_data = json.loads(subs_response)

    for sub in subs_data['data']:
        sub_id = sub['id']
        product_id = sub['attributes']['productId']
        print(f"   📱 {product_id} (ID: {sub_id})")
        subscription_ids.append(sub_id)

if not subscription_ids:
    print("\n❌ No subscriptions found!")
    sys.exit(1)

print(f"\n📎 Attaching {len(subscription_ids)} subscription(s) to version...")

# Attach subscriptions to the version
# API: POST /v1/appStoreVersions/{id}/relationships/subscriptions
for sub_id in subscription_ids:
    attach_json = json.dumps({
        "data": [
            {
                "type": "subscriptions",
                "id": sub_id
            }
        ]
    })

    attach_cmd = f'''curl -s -X POST \
      -H "Authorization: Bearer {token}" \
      -H "Content-Type: application/json" \
      -d '{attach_json}' \
      "https://api.appstoreconnect.apple.com/v1/appStoreVersions/{version_id}/relationships/subscriptions"'''

    try:
        result = subprocess.check_output(attach_cmd, shell=True, stderr=subprocess.STDOUT)
        result_data = json.loads(result) if result else {}

        # Check if there are errors
        if 'errors' in result_data:
            error_msg = result_data['errors'][0].get('detail', 'Unknown error')
            if 'already exists' in error_msg.lower():
                print(f"   ✅ {sub_id}: Already attached")
            else:
                print(f"   ⚠️  {sub_id}: {error_msg}")
        else:
            print(f"   ✅ {sub_id}: Attached!")
    except subprocess.CalledProcessError as e:
        print(f"   ⚠️  {sub_id}: API error")
        continue

print("\n🎉 Done!")
print("\n📋 Next steps:")
print("   1. Go to App Store Connect and verify subscriptions are attached")
print("   2. Submit subscription localizations for review if needed")
print("   3. Submit app version for review")
PYTHON_SCRIPT

export TOKEN
export VERSION_ID
