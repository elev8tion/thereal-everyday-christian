# Privacy & Security Implementation Verification

**Priority:** P0 (Blocker for App Store submission)
**Est. Time:** 1-2 days
**Owner:** Developer + Legal Review (if applicable)

---

## 🎯 Overview

Privacy is **non-negotiable** for a faith-based app handling:
- Personal prayers (highly sensitive)
- Spiritual conversations with AI
- Bible reading history
- Profile information

**Core Principle:** Privacy-first design. No user authentication = minimal data collection.

**Legal Compliance:**
- GDPR (European users)
- CCPA (California users)
- Apple App Store Privacy Requirements
- FTC data collection disclosures

---

## 🔐 Data Collection Audit

### What Data Do We Collect?

| Data Type | Location | Purpose | Sharing | Retention |
|-----------|----------|---------|---------|-----------|
| **First Name** | SharedPreferences | Personalization ("Hi, John") | None | Until deleted |
| **Prayer Journal** | SQLite (local) | User's prayer requests/answers | None | Until deleted |
| **Chat History** | SQLite (local) | AI conversations | Sent to Google AI API | Until deleted |
| **Bible Favorites** | SQLite (local) | Saved verses | None | Until deleted |
| **Profile Picture** | App Documents | Avatar | None | Until deleted |
| **Settings** | SharedPreferences | Theme, language, text size | None | Until deleted |
| **Subscription Receipt** | SharedPreferences | Premium validation | Apple (for verification) | Until deleted |
| **Device ID** | iOS auto-generated | In-app purchase tracking | Apple only | iOS managed |

**✅ What We DON'T Collect:**
- No email addresses
- No phone numbers
- No real names (optional first name only)
- No location data
- No usage analytics (unless opt-in added later)
- No third-party tracking
- No advertising identifiers

---

## 📱 Privacy Manifest (iOS 17+)

### Required: PrivacyInfo.xcprivacy

**Location:** `ios/Runner/PrivacyInfo.xcprivacy`

**Purpose:** Declare all iOS "required reason APIs" used in the app.

**Required Declarations:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Privacy Tracking Domains (none) -->
    <key>NSPrivacyTracking</key>
    <false/>

    <!-- Privacy Tracking Domains List -->
    <key>NSPrivacyTrackingDomains</key>
    <array/>

    <!-- Privacy Collected Data Types -->
    <key>NSPrivacyCollectedDataTypes</key>
    <array>
        <!-- Name (optional first name) -->
        <dict>
            <key>NSPrivacyCollectedDataType</key>
            <string>NSPrivacyCollectedDataTypeName</string>
            <key>NSPrivacyCollectedDataTypeLinked</key>
            <false/>
            <key>NSPrivacyCollectedDataTypeTracking</key>
            <false/>
            <key>NSPrivacyCollectedDataTypePurposes</key>
            <array>
                <string>NSPrivacyCollectedDataTypePurposeAppFunctionality</string>
            </array>
        </dict>

        <!-- User Content (prayers, chat) -->
        <dict>
            <key>NSPrivacyCollectedDataType</key>
            <string>NSPrivacyCollectedDataTypeOtherUserContent</string>
            <key>NSPrivacyCollectedDataTypeLinked</key>
            <false/>
            <key>NSPrivacyCollectedDataTypeTracking</key>
            <false/>
            <key>NSPrivacyCollectedDataTypePurposes</key>
            <array>
                <string>NSPrivacyCollectedDataTypePurposeAppFunctionality</string>
            </array>
        </dict>
    </array>

    <!-- Privacy Accessed API Types (required reason APIs) -->
    <key>NSPrivacyAccessedAPITypes</key>
    <array>
        <!-- UserDefaults API -->
        <dict>
            <key>NSPrivacyAccessedAPIType</key>
            <string>NSPrivacyAccessedAPICategoryUserDefaults</string>
            <key>NSPrivacyAccessedAPITypeReasons</key>
            <array>
                <string>CA92.1</string> <!-- Store user preferences -->
            </array>
        </dict>

        <!-- File timestamp API -->
        <dict>
            <key>NSPrivacyAccessedAPIType</key>
            <string>NSPrivacyAccessedAPICategoryFileTimestamp</string>
            <key>NSPrivacyAccessedAPITypeReasons</key>
            <array>
                <string>C617.1</string> <!-- Access file timestamps for app functionality -->
            </array>
        </dict>

        <!-- System boot time API (if used) -->
        <dict>
            <key>NSPrivacyAccessedAPIType</key>
            <string>NSPrivacyAccessedAPICategorySystemBootTime</string>
            <key>NSPrivacyAccessedAPITypeReasons</key>
            <array>
                <string>35F9.1</string> <!-- Measure time intervals -->
            </array>
        </dict>
    </array>
