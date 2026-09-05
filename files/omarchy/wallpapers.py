#!/usr/bin/env python3
"""Backgrounds for the Dark Winden themes, drawn rather than downloaded.

Three scenes from the Netflix series, as flat vector art: the cave passage, the
Sic Mundus emblem, and the Winden power plant behind the pine forest. Each is
emitted as SVG, rasterised at 4K with rsvg-convert, then encoded to JPEG --
13 MB of PNG for 1.8 MB of visually identical JPEG, in a repo that is otherwise
640 KB of text. The omarchy.* background stays PNG: it is flat colour and 30 KB.

Nothing at install time runs this; `after/08-themes` copies the committed
output. It exists so the palettes stay tunable -- edit the colours at the
bottom, re-run, commit the result:

    ./files/omarchy/wallpapers.py

Requires rsvg-convert (librsvg) and magick (imagemagick), both already present
on an Omarchy install.
"""
import math, os, random, shutil, subprocess, tempfile

W, H = 3840, 2160
OUT = os.path.dirname(os.path.abspath(__file__))

def hx(c):
    c = c.lstrip('#')
    return tuple(int(c[i:i+2], 16) for i in (0, 2, 4))

def mix(a, b, t):
    ra, rb = hx(a), hx(b)
    return '#%02x%02x%02x' % tuple(round(ra[i] + (rb[i] - ra[i]) * t) for i in range(3))

def wrap(body, defs=""):
    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" '
            f'viewBox="0 0 {W} {H}">\n<defs>{defs}</defs>\n{body}\n</svg>\n')

GRAIN = '''
<filter id="grain" x="0" y="0" width="100%" height="100%">
  <feTurbulence type="fractalNoise" baseFrequency="0.9" numOctaves="3" seed="17" result="n"/>
  <feColorMatrix in="n" type="saturate" values="0"/>
</filter>
<filter id="glow" x="-80%" y="-80%" width="260%" height="260%">
  <feGaussianBlur stdDeviation="46"/>
</filter>
<filter id="softglow" x="-60%" y="-60%" width="220%" height="220%">
  <feGaussianBlur stdDeviation="14"/>
</filter>
<filter id="fog" x="-20%" y="-20%" width="140%" height="140%">
  <feGaussianBlur stdDeviation="90"/>
</filter>
'''

def grain_layer(op=0.055, mode="overlay"):
    return (f'<rect width="{W}" height="{H}" filter="url(#grain)" '
            f'opacity="{op}" style="mix-blend-mode:{mode}"/>')

# ---------------------------------------------------------------- the passage
def ramp(outer, mid, inner, t):
    return mix(outer, mid, t / 0.55) if t < 0.55 else mix(mid, inner, (t - 0.55) / 0.45)

