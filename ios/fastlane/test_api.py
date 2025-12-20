#!/usr/bin/env python3
import jwt
import time
import requests
import json

KEY_ID = "T9L7G79827"
ISSUER_ID = "e5761715-cdcf-42cb-b50e-09977a5c8279"
KEY_FILE = "/Users/kcdacre8tor/private_keys/AuthKey_T9L7G79827.p8"

# Read private key
with open(KEY_FILE, 'r') as f:
    private_key = f.read()

# Generate token
payload = {
    'iss': ISSUER_ID,
    'exp': int(time.time()) + 1200,
    'aud': 'appstoreconnect-v1'
}

header = {
    'kid': KEY_ID,
    'typ': 'JWT',
    'alg': 'ES256'
}

token = jwt.encode(payload, private_key, algorithm='ES256', headers=header)

# Query API
print("🔍 Querying App Store Connect API...")
print()

headers = {
    'Authorization': f'Bearer {token}',
    'Content-Type': 'application/json'
}

# Get app
print("1️⃣  Getting app...")
response = requests.get(
    'https://api.appstoreconnect.apple.com/v1/apps?filter[bundleId]=com.elev8tion.everydaychristian',
    headers=headers
)

if response.status_code != 200:
    print(f"❌ Error: {response.status_code}")
    print(response.text)
    exit(1)

app_data = response.json()
if not app_data.get('data'):
    print("❌ App not found")
    exit(1)

app_id = app_data['data'][0]['id']
print(f"✅ Found app: {app_data['data'][0]['attributes']['name']}")
print(f"   App ID: {app_id}")
print()

# Get subscription groups
print("2️⃣  Getting subscription groups...")
response = requests.get(
    f'https://api.appstoreconnect.apple.com/v1/subscriptionGroups?filter[app]={app_id}&include=subscriptionGroupLocalizations,subscriptions',
    headers=headers
)

if response.status_code != 200:
    print(f"❌ Error: {response.status_code}")
    print(response.text)
    exit(1)

sub_data = response.json()

print(f"✅ Found {len(sub_data.get('data', []))} subscription group(s)")
print()

# Display subscription groups
for group in sub_data.get('data', []):
    print(f"📦 Group: {group['attributes']['referenceName']}")
    print(f"   ID: {group['id']}")
    print()

# Get subscriptions
if sub_data.get('included'):
    subs = [item for item in sub_data['included'] if item['type'] == 'subscriptions']
    print(f"💰 Found {len(subs)} subscription(s):")
    print()
    
    for sub in subs:
        attrs = sub['attributes']
        print(f"   📱 Product ID: {attrs.get('productId', 'N/A')}")
        print(f"      Name: {attrs.get('name', 'N/A')}")
        print(f"      State: {attrs.get('state', 'N/A')}")
        print(f"      Subscription ID: {sub['id']}")
        
        # Get localizations for this subscription
        print(f"      Getting localizations...")
        loc_response = requests.get(
            f"https://api.appstoreconnect.apple.com/v1/subscriptions/{sub['id']}/subscriptionLocalizations",
            headers=headers
        )
        
        if loc_response.status_code == 200:
            loc_data = loc_response.json()
            for loc in loc_data.get('data', []):
                locale = loc['attributes']['locale']
                name = loc['attributes'].get('name', '')
                desc = loc['attributes'].get('description', '')
                print(f"         🌍 {locale}:")
                print(f"            Name: {name}")
                print(f"            Description: {desc}")
                print(f"            Localization ID: {loc['id']}")
        print()

# Save for reference
with open('/tmp/subscriptions_full.json', 'w') as f:
    json.dump({
        'app': app_data,
        'subscriptions': sub_data
    }, f, indent=2)

print("✅ Query complete!")
print("📁 Full data saved to: /tmp/subscriptions_full.json")
