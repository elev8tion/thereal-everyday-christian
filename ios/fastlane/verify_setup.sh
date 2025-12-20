#!/bin/bash

# Fastlane Setup Verification Script
# Checks if Fastlane is configured correctly for Everyday Christian iOS

set -e

echo "🔍 Verifying Fastlane Setup..."
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track errors
ERRORS=0
WARNINGS=0

# 1. Check Fastlane installation
echo -n "1. Checking Fastlane installation... "
if command -v fastlane &> /dev/null; then
    VERSION=$(fastlane --version | head -n 1)
    echo -e "${GREEN}✓${NC} $VERSION"
else
    echo -e "${RED}✗ Fastlane not installed${NC}"
    echo "   Run: brew install fastlane"
    ((ERRORS++))
fi

# 2. Check if .env file exists
echo -n "2. Checking .env file... "
if [ -f "fastlane/.env" ]; then
    echo -e "${GREEN}✓${NC} Found"
else
    echo -e "${RED}✗ Missing${NC}"
    echo "   Run: cp fastlane/.env.sample fastlane/.env"
    echo "   Then edit fastlane/.env with your credentials"
    ((ERRORS++))
fi

# 3. Check .env contents (if exists)
if [ -f "fastlane/.env" ]; then
    echo -n "3. Checking .env configuration... "

    REQUIRED_VARS=("FASTLANE_USER" "FASTLANE_PASSWORD" "FASTLANE_ITC_TEAM_ID" "FASTLANE_TEAM_ID")
    MISSING_VARS=()

    for VAR in "${REQUIRED_VARS[@]}"; do
        if ! grep -q "^${VAR}=" fastlane/.env || grep -q "^${VAR}=.*example.com" fastlane/.env || grep -q "^${VAR}=.*123456789" fastlane/.env; then
            MISSING_VARS+=("$VAR")
        fi
    done

    if [ ${#MISSING_VARS[@]} -eq 0 ]; then
        echo -e "${GREEN}✓${NC} All required variables set"
    else
        echo -e "${YELLOW}⚠${NC} Incomplete"
        echo "   Missing or placeholder values: ${MISSING_VARS[*]}"
        ((WARNINGS++))
    fi
fi

# 4. Check Appfile
echo -n "4. Checking Appfile... "
if [ -f "fastlane/Appfile" ]; then
    if grep -q "\[\[YOUR_APPLE_ID\]\]" fastlane/Appfile || grep -q "\[\[YOUR_TEAM_ID\]\]" fastlane/Appfile; then
        echo -e "${YELLOW}⚠${NC} Contains placeholders"
        echo "   Edit fastlane/Appfile and replace [[YOUR_APPLE_ID]] and [[YOUR_TEAM_ID]]"
        ((WARNINGS++))
    else
        echo -e "${GREEN}✓${NC} Configured"
    fi
else
    echo -e "${RED}✗ Missing${NC}"
    ((ERRORS++))
fi

# 5. Check Fastfile
echo -n "5. Checking Fastfile... "
if [ -f "fastlane/Fastfile" ]; then
    echo -e "${GREEN}✓${NC} Found"
else
    echo -e "${RED}✗ Missing${NC}"
    ((ERRORS++))
fi

# 6. Check Xcode project
echo -n "6. Checking Xcode project... "
if [ -f "Runner.xcodeproj/project.pbxproj" ]; then
    echo -e "${GREEN}✓${NC} Found"
else
    echo -e "${RED}✗ Missing${NC}"
    ((ERRORS++))
fi

# 7. Check git status
echo -n "7. Checking git repository... "
if git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Git repository detected"
else
    echo -e "${YELLOW}⚠${NC} Not a git repository"
    ((WARNINGS++))
fi

# 8. Check bundle identifier
echo -n "8. Checking bundle identifier... "
BUNDLE_ID=$(grep -m 1 "PRODUCT_BUNDLE_IDENTIFIER" Runner.xcodeproj/project.pbxproj | sed 's/.*= \(.*\);/\1/' | tr -d ' ')
if [ "$BUNDLE_ID" == "com.elev8tion.everydaychristian" ]; then
    echo -e "${GREEN}✓${NC} $BUNDLE_ID"
else
    echo -e "${YELLOW}⚠${NC} $BUNDLE_ID (expected: com.elev8tion.everydaychristian)"
    ((WARNINGS++))
fi

# 9. Check code signing
echo -n "9. Checking code signing certificates... "
CERT_COUNT=$(security find-identity -v -p codesigning | grep -c "Apple Development\|Apple Distribution" || true)
if [ "$CERT_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✓${NC} $CERT_COUNT certificate(s) found"
else
    echo -e "${YELLOW}⚠${NC} No certificates found"
    echo "   Download from: Xcode → Settings → Accounts → Download Manual Profiles"
    ((WARNINGS++))
fi

# 10. Check .gitignore
echo -n "10. Checking .gitignore... "
if grep -q "fastlane/.env" .gitignore; then
    echo -e "${GREEN}✓${NC} .env is gitignored"
else
    echo -e "${RED}✗ .env is NOT gitignored (SECURITY RISK!)${NC}"
    echo "   Add to .gitignore: fastlane/.env"
    ((ERRORS++))
fi

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}🎉 Setup Complete!${NC}"
    echo ""
    echo "You're ready to deploy:"
    echo "  • TestFlight: cd ios && fastlane beta"
    echo "  • App Store:  cd ios && fastlane release"
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠ Setup Mostly Complete${NC}"
    echo ""
    echo "Found $WARNINGS warning(s). Please review above."
    echo "You can still deploy, but some features may not work."
else
    echo -e "${RED}❌ Setup Incomplete${NC}"
    echo ""
    echo "Found $ERRORS error(s) and $WARNINGS warning(s)."
    echo "Please fix the errors before deploying."
    echo ""
    echo "📖 See: ios/fastlane/QUICKSTART.md for setup instructions"
    exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

exit 0