def passage(path, outer, mid, inner, glow, silhouette, dust, vignette):
    """Nested irregular arches receding into a glowing throat."""
    rnd = random.Random(4)
    cx, cy = W * 0.5, H * 0.60
    rings = 13
    body = [f'<rect width="{W}" height="{H}" fill="url(#bgrad)"/>']
    # deep glow behind the throat
    body.append(f'<ellipse cx="{cx}" cy="{cy}" rx="360" ry="300" fill="{glow}" '
                f'opacity="0.55" filter="url(#glow)"/>')
    for i in range(rings):
        t = i / (rings - 1.0)                      # 0 outer -> 1 inner
        scale = 1.0 - 0.93 * (t ** 0.72)
        rx, ry = 1420 * scale, 1210 * scale
        oy = cy - 40 * (1 - scale)
        col = ramp(outer, mid, inner, t ** 1.25)
        pts = []
        n = 88
        wob = 0.085 * (1 - t * 0.5)
        for k in range(n):
            a = 2 * math.pi * k / n
            r = (1 + wob * (math.sin(a * 3 + i * 1.7) * 0.6
                            + math.sin(a * 7 + i * 2.9) * 0.28
                            + rnd.uniform(-0.22, 0.22)))
            # squash the floor flat-ish
            fy = 1.0 if math.sin(a) < 0 else 0.86
            pts.append((cx + rx * r * math.cos(a),
                        oy + ry * r * fy * math.sin(a)))
        d = 'M' + ' L'.join(f'{x:.1f},{y:.1f}' for x, y in pts) + ' Z'
        body.append(f'<path d="{d}" fill="{col}"/>')
    # throat light
    body.append(f'<ellipse cx="{cx}" cy="{cy - 34}" rx="150" ry="112" fill="{inner}" '
                f'opacity="0.9" filter="url(#softglow)"/>')
    if dust:
        for _ in range(260):
            x = rnd.gauss(cx, W * 0.19)
            y = rnd.gauss(cy, H * 0.22)
            r = rnd.uniform(1.4, 5.2)
            o = rnd.uniform(0.05, 0.38)
            body.append(f'<circle cx="{x:.0f}" cy="{y:.0f}" r="{r:.1f}" '
                        f'fill="{glow}" opacity="{o:.2f}"/>')
    if silhouette:
        # lone figure at the mouth of the light
        sx, sy, s = cx + 18, cy + 178, 1.0
        fig = (f'<g fill="{silhouette}" transform="translate({sx},{sy}) scale({s})">'
               f'<circle cx="0" cy="-152" r="21"/>'
               f'<path d="M-27,-126 q27,-16 54,0 l9,74 -14,4 6,60 -12,2 -10,-56 '
               f'-8,56 -13,-2 5,-60 -14,-4 z"/>'
               f'</g>')
        body.append(fig)
    body.append(f'<rect width="{W}" height="{H}" fill="url(#vig)" opacity="{vignette}"/>')
    body.append(grain_layer(0.05))
    defs = GRAIN + f'''
    <radialGradient id="bgrad" cx="50%" cy="58%" r="78%">
      <stop offset="0%" stop-color="{mix(outer, glow, 0.30)}"/>
      <stop offset="60%" stop-color="{outer}"/>
      <stop offset="100%" stop-color="{mix(outer, '#000000', 0.45) if vignette else outer}"/>
    </radialGradient>
    <radialGradient id="vig" cx="50%" cy="58%" r="72%">
      <stop offset="45%" stop-color="#000000" stop-opacity="0"/>
      <stop offset="100%" stop-color="#000000" stop-opacity="1"/>
    </radialGradient>'''
    open(path, 'w').write(wrap('\n'.join(body), defs))

# ---------------------------------------------------------------- sic mundus
def emblem(path, bg, bg2, ink, glow_col, text_col, glowing):
    cx, cy = W * 0.5, H * 0.455
    R = 470
    sw = 15
    # triquetra: three vesica arcs around the centre
    def arc_lobe(angle):
        a = math.radians(angle)
        r = R * 0.62
        ox, oy = cx + r * math.cos(a), cy + r * math.sin(a)
        return f'<circle cx="{ox:.1f}" cy="{oy:.1f}" r="{R*0.62:.1f}"/>'
    lobes = ''.join(arc_lobe(a) for a in (-90, 30, 150))
    knot = (f'<g fill="none" stroke="{ink}" stroke-width="{sw}" '
            f'stroke-linecap="round">{lobes}'
            f'<circle cx="{cx}" cy="{cy}" r="{R}"/>'
            f'<circle cx="{cx}" cy="{cy}" r="{R*0.985:.1f}" stroke-width="3" opacity="0.5"/>'
            f'</g>')
    body = [f'<rect width="{W}" height="{H}" fill="url(#bgrad)"/>']
    if glowing:
        body.append(f'<g opacity="0.5" filter="url(#glow)">{knot.replace(ink, glow_col)}</g>')
        body.append(f'<circle cx="{cx}" cy="{cy}" r="{R*0.9:.0f}" fill="{glow_col}" '
                    f'opacity="0.10" filter="url(#glow)"/>')
    body.append(knot)
    body.append(
        f'<text x="{cx}" y="{cy + R + 330}" text-anchor="middle" fill="{text_col}" '
        f'font-family="Liberation Serif, serif" font-size="104" letter-spacing="26" '
        f'opacity="0.92">SIC MUNDVS CREATVS EST</text>')
    body.append(
        f'<text x="{cx}" y="{cy + R + 452}" text-anchor="middle" fill="{text_col}" '
        f'font-family="Liberation Serif, serif" font-size="46" letter-spacing="18" '
        f'opacity="0.55">DER ANFANG IST DAS ENDE</text>')
    body.append(f'<rect width="{W}" height="{H}" fill="url(#vig)"/>')
    body.append(grain_layer(0.06))
    defs = GRAIN + f'''
    <radialGradient id="bgrad" cx="50%" cy="45%" r="80%">
      <stop offset="0%" stop-color="{bg2}"/>
      <stop offset="100%" stop-color="{bg}"/>
    </radialGradient>
    <radialGradient id="vig" cx="50%" cy="45%" r="70%">
      <stop offset="40%" stop-color="#000000" stop-opacity="0"/>
      <stop offset="100%" stop-color="#000000" stop-opacity="{0.42 if glowing else 0.10}"/>
    </radialGradient>'''
    open(path, 'w').write(wrap('\n'.join(body), defs))

