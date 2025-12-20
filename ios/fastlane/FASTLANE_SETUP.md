# Fastlane Setup Guide - Everyday Christian iOS

Complete guide for automating App Store submissions and deployments using Fastlane.

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Initial Setup](#initial-setup)
- [Configuration](#configuration)
- [Available Lanes](#available-lanes)
- [Common Workflows](#common-workflows)
- [Troubleshooting](#troubleshooting)

---

## 🔧 Prerequisites

1. **Fastlane installed** ✅ (Already installed via Homebrew)
2. **Xcode** with valid Apple Developer account
3. **App Store Connect** access with appropriate permissions
4. **Git repository** (already configured)
5. **Valid code signing certificates**

---

## 🚀 Initial Setup

### 1. Configure App Store Connect Credentials

Copy the environment template and add your credentials:

```bash
cd ios/fastlane
cp .env.sample .env
```

Edit `.env` with your actual values:

```bash
# Required fields:
FASTLANE_USER=your.apple.id@example.com
FASTLANE_PASSWORD=xxxx-xxxx-xxxx-xxxx  # App-specific password
FASTLANE_ITC_TEAM_ID=123456789
FASTLANE_TEAM_ID=123456789
```

### 2. Create App-Specific Password

1. Go to [appleid.apple.com](https://appleid.apple.com)
2. Sign in with your Apple ID
3. Navigate to **Security** → **App-Specific Passwords**
4. Click **Generate Password**
5. Name it "Fastlane" and copy the generated password
6. Paste it into `.env` as `FASTLANE_PASSWORD`

### 3. Get Your Team ID

**Method 1: App Store Connect**
1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Click your name (top right) → **View Membership**
3. Copy your **Team ID**

**Method 2: Command Line**
```bash
fastlane produce list_teams
```

### 4. Update Appfile

Edit `ios/fastlane/Appfile` and replace placeholders:

```ruby
apple_id("your.apple.id@example.com")
itc_team_id("123456789")
team_id("123456789")
app_identifier("com.elev8tion.everydaychristian")
```

### 5. Set up 2FA Session (Optional but Recommended)

Reduce 2FA prompts by creating a session token:

```bash
fastlane spaceauth -u your.apple.id@example.com
```

Copy the output and add to `.env`:
```bash
FASTLANE_SESSION='---\n- !ruby/object:HTTP::Cookie\n  name: ...'
```

---

## 🎯 Available Lanes

### 1. **Beta Deployment** (`fastlane beta`)

Uploads a new build to TestFlight for beta testing.

**What it does:**
- ✅ Checks git status is clean
- ✅ Increments build number
- ✅ Builds IPA file
- ✅ Uploads to TestFlight
- ✅ Commits version bump
- ✅ Pushes to GitHub

**Usage:**
```bash
cd ios
fastlane beta
```

**When to use:**
- Weekly beta releases
- Testing new features before production
- Internal QA testing

---

### 2. **App Store Release** (`fastlane release`)

Submits a new version to the App Store for review.

**What it does:**
- ✅ Ensures you're on `main` branch
- ✅ Increments version number (patch)
- ✅ Builds production IPA
- ✅ Uploads to App Store Connect
- ✅ Submits for App Store review
- ✅ Creates git tag
- ✅ Pushes to GitHub

**Usage:**
```bash
cd ios
fastlane release
```

**When to use:**
- Major releases
- Bug fixes that need App Store review
- After fixing App Store rejections

---

### 3. **Build Only** (`fastlane build`)

Builds the app without uploading.

**Usage:**
```bash
cd ios
fastlane build
```

**When to use:**
- Testing build configuration
- Creating local IPA for distribution
- Verifying no build errors before deployment

---

### 4. **Update Metadata** (`fastlane metadata`)

Updates App Store metadata without uploading a new build.

**Usage:**
```bash
cd ios
fastlane metadata
```

**When to use:**
- Fixing app description typos
- Updating screenshots
- Changing keywords or categories

---

### 5. **Version Bump** (`fastlane bump`)

Increments version number (patch: 1.0.0 → 1.0.1).

**Usage:**
```bash
cd ios
fastlane bump
```

**Bump types:**
```ruby
# In Fastfile, change bump_type:
bump_type: "patch"  # 1.0.0 → 1.0.1
bump_type: "minor"  # 1.0.0 → 1.1.0
bump_type: "major"  # 1.0.0 → 2.0.0
```

---

### 6. **Run Tests** (`fastlane test`)

Runs all unit and UI tests.

**Usage:**
```bash
cd ios
fastlane test
```

---

## 📖 Common Workflows

### Workflow 1: Fix App Store Rejection and Resubmit

You've just fixed the IAP bug, EULA links, and app name issues. Here's how to resubmit:

```bash
# 1. Navigate to iOS directory
cd ios

# 2. Ensure all changes are committed
git status

# 3. Build and submit to App Store
fastlane release

# 4. Monitor build processing in App Store Connect
# Check: https://appstoreconnect.apple.com/apps/YOUR_APP_ID/testflight
```

Fastlane will:
- ✅ Bump version to 1.0.1 (or next patch version)
- ✅ Build production IPA
- ✅ Upload to App Store Connect
- ✅ Submit for review automatically
- ✅ Create git tag `v1.0.1`

---

### Workflow 2: Weekly Beta Release

```bash
cd ios
fastlane beta
```

---

### Workflow 3: Emergency Hotfix

```bash
# 1. Create hotfix branch
git checkout -b hotfix/critical-bug

# 2. Make your fixes in code
# ... fix the bug ...

# 3. Commit changes
git add .
git commit -m "Fix critical bug"

# 4. Merge to main
git checkout main
git merge hotfix/critical-bug

# 5. Deploy to App Store
cd ios
fastlane release
```

---

## 🛠️ Troubleshooting

### Issue: "No valid code signing identity"

**Solution:**
```bash
# List available certificates
security find-identity -v -p codesigning

# If no certificates, download from Xcode:
# Xcode → Settings → Accounts → Your Apple ID → Download Manual Profiles
```

### Issue: "Invalid password for Apple ID"

**Solution:**
1. Verify you're using an **app-specific password**, NOT your Apple ID password
2. Regenerate at [appleid.apple.com](https://appleid.apple.com)
3. Update `.env` file

### Issue: "Could not find team with ID"

**Solution:**
```bash
# List all teams
fastlane produce list_teams

# Update Appfile with correct Team ID
```

### Issue: "No such file or directory - git"

**Solution:**
```bash
# Install Xcode Command Line Tools
xcode-select --install
```

### Issue: 2FA prompts on every run

**Solution:**
Set up session token:
```bash
fastlane spaceauth -u your.apple.id@example.com
# Copy output to .env as FASTLANE_SESSION
```

### Issue: "Build already exists"

**Solution:**
Increment build number:
```bash
# Check current build number
agvtool what-version

# Increment manually
cd ios
fastlane bump
```

---

## 📚 Additional Resources

- **Fastlane Docs:** https://docs.fastlane.tools
- **App Store Connect:** https://appstoreconnect.apple.com
- **TestFlight Guide:** https://developer.apple.com/testflight/
- **Code Signing Guide:** https://codesigning.guide

---

## 🔐 Security Best Practices

1. ✅ **Never commit `.env` file** - It's gitignored
2. ✅ **Use app-specific passwords** - Not your main Apple ID password
3. ✅ **Rotate credentials periodically** - Every 6 months
4. ✅ **Use Match for code signing** - Syncs certificates across team
5. ✅ **Enable 2FA** - On your Apple ID
6. ✅ **Store session token securely** - Use environment variables

---

## 🎉 Success Checklist

After your first successful deployment:

- [ ] `.env` file created and configured
- [ ] App-specific password generated
- [ ] Team IDs updated in Appfile
- [ ] Beta deployment successful (`fastlane beta`)
- [ ] Build appears in TestFlight
- [ ] Version number auto-incremented
- [ ] Git tags created
- [ ] Changes pushed to GitHub

---

## 🆘 Need Help?

- **Fastlane Community:** [fastlane.tools/community](https://fastlane.tools/community)
- **GitHub Issues:** [fastlane/fastlane/issues](https://github.com/fastlane/fastlane/issues)
- **Stack Overflow:** Tag `fastlane`

---

**Last Updated:** December 19, 2025
**App:** Everyday Christian iOS
**Bundle ID:** com.elev8tion.everydaychristian
