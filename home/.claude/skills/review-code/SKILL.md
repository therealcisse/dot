---
name: review-code
description: Multi-dimensional code review with structured reports. Analyzes correctness, readability, performance, security, testing, and architecture. Triggers on "review code" and "code review".
allowed-tools: Agent, AskUserQuestion, Read, Write, Glob, Grep, mcp__ace-tool__search_context, mcp__ide__getDiagnostics
---

# Review Code

Multi-dimensional code review skill that analyzes code across 6 key dimensions and generates structured review reports with actionable recommendations.

## Architecture Overview

```text
┌─────────────────────────────────────────────────────────────────┐
│ ⚠️ Phase 0: Specification Study (Mandatory Prerequisite)         │
│ → Read specs/review-dimensions.md                               │
│ → Understand review dimensions and issue classification standards│
└───────────────┬─────────────────────────────────────────────────┘
                ↓
┌─────────────────────────────────────────────────────────────────┐
│ Orchestrator (State-Driven Decision Making)                     │
│ → Read state → Select review action → Execute → Update state    │
└───────────────┬─────────────────────────────────────────────────┘
                │
    ┌───────────┼───────────┬───────────┬───────────┐
    ↓           ↓           ↓           ↓           ↓
┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐
│ Collect │ │ Quick   │ │ Deep    │ │ Report  │ │Complete │
│ Context │ │ Scan    │ │ Review  │ │ Generate│ │         │
└─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────┘
     ↓           ↓           ↓           ↓
┌─────────────────────────────────────────────────────────────────┐
│ Review Dimensions                                               │
│ ┌───────────┐ ┌───────────┐ ┌───────────┐ ┌──────────┐          │
│ │Correctness│ │Readability│ │Performance│ │ Security │          │
│ └───────────┘ └───────────┘ └───────────┘ └──────────┘          │
│ ┌──────────┐ ┌────────────┐                                      │
│ │ Testing │ │Architecture│                                      │
│ └──────────┘ └────────────┘                                      │
└─────────────────────────────────────────────────────────────────┘
```

**Project Context**: Run `ccw spec load --category review` for review standards, checklists, and approval gates.

## Key Design Principles

1. **Multi-dimensional review**: Covers six key dimensions: correctness, readability, performance, security, test coverage, and architectural consistency.
2. **Layered execution**: Uses quick scans to identify high-risk areas, then deep review to focus on key issues.
3. **Structured reports**: Classifies findings by severity and provides file locations and remediation recommendations.
4. **State-driven workflow**: Runs autonomously and dynamically selects the next action based on review progress.

---

## ⚠️ Mandatory Prerequisites

> **⛔ Do not skip**: Before performing any review operation, you **must** fully read the following documents.

### Specification Documents (Required Reading)

| Document | Purpose | Priority |
|----------|---------|----------|
| [specs/review-dimensions.md](specs/review-dimensions.md) | Review dimension definitions and checkpoints | **P0 - Highest** |
| [specs/issue-classification.md](specs/issue-classification.md) | Issue classification and severity standards | **P0 - Highest** |
| [specs/quality-standards.md](specs/quality-standards.md) | Review quality standards | P1 |

### Template Files (Required Before Generation)

| Document | Purpose |
|----------|---------|
| [templates/review-report.md](templates/review-report.md) | Review report template |
| [templates/issue-template.md](templates/issue-template.md) | Issue record template |

---

## Execution Flow

```text
┌─────────────────────────────────────────────────────────────────┐
│ Phase 0: Specification Study (Mandatory Prerequisite, Do Not Skip)│
│ → Read: specs/review-dimensions.md                              │
│ → Read: specs/issue-classification.md                           │
│ → Understand review standards and issue classification           │
├─────────────────────────────────────────────────────────────────┤
│ Action: collect-context                                          │
│ → Collect target files/directories                               │
│ → Identify technology stack and language                         │
│ → Output: state.context (files, language, framework)             │
├─────────────────────────────────────────────────────────────────┤
│ Action: quick-scan                                               │
│ → Quickly scan the overall structure                             │
│ → Identify high-risk areas                                       │
│ → Output: state.risk_areas, state.scan_summary                   │
├─────────────────────────────────────────────────────────────────┤
│ Action: deep-review (per dimension)                              │
│ → Perform deep review dimension by dimension                     │
│ → Record discovered issues                                       │
│ → Output: state.findings[]                                       │
├─────────────────────────────────────────────────────────────────┤
│ Action: generate-report                                          │
│ → Summarize all findings                                         │
│ → Generate structured report                                     │
│ → Output: review-report.md                                       │
├─────────────────────────────────────────────────────────────────┤
│ Action: complete                                                 │
│ → Save final state                                               │
│ → Output review summary                                          │
└─────────────────────────────────────────────────────────────────┘
```

## Directory Setup

```javascript
const timestamp = new Date().toISOString().slice(0,19).replace(/[-:T]/g, '');
const workDir = `.workflow/.scratchpad/review-code-${timestamp}`;
Write(`${workDir}/.gitkeep`, '');
Write(`${workDir}/findings/.gitkeep`, '');
```

## Output Structure

```text
.workflow/.scratchpad/review-code-{timestamp}/
├── state.json # Review state
├── context.json # Target context
├── findings/ # Findings
│   ├── correctness.json
│   ├── readability.json
│   ├── performance.json
│   ├── security.json
│   ├── testing.json
│   └── architecture.json
└── review-report.md # Final review report
```

## Review Dimensions

| Dimension | Focus Areas | Key Checks |
|-----------|-------------|------------|
| **Correctness** | Logic correctness | Boundary conditions, error handling, null checks |
| **Readability** | Code readability | Naming conventions, function length, comment quality |
| **Performance** | Performance efficiency | Algorithmic complexity, I/O optimization, resource usage |
| **Security** | Security | Injection risks, sensitive information, access control |
| **Testing** | Test coverage | Test adequacy, boundary coverage, maintainability |
| **Architecture** | Architectural consistency | Design patterns, layered structure, dependency management |

## Issue Severity Levels

| Level | Prefix | Description | Action Required |
|-------|--------|-------------|-----------------|
| **Critical** | [C] | Blocking issue that must be fixed immediately | Must fix before merge |
| **High** | [H] | Important issue that needs to be fixed | Should fix |
| **Medium** | [M] | Recommended improvement | Consider fixing |
| **Low** | [L] | Optional optimization | Nice to have |
| **Info** | [I] | Informational suggestion | For reference |

## Reference Documents

| Document | Purpose |
|----------|---------|
| [phases/orchestrator.md](phases/orchestrator.md) | Review orchestrator |
| [phases/state-schema.md](phases/state-schema.md) | State structure definition |
| [phases/actions/action-collect-context.md](phases/actions/action-collect-context.md) | Collect context |
| [phases/actions/action-quick-scan.md](phases/actions/action-quick-scan.md) | Quick scan |
| [phases/actions/action-deep-review.md](phases/actions/action-deep-review.md) | Deep review |
| [phases/actions/action-generate-report.md](phases/actions/action-generate-report.md) | Generate report |
| [phases/actions/action-complete.md](phases/actions/action-complete.md) | Complete review |
| [specs/review-dimensions.md](specs/review-dimensions.md) | Review dimension specification |
| [specs/issue-classification.md](specs/issue-classification.md) | Issue classification standards |
| [specs/quality-standards.md](specs/quality-standards.md) | Quality standards |
| [templates/review-report.md](templates/review-report.md) | Report template |
| [templates/issue-template.md](templates/issue-template.md) | Issue template |
