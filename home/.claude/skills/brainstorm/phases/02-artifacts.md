# Phase 2: Interactive Framework Generation (Artifacts)

Seven-phase interactive workflow generating confirmed guidance specification through role-based analysis and synthesis. This phase handles all user interaction for topic exploration, role selection, and decision gathering.

## Objective

- Collect project context automatically (Phase 0)
- Analyze topic and extract keywords/challenges (Phase 1)
- Select roles via intelligent recommendation + user confirmation (Phase 2)
- Generate deep role-specific questions (Phase 3)
- Resolve cross-role conflicts (Phase 4)
- Final clarification and feature decomposition (Phase 4.5)
- Generate declarative guidance-specification.md (Phase 5)

## Auto Mode

When `--yes` or `-y`: Auto-select recommended roles, skip all clarification questions, use default answers.

## TodoWrite Integration

**TodoWrite Rule**: EXTEND auto-parallel's task list (NOT replace/overwrite)

**When called from auto mode**:
- Find artifacts parent task → Mark "in_progress"
- APPEND sub-tasks (Phase 0-5) → Mark each as completes
- When Phase 5 completes → Mark parent "completed"
- PRESERVE all other auto-parallel tasks

**Standalone Mode**:
```json
[
  {"content": "Initialize session", "status": "pending", "activeForm": "Initializing"},
  {"content": "Phase 0: Context collection", "status": "pending", "activeForm": "Phase 0"},
  {"content": "Phase 1: Topic analysis (2-4 questions)", "status": "pending", "activeForm": "Phase 1"},
  {"content": "Phase 2: Role selection", "status": "pending", "activeForm": "Phase 2"},
  {"content": "Phase 3: Role questions (per role)", "status": "pending", "activeForm": "Phase 3"},
  {"content": "Phase 4: Conflict resolution", "status": "pending", "activeForm": "Phase 4"},
  {"content": "Phase 4.5: Final clarification + Feature decomposition", "status": "pending", "activeForm": "Phase 4.5"},
  {"content": "Phase 5: Generate specification", "status": "pending", "activeForm": "Phase 5"}
]
```

## Execution

### Session Management

- Check `.workflow/active/` for existing sessions
- Multiple → Prompt selection | Single → Use it | None → Create `WFS-[topic-slug]`
- Parse `--count N` parameter (default: 3)
- Store decisions in `workflow-session.json`

### Phase 0: Context Collection

**Goal**: Gather project context BEFORE user interaction

**Steps**:
1. Check if `context-package.json` exists → Skip if valid
2. Invoke `context-search-agent` (BRAINSTORM MODE - lightweight)
3. Output: `.workflow/active/WFS-{session-id}/.process/context-package.json`

**Graceful Degradation**: If agent fails, continue to Phase 1 without context

```javascript
Task(
  subagent_type="context-search-agent",
  run_in_background=false,
  description="Gather project context for brainstorm",
  prompt=`
Execute context-search-agent in BRAINSTORM MODE (Phase 1-2 only).

Session: ${session_id}
Task: ${task_description}
Output: .workflow/${session_id}/.process/context-package.json

Required fields: metadata, project_context, assets, dependencies, conflict_detection
`
)
```

### Phase 1: Topic Analysis

**Goal**: Extract keywords/challenges enriched by Phase 0 context

**Steps**:
1. Load Phase 0 context (tech_stack, modules, conflict_risk)
2. Deep topic analysis (entities, challenges, constraints, metrics)
3. Generate 2-4 context-aware probing questions
4. AskUserQuestion → Store to `session.intent_context`

**Example**:
```javascript
AskUserQuestion({
  questions: [
    {
      question: "What are the main technical challenges for real-time collaboration?",
      header: "Core Challenges",
      multiSelect: false,
      options: [
        { label: "Real-time Data Sync", description: "100+ concurrent users, high state sync complexity" },
        { label: "Scalable Architecture", description: "System scaling as user base grows" },
        { label: "Conflict Resolution", description: "Conflict handling for concurrent multi-user editing" }
      ]
    },
    {
      question: "Most important metric for MVP phase?",
      header: "Priorities",
      multiSelect: false,
      options: [
        { label: "Feature Completeness", description: "Implement all core features" },
        { label: "User Experience", description: "Smooth interaction and fast response times" },
        { label: "System Stability", description: "High availability and data consistency" }
      ]
    }
  ]
})
```

