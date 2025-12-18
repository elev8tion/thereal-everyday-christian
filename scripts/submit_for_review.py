#!/usr/bin/env python3
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
        elif method == "PATCH":
            response = requests.patch(url, headers=headers, json=data)

        if response.status_code >= 400:
            print(f"Error {response.status_code}: {response.text}")
            response.raise_for_status()

        return response.json() if response.text else {}

    def get_app(self, bundle_id):
        response = self.make_request("GET", f"/v1/apps?filter[bundleId]={bundle_id}")
        if response.get('data'):
            return response['data'][0]['id']
        return None

    def get_app_version(self, app_id):
        response = self.make_request("GET", f"/v1/apps/{app_id}/appStoreVersions?filter[platform]=IOS&filter[appStoreState]=PREPARE_FOR_SUBMISSION")
        versions = response.get('data', [])
        if not versions:
            response = self.make_request("GET", f"/v1/apps/{app_id}/appStoreVersions?filter[platform]=IOS&filter[appStoreState]=REJECTED")
            versions = response.get('data', [])
        if versions:
            return versions[0]['id']
        return None

    def get_or_create_review_submission(self, app_id):
        try:
            response = self.make_request("GET", f"/v1/apps/{app_id}/reviewSubmissions?filter[platform]=IOS")
            submissions = response.get('data', [])
            for submission in submissions:
                state = submission['attributes'].get('state')
                if state in ['READY_FOR_SUBMISSION', 'WAITING_FOR_REVIEW']:
                    return submission['id']
        except:
            pass

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

        response = self.make_request("POST", "/v1/reviewSubmissions", data)
        return response['data']['id']

    def add_version_to_submission(self, submission_id, version_id):
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
            return response['data']['id']
        except Exception as e:
            if "409" in str(e):
                return None
            raise

    def submit_for_review(self, submission_id):
        data = {
            "data": {
                "type": "reviewSubmissions",
                "id": submission_id,
                "attributes": {
                    "submitted": True
                }
            }
        }

        response = self.make_request("PATCH", f"/v1/reviewSubmissions/{submission_id}", data)
        return response['data']

def main():
    KEY_ID = "T9L7G79827"
    ISSUER_ID = "e5761715-cdcf-42cb-b50e-09977a5c8279"
    PRIVATE_KEY_PATH = "/Users/kcdacre8tor/Downloads/AuthKey_T9L7G79827.p8"
    BUNDLE_ID = "com.elev8tion.everydaychristian"

    api = AppStoreConnectAPI(KEY_ID, ISSUER_ID, PRIVATE_KEY_PATH)

    print("Step 1: Get app")
    app_id = api.get_app(BUNDLE_ID)
    print(f"  App ID: {app_id}")

    print("\nStep 2: Get app version")
    version_id = api.get_app_version(app_id)
    print(f"  Version ID: {version_id}")

    print("\nStep 3: Get or create review submission")
    submission_id = api.get_or_create_review_submission(app_id)
    print(f"  Submission ID: {submission_id}")

    print("\nStep 4: Add version to submission")
    item_id = api.add_version_to_submission(submission_id, version_id)
    if item_id:
        print(f"  Item ID: {item_id}")
    else:
        print(f"  Version already in submission")

    print("\nStep 5: Submit for review")
    result = api.submit_for_review(submission_id)
    state = result['attributes'].get('state')
    print(f"  State: {state}")

    print("\n" + "="*50)
    print("Submission complete!")
    print("="*50)

if __name__ == "__main__":
    main()
