#!/usr/bin/env python3
"""
Submit subscriptions for App Store review via API
"""

import jwt
import time
import requests

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

    def submit_subscription_group(self, group_id):
        """Submit subscription group for review"""
        print(f"📤 Submitting subscription group for review...")
        print(f"   Group ID: {group_id}")

        data = {
            "data": {
                "type": "subscriptionGroupSubmissions",
                "relationships": {
                    "subscriptionGroup": {
                        "data": {
                            "type": "subscriptionGroups",
                            "id": group_id
                        }
                    }
                }
            }
        }

        try:
            response = self.make_request("POST", "/v1/subscriptionGroupSubmissions", data)
            submission_id = response['data']['id']
            print(f"✅ Subscription group submitted successfully!")
            print(f"   Submission ID: {submission_id}")
            return submission_id
        except Exception as e:
            if "409" in str(e):
                print(f"ℹ️  Subscription group already submitted")
            else:
                raise


def main():
    print("=" * 70)
    print("Submit Subscriptions for App Store Review")
    print("=" * 70)
    print()

    KEY_ID = "T9L7G79827"
    ISSUER_ID = "e5761715-cdcf-42cb-b50e-09977a5c8279"
    PRIVATE_KEY_PATH = "/Users/kcdacre8tor/Downloads/AuthKey_T9L7G79827.p8"
    SUBSCRIPTION_GROUP_ID = "21863442"  # From verification script

    api = AppStoreConnectAPI(KEY_ID, ISSUER_ID, PRIVATE_KEY_PATH)

    try:
        api.submit_subscription_group(SUBSCRIPTION_GROUP_ID)

        print()
        print("=" * 70)
        print("✅ SUBMISSION COMPLETE!")
        print("=" * 70)
        print()
        print("Next steps:")
        print("1. Both subscriptions (yearly & monthly) are now submitted")
        print("2. Run verify_subscription_status.py to check status")
        print("3. They should now be available to link to your app version")
        print("4. In App Store Connect: Your App → App Store → Version")
        print("   → In-App Purchases and Subscriptions → Select both")
        print("5. Submit app for review")

    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    main()
