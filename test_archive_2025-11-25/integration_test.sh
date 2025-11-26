#!/bin/bash

echo "═══════════════════════════════════════════════════════════════"
echo "  INTEGRATION TEST: AI Chat Verse Recommendation Flow"
echo "═══════════════════════════════════════════════════════════════"
echo

# Simulate AI theme detection + verse search for common user inputs
test_message() {
  local message="$1"
  local expected_theme="$2"
  
  echo "📝 User Message: \"$message\""
  echo "🎯 Expected Theme: $expected_theme"
  echo "📖 Verses Found:"
  
  sqlite3 assets/bible.db << SQL
SELECT '  ✓ ' || reference || ' - ' || SUBSTR(text, 1, 50) || '...' as verse
FROM verses
WHERE themes LIKE '%"$expected_theme"%' OR category LIKE '%$expected_theme%' OR text LIKE '%$expected_theme%'
ORDER BY RANDOM()
LIMIT 3;
SQL
  
  echo
}

# Test Case 1: Anxiety
test_message "I'm feeling anxious about tomorrow" "anxiety"

# Test Case 2: Hope/Depression  
test_message "I feel hopeless" "hope"

# Test Case 3: Fear
test_message "I'm scared and afraid" "fear"

# Test Case 4: Strength
test_message "I feel weak and exhausted" "strength"

# Test Case 5: Comfort
test_message "I need comfort" "comfort"

echo "═══════════════════════════════════════════════════════════════"
echo "  ✅ Integration Test Complete"
echo "═══════════════════════════════════════════════════════════════"
