#!/usr/bin/env python3
"""Fix Subscription GROUP localizations"""
import jwt
import time
import requests
import json
import sys

KEY_ID = "T9L7G79827"
ISSUER_ID = "e5761715-cdcf-42cb-b50e-09977a5c8279"
KEY_FILE = "/Users/kcdacre8tor/private_keys/AuthKey_T9L7G79827.p8"
APP_ID = "6754500922"
API_BASE = "https://api.appstoreconnect.apple.com/v1"

def generate_token():
    with open(KEY_FILE, 'r') as f:
        private_key = f.read()
    
    payload = {
        'iss': ISSUER_ID,
        'exp': int(time.time()) + 1200,
        'aud': 'appstoreconnect-v1'
    }
    
    header = {'kid': KEY_ID, 'typ': 'JWT', 'alg': 'ES256'}
    return jwt.encode(payload, private_key, algorithm='ES256', headers=header)

def api_get(endpoint, params=None):
    token = generate_token()
    headers = {
        'Authorization': f'Bearer {token}',
        'Content-Type': 'application/json'
    }
    
    url = f"{API_BASE}{endpoint}"
    response = requests.get(url, headers=headers, params=params)
    
    if response.status_code != 200:
        print(f"❌ Error {response.status_code}: {response.text}")
        return None
    
    return response.json()

def api_patch(endpoint, data):
    token = generate_token()
    headers = {
        'Authorization': f'Bearer {token}',
        'Content-Type': 'application/json'
    }
    
    url = f"{API_BASE}{endpoint}"
    response = requests.patch(url, headers=headers, json=data)
    
    if response.status_code not in [200, 201]:
        print(f"❌ Error {response.status_code}: {response.text}")
        return None
    
    return response.json()

def api_delete(endpoint):
    token = generate_token()
    headers = {
        'Authorization': f'Bearer {token}',
        'Content-Type': 'application/json'
    }
    
    url = f"{API_BASE}{endpoint}"
    response = requests.delete(url, headers=headers)
    
    if response.status_code not in [200, 204]:
        print(f"❌ Error {response.status_code}: {response.text}")
        return False
    
    return True

def api_post(endpoint, data):
    token = generate_token()
    headers = {
        'Authorization': f'Bearer {token}',
        'Content-Type': 'application/json'
    }
    
    url = f"{API_BASE}{endpoint}"
    response = requests.post(url, headers=headers, json=data)
    
    if response.status_code not in [200, 201]:
        print(f"❌ Error {response.status_code}: {response.text}")
        return None
    
    return response.json()

print("🔍 Querying Subscription GROUP Localizations...")
print()

# Get subscription groups
data = api_get(
    f"/apps/{APP_ID}/subscriptionGroups",
    params={'include': 'subscriptionGroupLocalizations'}
)

if not data or not data.get('data'):
    print("❌ No subscription groups found")
    sys.exit(1)

group = data['data'][0]  # First group
group_id = group['id']
group_name = group['attributes']['referenceName']

print(f"📦 Subscription Group: {group_name}")
print(f"   Group ID: {group_id}")
print()

# Get group localizations
if data.get('included'):
    locs = [item for item in data['included'] if item['type'] == 'subscriptionGroupLocalizations']
    
    print(f"🌍 Found {len(locs)} group localization(s):")
    print()
    
    for loc in locs:
        attrs = loc['attributes']
        print(f"   Locale: {attrs['locale']}")
        print(f"   Name: {attrs.get('name', 'N/A')}")
        print(f"   State: {attrs.get('state', 'N/A')}")
        print(f"   ID: {loc['id']}")
        
        # If REJECTED, delete and recreate
        if attrs.get('state') == 'REJECTED':
            print(f"   ⚠️  REJECTED - Will delete and recreate")
            
            # Delete
            if api_delete(f"/subscriptionGroupLocalizations/{loc['id']}"):
                print(f"   ✅ Deleted")
                
                # Recreate with correct name
                new_name = "Premium Subscription" if attrs['locale'] == 'en-US' else "Suscripción Premium"
                
                payload = {
                    'data': {
                        'type': 'subscriptionGroupLocalizations',
                        'attributes': {
                            'name': new_name,
                            'locale': attrs['locale']
                        },
                        'relationships': {
                            'subscriptionGroup': {
                                'data': {
                                    'type': 'subscriptionGroups',
                                    'id': group_id
                                }
                            }
                        }
                    }
                }
                
                result = api_post('/subscriptionGroupLocalizations', payload)
                if result:
                    print(f"   ✅ Recreated with name: {new_name}")
                else:
                    print(f"   ❌ Failed to recreate")
        print()

print("✅ Group localizations processed!")
