#!/usr/bin/env python3
"""
Add 3-day free trial to yearly subscription
"""

import jwt
import time
import requests
import json

class AppStoreConnectAPI:
    def __init__(self, key_id, issuer_id, private_key_path):
        self.key_id = key_id
        self.issuer_id = issuer_id
        self.private_key_path = private_key_path
        self.base_url = "https://api.appstoreconnect.apple.com"

    def generate_token(self):
        with open(self.private_key_path, 'r') as f:
            private_key = f.read()

        headers = {"alg": "ES256", "kid": self.key_id, "typ": "JWT"}
        payload = {
            "iss": self.issuer_id,
            "iat": int(time.time()),
            "exp": int(time.time()) + 20 * 60,
            "aud": "appstoreconnect-v1"
        }
        return jwt.encode(payload, private_key, algorithm="ES256", headers=headers)

    def make_request(self, method, endpoint, data=None):
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

    def create_introductory_offer_with_territory(self, subscription_id):
        """Create introductory offer without territory relationship (global offer)"""
        print(f"🎁 Creating 3-day free trial...")

        data = {
            "data": {
                "type": "subscriptionIntroductoryOffers",
                "attributes": {
                    "offerMode": "FREE_TRIAL",
                    "duration": "THREE_DAYS",
                    "numberOfPeriods": 1
                },
                "relationships": {
                    "subscription": {
                        "data": {
                            "type": "subscriptions",
                            "id": subscription_id
                        }
                    }
                }
            }
        }

        try:
            response = self.make_request("POST", "/v1/subscriptionIntroductoryOffers", data)
            print(f"✅ Free trial created successfully!")
            return response['data']['id']
        except Exception as e:
            if "409" in str(e):
                print(f"ℹ️  Free trial already exists")
            elif "territory" in str(e).lower():
                print(f"⚠️  API requires territory - free trial must be added via App Store Connect UI")
                print(f"   1. Go to App Store Connect → Your App → Subscriptions")
                print(f"   2. Click 'Premium Annual' subscription")
                print(f"   3. Scroll to 'Subscription Prices' section")
                print(f"   4. Click on your USA pricing row")
                print(f"   5. Check 'Introductory Offer' box")
                print(f"   6. Select: Free Trial, 3 Days, 1 period")
                print(f"   7. Save")
            else:
                print(f"❌ Unexpected error: {e}")


def main():
    print("=" * 60)
    print("Add 3-Day Free Trial to Yearly Subscription")
    print("=" * 60)
    print()

    KEY_ID = "T9L7G79827"
    ISSUER_ID = "e5761715-cdcf-42cb-b50e-09977a5c8279"
    PRIVATE_KEY_PATH = "/Users/kcdacre8tor/Downloads/AuthKey_T9L7G79827.p8"
    YEARLY_SUB_ID = "6756732997"  # From verification script

    api = AppStoreConnectAPI(KEY_ID, ISSUER_ID, PRIVATE_KEY_PATH)

    try:
        api.create_introductory_offer_with_territory(YEARLY_SUB_ID)
        print()
        print("=" * 60)
        print("✅ Process Complete!")
        print("=" * 60)
    except Exception as e:
        print(f"❌ Error: {e}")


if __name__ == "__main__":
    main()
