# PULSE baseline ZIP re-audit — intake report

## Result

`FAIL — ZIP NOT ELIGIBLE FOR REBASELINE`

The mandatory intake gate failed before preservation or extraction.

Expected candidate:

`baseline/incoming/baseline_pulse_DEV_unmanaged_1_0_0_2_20260731.zip`

The expected path does not exist. Two ZIP files are physically present in `baseline/incoming/`:

| File | Bytes | Modified UTC | Git state | SHA-256 | Classification |
|---|---:|---|---|---|---|
| `baseline_pulse_1_0_0_1.zip` | 4,924,908 | `2026-07-31T10:07:04.8360380Z` | tracked | `C80249D24ECAA1BDF646595B00C2B8E951C4C8AB9825CA7DE5D7233B9D48B375` | Previous rejected evidence; not reused |
| `baseline_pulse_1_0_0_2.zip` | 5,033,101 | `2026-07-31T10:43:12.5869467Z` | untracked | `7E7646877DB8DF38CFCB5C2BF7896C598C4E772A1E2F667ACFDD9134C3959D77` | Ambiguous/unconfirmed file; name differs from the declared candidate |

No ZIP was copied, extracted, renamed, overwritten, or modified during this re-audit. The previous preserved evidence at `baseline/exported/2026-07-31/baseline_pulse_1_0_0_1.zip` remains untouched.

Minimum manual next step: place the intended export at the exact declared path and leave exactly one candidate ZIP in `baseline/incoming/`. Move the rejected `1.0.0.1` source out of `incoming` only through an explicitly authorized evidence-preserving operation; its preserved copy must remain untouched. Then rerun the re-audit.
