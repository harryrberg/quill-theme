"""Render cached vector screenshots without redistributing the originals."""
import json
from pathlib import Path
from PIL import Image, ImageDraw
from playwright.sync_api import sync_playwright

root = Path(__file__).resolve().parents[1] / '.research'
items = json.loads((root / 'media.json').read_text())
vectors = [m for m in items if m['url'].endswith('.svg')]
with sync_playwright() as p:
    browser = p.chromium.launch(channel='msedge', headless=True)
    page = browser.new_page(viewport={'width': 1800, 'height': 1400}, device_scale_factor=1)
    for m in vectors:
        import hashlib
        name = hashlib.sha256(m['url'].encode()).hexdigest()[:16]
        path = root / (name + '.svg')
        page.goto(path.as_uri())
        page.locator('svg').screenshot(path=str(root / (name + '-render.png')))
        m['render'] = name + '-render.png'
    browser.close()
sheet = Image.new('RGB', (1600, 6 * 270), '#eeeeee')
draw = ImageDraw.Draw(sheet)
for n, m in enumerate(vectors):
    with Image.open(root / m['render']) as im:
        im.thumbnail((390, 235))
        x, y = n % 4 * 400, n // 4 * 270
        sheet.paste(im.convert('RGB'), (x, y))
        draw.text((x+3,y+237), f"{n:02d} {m['url'].rsplit('/',1)[-1]}", fill='black')
sheet.save(root / 'vectors.jpg')
print(f'Rendered {len(vectors)} SVG screenshots')
