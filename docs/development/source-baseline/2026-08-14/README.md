# PULSE Source Baseline — 2026-08-14

This directory preserves the complete user-supplied Power Apps source baseline captured on 2026-08-14.

The archive is split into Base64 text parts so it can be stored reliably through the repository connector without rewriting or truncating the large screen sources.

## Parts

```text
PULSE_SOURCE_BASELINE_2026-08-14.tar.xz.b64.part001
PULSE_SOURCE_BASELINE_2026-08-14.tar.xz.b64.part002
PULSE_SOURCE_BASELINE_2026-08-14.tar.xz.b64.part003
PULSE_SOURCE_BASELINE_2026-08-14.tar.xz.b64.part004
PULSE_SOURCE_BASELINE_2026-08-14.tar.xz.b64.part005
PULSE_SOURCE_BASELINE_2026-08-14.tar.xz.b64.part006
PULSE_SOURCE_BASELINE_2026-08-14.tar.xz.b64.part007
PULSE_SOURCE_BASELINE_2026-08-14.tar.xz.b64.part008
```

## Reconstruct — PowerShell

Run from this directory:

```powershell
$parts = Get-ChildItem ".\PULSE_SOURCE_BASELINE_2026-08-14.tar.xz.b64.part*" |
    Sort-Object Name

$b64 = ($parts | ForEach-Object { Get-Content $_.FullName -Raw }) -join ""

[IO.File]::WriteAllBytes(
    ".\PULSE_SOURCE_BASELINE_2026-08-14.tar.xz",
    [Convert]::FromBase64String($b64)
)

tar -xJf ".\PULSE_SOURCE_BASELINE_2026-08-14.tar.xz"
```

## Reconstruct — shell

```bash
cat PULSE_SOURCE_BASELINE_2026-08-14.tar.xz.b64.part* \
  | base64 --decode \
  > PULSE_SOURCE_BASELINE_2026-08-14.tar.xz

tar -xJf PULSE_SOURCE_BASELINE_2026-08-14.tar.xz
```

## Integrity

Concatenated Base64 SHA-256:

```text
f7ae116505ca63f9c98cf4787fb710f01cdec0ed96976809033578d32b6c0431
```

Decoded archive SHA-256:

```text
2064e9d7ad1f8af4804b429d4b2d3fd461d2b42a24076599b4e218011fce3cd9
```

The per-file hashes and baseline semantics are documented in:

`docs/development/app/PULSE_SOURCE_BASELINE_2026-08-14.md`

## Important

This is a preservation baseline, not proof that the supplied sources have passed Power Apps Studio validation in this session.

Canonical source promotion remains subject to the validation gates defined by the incremental-architecture framework.
