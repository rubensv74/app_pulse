# PULSE Design System

**Status:** PDS-01 foundation baseline  
**Version:** 1.0-draft  
**Scope:** PULSE Power Apps UI  
**Reference screens:** `scr_PunchReview`, `scr_Home`

---

## 1. Purpose

This document defines the visual and interaction foundation for PULSE. The objective is to move from individually polished screens and components to a coherent SaaS product family with a reusable design language.

The design system is deliberately independent from any single screen archetype. `scr_PunchReview` remains an **Operational Review Workspace** while `scr_Home` evolves toward an **Operational Control Tower + Data Explorer**. They must not share the same layout, but they must share the same visual grammar.

The system governs:

- brand and interaction colors;
- semantic colors;
- typography;
- spacing;
- radii;
- borders and shadows;
- selection language;
- component states;
- action hierarchy;
- discipline colors;
- migration rules for legacy visual hardcodes.

---

## 2. Core principles

### 2.1 One visual language, multiple archetypes

Screens may use different information architectures, but must use the same shell, typography, interaction color, selection language, panel geometry and component states.

### 2.2 Color has meaning

Color is reserved for brand identity, interaction, selection, semantic status and data encoding. Decorative color is discouraged.

### 2.3 Brand is not interaction

PULSE cyan and interactive blue have different responsibilities:

- **Brand Accent**: `#00C8FF`
- **Action Primary**: `#1677FF`

PULSE cyan must not become the universal button color.

### 2.4 Dense does not mean cramped

PULSE is an enterprise operational application. High information density is acceptable when hierarchy, spacing and grouping remain consistent.

### 2.5 Borders before shadows

Normal panels use subtle borders and no shadow. Shadows are primarily reserved for floating surfaces such as modals, drawers, popovers and dropdowns.

### 2.6 Selection must look the same everywhere

A selected punch, heatmap cell, discipline bar, table row or configuration node must use the same selection language.

---

## 3. Canonical color system

### 3.1 Brand

| Token | Hex | Usage |
|---|---|---|
| BrandAccent | `#00C8FF` | PULSE identity, logo accents, non-semantic brand decoration |
| BrandDark | `#07111F` | Primary navigation background |
| BrandDarkAlt | `#0B1220` | Secondary dark navigation surface |

### 3.2 Interaction

| Token | Hex | Usage |
|---|---|---|
| ActionPrimary | `#1677FF` | Primary buttons, active controls, links, focus |
| ActionHover | `#0958D9` | Primary hover |
| ActionPressed | `#084CBE` | Primary pressed state |
| ActionSoft | `#EFF6FF` | Soft interactive background |
| ActionBorderSoft | `#BFDBFE` | Soft interactive border |

### 3.3 Surfaces

| Token | Hex | Usage |
|---|---|---|
| PageBg | `#F6F8FB` | Application page background |
| Surface | `#FFFFFF` | Cards, panels, inputs |
| SurfaceAlt | `#F8FAFC` | Secondary panel backgrounds, table headers |
| SurfaceHover | `#F8FAFC` | Neutral hover |
| SurfaceDisabled | `#F1F5F9` | Disabled areas |

### 3.4 Text

| Token | Hex | Usage |
|---|---|---|
| Text | `#0F172A` | Primary text |
| TextMuted | `#64748B` | Secondary text |
| TextSoft | `#94A3B8` | Tertiary metadata |
| TextWhite | `#FFFFFF` | Text on dark/primary surfaces |

### 3.5 Borders and selection

| Token | Hex | Usage |
|---|---|---|
| Border | `#E2E8F0` | Default panel/control border |
| BorderStrong | `#CBD5E1` | Stronger neutral divider |
| SelectedBg | `#EFF6FF` | Selected row/item background |
| SelectedBorder | `#91CAFF` | Selected border |
| SelectedAccent | `#1677FF` | Selected indicator/accent |

### 3.6 Semantic colors

| Semantic | Main | Soft | Text |
|---|---|---|---|
| Success | `#22C55E` | `#DCFCE7` | `#15803D` |
| Warning | `#F59E0B` | `#FEF3C7` | `#B45309` |
| Danger | `#EF4444` | `#FEE2E2` | `#B91C1C` |
| Info | `#1677FF` | `#EFF6FF` | `#1D4ED8` |
| Violet | `#8B5CF6` | `#F5F3FF` | `#6D28D9` |

### 3.7 Rules