</dict>
</plist>
```

**Verification:**
```bash
# Check if file exists
ls -la ios/Runner/PrivacyInfo.xcprivacy

# Validate XML syntax
plutil -lint ios/Runner/PrivacyInfo.xcprivacy
```

**Pass Criteria:**
- [ ] PrivacyInfo.xcprivacy exists
- [ ] All required reason APIs declared
- [ ] NSPrivacyTracking = false (no tracking)
- [ ] Data collection accurately described

---

## 🔒 Data Storage Security

### Local Storage Audit

**1. SQLite Database (Prayer Journal, Chat History, Verses)**

Location: `lib/core/services/database_service.dart`

**Security Checklist:**
- [ ] Database stored in iOS app sandbox (secure by default)
- [ ] No world-readable files
- [ ] iOS encrypts data when device locked (iOS 15+)
- [ ] "Delete All Data" completely removes database

**Verification:**
```bash
# Check database permissions (iOS Simulator)
xcrun simctl get_app_container booted com.yourcompany.everydaychristian data
cd Library/Application\ Support
ls -la *.db
# Should be: -rw------- (read/write for app only)
```

**2. SharedPreferences (Settings, Trial Status, Subscription)**

Location: `lib/core/services/preferences_service.dart`

**Security Checklist:**
- [ ] Stored in iOS plist (secure by default)
- [ ] No sensitive authentication tokens (we don't use auth)
- [ ] Subscription receipt stored (required for restore)
- [ ] Settings data non-sensitive (theme, language, etc.)

**3. Secure Storage (Biometric Data, Future Use)**

Location: `lib/features/auth/services/secure_storage_service.dart`

**Security Checklist:**
- [ ] Uses `flutter_secure_storage` (iOS Keychain)
- [ ] Biometric authentication optional (user choice)
- [ ] No passwords or auth tokens stored
- [ ] Data encrypted at rest via iOS Keychain

**Verification:**
```dart
// Test secure storage deletion
final secureStorage = FlutterSecureStorage();
await secureStorage.deleteAll();
// Verify: Biometric settings reset
```

---

## 🌐 Network Privacy

### Third-Party Data Sharing

**Google Generative AI (Gemini)**

**What We Send:**
- User's chat message text
- Conversation context (last 10 messages for continuity)
- System prompt (instructions for biblical guidance)

**What We DON'T Send:**
- User name
- Device ID
- Location
- Email/phone
- Other app data (prayers, Bible history)

**Privacy Checklist:**
- [ ] Only chat messages sent to Google AI
- [ ] No PII (personally identifiable information) in prompts
- [ ] Prayer journal NOT sent to AI (local only)
- [ ] Conversation history stored locally, not on Google servers

**Verification:**
```dart
// File: lib/services/ai_service.dart
// Audit: Ensure no user identifiers in API requests
```

**Apple In-App Purchase**

**What Apple Collects:**
- Apple ID (for subscription tracking)
- Purchase receipt
- Device identifier (for multi-device support)
- Payment information (handled by Apple, we never see it)

**Privacy Checklist:**
- [ ] We only store receipt (base64 string)
- [ ] No payment details stored in app
- [ ] Apple handles all billing/PII

---

## 📄 Privacy Policy Requirements

### Required Disclosures

**Privacy Policy Must Include:**
1. **Data We Collect**
   - Optional first name
   - Prayer journal entries (local only)
   - AI chat messages (sent to Google AI)
   - Bible favorites and reading history (local only)
   - App settings and preferences

2. **How We Use Data**
   - Personalization (first name)
   - AI-powered biblical guidance (chat)
   - Subscription management (Apple receipts)
   - App functionality (settings, prayers, verses)

3. **Data Sharing**
   - Google AI: Chat messages only (for AI responses)
   - Apple: Subscription receipts (for purchase verification)
   - No other third parties

4. **Data Retention**
   - Data stored locally on device
   - Retained until user deletes via "Delete All Data"
   - Subscription data retained until cancellation

5. **User Rights**
   - Right to delete all data (one-tap deletion)
   - Right to export data (future feature consideration)
   - No data portability required (local-only storage)

6. **Children's Privacy**
   - App rated 13+ (no COPPA requirements)
   - No data collection from children under 13

7. **Contact Information**
   - Support email: support@everydaychristian.com (or your email)
   - Physical address (if required by GDPR)

**Action Items:**
- [ ] Review Privacy Policy template (see 01_LEGAL_COMPLIANCE.md)
- [ ] Update privacy policy with accurate data practices
- [ ] Host privacy policy at: https://everydaychristian.com/privacy
- [ ] Link privacy policy in App Store Connect
- [ ] Link privacy policy in app (Settings → Privacy Policy)

---

## 🔐 Data Deletion Verification

### "Delete All Data" Feature

**Location:** `lib/screens/settings_screen.dart:1376-1431`

**What Gets Deleted:**
```dart
1. dbService.resetDatabase()
   - Prayer journal entries
   - Chat history
   - Saved verses
   - Reading progress

