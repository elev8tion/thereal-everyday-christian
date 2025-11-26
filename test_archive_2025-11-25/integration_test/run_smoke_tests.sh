#!/bin/bash

# Everyday Christian - Smoke Test Runner
# This script runs the comprehensive smoke test suite to verify app functionality
# before TestFlight/App Store submission.

set -e  # Exit on any error

echo "================================================"
echo "   EVERYDAY CHRISTIAN - SMOKE TEST SUITE"
echo "================================================"
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter is not installed or not in PATH${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Flutter found${NC}"
echo ""

# Check for connected devices
echo "Checking for connected devices..."
devices=$(flutter devices)

if echo "$devices" | grep -q "No devices detected"; then
    echo -e "${RED}❌ No devices connected${NC}"
    echo "Please connect a device or start an emulator/simulator"
    exit 1
fi

echo -e "${GREEN}✅ Device found${NC}"
echo "$devices"
echo ""

# Run smoke tests based on argument
if [ "$1" == "all" ] || [ -z "$1" ]; then
    echo "================================================"
    echo "   RUNNING FULL SMOKE TEST SUITE"
    echo "================================================"
    echo ""

    # Run all smoke tests
    echo -e "${YELLOW}Running Test 1: App Launch & Core Flow...${NC}"
    flutter test integration_test/01_app_launch_smoke_test.dart

    echo -e "${YELLOW}Running Test 2: Subscription & Trial Flow...${NC}"
    flutter test integration_test/02_subscription_trial_smoke_test.dart

    echo -e "${YELLOW}Running Test 3: Bible Reading Features...${NC}"
    flutter test integration_test/03_bible_reading_smoke_test.dart

    echo -e "${YELLOW}Running Test 4: Devotionals & Reading Plans...${NC}"
    flutter test integration_test/04_devotional_reading_plan_smoke_test.dart

    echo -e "${YELLOW}Running Test 5: Prayer, Verse Library & Chat...${NC}"
    flutter test integration_test/05_prayer_verse_chat_smoke_test.dart

    echo -e "${YELLOW}Running Test 6: Settings, Profile & Offline...${NC}"
    flutter test integration_test/06_settings_profile_offline_smoke_test.dart

    echo -e "${YELLOW}Running Test 7: Comprehensive Integration...${NC}"
    flutter test integration_test/07_comprehensive_integration_smoke_test.dart

elif [ "$1" == "quick" ]; then
    echo "================================================"
    echo "   RUNNING QUICK SMOKE TESTS"
    echo "================================================"
    echo ""

    # Run only critical path tests
    echo -e "${YELLOW}Running Test 1: App Launch (Critical)...${NC}"
    flutter test integration_test/01_app_launch_smoke_test.dart

    echo -e "${YELLOW}Running Test 2: Subscription (Critical)...${NC}"
    flutter test integration_test/02_subscription_trial_smoke_test.dart

    echo -e "${YELLOW}Running Test 7: Integration (Critical)...${NC}"
    flutter test integration_test/07_comprehensive_integration_smoke_test.dart

elif [ "$1" == "features" ]; then
    echo "================================================"
    echo "   RUNNING FEATURE-SPECIFIC SMOKE TESTS"
    echo "================================================"
    echo ""

    # Run feature tests only
    echo -e "${YELLOW}Running Test 3: Bible Reading...${NC}"
    flutter test integration_test/03_bible_reading_smoke_test.dart

    echo -e "${YELLOW}Running Test 4: Devotionals...${NC}"
    flutter test integration_test/04_devotional_reading_plan_smoke_test.dart

    echo -e "${YELLOW}Running Test 5: Prayer & Verses...${NC}"
    flutter test integration_test/05_prayer_verse_chat_smoke_test.dart

    echo -e "${YELLOW}Running Test 6: Settings & Offline...${NC}"
    flutter test integration_test/06_settings_profile_offline_smoke_test.dart

elif [[ "$1" =~ ^[0-9]+$ ]]; then
    # Run specific test by number
    echo "================================================"
    echo "   RUNNING SMOKE TEST #$1"
    echo "================================================"
    echo ""

    test_file="integration_test/0${1}_*.dart"
    if ls $test_file 1> /dev/null 2>&1; then
        flutter test $test_file
    else
        echo -e "${RED}❌ Test file not found: $test_file${NC}"
        exit 1
    fi

else
    echo "Usage: ./run_smoke_tests.sh [option]"
    echo ""
    echo "Options:"
    echo "  all        - Run all smoke tests (default)"
    echo "  quick      - Run critical path tests only"
    echo "  features   - Run feature-specific tests"
    echo "  1-7        - Run specific test by number"
    echo ""
    echo "Available tests:"
    echo "  1 - App Launch & Core Flow"
    echo "  2 - Subscription & Trial Flow"
    echo "  3 - Bible Reading Features"
    echo "  4 - Devotionals & Reading Plans"
    echo "  5 - Prayer, Verse Library & Chat"
    echo "  6 - Settings, Profile & Offline"
    echo "  7 - Comprehensive Integration"
    exit 1
fi

echo ""
echo "================================================"
echo -e "${GREEN}   ✅ ALL SMOKE TESTS PASSED!"
echo "================================================${NC}"
echo ""
echo "Your app is ready for:"
echo "  ✓ TestFlight beta testing"
echo "  ✓ App Store submission"
echo ""
echo "Next steps:"
echo "  1. Run ./run_smoke_tests.sh on physical iOS device"
echo "  2. Run ./run_smoke_tests.sh on physical Android device"
echo "  3. Review TestFlight release notes"
echo "  4. Submit to TestFlight for beta testing"
echo ""