1. Do not introduce new primary blues without updating this document.
2. Replace legacy `#0B5ED7`, `#0F6BFF`, `#0957D6` and comparable button blues with the interaction tokens.
3. Use red only for destructive actions, errors and real critical states.
4. `Clear`, `Reset`, `Remove filter` and similar reversible view actions are neutral, not danger actions.
5. Neutral metrics use ActionPrimary or Text; do not assign warning colors merely because the metric is named “Open”.

---

## 4. Discipline palette

Discipline colors are a **data-visualization palette**, not a UI interaction palette.

| Discipline | Hex |
|---|---|
| Electrical | `#F97316` |
| Piping | `#14B8A6` |
| Mechanical | `#2563EB` |
| Instrumentation | `#8B5CF6` |
| Civil | `#06B6D4` |
| HVAC | `#0EA5E9` |
| Structural | `#6366F1` |
| Fireproofing | `#EF4444` |
| Telecom | `#22C55E` |
| Safety | `#F59E0B` |
| Other | `#64748B` |

Allowed usage:

- donut/pie segments;
- bar-chart bars;
- legends;
- discipline markers;
- discipline-based heatmap encoding.

Not allowed as a substitute for:

- primary buttons;
- global links;
- page headers;
- generic selection borders;
- navigation state.

When a discipline bar is selected, keep its data color for the bar itself but use the common PULSE selection background/border for the selected container.

---

## 5. Typography

**Font family:** Segoe UI.

PULSE retains Segoe UI to stay aligned with the Microsoft/Fluent ecosystem and Power Apps runtime. The improvement target is hierarchy and consistency, not font substitution.

| Token | Power Apps Size | Weight | Usage |
|---|---:|---|---|
| TypePageTitle | 20 | Semibold | Page/workspace title |
| TypePageSubtitle | 10 | Normal | Page subtitle |
| TypeSectionTitle | 12 | Semibold | Panel/section title |
| TypePanelSubtitle | 9 | Normal | Panel explanatory line |
| TypeBody | 9 | Normal | Standard body text |
| TypeValue | 9 | Semibold | Field values |
| TypeLabel | 8 | Normal | Field labels |
| TypeMetadata | 8 | Normal | Timestamps, counts, secondary metadata |
| TypeBadge | 8 | Semibold | Status pills/chips |
| TypeKpiValue | 26 | Bold | KPI primary value |
| TypeKpiLabel | 10 | Semibold | KPI label |

Rules:

- Avoid new text below size 8.
- Existing size-7 metadata should be migrated when each component is touched.
- Use Semibold instead of Bold for most headings; reserve Bold for KPIs, critical numeric emphasis and short labels when necessary.
- Uppercase is reserved for short data headers, statuses and controlled labels, not paragraph headings.

---

## 6. Spacing system

| Token | Value | Usage |
|---|---:|---|
| SpaceXS | 4 | Micro separation |
| SpaceS | 8 | Tight control spacing |
| SpaceM | 12 | Standard internal gap |
| SpaceL | 16 | Standard panel padding |
| SpaceXL | 24 | Major section separation |
| SpaceXXL | 32 | Rare large structural separation |

Default recommendations:

- Panel padding: 12–16 px.
- Horizontal gap between sibling panels: 10–12 px.
- Header control gap: 8 px.
- Field label/value gap: 4 px.
- Major page section gap: 12–16 px.

Avoid arbitrary spacing values unless layout math requires them.

---

## 7. Geometry

The canonical geometry system is intentionally small.

| Token | Value | Usage |
|---|---:|---|
| RadiusControl | 8 | Inputs, buttons, compact controls |
| RadiusPanel | 12 | Cards, sections, queue rows |
| RadiusModal | 16 | Modals, drawers, large floating surfaces |
| RadiusPill | 999 | Status pills, chips, counters |

Legacy radii 6, 7, 9, 10, 14, 17, 18 and 20 should not be propagated into new work.

Do not perform a mass cosmetic rewrite of every existing control. Normalize geometry when the containing component/screen is migrated.

---

## 8. Border and shadow rules

### Normal panels

- Fill: Surface
- Border: Border
- BorderThickness: 1
- Radius: RadiusPanel
- DropShadow: None

### Selected items

- Fill: SelectedBg
- Border: SelectedBorder or SelectedAccent when stronger emphasis is required
- BorderThickness: 1 or 2 according to interaction density
- Optional left accent: 3 px SelectedAccent

### Floating surfaces

Modals, drawers, contextual overlays and popovers may use a shadow. Normal cards should not rely on shadows for hierarchy.

---

## 9. Component state standard

Every reusable interactive component should explicitly consider the following states when relevant:

1. Default
2. Hover
3. Focus
4. Pressed
5. Selected
6. Disabled
7. Loading
8. Empty
9. No results
10. Error
11. Success

