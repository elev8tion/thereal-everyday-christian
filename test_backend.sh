#!/bin/bash
# Backend Integration Tests (Fast - No Device Needed)
# Tests all backend services and data flows

set -e

echo "════════════════════════════════════════════════"
echo "🧪 BACKEND INTEGRATION TESTS"
echo "════════════════════════════════════════════════"
echo ""

echo "📦 Getting dependencies..."
flutter pub get

echo ""
echo "🔨 Running backend integration tests..."
flutter test test/integration/user_flow_test.dart --reporter expanded

echo ""
echo "════════════════════════════════════════════════"
echo "✅ BACKEND TESTS COMPLETE"
echo "════════════════════════════════════════════════"
