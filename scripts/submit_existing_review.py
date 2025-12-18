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
        elif method == "PATCH":
            response = requests.patch(url, headers=headers, json=data)

        if response.status_code >= 400:
            print(f"Error {response.status_code}: {response.text}")
            response.raise_for_status()

        return response.json() if response.text else {}

    def get_review_submission(self, submission_id):
        response = self.make_request("GET", f"/v1/reviewSubmissions/{submission_id}?include=items")
        return response['data']

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
    SUBMISSION_ID = "213a117a-afa7-4f47-960b-3ecbc3461b1c"

    api = AppStoreConnectAPI(KEY_ID, ISSUER_ID, PRIVATE_KEY_PATH)

    print("Step 1: Get review submission details")
    submission = api.get_review_submission(SUBMISSION_ID)
    state = submission['attributes'].get('state')
    print(f"  State: {state}")

    print("\nStep 2: Submit for review")
    result = api.submit_for_review(SUBMISSION_ID)
    new_state = result['attributes'].get('state')
    print(f"  New State: {new_state}")

    print("\n" + "="*50)
    print("Submission complete!")
    print("="*50)

if __name__ == "__main__":
    main()
