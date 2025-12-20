#!/usr/bin/env ruby
# Query App Store Connect for Everyday Christian app details

require 'spaceship'

puts "🔍 App Store Connect Query"
puts "=" * 50
puts ""

# Get Issuer ID from user
print "Enter your Issuer ID (from https://appstoreconnect.apple.com/access/api): "
issuer_id = gets.chomp

puts ""
puts "Authenticating with App Store Connect API..."

begin
  # Authenticate using API Key
  Spaceship::ConnectAPI.token = Spaceship::ConnectAPI::Token.create(
    key_id: "T9L7G79827",
    issuer_id: issuer_id,
    key_filepath: "#{Dir.home}/private_keys/AuthKey_T9L7G79827.p8"
  )
  
  puts "✅ Authentication successful!"
  puts ""
  
  # Get app
  puts "📱 Finding app: com.elev8tion.everydaychristian"
  app = Spaceship::ConnectAPI::App.find("com.elev8tion.everydaychristian")
  
  if app.nil?
    puts "❌ App not found in App Store Connect!"
    exit 1
  end
  
  puts "✅ Found: #{app.name}"
  puts ""
  
  # Get app info
  puts "📊 App Information:"
  puts "-" * 50
  puts "Name: #{app.name}"
  puts "Bundle ID: #{app.bundle_id}"
  puts "SKU: #{app.sku}"
  puts "Primary Locale: #{app.primary_locale}"
  puts ""
  
  # Get latest version
  puts "📦 Latest Version Information:"
  puts "-" * 50
  
  live_version = app.get_live_app_store_version
  if live_version
    puts "Live Version: #{live_version.version_string}"
    puts "Status: #{live_version.app_store_state}"
    puts ""
  else
    puts "No live version found"
    puts ""
  end
  
  # Get edit version (in review or rejected)
  edit_version = app.get_edit_app_store_version
  if edit_version
    puts "🔄 Current Edit Version:"
    puts "  Version: #{edit_version.version_string}"
    puts "  Status: #{edit_version.app_store_state}"
    puts "  Created: #{edit_version.created_date}"
    
    # Check for rejection
    if edit_version.app_store_state == "REJECTED" || 
       edit_version.app_store_state == "DEVELOPER_REJECTED" ||
       edit_version.app_store_state == "METADATA_REJECTED"
      puts ""
      puts "❌ REJECTION DETECTED!"
      puts "=" * 50
      
      # Get rejection reasons
      review_submission = edit_version.fetch_review_submission
      if review_submission && review_submission.submitted_date
        puts "Submitted: #{review_submission.submitted_date}"
      end
      
      # Try to get resolution center messages
      puts ""
      puts "Fetching rejection details from Resolution Center..."
      
      # This would require additional API calls
      # For now, direct user to App Store Connect
      puts ""
      puts "⚠️  For detailed rejection reasons, visit:"
      puts "https://appstoreconnect.apple.com/apps/#{app.id}/appstore/ios/version/deliverable"
      puts ""
      puts "Or check Resolution Center:"
      puts "https://appstoreconnect.apple.com/apps/#{app.id}/resolution"
    end
    puts ""
  end
  
  # Get TestFlight builds
  puts "🧪 TestFlight Builds:"
  puts "-" * 50
  
  builds = app.get_builds.first(5)
  if builds.any?
    builds.each do |build|
      status = build.processing_state || "UNKNOWN"
      puts "Build #{build.version} (#{build.build_number}) - #{status}"
    end
  else
    puts "No TestFlight builds found"
  end
  puts ""
  
  # Get In-App Purchases
  puts "💰 In-App Purchases / Subscriptions:"
  puts "-" * 50
  
  begin
    iaps = app.get_in_app_purchases
    subscriptions = app.get_subscription_groups
    
    if iaps.any?
      puts "In-App Purchases:"
      iaps.first(10).each do |iap|
        puts "  - #{iap.product_id} (#{iap.in_app_purchase_type})"
      end
    end
    
    if subscriptions.any?
      puts ""
      puts "Subscription Groups:"
      subscriptions.each do |group|
        puts "  - #{group.reference_name}"
        subs = group.subscriptions
        subs.each do |sub|
          puts "    └─ #{sub.product_id} (#{sub.state})"
        end
      end
    end
    
    if !iaps.any? && !subscriptions.any?
      puts "No IAPs or subscriptions found"
    end
  rescue => e
    puts "Could not fetch IAPs: #{e.message}"
  end
  
  puts ""
  puts "✅ Query complete!"
  
rescue => e
  puts ""
  puts "❌ Error: #{e.message}"
  puts ""
  puts "Possible issues:"
  puts "1. Invalid Issuer ID"
  puts "2. API key doesn't have sufficient permissions"
  puts "3. App not found in App Store Connect"
  puts ""
  puts "Double-check:"
  puts "- Issuer ID: #{issuer_id}"
  puts "- Key ID: T9L7G79827"
  puts "- Key file: ~/private_keys/AuthKey_T9L7G79827.p8"
  
  exit 1
end
