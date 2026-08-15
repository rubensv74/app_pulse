# OPDS-C01 — premium shell and visual state surfaces

## Capability contract

| Field | Decision |
|---|---|
| Objective | Create an independent premium Overview candidate whose six planned presentation states can be reviewed without connecting Overview data. |
| Risk | B — reversible Power Apps screen behavior and component integration; no persistence or external contract changes. |
| Scope | New `scr_Overview_PDS`, PULSE shell, Sidebar host, premium header host, local visual-state selector, loading, no-project, no-configuration, no-data, error and ready surfaces. |
| Out of scope | `scr_Overview`, operational navigation, Overview flows, response classification, SQL, Power Automate and real project-state evidence. |
| Manual validation budget | One grouped Studio round-trip; one consolidated FIX round-trip only if the first validation finds a material defect. |
| Engineering state before Studio | `CANDIDATE`; the six surfaces are `VISUAL_PREPARED`. |

## First-touch baseline and dependencies

The current complete `scr_Overview` source is archived on `main` at
`power-apps/screens/Overview/scr_Overview.pa.yaml`. It remains the functional reference
and is not a target of this capability.

Relevant application initialization is present in the repository:

- PULSE theme variables;
- active project variables;
- `colSidebarNavItems`;
- `varUserRole`.

No Overview flow is a C01 dependency because this capability deliberately stops at
visual preparation.

## Component readiness

| Dependency | Repository evidence | Runtime evidence available | C01 decision |
|---|---|---|---|
| `cmp_SidebarNav` | Complete component source and several existing consumers | First C01 validation: body rendered, but default `Text` values remained because bindings were not applied | Keep reuse; configure its exposed public inputs in the consolidated FIX. |
| `cmp_PageHeaderPro` | Complete component source and documented public contract | First C01 validation reproduced blank host hydration after manual insertion | Localized reuse gate: remove the instance from C01 and use a screen-native premium header. Do not alter the reusable component. |
| `cmp_EmptyState` | Definition exists | No sufficient host-specific instance evidence was found for this capability | Do not gate C01 on it; use screen-native state surfaces. Reconsider after visual stabilization and a reusable contract decision. |
| `cmp_SkeletonLoader` | Definition exists | Existing consumer found, but no separate current host validation for Overview PDS | Do not gate C01 on it; use a screen-native loading surface. |

The first grouped validation exhausted the safe reuse attempt. The consolidated FIX
uses one manual Sidebar insertion and a source-native header; no further component
microtests are authorized inside C01.

## Acceptance plan

All criteria are required for complete C01 acceptance.

| ID | Required result | Evidence needed |
|---|---|---|
| C01-A01 | `scr_Overview_PDS` exists independently and `scr_Overview` remains unchanged | Studio tree plus comparison with the existing screen. |
| C01-A02 | `cmp_SidebarNav` renders through its public contract and the native premium header renders inside its stable host | Studio render, save/reopen and App Checker. |
| C01-A03 | Each of the six selector actions shows its intended visual surface | Grouped Studio walkthrough. |
| C01-A04 | Exactly one surface is visible at a time | Visual walkthrough plus inspection of the six equality-based `Visible` formulas. |
| C01-A05 | Shell, hierarchy, texts, actions and prepared content are visually usable at 1600×900 | Screenshot evidence and visual review. |
| C01-A06 | No Overview flow executes and no real response is classified | Source inspection and absence of runtime flow activity attributable to C01. |
| C01-A07 | Operational navigation, SQL and Power Automate remain unchanged | Repository diff and Studio navigation check. |

Before Studio, none of these runtime criteria is `PASS`. Static inspection only makes
the package ready for the grouped validation.

## Rollback

Delete only the new `scr_Overview_PDS` screen. No operational route points to it and
the current `scr_Overview` remains the fallback.

## Readiness conclusion

After the first Studio validation: `READY_WITH_ASSUMPTIONS` for the consolidated FIX.

- the source package is statically coherent;
- the Sidebar body renders and its public inputs are available for configuration;
- the failed Page Header reuse path has been removed from the capability;
- no remote contract is required;
- the remaining assumption is Studio acceptance/rendering of the complete candidate,
  which is exactly the second and final planned Studio validation after one FIX batch.
