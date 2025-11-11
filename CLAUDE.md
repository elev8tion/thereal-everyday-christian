<!-- OPENSPEC:START -->
# OpenSpec Instructions

These instructions are for AI assistants working in this project.

Always open `@/openspec/AGENTS.md` when the request:
- Mentions planning or proposals (words like proposal, spec, change, plan)
- Introduces new capabilities, breaking changes, architecture shifts, or big performance/security work
- Sounds ambiguous and you need the authoritative spec before coding

Use `@/openspec/AGENTS.md` to learn:
- How to create and apply change proposals
- Spec format and conventions
- Project structure and guidelines

Keep this managed block so 'openspec update' can refresh the instructions.

<!-- OPENSPEC:END -->

---

# Everyday Christian - AI Assistant Guide

**Last Updated:** 2025-11-03
**App Status:** ✅ 9/10 Ready for App Store Submission
**Database Version:** 10 (shared_chats table added)

---

## 🚀 Quick Reference (Read This First)

### **App Readiness Status**
- ✅ **Subscription System:** Complete (eventual consistency model)
- ✅ **Content:** 424 devotionals (Nov 2025 - Dec 2026), 10+ reading plans
- ✅ **Legal Compliance:** Privacy Policy + Terms of Service complete
- ✅ **Trial Abuse Prevention:** Keychain/Keystore tracking (survives uninstall)
- ✅ **API Key Security:** Client-side storage with Google Cloud restrictions (compliant)
- ⏳ **TestFlight Beta:** Not started (next step)

### **Known Non-Issues (Don't Flag These)**
- ✅ `debugPrint()` and `kDebugMode` → Flutter strips these in release builds (standard practice)
- ✅ API key in `.env` → Acceptable for privacy-first apps (industry standard for no-backend architecture)
- ✅ Receipt validation "TODO" comment → Platform APIs handle this (eventual consistency model)
- ✅ Devotional content → 27 files, 424 devotionals complete
- ✅ Reading plans → 10+ plans (3 book-based in database + 4 curated in JSON)

---

## 📋 Key Architecture Decisions

### **1. Subscription System (Privacy-First Approach)**

**Implementation:** Eventual consistency via platform APIs
**Location:** `lib/core/services/subscription_service.dart`

**How It Works:**
- `restorePurchases()` called on every app launch (line 114)
- Platform (App Store/Play Store) returns ONLY active subscriptions
- Local 365-day placeholder immediately overwritten by platform data
- Trial tracking via iOS Keychain/Android Keystore (survives app uninstall)

**Trade-off:**
- ❌ No real-time cancellation detection (requires backend)
- ✅ Privacy-first (no server, no user tracking)
- ✅ Eventual consistency acceptable (detected on next app launch)

**Documentation:** `openspec/archive/subscription-refactor-completed-2025-01-19/RESEARCH_CANCELLATION_DETECTION.md` (333 lines)

**Code Note:** Line 641 has TODO comment, but feature is **complete via platform APIs** (comment is misleading, not incomplete)

---

### **2. API Key Security (Client-Side Storage)**

**Implementation:** `.env` file bundled in app assets
**Location:** `pubspec.yaml:96`, `lib/services/gemini_ai_service.dart:38-43`