# ---------------------------------------------------------------- winden
def tower(cx, base, w, h, waist=0.62, throat=0.78):
    """Hyperboloid cooling-tower silhouette."""
    top = base - h
    bw, tw = w / 2, w / 2 * throat
    mw = w / 2 * waist
    return (f'M{cx-bw:.0f},{base:.0f} '
            f'C{cx-bw:.0f},{base-h*0.45:.0f} {cx-mw:.0f},{base-h*0.55:.0f} {cx-tw:.0f},{top:.0f} '
            f'L{cx+tw:.0f},{top:.0f} '
            f'C{cx+mw:.0f},{base-h*0.55:.0f} {cx+bw:.0f},{base-h*0.45:.0f} {cx+bw:.0f},{base:.0f} Z')

def treeline(y, height, spread, seed, wob=1.0):
    """Overlapping tapered firs sitting on a solid ground band."""
    rnd = random.Random(seed)
    parts = [f'M-200,{H+200:.0f} L-200,{y+height*0.05:.0f} '
             f'L{W+200},{y+height*0.05:.0f} L{W+200},{H+200:.0f} Z']
    x = -240
    while x < W + 240:
        w = spread * rnd.uniform(0.5, 1.25)
        h = height * rnd.uniform(0.6, 1.5) * wob
        base = y + height * 0.18 + rnd.uniform(-height * 0.06, height * 0.06)
        lean = rnd.uniform(-w * 0.10, w * 0.10)
        tipx, tipy = x + lean, base - h
        # concave sides + a couple of bough steps give the fir its silhouette
        d = [f'M{x-w:.0f},{base:.0f}']
        steps = 4
        for k in range(steps, 0, -1):
            f = k / steps
            bx = w * (f ** 1.45)
            by = base - h * (1 - f)
            d.append(f'L{tipx-bx*1.12:.0f},{by:.0f} L{tipx-bx*0.80:.0f},{by-h*0.05:.0f}')
        d.append(f'L{tipx:.0f},{tipy:.0f}')
        for k in range(1, steps + 1):
            f = k / steps
            bx = w * (f ** 1.45)
            by = base - h * (1 - f)
            d.append(f'L{tipx+bx*0.80:.0f},{by-h*0.05:.0f} L{tipx+bx*1.12:.0f},{by:.0f}')
        d.append(f'L{x+w:.0f},{base:.0f} Z')
        parts.append(' '.join(d))
        x += w * rnd.uniform(0.85, 1.45)
    return ' '.join(parts)

