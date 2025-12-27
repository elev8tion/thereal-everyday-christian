#!/bin/bash
# Submit subscriptions for review using App Store Connect API
# Based on official API spec: /v1/subscriptionSubmissions

set -e

KEY_ID="T9L7G79827"
ISSUER_ID="e5761715-cdcf-42cb-b50e-09977a5c8279"
KEY_FILE="$HOME/private_keys/AuthKey_T9L7G79827.p8"

echo "🔐 Generating JWT token..."

# Generate JWT token
TOKEN=$(python3 - <<EOF
import jwt
import time

with open("$KEY_FILE", 'r') as f:
    private_key = f.read()

payload = {
    'iss': "$ISSUER_ID",
    'exp': int(time.time()) + 1200,
    'aud': 'appstoreconnect-v1'
}

headers = {
    'kid': "$KEY_ID",
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

APP_ID=$(echo $APP_RESPONSE | python3 -c "import sys, json; data=json.load(sys.stdin); print(data['data'][0]['id'] if data.get('data') else exit(1))" 2>/dev/null || echo "")

if [ -z "$APP_ID" ]; then
  echo "❌ Could not find app!"
  exit 1
fi

echo "✅ App ID: $APP_ID"

# Get subscription groups and subscriptions
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
data = json.load(sys.stdin)

if not data.get('data'):
    print("❌ No subscription groups found!")
    sys.exit(1)

subscription_ids = []

for group in data['data']:
    group_id = group['id']
    group_name = group['attributes']['referenceName']
    print(f"\n📦 Subscription Group: {group_name}")

    # Get subscriptions in this group
    subs_cmd = f'curl -s -H "Authorization: Bearer {token}" "https://api.appstoreconnect.apple.com/v1/subscriptionGroups/{group_id}/subscriptions"'
    subs_response = subprocess.check_output(subs_cmd, shell=True)
    subs_data = json.loads(subs_response)

    for sub in subs_data.get('data', []):
        sub_id = sub['id']
        product_id = sub['attributes']['productId']
        state = sub['attributes'].get('state', 'UNKNOWN')
        print(f"   📱 {product_id}")
        print(f"      State: {state}")
        subscription_ids.append({
            'id': sub_id,
            'product_id': product_id,
            'state': state
        })

if not subscription_ids:
    print("\n❌ No subscriptions found!")
    sys.exit(1)

print(f"\n📤 Submitting {len(subscription_ids)} subscription(s) for review...")

# Submit each subscription for review
# API: POST /v1/subscriptionSubmissions
for sub in subscription_ids:
    sub_id = sub['id']
    product_id = sub['product_id']
    state = sub['state']

    # Only submit if not already in review
    if state in ['WAITING_FOR_REVIEW', 'IN_REVIEW', 'APPROVED']:
        print(f"   ⏭️  {product_id}: Already {state}")
        continue

    submit_json = json.dumps({
        "data": {
            "type": "subscriptionSubmissions",
            "relationships": {
                "subscription": {
                    "data": {
                        "type": "subscriptions",
                        "id": sub_id
                    }
                }
            }
        }
    })

    submit_cmd = f'''curl -s -X POST \
      -H "Authorization: Bearer {token}" \
      -H "Content-Type: application/json" \
      -d '{submit_json}' \
      "https://api.appstoreconnect.apple.com/v1/subscriptionSubmissions"'''

    try:
        result = subprocess.check_output(submit_cmd, shell=True, stderr=subprocess.STDOUT)
        result_data = json.loads(result) if result else {}

        if 'errors' in result_data:
            error_msg = result_data['errors'][0].get('detail', 'Unknown error')
            print(f"   ⚠️  {product_id}: {error_msg}")
        else:
            print(f"   ✅ {product_id}: Submitted for review!")
    except subprocess.CalledProcessError as e:
        print(f"   ❌ {product_id}: API error")
        continue

print("\n🎉 Subscription submission complete!")
print("\n📋 Next steps:")
print("   1. Subscriptions are now in review queue")
print("   2. Go to App Store Connect → In-App Purchases → Subscriptions")
print("   3. Verify status changed to 'Waiting for Review'")
print("   4. Now you can submit your app version for review")
PYTHON_SCRIPT

export TOKEN