### Recommended visual behavior

- Hover: subtle SurfaceAlt/ActionSoft feedback.
- Focus: visible ActionPrimary focus treatment; keyboard focus must not disappear.
- Pressed: ActionPressed for primary actions.
- Selected: SelectedBg + SelectedBorder + SelectedAccent.
- Disabled: lower-contrast surface/text but remain legible.
- Loading: localized skeleton/spinner whenever possible.
- Empty: icon + title + explanation + optional action.
- Error: inline recoverable state before full-screen blocking error.

---

## 10. Action hierarchy

### Primary

One visually dominant action per local context.

Examples:

- Mark Reviewed
- Review
- Publish
- Save
- Resolve

### Secondary

Important but non-dominant action.

Examples:

- Open Punch List
- Reassign
- Request Info

### Utility

Operational helpers.

Examples:

- Refresh
- Export
- Comment
- Columns
- Density

### Danger

Only destructive, irreversible or critical actions.

Examples:

- Delete
- Reject when business semantics are destructive
- Discard changes

`Clear filters` is neutral and must not use danger styling.

---

## 11. Selection language

Canonical selection tokens:

- Background: `#EFF6FF`
- Border: `#91CAFF`
- Accent: `#1677FF`
- Text: `#0F172A`

Apply consistently to:

- Punch Review queue item;
- selected DataTable row;
- selected heatmap cell;
- selected discipline item;
- selected configuration tree node;
- selected master-detail record;
- selected contextual chip when it represents active context.

Data colors may remain visible inside the selected object, but must not replace the common selection treatment.

---

## 12. Canonical Power Fx bootstrap

### 12.1 Target location

The final target is **application-level initialization** (`App.OnStart` or the established central application bootstrap), not screen-specific `OnVisible` blocks.

During migration, legacy screen-level safety initialization may remain temporarily, but new tokens must be defined centrally first.

### 12.2 PDS-01 Power Fx block