def winden(path, sky_top, sky_mid, sky_low, glow_col, tree_far, tree_mid, tree_near,
           moon, rain, rain_col, fog_col, dark_mode):
    rnd = random.Random(11)
    horizon = H * 0.66
    body = [f'<rect width="{W}" height="{H}" fill="url(#sky)"/>']
    body.append(f'<circle cx="{W*0.70:.0f}" cy="{H*0.26:.0f}" r="120" fill="{moon}" opacity="0.9"/>')
    body.append(f'<circle cx="{W*0.70:.0f}" cy="{H*0.26:.0f}" r="230" fill="{moon}" '
                f'opacity="0.20" filter="url(#glow)"/>')
    # sodium glow at the horizon
    body.append(f'<ellipse cx="{W*0.42:.0f}" cy="{horizon:.0f}" rx="1500" ry="330" '
                f'fill="{glow_col}" opacity="0.30" filter="url(#glow)"/>')
    # steam plumes
    for tx, tw2 in ((W * 0.33, 300), (W * 0.50, 260)):
        body.append(f'<ellipse cx="{tx:.0f}" cy="{horizon-760:.0f}" rx="{tw2}" ry="330" '
                    f'fill="{fog_col}" opacity="0.28" filter="url(#fog)"/>')
    # cooling towers + stack
    tcol = mix(tree_far, sky_mid, 0.28)
    body.append(f'<path d="{tower(W*0.33, horizon+40, 560, 640)}" fill="{tcol}"/>')
    body.append(f'<path d="{tower(W*0.50, horizon+40, 470, 540)}" fill="{tcol}"/>')
    body.append(f'<rect x="{W*0.60:.0f}" y="{horizon-700:.0f}" width="70" height="740" fill="{tcol}"/>')
    body.append(f'<rect x="{W*0.24:.0f}" y="{horizon-150:.0f}" width="{W*0.42:.0f}" '
                f'height="200" fill="{tcol}"/>')
    # a few lit windows
    for _ in range(26):
        x = rnd.uniform(W * 0.25, W * 0.65)
        y = rnd.uniform(horizon - 130, horizon + 10)
        body.append(f'<rect x="{x:.0f}" y="{y:.0f}" width="14" height="9" '
                    f'fill="{glow_col}" opacity="{rnd.uniform(0.3,0.85):.2f}"/>')
    # fog band
    body.append(f'<rect x="0" y="{horizon-90:.0f}" width="{W}" height="360" fill="{fog_col}" '
                f'opacity="0.30" filter="url(#fog)"/>')
    # receding treelines
    body.append(f'<path d="{treeline(horizon+70, 210, 120, 3)}" fill="{tree_far}" fill-rule="nonzero"/>')
    body.append(f'<rect x="0" y="{horizon:.0f}" width="{W}" height="500" fill="{fog_col}" '
                f'opacity="0.22" filter="url(#fog)"/>')
    body.append(f'<path d="{treeline(horizon+340, 360, 210, 8)}" fill="{tree_mid}" fill-rule="nonzero"/>')
    body.append(f'<path d="{treeline(horizon+760, 620, 330, 21)}" fill="{tree_near}" fill-rule="nonzero"/>')
    if rain:
        for _ in range(900):
            x = rnd.uniform(-200, W)
            y = rnd.uniform(0, H)
            ln = rnd.uniform(40, 130)
            body.append(f'<line x1="{x:.0f}" y1="{y:.0f}" x2="{x+ln*0.22:.0f}" '
                        f'y2="{y+ln:.0f}" stroke="{rain_col}" stroke-width="2" '
                        f'opacity="{rnd.uniform(0.05,0.22):.2f}"/>')
    body.append(f'<rect width="{W}" height="{H}" fill="url(#vig)"/>')
    body.append(grain_layer(0.05))
    defs = GRAIN + f'''
    <linearGradient id="sky" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="{sky_top}"/>
      <stop offset="45%" stop-color="{sky_mid}"/>
      <stop offset="100%" stop-color="{sky_low}"/>
    </linearGradient>
    <radialGradient id="vig" cx="50%" cy="50%" r="72%">
      <stop offset="45%" stop-color="#000000" stop-opacity="0"/>
      <stop offset="100%" stop-color="#000000" stop-opacity="{0.45 if dark_mode else 0.12}"/>
    </radialGradient>'''
    open(path, 'w').write(wrap('\n'.join(body), defs))

