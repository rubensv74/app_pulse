from pathlib import Path
import yaml
path = Path(r'power-platform/working-baselines/1.0.0.2/canvas-source/new_pulse_9584c/Src/scr_Home_1.pa.yaml')
with path.open('r', encoding='utf-8') as f:
    data = yaml.safe_load(f)

screen = data['Screens']['scr_Home_1']
children = screen.get('Children', [])
print('child_count', len(children))
for item in children:
    for name, cfg in item.items():
        print(name, '->', cfg.get('Control'))
