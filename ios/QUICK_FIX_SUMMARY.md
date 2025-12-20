# ⚡ QUICK FIX - Subscription Localization

## 🎯 Your Issue
**Subscription localization has rejection points**

This means your subscription products exist, but the text descriptions need to be updated to meet Apple's requirements.

---

## ✅ 10-Minute Fix

### Step 1: Open App Store Connect (Now)
```bash
cd /Users/kcdacre8tor/thereal-everyday-christian/ios
bash fastlane/FIX_LOCALIZATION_NOW.sh
```

### Step 2: Fix Both Subscriptions

Go to: **Apps → Everyday Christian → In-App Purchases → Subscriptions**

**For each subscription (`everyday_christian_ios_yearly_sub` and `everyday_christian_ios_monthly_sub`):**

1. Click the subscription
2. Click **Subscription Localization** → **English (U.S.)**
3. Update these fields:

**Subscription Display Name:**
- Yearly: `Yearly Premium`
- Monthly: `Monthly Premium`

**Description (45 char limit):**
- Yearly: `Unlimited access, renews yearly`
- Monthly: `Unlimited access, renews monthly`

4. Scroll to **Review Information**
5. Paste this template (modify pricing as needed):

```
SUBSCRIPTION INCLUDES:
• Unlimited AI-powered prayer assistance (normally 150 messages/month)
• Personalized daily devotionals
• Advanced Bible study tools
• Ad-free experience

PRICING:
• $X.XX per [month/year] (or equivalent in your currency)
• Automatically renews [monthly/yearly] unless cancelled
• Charged to Apple Account at purchase confirmation
• Cancel in Account Settings at least 24 hours before renewal

FREE TRIAL:
• 3 days free trial OR 15 free messages (whichever comes first)
• No charge if cancelled before trial ends

LEGAL:
• Terms of Use: https://everydaychristian.app/terms
• Privacy Policy: https://everydaychristian.app/privacy

Users can manage and cancel subscriptions through their Apple Account settings.
```

6. **Save**
7. Click **Resubmit for Review**

### Step 3: Done!

Wait 1-3 business days for Apple to re-review the subscriptions.

---

## 🚨 Most Common Issues

Apple rejects if you're missing:
1. ❌ Auto-renewal statement
2. ❌ Cancellation instructions
3. ❌ Clear pricing with billing frequency
4. ❌ What's included in subscription

**All fixed by the template above!**

---

## 📋 After Fixing Subscriptions

Once subscriptions are approved, you may need to resubmit the app:

```bash
cd /Users/kcdacre8tor/thereal-everyday-christian/ios

# Test in TestFlight first
fastlane beta

# Or submit to App Store
fastlane release
```

---

## 📚 Detailed Guide

See complete guide: `ios/SUBSCRIPTION_LOCALIZATION_FIX.md`

---

**Time to fix:** ~10-15 minutes  
**Review time:** 1-3 business days  
**Approval rate:** Very high if you follow template
