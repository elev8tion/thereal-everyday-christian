# 🧪 Pre-Submission Critical Test Plan

**Date Created:** October 29, 2025
**App Version:** 1.0 (Build TBD)
**Device:** iPhone 16e Simulator (iOS 18.6)
**Tester:** Manual testing required
**Related:** AUDIT_REPORT_2025-01-29.md

---

## 📋 Test Overview

These tests verify critical bug fixes from the comprehensive audit:
- ✅ Unprotected database write fix (commit 6ced31d)
- ✅ Timestamp boundary fixes (commits 7640e8f, acb08ec)

**Goal:** Ensure app handles edge cases gracefully without crashing before App Store submission.

---

## 🧪 TEST 1: Low Storage Scenario

**Purpose:** Verify app doesn't crash when device storage is nearly full
**Related Fix:** chat_screen.dart:389 - Database write now wrapped in try-catch
**Severity if fails:** 🔴 CRITICAL - App Store rejection risk

### Setup Steps:
1. Open iPhone Simulator
2. Fill simulator storage to <100MB:
   ```bash
   # Create large dummy file in simulator
   DEVICE_ID="61EED997-BFC5-4844-8294-E2C8116F0DEA"
   SIM_PATH="$HOME/Library/Developer/CoreSimulator/Devices/$DEVICE_ID/data"

   # Create 10GB dummy file to fill storage
   cd "$SIM_PATH"
   dd if=/dev/zero of=dummy.dat bs=1m count=10000
   ```

3. Launch Everyday Christian app
4. Navigate to AI Chat screen

### Test Procedure:
1. **Send a chat message** (e.g., "What is faith?")
2. **Observe behavior:**
   - ✅ **PASS:** Message appears in UI, AI responds (or shows error)
   - ✅ **PASS:** SnackBar appears if DB save fails (graceful degradation)
   - ✅ **PASS:** App continues functioning
   - ❌ **FAIL:** App crashes with SQLite error
   - ❌ **FAIL:** App freezes/hangs

3. **Try sending 3 more messages** to verify continued functionality
4. **Check debug logs** for database save errors:
   ```
   Expected log: "⚠️ Failed to save user message: [error]"
   ```

### Expected Results:
- ✅ User message appears in chat UI immediately
- ✅ AI response streams normally (or fails gracefully if storage full)
- ✅ App doesn't crash
- ✅ Debug log shows "⚠️ Failed to save user message" if DB write fails
- ⚠️ Messages may not persist after app restart (acceptable - storage full)

### Cleanup:
```bash
# Remove dummy file
rm "$SIM_PATH/dummy.dat"
```

### Status: [ ] PASS / [ ] FAIL
**Notes:**

---

## 🧪 TEST 2: Database Corruption

**Purpose:** Verify app recovers gracefully from database corruption
**Related Fix:** chat_screen.dart:389 - Database write error handling
**Severity if fails:** 🔴 CRITICAL - Data loss risk

### Setup Steps:
1. Launch app and send 1-2 chat messages successfully
2. **While sending a message**, kill the app process:
   ```bash
   # Get app PID
   xcrun simctl spawn 61EED997-BFC5-4844-8294-E2C8116F0DEA \
     launchctl list | grep everydaychristian

   # Kill process during message send
   kill -9 <PID>
   ```

### Test Procedure:
1. **Relaunch the app**
2. **Navigate to AI Chat**
3. **Observe behavior:**
   - ✅ **PASS:** App launches successfully
   - ✅ **PASS:** Previous messages load (or empty if corrupted)
   - ✅ **PASS:** Can send new messages
   - ❌ **FAIL:** App crashes on launch
   - ❌ **FAIL:** Database error prevents chat usage

4. **Send a new message** to verify DB is still functional
5. **Check Settings > Delete All Data** works if DB is corrupted

### Expected Results:
- ✅ App relaunches without crashing
- ✅ Either previous messages load OR chat is empty (both acceptable)
- ✅ New messages can be sent successfully
- ✅ If corruption detected, "Delete All Data" resets DB cleanly

### Recovery Path:
If database is corrupted:
1. User goes to Settings
2. Taps "Delete All Data"
3. Confirms deletion
4. App resets database
5. User can resume using chat

### Status: [ ] PASS / [ ] FAIL
**Notes:**

---

## 🧪 TEST 3: Network Offline

**Purpose:** Verify app handles offline state gracefully
**Severity if fails:** 🟡 MEDIUM - User experience issue

### Setup Steps:
1. Launch app normally
2. Disable network on simulator:
   ```bash
   # Disconnect network
   xcrun simctl status_bar 61EED997-BFC5-4844-8294-E2C8116F0DEA \
     override --dataNetwork no-service --wifiMode failed
   ```