**⚠️ CRITICAL**: Questions MUST reference topic keywords. Generic "Project type?" violates dynamic generation.

### Phase 1.5: Terminology & Boundary Definition

**Goal**: Extract core terminology and define scope boundaries (Non-Goals)

**Steps**:
1. Analyze Phase 1 user responses and topic description
2. Extract 5-10 core domain terms that will be used throughout the specification
3. Generate terminology clarification questions if needed
4. Define scope boundaries by identifying what is explicitly OUT of scope

**Terminology Extraction**:
```javascript
// Based on Phase 1 context and user input
const coreTerms = extractTerminology({
  topic: session.topic,
  userResponses: session.intent_context,
  contextPackage: contextPackage // from Phase 0
});

// Generate terminology table
const terminologyTable = coreTerms.map(term => ({
  term: term.canonical,
  definition: term.definition,
  aliases: term.alternatives,
  category: term.category // core|technical|business
}));
```

**Non-Goals Definition**:
```javascript
AskUserQuestion({
  questions: [{
    question: "Which of the following are explicitly NOT in scope for this project? (Select all that apply)",
    header: "Scope Boundaries (Non-Goals)",
    multiSelect: true,
    options: [
      { label: "Mobile Application", description: "Web only for now, mobile considered later" },
      { label: "Multi-language Support", description: "MVP phase supports only one language" },
      { label: "Third-party Integrations", description: "No external system integration at this stage" },
      { label: "Advanced Analytics", description: "Core features first, analytics in v2" },
      { label: "Other (specify later)", description: "User-defined exclusions" }
    ]
  }]
});

// If user selects "Other", follow up with:
if (selectedNonGoals.includes("Other")) {
  AskUserQuestion({
    questions: [{
      question: "Describe other explicitly excluded features or scope",
      header: "Additional Non-Goals",
      multiSelect: false,
      freeText: true
    }]
  });
}

// Store to session
session.terminology = terminologyTable;
session.non_goals = selectedNonGoals.map(ng => ({
  item: ng.label,
  rationale: ng.description
}));
```

**Output**: Updated `workflow-session.json` with `terminology` and `non_goals` fields

### Phase 2: Role Selection

**Goal**: User selects roles from intelligent recommendations

**Available Roles**: data-architect, product-manager, product-owner, scrum-master, subject-matter-expert, system-architect, test-strategist, ui-designer, ux-expert

**Steps**:
1. Analyze Phase 1 keywords → Recommend count+2 roles with rationale
2. AskUserQuestion (multiSelect=true) → Store to `session.selected_roles`
3. If count+2 > 4, split into multiple rounds

**Example**:
```javascript
AskUserQuestion({
  questions: [{
    question: "Select 3 roles for brainstorm analysis",
    header: "Role Selection",
    multiSelect: true,
    options: [
      { label: "system-architect", description: "Real-time sync architecture design and technology selection" },
      { label: "ui-designer", description: "Collaborative interface UX and state display" },
      { label: "product-manager", description: "Feature prioritization and MVP scope decisions" },
      { label: "data-architect", description: "Data sync model and storage design" }
    ]
  }]
})
```

**⚠️ CRITICAL**: User MUST interact. NEVER auto-select without confirmation (unless --yes flag).

### Phase 3: Role-Specific Questions

**Goal**: Generate deep questions mapping role expertise to Phase 1 challenges

**Algorithm**:
1. FOR each selected role:
   - Map Phase 1 challenges to role domain
   - Generate 3-4 questions (implementation depth, trade-offs, edge cases)
   - AskUserQuestion per role → Store to `session.role_decisions[role]`
2. Process roles sequentially (one at a time for clarity)
3. If role needs > 4 questions, split into multiple rounds

**Example** (system-architect):
```javascript
AskUserQuestion({
  questions: [
    {
      question: "Real-time state sync solution for 100+ users?",
      header: "State Sync",
      multiSelect: false,
      options: [
        { label: "Event Sourcing", description: "Full event history, supports replay, high storage cost" },
        { label: "Centralized State Management", description: "Simple to implement, single-point bottleneck risk" },
        { label: "CRDT", description: "Decentralized, auto-merge, steep learning curve" }
      ]
    },
    {
      question: "How to resolve concurrent editing conflicts between two users?",
      header: "Conflict Resolution",
      multiSelect: false,
      options: [
        { label: "Auto-merge", description: "Transparent to user, may produce unexpected results" },
        { label: "Manual Resolution", description: "User-controlled, increases interaction complexity" },
        { label: "Version Control", description: "Preserves history, requires branch management" }
      ]
    }
  ]
})
```

