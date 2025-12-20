#!/usr/bin/env ruby
# Query current subscription configuration via API

lane :query_subscriptions do
  api_key = app_store_connect_api_key(
    key_id: "T9L7G79827",
    issuer_id: "e5761715-cdcf-42cb-b50e-09977a5c8279",
    key_filepath: "#{Dir.home}/private_keys/AuthKey_T9L7G79827.p8",
    duration: 1200
  )
  
  UI.header "Querying Subscription Products"
  
  app = Spaceship::ConnectAPI::App.find("com.elev8tion.everydaychristian")
  
  # Get in-app purchases
  iaps = Spaceship::ConnectAPI.get_in_app_purchases(
    filter: { app: app.id },
    includes: "appStoreReviewScreenshot,iapPriceSchedule,inAppPurchaseLocalizations"
  )
  
  if iaps && iaps.count > 0
    UI.success "Found #{iaps.count} In-App Purchases/Subscriptions"
    UI.message ""
    
    iaps.each do |iap|
      UI.important "Product: #{iap.product_id}"
      UI.message "  Type: #{iap.in_app_purchase_type}"
      UI.message "  Reference Name: #{iap.reference_name}"
      UI.message "  State: #{iap.state}"
      UI.message ""
      
      # Get localizations
      if iap.in_app_purchase_localizations
        UI.header "Localizations:"
        iap.in_app_purchase_localizations.each do |loc|
          UI.message "  Language: #{loc.locale}"
          UI.message "  Name: #{loc.name}"
          UI.message "  Description: #{loc.description}"
          UI.message ""
        end
      end
    end
  else
    UI.error "No subscriptions found!"
  end
end
