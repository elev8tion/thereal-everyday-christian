# Fastlane Quick Start - Everyday Christian iOS

**5-Minute Setup Guide** for deploying to TestFlight and App Store.

---

## ⚡ Quick Setup (First Time Only)

### 1. Create `.env` file

```bash
cd ios/fastlane
cp .env.sample .env
```

### 2. Get App-Specific Password

1. Visit: https://appleid.apple.com
2. **Security** → **App-Specific Passwords**
3. Generate password named "Fastlane"
4. Copy the password

### 3. Get Team ID

Visit: https://appstoreconnect.apple.com
- Click your name → **View Membership**
- Copy **Team ID**

### 4. Edit `.env`

```bash
FASTLANE_USER=your.apple.id@example.com
FASTLANE_PASSWORD=xxxx-xxxx-xxxx-xxxx  # From step 2
FASTLANE_ITC_TEAM_ID=123456789           # From step 3
FASTLANE_TEAM_ID=123456789               # Same as above
```

### 5. Update `Appfile`

Edit `ios/fastlane/Appfile`:

```ruby
apple_id("your.apple.id@example.com")
itc_team_id("123456789")
team_id("123456789")
```

---

## 🚀 Deploy Commands

### Send to TestFlight (Beta Testing)

```bash
cd ios
fastlane beta
```

### Submit to App Store (Production)

```bash
cd ios
fastlane release
```

### Build Without Upload

```bash
cd ios
fastlane build
```

---

## ✅ Your Next Steps (Right Now!)

Since you just fixed the App Store rejection issues, you should:

### Option A: Test in TestFlight First (Recommended)

```bash
cd ios
fastlane beta
```

**Then:**
1. Check TestFlight in App Store Connect
2. Install on your device via TestFlight
3. Verify the fixes:
   - ✅ IAP purchase validation works
   - ✅ Privacy Policy link opens
   - ✅ Terms of Use link opens
   - ✅ App name shows "Everyday Christian"

### Option B: Submit Directly to App Store

```bash
cd ios
fastlane release
```

**Then:**
1. Monitor at: https://appstoreconnect.apple.com
2. Wait for "Ready for Sale" status
3. Respond to any Apple feedback

---

## 🎯 What Happens During Deployment?

When you run `fastlane beta` or `fastlane release`:

```
1. ✅ Checks git is clean
2. ✅ Increments build number (e.g., 1 → 2)
3. ✅ Builds IPA file
4. ✅ Uploads to App Store Connect
5. ✅ Submits for review (release only)
6. ✅ Commits version bump
7. ✅ Pushes to GitHub
8. ✅ Creates git tag (release only)
9. ✅ Shows success notification
```

**Total time:** ~5-10 minutes per deployment

---

## 🐛 Common Issues

### Issue: "No such file or directory - .env"

**Solution:**
```bash
cd ios/fastlane
cp .env.sample .env
# Edit .env with your credentials
```

### Issue: "Invalid password"

**Solution:**
- Use **app-specific password**, not your Apple ID password
- Regenerate at: https://appleid.apple.com

### Issue: "Team not found"

**Solution:**
```bash
# List all teams
fastlane produce list_teams

# Update Appfile and .env with correct Team ID
```

---

## 📖 Full Documentation

For detailed guides:
- **Full Setup Guide:** `ios/fastlane/FASTLANE_SETUP.md`
- **Troubleshooting:** See FASTLANE_SETUP.md
- **Official Docs:** https://docs.fastlane.tools

---

## 🎉 You're Ready!

After setup, deploying is as simple as:

```bash
cd ios && fastlane beta    # For TestFlight
cd ios && fastlane release # For App Store
```

No more manual uploads! 🚀
