# BRIEFING_PDS — BLOCK 00 — FOUNDATION AUDIT

**Capability:** `BRF-C01 — Premium shell and visual states`  
**Target screen:** `scr_Briefing_PDS`  
**Branch:** `brf-c01-premium-shell`  
**Canonical base:** `main`  
**Validation authority:** Power Apps Studio + App Checker  
**Status:** PRE-FLIGHT COMPLETE — IMPLEMENTATION MAY PROCEED TO STUDIO GATE

## 1. Sources of truth consulted

- `AGENTS.md`
- `docs/specifications/briefing-pds/BRIEFING_PDS_SCREEN_SPECIFICATION.md`
- `docs/specifications/briefing-pds/BRF_C01_CAPABILITY_PROMPT.md`
- `docs/design-system/PULSE_DESIGN_SYSTEM.md`
- `docs/design-system/SAAS_INTERFACE_ARCHETYPES.md`
- `docs/design-system/POWER_APPS_VISUAL_QA_GUARDRAILS.md`
- `docs/development/PROTOCOLO_CONSTRUCCION_MODULAR_PANTALLAS_POWER_APPS.md`
- `docs/development/ARTIFACT_DELIVERY_POLICY.md`
- `docs/development/screens/home-pds/POWER_APPS_SOURCE_CODE_COMPATIBILITY.md`
- `docs/development/screens/home-pds/blocks/01_screen_shell.pa.yaml`
- `docs/development/screens/home-pds/blocks/01A_sidebar_manual_instance.md`
- `power-apps/components/cmp_SidebarNav.pa.yaml`
- `power-apps/screens/PunchReview/scr_PunchReview.pa.yaml`

## 2. Confirmed UI dialect

Control families already demonstrated in the repository and allowed for BRF-C01:

```text
GroupContainer@1.5.0
Label@2.5.1
ModernText@1.0.0
ModernButton@1.0.0
ModernCombobox@1.1.1
Spinner@1.4.6
Classic/Icon@2.5.0
CanvasComponent
```

Major geometry uses `GroupContainer@1.5.0` AutoLayout. ManualLayout is restricted to bounded cards/modules. Static ModernText defaults to `AutoHeight=true` and an explicit wrap strategy.

## 3. PDS baseline

```text
PageBg            #F6F8FB
Surface           #FFFFFF
SurfaceAlt        #F8FAFC
BrandDark         #07111F
BrandAccent       #00C8FF
ActionPrimary     #1677FF
ActionSoft        #EFF6FF
ActionBorderSoft  #BFDBFE
Border            #E2E8F0
BorderStrong      #CBD5E1
Text              #0F172A
TextMuted         #64748B
SelectedBg        #EFF6FF
SelectedBorder    #91CAFF
Success           #22C55E
Warning           #F59E0B
Danger            #EF4444
```

Geometry:

```text
RadiusControl 8
RadiusPanel   12
RadiusModal   16
```

Rule: borders before shadows. Normal panels use `Surface + Border 1 + RadiusPanel + DropShadow.None`.

## 4. Architecture frozen for BRF-C01

```text
PRIMARY_ARCHETYPE: Object 360
PRIMARY_OBJECT: Review Session
SECONDARY_PATTERNS:
- KPI Strip
- Audit Timeline
- Contextual Tabs
- Evidence Drawer
- Activity Stream
- Inline Review
- Empty / Loading / Error state surfaces
```

BRF-C01 is synthetic/local only. No SQL, flows, real Review Session persistence, Session Delta, AI, Outlook or Teams integration is permitted.

## 5. Known incompatibilities and defensive decisions

### 5.1 `cmp_PageHeaderPro` is NOT used

Home_PDS evidence shows that a Source Code-created custom component instance may render without hydrating its expected public input contract. A manually inserted `cmp_PageHeaderPro` can be instance-safe while the Source Code-created equivalent is not.

Decision:

> BRF-C01 builds the premium header from confirmed native controls instead of reusing `cmp_PageHeaderPro`.

This avoids a known non-value-adding integration risk.

### 5.2 `cmp_SidebarNav` remains required but has a localized hydration risk

