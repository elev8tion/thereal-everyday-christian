#!/bin/bash

echo "=== SCREENS WITHOUT TESTS ==="
for file in lib/screens/*.dart; do
  name=$(basename "$file" .dart)
  if [ ! -f "test/screens/${name}_test.dart" ] && [ ! -f "test/${name}_test.dart" ]; then
    echo "  - $(basename $file)"
  fi
done

echo ""
echo "=== SERVICES WITHOUT TESTS ==="
for file in lib/services/*.dart; do
  name=$(basename "$file" .dart)
  if [ ! -f "test/services/${name}_test.dart" ] && [ ! -f "test/${name}_test.dart" ]; then
    echo "  - $(basename $file)"
  fi
done

echo ""
echo "=== CORE SERVICES WITHOUT TESTS ==="
for file in lib/core/services/*.dart; do
  name=$(basename "$file" .dart)
  if [ ! -f "test/services/${name}_test.dart" ] && [ ! -f "test/${name}_test.dart" ] && [ ! -f "test/core/services/${name}_test.dart" ]; then
    echo "  - $(basename $file)"
  fi
done

echo ""
echo "=== COMPONENTS WITHOUT TESTS ==="
count=0
for file in lib/components/*.dart; do
  name=$(basename "$file" .dart)
  if [ ! -f "test/components/${name}_test.dart" ] && [ ! -f "test/${name}_test.dart" ]; then
    echo "  - $(basename $file)"
    ((count++))
  fi
done
echo "  Total: $count components without tests"

echo ""
echo "=== WIDGETS WITHOUT TESTS ==="
for file in lib/widgets/*.dart; do
  name=$(basename "$file" .dart)
  if [ ! -f "test/widgets/${name}_test.dart" ] && [ ! -f "test/${name}_test.dart" ]; then
    echo "  - $(basename $file)"
  fi
done

echo ""
echo "=== FEATURES WITHOUT TESTS ==="
find lib/features -name "*.dart" -type f | while read file; do
  # Extract relative path from lib/
  rel_path=${file#lib/}
  # Construct test path
  test_path="test/${rel_path%.dart}_test.dart"
  if [ ! -f "$test_path" ]; then
    echo "  - $rel_path"
  fi
done
