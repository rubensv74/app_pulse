# ZIP regression audit

## Conclusion

**FAIL**

## Incident

The imported solution package contained an obsolete Canvas App and was capable
of overwriting a substantially newer PULSE application. No Power Platform
solution ZIP currently present in the repository is authorized for import.

## Imported/packaged Canvas App

- Package:
  `power-platform/build/PULSE/dist/PULSE_I01_1_unmanaged.zip`
- Package SHA-256:
  `CCF75ED2088E248AE5D778ACACD50AE8D75F9069AF78291284A910D17C5B7233`
- Solution version: `1.0.0.0`
- Packaged AppVersion: `2026-06-19T10:35:15Z`
- Packaged client version: `3.26062.6.0`
- Packaged `.msapp` SHA-256:
  `648A8D87C246BFB6BA8B482D6C0F7AEF94D173DBC22C538627A2F6C4333E730F`
- Packaged `.msapp` entries: 37
- Packaged binding errors: 58
- Packaged Workflows: 3

## Newer repository Canvas App

- File:
  `power-platform/solutions/PULSE/CanvasApps/new_pulse_9584c_DocumentUri.msapp`
- Metadata:
  `power-platform/solutions/PULSE/CanvasApps/new_pulse_9584c.meta.xml`
- AppVersion: `2026-07-29T11:28:11Z`
- Client version: `3.26072.8.0`
- `.msapp` SHA-256:
  `6A2E31105E903BAE401E4A5F779B8A97CB65F38210D0C34759329EC14B31669B`
- `.msapp` entries: 97
- Parser errors: 0
- Binding errors: 17

The packaged app predates the repository app by approximately 40 days and the
two `.msapp` binaries are materially different. The obsolete build contains 60
fewer archive entries and more than three times as many recorded binding
errors.

## Unsafe solution artifacts

The following physical ZIP files must not be imported:

| ZIP | SHA-256 | Reason |
|---|---|---|
| `power-platform/build/PULSE/dist/PULSE_I01_1_unmanaged.zip` | `CCF75ED2088E248AE5D778ACACD50AE8D75F9069AF78291284A910D17C5B7233` | Contains the obsolete 2026-06-19 Canvas App and three Workflows |
| `power-platform/build/PULSE/pulse/bin/Release/pulse.zip` | `EA637C27F5376593E475B006AF7E7EEDEEC47D0343A4529D77C66540AF126D95` | Contains the same obsolete Canvas App and three Workflows |
| `power-platform/build/PULSE_I01_1_app_update/pulse/bin/Release/pulse.zip` | `EA637C27F5376593E475B006AF7E7EEDEEC47D0343A4529D77C66540AF126D95` | Byte-identical stale copy; it is not the intended minimal build |

The two `EA637...` packages are byte-identical. The artifact under the
`PULSE_I01_1_app_update` project was copied with the build tree and was not
regenerated after the project was scoped down. A failed NuGet restore left that
stale binary in place.

## Root cause

1. The build project used an old `.msapp` exported on 2026-06-19.
2. A newer `.msapp` existed in the repository but was not synchronized into
   the package source before packing.
3. Package verification checked structure and JSON encoding but initially did
   not enforce Canvas App freshness against the canonical app artifact or the
   target environment.
4. The copied build tree retained a stale `bin/Release/pulse.zip`, which could
   be mistaken for a newly generated minimal package.

## Mandatory controls before any replacement ZIP

1. Export the current/recovered target Canvas App and retain its `.msapp`,
   AppVersion, modification timestamp and SHA-256.
2. Establish which artifact is the recovery baseline. The repository
   `2026-07-29` app is newer than the regressed package but cannot by itself
   prove that it matches the latest pre-regression environment version.
3. Start the build output from an empty `bin`/`obj` or a new clean staging
   directory; never copy build outputs into a new package project.
4. Package only the explicitly approved root components.
5. Extract the final ZIP and verify the embedded `.msapp` SHA-256 exactly
   matches the approved recovery baseline.
6. Fail the audit if the final ZIP includes any unexpected Workflow, Canvas
   App, connection reference or other solution component.
7. Perform the first import in a non-production environment and retain the
   import report, App Checker result and functional smoke-test evidence.

Until these controls pass, replacement import authorization remains denied.
