#!/usr/bin/env python3
"""
Complete subscription setup via API:
1. Add introductory offer with territory
2. Upload App Review screenshots
"""

import jwt
import time
import requests
import json
import os
import hashlib

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
        elif method == "PATCH":
            response = requests.patch(url, headers=headers, json=data)
        elif method == "PUT":
            response = requests.put(url, headers=headers, data=data if isinstance(data, bytes) else json.dumps(data))

        if response.status_code >= 400:
            print(f"❌ Error {response.status_code}: {response.text}")
            response.raise_for_status()

        return response.json() if response.text else {}

    def find_territory(self, code="USA"):
        """Find territory by code"""
        print(f"🔍 Finding territory: {code}")
        response = self.make_request("GET", "/v1/territories?limit=200")
        for territory in response.get('data', []):
            if territory['id'] == code:
                print(f"✅ Found territory: {code}")
                return territory['id']
        raise Exception(f"Territory {code} not found")

    def create_intro_offer_with_territory(self, subscription_id, territory_id):
        """Create introductory offer with territory"""
        print(f"🎁 Creating 3-day free trial for territory {territory_id}...")

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
                    },
                    "territory": {
                        "data": {
                            "type": "territories",
                            "id": territory_id
                        }
                    }
                }
            }
        }

        try:
            response = self.make_request("POST", "/v1/subscriptionIntroductoryOffers", data)
            print(f"✅ Free trial created for {territory_id}!")
            return response['data']['id']
        except Exception as e:
            if "409" in str(e):
                print(f"ℹ️  Free trial already exists for {territory_id}")
                return None
            else:
                raise

    def upload_screenshot(self, subscription_id, screenshot_path):
        """Upload App Store Review screenshot"""
        print(f"📸 Uploading screenshot: {screenshot_path}")

        # Get file info
        file_size = os.path.getsize(screenshot_path)
        file_name = os.path.basename(screenshot_path)

        print(f"   File: {file_name}, Size: {file_size} bytes")

        # Step 1: Create screenshot placeholder
        print(f"   Step 1: Creating screenshot placeholder...")
        data = {
            "data": {
                "type": "subscriptionAppStoreReviewScreenshots",
                "attributes": {
                    "fileName": file_name,
                    "fileSize": file_size
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

        response = self.make_request("POST", "/v1/subscriptionAppStoreReviewScreenshots", data)
        screenshot_id = response['data']['id']
        upload_operations = response['data']['attributes'].get('uploadOperations', [])

        print(f"   ✅ Screenshot placeholder created: {screenshot_id}")

        # Step 2: Upload file using upload operations
        if upload_operations:
            print(f"   Step 2: Uploading file...")

            with open(screenshot_path, 'rb') as f:
                file_data = f.read()

            for operation in upload_operations:
                method = operation['method']
                url = operation['url']
                headers = {header['name']: header['value'] for header in operation.get('requestHeaders', [])}

                if method == 'PUT':
                    response = requests.put(url, data=file_data, headers=headers)
                    if response.status_code not in [200, 201, 204]:
                        print(f"   ⚠️  Upload warning: {response.status_code}")
                    else:
                        print(f"   ✅ File uploaded successfully")

            # Step 3: Confirm upload
            print(f"   Step 3: Confirming upload...")

            # Calculate MD5 checksum
            md5_hash = hashlib.md5(file_data).hexdigest()

            patch_data = {
                "data": {
                    "type": "subscriptionAppStoreReviewScreenshots",
                    "id": screenshot_id,
                    "attributes": {
                        "sourceFileChecksum": md5_hash,
                        "uploaded": True
                    }
                }
            }

            self.make_request("PATCH", f"/v1/subscriptionAppStoreReviewScreenshots/{screenshot_id}", patch_data)
            print(f"   ✅ Upload confirmed!")

            return screenshot_id
        else:
            print(f"   ⚠️  No upload operations returned")
            return screenshot_id


def main():
    print("=" * 70)
    print("Complete Subscription Setup via API")
    print("=" * 70)
    print()

    KEY_ID = "T9L7G79827"
    ISSUER_ID = "e5761715-cdcf-42cb-b50e-09977a5c8279"
    PRIVATE_KEY_PATH = "/Users/kcdacre8tor/Downloads/AuthKey_T9L7G79827.p8"
    YEARLY_SUB_ID = "6756732997"
    MONTHLY_SUB_ID = "6756733199"
    SCREENSHOT_PATH = "/Users/kcdacre8tor/thereal-everyday-christian/assets/screenshots/app-store-ready/subscriptions.png"

    api = AppStoreConnectAPI(KEY_ID, ISSUER_ID, PRIVATE_KEY_PATH)

    try:
        # Step 1: Add free trial to yearly subscription
        print("=" * 70)
        print("STEP 1: Add 3-Day Free Trial (Yearly Subscription)")
        print("=" * 70)
        print()

        territory_id = api.find_territory("USA")
        api.create_intro_offer_with_territory(YEARLY_SUB_ID, territory_id)

        print()

        # Step 2: Upload screenshots
        print("=" * 70)
        print("STEP 2: Upload App Store Review Screenshots")
        print("=" * 70)
        print()

        print("📱 Yearly Subscription:")
        try:
            api.upload_screenshot(YEARLY_SUB_ID, SCREENSHOT_PATH)
        except Exception as e:
            if "409" in str(e):
                print("ℹ️  Screenshot already uploaded for yearly subscription")
            else:
                print(f"⚠️  Error: {e}")

        print()
        print("📱 Monthly Subscription:")
        try:
            api.upload_screenshot(MONTHLY_SUB_ID, SCREENSHOT_PATH)
        except Exception as e:
            if "409" in str(e):
                print("ℹ️  Screenshot already uploaded for monthly subscription")
            else:
                print(f"⚠️  Error: {e}")

        print()
        print("=" * 70)
        print("✅ SETUP COMPLETE!")
        print("=" * 70)
        print()
        print("Next steps:")
        print("1. Run verify_subscription_status.py to confirm everything")
        print("2. Link subscriptions to app version in App Store Connect")
        print("3. Submit for review")

    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    main()
