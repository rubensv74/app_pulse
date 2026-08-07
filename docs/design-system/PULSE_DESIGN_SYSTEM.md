# PULSE Design System

**Status:** PDS-01 foundation baseline  
**Version:** 1.0-draft  
**Scope:** PULSE Power Apps UI  
**Reference screens:** `scr_PunchReview`, `scr_Home`

---

## 1. Purpose

This document defines the visual and interaction foundation for PULSE. The objective is to move from individually polished screens and components to a coherent SaaS product family with a reusable design language.

The design system is independent from any single screen archetype. `scr_PunchReview` remains an **Operational Review Workspace** while `scr_Home` evolves toward an **Operational Control Tower + Data Explorer**. They must not share the same layout, but they must share the same visual grammar.

PDS governs brand and interaction colors, semantic colors, typography, spacing, radii, borders/shadows, selection language, component states, action hierarchy, discipline colors and migration rules for legacy hardcodes.

---

## 2. Core principles

1. **One visual language, multiple archetypes.** Different layouts may coexist; shell, typography, interaction color, geometry and states must be shared.
2. **Color has meaning.** Color is for brand, interaction, selection, semantic status and data encoding—not decoration.
3. **Brand is not interaction.** PULSE cyan (`#00C8FF`) identifies the product. Interactive blue (`#1677FF`) drives actions and selection.
4. **Dense does not mean cramped.** PULSE is an enterprise operational product; high information density is valid when hierarchy is controlled.
5. **Borders before shadows.** Standard panels use subtle borders and no shadow. Floating surfaces may use shadow.
6. **Selection is universal.** A selected punch, row, heatmap cell, discipline item or config node must use the same selection language.
7. **Migration must be incremental.** PDS-01 adds the canonical system without silently restyling existing screens. Existing visuals migrate component by component with QA.

---

## 3. Canonical color system

### Brand

| Token | Hex | Usage |
|---|---|---|
| BrandAccent | `#00C8FF` | PULSE identity and non-semantic brand accents |
| BrandDark | `#07111F` | Primary navigation background |
| BrandDarkAlt | `#0B1220` | Secondary dark navigation surface |

### Interaction

| Token | Hex | Usage |
|---|---|---|
| ActionPrimary | `#1677FF` | Primary buttons, links, active controls, focus |
| ActionHover | `#0958D9` | Primary hover |
| ActionPressed | `#084CBE` | Primary pressed |
| ActionSoft | `#EFF6FF` | Soft interactive background |
| ActionBorderSoft | `#BFDBFE` | Soft interactive border |

### Surfaces

| Token | Hex |
|---|---|
| PageBg | `#F6F8FB` |
| Surface | `#FFFFFF` |
| SurfaceAlt | `#F8FAFC` |
| SurfaceHover | `#F8FAFC` |
| SurfaceDisabled | `#F1F5F9` |

### Text

| Token | Hex |
|---|---|
| Text | `#0F172A` |
| TextMuted | `#64748B` |
| TextSoft | `#94A3B8` |
| TextWhite | `#FFFFFF` |

### Borders and selection

| Token | Hex |
|---|---|
| Border | `#E2E8F0` |
| BorderStrong | `#CBD5E1` |
| SelectedBg | `#EFF6FF` |
| SelectedBorder | `#91CAFF` |
| SelectedAccent | `#1677FF` |

### Semantic

| Semantic | Main | Soft | Text |
|---|---|---|---|
| Success | `#22C55E` | `#DCFCE7` | `#15803D` |
| Warning | `#F59E0B` | `#FEF3C7` | `#B45309` |
| Danger | `#EF4444` | `#FEE2E2` | `#B91C1C` |
| Info | `#1677FF` | `#EFF6FF` | `#1D4ED8` |
| Violet | `#8B5CF6` | `#F5F3FF` | `#6D28D9` |

Rules:

- Do not introduce new primary blues without updating PDS.
- Legacy `#0B5ED7`, `#0F6BFF`, `#0957D6` and comparable button blues are migration targets.
- Red is reserved for destructive actions, errors and genuinely critical states.
- `Clear filters`, `Reset view` and similar reversible actions are neutral.
- Neutral KPIs should not become warning-colored merely because they represent open work.

---

## 4. Discipline palette

Discipline colors are a **data-visualization palette**, not an interaction palette.

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

Allowed: charts, legends, discipline markers, discipline-coded heatmaps.  
Not allowed as substitutes for primary buttons, global links, generic selection, navigation or page-header styling.

When a discipline item is selected, its data color may remain inside the visualization, but the container must use the common PULSE selected background/border.

---

## 5. Typography

**Font:** Segoe UI.

