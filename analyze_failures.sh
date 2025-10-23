#!/bin/bash

echo "=== COMPILATION ERRORS BY FILE ==="
grep "^test/.*\.dart:" test_output.txt | cut -d: -f1 | sort | uniq -c | sort -rn

echo ""
echo "=== MOST COMMON ERROR TYPES ==="
grep "Error:" test_output.txt | grep -oE "Error: [^\.]*\." | sort | uniq -c | sort -rn | head -10

echo ""
echo "=== RUNTIME TEST FAILURES ==="
grep "\[E\]" test_output.txt | grep -oE "test/[^:]*_test.dart" | sort | uniq -c | sort -rn
