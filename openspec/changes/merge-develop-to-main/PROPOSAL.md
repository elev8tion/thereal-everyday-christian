# Merge Develop to Main - Release v1.1.0 Proposal

**Status:** Draft - Awaiting Approval
**Priority:** P1 (High - Production Deployment)
**Created:** 2025-01-19
**Target Release:** v1.1.0
**Author:** Senior Developer

---

## Executive Summary

This proposal outlines the merge of 45 commits from `develop` to `main` branch, representing a major release with:

- **6 critical business logic vulnerabilities fixed** (subscription system)
- **App Store legal compliance** (Terms of Service, Privacy Policy, AI chat export)
- **FTC compliance** (regional pricing disclaimers)
- **Privacy-first onboarding** (optional name collection)
- **Major UX improvements** (rebranding, styling consistency)

**Change Scope:**
- 84 files changed
- 50,398 insertions
- 1,494 deletions
- 45 commits (6+ weeks of development)

---

## Problem Statement

The current `main` branch lacks:

1. **Critical Subscription Fixes**: Trial reset abuse, lost subscriptions after data deletion, no expiry tracking
2. **Legal Compliance**: No in-app Terms of Service, Privacy Policy, or AI chat export
3. **FTC Compliance**: Missing regional pricing disclaimers
4. **Onboarding Flow**: Direct jump to home screen without name collection option
5. **UX Consistency**: Inconsistent dialog styling, outdated branding

**Business Impact:**
- Revenue loss from trial gaming
- App Store rejection risk (legal compliance)
- FTC penalty risk (pricing transparency)
- Poor first-run user experience

---

## Commits to Merge (45 Total)

### Category 1: Crisis Detection & Content Filtering (7 commits)

1. `6574b24f` Wire up crisis detection in AI chat
2. `24702f85` Fix crisis detection to be less aggressive
3. `190ff1c0` Add comprehensive crisis detection integration tests
4. `42e12ed0` Expand crisis detection with indirect language patterns
5. `0d6e0519` 🧪 Add debug mode bypass for unlimited testing
6. `d78c6da7` ✅ Connect content filtering to AI chat
7. `4603b443` 🛡️ Wire ContentFilterService into AI response pipeline

### Category 2: Legal & Privacy Documentation (7 commits)

8. `9739fc09` 📝 Document environment variable setup comprehensively
9. `5aa6c0c4` 📄 Update privacy policies to match implementation reality
10. `9b571e40` 📜 Create comprehensive Terms of Service document
11. `3ec5bd59` 📜 Remove unimplemented 3-strike enforcement from TOS
12. `383e3ef9` 📄 Implement in-app Privacy Policy and Terms of Service display
13. `62c51cf8` 🔒 Replace legal document summaries with full verbatim text for App Store compliance
14. `adec8d12` 📄 Rewrite legal documents in professional plain text format

### Category 3: Notifications System (2 commits)

15. `4d8b8cb3` 📱 Design comprehensive notification system UX
16. `c5820ca6` 🔔 Fix iOS notification permissions and add test functionality

### Category 4: User Profile & Data Management (8 commits)

17. `64b45db5` 🚀 Production readiness: Remove debug code and fix static analysis
18. `1017b149` ✨ Add user profile picture functionality
19. `d2eb4519` 🔒 Make Bible Version read-only in settings
20. `c3d5a4e4` ✨ Update profile screen avatar to match app-wide styling
21. `6b023a78` ✅ Add comprehensive tests for Data & Privacy settings
22. `b0cd9ce0` 🗑️ Add Delete All Data feature with strong safety warnings
23. `ef95a8b8` 📊 Connect profile screen to real devotional streak & stats tracking
24. `1152d9c2` ✅ Add comprehensive tests for profile screen real data integration

### Category 5: UX Consistency & Styling (7 commits)

