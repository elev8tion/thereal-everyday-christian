# Add this lane to query App Store Connect

lane :query_status do
  api_key = app_store_connect_api_key(
    key_id: "T9L7G79827",
    issuer_id: "e5761715-cdcf-42cb-b50e-09977a5c8279",
    key_filepath: "#{Dir.home}/private_keys/AuthKey_T9L7G79827.p8",
    duration: 1200,
    in_house: false
  )
  
  UI.header "Everyday Christian - App Store Status"
  
  # Get app info
  app = Spaceship::ConnectAPI::App.find("com.elev8tion.everydaychristian")
  
  if app
    UI.success "Found app: #{app.name}"
    UI.message "Bundle ID: #{app.bundle_id}"
    
    # Get versions
    live_version = app.get_live_app_store_version
    edit_version = app.get_edit_app_store_version
    
    if live_version
      UI.success "Live Version: #{live_version.version_string} (#{live_version.app_store_state})"
    end
    
    if edit_version
      UI.important "Edit Version: #{edit_version.version_string}"
      UI.important "Status: #{edit_version.app_store_state}"
      
      if edit_version.app_store_state.include?("REJECT")
        UI.error "⚠️  VERSION REJECTED!"
        UI.error "Check Resolution Center for details"
      end
    end
    
    # Get builds
    UI.header "TestFlight Builds"
    builds = app.get_builds(limit: 10)
    builds.each do |build|
      UI.message "  Build #{build.version} (#{build.build_number}) - #{build.processing_state}"
    end
    
    # Get IAPs
    UI.header "In-App Purchases"
    begin
      subscription_groups = app.get_subscription_groups
      subscription_groups.each do |group|
        UI.message "Group: #{group.reference_name}"
        subscriptions = group.subscriptions
        subscriptions.each do |sub|
          UI.message "  - #{sub.product_id}: #{sub.state}"
        end
      end
    rescue => e
      UI.error "Could not fetch subscriptions: #{e.message}"
    end
    
  else
    UI.error "App not found!"
  end
end
