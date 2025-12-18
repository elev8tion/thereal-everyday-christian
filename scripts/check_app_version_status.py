#!/usr/bin/env python3
"""
Check current status of app versions
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

    def get_app(self, bundle_id):
        """Get app by bundle ID"""
        response = self.make_request("GET", f"/v1/apps?filter[bundleId]={bundle_id}")
        if response.get('data'):
            return response['data'][0]['id']
        return None

    def get_all_app_versions(self, app_id):
        """Get all app store versions"""
        response = self.make_request("GET", f"/v1/apps/{app_id}/appStoreVersions?filter[platform]=IOS&limit=20")
        return response.get('data', [])


def main():
    print("=" * 70)
    print("Check App Version Status")
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
        print(f"✅ App ID: {app_id}")
        print()

        print("📱 Getting all app versions...")
        versions = api.get_all_app_versions(app_id)
        print(f"✅ Found {len(versions)} version(s)")
        print()

        if not versions:
            print("❌ No versions found")
            print()
            print("You need to create a version in App Store Connect:")
            print("1. Go to App Store Connect → Your App → App Store")
            print("2. Click the + button next to 'iOS App'")
            print("3. Enter the version number (e.g., 1.0.0)")
            return

        for i, version in enumerate(versions):
            version_string = version['attributes'].get('versionString', 'N/A')
            state = version['attributes'].get('appStoreState', 'N/A')
            version_id = version['id']
            created = version['attributes'].get('createdDate', 'N/A')

            print(f"{'='*70}")
            print(f"Version {i+1}: {version_string}")
            print(f"{'='*70}")
            print(f"State: {state}")
            print(f"ID: {version_id}")
            print(f"Created: {created}")
            print()

            # Show what states mean
            if state == "PREPARE_FOR_SUBMISSION":
                print("✅ This version can be submitted for review")
            elif state == "WAITING_FOR_REVIEW":
                print("⏳ This version is waiting for App Review")
            elif state == "IN_REVIEW":
                print("🔍 This version is currently in review")
            elif state == "PENDING_DEVELOPER_RELEASE":
                print("✅ This version is approved and pending your release")
            elif state == "READY_FOR_SALE":
                print("🎉 This version is live on the App Store")
            elif state == "REJECTED":
                print("❌ This version was rejected")
            elif state == "DEVELOPER_REMOVED_FROM_SALE":
                print("🚫 This version was removed from sale")
            elif state == "REMOVED_FROM_SALE":
                print("🚫 This version was removed from sale")

            print()

        print("=" * 70)
        print("Next Steps:")
        print("=" * 70)
        print()

        prep_versions = [v for v in versions if v['attributes'].get('appStoreState') == 'PREPARE_FOR_SUBMISSION']
        if prep_versions:
            print("✅ You have version(s) ready to submit")
            print("   Run submit_app_with_subscriptions.py to submit")
        else:
            print("ℹ️  No versions in PREPARE_FOR_SUBMISSION state")
            print()
            print("Common scenarios:")
            print("1. If a version is WAITING_FOR_REVIEW or IN_REVIEW:")
            print("   → Wait for App Review to complete")
            print()
            print("2. If a version is PENDING_DEVELOPER_RELEASE:")
            print("   → Your app is approved! Release it or create a new version")
            print()
            print("3. If a version is READY_FOR_SALE:")
            print("   → Your app is live! Create a new version for updates")
            print()
            print("4. If a version is REJECTED:")
            print("   → Address rejection reasons and resubmit the same version")

    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    main()
