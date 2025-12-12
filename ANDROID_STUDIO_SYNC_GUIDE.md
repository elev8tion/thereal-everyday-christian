# Android Studio Sync Guide

## Opening the Project

### First Time Setup
```bash
# Your project location
/Users/kcdacre8tor/thereal-everyday-christian
```

1. **Open Android Studio**
2. **Select "Open"** from welcome screen
3. **Navigate to** the project folder above
4. **Click Open**

### If Already Open
The project auto-syncs, but you can force sync:

## Sync Methods

### 1. Gradle Sync (Most Important)
- **Menu**: File → Sync Project with Gradle Files
- **Toolbar**: Click the elephant icon 🐘
- **Shortcut**: None by default

### 2. Reload Changes from Disk
- **Menu**: File → Reload from Disk
- **Shortcut**: ⌘+⌥+Y (Mac) / Ctrl+Alt+Y (Windows)

### 3. Invalidate Caches (If Issues Persist)
- **Menu**: File → Invalidate Caches...
- **Select**: "Invalidate and Restart"
- Use when: Icons not updating, files not showing

## After Our Icon Changes

### Recommended Steps:
1. **Pull Latest Changes** (if needed):
   ```bash
   git pull origin main
   ```

2. **In Android Studio**:
   - Build → Clean Project
   - Build → Rebuild Project
   - Run → Run 'app' (or press ▶️)

3. **Check Icon Updates**:
   - Look in: `android/app/src/main/res/mipmap-*`
   - Spanish icons: `android/app/src/main/res/mipmap-es-r*`

## Real-Time Sync

### What Syncs Automatically:
✅ Code changes (.dart files)
✅ Asset changes (images, icons)
✅ Configuration files (pubspec.yaml)
✅ Android resources (res/ folder)

### What Needs Manual Sync:
⚠️ Gradle dependencies (click sync)
⚠️ Build configuration changes
⚠️ New Flutter packages (run `flutter pub get`)

## Troubleshooting

### Icons Not Showing?
1. Build → Clean Project
2. Build → Rebuild Project
3. Uninstall app from device/emulator
4. Run → Run 'app'

### Files Not Appearing?
1. Right-click project root
2. Select "Synchronize"
3. Or File → Reload from Disk

### Gradle Sync Failed?
1. Check `android/gradle.properties`
2. File → Invalidate Caches and Restart
3. Run in terminal:
   ```bash
   cd android
   ./gradlew clean
   ./gradlew build
   ```

## Terminal vs Android Studio

| Action | Terminal (Here) | Android Studio |
|--------|----------------|----------------|
| Edit Code | ✅ Changes saved to disk | ✅ Auto-reloads |
| Run App | `flutter run` | Click Run button |
| Hot Reload | Press 'r' | Click ⚡ button |
| Git Operations | `git add/commit/push` | VCS menu |
| View Logs | Terminal output | Logcat window |

## Best Practices

1. **Keep Android Studio Open** while working here
   - It auto-syncs most changes
   - Provides visual feedback

2. **Use Android Studio For**:
   - Visual layout preview
   - Debugging with breakpoints
   - Logcat monitoring
   - Gradle management
   - APK signing

3. **Use Terminal/VS Code For**:
   - Quick edits
   - Git operations
   - Running flutter commands
   - Package management

## Current Project State

- **Latest Commit**: Icon updates with language variants
- **Branch**: main
- **Icons Updated**: ✅
- **Spanish Support**: ✅
- **Ready to Build**: ✅