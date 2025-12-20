#!/usr/bin/env python3
"""
Terminal-based subscription localization fixer
Uses correct App Store Connect API endpoints
"""
import jwt
import time
import requests
import json
import sys

# Configuration
KEY_ID = "T9L7G79827"
ISSUER_ID = "e5761715-cdcf-42cb-b50e-09977a5c8279"
KEY_FILE = "/Users/kcdacre8tor/private_keys/AuthKey_T9L7G79827.p8"
APP_ID = "6754500922"  # From earlier query
API_BASE = "https://api.appstoreconnect.apple.com/v1"

def generate_token():
    """Generate JWT token"""
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
    """Make GET request to API"""
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
    """Make PATCH request to API"""
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

def query_subscriptions():
    """Query all subscriptions for the app"""
    print("🔍 Querying subscriptions...")
    print()
    
    # Get subscription groups with included subscriptions
    data = api_get(
        f"/apps/{APP_ID}/subscriptionGroups",
        params={'include': 'subscriptions,subscriptionGroupLocalizations'}
    )
    
    if not data:
        return None
    
    # Extract subscriptions from included data
    subscriptions = [item for item in data.get('included', []) if item['type'] == 'subscriptions']
    
    print(f"✅ Found {len(subscriptions)} subscription(s)")
    print()
    
    results = []
    for sub in subscriptions:
        sub_id = sub['id']
        attrs = sub['attributes']
        
        print(f"📱 Product ID: {attrs.get('productId')}")
        print(f"   Name: {attrs.get('name')}")
        print(f"   State: {attrs.get('state')}")
        print(f"   Subscription ID: {sub_id}")
        
        # Get localizations
        loc_data = api_get(f"/subscriptions/{sub_id}/subscriptionLocalizations")
        
        if loc_data:
            localizations = []
            for loc in loc_data.get('data', []):
                loc_attrs = loc['attributes']
                localizations.append({
                    'id': loc['id'],
                    'locale': loc_attrs['locale'],
                    'name': loc_attrs.get('name', ''),
                    'description': loc_attrs.get('description', ''),
                    'state': loc_attrs.get('state')
                })
                
                print(f"      🌍 {loc_attrs['locale']}: {loc_attrs.get('name', 'NO NAME')}")
                print(f"         Description: {loc_attrs.get('description', 'NO DESCRIPTION')}")
                print(f"         State: {loc_attrs.get('state')}")
                print(f"         Localization ID: {loc['id']}")
            
            results.append({
                'subscription_id': sub_id,
                'product_id': attrs.get('productId'),
                'name': attrs.get('name'),
                'localizations': localizations
            })
        
        print()
    
    return results

def update_localization(loc_id, name, description):
    """Update a subscription localization"""
    payload = {
        'data': {
            'type': 'subscriptionLocalizations',
            'id': loc_id,
            'attributes': {
                'name': name,
                'description': description
            }
        }
    }
    
    return api_patch(f"/subscriptionLocalizations/{loc_id}", payload)

def main():
    print("=" * 70)
    print("🔧 SUBSCRIPTION LOCALIZATION FIXER - Terminal Mode")
    print("=" * 70)
    print()
    
    # Query current state
    subs = query_subscriptions()
    
    if not subs:
        print("❌ Failed to query subscriptions")
        sys.exit(1)
    
    # Save current state
    with open('/tmp/current_subscriptions.json', 'w') as f:
        json.dump(subs, f, indent=2)
    
    print("📁 Current state saved to: /tmp/current_subscriptions.json")
    print()
    
    # Show what needs fixing
    print("=" * 70)
    print("🛠️  READY TO FIX")
    print("=" * 70)
    print()
    print("Run with 'fix' argument to update localizations:")
    print(f"  python3 {__file__} fix")
    print()

if __name__ == '__main__':
    if len(sys.argv) > 1 and sys.argv[1] == 'fix':
        print("Fix mode not yet implemented - manual review required first")
    else:
        main()

# Correct localization templates
TEMPLATES = {
    'en-US': {
        'yearly': {
            'name': 'Yearly Premium',
            'description': 'Unlimited access, auto-renews yearly'
        },
        'monthly': {
            'name': 'Monthly Premium',  
            'description': 'Unlimited access, auto-renews monthly'
        }
    },
    'es-MX': {
        'yearly': {
            'name': 'Premium Anual',
            'description': 'Acceso ilimitado, renovación anual'
        },
        'monthly': {
            'name': 'Premium Mensual',
            'description': 'Acceso ilimitado, renovación mensual'
        }
    },
    'es-ES': {
        'yearly': {
            'name': 'Premium Anual',
            'description': 'Acceso ilimitado, renovación anual'
        },
        'monthly': {
            'name': 'Premium Mensual',
            'description': 'Acceso ilimitado, renovación mensual'
        }
    }
}

def fix_subscriptions():
    """Fix all subscription localizations"""
    print("=" * 70)
    print("🔧 FIXING SUBSCRIPTION LOCALIZATIONS")
    print("=" * 70)
    print()
    
    # Load current state
    with open('/tmp/current_subscriptions.json', 'r') as f:
        subs = json.load(f)
    
    for sub in subs:
        product_id = sub['product_id']
        is_yearly = 'yearly' in product_id.lower()
        period = 'yearly' if is_yearly else 'monthly'
        
        print(f"📱 Fixing: {product_id}")
        print()
        
        for loc in sub['localizations']:
            locale = loc['locale']
            loc_id = loc['id']
            current_state = loc['state']
            
            # Get template
            if locale in TEMPLATES and period in TEMPLATES[locale]:
                template = TEMPLATES[locale][period]
                new_name = template['name']
                new_desc = template['description']
                
                print(f"   🌍 {locale} ({current_state}):")
                print(f"      Old: {loc['name']} - {loc['description']}")
                print(f"      New: {new_name} - {new_desc}")
                
                # Update
                result = update_localization(loc_id, new_name, new_desc)
                
                if result:
                    print(f"      ✅ Updated successfully!")
                else:
                    print(f"      ❌ Update failed")
                print()
            else:
                print(f"   ⚠️  {locale}: No template found, skipping")
                print()
    
    print("=" * 70)
    print("✅ FIX COMPLETE!")
    print("=" * 70)
    print()
    print("Next steps:")
    print("1. Verify changes in App Store Connect")
    print("2. Resubmit for review")
    print("3. Wait 1-3 business days")

if __name__ == '__main__':
    if len(sys.argv) > 1 and sys.argv[1] == 'fix':
        fix_subscriptions()
    else:
        main()
