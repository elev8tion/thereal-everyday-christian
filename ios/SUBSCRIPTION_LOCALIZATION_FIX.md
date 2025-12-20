# 🔧 Subscription Localization Rejection - Fix Guide

**Issue:** Subscription products have rejection points in localization
**App:** Everyday Christian
**Date:** December 20, 2025

---

## ✅ Good News!

Your subscriptions **ARE configured** in App Store Connect. The rejection is about the **text content** (localization), not the implementation. This is much easier to fix than code issues!

---

## 🔍 Common Subscription Localization Rejections

Apple rejects subscription localizations for these reasons:

### 1. **Missing Required Information**

**What Apple Requires in Subscription Description:**
- ✅ What the subscription includes (features/content)
- ✅ Subscription duration (monthly/yearly)
- ✅ Price (or "See pricing for your region")
- ✅ Auto-renewal statement
- ✅ How to cancel

**Example REJECTED Description:**
```
Premium access to all features.
```

**Example APPROVED Description:**
```
Everyday Christian Premium includes:
• Unlimited AI-powered prayer assistance
• Personalized daily devotionals
• Advanced Bible study tools
• Ad-free experience

SUBSCRIPTION TERMS:
• Monthly: $3.99/month (or equivalent in your currency)
• Yearly: $35.99/year (or equivalent in your currency)
• Payment charged to Apple Account at confirmation
• Auto-renews unless cancelled 24 hours before period ends
• Manage or cancel in Account Settings

Terms: https://everydaychristian.app/terms
Privacy: https://everydaychristian.app/privacy
```

---

### 2. **Misleading or Unclear Pricing**

