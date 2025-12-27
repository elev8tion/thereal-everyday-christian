#!/usr/bin/env ruby
# Script to fix subscription localizations via App Store Connect API
# Updates subscription descriptions to show "150 messages monthly" instead of "Unlimited access"

require 'spaceship'
require 'json'

# API credentials
KEY_ID = "T9L7G79827"
ISSUER_ID = "e5761715-cdcf-42cb-b50e-09977a5c8279"
KEY_PATH = "#{Dir.home}/private_keys/AuthKey_T9L7G79827.p8"
BUNDLE_ID = "com.elev8tion.everydaychristian"

# Authenticate
Spaceship::ConnectAPI.token = Spaceship::ConnectAPI::Token.create(
  key_id: KEY_ID,
  issuer_id: ISSUER_ID,
  filepath: KEY_PATH
)

puts "🔐 Authenticated with App Store Connect API"

# Find the app
app = Spaceship::ConnectAPI::App.find(BUNDLE_ID)
unless app
  puts "❌ App not found: #{BUNDLE_ID}"
  exit 1
end

puts "✅ Found app: #{app.name}"

# Correct descriptions
DESCRIPTIONS_MONTHLY = {
  "en-US" => "150 messages monthly, auto-renews monthly",
  "es-MX" => "150 mensajes mensuales, renovación automática mensual",
  "es-ES" => "150 mensajes mensuales, renovación automática mensual"
}

DESCRIPTIONS_YEARLY = {
  "en-US" => "150 messages monthly, auto-renews yearly",
  "es-MX" => "150 mensajes mensuales, renovación automática anual",
  "es-ES" => "150 mensajes mensuales, renovación automática anual"
}

# Get subscription groups via direct API
response = Spaceship::ConnectAPI.get("apps/#{app.id}/subscriptionGroups")
groups = response['data']

puts "\n📦 Found #{groups.count} subscription group(s)"

groups.each do |group|
  group_id = group['id']
  group_name = group['attributes']['referenceName']

  puts "\n🔍 Processing group: #{group_name}"

  # Get subscriptions in this group
  subs_response = Spaceship::ConnectAPI.get("subscriptionGroups/#{group_id}/subscriptions")
  subscriptions = subs_response['data']

  puts "   Found #{subscriptions.count} subscription(s)"

  subscriptions.each do |sub|
    sub_id = sub['id']
    product_id = sub['attributes']['productId']

    puts "\n   📱 Product: #{product_id}"

    # Determine if yearly or monthly
    is_yearly = product_id.include?('yearly')
    correct_descriptions = is_yearly ? DESCRIPTIONS_YEARLY : DESCRIPTIONS_MONTHLY

    # Get localizations for this subscription
    locs_response = Spaceship::ConnectAPI.get("subscriptions/#{sub_id}/subscriptionLocalizations")
    localizations = locs_response['data']

    puts "      Found #{localizations.count} localization(s)"

    localizations.each do |loc|
      loc_id = loc['id']
      locale = loc['attributes']['locale']
      current_desc = loc['attributes']['description']
      current_name = loc['attributes']['name']

      new_desc = correct_descriptions[locale]

      if new_desc.nil?
        puts "      ⏭  #{locale}: No mapping defined, skipping"
        next
      end

      if current_desc == new_desc
        puts "      ✅ #{locale}: Already correct"
        next
      end

      puts "      🔧 #{locale}: Updating description"
      puts "         OLD: #{current_desc}"
      puts "         NEW: #{new_desc}"

      # Update the localization
      begin
        update_data = {
          data: {
            type: "subscriptionLocalizations",
            id: loc_id,
            attributes: {
              description: new_desc
            }
          }
        }

        Spaceship::ConnectAPI.patch("subscriptionLocalizations/#{loc_id}", update_data)
        puts "      ✅ #{locale}: Updated successfully!"

      rescue => e
        puts "      ❌ #{locale}: Failed to update - #{e.message}"
      end
    end
  end
end

puts "\n" + "="*60
puts "✅ Subscription localization updates complete!"
puts "⚠️  You may need to resubmit your app for these changes to take effect"
puts "="*60
