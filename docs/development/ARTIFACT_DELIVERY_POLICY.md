# PULSE — Artifact Delivery Policy

## Mandatory rule

Every generated implementation artifact that the user must open, copy, paste, review or reuse must be stored in the `app_pulse` repository before it is delivered in chat.

The response must include a direct GitHub link to the repository file.

This applies to:

- Power Apps `.pa.yaml` blocks;
- `.property-guide.md` files;
- Power Fx replacement guides;
- SQL / PowerShell scripts;
- implementation contracts;
- test seeds;
- implementation and validation documentation.

## Delivery priority

1. Repository file is the canonical artifact.
2. Direct GitHub `blob/main/...` link is the primary delivery mechanism.
3. `sandbox:/...` links are not used as the primary handoff when the repository is available.
4. A local/download copy may only be supplemental.
5. If repository publication is technically impossible, state that explicitly before offering a temporary alternative.

## Power Apps incremental construction

For every future block:

- consult the current modular Power Apps construction playbook;
- consult the current Source Code compatibility register before YAML;
- create/update the artifact in the repository;
- provide the exact target and operation;
- provide the direct repository link;
- wait for Power Apps Studio validation before freezing the block.

This delivery rule does not change Studio-first validation. GitHub is the stable handoff and source-of-truth location for generated artifacts; Power Apps Studio remains the implementation and validation environment.