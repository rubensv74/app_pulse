# Using PULSE SVG Icons in Power Apps

## Preferred strategy

For the current Canvas application, prefer **imported SVG media assets** when the color/state is known in advance. This avoids dependence on native Power Apps icon availability and avoids fragile runtime SVG parsing for routine navigation.

The V1 sidebar therefore ships two physical variants per primary destination:

```text
sidebar/inactive/*.svg  → white
sidebar/active/*.svg    → PULSE cyan
```

## Sidebar pattern

Import both media files with stable names, for example:

```text
pulse_home_inactive
pulse_home_active
```

Then bind the Image property conceptually as:

```powerfx
If(
    ThisItem.IsActive,
    pulse_home_active,
    pulse_home_inactive
)
```

The selected container should still use the common PULSE selection language; do not rely on cyan alone.

## Toolbar and light surfaces

Use the canonical `outline/` assets on light surfaces. They use PDS Text `#0F172A` and are designed for compact toolbars, cards and grids.

Recommended visual sizes:

```text
16 px → dense secondary action, validate carefully
20 px → preferred compact UI size
24 px → navigation / prominent action
```

The clickable control itself should normally be larger than the icon.

## Semantic states

Use `semantic/` assets only when the symbol communicates actual status. Do not recolor generic actions red, amber or green merely to make them more visible.

## Accessibility

For interactive icon controls:

```text
AccessibleLabel = clear action name
Tooltip         = useful short explanation when supported
```

A decorative Image should not be the only source of an action label.

## Dynamic recoloring

Dynamic SVG data-URI techniques can be introduced later for components that genuinely need arbitrary runtime colors. They should not be the default for navigation because fixed imported variants are simpler and more predictable in Power Apps Studio.

If a dynamic implementation is added, it must preserve the same geometry and use PDS tokens; it must not create a parallel icon design.

## Validation gate

Before V1 becomes `ACTIVE`, validate at least:

1. SVG import into the real PULSE Canvas app.
2. Rendering on dark sidebar and light surfaces.
3. 16/20/24 px legibility.
4. No unexpected cropping or background.
5. Active/inactive switching.
6. Accessibility label on the host control.
7. Rendering at normal browser zoom and one higher zoom level.

Record any Power Apps-specific rendering lesson in the visual QA guardrails before changing the canonical geometry globally.
