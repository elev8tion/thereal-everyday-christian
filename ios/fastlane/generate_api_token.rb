#!/usr/bin/env ruby
require 'jwt'
require 'base64'

# Generate App Store Connect API JWT token
key_id = "T9L7G79827"
issuer_id = "e5761715-cdcf-42cb-b50e-09977a5c8279"
key_file = "#{Dir.home}/private_keys/AuthKey_T9L7G79827.p8"

# Read the private key
private_key = OpenSSL::PKey.read(File.read(key_file))

# Create JWT payload
payload = {
  iss: issuer_id,
  exp: Time.now.to_i + 20 * 60, # 20 minutes
  aud: "appstoreconnect-v1"
}

# Create JWT header
header = {
  kid: key_id,
  typ: "JWT",
  alg: "ES256"
}

# Generate token
token = JWT.encode(payload, private_key, 'ES256', header)
puts token
