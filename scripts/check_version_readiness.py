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

    def make_request(self, method, endpoint):
        token = self.generate_token()
        headers = {
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json"
        }
        url = f"{self.base_url}{endpoint}"
        response = requests.get(url, headers=headers)

        if response.status_code >= 400:
            print(f"Error {response.status_code}: {response.text}")
            response.raise_for_status()

        return response.json() if response.text else {}

    def check_version(self, version_id):
        response = self.make_request("GET", f"/v1/appStoreVersions/{version_id}")
        return response['data']

def main():
    KEY_ID = "T9L7G79827"
    ISSUER_ID = "e5761715-cdcf-42cb-b50e-09977a5c8279"
    PRIVATE_KEY_PATH = "/Users/kcdacre8tor/Downloads/AuthKey_T9L7G79827.p8"
    VERSION_ID = "83f13bca-5bc5-4bbd-a9cd-01b3e6c5bc7f"

    api = AppStoreConnectAPI(KEY_ID, ISSUER_ID, PRIVATE_KEY_PATH)

    print("Checking app version...")
    version = api.check_version(VERSION_ID)

    attrs = version['attributes']
    print(f"Version: {attrs.get('versionString')}")
    print(f"Platform: {attrs.get('platform')}")
    print(f"App Store State: {attrs.get('appStoreState')}")
    print(f"App Version State: {attrs.get('appVersionState')}")
    print(f"Release Type: {attrs.get('releaseType')}")
    print(f"Downloadable: {attrs.get('downloadable')}")

if __name__ == "__main__":
    main()