2. prefs.clear()
   - First name
   - Settings (theme, language, text size)
   - Trial status
   - Subscription receipt (will be restored)
   - Notification preferences

3. profileService.removeProfilePicture()
   - Profile picture file

4. Image cache cleanup
   - Cached images
   - Temporary files
```

**What Persists:**
- Subscription status (restored via Apple receipt on next launch)
- Bible database (read-only asset, not user data)

**Testing Checklist:**
- [ ] Test deletion on physical device
- [ ] Verify all SQLite tables emptied
- [ ] Verify SharedPreferences cleared
- [ ] Verify profile picture removed
- [ ] Verify subscription auto-restores on relaunch
- [ ] No residual files in app documents folder

**Verification:**
```bash
# iOS Simulator
xcrun simctl get_app_container booted com.yourcompany.everydaychristian data

# Check directories:
# Documents/ → Should be empty (except bible.db)
# Library/Application Support/ → Empty or recreated defaults
# Library/Preferences/ → Only subscription data after restore
```

**Pass Criteria:**
- Complete data deletion ✅
- No user content remains ✅
- Subscription restored automatically ✅

---

## 🌍 GDPR Compliance (European Users)

### Requirements

**1. Lawful Basis for Processing**
- Consent: First name (optional) → Implied consent by providing it
- Legitimate interest: App functionality (prayers, chat, Bible)
- Contract: Subscription (payment processing)

**2. User Rights**
- ✅ Right to access data: All data stored locally (user has access)
- ✅ Right to erasure: "Delete All Data" feature
- ✅ Right to data portability: Not applicable (local-only storage)
- ✅ Right to object: User can decline data collection (don't provide name)
- ✅ Right to rectification: User can edit prayers, settings

**3. Data Protection**
- ✅ Data minimization: Only collect essential data
- ✅ Storage limitation: Data deleted on user request
- ✅ Security: iOS encryption at rest
- ✅ Privacy by design: No unnecessary data collection

**Action Items:**
- [ ] Add GDPR disclosure to Privacy Policy
- [ ] Provide data access instructions (all local)
- [ ] Ensure deletion is permanent and complete

---

## 🇺🇸 CCPA Compliance (California Users)

### Requirements

**1. Disclosures**
- Categories of data collected: Name, user content (prayers, chat)
- Purpose: App functionality, personalization
- Third parties: Google AI (chat only), Apple (subscriptions)

**2. User Rights**
- ✅ Right to know: Privacy policy describes data practices
- ✅ Right to delete: "Delete All Data" feature
- ✅ Right to opt-out of sale: We don't sell data (N/A)

**3. Do Not Sell My Personal Information**
- ✅ We don't sell data → No "Do Not Sell" toggle needed
- ✅ Disclose in privacy policy: "We do not sell your personal information"

**Action Items:**
- [ ] Add CCPA disclosure to Privacy Policy
- [ ] Confirm: No data sales or sharing for advertising

---

## 📱 App Store Privacy Labels

### App Store Connect → App Privacy

**What to Declare:**

**1. Contact Info**
- ❌ Name: Collected (optional first name)
  - Linked to user: No
  - Used for tracking: No
  - Purpose: App functionality (personalization)

**2. User Content**
- ✅ Other User Content: Collected (prayers, chat)
  - Linked to user: No
  - Used for tracking: No
  - Purpose: App functionality

**3. Identifiers**
- ✅ Device ID: Collected by Apple (in-app purchases)
  - Linked to user: Yes (by Apple, not us)
  - Used for tracking: No
  - Purpose: Subscription management

**4. Purchases**
- ✅ Purchase History: Collected by Apple
  - Linked to user: Yes (by Apple)
  - Used for tracking: No
  - Purpose: Subscription validation

**Privacy Label Summary:**
```
Data Not Linked to You:
- Name (first name, optional)
- User Content (prayers, chat)

Data Linked to You (by Apple):
- Purchases
- Device ID (for subscription tracking)

Data Used to Track You:
- None
```

**Action Items:**
- [ ] Complete App Privacy questionnaire in App Store Connect
- [ ] Match privacy labels to actual data practices
- [ ] Review before each app update (changes require re-declaration)

---

## 🔒 Permissions & User Consent

### Required iOS Permissions

**1. Photo Library (Profile Picture)**
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Upload a profile picture to personalize your experience</string>
```
- Triggered: When user taps "Change Profile Picture"
- Consent: User can deny, app still works

**2. Camera (Profile Picture)**
```xml
<key>NSCameraUsageDescription</key>
<string>Take a profile picture</string>
```
- Triggered: When user taps "Take Photo"
- Consent: User can deny, upload from library instead

