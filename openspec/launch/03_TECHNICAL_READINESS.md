# Technical Readiness & Security Audit

**Priority:** P0 (Blocker for App Store submission)
**Est. Time:** 2-3 days
**Owner:** Developer + Security Review

---

## 🎯 Overview

This checklist ensures the app is technically sound, secure, and meets Apple's App Store technical requirements. Complete all P0 items before submission.

---

## 🔒 Security Audit Checklist

### API Key Security (P0)

- [ ] **Environment Variables Protection**
  - API keys stored in `.env` file (NOT committed to git)
  - `.env` listed in `.gitignore`
  - Verify: `git log --all -- .env` returns nothing
  - Production keys different from development keys

- [ ] **Google AI API Key**
  - Location: `assets/.env` → `GEMINI_API_KEY`
  - Loaded via `flutter_dotenv` package (pubspec.yaml:65)
  - Key has IP/domain restrictions in Google Cloud Console
  - Usage quotas configured to prevent abuse
  - Test: Confirm key works in production build

- [ ] **API Key Obfuscation**
  ```bash
  # Check that .env is NOT in version control
  git ls-files | grep -i "\.env"  # Should return nothing

  # Check for hardcoded secrets
  grep -r "AIza" lib/ --exclude-dir=.git  # Should return nothing
  ```

**Action Items:**
1. Add `.env` to `.gitignore` if not already present
2. Configure API key restrictions in Google Cloud Console
3. Set up billing alerts for AI API usage
4. Document key rotation procedure

---

### Data Encryption (P0)

- [ ] **At-Rest Encryption**
  - SQLite database: Native iOS encryption (no additional action needed)
  - SharedPreferences: Native iOS keychain (secure by default)
  - Secure storage: Using `flutter_secure_storage: ^9.0.0` (pubspec.yaml:25)
  - Verify: User data encrypted when device locked

- [ ] **Sensitive Data Protection**
  ```dart
  // Files to audit:
  // lib/features/auth/services/secure_storage_service.dart - Biometric data
  // lib/core/services/database_service.dart - Prayer journal, chat history
  // lib/core/services/preferences_service.dart - User settings
  ```
  - Prayer journal: Stored in encrypted SQLite
  - Chat history: Stored in encrypted SQLite
  - User profile picture: Stored in app documents (iOS sandboxed)
  - No sensitive data in logs or analytics

- [ ] **Data Deletion Verification**
  - "Delete All Data" completely removes user data (settings_screen.dart:1376-1431)
  - Test: Delete data → Check file system → No residual files
  - Test: Uninstall app → Reinstall → No data persists (unless subscription restored)

**Action Items:**
1. Audit all database queries for proper encryption
2. Test data deletion on physical device
3. Verify no sensitive data logged in production

---

### Network Security (P0)

- [ ] **HTTPS-Only Communication**
  - All API calls use HTTPS (Google AI, in-app purchases)
  - No HTTP endpoints in production
  - Certificate pinning considered (optional for now)

- [ ] **API Request Validation**
  ```dart
  // File: lib/services/ai_service.dart
  ```
  - Input sanitization for AI prompts
  - Rate limiting implemented (subscription service)
  - Timeout configuration for network requests
  - Error handling for network failures

- [ ] **Third-Party Dependencies**
  - All packages from pub.dev (verified source)
  - No deprecated packages (check with `flutter pub outdated`)
  - Security audit of critical packages:
    - `google_generative_ai: ^0.4.0` - Official Google package ✅
    - `in_app_purchase: ^3.1.13` - Official Flutter package ✅
    - `flutter_secure_storage: ^9.0.0` - Well-maintained, 2.5k+ stars ✅

**Action Items:**
1. Run `flutter pub outdated` and update critical packages
2. Review `ai_service.dart` for input sanitization
3. Test network error handling (airplane mode)

---

### Authentication & Authorization (P1)

- [ ] **Biometric Authentication**
  - Optional feature (lib/features/auth/services/biometric_service.dart)
  - Proper permission requests (Info.plist)
  - Fallback to device passcode
  - No plaintext passwords stored

- [ ] **Session Management**
  - No user authentication required (privacy-first design)
  - App state managed locally
  - No session tokens or cookies

- [ ] **Subscription Validation**
  ```dart
  // File: lib/core/services/subscription_service.dart
  ```
  - Receipt validation with Apple StoreKit
  - No client-side subscription bypasses
  - Expiry date checking
  - Restore purchases functionality

**Action Items:**
1. Test biometric authentication on multiple device types
2. Verify subscription receipt validation works
3. Test "Restore Purchases" with real Apple ID

---

## 📱 iOS-Specific Requirements

### App Store Connect Configuration (P0)

- [ ] **Bundle Identifier**
  - Format: `com.yourcompany.everydaychristian`
  - Matches Xcode project configuration
  - Registered in Apple Developer account

- [ ] **Signing & Certificates**
  - Distribution certificate valid
  - Provisioning profile configured
  - App Store distribution profile (not Ad Hoc)
  - Automatic signing enabled in Xcode (recommended)

