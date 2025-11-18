# Android Release Signing Setup Guide

**Last Updated:** November 18, 2025
**App:** Everyday Christian
**Package:** com.everydaychristian.app

---

## 🔐 Generate Release Keystore (One-Time Setup)

### Step 1: Create Keystore File

Run this command in your terminal (from the project root):

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias everyday-christian-key
```

**Prompts and Recommended Answers:**
```
Enter keystore password: [CREATE STRONG PASSWORD - SAVE IT!]
Re-enter new password: [REPEAT PASSWORD]

What is your first and last name?
  [Your Name or Company Name]: Elev8tion

What is the name of your organizational unit?
  [Your Team]: Development

What is the name of your organization?
  [Your Company]: Elev8tion

What is the name of your City or Locality?
  [Your City]: [Your City]

What is the name of your State or Province?
  [Your State]: [Your State]

What is the two-letter country code for this unit?
  [Country Code]: US

Is CN=..., OU=..., O=..., L=..., ST=..., C=... correct?
  [no]: yes

Enter key password for <everyday-christian-key>
  (RETURN if same as keystore password): [PRESS ENTER]
```

**Result:** Creates `~/upload-keystore.jks` in your home directory

---

## 📝 Step 2: Create key.properties File

Create file: `android/key.properties`

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=everyday-christian-key
storeFile=/Users/YOUR_USERNAME/upload-keystore.jks
```

**IMPORTANT:**
- Replace `YOUR_KEYSTORE_PASSWORD` with the password you created
- Replace `YOUR_KEY_PASSWORD` with the key password (same as keystore if you pressed ENTER)
- Replace `YOUR_USERNAME` with your actual macOS username
- Add `key.properties` to `.gitignore` (already done ✅)

---

## 🔧 Step 3: Update build.gradle.kts

The signing configuration is already prepared in `android/app/build.gradle.kts`.

**Uncomment lines 50-58 and 41-42:**

```kotlin
// BEFORE (commented out):
// signingConfigs {
//     release {
//         storeFile = file("release-keystore.jks")
//         storePassword = System.getenv("KEYSTORE_PASSWORD")
//         keyAlias = System.getenv("KEY_ALIAS")
//         keyPassword = System.getenv("KEY_PASSWORD")
//     }
// }

// AFTER (uncommented and updated):
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = java.util.Properties()
keystoreProperties.load(java.io.FileInputStream(keystorePropertiesFile))

android {
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            // ... rest of release config
        }
    }
}
```

---

## 🚀 Step 4: Build Release APK/AAB

### Build App Bundle (for Google Play Store):
```bash
flutter build appbundle --release
```

**Output:** `build/app/outputs/bundle/release/app-release.aab`

### Build APK (for direct distribution or testing):
```bash
flutter build apk --release
```

**Output:** `build/app/outputs/flutter-apk/app-release.apk`

---

## 🔒 Security Checklist

- ✅ `key.properties` added to `.gitignore`
- ✅ Keystore file stored outside project directory (`~/upload-keystore.jks`)
- ✅ Passwords saved in secure password manager
- ✅ Backup keystore file to secure cloud storage
- ❌ **NEVER** commit keystore or passwords to Git

---

## 📋 Google Play Console Setup

### 1. Create App Listing
- **App Name:** Everyday Christian
- **Package Name:** com.everydaychristian.app
- **Category:** Lifestyle > Faith & Religion

### 2. Upload Release Bundle
1. Go to "Release" → "Production"
2. Click "Create new release"
3. Upload `app-release.aab`
4. Version: 1.0.0 (13)

### 3. Content Rating
- Select: "Faith & Religion" app
- Answer questionnaire (No violence, No mature content)
- Expected: "Everyone" rating

### 4. App Content
- Privacy Policy URL: [Your hosted privacy policy URL]
- Target audience: Ages 13+
- Ads: No (no ads in app)
- In-app purchases: Yes (Premium subscription)

---

## 🔍 Verify Build

### Check APK Contents:
```bash
# Extract APK to inspect
unzip -l build/app/outputs/flutter-apk/app-release.apk

# Check if properly signed
jarsigner -verify -verbose -certs build/app/outputs/flutter-apk/app-release.apk
```

### Test on Physical Device:
```bash
# Install release APK
adb install build/app/outputs/flutter-apk/app-release.apk

# Or run release build directly
flutter run --release
```

---

## 🆘 Troubleshooting

### Error: "Keystore file not found"
- Check `storeFile` path in `key.properties`
- Ensure `~/upload-keystore.jks` exists
- Use absolute path (not `~`)

### Error: "Incorrect keystore password"
- Verify password in `key.properties`
- Try generating new keystore if forgotten

### Error: "Build fails with signing errors"
- Ensure `key.properties` is in `android/` directory
- Check all fields are filled in `key.properties`
- Verify keystore file path is correct

---

## 📚 Additional Resources

- [Flutter Android Release Docs](https://docs.flutter.dev/deployment/android)
- [Google Play Console](https://play.google.com/console)
- [Android App Signing](https://developer.android.com/studio/publish/app-signing)

---

**Next Steps After Signing Setup:**
1. Build and test release APK
2. Create Google Play Console account
3. Complete app listing with screenshots and descriptions
4. Submit for review