```powerfx
// =====================================================
// PULSE DESIGN SYSTEM v1 — PDS-01 FOUNDATIONS
// Central application bootstrap
// =====================================================

// -----------------------------------------------------
// BRAND
// -----------------------------------------------------
Set(varTheme_BrandAccent, ColorValue("#00C8FF"));
Set(varTheme_BrandDark, ColorValue("#07111F"));
Set(varTheme_BrandDarkAlt, ColorValue("#0B1220"));

// -----------------------------------------------------
// INTERACTION
// -----------------------------------------------------
Set(varTheme_ActionPrimary, ColorValue("#1677FF"));
Set(varTheme_ActionHover, ColorValue("#0958D9"));
Set(varTheme_ActionPressed, ColorValue("#084CBE"));
Set(varTheme_ActionSoft, ColorValue("#EFF6FF"));
Set(varTheme_ActionBorderSoft, ColorValue("#BFDBFE"));

// -----------------------------------------------------
// SURFACES
// -----------------------------------------------------
Set(varTheme_PageBg, ColorValue("#F6F8FB"));
Set(varTheme_Surface, ColorValue("#FFFFFF"));
Set(varTheme_SurfaceAlt, ColorValue("#F8FAFC"));
Set(varTheme_SurfaceHover, ColorValue("#F8FAFC"));
Set(varTheme_SurfaceDisabled, ColorValue("#F1F5F9"));

// -----------------------------------------------------
// TEXT
// -----------------------------------------------------
Set(varTheme_Text, ColorValue("#0F172A"));
Set(varTheme_TextMuted, ColorValue("#64748B"));
Set(varTheme_TextSoft, ColorValue("#94A3B8"));
Set(varTheme_TextWhite, ColorValue("#FFFFFF"));

// -----------------------------------------------------
// BORDERS + SELECTION
// -----------------------------------------------------
Set(varTheme_Border, ColorValue("#E2E8F0"));
Set(varTheme_BorderStrong, ColorValue("#CBD5E1"));
Set(varTheme_SelectedBg, ColorValue("#EFF6FF"));
Set(varTheme_SelectedBorder, ColorValue("#91CAFF"));
Set(varTheme_SelectedAccent, varTheme_ActionPrimary);

// -----------------------------------------------------
// SEMANTIC
// -----------------------------------------------------
Set(varTheme_Green, ColorValue("#22C55E"));
Set(varTheme_GreenSoft, ColorValue("#DCFCE7"));
Set(varTheme_GreenText, ColorValue("#15803D"));

Set(varTheme_Amber, ColorValue("#F59E0B"));
Set(varTheme_AmberSoft, ColorValue("#FEF3C7"));
Set(varTheme_AmberText, ColorValue("#B45309"));

Set(varTheme_Red, ColorValue("#EF4444"));
Set(varTheme_RedSoft, ColorValue("#FEE2E2"));
Set(varTheme_RedText, ColorValue("#B91C1C"));

Set(varTheme_Info, varTheme_ActionPrimary);
Set(varTheme_InfoSoft, varTheme_ActionSoft);
Set(varTheme_InfoText, ColorValue("#1D4ED8"));

Set(varTheme_Violet, ColorValue("#8B5CF6"));
Set(varTheme_VioletSoft, ColorValue("#F5F3FF"));
Set(varTheme_VioletText, ColorValue("#6D28D9"));

// -----------------------------------------------------
// GEOMETRY
// -----------------------------------------------------
Set(varTheme_RadiusControl, 8);
Set(varTheme_RadiusPanel, 12);
Set(varTheme_RadiusModal, 16);
Set(varTheme_RadiusPill, 999);

// -----------------------------------------------------
// SPACING
// -----------------------------------------------------
Set(varTheme_SpaceXS, 4);
Set(varTheme_SpaceS, 8);
Set(varTheme_SpaceM, 12);
Set(varTheme_SpaceL, 16);
Set(varTheme_SpaceXL, 24);
Set(varTheme_SpaceXXL, 32);

// -----------------------------------------------------
// TYPOGRAPHY
// -----------------------------------------------------
Set(varTheme_Type_PageTitle, 20);
Set(varTheme_Type_PageSubtitle, 10);
Set(varTheme_Type_SectionTitle, 12);
Set(varTheme_Type_PanelSubtitle, 9);
Set(varTheme_Type_Body, 9);
Set(varTheme_Type_Value, 9);
Set(varTheme_Type_Label, 8);
Set(varTheme_Type_Metadata, 8);
Set(varTheme_Type_Badge, 8);
Set(varTheme_Type_KpiValue, 26);
Set(varTheme_Type_KpiLabel, 10);

// -----------------------------------------------------
// LEGACY COMPATIBILITY ALIASES
// Keep during migration; do not use in new components.
// -----------------------------------------------------
Set(varTheme_NavBg, varTheme_BrandDark);
Set(varTheme_NavBg2, varTheme_BrandDarkAlt);
Set(varTheme_PulseBlue, varTheme_BrandAccent);
Set(varTheme_PulseBlueDark, varTheme_ActionPrimary);
Set(varTheme_PulseSoft, varTheme_ActionSoft);
Set(varTheme_CardRadius, varTheme_RadiusPanel);
Set(varTheme_ButtonRadius, varTheme_RadiusControl);

// -----------------------------------------------------
// DISCIPLINE DATA-VISUALIZATION PALETTE
// -----------------------------------------------------
ClearCollect(
    colDisciplinePalette,
    { DisciplineCode: "ELECTRICAL",      DisciplineName: "Electrical",      DisciplineColor: "#F97316", DisciplineOrder: 1 },
    { DisciplineCode: "PIPING",          DisciplineName: "Piping",          DisciplineColor: "#14B8A6", DisciplineOrder: 2 },
    { DisciplineCode: "MECHANICAL",      DisciplineName: "Mechanical",      DisciplineColor: "#2563EB", DisciplineOrder: 3 },
    { DisciplineCode: "INSTRUMENTATION", DisciplineName: "Instrumentation", DisciplineColor: "#8B5CF6", DisciplineOrder: 4 },
    { DisciplineCode: "CIVIL",           DisciplineName: "Civil",           DisciplineColor: "#06B6D4", DisciplineOrder: 5 },
    { DisciplineCode: "HVAC",            DisciplineName: "HVAC",            DisciplineColor: "#0EA5E9", DisciplineOrder: 6 },
    { DisciplineCode: "STRUCTURAL",      DisciplineName: "Structural",      DisciplineColor: "#6366F1", DisciplineOrder: 7 },
    { DisciplineCode: "FIREPROOFING",    DisciplineName: "Fireproofing",    DisciplineColor: "#EF4444", DisciplineOrder: 8 },
    { DisciplineCode: "TELECOM",         DisciplineName: "Telecom",         DisciplineColor: "#22C55E", DisciplineOrder: 9 },
    { DisciplineCode: "SAFETY",          DisciplineName: "Safety",          DisciplineColor: "#F59E0B", DisciplineOrder: 10 },
    { DisciplineCode: "OTHER",           DisciplineName: "Other",           DisciplineColor: "#64748B", DisciplineOrder: 999 }
);

// -----------------------------------------------------
// DESIGN SYSTEM VERSION
// -----------------------------------------------------
Set(varTheme_DesignSystemVersion, "PDS-1.0");
```

