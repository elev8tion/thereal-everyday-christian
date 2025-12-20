#!/bin/bash
# Query subscriptions via App Store Connect API

set -e

KEY_ID="T9L7G79827"
ISSUER_ID="e5761715-cdcf-42cb-b50e-09977a5c8279"
KEY_FILE="$HOME/private_keys/AuthKey_T9L7G79827.p8"
API_BASE="https://api.appstoreconnect.apple.com/v1"

echo "🔍 Querying App Store Connect API..."
echo ""

# Generate JWT token
TOKEN=$(python3 << PYTHON
import jwt
import time

with open("${KEY_FILE}", 'r') as f:
    private_key = f.read()

payload = {
    'iss': '${ISSUER_ID}',
    'exp': int(time.time()) + 1200,
    'aud': 'appstoreconnect-v1'
}

header = {'kid': '${KEY_ID}', 'typ': 'JWT', 'alg': 'ES256'}
token = jwt.encode(payload, private_key, algorithm='ES256', headers=header)
print(token)
PYTHON
)

# Get app ID
echo "1️⃣  Getting app information..."
APP_RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN" \
    "${API_BASE}/apps?filter[bundleId]=com.elev8tion.everydaychristian")

APP_ID=$(echo "$APP_RESPONSE" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data['data'][0]['id'] if data.get('data') else '')")

if [ -z "$APP_ID" ]; then
    echo "❌ Error: Could not find app"
    echo "$APP_RESPONSE" | python3 -m json.tool
    exit 1
fi

echo "✅ Found app ID: $APP_ID"
echo ""

# Get subscriptions
echo "2️⃣  Getting subscription groups..."
SUBS_RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN" \
    "${API_BASE}/subscriptionGroups?filter[app]=$APP_ID&include=subscriptions")

echo "$SUBS_RESPONSE" | python3 << 'PYTHON'
import sys
import json

try:
    data = json.load(sys.stdin)
    
    if not data.get('data'):
        print("❌ No subscription groups found")
        sys.exit(1)
    
    print(f"✅ Found {len(data['data'])} subscription group(s)")
    print()
    
    for group in data['data']:
        print(f"📦 Subscription Group:")
        print(f"   ID: {group['id']}")
        print(f"   Reference Name: {group['attributes'].get('referenceName', 'N/A')}")
        print()
    
    # Get included subscriptions
    if data.get('included'):
        print(f"💰 Subscriptions ({len(data['included'])} products):")
        print()
        for sub in data['included']:
            if sub['type'] == 'subscriptions':
                attrs = sub['attributes']
                print(f"   Product ID: {attrs.get('productId', 'N/A')}")
                print(f"   Name: {attrs.get('name', 'N/A')}")
                print(f"   State: {attrs.get('state', 'N/A')}")
                print(f"   Review Note: {attrs.get('reviewNote', 'N/A')[:100]}...")
                print()
    
    # Save for further use
    with open('/tmp/asc_subs.json', 'w') as f:
        json.dump(data, f, indent=2)
    
    print("📁 Full response saved to: /tmp/asc_subs.json")
    
except Exception as e:
    print(f"❌ Error parsing response: {e}")
    print(sys.stdin.read())
PYTHON

echo ""
echo "✅ Query complete!"