**REJECTED Examples:**
- ❌ "Only $3.99!" (doesn't mention per month)
- ❌ "Best value!" (without context)
- ❌ "$35.99" (doesn't mention per year or auto-renewal)

**APPROVED Examples:**
- ✅ "$3.99 per month, auto-renewing"
- ✅ "$35.99 per year (Save 17%)"
- ✅ "Monthly plan: $3.99/month"

---

### 3. **Missing Auto-Renewal Disclosure**

Apple **REQUIRES** you state:
- ✅ "Automatically renews unless cancelled"
- ✅ "Auto-renews monthly/yearly"
- ✅ "Subscription automatically renews"

---

### 4. **Missing Cancellation Information**

You **MUST** tell users how to cancel:
- ✅ "Cancel anytime in Account Settings"
- ✅ "Manage subscription in your Apple Account"
- ✅ "Cancel before renewal to avoid charges"

---

### 5. **Prohibited Language**

**DON'T use:**
- ❌ "Free forever!" (misleading)
- ❌ "Best app ever!" (unsubstantiated claim)
- ❌ "Doctor recommended" (without proof)
- ❌ "Cure" or medical claims
- ❌ "Limited time offer" (creates urgency)

**DO use:**
- ✅ "Try free for 3 days"
- ✅ "Cancel anytime"
- ✅ "150 AI messages per month"
- ✅ "Faith-based guidance"

---

### 6. **Inconsistent Information**

All fields must match:
- Display Name ↔ Description
- App Description ↔ Subscription Description
- English ↔ Other Languages (if multiple localizations)

---

## 📝 Required Fields for Each Subscription

### For BOTH Products:
1. **Subscription Display Name** (30 chars max)
   - Yearly: "Yearly Premium"
   - Monthly: "Monthly Premium"

2. **Description** (45 chars max - SHORT!)
   - Yearly: "Full access, billed yearly"
   - Monthly: "Full access, billed monthly"

3. **Subscription Group Display Name**
   - "Everyday Christian Premium"

4. **Review Information** (Internal only)
   - Full description of what subscription includes
   - Screenshots showing subscription features
   - Login credentials for Apple reviewer (if needed)

---

## 🛠️ How to Fix in App Store Connect

### Step 1: Open App Store Connect

```bash
open "https://appstoreconnect.apple.com/apps"
```

Navigate to:
**Apps → Everyday Christian → Features → In-App Purchases → Subscriptions tab**

---

### Step 2: Edit Each Subscription

**For `everyday_christian_ios_yearly_sub`:**

1. Click the subscription
2. Go to **Subscription Localization** section
3. Click **English (U.S.)** or your primary language
4. Update fields:

**Subscription Display Name:**
```
Yearly Premium
```

**Description:**
```
Unlimited access, renews yearly
```

5. Scroll to **Review Notes** section
6. Add detailed description for Apple:

```
SUBSCRIPTION INCLUDES:
• Unlimited AI-powered prayer assistance (normally 150 messages/month)
• Personalized daily devotionals
• Advanced Bible study tools
• Ad-free experience

PRICING:
• $35.99 per year (or equivalent)
• Automatically renews yearly unless cancelled
• Charged to Apple Account at purchase
• Cancel in Account Settings at least 24 hours before renewal

TRIAL:
• 3 days free trial OR 15 messages (whichever comes first)
• No charge if cancelled before trial ends

LEGAL:
• Terms of Use: https://everydaychristian.app/terms
• Privacy Policy: https://everydaychristian.app/privacy

Users can manage and cancel subscriptions through their Apple Account settings.
```

---

**For `everyday_christian_ios_monthly_sub`:**

Same process, but use:

**Subscription Display Name:**
```
Monthly Premium
```

**Description:**
```
Unlimited access, renews monthly
```

**Review Notes:**
```
SUBSCRIPTION INCLUDES:
• Unlimited AI-powered prayer assistance (normally 150 messages/month)
• Personalized daily devotionals
• Advanced Bible study tools
• Ad-free experience

PRICING:
• $3.99 per month (or equivalent)
• Automatically renews monthly unless cancelled
• Charged to Apple Account at purchase
• Cancel in Account Settings at least 24 hours before renewal

TRIAL:
• 3 days free trial OR 15 messages (whichever comes first)
• No charge if cancelled before trial ends

LEGAL:
• Terms of Use: https://everydaychristian.app/terms
• Privacy Policy: https://everydaychristian.app/privacy

Users can manage and cancel subscriptions through their Apple Account settings.
```

---

### Step 3: Update Subscription Group Info

1. Go back to subscription group
2. Edit **Group Display Name**: "Everyday Christian Premium"
3. Save changes

---

### Step 4: Check App Store Listing

Make sure your **main app description** also mentions subscriptions:

**App Store → App Information → Description** should include:

```
...your existing description...

SUBSCRIPTION INFORMATION:
Everyday Christian offers optional premium subscriptions:
• Monthly: $3.99/month
• Yearly: $35.99/year (Save 17%)

Premium includes unlimited AI messages, personalized devotionals, and ad-free experience.

Subscriptions automatically renew unless cancelled at least 24 hours before the end of the current period. Manage subscriptions in your Account Settings.

Terms: https://everydaychristian.app/terms
Privacy: https://everydaychristian.app/privacy
```

---

## 📸 Screenshots Required

Apple may require **subscription screenshots** showing:

1. **Pricing screen** - Where users see subscription options
2. **Features screen** - What's included in premium
3. **Settings screen** - Where to manage/cancel subscription

**How to add:**
1. In App Store Connect → Subscriptions → [Your subscription]
2. Scroll to **Subscription Review Information**
3. Upload screenshots (max 3)

---

## ✅ Subscription Localization Checklist

Before resubmitting, verify:

**Subscription Display Name:**
- [ ] Clear and concise (< 30 characters)
- [ ] Mentions duration (Yearly/Monthly)
- [ ] No misleading claims

**Description:**
- [ ] States billing frequency
- [ ] Mentions auto-renewal
- [ ] Clear about what's included

**Review Information:**
- [ ] Full feature list provided
- [ ] Pricing clearly stated
- [ ] Auto-renewal disclosure included
- [ ] Cancellation instructions included
- [ ] Links to Terms and Privacy Policy
- [ ] Screenshots uploaded (if required)

**App Metadata:**
- [ ] App description mentions subscriptions
- [ ] Subscription pricing is consistent everywhere
- [ ] Privacy Policy accessible
- [ ] Terms of Use accessible

---

## 🚀 Resubmit Process

### After fixing localization:

1. **Save all changes in App Store Connect**

2. **Resubmit subscriptions for review:**
   - In App Store Connect → Subscriptions
   - Each subscription should show "Ready to Submit" or "Waiting for Review"
   - If status is "Rejected", click "Resubmit for Review"

3. **Resubmit app if needed:**
   ```bash
   cd /Users/kcdacre8tor/thereal-everyday-christian/ios
   
   # Option 1: TestFlight first (recommended)
   fastlane beta
   
   # Option 2: Direct to App Store
   fastlane release
   ```

---

## 🆘 If Still Rejected

### Check Resolution Center for specific feedback:

1. Go to App Store Connect → Apps → Everyday Christian
2. Click **Resolution Center** tab
3. Look for messages from Apple Review team
4. Apple will specify exactly which fields are problematic

### Common specific rejections:

**"Subscription description is unclear"**
- Add more detail about what's included
- Explicitly state billing frequency
- Add auto-renewal language

**"Missing required disclosures"**
- Add auto-renewal statement
- Add cancellation instructions
- Link to Terms and Privacy Policy

**"Misleading pricing information"**
- Remove superlatives ("best", "only", etc.)
- State exact pricing with currency
- Mention regional variations

---

## 📋 Template: Complete Subscription Review Info

Use this template for **Review Notes** section:

```
EVERYDAY CHRISTIAN PREMIUM SUBSCRIPTION

WHAT'S INCLUDED:
• Unlimited AI-powered spiritual guidance (150 messages/month limit removed)
• Daily personalized devotionals
• Advanced Bible study tools and commentary
• Ad-free experience across all features

PRICING & BILLING:
• [Monthly/Yearly] Subscription: $X.XX per [month/year]
• Prices may vary by region
• Payment charged to Apple Account upon purchase confirmation
• Subscription automatically renews unless auto-renewal is turned off at least 24 hours before the end of the current period
• Account will be charged for renewal within 24 hours prior to the end of the current period

FREE TRIAL:
• New subscribers receive 3 days free OR 15 free messages (whichever comes first)
• Trial can be cancelled anytime before end without charge
• Subscription begins automatically after trial unless cancelled

MANAGING SUBSCRIPTION:
• Subscriptions can be managed and auto-renewal turned off in Account Settings
• Users can cancel anytime through their Apple Account settings
• No refunds for current active subscription period

LEGAL INFORMATION:
• Terms of Use: https://everydaychristian.app/terms
• Privacy Policy: https://everydaychristian.app/privacy
• Support: [your support email]

CONTENT:
• Faith-based AI conversations
• Christian devotional content
• Bible study materials
• Prayer assistance
• Content is suitable for ages 4+
```

---

## 🎯 Expected Timeline

After fixing and resubmitting:
- **Subscription Review:** 1-3 business days
- **App Review:** 1-2 days
- **Total:** ~2-5 days for approval

---

## 📞 Need Help?

If rejected again:
1. Read Apple's specific feedback in Resolution Center
2. Update based on their exact notes
3. Reply to Resolution Center with your changes
4. Resubmit

**Pro Tip:** You can add a note when resubmitting explaining what you changed!

---

**Generated:** December 20, 2025
**App:** Everyday Christian iOS
**Issue:** Subscription Localization Rejection
**Status:** Fixable - Update text and resubmit
