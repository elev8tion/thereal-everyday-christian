#!/usr/bin/env python3
"""
Verify current status of iOS subscriptions in App Store Connect
"""

import jwt
import time
import requests
import json
from datetime import datetime, timedelta

class AppStoreConnectAPI:
    """App Store Connect API client"""

    def __init__(self, key_id, issuer_id, private_key_path):
        self.key_id = key_id
        self.issuer_id = issuer_id
        self.private_key_path = private_key_path
        self.base_url = "https://api.appstoreconnect.apple.com"

    def generate_token(self):
        """Generate JWT token for API authentication"""
        with open(self.private_key_path, 'r') as f:
            private_key = f.read()

        headers = {
            "alg": "ES256",
            "kid": self.key_id,
            "typ": "JWT"
        }

        payload = {
            "iss": self.issuer_id,
            "iat": int(time.time()),
            "exp": int(time.time()) + 20 * 60,
            "aud": "appstoreconnect-v1"
        }

        token = jwt.encode(payload, private_key, algorithm="ES256", headers=headers)
        return token

    def make_request(self, method, endpoint, data=None):
        """Make authenticated API request"""
        token = self.generate_token()
        headers = {
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json"
        }

        url = f"{self.base_url}{endpoint}"

        if method == "GET":
            response = requests.get(url, headers=headers)
        elif method == "POST":
            response = requests.post(url, headers=headers, json=data)

        if response.status_code >= 400:
            print(f"❌ Error {response.status_code}: {response.text}")
            response.raise_for_status()

        return response.json() if response.text else {}

    def get_app(self, bundle_id):
        """Get app by bundle ID"""
        response = self.make_request("GET", f"/v1/apps?filter[bundleId]={bundle_id}")
        if response.get('data'):
            return response['data'][0]['id']
        return None

    def get_subscription_groups(self, app_id):
        """Get subscription groups for app"""
        response = self.make_request("GET", f"/v1/apps/{app_id}/subscriptionGroups")
        return response.get('data', [])

    def get_subscriptions(self, group_id):
        """Get subscriptions in group"""
        response = self.make_request("GET", f"/v1/subscriptionGroups/{group_id}/subscriptions")
        return response.get('data', [])

    def get_subscription_details(self, subscription_id):
        """Get detailed subscription info"""
        response = self.make_request("GET", f"/v1/subscriptions/{subscription_id}?include=subscriptionLocalizations,introductoryOffers,prices")
        return response

    def get_subscription_prices(self, subscription_id):
        """Get pricing for subscription"""
        response = self.make_request("GET", f"/v1/subscriptions/{subscription_id}/prices?limit=200")
        return response.get('data', [])

    def get_subscription_localizations(self, subscription_id):
        """Get localizations for subscription"""
        response = self.make_request("GET", f"/v1/subscriptions/{subscription_id}/subscriptionLocalizations")
        return response.get('data', [])

    def get_introductory_offers(self, subscription_id):
        """Get introductory offers for subscription"""
        response = self.make_request("GET", f"/v1/subscriptions/{subscription_id}/introductoryOffers")
        return response.get('data', [])

    def get_app_store_review_screenshot(self, subscription_id):
        """Get app store review screenshot status"""
        try:
            response = self.make_request("GET", f"/v1/subscriptions/{subscription_id}/appStoreReviewScreenshot")
            return response.get('data')
        except:
            return None


def main():
    print("=" * 70)
    print("App Store Connect Subscription Status Verification")
    print("=" * 70)
    print()

    KEY_ID = "T9L7G79827"
    ISSUER_ID = "e5761715-cdcf-42cb-b50e-09977a5c8279"
    PRIVATE_KEY_PATH = "/Users/kcdacre8tor/Downloads/AuthKey_T9L7G79827.p8"
    BUNDLE_ID = "com.elev8tion.everydaychristian"

    api = AppStoreConnectAPI(KEY_ID, ISSUER_ID, PRIVATE_KEY_PATH)

    try:
        print("🔍 Finding app...")
        app_id = api.get_app(BUNDLE_ID)
        print(f"✅ App ID: {app_id}\n")

        print("📦 Getting subscription groups...")
        groups = api.get_subscription_groups(app_id)
        print(f"✅ Found {len(groups)} subscription group(s)\n")

        for group in groups:
            group_id = group['id']
            group_name = group['attributes'].get('referenceName', 'N/A')
            print(f"{'='*70}")
            print(f"Subscription Group: {group_name}")
            print(f"Group ID: {group_id}")
            print(f"{'='*70}\n")

            print("📱 Getting subscriptions...")
            subscriptions = api.get_subscriptions(group_id)
            print(f"✅ Found {len(subscriptions)} subscription(s)\n")

            for sub in subscriptions:
                sub_id = sub['id']
                sub_name = sub['attributes'].get('name', 'N/A')
                product_id = sub['attributes'].get('productId', 'N/A')
                period = sub['attributes'].get('subscriptionPeriod', 'N/A')
                state = sub['attributes'].get('state', 'N/A')

                print(f"{'-'*70}")
                print(f"📱 Subscription: {sub_name}")
                print(f"   Product ID: {product_id}")
                print(f"   Duration: {period}")
                print(f"   State: {state}")
                print(f"   ID: {sub_id}")
                print()

                # Check localizations
                print("🌍 Localizations:")
                localizations = api.get_subscription_localizations(sub_id)
                if localizations:
                    for loc in localizations:
                        locale = loc['attributes'].get('locale', 'N/A')
                        name = loc['attributes'].get('name', 'N/A')
                        desc = loc['attributes'].get('description', 'N/A')
                        print(f"   ✅ {locale}: {name}")
                        print(f"      {desc}")
                else:
                    print("   ❌ No localizations found")
                print()

                # Check pricing
                print("💰 Pricing:")
                prices = api.get_subscription_prices(sub_id)
                if prices:
                    print(f"   ✅ {len(prices)} price(s) configured")
                    for price in prices[:5]:  # Show first 5
                        try:
                            territory = price.get('relationships', {}).get('territory', {}).get('data', {}).get('id', 'N/A')
                            print(f"      - Territory: {territory}")
                        except:
                            print(f"      - Price configured")
                else:
                    print("   ❌ No pricing set")
                print()

                # Check introductory offers
                print("🎁 Introductory Offers:")
                offers = api.get_introductory_offers(sub_id)
                if offers:
                    for offer in offers:
                        mode = offer['attributes'].get('offerMode', 'N/A')
                        duration = offer['attributes'].get('duration', 'N/A')
                        periods = offer['attributes'].get('numberOfPeriods', 'N/A')
                        print(f"   ✅ {mode}: {duration} x {periods} period(s)")
                else:
                    print("   ❌ No introductory offers")
                print()

                # Check screenshot
                print("📸 App Store Review Screenshot:")
                screenshot = api.get_app_store_review_screenshot(sub_id)
                if screenshot:
                    state = screenshot.get('attributes', {}).get('assetDeliveryState', {}).get('state', 'N/A')
                    filename = screenshot.get('attributes', {}).get('fileName', 'N/A')
                    print(f"   ✅ Screenshot uploaded: {filename}")
                    print(f"      State: {state}")
                else:
                    print("   ❌ No screenshot uploaded")
                print()

        print("=" * 70)
        print("✅ Verification Complete!")
        print("=" * 70)

    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    main()
