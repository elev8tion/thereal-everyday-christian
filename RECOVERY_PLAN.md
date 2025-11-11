# 🔧 Project Recovery Plan
**Created:** 2025-11-11  
**Issue:** Spanish Bible integration caused UI/data alignment issues  
**Goal:** Get everything back on track with proper Spanish + English support

---

## 📊 Current State Assessment

### ✅ What's Working:
1. **Spanish Devotionals:** Complete in `assets/devotionals/es/` folder
2. **English Devotionals:** Complete in `assets/devotionals/en/` folder  
3. **Database Schemas:** Both English and Spanish Bible databases have correct structure
4. **BibleConfig:** Centralized language mapping exists
5. **Core Architecture:** Database version 19 with language support

### ❌ What's Broken:
1. **UI Data Binding:** Spanish verses not displaying correctly
2. **Data Alignment:** Mismatch between what's loaded and what UI expects
3. **Claude Code Sessions:** Multiple incomplete refactors caused drift

---

## 🎯 Recovery Steps

### Phase 1: Verify Current Database State (5 min)

**Check if Spanish verses actually loaded:**

```bash
# Find the app's main database
find ~/Library/Containers -name "everyday_christian.db" 2>/dev/null

# Or check iOS simulator
find ~/Library/Developer/CoreSimulator -name "everyday_christian.db" 2>/dev/null

# Check verse counts in main DB
sqlite3 [PATH_TO_DB] "SELECT language, COUNT(*) FROM bible_verses GROUP BY language;"
```

**Expected Result:**
- English (en): ~31,000 verses
- Spanish (es): ~31,000 verses

**If verses missing:** App hasn't loaded them yet (first launch needed)

---

### Phase 2: Clean Up Code Issues (15 min)

#### Issue 1: BibleLoaderService - Verify Column Mapping

**File:** `lib/core/services/bible_loader_service.dart`

**Current Code (Line 151):**
```dart
spanish_text as text,  // ✅ CORRECT - column exists
```

**Verification Needed:** Check if WHERE clause is filtering correctly:
```dart
WHERE spanish_text IS NOT NULL AND LENGTH(spanish_text) > 0
```

**Action:** Add logging to see what's happening:

```dart
// After line 151, add:
print('📚 Loading Spanish verses from RVR1909...');

// After the INSERT statement (around line 167), add:
final count = await db.rawQuery('SELECT COUNT(*) as count FROM bible_verses WHERE language = "es"');
print('✅ Loaded ${count.first['count']} Spanish verses');
```

---

#### Issue 2: UnifiedVerseService - Language-Aware Queries

**File:** `lib/services/unified_verse_service.dart`

**Problem:** Search queries might not be filtering by language correctly

**Fix:** Update search methods to accept language parameter:

```dart
/// Search verses by text content using FTS5 full-text search
Future<List<BibleVerse>> searchVerses(
  String query, {
  int limit = 20,
  String? language, // ADD THIS
}) async {
  if (query.trim().isEmpty) return [];

  try {
    final database = await _db.database;

    String whereClause = '';
    List<dynamic> args = [query];
    
    // ADD LANGUAGE FILTER
    if (language != null) {
      whereClause = ' AND v.language = ?';
      args.add(language);
    }

    final results = await database.rawQuery('''
      SELECT v.id, v.book, v.chapter, v.verse as verse_number, v.text,
             v.version as translation, v.language, v.themes, v.category, v.reference,
             snippet(bible_verses_fts, 0, '<mark>', '</mark>', '...', 32) as snippet,
             rank
      FROM bible_verses_fts
      JOIN bible_verses v ON bible_verses_fts.rowid = v.id
      WHERE bible_verses_fts MATCH ?$whereClause
      ORDER BY rank, RANDOM()
      LIMIT ?
    ''', [...args, limit]);
    
    // ... rest of method
  }
}
```

**Apply same pattern to:**
- `searchByTheme()`
- `getVersesForSituation()`
- `getDailyVerse()`

---

#### Issue 3: Daily Verse Service - Language Detection

**Check:** Does daily verse service respect current language?