- [ ] **Privacy Manifest (iOS 17+)**
  - Required APIs declared:
    - File timestamp APIs (reading Bible database)
    - UserDefaults APIs (SharedPreferences)
    - System boot time APIs (if used)
  - Location: `ios/Runner/PrivacyInfo.xcprivacy`
  - Test: Build succeeds without privacy warnings

- [ ] **Info.plist Permissions**
  ```xml
  <!-- Required permissions to declare: -->
  <key>NSPhotoLibraryUsageDescription</key>
  <string>Upload a profile picture for personalization</string>

  <key>NSCameraUsageDescription</key>
  <string>Take a profile picture</string>

  <key>NSFaceIDUsageDescription</key>
  <string>Use Face ID to secure your prayer journal</string>

  <key>NSUserNotificationsUsageDescription</key>
  <string>Receive daily devotional and prayer reminders</string>
  ```

**Action Items:**
1. Create `ios/Runner/PrivacyInfo.xcprivacy` if missing
2. Verify all Info.plist permission descriptions are user-friendly
3. Test that permission requests appear correctly

---

### Build Configuration (P0)

- [ ] **Release Build Settings**
  ```bash
  # Build release iOS app
  flutter build ios --release

  # Expected output: No errors, warnings acceptable
  # Check build size: Should be <100 MB for iOS
  ```
  - No debug symbols in release build
  - Code obfuscation enabled (optional but recommended)
  - Build warnings reviewed and resolved

- [ ] **App Size Optimization**
  - Current size estimate: ~50 MB (Bible database ~10 MB, AI SDK ~5 MB)
  - Target: Under 100 MB for cellular downloads
  - Assets compressed (images, icons)
  - Unused resources removed

- [ ] **Performance Benchmarks**
  - App launch time: <3 seconds (splash to home)
  - Bible search: <500ms for verse lookup
  - AI chat response: <5 seconds (network dependent)
  - Scroll performance: 60 FPS (no jank)
  - Memory usage: <200 MB peak

**Action Items:**
1. Run `flutter build ios --release` and fix all errors
2. Measure app size: `ls -lh build/ios/Release-iphoneos/*.app`
3. Profile performance with Xcode Instruments

---

### StoreKit Configuration (P0)

- [ ] **In-App Purchase Setup**
  - Product ID: `com.yourcompany.everydaychristian.premium.yearly`
  - Price: $34.99/year (or regional equivalent)
  - Subscription duration: 1 year
  - Free trial: 3 days (configured in App Store Connect)
  - Auto-renewable subscription type

- [ ] **StoreKit Testing**
  - Sandbox account created in App Store Connect
  - Test purchase flow in debug mode
  - Test trial expiration (manually advance time)
  - Test restore purchases
  - Test cancellation

- [ ] **Subscription Disclosure**
  - Auto-renewal terms in app description (App Store requirement)
  - Link to subscription terms in paywall screen
  - Clear cancellation instructions
  - FTC compliance (see 01_LEGAL_COMPLIANCE.md)

**Action Items:**
1. Configure subscription product in App Store Connect
2. Create StoreKit configuration file for local testing
3. Test full purchase flow with sandbox account

---

## 🧪 Testing Checklist

### Functional Testing (P0)

- [ ] **Core Features**
  - ✅ Onboarding flow (name entry, feature preview)
  - ✅ Home screen navigation
  - ✅ AI chat (send message, receive response)
  - ✅ Bible reading (KJV & RVR1909)
  - ✅ Verse search and favorites
  - ✅ Prayer journal (create, edit, delete)
  - ✅ Settings (theme, language, text size, notifications)

- [ ] **Subscription Flow**
  - Trial starts on first message send
  - 5 messages/day limit enforced
  - Paywall appears when limit reached
  - Purchase flow completes successfully
  - Premium unlocks 150 messages/month
  - Restore purchases works

- [ ] **Edge Cases**
  - Offline mode (Bible still works, AI chat shows error)
  - Network interruption during AI response
  - App backgrounded during chat
  - Notifications while app closed
  - Delete all data (clean slate)

**Action Items:**
1. Create test plan document with all user flows
2. Test on iPhone SE (small screen) and iPhone 15 Pro Max (large screen)
3. Test on iOS 15, iOS 16, iOS 17 (minimum supported versions)

---

### Crash & Error Testing (P0)

- [ ] **Error Handling**
  ```dart
  // Files to audit:
  // lib/core/error/error_handler.dart
  // lib/core/logging/app_logger.dart
  ```
  - All async operations wrapped in try-catch
  - User-friendly error messages (no stack traces shown)
  - Errors logged for debugging (console only, no external service)
  - App doesn't crash on network failures

- [ ] **Common Crash Scenarios**
  - AI API rate limit exceeded
  - Database corruption (rare but possible)
  - Out of memory (large chat history)
  - Invalid subscription receipt
  - Missing .env file (should fail gracefully)

**Action Items:**
1. Audit error handling in all services
2. Simulate network failures and API errors
3. Test with intentionally corrupted database

---

