#!/bin/bash
# App Store Connect API Client using curl

KEY_ID="T9L7G79827"
ISSUER_ID="e5761715-cdcf-42cb-b50e-09977a5c8279"
KEY_FILE="$HOME/private_keys/AuthKey_T9L7G79827.p8"

# Function to generate JWT token using Python
generate_token() {
    python3 << PYTHON
import jwt
import time
from pathlib import Path

key_id = "${KEY_ID}"
issuer_id = "${ISSUER_ID}"
key_file = "${KEY_FILE}"

# Read private key
with open(key_file, 'r') as f:
    private_key = f.read()

# Create payload
payload = {
    'iss': issuer_id,
    'exp': int(time.time()) + 1200,  # 20 minutes
    'aud': 'appstoreconnect-v1'
}

# Create header
header = {
    'kid': key_id,
    'typ': 'JWT',
    'alg': 'ES256'
}

# Generate token
token = jwt.encode(payload, private_key, algorithm='ES256', headers=header)
print(token)
PYTHON
}

# Generate token
TOKEN=$(generate_token)

if [ -z "$TOKEN" ]; then
    echo "Error: Failed to generate token"
    echo "Installing PyJWT..."
    pip3 install PyJWT cryptography
    TOKEN=$(generate_token)
fi

export ASC_TOKEN="$TOKEN"
echo "✅ Token generated successfully"
