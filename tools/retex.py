# Writes the Night City material overrides (mod/materials/<path>.vmt) for the stage map's textures.
import re, struct, sys
from pathlib import Path
f = open('C:/Games/portal2/portal2/maps/sp_a2_catapult_intro.bsp', 'rb').read()
off, ln, _, _ = struct.unpack('<iiii', f[8 + 43 * 16:8 + 43 * 16 + 16])
names = sorted(set(x.decode().lower() for x in f[off:off + ln].split(b'\0') if x))
names = [n for n in names if not n.startswith(('maps/', 'tools/', 'dev/', 'overlays/', 'signage/', 'effects/'))]
vmtdir = Path('gen/vmt')
out = Path('mod/materials')

def pick(n):
    if 'light_panel' in n: return 'light'
    if 'ceiling' in n or 'tileceiling' in n: return 'ceil'
    if 'floor' in n or 'dirtfloor' in n or 'carpet' in n: return 'floor'
    if n.startswith('tile/') : return 'wall_a'
    if n.startswith('metal/black_wall') or 'metalwall' in n or 'metalhull' in n: return 'wall_b'
    if n.startswith(('concrete/', 'plastic/', 'props/', 'anim_wp/')): return 'wall_b'
    return None

TPL = '''LightmappedGeneric
{{
$basetexture "sigf/{tex}"
$surfaceprop {sp}
$basetexturetransform "center .5 .5 scale {sc} {sc} rotate 0 translate 0 0"
{extra}"%keywords" "portal2 chamber"
}}
'''
done = 0
for n in names:
    k = pick(n)
    src = vmtdir / (n.replace('/', '__') + '.vmt')
    if k is None or not src.exists(): 
        print('skip', n); continue
    t = src.read_text()
    p = out / (n + '.vmt')
    p.parent.mkdir(parents=True, exist_ok=True)
    if k == 'light':
        col = '[1.0 0.15 0.85]' if 'cool' in n else '[0.1 0.9 1.0]'
        t = re.sub(r'\}\s*$', '$color "%s"\n}\n' % col, t.strip())
        p.write_text(t); done += 1; continue
    m = re.search(r'\$surfaceprop\s+"?(\w+)"?', t, re.I)
    sp = m.group(1) if m else 'metal'
    extra = '"%noportal" 1\n' if '%noportal' in t else ''
    # the map's vertex-blended / lightmapped surfaces keep their flags
    if re.search(r'\$translucent|\$alphatest', t): extra += ''
    p.write_text(TPL.format(tex=k, sp=sp, extra=extra, sc={'wall_a':0.5,'wall_b':0.5,'floor':0.5,'ceil':0.5}[k]))
    done += 1
print(done, 'materials')
