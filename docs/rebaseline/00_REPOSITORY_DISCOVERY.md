# Repository discovery

- Repository: `app_pulse`
- Path: `C:\GitHub\app_pulse`
- Remote: `https://github.com/rubensv74/app_pulse.git`
- Branch: `fix/punch-export-filter-audit`
- Initial commit: `76172be1a778d95fd03b305463dbe32b94e18040`
- Initial status: clean; upstream `origin/fix/punch-export-filter-audit`, ahead 0, behind 0.
- Files: 473 tracked, 0 modified, 0 staged, 0 untracked, 20 ignored.
- Approximate workspace size: 142,345,426 bytes.
- Local branches: `feature/excel-import-i01-1`, `fix/i01-1-flow-clientdata`, `fix/punch-export-filter-audit`, `main`.
- Remote branches: the same four branches under `origin`.
- Tags at discovery: none.
- Submodule/LFS query: inconclusive because Git's auxiliary `sh.exe` could not create its signal pipe (Win32 error 5). No `.gitmodules` or LFS pointer evidence was found in the inventory.

## Tools

| Tool | Result |
|---|---|
| Git | 2.55.0.windows.2 |
| PowerShell | 5.1.22621.6931 |
| PAC CLI | Not found |
| `pac solution unpack` | Not available; not executed |
| Python | Store alias only; runtime unavailable |
| Node.js | Not found |
| 7-Zip | Not found |
| Windows ZIP support | Available through `Microsoft.PowerShell.Archive` / .NET |

## Risks and recommendation

PAC CLI is unavailable, so no official unpack can be attempted. ZIP physical inspection is possible with PowerShell. Existing ignored build outputs contain two generated `pulse.zip` files and must not be confused with the incoming baseline. Continue only through ZIP audit gate.