`scr_PunchReview` proves that an already-hydrated `cmp_SidebarNav` instance can serialize host-side custom inputs successfully. Home_PDS proves that creating the instance from Source Code on a restarted empty screen can render the body while ignoring custom host input assignments and showing component defaults such as `Text`.

Decision:

- include the required `cmp_SidebarNav` instance in the cumulative screen source;
- bind the same public contract used by canonical screens;
- treat host-input hydration as `NOT_RUN` until Studio validates the new screen;
- if the footer shows default `Text / Text`, keep the screen source and replace **only** the sidebar instance manually in Studio using the supplied integration guide;
- do not regenerate the component definition.

This is a localized gate and does not block construction of the rest of BRF-C01.

### 5.3 No custom components inside galleries

BRF-C01 uses native controls for synthetic lists and table rows. No new reusable Canvas component is introduced.

### 5.4 Radius properties remain control-specific

Radius properties are applied only to GroupContainer surfaces where the repository already demonstrates the pattern. They are not applied to Label/ModernText/Icon controls.

### 5.5 Static text overflow

Every static `ModernText@1.0.0` uses `AutoHeight=true`. One-line values additionally use `Wrap=false`; narrative content uses `Wrap=true`.

## 6. Reusable component decision

### Reuse

`cmp_SidebarNav` only.

### Do not reuse in BRF-C01

- `cmp_PageHeaderPro` — known source-created host contract risk.
- `cmp_KpiCardPro` — unnecessary for five fixed synthetic KPI surfaces and would add a custom-component hydration dependency.
- data-grid components — Action Register is synthetic and can be represented safely with native rows during the visual gate.
- legacy detail drawer — not needed; Evidence Drawer is built as a bounded native surface.

## 7. Synthetic state contract

The screen owns only local test variables:

```text
varBRF_TestState
varBRF_ActiveTab
varBRF_ShowEvidence
```

Allowed values for `varBRF_TestState`:

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

These states are visual scaffolding only and must never be described as evidence of backend behavior.

## 8. Synthetic dataset

The visual composition uses one coherent fictional session:

```text
Project            10490 · Bilbao LNG Project
Review Session     Weekly Punch Review · #PR-2026-0816
Meeting Date       16 Aug 2026 · 09:00–10:15
Reviewed           63
Changed            21
Comments            34
Actions              7
Blockers             4
Source events       84
Review issues         8
Missing owners        2
Missing due dates     1
Unsupported claims    0
```

The same numbers must remain consistent across header, KPI strip, quality panel and synthetic copy.

## 9. Do-not-invent list

BRF-C01 must not invent or imply:

- a real ReviewSessionId contract;
- database tables or stored procedures;
- flow names or payloads;
- AI provider/model configuration;
- Teams transcript availability;
- Outlook send confirmation;
- real attendees;
- real owners/due dates for missing information;
- persistence of any state selected in the visual test control.

## 10. Open risks entering Studio gate

| Risk | Status before Studio | Required evidence |
|---|---|---|
| Full screen Source Code accepted | NOT_RUN | Paste/save in Studio |
| `cmp_SidebarNav` host inputs hydrate | NOT_RUN | Footer + active key visual check |
| AutoLayout proportions at target resolution | NOT_RUN | Screenshot + visual inspection |
| Static ModernText has no internal scrollbars | NOT_RUN | Visual inspection at normal/125% zoom |
| Evidence drawer overlay geometry | NOT_RUN | Open/close interaction |
| Tab state switching | NOT_RUN | Click all three tabs |
| Nine states mutually exclusive | NOT_RUN | Select every state |
| Action Register density | NOT_RUN | Screenshot + visual inspection |
| Responsive behavior | NOT_RUN | Width reduction test |

## 11. Preflight result

```text
BASELINE_RECONSTRUCTED          PASS
PDS_RULES_IDENTIFIED            PASS
ARCHETYPE_FROZEN                PASS
CONTROL_FAMILIES_CONFIRMED      PASS
KNOWN_COMPONENT_RISKS_CAPTURED  PASS
BACKEND_DEPENDENCIES_REQUIRED   NOT_APPLICABLE
STUDIO_EXECUTION                NOT_RUN
```

No repository-side dependency blocks construction. The first unavoidable gate is Power Apps Studio acceptance and visual validation of the BRF-C01 cumulative source.