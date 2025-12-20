# Deployment Guide - Everyday Christian

Automated deployment workflows for iOS App Store using Fastlane.

---

## 📱 iOS Deployment

### Prerequisites

1. **Fastlane installed** ✅ (via Homebrew)
2. **Apple Developer account** with App Store Connect access
3. **Valid code signing certificates**

### Quick Deploy

#### Deploy to TestFlight (Beta)

```bash
cd ios
fastlane beta
```

#### Deploy to App Store (Production)

```bash
cd ios
fastlane release
```

### First-Time Setup

See detailed setup instructions:
- **Quick Start:** [ios/fastlane/QUICKSTART.md](ios/fastlane/QUICKSTART.md)
- **Full Setup Guide:** [ios/fastlane/FASTLANE_SETUP.md](ios/fastlane/FASTLANE_SETUP.md)

**Summary:**
1. Create `ios/fastlane/.env` from template
2. Add Apple ID and app-specific password
3. Add Team ID from App Store Connect
4. Run `cd ios && fastlane beta`

---

## 🔄 Deployment Workflows

### Workflow 1: Weekly Beta Release

```bash
# 1. Ensure all changes committed
git status

# 2. Deploy to TestFlight
cd ios
fastlane beta

# 3. Test via TestFlight app
# Install on device and verify functionality
```

**What happens:**
- Build number auto-increments (e.g., 1 → 2)
- IPA uploaded to TestFlight
- Version bump committed and pushed
- Takes ~5-10 minutes

---

### Workflow 2: Production Release

```bash
# 1. Ensure on main branch
git checkout main
git pull

# 2. Run tests (optional but recommended)
cd ios
fastlane test

# 3. Deploy to App Store
fastlane release
```

**What happens:**
- Version number increments (e.g., 1.0.0 → 1.0.1)
- Build uploaded to App Store Connect
- Automatically submitted for review
- Git tag created (e.g., v1.0.1)
- Takes ~10-15 minutes

---

### Workflow 3: Fix App Store Rejection

This is your current situation! You've fixed:
- ✅ IAP purchase validation
- ✅ Privacy Policy link (clickable, opens Safari)
- ✅ Terms of Use link (clickable, opens Safari)
- ✅ App name mismatch

**Steps to resubmit:**

```bash
# 1. Verify code changes committed
git log --oneline -5

# 2. Deploy to App Store
cd ios
fastlane release
```

**Expected timeline:**
- Upload: ~10 minutes
- Processing: ~30-60 minutes
- Review: 1-3 days

**Monitor progress:**
- App Store Connect: https://appstoreconnect.apple.com
- Check status: Apps → Everyday Christian → Activity

**When Apple responds:**
You'll receive an email with either:
- ✅ **Approved** - App goes live
- ❌ **Rejected** - Fix issues and run `fastlane release` again

---

## 🛠️ Available Commands

| Command | Description | Use Case |
|---------|-------------|----------|
| `fastlane beta` | Upload to TestFlight | Weekly beta testing |
| `fastlane release` | Submit to App Store | Production releases |
| `fastlane build` | Build without upload | Local testing |
| `fastlane test` | Run all tests | Pre-deployment checks |
| `fastlane bump` | Increment version | Manual version control |
| `fastlane metadata` | Update metadata only | Fix descriptions/screenshots |

---

## 📊 Version Management

Fastlane automatically manages versions:

### Build Numbers (Auto-Incremented)

```
Before: 1.0.0 (1)
After:  1.0.0 (2)  ← Build number increments
```

**Triggered by:** `fastlane beta`

### Version Numbers (Manual Control)

```
Before: 1.0.0
After:  1.0.1  ← Patch version increments
```

**Triggered by:** `fastlane release`

**To change bump type:**

Edit `ios/fastlane/Fastfile`, line ~70:

```ruby
increment_version_number(
  bump_type: "patch",  # 1.0.0 → 1.0.1
  # bump_type: "minor",  # 1.0.0 → 1.1.0
  # bump_type: "major",  # 1.0.0 → 2.0.0
  xcodeproj: "Runner.xcodeproj"
)
```

---

## 🔐 Security & Credentials

### Environment Variables (`.env`)

Credentials stored in `ios/fastlane/.env` (gitignored):

```bash
FASTLANE_USER=your.apple.id@example.com
FASTLANE_PASSWORD=xxxx-xxxx-xxxx-xxxx
FASTLANE_ITC_TEAM_ID=123456789
FASTLANE_TEAM_ID=123456789
```

**Important:**
- ✅ Never commit `.env` file
- ✅ Use app-specific passwords (not main Apple ID password)
- ✅ Rotate passwords every 6 months
- ✅ Each developer needs their own `.env`

### Creating App-Specific Password

1. Visit: https://appleid.apple.com
2. **Security** → **App-Specific Passwords**
3. Click **Generate Password**
4. Name: "Fastlane"
5. Copy password → paste into `.env`

---

## 📈 Deployment Checklist

Before every production release:

### Pre-Deployment

- [ ] All code changes committed and pushed
- [ ] Tests passing locally (`fastlane test`)
- [ ] Version number appropriate for changes
- [ ] Release notes updated
- [ ] On `main` branch
- [ ] Local build successful

### During Deployment

- [ ] Run `fastlane release`
- [ ] Monitor output for errors
- [ ] Verify upload succeeded (check App Store Connect)

### Post-Deployment

- [ ] Build processing complete (~30-60 min)
- [ ] Screenshots and metadata correct
- [ ] Submission successful
- [ ] Git tag created
- [ ] Team notified

---

## 🐛 Troubleshooting

### Common Issues

#### 1. Invalid Password

**Error:** `Invalid username and password combination`

**Solution:**
- Use **app-specific password**, NOT your Apple ID password
- Regenerate at: https://appleid.apple.com
- Update `ios/fastlane/.env`

#### 2. Team Not Found

**Error:** `Could not find team with ID`

**Solution:**
```bash
# List all teams
fastlane produce list_teams

# Update ios/fastlane/Appfile with correct Team ID
```

#### 3. Code Signing Failed

**Error:** `No valid code signing identity`

**Solution:**
- Open Xcode → Settings → Accounts
- Select your Apple ID
- Click **Download Manual Profiles**
- Retry deployment

#### 4. Build Already Exists

**Error:** `Build with version already exists`

**Solution:**
```bash
# Increment build number manually
cd ios
agvtool next-version -all

# Or increment in Xcode:
# Runner → General → Build number (increment by 1)
```

### Full Troubleshooting Guide

See: [ios/fastlane/FASTLANE_SETUP.md](ios/fastlane/FASTLANE_SETUP.md#troubleshooting)

---

## 📚 Additional Resources

- **Fastlane Documentation:** https://docs.fastlane.tools
- **App Store Connect:** https://appstoreconnect.apple.com
- **TestFlight Guide:** https://developer.apple.com/testflight/
- **App Store Review Guidelines:** https://developer.apple.com/app-store/review/guidelines/

---

## 🆘 Need Help?

1. Check [FASTLANE_SETUP.md](ios/fastlane/FASTLANE_SETUP.md)
2. Check [QUICKSTART.md](ios/fastlane/QUICKSTART.md)
3. Search Fastlane docs: https://docs.fastlane.tools
4. Ask on Fastlane community: https://fastlane.tools/community

---

**Last Updated:** December 19, 2025
**Platform:** iOS only (Flutter project)
**Bundle ID:** com.elev8tion.everydaychristian
