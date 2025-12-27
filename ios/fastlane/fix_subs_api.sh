#!/bin/bash
# Direct App Store Connect API script to fix subscription descriptions

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

# Get subscription groups
echo "📦 Getting subscription groups..."
GROUPS_RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN" \
  "https://api.appstoreconnect.apple.com/v1/apps/$APP_ID/subscriptionGroups")

echo "$GROUPS_RESPONSE" | python3 - <<'PYTHON_SCRIPT'
import sys
import json
import os

token = os.environ['TOKEN']
data = json.load(sys.stdin)

for group in data['data']:
    group_id = group['id']
    group_name = group['attributes']['referenceName']
    print(f"\n🔍 Group: {group_name}")

    # Get subscriptions
    import subprocess
    subs_cmd = f'curl -s -H "Authorization: Bearer {token}" "https://api.appstoreconnect.apple.com/v1/subscriptionGroups/{group_id}/subscriptions"'
    subs_response = subprocess.check_output(subs_cmd, shell=True)
    subs_data = json.loads(subs_response)

    for sub in subs_data['data']:
        sub_id = sub['id']
        product_id = sub['attributes']['productId']
        print(f"   📱 {product_id}")

        # Get localizations
        locs_cmd = f'curl -s -H "Authorization: Bearer {token}" "https://api.appstoreconnect.apple.com/v1/subscriptions/{sub_id}/subscriptionLocalizations"'
        locs_response = subprocess.check_output(locs_cmd, shell=True)
        locs_data = json.loads(locs_response)

        is_yearly = 'yearly' in product_id

        descriptions = {
            'en-US': '150 messages monthly, auto-renews yearly' if is_yearly else '150 messages monthly, auto-renews monthly',
            'es-MX': '150 mensajes mensuales, renovación automática anual' if is_yearly else '150 mensajes mensuales, renovación automática mensual',
            'es-ES': '150 mensajes mensuales, renovación automática anual' if is_yearly else '150 mensajes mensuales, renovación automática mensual'
        }

        for loc in locs_data['data']:
            loc_id = loc['id']
            locale = loc['attributes']['locale']
            current_desc = loc['attributes'].get('description', '')

            if locale not in descriptions:
                continue

            new_desc = descriptions[locale]

            if current_desc == new_desc:
                print(f"      ✅ {locale}: Already correct")
                continue

            print(f"      🔧 {locale}: {current_desc} → {new_desc}")

            # Update
            update_json = json.dumps({
                "data": {
                    "type": "subscriptionLocalizations",
                    "id": loc_id,
                    "attributes": {
                        "description": new_desc
                    }
                }
            })

            update_cmd = f'''curl -s -X PATCH \
              -H "Authorization: Bearer {token}" \
              -H "Content-Type: application/json" \
              -d '{update_json}' \
              "https://api.appstoreconnect.apple.com/v1/subscriptionLocalizations/{loc_id}"'''

            result = subprocess.check_output(update_cmd, shell=True)
            print(f"      ✅ {locale}: Updated!")

print("\n✅ All subscription descriptions updated!")
PYTHON_SCRIPT

export TOKEN
