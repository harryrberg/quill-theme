"""Inventory public Mastering Emacs article media; keep downloaded media local."""
import concurrent.futures as cf
import hashlib
import json
from pathlib import Path
from urllib.parse import urljoin, urlparse
import xml.etree.ElementTree as ET

import requests
from bs4 import BeautifulSoup
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
CACHE = ROOT / '.research'
CACHE.mkdir(exist_ok=True)
BASE = 'https://www.masteringemacs.org'

def get(url):
    r = requests.get(url, timeout=45)
    r.raise_for_status()
    return r

def page(url):
    try:
        html = get(url).text
        soup = BeautifulSoup(html, 'html.parser')
        media = []
        for tag in soup.select('img, video, source, iframe'):
            for attr in ('src', 'data-src', 'poster'):
                src = tag.get(attr)
                if src:
                    media.append({'kind': tag.name, 'url': urljoin(url, src), 'alt': tag.get('alt', '')})
        videos = sorted({urljoin(url, a['href']) for a in soup.select('a[href]')
                         if any(x in a['href'] for x in ('youtu.be/', 'youtube.com/watch', 'vimeo.com/'))})
        return {'url': url, 'media': media, 'video_links': videos}
    except Exception as e:
        return {'url': url, 'error': str(e)}

def download(item):
    url = item['url']
    suffix = Path(urlparse(url).path).suffix or '.bin'
    path = CACHE / (hashlib.sha256(url.encode()).hexdigest()[:16] + suffix)
    try:
        if not path.exists():
            path.write_bytes(get(url).content)
        if suffix == '.svg':
            ET.fromstring(path.read_bytes())
            item.update(file=path.name, format='svg')
            return item
        with Image.open(path) as im:
            frames = getattr(im, 'n_frames', 1)
            samples = sorted({0, frames // 2, frames - 1})
            item.update(file=path.name, width=im.width, height=im.height, frames=frames, samples=samples)
            counts = {}
            for f in samples:
                im.seek(f)
                rgb = im.convert('RGB')
                for count, color in rgb.getcolors(rgb.width * rgb.height):
                    counts[color] = counts.get(color, 0) + count
            item['colors'] = [{'hex': '#%02x%02x%02x' % color, 'pixels': count}
                              for color, count in sorted(counts.items(), key=lambda x: -x[1])[:24]]
    except Exception as e:
        item['error'] = str(e)
    return item

def main():
    sitemap = ET.fromstring(get(BASE + '/sitemap.xml').content)
    urls = {node.text for node in sitemap.iter() if node.tag.endswith('loc') and node.text and '/article/' in node.text}
    index = BeautifulSoup(get(BASE + '/all-articles').text, 'html.parser')
    urls.update(urljoin(BASE, a['href']) for a in index.select('a[href]') if a['href'].startswith('/article/'))
    with cf.ThreadPoolExecutor(max_workers=4) as pool:
        pages = list(pool.map(page, sorted(urls)))
    (CACHE / 'pages.json').write_text(json.dumps(pages, indent=2), encoding='utf-8')
    media = {}
    for p in pages:
        for m in p.get('media', []):
            if '/static/uploads/' in m['url']:
                entry = media.setdefault(m['url'], dict(m, articles=[]))
                if p['url'] not in entry['articles']:
                    entry['articles'].append(p['url'])
    with cf.ThreadPoolExecutor(max_workers=4) as pool:
        items = list(pool.map(download, media.values()))
    (CACHE / 'media.json').write_text(json.dumps(items, indent=2), encoding='utf-8')
    valid = [m for m in items if 'width' in m]
    for start in range(0, len(valid), 24):
        batch = valid[start:start+24]
        sheet = Image.new('RGB', (1600, 6 * 245), '#eeeeee')
        draw = ImageDraw.Draw(sheet)
        for n, m in enumerate(batch):
            with Image.open(CACHE / m['file']) as im:
                im.seek(m['samples'][len(m['samples'])//2])
                thumb = im.convert('RGB')
                thumb.thumbnail((390, 205))
                x, y = n % 4 * 400, n // 4 * 245
                sheet.paste(thumb, (x, y))
                draw.text((x+3, y+207), f"{start+n:03d} {Path(urlparse(m['url']).path).name[:48]}", fill='black')
                draw.text((x+3, y+223), f"{m['width']}x{m['height']} / {m['frames']} frames", fill='black')
        sheet.save(CACHE / f'contact-{start//24:02d}.jpg')
    print(json.dumps({'articles': len(pages), 'page_errors': [p for p in pages if 'error' in p],
                      'media': len(items), 'readable_images': len(valid),
                      'videos': [p for p in pages if p.get('video_links') or any(m['kind'] in ('video','iframe','source') for m in p.get('media', []))]}, indent=2))

if __name__ == '__main__':
    main()
