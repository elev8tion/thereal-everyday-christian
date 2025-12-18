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

        if response.status_code >= 400:
            print(f"Error {response.status_code}: {response.text}")
            response.raise_for_status()

        return response.json() if response.text else {}

    def get_subscription_group_localizations(self, group_id):
        response = self.make_request("GET", f"/v1/subscriptionGroups/{group_id}/subscriptionGroupLocalizations")
        return response.get('data', [])

def main():
    KEY_ID = "T9L7G79827"
    ISSUER_ID = "e5761715-cdcf-42cb-b50e-09977a5c8279"
    PRIVATE_KEY_PATH = "/Users/kcdacre8tor/Downloads/AuthKey_T9L7G79827.p8"
    GROUP_ID = "21863442"

    api = AppStoreConnectAPI(KEY_ID, ISSUER_ID, PRIVATE_KEY_PATH)

    print("Checking subscription group localizations...")
    localizations = api.get_subscription_group_localizations(GROUP_ID)

    if localizations:
        print(f"Found {len(localizations)} localization(s):")
        for loc in localizations:
            locale = loc['attributes'].get('locale', 'N/A')
            name = loc['attributes'].get('name', 'N/A')
            print(f"  - {locale}: {name}")
    else:
        print("No localizations found for subscription group!")
        print("\nThis is why subscriptions are in MISSING_METADATA state.")
        print("You need to add localizations to the subscription group.")

if __name__ == "__main__":
    main()