### Performance Testing (P1)

- [ ] **Memory Leaks**
  - Run Xcode Instruments → Leaks tool
  - Scroll through chat history (no memory buildup)
  - Open/close screens repeatedly
  - Target: No leaks detected

- [ ] **Battery Usage**
  - Background behavior: Minimal battery drain
  - AI requests: Efficient (don't spam API)
  - Animations: GPU-accelerated, no excessive CPU usage

- [ ] **Database Performance**
  - Bible verse lookup: <500ms
  - Prayer journal queries: <100ms
  - Chat history loading: <1s for 100 messages
  - Indexes configured properly (see database_service.dart)

**Action Items:**
1. Profile with Xcode Instruments (Allocations, Leaks, Time Profiler)
2. Test with 1000+ prayer entries and 500+ chat messages
3. Optimize database queries if needed

---

## 🔍 Code Quality Audit

### Static Analysis (P1)

- [ ] **Flutter Analyze**
  ```bash
  flutter analyze
  # Expected: 0 errors, <10 warnings
  ```
  - No analyzer errors
  - Warnings reviewed and addressed
  - Unused imports removed
  - Dead code eliminated

- [ ] **Dart Code Metrics**
  - Cyclomatic complexity: <15 per function (simpler is better)
  - Lines per file: <500 (exceptions for screens)
  - Function length: <50 lines (exceptions acceptable)
  - TODOs addressed or documented

**Action Items:**
1. Run `flutter analyze` and fix all errors
2. Review warnings and address critical ones
3. Refactor complex functions (complexity >15)

---

### Dependency Audit (P1)

- [ ] **Outdated Packages**
  ```bash
  flutter pub outdated
  # Review: Major version updates (breaking changes)
  # Action: Update patch and minor versions
  ```

- [ ] **Vulnerable Dependencies**
  - No known security vulnerabilities
  - Check: https://pub.dev/packages/[package]/score (security tab)
  - Critical packages up-to-date:
    - `flutter_secure_storage: ^9.0.0` ✅
    - `in_app_purchase: ^3.1.13` ✅
    - `google_generative_ai: ^0.4.0` ✅

- [ ] **Unnecessary Dependencies**
  - Remove unused packages
  - Reduce bundle size
  - Minimize dependency conflicts

**Action Items:**
1. Run `flutter pub outdated` and update safe packages
2. Check security scores on pub.dev for critical packages
3. Remove unused dependencies from pubspec.yaml

---

## 🚨 Pre-Submission Checklist

### Final Build Verification (P0)

- [ ] **Clean Build**
  ```bash
  flutter clean
  flutter pub get
  flutter build ios --release
  ```
  - Build completes without errors
  - App runs on physical device (not just simulator)
  - Archive created successfully in Xcode

- [ ] **Archive Upload**
  - Open Xcode → Product → Archive
  - Upload to App Store Connect
  - Processing completes (can take 10-30 minutes)
  - Build appears in TestFlight section

- [ ] **TestFlight Build**
  - Export compliance information completed (NO encryption exports)
  - Build available for internal testing
  - Install on device via TestFlight
  - Smoke test: App launches, core features work

**Action Items:**
1. Create release build and archive
2. Upload to App Store Connect
3. Complete export compliance form
4. Test TestFlight build on physical device

---

## 📊 Technical Readiness Score

**Before Submission, Verify:**

| Category | Items | Completed | Score |
|----------|-------|-----------|-------|
| Security Audit | 15 | __ / 15 | __% |
| iOS Requirements | 12 | __ / 12 | __% |
| Testing | 10 | __ / 10 | __% |
| Code Quality | 8 | __ / 8 | __% |
| Pre-Submission | 6 | __ / 6 | __% |
| **TOTAL** | **51** | **__ / 51** | **__%** |

**Target: 100% (51/51) before App Store submission**

---

## 🔧 Tools & Resources

### Development Tools
- **Xcode**: Archive and upload to App Store
- **Flutter DevTools**: Performance profiling
- **Xcode Instruments**: Memory leaks, battery usage
- **App Store Connect**: Build management, TestFlight

### Security Tools
- **`git log` search**: Find accidentally committed secrets
- **`flutter analyze`**: Static code analysis
- **Xcode Static Analyzer**: C/C++/Objective-C code (iOS native)

### Testing Tools
- **Sandbox Account**: Test in-app purchases
- **StoreKit Configuration File**: Local IAP testing (no server)
- **Charles Proxy / Proxyman**: Network debugging
- **TestFlight**: Beta distribution and testing

---

## 🚀 Next Steps

**After completing this checklist:**
1. ✅ Complete security audit (P0 items)
2. ✅ Build release archive
3. ✅ Upload to App Store Connect
4. → Move to **04_SUBSCRIPTION_TESTING.md** for trial/purchase testing
5. → Move to **05_PRIVACY_SECURITY.md** for privacy review
6. → Move to **06_CONTENT_REVIEW.md** for theological content audit

---

**Last Updated:** 2025-01-20
**Status:** Ready for review
**Estimated Completion:** 2-3 days
