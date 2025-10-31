#!/bin/bash

echo "═══════════════════════════════════════════════════════════════"
echo "  FINAL INTEGRATION TEST: Verse Search Results"
echo "═══════════════════════════════════════════════════════════════"
echo

test_search() {
  local theme="$1"
  local min_expected="$2"
  
  echo "🔍 Theme: $theme (expecting $min_expected+ verses)"
  
  result=$(sqlite3 assets/bible.db "SELECT COUNT(*) FROM (SELECT * FROM verses WHERE themes LIKE '%\"$theme\"%' ORDER BY RANDOM() LIMIT 5);")
  
  if [ "$result" -ge "$min_expected" ]; then
    echo "  ✅ PASS: Found $result verses"
    sqlite3 assets/bible.db "SELECT '    📖 ' || reference || ' (' || book || ')' FROM verses WHERE themes LIKE '%\"$theme\"%' ORDER BY RANDOM() LIMIT 3;"
  else
    echo "  ❌ FAIL: Only found $result verses (needed $min_expected)"
  fi
  echo
}

test_search "anxiety" 3
test_search "hope" 3
test_search "fear" 3
test_search "comfort" 3
test_search "strength" 3
test_search "faith" 3
test_search "love" 3

echo "═══════════════════════════════════════════════════════════════"
echo "  📊 SUMMARY: Core Theme Search Results"
echo "═══════════════════════════════════════════════════════════════"

sqlite3 assets/bible.db << 'SQL'
SELECT 
  CASE 
    WHEN MIN(count) >= 3 THEN '✅ ALL THEMES HAVE 3+ VERSES'
    ELSE '⚠️  SOME THEMES HAVE <3 VERSES'
  END as status
FROM (
  SELECT COUNT(*) as count FROM verses WHERE themes LIKE '%"anxiety"%'
  UNION ALL SELECT COUNT(*) FROM verses WHERE themes LIKE '%"hope"%'
  UNION ALL SELECT COUNT(*) FROM verses WHERE themes LIKE '%"fear"%'
  UNION ALL SELECT COUNT(*) FROM verses WHERE themes LIKE '%"comfort"%'
  UNION ALL SELECT COUNT(*) FROM verses WHERE themes LIKE '%"strength"%'
  UNION ALL SELECT COUNT(*) FROM verses WHERE themes LIKE '%"faith"%'
  UNION ALL SELECT COUNT(*) FROM verses WHERE themes LIKE '%"love"%'
);
SQL

echo
echo "✅ Integration test complete!"