**File to Review:** Look for daily verse providers/services

**Expected Behavior:**
```dart
final locale = Localizations.localeOf(context);
final language = BibleConfig.getLanguage(locale);
final verse = await verseService.getDailyVerse(language: language);
```

---

### Phase 3: Test Data Loading (10 min)

#### Step 1: Reset App Database

```bash
# Stop the app if running
# Then delete the app database to force fresh load:

# iOS Simulator
rm -rf ~/Library/Developer/CoreSimulator/Devices/*/data/Containers/Data/Application/*/Library/Application\ Support/everyday_christian.db

# OR just uninstall/reinstall the app
```

#### Step 2: Launch App and Monitor Logs

**Look for:**
```
📚 Loading English verses from WEB...
✅ Loaded 31103 English verses
📚 Loading Spanish verses from RVR1909...
✅ Loaded 31103 Spanish verses
```

**If loading fails:**
- Check asset paths in `pubspec.yaml`
- Verify both `.db` files are in `assets/` folder
- Check file permissions

---

### Phase 4: UI Verification (10 min)

#### Test 1: Language Switching

1. Open app in English
2. Navigate to Bible screen
3. Search for "love" → Should show English verses
4. Switch to Spanish in Settings
5. Search for "amor" → Should show Spanish verses
6. Verify book names display in Spanish (Juan, not John)

#### Test 2: Daily Verses

1. Check that daily verse respects language setting
2. Verify verse reference format matches language:
   - English: "John 3:16"
   - Spanish: "Juan 3:16"

#### Test 3: Devotionals

1. Switch to Spanish
2. Open devotional → Should show Spanish content
3. Verify Bible verses in devotional are in Spanish
4. Check that sharing works in Spanish

---

### Phase 5: Git Cleanup (5 min)

```bash
# Check what's uncommitted
git status

# If you have working changes you want to keep:
git add -A
git commit -m "WIP: Spanish integration recovery checkpoint"

# If you want to clean up:
git stash  # Save work for later
# OR
git reset --hard HEAD  # Discard all changes (DANGEROUS!)
```

---

## 🐛 Common Issues & Fixes

### Issue: "Column spanish_text not found"

**Cause:** Old database schema without the column

**Fix:**
```bash
# Check Spanish DB schema
sqlite3 assets/spanish_bible_rvr1909.db ".schema verses"

# If missing, regenerate from source
```

---

### Issue: Spanish verses show "null" or empty

**Cause:** Data didn't load or wrong column selected

**Fix:**
```sql
-- Check if data exists
SELECT COUNT(*) FROM verses WHERE spanish_text IS NOT NULL;

-- If 0, regenerate database
-- If >0, check loader SQL query
```

---

### Issue: UI shows mixed English/Spanish

**Cause:** Language detection not working in specific screens

**Fix:** Add BibleConfig imports to affected screens:
```dart
import 'package:everyday_christian/core/services/bible_config.dart';

// In build method:
final language = BibleConfig.getLanguage(Localizations.localeOf(context));
```

---

## 📝 Verification Checklist

After completing recovery:

- [ ] App launches without errors
- [ ] English verses load correctly
- [ ] Spanish verses load correctly  
- [ ] Language switching works
- [ ] Daily verses respect language
- [ ] Devotionals show correct language
- [ ] Search works in both languages
- [ ] Book names localized correctly
- [ ] Sharing works
- [ ] No console errors

---

## 🚨 If All Else Fails: Nuclear Option

```bash
# 1. Backup important files
cp -r lib/ lib_backup/
cp -r assets/ assets_backup/

# 2. Reset to last known good commit
git log --oneline -20  # Find good commit
git reset --hard [COMMIT_HASH]

# 3. Restore Spanish devotionals if lost
cp -r assets_backup/devotionals/es/ assets/devotionals/es/

# 4. Re-apply Spanish Bible changes carefully
```

---

## 📞 Next Steps

1. Run Phase 1 verification commands
2. Share results 
3. We'll proceed with targeted fixes based on what we find

---

**Questions?** Let's tackle this systematically!
