# Everyday Christian - iOS Launch Dashboard

**Target:** ASAP iOS Launch → TestFlight Beta (10 testers) → App Store Release
**Platform Priority:** iOS-first (Android later)
**Theological Review:** Self-managed (former youth pastor background)
**Marketing:** SEO + social media

---

## 🚦 Launch Readiness Status

| Category | Status | Priority | Blocking? |
|----------|--------|----------|-----------|
| **Legal & Compliance** | 🟡 In Progress | P0 | ✅ YES |
| **ASO Assets** | 🔴 Not Started | P0 | ✅ YES |
| **Technical Readiness** | 🟢 Ready | P1 | ❌ NO |
| **Security & Privacy** | 🟡 In Progress | P0 | ✅ YES |
| **Content Review** | 🔴 Not Started | P0 | ✅ YES |
| **TestFlight Beta** | 🔴 Not Started | P1 | ❌ NO |
| **Marketing Prep** | 🔴 Not Started | P2 | ❌ NO |

**Legend:**
- 🟢 Ready - Complete
- 🟡 In Progress - Partial completion
- 🔴 Not Started - Requires action
- P0 = Blocker (must complete before submission)
- P1 = Critical (complete before beta)
- P2 = Important (complete before public launch)

---

## 📋 Quick Start Checklist (iOS-First)

### Week 1: Legal & Compliance (P0)
- [ ] Review legal compliance checklist → [01_LEGAL_COMPLIANCE.md](01_LEGAL_COMPLIANCE.md)
- [ ] Privacy Policy finalization (required for App Store)
- [ ] Terms of Service finalization
- [ ] COPPA compliance review (if targeting <13)
- [ ] Subscription disclosure compliance (FTC requirements)
- [ ] App Store Review Guidelines compliance check