### Phase 4: Conflict Resolution

**Goal**: Resolve ACTUAL conflicts from Phase 3 answers

**Algorithm**:
1. Analyze Phase 3 answers for conflicts:
   - Contradictory choices (e.g., "fast iteration" vs "complex Event Sourcing")
   - Missing integration (e.g., "Optimistic updates" but no conflict handling)
   - Implicit dependencies (e.g., "Live cursors" but no auth defined)
2. Generate clarification questions referencing SPECIFIC Phase 3 choices
3. AskUserQuestion (max 4 per call, multi-round) → Store to `session.cross_role_decisions`
4. If NO conflicts: Skip Phase 4 (inform user: "No cross-role conflicts detected, skipping Phase 4")

**Example**:
```javascript
AskUserQuestion({
  questions: [{
    question: "CRDT vs UI rollback expectation conflict, how to resolve?\nContext: system-architect chose CRDT, ui-designer expects UI rollback",
    header: "Architecture Conflict",
    multiSelect: false,
    options: [
      { label: "Use CRDT", description: "Maintain decentralization, adjust UI expectations" },
      { label: "Show Merge UI", description: "Add user interaction, display conflict details" },
      { label: "Switch to OT", description: "Supports rollback, increases server complexity" }
    ]
  }]
})
```

### Phase 4.5: Final Clarification

**Purpose**: Ensure no important points missed before generating specification

**Steps**:
1. Ask initial check:
   ```javascript
   AskUserQuestion({
     questions: [{
       question: "Before generating the final spec, are there any key points from earlier that need clarification?",
       header: "Supplementary Confirmation",
       multiSelect: false,
       options: [
         { label: "No Supplements Needed", description: "Previous discussions are sufficiently complete" },
         { label: "Supplements Needed", description: "There are important points that still need clarification" }
       ]
     }]
   })
   ```
2. If "Supplements Needed":
   - Analyze user's additional points
   - Generate progressive questions (not role-bound, interconnected)
   - AskUserQuestion (max 4 per round) → Store to `session.additional_decisions`
   - Repeat until user confirms completion
3. If "No Supplements Needed": Proceed to Feature Decomposition

**Progressive Pattern**: Questions interconnected, each round informs next, continue until resolved.

#### Feature Decomposition

After final clarification, extract implementable feature units from all Phase 1-4 decisions.

**Steps**:
1. Analyze all accumulated decisions (`intent_context` + `role_decisions` + `cross_role_decisions` + `additional_decisions`)
2. Extract candidate features: each must be an independently implementable unit with clear boundaries
3. Generate candidate list (max 8 features) with structured format:
   - Feature ID: `F-{3-digit}` (e.g., F-001)
   - Name: kebab-case slug (e.g., `real-time-sync`, `user-auth`)
   - Description: one-sentence summary of the feature's scope
   - Related roles: which roles' decisions drive this feature
   - Priority: High / Medium / Low
4. Present candidate list to user for confirmation:
   ```javascript
   AskUserQuestion({
     questions: [{
       question: "Here is the feature list extracted from the discussion:\n\nF-001: [name] - [description]\nF-002: [name] - [description]\n...\n\nDo you need to make adjustments?",
       header: "Feature Confirmation",
       multiSelect: false,
       options: [
         { label: "Confirmed", description: "Feature list is complete and reasonable, proceed with spec generation" },
         { label: "Adjustments Needed", description: "Need to add, remove, or modify features" }
       ]
     }]
   })
   ```
5. If "Adjustments Needed": Collect adjustments and re-present until user confirms
6. Store confirmed list to `session.feature_list`

**Constraints**:
- Maximum 8 features (if more candidates, merge related items)
- Each feature MUST be independently implementable (no implicit cross-feature dependencies)
- Feature ID format: `F-{3-digit}` (F-001, F-002, ...)
- Feature slug: kebab-case, descriptive of the feature scope

**Granularity Guidelines** (Used to validate feature granularity):

| Signal | Too Coarse | Just Right | Too Fine |
|--------|-----------|------------|----------|
| Implementation Scope | Requires 5+ independent modules coordinating | 1-3 modules with clear boundaries | Single function or single API endpoint |
| Role Involvement | All roles deeply involved | 2-4 roles make substantive contributions | Only 1 role concerned |
| Testability | Cannot write clear acceptance criteria | Can define 3-5 measurable acceptance criteria | Acceptance criteria equivalent to unit tests |
| Dependencies | Circular dependencies with other features | One-way, identifiable dependencies | No external dependencies (may be an omission) |