25. `70aab9eb` 🔧 Fix commented-out database initialization in services
26. `6bd98390` 💎 Unify dialog styling with FrostedGlassCard design system
27. `c13760af` 🚨 Apply FrostedGlassCard styling to crisis dialog
28. `23875be4` 🎨 Fix crisis dialog to match consistent app styling
29. `ad52720b` 🎨 Standardize all bottom sheets to consistent dark gradient style
30. `32509527` 🎨 Improve Terms Dialog UX: circular checkboxes, compact layout, better contrast
31. `cfc97eb5` 🎨 Improve Terms Dialog link contrast with black87 text

### Category 6: Infrastructure & Maintenance (4 commits)

32. `8e7d5dbb` 🗑️ Remove unused offline mode toggle from settings
33. `ba60e554` 📝 Update documentation to clarify offline-first architecture
34. `f10373bc` ✨ Add in-app update checker with upgrader package
35. `6e356ead` 🔧 Add debug mode bypass for AI Chat & fix upgrader package

### Category 7: App Store Compliance (4 commits)

36. `539fc10f` 📧 Update contact email from support@ to connect@everydaychristian.app
37. `94ac9746` ✅ Add Terms Acceptance & AI Chat Export for App Store Compliance
38. `b8e9671a` ⚖️ Add FTC-compliant regional pricing disclaimers throughout app
39. `4c128679` 🎨 Rebrand AI Guidance to Biblical Chat

### Category 8: Onboarding & Legal Agreements (3 commits)

40. `bb93a0a3` ✨ Add Legal Agreements screen with GlassButton styling
41. `f6805c0e` ✨ Implement privacy-first onboarding with optional name collection
42. `b6b2e0ff` 🔧 Fix onboarding persistence + Add subscription implementation roadmap

### Category 9: Subscription System Refactor (3 commits) - CRITICAL

43. `c9809e80` ✨ Implement comprehensive subscription system refactor (Phases 1-4)
44. `71e13cbd` ✅ Complete Task 3.2: Client-side trial cancellation detection
45. `e1c39fac` 📋 Mark OpenSpec PROPOSAL.md as complete - all tasks implemented

---

## Pre-Merge Checklist

### Code Quality

- [ ] All commits in develop have meaningful messages
- [ ] No debug code or console.log statements left in production code
- [ ] All TODOs addressed or documented for future releases
- [ ] Code follows established patterns and conventions

### Testing

- [ ] App builds successfully on iOS (`flutter build ios`)
- [ ] App builds successfully on Android (`flutter build apk`)
- [ ] All tests passing (`flutter test`)
- [ ] Static analysis passing (`flutter analyze`)
- [ ] App launches and navigates correctly in simulator
- [ ] Subscription flow tested manually
- [ ] Onboarding flow tested from fresh install
- [ ] Legal agreements acceptance tested
- [ ] AI chat with crisis detection tested
- [ ] Profile picture upload/delete tested
- [ ] Delete All Data feature tested

### Legal & Compliance

- [ ] Privacy Policy displays correctly in-app
- [ ] Terms of Service displays correctly in-app
- [ ] FTC pricing disclaimers present on all subscription screens
- [ ] AI chat export functionality working
- [ ] Contact email updated throughout app (connect@everydaychristian.app)

### Documentation

- [ ] README.md updated with new features
- [ ] CHANGELOG.md updated with v1.1.0 release notes
- [ ] OpenSpec documentation archived (subscription-refactor)
- [ ] Environment variables documented in .env.example

### Git Hygiene

- [ ] develop branch is up to date with origin/develop
- [ ] main branch is up to date with origin/main
- [ ] No merge conflicts detected
- [ ] All CI/CD checks passing on develop

### Deployment Preparation

- [ ] Version number updated in pubspec.yaml (1.1.0)
- [ ] Build number incremented
- [ ] App Store Connect metadata updated
- [ ] Google Play Console metadata updated
- [ ] Screenshots updated if UI changed significantly

---

## Merge Strategy

### Recommended Approach: Merge Commit

