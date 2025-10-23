#!/bin/bash
echo "Analyzing test suite metrics..."

# Count test blocks
total_tests=$(grep -rh "test(" test/ --include="*_test.dart" 2>/dev/null | wc -l)
total_groups=$(grep -rh "group(" test/ --include="*_test.dart" 2>/dev/null | wc -l)
total_widget_tests=$(grep -rh "testWidgets(" test/ --include="*_test.dart" 2>/dev/null | wc -l)

echo "Total test() blocks: $total_tests"
echo "Total testWidgets() blocks: $total_widget_tests"
echo "Total group() blocks: $total_groups"
echo "Combined test cases: $((total_tests + total_widget_tests))"
