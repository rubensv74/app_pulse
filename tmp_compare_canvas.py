from pathlib import Path
import difflib
files=[('home',Path(r'power-platform/working-baselines/1.0.0.2/canvas-source/new_pulse_9584c/Src/scr_Home_1.pa.yaml'),Path(r'C:/Temp/pulse-canvas-verify/unpacked-msapp/Src/scr_Home_1.pa.yaml')),('punches',Path(r'power-platform/working-baselines/1.0.0.2/canvas-source/new_pulse_9584c/Src/scr_Punches_1.pa.yaml'),Path(r'C:/Temp/pulse-canvas-verify/unpacked-msapp/Src/scr_Punches_1.pa.yaml'))]
for name,a,b in files:
    ta=a.read_text(encoding='utf-8')
    tb=b.read_text(encoding='utf-8')
    print(name, 'same=', ta==tb, 'len_a=', len(ta), 'len_b=', len(tb))
    if ta!=tb:
        diff=list(difflib.unified_diff(ta.splitlines(), tb.splitlines(), fromfile=str(a), tofile=str(b), n=2))
        print('diff_lines=', len(diff))
        print('\n'.join(diff[:120]))
