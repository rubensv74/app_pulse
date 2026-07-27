# PULSE — Design System

## Visual intent

PULSE uses a restrained enterprise visual language focused on operational clarity, dense information and predictable interaction.

## Core palette

| Token | Value | Use |
|---|---|---|
| Navigation | `#07111F` | Main navigation and dark shell surfaces |
| Navigation secondary | `#0F172A` | Secondary dark surfaces and primary text |
| Surface | `#FFFFFF` | Cards and working surfaces |
| Background | `#F6F8FB` | Application background |
| Border | `#E2E8F0` | Card, panel and table boundaries |
| Text | `#0F172A` | Primary content |
| Muted text | `#64748B` | Supporting content |
| Pulse blue | `#1677FF` | Primary action and information |
| Pulse purple | `#6B2C7A` | Brand accent |
| Success | `#16A34A` | Completed and healthy states |
| Warning | `#D97706` | Attention and emerging risk |
| Danger | `#DC2626` | Failure and critical risk |

## Spacing

Use a four-pixel base grid.

- 4 px: micro spacing.
- 8 px: internal compact spacing.
- 12 px: related-control spacing.
- 16 px: standard card padding.
- 24 px: section separation.
- 32 px: major page separation.

## Radius

- 9–10 px: buttons and compact controls.
- 12–14 px: alerts and KPI cards.
- 16–18 px: dashboard panels.

Do not add radius properties to controls that do not support them. Prefer `GroupContainer@1.5.0` or `Classic/Button@2.2.0` when exact radius control is required.

## Typography

- Screen title: 22–24 px, semibold.
- Section title: 16–18 px, semibold.
- Card title: 11–14 px, semibold.
- KPI value: 20–24 px, bold.
- Body: 9–11 px.
- Metadata: 8–9 px.

## Component behavior

- Cards use a one-pixel border and no heavy shadow.
- Clickable cards use a transparent classic button overlay.
- Status is communicated with both color and text.
- Empty states always provide a concrete next action when recovery is possible.
- Loading states should replace content without shifting the page layout.
- Responsive behavior is controlled by parent width rather than fixed screen resolution.
