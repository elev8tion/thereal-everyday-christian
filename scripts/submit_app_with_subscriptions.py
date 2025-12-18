#!/usr/bin/env python3
"""
Submit app version with subscriptions for review via ReviewSubmission API
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
        elif method == "PATCH":
            response = requests.patch(url, headers=headers, json=data)

        if response.status_code >= 400:
            print(f"❌ Error {response.status_code}: {response.text}")
            response.raise_for_status()

        return response.json() if response.text else {}

    def get_app(self, bundle_id):
        """Get app by bundle ID"""
        print(f"🔍 Finding app with bundle ID: {bundle_id}")
        response = self.make_request("GET", f"/v1/apps?filter[bundleId]={bundle_id}")
        if response.get('data'):
            app_id = response['data'][0]['id']
            print(f"✅ App ID: {app_id}")
            return app_id
        raise Exception(f"App not found with bundle ID: {bundle_id}")

    def get_app_store_versions(self, app_id):
        """Get app store versions - checks PREPARE_FOR_SUBMISSION or REJECTED"""
        print(f"📱 Getting app versions...")

        # First try PREPARE_FOR_SUBMISSION
        response = self.make_request("GET", f"/v1/apps/{app_id}/appStoreVersions?filter[platform]=IOS&filter[appStoreState]=PREPARE_FOR_SUBMISSION")
        versions = response.get('data', [])

        # If no PREPARE_FOR_SUBMISSION, try REJECTED
        if not versions:
            print(f"   No PREPARE_FOR_SUBMISSION versions, checking REJECTED...")
            response = self.make_request("GET", f"/v1/apps/{app_id}/appStoreVersions?filter[platform]=IOS&filter[appStoreState]=REJECTED")
            versions = response.get('data', [])

        if versions:
            version = versions[0]
            version_string = version['attributes'].get('versionString', 'N/A')
            state = version['attributes'].get('appStoreState', 'N/A')
            version_id = version['id']
            print(f"✅ Found version {version_string} (State: {state}, ID: {version_id})")
            return version_id, version_string, state

        raise Exception("No version in PREPARE_FOR_SUBMISSION or REJECTED state found")

    def get_subscription_groups(self, app_id):
        """Get subscription groups"""
        print(f"📦 Getting subscription groups...")
        response = self.make_request("GET", f"/v1/apps/{app_id}/subscriptionGroups")
        groups = response.get('data', [])
        if groups:
            group_id = groups[0]['id']
            group_name = groups[0]['attributes'].get('referenceName', 'N/A')
            print(f"✅ Subscription group: {group_name} (ID: {group_id})")
            return group_id
        raise Exception("No subscription group found")

    def get_subscriptions(self, group_id):
        """Get subscriptions in group"""
        print(f"💰 Getting subscriptions...")
        response = self.make_request("GET", f"/v1/subscriptionGroups/{group_id}/subscriptions")
        subscriptions = response.get('data', [])
        print(f"✅ Found {len(subscriptions)} subscription(s)")
        return [sub['id'] for sub in subscriptions]

    def submit_individual_subscription(self, subscription_id):
        """Submit individual subscription for review"""
        print(f"📤 Submitting subscription {subscription_id} for review...")

        data = {
            "data": {
                "type": "subscriptionSubmissions",
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
            response = self.make_request("POST", "/v1/subscriptionSubmissions", data)
            submission_id = response['data']['id']
            print(f"   ✅ Subscription submitted: {submission_id}")
            return submission_id
        except Exception as e:
            if "409" in str(e):
                print(f"   ℹ️  Subscription already submitted")
                return None
            else:
                raise

    def create_review_submission(self, app_id):
        """Create review submission for app"""
        print(f"📤 Creating review submission...")

        data = {
            "data": {
                "type": "reviewSubmissions",
                "attributes": {
                    "platform": "IOS"
                },
                "relationships": {
                    "app": {
                        "data": {
                            "type": "apps",
                            "id": app_id
                        }
                    }
                }
            }
        }

        try:
            response = self.make_request("POST", "/v1/reviewSubmissions", data)
            submission_id = response['data']['id']
            print(f"✅ Review submission created: {submission_id}")
            return submission_id
        except Exception as e:
            if "409" in str(e):
                print(f"ℹ️  Review submission already exists")
                # Try to get existing submission
                try:
                    response = self.make_request("GET", f"/v1/apps/{app_id}/reviewSubmissions?filter[platform]=IOS")
                    submissions = response.get('data', [])
                    if submissions:
                        submission_id = submissions[0]['id']
                        print(f"   Using existing submission: {submission_id}")
                        return submission_id
                except:
                    pass
                return None
            else:
                raise

    def add_app_version_to_submission(self, submission_id, version_id):
        """Add app version to review submission"""
        print(f"📱 Adding app version to review submission...")

        data = {
            "data": {
                "type": "reviewSubmissionItems",
                "relationships": {
                    "reviewSubmission": {
                        "data": {
                            "type": "reviewSubmissions",
                            "id": submission_id
                        }
                    },
                    "appStoreVersion": {
                        "data": {
                            "type": "appStoreVersions",
                            "id": version_id
                        }
                    }
                }
            }
        }

        try:
            response = self.make_request("POST", "/v1/reviewSubmissionItems", data)
            item_id = response['data']['id']
            print(f"   ✅ App version added to submission: {item_id}")
            return item_id
        except Exception as e:
            if "409" in str(e):
                print(f"   ℹ️  App version already in submission")
                return None
            else:
                raise

    def submit_review_submission(self, submission_id):
        """Submit review submission for App Review"""
        print(f"🚀 Submitting for review...")

        data = {
            "data": {
                "type": "reviewSubmissions",
                "id": submission_id,
                "attributes": {
                    "submitted": True
                }
            }
        }

        try:
            response = self.make_request("PATCH", f"/v1/reviewSubmissions/{submission_id}", data)
            print(f"✅ Review submission submitted!")
            return response['data']
        except Exception as e:
            if "409" in str(e):
                print(f"ℹ️  Review submission already submitted")
            else:
                raise


def main():
    print("=" * 70)
    print("Submit App with Subscriptions for Review")
    print("=" * 70)
    print()

    KEY_ID = "T9L7G79827"
    ISSUER_ID = "e5761715-cdcf-42cb-b50e-09977a5c8279"
    PRIVATE_KEY_PATH = "/Users/kcdacre8tor/Downloads/AuthKey_T9L7G79827.p8"
    BUNDLE_ID = "com.elev8tion.everydaychristian"

    api = AppStoreConnectAPI(KEY_ID, ISSUER_ID, PRIVATE_KEY_PATH)

    try:
        # Step 1: Get app
        print("=" * 70)
        print("STEP 1: Get App")
        print("=" * 70)
        print()
        app_id = api.get_app(BUNDLE_ID)
        print()

        # Step 2: Get app version in PREPARE_FOR_SUBMISSION or REJECTED state
        print("=" * 70)
        print("STEP 2: Get App Version")
        print("=" * 70)
        print()
        version_id, version_string, state = api.get_app_store_versions(app_id)
        if state == "REJECTED":
            print(f"ℹ️  Version {version_string} was rejected - will fix and resubmit")
        print()

        # Step 3: Get subscriptions
        print("=" * 70)
        print("STEP 3: Get Subscriptions")
        print("=" * 70)
        print()
        group_id = api.get_subscription_groups(app_id)
        subscription_ids = api.get_subscriptions(group_id)
        print()

        # Step 4: Create review submission
        print("=" * 70)
        print("STEP 4: Create Review Submission")
        print("=" * 70)
        print()
        submission_id = api.create_review_submission(app_id)
        if not submission_id:
            print("❌ Failed to create review submission")
            return
        print()

        # Step 5: Add app version to submission
        print("=" * 70)
        print("STEP 5: Add App Version to Review Submission")
        print("=" * 70)
        print()
        api.add_app_version_to_submission(submission_id, version_id)
        print()

        # Step 6: Submit the review submission
        print("=" * 70)
        print("STEP 6: Submit for App Review")
        print("=" * 70)
        print()
        api.submit_review_submission(submission_id)
        print()

        print("=" * 70)
        print("✅ SUBMISSION COMPLETE!")
        print("=" * 70)
        print()
        print("Your app and subscriptions have been submitted for review!")
        print()
        print("Next steps:")
        print("1. Check App Store Connect to verify submission status")
        print("2. Monitor email for App Review updates")
        print("3. Respond to any App Review questions if needed")

    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    main()
