# App Store Connect Metadata Updates
**Required Changes for Guideline 3.1.2 Compliance**

---

## 1. App Description Field

**WHERE:** App Store Connect → My Apps → Everyday Christian → App Information → Description

**ACTION:** Add the following section at the **beginning** of your app description (before the existing text):

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SUBSCRIPTION INFORMATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Premium Yearly: $35.99/year
• 12 months of access
• 150 Scripture Chats per month
• AI-powered Bible study assistant
• Full access to KJV and RVR1909 translations
• Context-aware responses
• Crisis detection and support

Premium Monthly: $5.99/month
• 1 month of access
• 150 Scripture Chats per month
• Same premium features as yearly plan

FREE 3-DAY TRIAL: 15 messages to explore premium features

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
LEGAL & PRIVACY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Privacy Policy: https://everydaychristian.app/privacy
Terms of Use (EULA): https://everydaychristian.app/terms

Payment will be charged to your iTunes Account at confirmation of purchase. Subscription automatically renews unless auto-renew is turned off at least 24 hours before the end of the current period. Your account will be charged for renewal within 24 hours prior to the end of the current period. You can manage subscriptions and turn off auto-renewal by going to Account Settings after purchase.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[YOUR EXISTING APP DESCRIPTION TEXT CONTINUES HERE]
```

---

## 2. Privacy Policy URL Field

**WHERE:** App Store Connect → My Apps → Everyday Christian → App Information → Privacy Policy URL

**ACTION:** Enter the following URL:

```
https://everydaychristian.app/privacy
```

**VERIFY:** Click the URL to confirm it opens correctly

---

## 3. Apple's Standard EULA vs Custom EULA

**WHERE:** App Store Connect → My Apps → Everyday Christian → App Information → License Agreement

**OPTION 1 (RECOMMENDED):** Use Apple's Standard EULA
- Select "Use Apple's standard EULA"
- Add this line to your App Description (already included above):
  ```
  Terms of Use (EULA): https://everydaychristian.app/terms
  ```

**OPTION 2:** Custom EULA
- Select "Custom EULA"
- Paste the full text from https://everydaychristian.app/terms into the text field

**RECOMMENDATION:** Use Option 1 (Apple's Standard EULA with link in description) because:
- Faster approval
- Automatically updated for legal compliance
- Still links to your custom terms for additional app-specific policies

---

## 4. Reply to App Review Team

**WHERE:** App Store Connect → My Apps → Everyday Christian → App Review → Resolution Center

**ACTION:** Copy and paste the entire contents of `APPLE_REVIEWER_RESPONSE.md` into your reply

**KEY POINTS TO EMPHASIZE IN YOUR REPLY:**

1. **We have updated the app binary** to include:
   - Explicit subscription lengths ("12 months" / "1 month")
   - Prominent pricing display
   - Functional EULA and Privacy Policy links above Subscribe button

2. **Navigation instructions** for reviewers (3 different paths provided)

3. **All metadata fields updated** with required information

4. **Sandbox testing notes** to help reviewers test IAPs

---

## 5. Version Information

**WHERE:** App Store Connect → My Apps → Everyday Christian → Version → Version Information → What's New in This Version

**SUGGESTED TEXT:**

```
App Store Compliance Update

This version includes enhanced subscription information display to comply with App Store guidelines:

• Explicit subscription duration now shown on plan cards (12 months for yearly, 1 month for monthly)
• More prominent placement of Terms of Use and Privacy Policy links
• Improved pricing clarity
• Bug fixes and performance improvements

We appreciate your patience as we work to provide the best experience while meeting App Store requirements.
```

---

## 6. Reviewer Notes (Optional but Helpful)

**WHERE:** App Store Connect → My Apps → Everyday Christian → Version → App Review Information → Notes

**SUGGESTED TEXT:**

```
NAVIGATION TO IAP SCREEN:

Fastest Path:
1. Complete onboarding (3 swipe screens + "Get Started")
2. Tap hamburger menu (top-left)
3. Select "Settings"
4. Tap "Manage Subscription"
5. IAPs appear with full subscription details

Alternative: Use 15 messages in Scripture Chat to trigger paywall automatically.

TESTING NOTES:
- 3-day trial OR 15 messages (whichever comes first)
- Both yearly ($35.99) and monthly ($5.99) plans available
- Sandbox environment fully configured
- All required subscription info now displayed in binary

Thank you for your thorough review!
```

---

## Checklist Before Resubmission

- [ ] Updated App Description with subscription information
- [ ] Verified Privacy Policy URL is correct
- [ ] Selected EULA option and added Terms link
- [ ] Replied to App Review team with navigation instructions
- [ ] Updated "What's New" text
- [ ] Added helpful Reviewer Notes
- [ ] **Built and uploaded new binary** with code changes
- [ ] Submitted for review

---

## Important: New Binary Required

**⚠️ CRITICAL:** You **must submit a NEW BUILD** with the code changes we made to `paywall_screen.dart`. The metadata updates alone are not sufficient.

**Steps:**
1. Increment build number in `pubspec.yaml`
2. Run `flutter build ios --release`
3. Upload to TestFlight via Xcode or Transporter
4. Select the new build in App Store Connect
5. Submit for review with updated metadata

---

## Timeline Expectations

Once you've made these changes and uploaded a new build:
- **Metadata review:** Usually approved within 1-2 hours
- **App binary review:** Typically 24-48 hours
- **Total time to approval:** 1-3 days

The detailed navigation instructions should help reviewers quickly find and test the IAPs, speeding up the review process.

---

## Support

If Apple requests additional information, reply promptly in the Resolution Center. The more responsive you are, the faster the approval process.

Good luck! 🙏
