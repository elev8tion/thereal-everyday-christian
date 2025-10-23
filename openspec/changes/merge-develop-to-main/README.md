# Merge Develop to Main - Release v1.1.0

**Type:** Release
**Priority:** P1 (High - Production Deployment)
**Created:** 2025-01-19
**Status:** Proposed

---

## Overview

This change merges 45 commits from `develop` branch into `main` branch, representing a major release with critical business logic, legal compliance, and UX improvements.

## Change Summary

**Statistics:**
- **Commits:** 45
- **Files Changed:** 84
- **Insertions:** 50,398 lines
- **Deletions:** 1,494 lines

## Major Features

### 1. Subscription System Refactor (P0)
Complete rewrite of subscription logic with trial management, auto-subscribe, and receipt validation.

### 2. Legal Compliance (P0)
- In-app Terms of Service and Privacy Policy
- FTC-compliant pricing disclaimers
- AI chat export for user data portability
- Legal agreements acceptance flow

### 3. Privacy-First Onboarding (P0)
- Optional user name collection
- No mandatory authentication
- Improved first-run experience

### 4. UX Improvements (P1)
- Rebranded "AI Guidance" to "Biblical Chat"
- Standardized bottom sheet styling
- Improved legal document presentation
- In-app update checker

## Impact

**User-Facing:**
- Better trial management (prevents abuse)
- Improved onboarding flow
- Professional legal compliance
- Enhanced subscription UX

**Business:**
- Prevents revenue loss from trial gaming
- App Store compliance for legal requirements
- FTC compliance for pricing
- Restored subscriptions after data deletion

**Technical:**
- 6 critical subscription vulnerabilities fixed
- Comprehensive error handling
- Privacy-first architecture maintained

## Risk Assessment

**Low Risk:**
- All changes tested in develop branch
- App compiles and runs successfully
- Backward compatible (no breaking changes)
- Can rollback if needed

## Documents

- [PROPOSAL.md](./PROPOSAL.md) - Detailed merge plan and pre-merge checklist
- [PROGRESS.md](./PROGRESS.md) - Execution tracking (created during merge)

---

**See PROPOSAL.md for detailed merge plan and execution steps.**
