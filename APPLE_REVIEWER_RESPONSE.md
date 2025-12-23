# Response to Apple App Review - Everyday Christian
**Submission ID:** 213a117a-afa7-4f47-960b-3ecbc3461b1c
**Date:** December 22, 2025
**Version:** 1.0

---

## Response to Guideline 3.1.2 - Subscriptions Information

We have updated the app binary to include **all required subscription information** as specified in Guideline 3.1.2:

### ✅ What's Now Included in the Binary:

**1. Title of Auto-Renewing Subscription:**
- Yearly Plan: "Premium Yearly"
- Monthly Plan: "Premium Monthly"

**2. Length of Subscription (ADDED):**
- Yearly Plan: **"12 months of access"** - displayed prominently on the plan card
- Monthly Plan: **"1 month of access"** - displayed prominently on the plan card

**3. Price of Subscription:**
- Yearly Plan: **$35.99/year** (displayed in large, bold text)
- Monthly Plan: **$5.99/month** (displayed in large, bold text)

**4. Content/Services Provided:**
- **150 Scripture Chats per month** - displayed in a prominent badge
- AI-powered Bible study assistant
- Full access to KJV and RVR1909 Bible translations
- Context-aware responses based on user's reading history
- Crisis detection and support resources

**5. Functional Links to Privacy Policy and Terms of Use (EULA):**
- **NEW LOCATION:** Links are now displayed in a **prominent frosted glass card** positioned **immediately above the Subscribe button**
- Privacy Policy: https://everydaychristian.app/privacy ✅ (verified accessible)
- Terms of Use (EULA): https://everydaychristian.app/terms ✅ (verified accessible)
- Both links open in external browser (Safari) when tapped

### Screenshot References:
The subscription information screen displays:
1. Plan selector cards showing **subscription length** (12 months / 1 month)
2. **Clear pricing** ($35.99/year or $5.99/month)
3. **"150 Scripture Chats/month"** badge
4. **Privacy Policy and Terms of Use links** in gold, underlined text
5. Large "Subscribe Now" button
6. Complete feature list with descriptions

---

## Response to Guideline 2.1 - Locating In-App Purchases

We apologize for any confusion. The in-app purchases are **available and fully functional** in the app. Here are the **step-by-step instructions** to locate them:

### 🔍 How to Access In-App Purchases in Everyday Christian:

**Method 1: Through Settings (Most Direct)**
1. Launch the Everyday Christian app
2. Complete the brief onboarding flow (swipe through 3 intro screens, tap "Get Started")
3. You'll arrive at the Home screen
4. Tap the **hamburger menu icon** (three horizontal lines) in the top-left corner
5. Select **"Settings"** from the menu
6. Scroll down to the "Account" section
7. Tap **"Manage Subscription"**
8. You will see the **Paywall screen** with both subscription options:
   - **Premium Yearly** ($35.99/year) - with "BEST VALUE" badge
   - **Premium Monthly** ($5.99/month)

**Method 2: Through Prayer Journal (Alternative Path)**
1. Launch the Everyday Christian app
2. Complete onboarding
3. From the Home screen, tap **"My Prayers"** (in the Quick Actions section)
4. Tap the **"+ Add Prayer"** button at the bottom
5. Fill in a prayer request (any text)
6. Tap **"Get AI Guidance"** button
7. After using 15 messages during the 3-day trial, the app will automatically show the Paywall screen

**Method 3: Through Scripture Chat (Another Alternative)**
1. Launch the Everyday Christian app
2. Complete onboarding
3. Tap **"Scripture Chat"** from the Home screen Quick Actions
4. Start a conversation with the AI assistant
5. After using 15 messages during the 3-day trial, the Paywall screen appears

### 📱 Important Notes for Sandbox Testing:

**Trial Period:**
- New users receive a **3-day trial** OR **15 total messages** (whichever comes first)
- During sandbox testing, you can trigger the paywall immediately by sending 15 messages to the AI assistant

**Sandbox Environment:**
- The app is configured to work with **Apple's sandbox environment** for testing
- Product IDs are correctly configured:
  - iOS Yearly: `everyday_christian_premium_yearly`
  - iOS Monthly: `everyday_christian_premium_monthly`

**Paid Apps Agreement:**
- ✅ The Account Holder has **accepted the Paid Apps Agreement** in App Store Connect
- ✅ Both subscription products are **active and available** in App Store Connect

**Storefront Configuration:**
- The app's IAPs are available in **all storefronts** (not restricted by region)
- No device-specific restrictions applied

---

## App Store Metadata Updates

We have also updated the App Store metadata as requested:

### ✅ App Description (Updated)
Added the following section to the App Description:

```
SUBSCRIPTION INFORMATION:
• Premium Yearly: $35.99/year - 12 months of access to 150 Scripture Chats per month
• Premium Monthly: $5.99/month - 1 month of access to 150 Scripture Chats per month
• Free 3-day trial included (15 messages total)
• Auto-renewable subscription - cancel anytime

Privacy Policy: https://everydaychristian.app/privacy
Terms of Use (EULA): https://everydaychristian.app/terms

Payment will be charged to your iTunes Account at confirmation of purchase. Subscription automatically renews unless auto-renew is turned off at least 24 hours before the end of the current period. Your account will be charged for renewal within 24 hours prior to the end of the current period. You can manage subscriptions and turn off auto-renewal by going to Account Settings after purchase.
```

### ✅ Privacy Policy URL
- Field: Filled with `https://everydaychristian.app/privacy`

### ✅ EULA (Terms of Use)
- Field: Filled with `https://everydaychristian.app/terms`

---

## Summary of Changes

| Issue | Status | Solution |
|-------|--------|----------|
| Missing subscription length in binary | ✅ **FIXED** | Added "12 months of access" and "1 month of access" to plan cards |
| Missing price in binary | ✅ **FIXED** | Price already displayed prominently ($35.99 / $5.99) |
| Missing EULA link in binary | ✅ **FIXED** | Moved Terms of Use link to prominent position above Subscribe button |
| Missing EULA in metadata | ✅ **FIXED** | Added EULA link to App Description and EULA field |
| Reviewers cannot locate IAPs | ✅ **FIXED** | Provided 3 detailed navigation paths above |

---

## Contact Information

If you have any questions or need further clarification, please reply to this message in App Store Connect.

Thank you for your thorough review!

**Developer:** Everyday Christian Team
**Support Email:** connect@everydaychristian.app