**3. Face ID / Touch ID (Optional Security)**
```xml
<key>NSFaceIDUsageDescription</key>
<string>Use Face ID to secure your prayer journal</string>
```
- Triggered: When user enables biometric lock
- Consent: Completely optional feature

**4. Notifications (Devotional Reminders)**
```xml
<key>NSUserNotificationsUsageDescription</key>
<string>Receive daily devotional and prayer reminders</string>
```
- Triggered: On app first launch (splash screen)
- Consent: User can deny, app still works

**Testing Checklist:**
- [ ] All permission dialogs show user-friendly descriptions
- [ ] App works gracefully when permissions denied
- [ ] No crashes when permissions revoked mid-session
- [ ] Settings provide link to re-enable permissions (iOS Settings)

---

## 🧪 Privacy Testing Checklist

### Manual Testing

- [ ] **Fresh Install → No Data Leakage**
  - Install app on clean device
  - Verify no data from previous installs
  - Subscription restores correctly (if applicable)

- [ ] **Delete All Data → Complete Removal**
  - Use app extensively (prayers, chat, favorites)
  - Delete all data
  - Verify file system clean (see commands above)

- [ ] **Permission Denials → Graceful Handling**
  - Deny photo library → Can't upload picture, no crash
  - Deny camera → Can't take photo, no crash
  - Deny notifications → No reminders, app works

- [ ] **Offline Mode → No Data Leaks**
  - Enable airplane mode
  - Use app (Bible, prayers)
  - Verify no network requests (except when online required)

- [ ] **Third-Party Sharing Audit**
  - Monitor network traffic (Charles Proxy / Proxyman)
  - Verify only expected domains:
    - `generativelanguage.googleapis.com` (Google AI)
    - `buy.itunes.apple.com` (App Store)
  - No analytics domains (unless explicitly added)

---

## 📊 Privacy Compliance Score

**Before Submission, Verify:**

| Category | Items | Completed | Score |
|----------|-------|-----------|-------|
| Privacy Manifest | 4 | __ / 4 | __% |
| Data Storage Security | 6 | __ / 6 | __% |
| Network Privacy | 4 | __ / 4 | __% |
| Privacy Policy | 7 | __ / 7 | __% |
| Data Deletion | 6 | __ / 6 | __% |
| GDPR Compliance | 5 | __ / 5 | __% |
| CCPA Compliance | 3 | __ / 3 | __% |
| App Store Privacy Labels | 4 | __ / 4 | __% |
| Permissions | 4 | __ / 4 | __% |
| **TOTAL** | **43** | **__ / 43** | **__%** |

**Target: 100% (43/43) before App Store submission**

---

## 🚨 Common Privacy Pitfalls to Avoid

**1. Analytics Without Consent**
- ❌ Don't add Google Analytics, Firebase, or Mixpanel without explicit opt-in
- ✅ If adding analytics later, make it opt-in with clear disclosure

**2. Third-Party SDKs**
- ❌ Don't integrate ad networks (we have no ads)
- ❌ Don't use social media SDKs (no Facebook/Twitter login)
- ✅ Only essential SDKs: Google AI, in_app_purchase, flutter packages

**3. Logging Sensitive Data**
- ❌ Don't log prayer content or chat messages in production
- ❌ Don't log user names or identifiers
- ✅ Only log errors and debugging info (no PII)

**4. Data Retention**
- ❌ Don't keep deleted data in backups or caches
- ✅ "Delete All Data" must be permanent

**5. Privacy Policy Outdated**
- ❌ Don't add features without updating privacy policy
- ✅ Review and update policy with each major release

---

## 🔧 Tools & Resources

### Privacy Testing Tools
- **Charles Proxy / Proxyman**: Monitor network requests
- **Xcode Instruments**: File system activity
- **iOS Settings → Privacy**: Check permission status

### Legal Resources
- **GDPR Checklist**: https://gdpr.eu/checklist/
- **CCPA Compliance**: https://oag.ca.gov/privacy/ccpa
- **Apple Privacy Guidelines**: https://developer.apple.com/app-store/app-privacy-details/

### Privacy Policy Generators
- **TermsFeed**: Free privacy policy generator
- **iubenda**: Privacy policy compliance tool
- **PrivacyPolicies.com**: Customizable templates

---

## 🚀 Next Steps

**After completing privacy verification:**
1. ✅ Create/verify PrivacyInfo.xcprivacy
2. ✅ Update Privacy Policy with accurate disclosures
3. ✅ Complete App Store Privacy Labels
4. ✅ Test data deletion thoroughly
5. → Move to **06_CONTENT_REVIEW.md** for theological content audit
6. → Move to **07_BETA_TESTING.md** for TestFlight beta plan

---

**Last Updated:** 2025-01-20
**Status:** Ready for review
**Estimated Completion:** 1-2 days
