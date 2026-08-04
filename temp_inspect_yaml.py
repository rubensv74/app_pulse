import yaml, json
from pathlib import Path
path = Path(r'C:\GitHub\app_pulse\power-platform\working-baselines\1.0.0.2\canvas-source\new_pulse_9584c\Src\scr_Home_1.pa.yaml')
text = path.read_text(encoding='utf-8')
print('len', len(text))
obj = yaml.safe_load(text)
print(type(obj).__name__)
if isinstance(obj, dict):
    print('keys', list(obj.keys())[:20])
    for k,v in list(obj.items())[:5]:
        print('KEY',k,'TYPE',type(v).__name__)
        if isinstance(v, dict):
            print('subkeys', list(v.keys())[:10])
            if 'Children' in v:
                print('Children len', len(v['Children']))
                print('First child type', type(v['Children'][0]).__name__)
