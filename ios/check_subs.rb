require 'spaceship'

api_key = Spaceship::ConnectAPI::APIClient::Token.create(
  key_id: 'T9L7G79827',
  issuer_id: 'e5761715-cdcf-42cb-b50e-09977a5c8279',
  filepath: ENV['HOME'] + '/private_keys/AuthKey_T9L7G79827.p8'
)

Spaceship::ConnectAPI.token = api_key

app = Spaceship::ConnectAPI::App.find('com.elev8tion.everydaychristian')

puts "=== Fetching Subscription Groups ==="
groups = Spaceship::ConnectAPI.get_subscription_groups(filter: { app: app.id })

groups.each do |group|
  puts "\nGroup: #{group.reference_name}"
  puts "ID: #{group.id}"
  
  # Fetch subscriptions for this group
  subs = Spaceship::ConnectAPI.get_subscriptions(filter: { subscriptionGroup: group.id })
  
  subs.each do |sub|
    puts "\n  ━━━ #{sub.product_id} ━━━"
    puts "  Name: #{sub.name}"
    puts "  State: #{sub.state}"
    puts "  Available in all territories: #{sub.available_in_all_territories}"
    
    # Get localizations
    locs = sub.get_subscription_localizations
    puts "\n  Localizations:"
    locs.each do |loc|
      puts "    • #{loc.locale}: #{loc.name}"
      puts "      Desc: #{loc.description[0..50]}..." if loc.description
    end
  end
end
