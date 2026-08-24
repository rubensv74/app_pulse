# BRIEFING_PDS — Construction Workspace

**Screen:** `scr_Briefing_PDS`  
**Current capability:** `BRF-C01 — Premium shell and visual states`  
**Branch:** `brf-c01-premium-shell`

## 1. Current status

```text
FOUNDATION AUDIT                         PASS
ARCHITECTURE FROZEN                      PASS
SOURCE COMPATIBILITY REVIEW              PASS
CUMULATIVE BRF-C01 SOURCE PUBLISHED      PASS
STATIC PROHIBITED-PATTERN REVIEW         PASS
POWER APPS STUDIO SOURCE ACCEPTANCE      NOT_RUN
APP CHECKER                              NOT_RUN
VISUAL QA                                NOT_RUN
BRF-C01 ACCEPTANCE                       GATED_BY_STUDIO
```

`PASS` above means repository/preflight evidence only. It does not imply Studio compilation or functional backend behavior.

## 2. Artefacts

- `BLOCK_00_FOUNDATION_AUDIT.md` — baseline, dependencies, risks and do-not-invent list.
- `SCREEN_ARCHITECTURE.md` — frozen Object 360 architecture.
- `POWER_APPS_SOURCE_CODE_COMPATIBILITY.md` — inherited and Briefing-specific Source Code rules.
- `blocks/BRF_C01_scr_Briefing_PDS.full-screen.pa.yaml` — cumulative pasteable BRF-C01 screen candidate.
- `BRF_C01_STUDIO_INTEGRATION_GUIDE.md` — Spanish Studio integration/validation guide.

## 3. Logical construction blocks inside BRF-C01

BRF-C01 is delivered as one cumulative source for a single grouped Studio gate, but its design remains separable into these responsibilities:

```text
01 Shell + PDS initialization
02 Native premium header + synthetic state selector
03 KPI strip + contextual tabs
04 Standalone visual states
05 Briefing Object-360 workspace
06 Action Register + quality + source activity
07 Meeting Notes + Email preview surfaces
08 Evidence Drawer
09 Responsive/state hardening
```

No remote service block exists in BRF-C01.

## 4. Why there is one Studio gate

The approved BRF-C01 capability contract explicitly groups the visual architecture so the user can evaluate the whole Briefing experience before backend work begins. Therefore the repository can prepare the cumulative visual package autonomously while Studio remains the first unavoidable execution gate.

The grouped gate does **not** waive evidence requirements:

- no claim of compilation before Studio;
- no claim of custom component hydration before Studio;
- no claim of visual acceptance before screenshots/interaction checks;
- no authorization for BRF-C02 until BRF-C01 is accepted.

## 5. Synthetic states

```text
NO_SESSION
READY
GENERATING
DRAFT
NEEDS_REVIEW
APPROVED
STALE
SENT
ERROR
```

Standalone body states:

```text
NO_SESSION
READY
GENERATING
ERROR
```

Full workspace states:

```text
DRAFT
NEEDS_REVIEW
APPROVED
STALE
SENT
```

## 6. Known localized risk

`cmp_SidebarNav` is required. Existing evidence shows that a Source Code-created custom component instance on a new/restarted screen may render while ignoring host input assignments.

If Studio shows literal component defaults (`Text / Text`) in the sidebar footer, this is **not** a reason to discard the screen. Follow the manual sidebar hydration correction in `BRF_C01_STUDIO_INTEGRATION_GUIDE.md` and revalidate only that instance.

## 7. Next gate

The next action is Power Apps Studio integration of:

`blocks/BRF_C01_scr_Briefing_PDS.full-screen.pa.yaml`

BRF-C02 remains blocked until the visual gate is explicitly passed.