---

## 13. Current legacy patterns to migrate

The following are confirmed patterns in the current reference screens/components and must not be propagated into new work.

### 13.1 Duplicate primary blues

Examples currently present include:

- `#00C8FF`
- `#1677FF`
- `#0B5ED7`
- `#0F6BFF`
- `#0957D6`

Migration:

- brand → `varTheme_BrandAccent`
- default interaction → `varTheme_ActionPrimary`
- hover → `varTheme_ActionHover`
- pressed → `varTheme_ActionPressed`

### 13.2 Hardcoded selection colors

Replace local selection backgrounds/borders with:

- `varTheme_SelectedBg`
- `varTheme_SelectedBorder`
- `varTheme_SelectedAccent`

Do not use a discipline color as the generic selected-item border.

### 13.3 Hardcoded status colors

Current OPEN / IN PROGRESS / CLOSED pills and Session Activity event colors contain direct hex values. Replace them progressively with semantic tokens:

- Danger / DangerSoft / DangerText
- Warning / WarningSoft / WarningText
- Success / SuccessSoft / SuccessText
- Info / InfoSoft / InfoText
- Violet / VioletSoft / VioletText

### 13.4 Radius proliferation

Current screens contain values including 4, 6, 7, 8, 9, 10, 12, 14, 17, 18 and 20.

New work uses only 8 / 12 / 16 / 999 unless a geometry-specific control requires a mathematically derived circle radius.

### 13.5 Typography below the new floor

Existing size-7 metadata and badges remain functional but are migration targets. New work should not introduce text below size 8.

### 13.6 Normal-card shadows

`DropShadow.Semilight` currently appears on standard Punch Review cards. These should become border-driven panels when each component is migrated. Preserve shadows for floating surfaces.

---

## 14. PDS-01 migration sequence

PDS-01 must not become a mass visual rewrite.

### Step 1 — Add central tokens

Add the canonical bootstrap to the application-level initialization.

### Step 2 — Preserve compatibility

Keep legacy aliases so current components continue working.

### Step 3 — Remove screen-level ownership of theme

`Home.OnVisible` and `PunchReview.OnVisible` may retain temporary safety fallbacks only during migration. They must not be the long-term source of truth for PULSE theme definitions.

### Step 4 — New components use canonical tokens only

The next components (`cmp_PageHeaderPro`, `cmp_PanelHeaderPro`, etc.) use the new `Action`, `Selected`, `Radius`, `Space` and typography tokens rather than legacy aliases.

### Step 5 — Migrate existing components when touched

Do not perform blind search/replace across the entire app. Migrate by component/screen with visual QA.

---

## 15. Do not change in PDS-01

The following are explicitly out of scope for this foundation block:

- Punch Review information architecture;
- Home heatmap behavior;
- discipline filtering logic;
- DataGrid filtering/pagination logic;
- comments service calls;
- review session business behavior;
- drawer behavior;
- SQL / flows;
- responsive layout redesign;
- page-header redesign.

Those changes belong to subsequent PDS blocks.

---

## 16. Acceptance criteria — PDS-01

PDS-01 is complete when all conditions below are true:

- [ ] Canonical theme variables are initialized centrally.
- [ ] Existing screens still load without functional regression.
- [ ] `varTheme_PulseBlueDark` resolves to `varTheme_ActionPrimary` through compatibility aliasing.
- [ ] `varTheme_PulseBlue` resolves to `varTheme_BrandAccent`.
- [ ] `varTheme_CardRadius` resolves to `varTheme_RadiusPanel`.
- [ ] `varTheme_ButtonRadius` resolves to `varTheme_RadiusControl`.
- [ ] Discipline colors remain unchanged and function only as data/discipline semantics.
- [ ] No new use of `#0B5ED7`, `#0F6BFF` or `#0957D6` is introduced.
- [ ] No new radius outside 8 / 12 / 16 / 999 is introduced in reusable UI components.
- [ ] No new typography below size 8 is introduced.
- [ ] `scr_Home` continues to render the current dashboard.
- [ ] `scr_PunchReview` continues to render and execute review actions/comments normally.
- [ ] Design-system version is available as `varTheme_DesignSystemVersion = "PDS-1.0"`.

---

## 17. Next block

**PDS-02 — PULSE Application Shell / `cmp_PageHeaderPro`**

The next block will define and implement the common page header shared by Control Tower, Review Workspace, Data Explorer, Configuration Studio and future PULSE archetypes without forcing those screens into the same internal layout.