**Quality Validation** (Validate each candidate feature after Step 3 extraction):
1. **Independence Check**: Can this feature be delivered independently without other features? If no → consider merging or re-partitioning
2. **Completeness Check**: Does this feature cover a complete user-perceivable value? If no → may be too fine-grained, consider merging
3. **Granularity Balance Check**: Is complexity roughly balanced across features (max no more than 3x min)? If no → split oversized or merge undersized
4. **Boundary Clarity Check**: Can you describe the feature's input and output in one sentence? If no → boundaries are unclear, needs redefinition

**Handling Vague Requirements** (Extra steps when requirements are vague):
- If Phase 1-4 decisions are insufficient to support feature decomposition (e.g., missing concrete business scenarios, technology choices undecided), proactively inform the user which features may have imprecise granularity during Step 4 confirmation
- Mark uncertain features as `Priority: TBD`，clarified further through cross-role analysis in the synthesis phase
- If candidate features ≤ 2, requirements may be too abstract → prompt user to add more concrete scenarios before decomposition

### Phase 5: Generate Specification

**Steps**:
1. Load all decisions: `intent_context` + `selected_roles` + `role_decisions` + `cross_role_decisions` + `additional_decisions` + `feature_list` + `terminology` + `non_goals`
2. Transform Q&A to declarative: Questions → Headers, Answers → CONFIRMED/SELECTED statements
3. Apply RFC 2119 keywords (MUST, SHOULD, MAY, MUST NOT, SHOULD NOT) to all behavioral requirements
4. Generate `guidance-specification.md` with Concepts & Terminology and Non-Goals sections
5. Update `workflow-session.json` (metadata only)
6. Validate: No interrogative sentences, all decisions traceable, RFC keywords applied

**RFC 2119 Compliance**:

All behavioral requirements and constraints MUST be expressed using RFC 2119 keywords:
- **MUST**: Absolute requirement, non-negotiable
- **MUST NOT**: Absolute prohibition
- **SHOULD**: Strong recommendation, may be ignored with valid reason
- **SHOULD NOT**: Strong discouragement
- **MAY**: Optional, implementer's choice

Example transformations:
- "Users need to log in" → "The system MUST authenticate users before granting access"
- "Consider using caching" → "The system SHOULD cache frequently accessed data"
- "Can support OAuth" → "The system MAY support OAuth2 authentication"

## Question Guidelines

### Core Principle

**Target**: Developer (understands technology but needs to start from user needs)

**Question Structure**: `[Business scenario/requirement context] + [Technical concern]`
**Option Structure**: `Label: [Technical solution] + Description: [Business impact] + [Technical trade-off]`

### Quality Rules

**MUST Include**:
- ✅ All questions in the user's language
- ✅ Business scenarios as question context
- ✅ Business impact explanation for technical options
- ✅ Quantified metrics and constraints

**MUST Avoid**:
- ❌ Pure technology selection without business context
- ❌ Overly abstract UX questions
- ❌ Generic architecture questions unrelated to the topic

### Phase-Specific Requirements

| Phase | Focus | Key Requirements |
|-------|-------|------------------|
| 1 | Intent Understanding | Reference topic keywords, User scenarios, business constraints, priorities |
| 2 | Role Recommendation | Intelligent analysis (NOT keyword mapping), explain relevance |
| 3 | Role Questions | Reference Phase 1 keywords, concrete options with trade-offs |
| 4 | Conflict Resolution | Reference SPECIFIC Phase 3 choices, explain impact on both roles |

### Multi-Round Execution Pattern

```javascript
const BATCH_SIZE = 4;
for (let i = 0; i < allQuestions.length; i += BATCH_SIZE) {
  const batch = allQuestions.slice(i, i + BATCH_SIZE);
  AskUserQuestion({ questions: batch });
  // Store responses before next round
}
```

## Output

### Generated Files

**File**: `.workflow/active/WFS-{topic}/.brainstorming/guidance-specification.md`