### Week 1-2: App Store Assets (P0)
- [ ] Learn ASO fundamentals → [02_ASO_ASSETS.md](02_ASO_ASSETS.md)
- [ ] App icon (1024x1024px, no transparency)
- [ ] Screenshots (6.7", 6.5", 5.5" iPhone required)
- [ ] App preview video (optional but recommended)
- [ ] App name (30 characters max)
- [ ] Subtitle (30 characters max)
- [ ] Keywords (100 characters max, comma-separated)
- [ ] Description (4000 characters max)
- [ ] Promotional text (170 characters, editable without review)

### Week 2: Security & Content (P0)
- [ ] Security audit → [03_TECHNICAL_READINESS.md](03_TECHNICAL_READINESS.md)
- [ ] Theological content review → [06_CONTENT_REVIEW.md](06_CONTENT_REVIEW.md)
- [ ] AI response testing (crisis detection, doctrinal accuracy)
- [ ] Subscription flow testing (trial, purchase, cancellation)
- [ ] Data deletion verification
- [ ] Privacy implementation check (no tracking without consent)

### Week 3: TestFlight Beta (P1)
- [ ] TestFlight setup → [07_BETA_TESTING.md](07_BETA_TESTING.md)
- [ ] Recruit 10 beta testers (mix of technical + non-technical)
- [ ] Create beta testing feedback form
- [ ] Beta build upload
- [ ] 1-2 week beta testing period
- [ ] Bug fixes and iteration

### Week 4+: App Store Submission
- [ ] Final build with all feedback addressed
- [ ] App Store Connect submission
- [ ] App Review process (typically 24-48 hours)
- [ ] Release coordination

---

## 📚 What is ASO? (App Store Optimization)

**ASO = SEO for App Stores** - It's how users discover your app organically (without paid ads).

**Why It Matters:**
- 70% of App Store users find apps through search
- Good ASO = free, ongoing user acquisition
- Bad ASO = your app is invisible, even if it's amazing

**Key ASO Elements:**
1. **App Name** - Most important for search ranking (e.g., "Everyday Christian - Bible & Prayer")
2. **Keywords** - 100 characters to describe what your app does (e.g., "bible,prayer,christian,faith,devotional,scripture,kjv")
3. **Screenshots** - Show your best features first (users decide in 3 seconds)
4. **Ratings/Reviews** - Social proof (aim for 4.5+ stars)
5. **Downloads** - App Store ranks popular apps higher

**Your ASO Plan (No Budget):**
1. Research competitors' keywords (Bible apps, prayer apps)
2. Create compelling screenshots showing key features
3. Write clear, benefit-focused description
4. Ask beta testers for honest reviews
5. Share on social media to drive initial downloads

📖 **Deep Dive:** See [02_ASO_ASSETS.md](02_ASO_ASSETS.md) for step-by-step ASO creation

---

## 🎯 iOS-Specific Requirements

### Required for App Store Submission:
✅ **Technical**
- [ ] Bundle ID registered in Apple Developer account
- [ ] App Store Connect app created
- [ ] StoreKit configuration for in-app purchases
- [ ] Subscription products configured (Premium $35/year)
- [ ] Privacy manifest (required iOS 17+)
- [ ] App icon (all required sizes)

✅ **Legal**
- [ ] Privacy Policy URL (publicly accessible)
- [ ] Terms of Service URL
- [ ] EULA (or use Apple's standard)
- [ ] Age rating questionnaire completed

✅ **Content**
- [ ] App Store screenshots (required sizes)
- [ ] App description (concise, benefit-focused)
- [ ] What's New text (for version 1.0.0)
- [ ] Support URL
- [ ] Marketing URL (optional)

✅ **Business**
- [ ] Tax forms submitted (W-9 or equivalent)
- [ ] Banking information for payouts
- [ ] Pricing configured for all regions
- [ ] Subscription terms disclosed in description

---

## 🧪 Beta Testing Plan (10 Testers)

**Tester Mix:**
- 3 technical users (find bugs, test edge cases)
- 4 target users (pastors, ministry leaders, active Christians)
- 3 general users (varying tech literacy, age groups)

**What to Test:**
1. **Onboarding Flow** - Clear? Confusing? Too long?
2. **AI Chat Quality** - Helpful? Doctrinally sound? Crisis detection working?
3. **Subscription Flow** - Easy to subscribe? Trial clear? Cancellation easy?
4. **Bible Reading** - Smooth? Fast? Verse lookup working?
5. **Prayer Journal** - Intuitive? Bugs? Feature requests?
6. **Performance** - Crashes? Slow loading? Battery drain?

**Feedback Collection:**
- Google Form or Typeform survey
- Weekly check-ins via email/Slack
- Bug reporting channel (GitHub issues or Notion)

---

## ⚖️ Self-Managed Theological Review

**As Former Youth Pastor, Review:**

1. **AI Pastoral Guidance Accuracy**
   - [ ] Test 20 common questions (salvation, prayer, doubt, suffering)
   - [ ] Verify responses align with orthodox Christian theology
   - [ ] Check for heretical content (prosperity gospel, universalism, etc.)
   - [ ] Ensure crisis detection triggers for suicidal ideation, abuse, etc.

2. **Crisis Detection Safeguards**
   - [ ] Test phrases indicating: suicide, self-harm, domestic abuse, addiction
   - [ ] Verify emergency resource referrals appear
   - [ ] Confirm AI doesn't replace professional help

3. **Bible Translation Integrity**
   - [ ] Verify KJV and RVR1909 text accuracy (spot check 50 verses)
   - [ ] Check verse references match content
   - [ ] Test search functionality

4. **Doctrinal Boundaries**
   - [ ] AI doesn't promote specific denominations
   - [ ] Respects evangelical orthodox positions
   - [ ] Avoids political endorsements
   - [ ] Age-appropriate content (13+)

---

## 📞 Support & Resources

**Apple Developer Support:**
- App Store Connect: https://appstoreconnect.apple.com
- Developer Forums: https://developer.apple.com/forums
- Review Guidelines: https://developer.apple.com/app-store/review/guidelines/

**ASO Tools (Free Tier):**
- App Store keyword research: AppTweak, Sensor Tower
- Screenshot generator: Screenshots.pro, AppLaunchpad
- Icon testing: App Icon Generator

**Beta Testing:**
- TestFlight: Built into App Store Connect
- Feedback collection: Google Forms, Typeform, Notion

---

## 🚀 Next Actions

**This Week:**
1. Complete legal compliance checklist ([01_LEGAL_COMPLIANCE.md](01_LEGAL_COMPLIANCE.md))
2. Learn ASO basics ([02_ASO_ASSETS.md](02_ASO_ASSETS.md))
3. Start theological content review ([06_CONTENT_REVIEW.md](06_CONTENT_REVIEW.md))

**Next Week:**
1. Create App Store assets (screenshots, description, keywords)
2. Upload TestFlight build
3. Recruit 10 beta testers

**Week 3:**
1. Run beta testing
2. Fix critical bugs
3. Finalize App Store submission materials

**Week 4:**
1. Submit to App Store
2. Monitor review status
3. Plan launch marketing (social media, SEO)

---

**Last Updated:** 2025-01-20
**Next Review:** After beta testing completion
