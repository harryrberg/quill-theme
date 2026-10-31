"""Render the resolved Emacs palette as a complete, grouped SVG colour chart."""
import json
from collections import defaultdict
from pathlib import Path
from xml.sax.saxutils import escape

root = Path(__file__).resolve().parents[1]
entries = json.loads((root / 'docs/palette.json').read_text())
groups = defaultdict(list)
for entry in entries:
    if entry['name'] not in groups[entry['color']]:
        groups[entry['color']].append(entry['name'])
colors = sorted(groups)
columns, cell_width, cell_height = 6, 220, 66
height = 85 + ((len(colors) + columns - 1) // columns) * cell_height
parts = [f'<svg xmlns="http://www.w3.org/2000/svg" width="1320" height="{height}" viewBox="0 0 1320 {height}">',
         '<rect width="100%" height="100%" fill="#000000"/>',
         '<g font-family="MonoLisa Variable, Consolas, monospace" fill="#dcdcdc">',
         '<text x="20" y="30" font-size="20">Quill - complete resolved palette</text>',
         f'<text x="20" y="55" font-size="13">{len(colors)} unique colours / {len(entries)} named colours and roles, including Modus fallbacks</text>']
for index, color in enumerate(colors):
    x, y = 20 + index % columns * cell_width, 80 + index // columns * cell_height
    label = groups[color][0]
    title = escape(color + ': ' + ', '.join(groups[color]))
    parts.extend([f'<g><title>{title}</title>',
                  f'<rect x="{x}" y="{y}" width="44" height="40" fill="{color}" stroke="#555555"/>',
                  f'<text x="{x+54}" y="{y+15}" font-size="14">{color}</text>',
                  f'<text x="{x+54}" y="{y+34}" font-size="11">{escape(label[:22])}</text>',
                  '</g>'])
parts.append('</g></svg>')
(root / 'docs/palette.svg').write_text('\n'.join(parts) + '\n', encoding='utf-8')
print(f'Rendered all {len(colors)} unique colours from {len(entries)} resolved palette entries.')
