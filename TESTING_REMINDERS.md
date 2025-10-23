# Testing Reminders

## In-App Update System (upgrader package)
**Added:** 2025-10-17
**Status:** ⏳ Pending Production Test

### What to Test:
1. Publish version 1.0.0 to App Store
2. After users install, publish version 1.0.1
3. Users should see update dialog on app launch

### Expected Behavior:
- iOS-style (Cupertino) dialog appears
- Shows "Update Now" and "Later" buttons
- After dismissing, won't show again for 24 hours
- Clicking "Update Now" takes user to App Store

### Notes:
- Won't work in simulator/development (no published version to check against)
- Only works with actual App Store releases
- Configuration: lib/main.dart:112-119

---

## Crisis Dialog Styling
**Updated:** 2025-10-17
**Status:** ✅ Updated (visual check recommended)

### What to Test:
- Go to AI Chat
- Type crisis keywords: "hurt myself", "suicide", etc.
- Verify dialog uses white text throughout (not red)
- Red warning icon should still appear

---

## Offline Mode Toggle Removal
**Updated:** 2025-10-17
**Status:** ✅ Removed

### What to Test:
- Open Settings → Data & Privacy
- Verify "Offline Mode" toggle is no longer present
- Only "Clear Cache" and "Export Data" should show
