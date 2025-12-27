#!/usr/bin/env ruby
# Script to attach subscriptions to app version and submit for review

require 'spaceship'
require 'json'

# Load API key
api_key = Spaceship::ConnectAPI::APIKey.from_json_file('fastlane/api_key.json')
Spaceship::ConnectAPI.token = api_key

puts "🔐 Authenticated with App Store Connect API"

# Get the app
bundle_id = "com.elev8tion.everydayChristian"
app = Spaceship::ConnectAPI::App.find(bundle_id)

unless app
  puts "❌ Could not find app with bundle ID: #{bundle_id}"
  exit 1
end

puts "✅ Found app: #{app.name} (#{app.bundle_id})"

# Get the latest version
app_store_version = app.get_edit_app_store_version

unless app_store_version
  puts "❌ No editable version found. Make sure you have a version in 'Prepare for Submission' state."
  exit 1
end

puts "📱 Found version: #{app_store_version.version_string} (#{app_store_version.app_store_state})"

# Get subscription groups
puts "\n🔍 Looking for subscriptions..."
groups = app.get_subscription_groups

if groups.nil? || groups.empty?
  puts "❌ No subscription groups found!"
  exit 1
end

subscription_ids = []

groups.each do |group|
  puts "\n📦 Subscription Group: #{group.reference_name}"

  subscriptions = group.subscriptions

  if subscriptions && subscriptions.any?
    subscriptions.each do |sub|
      puts "  ├─ #{sub.name} (#{sub.product_id})"
      subscription_ids << sub.id
    end
  end
end

if subscription_ids.empty?
  puts "❌ No subscriptions found in groups!"
  exit 1
end

puts "\n📎 Attaching #{subscription_ids.count} subscription(s) to version #{app_store_version.version_string}..."

# Attach subscriptions to the version
begin
  # The API call to attach subscriptions
  subscription_ids.each do |sub_id|
    Spaceship::ConnectAPI.post(
      "appStoreVersions/#{app_store_version.id}/relationships/subscriptions",
      {
        data: [
          {
            type: "subscriptions",
            id: sub_id
          }
        ]
      }
    )
    puts "  ✅ Attached subscription ID: #{sub_id}"
  end

  puts "\n🎉 Successfully attached all subscriptions to version!"
  puts "\n📋 Next steps:"
  puts "  1. Go to App Store Connect and verify subscriptions are attached"
  puts "  2. Submit localizations for each subscription"
  puts "  3. Run: fastlane submit"

rescue => e
  puts "❌ Error attaching subscriptions: #{e.message}"
  puts "   This might mean they're already attached or there's an API issue."
  puts "   Check App Store Connect manually."
  exit 1
end
