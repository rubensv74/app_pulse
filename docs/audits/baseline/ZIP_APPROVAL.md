FAIL — ZIP NOT ELIGIBLE FOR REBASELINE

# Decision

The preserved ZIP is physically intact and is a valid Unmanaged Power Platform solution, but it does not meet the strict eligibility criteria.

Critical reasons: 71 external flow references cannot be traced from the package; `Warroom_ExportPunchesToExcel` is absent; four referenced connection references are not packaged; the Canvas App differs from the repository copy; and three unexpected residual-looking artifacts are unexplained.

Minimum manual next step: in Power Platform DEV, verify the intended solution membership with the solution owner, add/export every required flow and connection reference (or supply an approved external-dependency contract), remove or explicitly approve residual artifacts, then export a fresh Unmanaged PULSE solution ZIP. Place exactly one new candidate in `baseline/incoming/` and rerun this physical audit. Do not run the official unpack before a PASS.

No official unpack has been executed. No import, deployment, publication, cleanup, or solution modification was performed.
