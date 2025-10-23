# OpenSpec Agent Instructions

This file provides workflow instructions for AI coding assistants working on this project.

## Workflow

When working on this project, follow this spec-driven development process:

### 1. Draft Change Proposal
When starting new work:
- Create a proposal in `openspec/changes/[feature-name]/PROPOSAL.md`
- Document the problem, solution, and implementation plan
- Include affected files and specific changes
- Get human approval before coding

### 2. Implementation
After proposal approval:
- Reference the proposal in commit messages
- Implement changes incrementally
- Update the proposal with progress notes
- Document any deviations from the original plan

### 3. Archive and Update Specs
After implementation:
- Move completed proposal to `openspec/changes/[feature-name]/IMPLEMENTED.md`
- Update relevant specs in `openspec/specs/`
- Document lessons learned

## Change Proposal Format

```markdown
# [Feature Name] - Change Proposal

**Status:** Draft | In Review | Approved | Implemented
**Priority:** P0 (Critical) | P1 (High) | P2 (Medium) | P3 (Low)

## Problem Statement
[What problem are we solving?]

## Proposed Solution
[How will we solve it?]

## Implementation Plan

### Phase 1: [Phase Name]
**Objective:** [What this phase achieves]

**Tasks:**
- [ ] Task 1.1: [Description]
  - File: `path/to/file.dart`
  - Changes: [Specific changes]
- [ ] Task 1.2: [Description]

### Phase 2: [Phase Name]
[Continue...]

## Affected Files
- `file1.dart` - [What changes]
- `file2.dart` - [What changes]

## Testing Plan
- [ ] Test case 1
- [ ] Test case 2

## Risks & Considerations
[Potential issues and how to mitigate them]
```

## Current Specs

Active specifications are stored in `openspec/specs/`:
- `subscription-model.md` - Subscription and trial business logic
- `data-persistence.md` - Local data storage patterns
- `paywall-flows.md` - User-facing subscription interactions

## Project Guidelines

### Code Style
- Follow Flutter/Dart conventions
- Use Riverpod for state management
- Maintain glass-morphic design system
- Keep line-by-line code references

### Privacy & Compliance
- All data stored locally (SharedPreferences, SQLite)
- No personal data collection beyond Apple/Google receipts
- FTC-compliant subscription disclosures

### Testing Requirements
- Comprehensive test coverage for subscription logic
- Test trial abuse prevention
- Test offline/online state transitions
- Test data deletion and restoration flows
