# BRIEFING_PDS — Screen Architecture

**Screen:** `scr_Briefing_PDS`  
**Capability:** `BRF-C01 — Premium shell and visual states`  
**Status:** FROZEN FOR BRF-C01

## 1. User task

The Handover Manager must be able to look at a completed Punch Review session and understand, at a glance, what happened, what changed, what needs attention, what actions were identified, and whether the generated interpretation is safe to approve.

BRF-C01 validates this workflow visually with synthetic data only.

## 2. Dominant archetype

```text
PRIMARY_ARCHETYPE: Object 360
PRIMARY_OBJECT: Review Session
```

Secondary patterns:

```text
KPI Strip
Contextual Tabs
Audit Timeline
Evidence Drawer
Activity Stream
Inline Review
State Surface
```

## 3. Frozen information hierarchy

```text
scr_Briefing_PDS
└── conBRF_ScreenRoot                          Horizontal AutoLayout
    ├── cmpBRF_Sidebar                         cmp_SidebarNav
    └── conBRF_ContentShell                    Vertical AutoLayout
        ├── conBRF_Header                      Premium native header
        │   ├── conBRF_HeaderTop
        │   │   ├── conBRF_Identity
        │   │   └── conBRF_TestControls
        │   └── conBRF_ContextRow
        │       ├── conBRF_ProjectContext
        │       ├── conBRF_SessionContext
        │       ├── conBRF_DateContext
        │       ├── conBRF_StatusContext
        │       ├── btnBRF_Refresh
        │       └── btnBRF_PrimaryAction
        ├── conBRF_KpiStrip
        │   ├── conBRF_KpiReviewed
        │   ├── conBRF_KpiChanged
        │   ├── conBRF_KpiComments
        │   ├── conBRF_KpiActions
        │   └── conBRF_KpiBlockers
        ├── conBRF_TabBar
        │   ├── btnBRF_TabBriefing
        │   ├── btnBRF_TabMeetingNotes
        │   └── btnBRF_TabEmail
        └── conBRF_BodyHost
            ├── conBRF_State_NoSession
            ├── conBRF_State_Ready
            ├── conBRF_State_Generating
            ├── conBRF_State_Error
            └── conBRF_Workspace
                ├── conBRF_MainColumn
                │   ├── conBRF_BriefingTab
                │   │   ├── conBRF_SummaryQualityRow
                │   │   │   ├── conBRF_ExecutiveSummary
                │   │   │   └── conBRF_ReviewQuality
                │   │   ├── conBRF_InsightRow
                │   │   │   ├── conBRF_KeyDecisions
                │   │   │   ├── conBRF_ProgressChanges
                │   │   │   └── conBRF_Blockers
                │   │   ├── conBRF_OpenItems
                │   │   └── conBRF_ActionRegister
                │   ├── conBRF_MeetingNotesTab
                │   └── conBRF_EmailTab
                └── conBRF_RightRail
                    ├── conBRF_Lifecycle
                    └── conBRF_SourceActivity
        └── conBRF_EvidenceOverlay             Floating drawer layer
            └── conBRF_EvidenceDrawer
```

## 4. State model

### Blocking/standalone states

These replace the workspace body entirely:

```text
NO_SESSION
READY
GENERATING
ERROR
```

### Workspace states

These keep the full object-360 workspace visible and alter banner/status/action semantics:

```text
DRAFT
NEEDS_REVIEW
APPROVED
STALE
SENT
```

Mutual exclusivity is controlled by `varBRF_TestState`.

## 5. Tab model

```text
BRIEFING
MEETING_NOTES
EMAIL
```

`varBRF_ActiveTab` owns the local selection.

Behavioral contract in BRF-C01:

- Briefing is always viewable in workspace states.
- Meeting Notes clearly indicates that it derives from an approved Briefing.
- Email clearly indicates that it derives from an approved Briefing.
- Send is enabled visually only in `APPROVED`.
- `STALE` explicitly disables the send path and promotes source refresh.
- `SENT` represents an archived/sent visual snapshot only.

No real document generation or email operation occurs.

## 6. Main surfaces

### Executive Summary

Dominant narrative surface. Shows synthetic meeting interpretation, source count and evidence affordance.

### Review Quality

Quality-control surface. It must answer: “Can I trust and approve this briefing?”

Synthetic checks:

```text
8 items need review
2 actions missing owner
1 action missing due date
0 unsupported statements
84/84 source events processed
```

### Key Decisions

Compact decision cards with evidence affordance and local visual actions such as Accept/Edit/Exclude. These actions do not persist anything in BRF-C01.

### Progress & Changes

Operational grouping by discipline:

```text
Mechanical  18 reviewed · 7 updated · 3 status changes
Piping      27 reviewed · 8 updated · 9 status changes
Electrical  18 reviewed · 6 updated · 2 status changes
```

### Blockers & Risks

Only genuine constraints receive warning/danger semantics. Open work is not automatically classified as risk.

### Open Items

Neutral outstanding work categories. This separates “still open” from “blocked”.

### Action Register

Native synthetic table with:

```text
Action
Owner
Due date
Source punches
Status
```

Missing information is explicit:

```text
Owner missing
Due date missing
```

The visual contract must never fabricate certainty.

### Source Activity

Compact audit timeline showing timestamp, event type and source Punch reference.

### Evidence Drawer

Floating native panel opened from evidence links. Shows the selected claim, source Punch IDs and event summaries. It is visual-only in BRF-C01.

## 7. Responsive strategy

### Wide desktop

```text
Sidebar 154
Content shell fills remaining width
Workspace: main column + right rail (~300)
Summary/Quality in one row
Decisions/Progress/Blockers in one row
```

### Medium width

- workspace may stack right rail below main content;
- insight row may remain horizontal while allowing bounded overflow where necessary;
- header context row may scroll horizontally rather than collapse labels into unreadable widths.

### Narrow width

- main workspace stacks vertically;
- KPI strip allows horizontal overflow rather than compressing values below legibility;
- Evidence Drawer becomes a wide bounded overlay but remains inside screen bounds.

BRF-C01 does not target phone UX; the goal is robust enterprise desktop/tablet degradation.

## 8. Visual rules

- One primary action per local context.
- Normal surfaces: white, 1 px border, radius 12, no shadow.
- Floating Evidence Drawer may use a semilight shadow.
- Interaction blue is `#1677FF`; PULSE cyan is brand accent only.
- Warning/danger colors are semantic, not decorative.
- Static ModernText uses `AutoHeight=true`.
- No text below PDS size 8.
- No arbitrary new radii.
- No custom components added for BRF-C01.

## 9. Capability boundaries

BRF-C01 ends after Studio accepts and visually validates the synthetic workspace.

Explicitly deferred:

```text
BRF-C02 Review Session persistence
BRF-C03 Session Delta and evidence contract
BRF-C04 real briefing generation/review
BRF-C05 Action Register persistence
BRF-C06 Meeting Notes generation
BRF-C07 Outlook distribution/archive
BRF-C08 Carry Forward
```

## 10. Acceptance gate

The architecture remains frozen until a Studio screenshot and interaction pass confirm:

- proportions and hierarchy;
- all nine state surfaces;
- all three tabs;
- KPI density;
- Action Register density;
- Source Activity legibility;
- Evidence Drawer open/close behavior;
- no unintended static-text scrollbars;
- sidebar hydration or localized manual correction;
- no new App Checker error attributable to the screen.

Only after this visual gate may the architecture be promoted as the baseline for BRF-C02.