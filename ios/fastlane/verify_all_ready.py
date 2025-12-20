#!/usr/bin/env python3
"""
Verify ALL subscription localizations are ready for App Store submission.

This script checks both:
1. Individual subscription product localizations (6 total)
2. Subscription group localizations (3 total)

Run this AFTER manually fixing the Spanish (Mexico) group localization.
"""

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

print("═" * 70)
print("  🔍 FINAL VERIFICATION - ALL SUBSCRIPTION LOCALIZATIONS")
print("═" * 70)
print()

all_ready = True

# ─────────────────────────────────────────────────────────────────────────
# 1. Check Individual Subscription Product Localizations
# ─────────────────────────────────────────────────────────────────────────

print("1️⃣  INDIVIDUAL SUBSCRIPTION LOCALIZATIONS:")
print()

# Get subscription groups to find products
groups_data = api_get(
    f"/apps/{APP_ID}/subscriptionGroups",
    params={'include': 'subscriptions'}
)

if not groups_data or not groups_data.get('data'):
    print("❌ Could not fetch subscription groups")
    sys.exit(1)

group_id = groups_data['data'][0]['id']

# Get all products in the group
if groups_data.get('included'):
    products = [item for item in groups_data['included'] if item['type'] == 'subscriptions']

    for product in products:
        product_id = product['id']
        product_name = product['attributes']['name']
        reference_name = product['attributes']['productId']

        print(f"  📦 {product_name} ({reference_name})")

        # Get localizations for this product
        loc_data = api_get(
            f"/subscriptions/{product_id}/subscriptionLocalizations"
        )

        if loc_data and loc_data.get('data'):
            for loc in loc_data['data']:
                attrs = loc['attributes']
                state = attrs.get('state', 'UNKNOWN')

                if state == 'PREPARE_FOR_SUBMISSION':
                    icon = '✅'
                elif state == 'REJECTED':
                    icon = '❌'
                    all_ready = False
                else:
                    icon = '⚠️'
                    all_ready = False

                print(f"     {icon} {attrs['locale']}: \"{attrs['name']}\" - {state}")
        print()

# ─────────────────────────────────────────────────────────────────────────
# 2. Check Subscription Group Localizations
# ─────────────────────────────────────────────────────────────────────────

print("2️⃣  SUBSCRIPTION GROUP LOCALIZATIONS:")
print()

group_data = api_get(
    f"/apps/{APP_ID}/subscriptionGroups",
    params={'include': 'subscriptionGroupLocalizations'}
)

if group_data and group_data.get('data'):
    group = group_data['data'][0]
    group_name = group['attributes']['referenceName']

    print(f"  📦 {group_name}")

    if group_data.get('included'):
        locs = [item for item in group_data['included']
                if item['type'] == 'subscriptionGroupLocalizations']

        for loc in locs:
            attrs = loc['attributes']
            state = attrs.get('state', 'UNKNOWN')

            if state == 'PREPARE_FOR_SUBMISSION':
                icon = '✅'
            elif state == 'REJECTED':
                icon = '❌'
                all_ready = False
            else:
                icon = '⚠️'
                all_ready = False

            print(f"     {icon} {attrs['locale']}: \"{attrs['name']}\" - {state}")

print()
print("═" * 70)

if all_ready:
    print("  🎉 ALL LOCALIZATIONS READY FOR SUBMISSION!")
    print("═" * 70)
    print()
    print("✅ Next Steps:")
    print("   1. Add Review Information to each subscription product")
    print("      (see ios/VERIFICATION_REPORT.md for template)")
    print()
    print("   2. Submit subscriptions for Apple review:")
    print("      https://appstoreconnect.apple.com/apps/6754500922")
    print()
    print("   3. Wait 1-3 business days for subscription approval")
    print()
    print("   4. Resubmit app version 1.0 for App Store review")
    print()
    sys.exit(0)
else:
    print("  ⚠️  SOME LOCALIZATIONS NEED ATTENTION")
    print("═" * 70)
    print()
    print("❌ Issues Found:")
    print("   Some localizations are not in PREPARE_FOR_SUBMISSION state.")
    print()
    print("📋 Actions Required:")
    print("   1. Review the output above for ❌ or ⚠️  markers")
    print("   2. Fix any REJECTED or non-ready localizations")
    print("   3. Run this script again to verify")
    print()
    print("📚 See: ios/fastlane/SUBSCRIPTION_ISSUES_DIAGNOSTIC.md")
    print()
    sys.exit(1)