```bash
# Ensure branches are up to date
git checkout main
git pull origin main

git checkout develop
git pull origin develop

# Merge develop into main with merge commit
git checkout main
git merge develop --no-ff -m "Release v1.1.0: Subscription refactor, legal compliance, onboarding improvements

Merges 45 commits from develop to main:

Major Features:
- Comprehensive subscription system refactor (6 critical fixes)
- In-app Terms of Service and Privacy Policy
- FTC-compliant regional pricing disclaimers
- Privacy-first onboarding with optional name collection
- AI chat export for user data portability
- Crisis detection and content filtering
- User profile picture functionality
- Standardized UX styling (FrostedGlassCard)

Statistics:
- 84 files changed
- 50,398 insertions
- 1,494 deletions

See openspec/changes/merge-develop-to-main/ for detailed documentation.
"

# Push to origin/main
git push origin main
```

**Why --no-ff:**
- Preserves full commit history
- Creates clear release point
- Makes rollback easier if needed
- Follows semantic versioning best practices

---

## Rollback Plan

If issues are discovered after merge:

### Option 1: Revert Merge Commit (Preferred)

```bash
git checkout main
git revert -m 1 <merge-commit-hash>
git push origin main
```

### Option 2: Hard Reset (Nuclear Option)

```bash
git checkout main
git reset --hard <last-good-commit>
git push --force-with-lease origin main
```

**Note:** Option 2 should only be used if no other developers have pulled the bad merge.

---

## Post-Merge Tasks

### Immediate (Within 1 Hour)

- [ ] Verify app builds successfully from main
- [ ] Run full test suite on main branch
- [ ] Deploy to TestFlight for internal testing
- [ ] Test critical paths (subscription, onboarding, legal agreements)
- [ ] Monitor error tracking for new crashes

### Short-Term (Within 24 Hours)

- [ ] Create GitHub release v1.1.0 with release notes
- [ ] Tag commit: `git tag -a v1.1.0 -m "Release v1.1.0"`
- [ ] Push tag: `git push origin v1.1.0`
- [ ] Update project board/issue tracker
- [ ] Notify QA team for regression testing

### Medium-Term (Within 1 Week)

- [ ] Submit to App Store Review
- [ ] Submit to Google Play Review
- [ ] Prepare customer support for new features
- [ ] Update user documentation/help center
- [ ] Monitor analytics for usage patterns

---

## Risk Assessment

### Low Risk Items ✅
- Crisis detection (tested extensively)
- Content filtering (non-breaking addition)
- Profile picture (optional feature)
- Styling updates (visual only)
- Documentation updates

### Medium Risk Items ⚠️
- Subscription system refactor (thoroughly tested but complex)
- Onboarding flow changes (affects first-run experience)
- Delete All Data (safety warnings in place)

### High Risk Items ⚠️⚠️
- Legal agreements acceptance (App Store requirement)
- FTC pricing disclaimers (regulatory compliance)

**Mitigation:**
- All changes tested in develop for 6+ weeks
- Comprehensive test coverage (38+ tests for subscription alone)
- Can rollback merge if critical issues found
- Phased rollout possible via TestFlight

---

## Success Criteria

Merge is considered successful if:

1. ✅ App builds and runs without errors
2. ✅ All automated tests pass
3. ✅ Subscription flow works correctly (trial, purchase, restore)
4. ✅ Onboarding flow completes successfully
5. ✅ Legal agreements display and acceptance works
6. ✅ No critical crashes in first 24 hours
7. ✅ App Store/Play Store acceptance

---

## Stakeholder Approval

**Required Approvals:**

- [ ] Technical Lead / Senior Developer (Code Quality)
- [ ] Product Owner (Feature Completeness)
- [ ] QA Lead (Testing Coverage)
- [ ] Legal/Compliance (if applicable)

**Approval Comments:**

_Space for stakeholders to add approval signatures and comments_

---

## Timeline

**Proposed Schedule:**

1. **Day 1 (Today)**: Pre-merge checklist execution
2. **Day 2**: Merge to main, deploy to TestFlight
3. **Day 3-4**: Internal QA and regression testing
4. **Day 5-6**: Fix any critical issues found in testing
5. **Day 7**: Submit to App Store/Play Store
6. **Day 14-21**: App review and public release

---

**Last Updated:** 2025-01-19
**Next Review:** After pre-merge checklist completion