# ---------------------------------------------------------------- omarchy bg
def omarchy(path, bg, fg):
    logo = open('/usr/share/omarchy/logo.svg').read()
    logo = logo.replace('fill="#000"', f'fill="{fg}"')
    inner = logo.split('>', 1)[1].rsplit('</svg>', 1)[0]
    s = 0.60
    lw, lh = 1215 * s, 285 * s
    body = (f'<rect width="{W}" height="{H}" fill="{bg}"/>'
            f'<g transform="translate({(W-lw)/2:.0f},{(H-lh)/2:.0f}) scale({s})">{inner}</g>')
    open(path, 'w').write(wrap(body))


# ---------------------------------------------------------------- build
THEMES = {
    'dark-winden': dict(
        passage=dict(outer='#060a0c', mid='#1b3238', inner='#b6e4e4', glow='#4e9ea4',
                     silhouette='#04080a', dust=True, vignette=0.55),
        emblem=dict(bg='#05090b', bg2='#101e22', ink='#6fb3b8', glow_col='#6fb3b8',
                    text_col='#9db8ba', glowing=True),
        winden=dict(sky_top='#060b0d', sky_mid='#0e1a1e', sky_low='#1d2b2c',
                    glow_col='#d3a558', tree_far='#0b1518', tree_mid='#070f11',
                    tree_near='#03080a', moon='#cfe0dd', rain=True,
                    rain_col='#a9c7c8', fog_col='#54767a', dark_mode=True),
        omarchy=dict(bg='#0a1114', fg='#6fb3b8'),
    ),
    'dark-winden-light': dict(
        passage=dict(outer='#f4f5f2', mid='#a9c2c2', inner='#0f2a30', glow='#7fa5a8',
                     silhouette='#2b3a3d', dust=False, vignette=0.0),
        emblem=dict(bg='#e4e7e3', bg2='#f4f5f2', ink='#2f6d75', glow_col='#2f6d75',
                    text_col='#4a5a5c', glowing=False),
        winden=dict(sky_top='#dfe4e1', sky_mid='#ebeeea', sky_low='#f3f4f1',
                    glow_col='#b98d3f', tree_far='#b9c5c2', tree_mid='#8b9c9a',
                    tree_near='#55686a', moon='#fbfaf4', rain=False,
                    rain_col='#8fa3a4', fog_col='#ffffff', dark_mode=False),
        omarchy=dict(bg='#e3e6e2', fg='#2f6d75'),
    ),
}

SCENES = [
    (passage, 'passage', '1-the-passage.jpg'),
    (emblem, 'emblem', '2-sic-mundus.jpg'),
    (winden, 'winden', '3-winden-plant.jpg'),
    (omarchy, 'omarchy', 'omarchy.png'),
]

def render(svg, out):
    """SVG -> 4K raster. JPEG at q92 with no chroma subsampling: PSNR ~51 dB
    against the PNG, no banding in the dark gradients even amplified 5x."""
    png = svg[:-4] + '.raster.png'
    subprocess.run(['rsvg-convert', '-w', str(W), '-h', str(H), '-o', png, svg], check=True)
    if out.endswith('.jpg'):
        subprocess.run(['magick', png, '-quality', '92',
                        '-sampling-factor', '4:4:4', out], check=True)
        os.remove(png)
    else:
        shutil.move(png, out)
    print(f'  {os.path.basename(out)}')

def main():
    root = os.path.join(OUT, 'themes')
    with tempfile.TemporaryDirectory() as tmp:
        for slug, scenes in THEMES.items():
            print(slug)
            dest = os.path.join(root, slug, 'backgrounds')
            os.makedirs(dest, exist_ok=True)
            for fn, key, name in SCENES:
                svg = os.path.join(tmp, f'{slug}-{key}.svg')
                fn(svg, **scenes[key])
                render(svg, os.path.join(dest, name))

if __name__ == '__main__':
    main()