**Why This Is Safe:**
1. ✅ `.env` in `.gitignore` (not in Git repo)
2. ✅ Google Cloud Console restrictions (bundle ID, package name, API quota)
3. ✅ Client-side message limits (15 trial, 150/month premium)
4. ✅ Trial abuse prevention (Keychain/Keystore tracking)
5. ✅ Platform subscription validation (can't fake premium)

**Industry Standard:**
- Google Maps API, Firebase, OpenAI all use client-side keys
- Acceptable for apps without backend infrastructure
- **App Store & Play Store compliant** (third-party API keys ≠ user credentials)

**Post-Launch Task:**
- Add Google Cloud Console restrictions:
  - Application restrictions (bundle ID: `com.everydaychristian.app`)
  - API restrictions (Generative Language API only)
  - Billing alerts ($50/month warning, $100/month cap)

---

### **3. Content Strategy**

**Devotionals:**
- **424 devotionals** across 27 JSON files
- Coverage: Nov 3, 2025 → Dec 31, 2026 (14+ months)
- Structure: 8 sections per devotional
- Location: `assets/devotionals/`
- Documentation: `assets/devotionals/BATCH_COMPLETION_SUMMARY.md`

**Bible Translations:**
- **English:** WEB (World English Bible) - Public domain
  - Database: `assets/bible.db`
  - 31,103 verses
- **Spanish:** RVR1909 (Reina-Valera 1909) - Public domain
  - Database: `assets/spanish_bible_rvr1909.db`
  - 31,103 verses
  - Classic translation, widely recognized

**Reading Plans:**
- **10+ plans total:**
  - 3 book-based plans in `lib/core/database/database_helper.dart` (lines 1005-1081)
    - Gospel of John (21 days)
    - Proverbs (31 days)
    - Psalms for Prayer (30 days)
  - 4 curated thematic plans in `assets/reading_plans/curated_thematic_plans.json`
    - 30 Days of Grace
    - Finding Peace in Anxiety
    - Advent Journey
    - Identity in Christ
  - 6 additional generator-based plans (One Year Bible, Paul's Letters, etc.)

---

### **4. Trial & Subscription Business Logic**

**Trial Period:**
- Duration: 3 days OR 15 messages (whichever comes first)
- Messages: 15 total (use anytime within 3 days, no daily limits)
- Tracking: iOS Keychain/Android Keystore (survives uninstall)

**Premium Subscription:**
- Price: $35/year (varies by region)
- Messages: 150 per month
- Auto-renewal: After 3-day trial (unless cancelled)

**Key Files:**
- `lib/core/services/subscription_service.dart` (485 lines)
- `lib/screens/paywall_screen.dart` (460 lines)
- `lib/screens/chat_screen.dart` (message sending logic)

**Implementation Status:**
- ✅ Phase 1: Trial reset abuse prevention
- ✅ Phase 2: Message limit dialogs
- ✅ Phase 3: Chat lockout overlay
- ✅ Phase 4: Auto-subscription logic

---

### **5. Database Schema**

**Current Version:** 10
**Location:** `lib/core/database/database_helper.dart`

**Recent Changes:**
- **v10 (Nov 3, 2025):** Added `shared_chats` table for tracking conversation shares
  - Columns: `id`, `session_id`, `shared_at`
  - Integrated with ChatShareService (`lib/services/chat_share_service.dart`)
  - New achievement: "Conversation Sharer" (10 shares)

**Key Tables:**
- `devotionals` - 8-section format (v9 migration)
- `reading_plans` - Hardcoded + curated plans
- `daily_readings` - Generated reading schedule
- `prayer_requests` - Prayer journal
- `chat_sessions` + `chat_messages` - AI chat history
- `shared_chats` - Conversation sharing tracking (NEW)
- `bible_verses` - 31,103 verses (WEB translation)
- `favorite_verses` - User bookmarks

---

## 🔧 Common Tasks

### **Adding a New Achievement**
1. Update `profile_screen.dart` `_buildAchievements()` method
2. Add provider to `app_providers.dart` (if tracking new metric)
3. Watch provider in `profile_screen.dart` `build()` method
4. Pass to `_buildAchievementsSection()`

**Example:** Conversation Sharer achievement (Nov 3, 2025)
- Provider: `sharedChatsCountProvider` (app_providers.dart:179-189)
- Database: `shared_chats` table
- Achievement: Unlock at 10 shares

### **Database Migration**
1. Increment `_databaseVersion` in `database_helper.dart`
2. Add table/column in `_onCreate()` method
3. Add migration logic in `_onUpgrade()` method with version check
4. Test on fresh install AND existing database

### **Updating Devotional Content**
- Location: `assets/devotionals/`
- Format: JSON array of devotionals (8 sections each)
- Loader: `lib/core/services/devotional_content_loader.dart`
- Max file size: ~84K (keep under 100K for performance)

### **Adding Reading Plans**
**Option A: Hardcoded (simple books)**
- Add to `database_helper.dart` lines 1005-1081
- Used for: One Year Bible, Paul's Letters, etc.

**Option B: Curated (custom selections)**
- Add to `assets/reading_plans/curated_thematic_plans.json`
- Used for: Themed plans with specific verse selections

---

## 📁 Project Structure

```
lib/
├── core/
│   ├── database/
│   │   └── database_helper.dart        # Schema v10, migrations
│   ├── services/
│   │   ├── subscription_service.dart   # Trial & premium logic
│   │   ├── devotional_progress_service.dart
│   │   ├── reading_plan_progress_service.dart
│   │   └── database_service.dart
│   ├── providers/
│   │   └── app_providers.dart          # Riverpod providers
│   └── models/
├── screens/
│   ├── splash_screen.dart              # Entry point
│   ├── legal_agreements_screen.dart    # Terms + Privacy
│   ├── onboarding_screen.dart
│   ├── home_screen.dart
│   ├── chat_screen.dart                # AI chat (Premium)
│   ├── devotional_screen.dart
│   ├── reading_plan_screen.dart
│   ├── profile_screen.dart             # Achievements
│   └── paywall_screen.dart             # Subscription prompts
└── services/
    ├── gemini_ai_service.dart          # Google Gemini API
    └── chat_share_service.dart         # Conversation sharing

assets/
├── devotionals/                        # 27 JSON files, 424 devotionals
├── reading_plans/                      # Curated thematic plans
├── legal/
│   ├── PRIVACY_POLICY.md
│   └── TERMS_OF_SERVICE.md
└── bible.db                            # 31,103 verses (26 MB)

openspec/
├── launch/                             # App Store submission checklists
│   ├── 01_LEGAL_COMPLIANCE.md
│   ├── 02_ASO_ASSETS.md
│   ├── 03_TECHNICAL_READINESS.md
│   ├── 04_SUBSCRIPTION_TESTING.md
│   ├── 05_PRIVACY_SECURITY.md
│   ├── 06_CONTENT_REVIEW.md
│   └── 07_BETA_TESTING.md
└── archive/
    ├── subscription-refactor-completed-2025-01-19/
    │   └── RESEARCH_CANCELLATION_DETECTION.md
    └── oct-2025-audits/

docs/
└── archive/
    ├── pre-launch-tests/               # Test results (Oct 2025)
    └── old-planning/                   # Design docs (archived)
```

---

## 🚦 Pre-Submission Checklist

**Before App Store Submission:**
- [ ] Add Google Cloud Console restrictions (bundle ID, API limits)
- [ ] Update TestFlight release notes
- [ ] Run TestFlight beta (10+ testers, 7+ days)
- [ ] Verify all achievements unlock correctly
- [ ] Test subscription flow (trial → premium → cancellation)
- [ ] Test "Delete All Data" → subscription restores on relaunch
- [ ] Verify crisis detection dialogs appear for test keywords
- [ ] Check VoiceOver accessibility on key screens
- [ ] Update `openspec/launch/README.md` status table

**App Store Review Notes:**
```
EVERYDAY CHRISTIAN - REVIEW NOTES

App Overview:
Christian devotional app with AI pastoral guidance (Premium feature).

Premium Feature Testing:
- AI chat requires subscription ($35/year)
- Free 3-day trial included (15 messages total)
- To test: Use Sandbox tester account

Network Requirements:
- AI chat requires internet (Google Gemini API)
- All other features work offline (Bible, prayer, verses)

Permissions:
- Camera: Profile picture upload
- Photos: Profile picture selection, verse sharing
- Notifications: Daily verses and prayer reminders
- Face ID: Optional biometric lock for prayer journal
- Background audio: Bible chapter TTS playback (can listen while screen locked)

Privacy:
- No user accounts or personal data collection
- AI messages sent anonymously to Google Gemini API
- All data stored locally on device
```

---

## 🐛 Known Issues (None Blocking)

**None.** All critical issues resolved as of Nov 3, 2025.

**Resolved Issues:**
- ✅ Subscription validation (eventual consistency working)
- ✅ Trial abuse prevention (Keychain tracking)
- ✅ Chat history lockout (overlay implemented)
- ✅ Message limit dialogs (Phase 2 complete)
- ✅ Devotional content (424 complete)
- ✅ Reading plans (10+ available)

---

## 📚 Additional Documentation

**For AI Assistants:**
- `/openspec/AGENTS.md` - How to create change proposals
- `/openspec/launch/` - App Store submission guides
- This file (CLAUDE.md) - Quick reference

**For Developers:**
- `README.md` - Project overview, features, setup
- `ENV_SETUP_GUIDE.md` - Development environment setup
- `TESTFLIGHT_RELEASE_NOTES.md` - Current beta status

**For Reference:**
- `openspec/archive/subscription-refactor-completed-2025-01-19/` - Subscription research
- `docs/archive/` - Historical audits and test results

---

**Questions? Check `openspec/launch/README.md` for App Store submission guidance.**
- memorize