| Token | Size | Weight | Usage |
|---|---:|---|---|
| TypePageTitle | 20 | Semibold | Page/workspace title |
| TypePageSubtitle | 10 | Normal | Page subtitle |
| TypeSectionTitle | 12 | Semibold | Section/panel title |
| TypePanelSubtitle | 9 | Normal | Panel explanatory line |
| TypeBody | 9 | Normal | Standard body |
| TypeValue | 9 | Semibold | Field values |
| TypeLabel | 8 | Normal | Field labels |
| TypeMetadata | 8 | Normal | Timestamps/counts |
| TypeBadge | 8 | Semibold | Status/chips |
| TypeKpiValue | 26 | Bold | KPI value |
| TypeKpiLabel | 10 | Semibold | KPI label |

Rules:

- No new reusable UI text below size 8.
- Existing size-7 content is a migration target when the containing component is touched.
- Prefer Semibold to Bold for headings; reserve Bold for KPI/numeric emphasis.

---

## 6. Spacing

| Token | Value |
|---|---:|
| SpaceXS | 4 |
| SpaceS | 8 |
| SpaceM | 12 |
| SpaceL | 16 |
| SpaceXL | 24 |
| SpaceXXL | 32 |

Default: panel padding 12–16; sibling panel gap 10–12; header control gap 8; label/value gap 4; major section gap 12–16.

---

## 7. Geometry

| Token | Value | Usage |
|---|---:|---|
| RadiusControl | 8 | Inputs, buttons, compact controls |
| RadiusPanel | 12 | Cards, panels, queue/table rows |
| RadiusModal | 16 | Modal/drawer/floating large surface |
| RadiusPill | 999 | Pills, badges, chips |

Legacy radii such as 6, 7, 9, 10, 14, 17, 18 and 20 must not be propagated into new reusable components. Existing screens migrate when their components are refactored.

---

## 8. Borders and shadows

**Normal panel:** Surface + Border 1 + RadiusPanel + `DropShadow.None`.  
**Selected item:** SelectedBg + SelectedBorder/SelectedAccent + optional 3 px accent.  
**Floating surface:** modal/drawer/popover may use shadow.

---

## 9. Component state standard

Reusable interactive components consider, where relevant:

`Default · Hover · Focus · Pressed · Selected · Disabled · Loading · Empty · No results · Error · Success`

Recommended behavior:

- Hover → subtle SurfaceAlt/ActionSoft.
- Focus → visible ActionPrimary focus treatment.
- Pressed → ActionPressed for primary actions.
- Selected → SelectedBg + SelectedBorder + SelectedAccent.
- Disabled → lower contrast but legible.
- Loading → localized skeleton/spinner whenever possible.
- Empty → icon + title + explanation + optional action.
- Error → recoverable inline state before full-page blocking error.

---

## 10. Action hierarchy

**Primary:** one dominant action per local context (`Mark Reviewed`, `Review`, `Publish`, `Save`, `Resolve`).  
**Secondary:** important but non-dominant (`Open Punch List`, `Reassign`).  
**Utility:** `Refresh`, `Export`, `Comment`, `Columns`, `Density`.  
**Danger:** only destructive/irreversible actions (`Delete`, true rejection/discard semantics).

---

## 11. Selection language

Canonical:

- Background `#EFF6FF`
- Border `#91CAFF`
- Accent `#1677FF`
- Text `#0F172A`

Apply consistently to Review Queue, DataTable, heatmap, discipline selection, Config tree and all master-detail selections.

---

## 12. Canonical Power Fx bootstrap

### Target location

Final source of truth: **application-level initialization** (`App.OnStart` or the established central bootstrap), not screen `OnVisible`.

PDS-01 is intentionally non-destructive: current screen-level theme fallbacks remain temporarily until the reference screens are migrated and visually validated.