```markdown
# [Project] - Confirmed Guidance Specification

**Metadata**: [timestamp, type, focus, roles]

## 1. Project Positioning & Goals
**CONFIRMED Objectives**: [from topic + Phase 1]
**CONFIRMED Success Criteria**: [from Phase 1 answers]

## 2. Concepts & Terminology

**Core Terms**: The following terms are used consistently throughout this specification.

| Term | Definition | Aliases | Category |
|------|------------|---------|----------|
${session.terminology.map(t => `| ${t.term} | ${t.definition} | ${t.aliases.join(', ')} | ${t.category} |`).join('\n')}

**Usage Rules**:
- All documents MUST use the canonical term
- Aliases are for reference only
- New terms introduced in role analysis MUST be added to this glossary

## 3. Non-Goals (Out of Scope)

The following are explicitly OUT of scope for this project:

${session.non_goals.map(ng => `- **${ng.item}**: ${ng.rationale}`).join('\n')}

**Rationale**: These exclusions help maintain focus on core objectives and prevent scope creep.

## 4-N. [Role] Decisions
### SELECTED Choices
**[Question topic]**: [User's answer with RFC 2119 keywords]
- **Rationale**: [From option description]
- **Impact**: [Implications with RFC keywords]
- **Requirement Level**: [MUST/SHOULD/MAY based on criticality]

**Example**:
- The system MUST authenticate users within 200ms (P99)
- The system SHOULD cache frequently accessed data
- The system MAY support OAuth2 providers (Google, GitHub)

### Cross-Role Considerations
**[Conflict resolved]**: [Resolution from Phase 4 with RFC keywords]
- **Affected Roles**: [Roles involved]
- **Decision**: [MUST/SHOULD/MAY statement]

## Cross-Role Integration
**CONFIRMED Integration Points**: [API/Data/Auth from multiple roles]

## Risks & Constraints
**Identified Risks**: [From answers] → Mitigation: [Approach]

## Next Steps
**⚠️ Automatic Continuation** (when called from auto mode):
- Auto mode assigns agents for role-specific analysis
- Each selected role gets conceptual-planning-agent
- Agents read this guidance-specification.md for context

## Feature Decomposition

**Constraints**: Max 8 features | Each independently implementable | ID format: F-{3-digit}

| Feature ID | Name | Description | Related Roles | Priority |
|------------|------|-------------|---------------|----------|
| F-001 | [kebab-case-slug] | [One-sentence scope] | [role1, role2] | High/Medium/Low |
| F-002 | [kebab-case-slug] | [One-sentence scope] | [role1] | High/Medium/Low |

## Appendix: Decision Tracking
| Decision ID | Category | Question | Selected | Phase | Rationale |
|-------------|----------|----------|----------|-------|-----------|
| D-001 | Intent | [Q] | [A] | 1 | [Why] |
| D-002 | Roles | [Selected] | [Roles] | 2 | [Why] |
| D-003+ | [Role] | [Q] | [A] | 3 | [Why] |
```

### Session Metadata

```json
{
  "session_id": "WFS-{topic-slug}",
  "type": "brainstorming",
  "topic": "{original user input}",
  "selected_roles": ["system-architect", "ui-designer", "product-manager"],
  "phase_completed": "artifacts",
  "timestamp": "2025-10-24T10:30:00Z",
  "count_parameter": 3,
  "style_skill_package": null
}
```

**⚠️ Rule**: Session JSON stores ONLY metadata. All guidance content goes to guidance-specification.md.

### Validation Checklist

- ✅ No interrogative sentences (use CONFIRMED/SELECTED)
- ✅ Every decision traceable to user answer
- ✅ Cross-role conflicts resolved or documented
- ✅ Next steps concrete and specific
- ✅ No content duplication between .json and .md
- ✅ Feature Decomposition table present with validated entries

### Governance Rules

- All decisions MUST use CONFIRMED/SELECTED (NO "?" in decision sections)
- Every decision MUST trace to user answer
- Conflicts MUST be resolved (not marked "TBD")
- Next steps MUST be actionable
- Topic preserved as authoritative reference

**CRITICAL**: Guidance is single source of truth for downstream phases. Ambiguity violates governance.

### Update Mechanism

```
IF guidance-specification.md EXISTS:
  Prompt: "Regenerate completely / Update sections / Cancel"
ELSE:
  Run full Phase 0-5 flow
```

- **TodoWrite**: Mark Phase 2 completed, collapse sub-tasks to summary

## Next Phase

Return to orchestrator, then auto-continue to [Phase 3: Role Analysis](03-role-analysis.md) (auto mode: parallel execution for all selected roles).
