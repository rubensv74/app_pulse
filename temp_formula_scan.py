from pathlib import Path
import re
path = Path(r'C:\GitHub\app_pulse\power-platform\working-baselines\1.0.0.2\canvas-source\new_pulse_9584c\Src\scr_Home_1.pa.yaml')
lines = path.read_text(encoding='utf-8', errors='replace').splitlines()
stack = []
for idx, line in enumerate(lines, 1):
    m = re.match(r'^(?P<indent>\s*)-\s+(?P<name>[A-Za-z0-9_\.]+):\s*$', line)
    if m:
        indent = len(m.group('indent'))
        while stack and stack[-1][0] >= indent:
            stack.pop()
        name = m.group('name')
        stack.append((indent, name))
        continue
    m = re.match(r'^(?P<indent>\s*)(?P<prop>[A-Za-z0-9_]+):\s*(?P<value>\|[+-]?|>[-+]?)\s*$', line)
    if m and stack:
        indent = len(m.group('indent'))
        prop = m.group('prop')
        # collect following indented lines until dedent
        content_lines = []
        for k in range(idx, len(lines)):
            l = lines[k]
            if k == idx - 1:
                continue
            if not l.strip():
                content_lines.append('')
                continue
            if len(l) - len(l.lstrip(' ')) <= indent:
                break
            content_lines.append(l)
        content = '\n'.join(content_lines)
        if len(content) > 1000:
            print(f'{len(content)}\t{stack[-1][1]}\t{prop}')