```powerfx
// =====================================================
// PULSE DESIGN SYSTEM v1 — PDS-01 FOUNDATIONS
// Central application bootstrap
// =====================================================

// BRAND
Set(varTheme_BrandAccent, ColorValue("#00C8FF"));
Set(varTheme_BrandDark, ColorValue("#07111F"));
Set(varTheme_BrandDarkAlt, ColorValue("#0B1220"));

// INTERACTION
Set(varTheme_ActionPrimary, ColorValue("#1677FF"));
Set(varTheme_ActionHover, ColorValue("#0958D9"));
Set(varTheme_ActionPressed, ColorValue("#084CBE"));
Set(varTheme_ActionSoft, ColorValue("#EFF6FF"));
Set(varTheme_ActionBorderSoft, ColorValue("#BFDBFE"));

// SURFACES
Set(varTheme_PageBg, ColorValue("#F6F8FB"));
Set(varTheme_Surface, ColorValue("#FFFFFF"));
Set(varTheme_SurfaceAlt, ColorValue("#F8FAFC"));
Set(varTheme_SurfaceHover, ColorValue("#F8FAFC"));
Set(varTheme_SurfaceDisabled, ColorValue("#F1F5F9"));

// TEXT
Set(varTheme_Text, ColorValue("#0F172A"));
Set(varTheme_TextMuted, ColorValue("#64748B"));
Set(varTheme_TextSoft, ColorValue("#94A3B8"));
Set(varTheme_TextWhite, ColorValue("#FFFFFF"));

// BORDERS + SELECTION
Set(varTheme_Border, ColorValue("#E2E8F0"));
Set(varTheme_BorderStrong, ColorValue("#CBD5E1"));
Set(varTheme_SelectedBg, ColorValue("#EFF6FF"));
Set(varTheme_SelectedBorder, ColorValue("#91CAFF"));
Set(varTheme_SelectedAccent, varTheme_ActionPrimary);

// SEMANTIC
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

// GEOMETRY — canonical values for NEW/MIGRATED components
Set(varTheme_RadiusControl, 8);
Set(varTheme_RadiusPanel, 12);
Set(varTheme_RadiusModal, 16);
Set(varTheme_RadiusPill, 999);

// SPACING
Set(varTheme_SpaceXS, 4);
Set(varTheme_SpaceS, 8);
Set(varTheme_SpaceM, 12);
Set(varTheme_SpaceL, 16);
Set(varTheme_SpaceXL, 24);
Set(varTheme_SpaceXXL, 32);

// TYPOGRAPHY
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
// LEGACY COMPATIBILITY
// Preserve CURRENT appearance during PDS-01.
// New components MUST NOT use these aliases.
// -----------------------------------------------------
Set(varTheme_NavBg, ColorValue("#07111F"));
Set(varTheme_NavBg2, ColorValue("#0B1220"));
Set(varTheme_PulseBlue, ColorValue("#00C8FF"));
Set(varTheme_PulseBlueDark, ColorValue("#1677FF"));
Set(varTheme_PulseSoft, ColorValue("#E0F7FF"));
Set(varTheme_CardRadius, 16);
Set(varTheme_ButtonRadius, 10);

// DESIGN SYSTEM VERSION
Set(varTheme_DesignSystemVersion, "PDS-1.0");
```

### Discipline collection

The existing `colDisciplinePalette` values are already compatible with PDS-01. In this block they may remain where they currently initialize. Centralization can be done together with application bootstrap cleanup after reference-screen validation.

---

## 13. Confirmed migration targets

### Duplicate interaction colors

Current code contains or references multiple action blues (`#0B5ED7`, `#0F6BFF`, `#0957D6`, plus canonical `#1677FF`). New components use the canonical interaction tokens. Existing controls migrate when touched.

### Local selection implementations

Selected heatmap/discipline/queue/table treatments must progressively converge on SelectedBg / SelectedBorder / SelectedAccent. Discipline colors remain data encoding, not generic selection borders.

### Hardcoded semantic colors

OPEN / IN PROGRESS / CLOSED pills, Session Activity events and help/status surfaces contain direct hex values. Migrate them to semantic tokens component by component.

### Radius proliferation

Existing values include several radii outside the 8 / 12 / 16 / 999 system. Do not mass-replace; normalize during component migration.

### Typography floor

Existing size-7 metadata remains valid temporarily but no new reusable UI should introduce sizes below 8.

### Shadows

Standard Punch Review cards currently use `DropShadow.Semilight` in places. These are migration targets; normal PDS panels are border-driven.

---

## 14. PDS-01 implementation sequence

1. Add canonical tokens to the central application bootstrap.
2. Preserve the legacy compatibility values exactly as they exist today.
3. Run application bootstrap and validate Home + Punch Review.
4. Do **not** remove screen-level token fallbacks yet.
5. New PDS components use canonical tokens only.
6. Remove legacy/screen-level ownership only when the relevant reference screens have migrated and passed visual QA.

---

## 15. Out of scope in PDS-01

Do not change yet:

- Punch Review information architecture;
- Home heatmap or discipline filtering behavior;
- DataGrid filtering/pagination;
- comments service calls;
- review-session business behavior;
- drawer behavior;
- SQL/flows;
- responsive layout;
- page header layouts.

---

## 16. Acceptance criteria

PDS-01 is complete when:

- [ ] Canonical variables are initialized at application level.
- [ ] Existing Home and Punch Review continue working without functional regression.
- [ ] Existing visual aliases keep their current values during the foundation block.
- [ ] `varTheme_ActionPrimary = #1677FF` and `varTheme_BrandAccent = #00C8FF` are available globally.
- [ ] Selection tokens are globally available.
- [ ] Canonical radius, spacing and typography tokens are globally available.
- [ ] No new `#0B5ED7`, `#0F6BFF` or `#0957D6` is introduced.
- [ ] No new reusable radius outside 8 / 12 / 16 / 999 is introduced.
- [ ] No new reusable typography below size 8 is introduced.
- [ ] `varTheme_DesignSystemVersion = "PDS-1.0"` is available.

---

## 17. Next block

**PDS-02 — PULSE Application Shell / `cmp_PageHeaderPro`**

PDS-02 will define and implement the common page header used by Control Tower, Review Workspace, Data Explorer, Configuration Studio and future PULSE archetypes without forcing them into the same internal layout.
