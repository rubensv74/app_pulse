# OPDS-C02 — dependency preflight and contract gate

## Capability

**Capability:** OPDS-C02 — report snapshot workspace  
**Risk:** B  
**Runtime baseline:** `baseline_pulse_1_0_0_5.zip`  
**Baseline date:** 2026-08-15  
**Readiness result:** `GATED` for real empty-state classification; independent loaded/error work remains technically possible but full C02 is not ready for one meaningful runtime validation.

## Objective

Connect `scr_Overview_PDS` to the existing Overview flows without changing `scr_Overview`, and map each real outcome to exactly one state:

- `READY`
- `NO_CONFIGURATION`
- `NO_DATA`
- `ERROR`

No classification may depend on `FirstError.Message`, translated connector messages, substring searches or other free text.

## Runtime dependencies confirmed

| Dependency | Evidence | Status |
|---|---|---|
| `scr_Overview_PDS.pa.yaml` | Present in the exported Canvas App | `CONFIRMED_IN_RUNTIME_SOURCE` |
| `warroom_GenerateOverviewSnapshot` | Present in Canvas data sources and solution workflows | `CONFIRMED_IN_RUNTIME_SOURCE` |
| `Warroom_GetOverviewSnapshot` | Present in Canvas data sources and solution workflows | `CONFIRMED_IN_RUNTIME_SOURCE` |
| `warroom.usp_GenerateOverviewSnapshot` | Executed by the Generate flow | `CONFIRMED_IN_RUNTIME_SOURCE` |
| `warroom.usp_GetOverviewSnapshot` | Executed by the Get flow | `CONFIRMED_IN_RUNTIME_SOURCE` |
| Existing functional reference | `scr_Overview.pa.yaml` uses both flows | `CONFIRMED_IN_RUNTIME_SOURCE` |

## Verified input contracts

### Generate

```text
warroom_GenerateOverviewSnapshot(ProjectId)
```

### Get

```text
Warroom_GetOverviewSnapshot(
    ProjectId,
    SearchSubsystem,
    PageNumber,
    PageSize
)
```

The parameter order agrees with the approved strategy and the current `scr_Overview` implementation.

## Verified output contract

`Warroom_GetOverviewSnapshot` always builds a successful JSON payload with this shape:

```json
{
  "subsystems": [],
  "headers": [],
  "metrics": [],
  "totalCount": 0,
  "generatedOn": ""
}
```

The arrays and values may contain data, but the contract exposes no stable field describing the business outcome.

It does **not** expose a field such as:

```json
{
  "statusCode": "READY | NO_CONFIGURATION | NO_DATA",
  "configurationExists": true,
  "dataExists": true
}
```

## Gate

An empty successful payload can currently mean more than one business situation:

1. the project has no published report configuration;
2. the project has a valid published configuration but no subsystem/report data;
3. the stored procedure returned no result row and the flow normalized it to empty arrays.

Therefore the consumer cannot distinguish `NO_CONFIGURATION` from `NO_DATA` reliably.

### Prohibited workaround

Do not classify the result by:

- reading `FirstError.Message`;
- searching for words such as “configuration” or “data”;
- interpreting translated connector or SQL messages;
- assuming that `headers = []` always means no configuration;
- assuming that `subsystems = []` always means no data.

Those rules would convert an ambiguous producer response into a false business fact.

## Minimum contract change required

The producer must return one stable structured discriminator. Recommended minimum:

```json
{
  "statusCode": "READY | NO_CONFIGURATION | NO_DATA",
  "subsystems": [],
  "headers": [],
  "metrics": [],
  "totalCount": 0,
  "generatedOn": ""
}
```

The stored procedure should own the semantic classification. Power Automate should transmit the code unchanged, and Power Apps should map it directly to one visual state.

A separate human-readable `message` may be included for display, but it must not drive classification.

## Validation status

| Criterion | Result | Reason |
|---|---|---|
| Runtime screen baseline available | `PASS` | Source present in the exported app |
| Generate/Get dependencies present | `PASS` | Flow definitions and bindings inspected |
| Input parameters aligned | `PASS` | Existing screen and workflow definitions agree |
| Loaded outcome structurally detectable | `PASS` | Non-empty structured collections can be consumed |
| Genuine connector failure detectable | `PASS` | Power Fx can use `IfError` without parsing message text |
| No-configuration detectable | `GATED` | Missing structured producer discriminator |
| No-data detectable independently | `GATED` | Empty payload is ambiguous |
| Complete C02 runtime validation | `GATED` | Mandatory outcomes cannot be classified mutually exclusively |

These are static contract results. No real project scenario has been executed by this preflight.

## Decision needed at the gate

Approve a separate contract change to:

1. update `warroom.usp_GetOverviewSnapshot` so it returns a stable outcome code;
2. pass that code through `Warroom_GetOverviewSnapshot`;
3. update `scr_Overview_PDS` to map the code to its real state surfaces;
4. validate the complete C02 package once in Studio/runtime.

Until that decision is taken:

- do not modify `scr_Overview`;
- do not connect synthetic C01 states to guessed conditions;
- do not claim `NO_CONFIGURATION` or `NO_DATA` as demonstrated;
- keep `scr_Overview_PDS` as the isolated premium candidate.
