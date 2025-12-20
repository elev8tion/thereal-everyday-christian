lane :rejection_details do
  api_key = app_store_connect_api_key(
    key_id: "T9L7G79827",
    issuer_id: "e5761715-cdcf-42cb-b50e-09977a5c8279",
    key_filepath: "#{Dir.home}/private_keys/AuthKey_T9L7G79827.p8",
    duration: 1200
  )
  
  app = Spaceship::ConnectAPI::App.find("com.elev8tion.everydaychristian")
  
  UI.header "📱 Everyday Christian - Rejection Report"
  UI.message "Bundle ID: #{app.bundle_id}"
  UI.message ""
  
  # Get all versions
  edit_version = app.get_edit_app_store_version
  
  if edit_version
    UI.important "Version: #{edit_version.version_string}"
    UI.important "Status: #{edit_version.app_store_state}"
    UI.important "Created: #{edit_version.created_date}" if edit_version.created_date
    UI.message ""
    
    # Get subscription groups and products
    UI.header "💰 Subscription Configuration"
    begin
      groups = app.get_subscription_groups
      if groups.any?
        groups.each do |group|
          UI.message "Group: #{group.reference_name}"
          subs = group.subscriptions
          subs.each do |sub|
            UI.message "  └─ Product ID: #{sub.product_id}"
            UI.message "     State: #{sub.state}"
            UI.message "     Name: #{sub.name}" if sub.name
          end
        end
      else
        UI.error "❌ No subscription groups found!"
      end
    rescue => e
      UI.error "Error fetching subscriptions: #{e.message}"
    end
    
    UI.message ""
    UI.message "━" * 60
    UI.important "To see detailed rejection reasons:"
    UI.important "1. Visit App Store Connect Resolution Center"
    UI.important "2. Or check your email for rejection notice from Apple"
    UI.message "━" * 60
  else
    UI.error "No edit version found"
  end
end
