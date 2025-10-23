# Verse Library Redesign - Decisions & Next Steps

**Date:** 2025-01-20
**Status:** Planning Phase - Implementation Pending

---

## Key Decisions Made

### 1. **Pivot from Pre-Populated to User-Saved Only**
- **Problem:** Current "All Verses" tab shows 100+ verses nobody chose
- **Problem:** Theme filtering uses keyword search (broken - finds "hope" in negative contexts)
- **Decision:** Verse Library = User's personal collection only
- **Impact:** More meaningful, personal experience

### 2. **New User Flow**
```
Bible Reading → User finds meaningful verse → Taps ❤️
  ↓
Theme Selection Dialog (multi-select, max 2 themes, skip option)
  ↓
Verse saves to "Saved Verses" with user-chosen themes
  ↓
User can filter their collection by themes they assigned
```

### 3. **Tab Structure Changes**
- **Tab 1:** "Saved Verses" (replaces "All Verses")
  - Shows only verses user favorited from Bible reading
  - Empty state: "💡 Save verses while reading to build your collection"
- **Tab 2:** "Shared" (replaces "Favorites" - was redundant)
  - Tracks verses user shared via OS share
  - User remembers context of who they shared with

### 4. **Theme Selection Dialog**
- **Design Pattern:** Match Help/FAQ dialog from settings (FrostedGlassCard)
- **UI:** Multi-select checkboxes, limit to 2 themes
- **Themes:** Show all 25 available themes
- **Skip Option:** User can save without themes
- **Trigger:** Shows when user taps ❤️ on unfavorited verse

### 5. **Existing Favorite Button Behavior**
When verse already favorited and user taps ❤️ again:
- **Decision Needed:** Remove? Edit themes? Confirmation dialog?
- **Status:** ⏸️ Awaiting user input

### 6. **Pre-Populated Verses**
- **Keep in database:** Still used for Daily Verse, Bible reading content
- **Remove from display:** Don't show in Verse Library tabs
- **Future:** May find other use cases

---

## Implementation Tasks (In Order)

### Phase 1: Database & Theme Management
- [ ] Create verse_themes junction table (if needed)
- [ ] Add "shared" flag to favorite_verses table
- [ ] Create theme color mapping (like prayer categories)

### Phase 2: Theme Selection Dialog
- [ ] Create dialog component using FrostedGlassCard pattern
- [ ] Add multi-select checkboxes (max 2)
- [ ] Add "Skip" button
- [ ] Integrate with favorite button in chapter_reading_screen.dart

### Phase 3: Verse Library Screen Updates
- [ ] Rename "All Verses" → "Saved Verses"
- [ ] Add "Shared" tab
- [ ] Filter out pre-populated verses from display
- [ ] Update empty state messaging
- [ ] Fix theme badges to show user-assigned themes with colors

### Phase 4: Share Tracking
- [ ] Detect when user shares verse via OS share
- [ ] Mark verse as "shared" in database
- [ ] Display shared verses in "Shared" tab

### Phase 5: Theme Colors & Badges
- [ ] Create color assignments for all 25 themes
- [ ] Update CategoryBadge to accept theme colors
- [ ] Show filtered theme color on verse cards

---

## Open Questions

1. **Favorite button re-tap behavior?** (Remove vs Edit themes vs Confirm)
2. **Theme color scheme?** (Consistent across app or unique palette?)
3. **Share detection?** (How to track OS share events?)

---

## Technical Notes

### Key Files
- `lib/screens/chapter_reading_screen.dart:495` - _toggleFavorite() method
- `lib/screens/verse_library_screen.dart` - Main screen to update
- `lib/services/unified_verse_service.dart:78` - searchByTheme() (currently broken)
- `lib/screens/settings_screen.dart:1464` - Help dialog pattern to copy

### Existing Components to Reuse
- FrostedGlassCard (from settings Help dialog)
- CategoryBadge (from prayer journal)
- GlassButton (existing button component)
- Visibility widget (for layout stability)

---

## Work Log System Discussion

**Decision Pending:** Create real-time work log after each task completion
- Format: `Work Logs/YYYY-MM-DD.md`
- Include: timestamp, what, why, how, files, line numbers, commit hash
- Trigger: After every completed task (not just commits)
- Status: To be implemented after current redesign work

---

**Next Action:** Return to active implementation work