### Test Procedure:
1. **Try to send a chat message** while offline
2. **Observe behavior:**
   - ✅ **PASS:** Message appears in UI
   - ✅ **PASS:** Loading indicator shows
   - ✅ **PASS:** Error message appears after timeout (e.g., "Network error")
   - ✅ **PASS:** App doesn't crash
   - ❌ **FAIL:** App freezes waiting for network
   - ❌ **FAIL:** App crashes with network error

3. **Reconnect network:**
   ```bash
   xcrun simctl status_bar 61EED997-BFC5-4844-8294-E2C8116F0DEA clear
   ```

4. **Send another message** - should work normally

### Expected Results:
- ✅ Offline message send shows loading → timeout → error
- ✅ Error message is user-friendly (not raw exception)
- ✅ User can dismiss error and try again
- ✅ App resumes normally when network returns

### Error Message Should Say:
- "Unable to connect to AI service. Please check your internet connection."
- NOT: "SocketException: Failed host lookup" (too technical)

### Status: [ ] PASS / [ ] FAIL
**Notes:**

---

## 🧪 TEST 4: Background Interruption

**Purpose:** Verify app handles iOS lifecycle events during message send
**Severity if fails:** 🟡 MEDIUM - User experience issue

### Setup Steps:
1. Launch app
2. Navigate to AI Chat

### Test Procedure:
1. **Send a chat message**
2. **IMMEDIATELY lock the simulator** (Cmd+L) while AI is streaming response
3. **Wait 10 seconds**
4. **Unlock simulator**
5. **Observe behavior:**
   - ✅ **PASS:** Message stream resumes OR shows completion
   - ✅ **PASS:** App state is preserved
   - ✅ **PASS:** Can send new messages
   - ❌ **FAIL:** App crashes or shows error
   - ❌ **FAIL:** Message disappears
   - ❌ **FAIL:** App is stuck in loading state

6. **Try sending a new message** to verify app recovered

### Alternative Test:
1. Send message
2. **Swipe up to home screen** (background app) during streaming
3. Wait 30 seconds
4. Reopen app
5. Verify chat state

### Expected Results:
- ✅ AI response completes (or shows partial response)
- ✅ User can send new messages
- ✅ No crashed state or frozen UI
- ⚠️ Partial response acceptable (stream interrupted)

### Status: [ ] PASS / [ ] FAIL
**Notes:**

---

## 📊 Test Results Summary

| Test | Status | Severity | Critical? | Notes |
|------|--------|----------|-----------|-------|
| 1. Low Storage | [ ] | 🔴 CRITICAL | YES | |
| 2. DB Corruption | [ ] | 🔴 CRITICAL | YES | |
| 3. Network Offline | [ ] | 🟡 MEDIUM | NO | |
| 4. Background Interrupt | [ ] | 🟡 MEDIUM | NO | |

**Overall Result:** [ ] PASS ALL / [ ] FAIL SOME

**Critical Tests (MUST PASS):**
- Test 1: Low Storage
- Test 2: Database Corruption

**Nice-to-Have Tests (Should pass, but not blockers):**
- Test 3: Network Offline
- Test 4: Background Interruption

---

## 🚀 Approval Criteria

**Ready for TestFlight if:**
- ✅ Tests 1 & 2 PASS (critical edge cases)
- ✅ Tests 3 & 4 PASS or have documented workarounds

**Needs fixes if:**
- ❌ Test 1 or 2 FAILS → Fix immediately, re-test
- ⚠️ Test 3 or 4 FAILS → Document known issue, acceptable for beta

---

## 📝 Additional Verification

After running all 4 tests, verify:

1. **Timestamp fixes are working:**
   - Send a chat message today
   - Wait until after midnight
   - Check conversation history bottom sheet
   - Timestamp should say "Yesterday" (not "Today")

2. **Prayer journal dates:**
   - Add a prayer today
   - Wait until after midnight
   - Check prayer journal
   - Date should update to "Yesterday"

3. **Subscription state persists:**
   - Check subscription status in Settings
   - Delete all data
   - Relaunch app
   - Subscription should auto-restore (if premium)

---

## 🔧 Debugging Commands

**View app logs:**
```bash
xcrun simctl spawn 61EED997-BFC5-4844-8294-E2C8116F0DEA \
  log stream --predicate 'processImagePath contains "everydaychristian"' \
  --level debug
```

**Check app storage:**
```bash
xcrun simctl get_app_container 61EED997-BFC5-4844-8294-E2C8116F0DEA \
  com.elev8tion.everydaychristian
```

**Reset simulator:**
```bash
xcrun simctl erase 61EED997-BFC5-4844-8294-E2C8116F0DEA
```

---

**Test Plan Created:** October 29, 2025
**Next Steps:** Run manual tests, document results, approve for TestFlight
**Related Commits:**
- 6ced31d - Database error handling fix
- 7640e8f - Chat timestamp fix
- acb08ec - Prayer timestamp fix
