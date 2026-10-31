# Sources and reconstruction notes

Survey date: **2026-10-31**. Package version: **0.1.0**.

## Scope and method

The union of [the article index](https://www.masteringemacs.org/all-articles)
and [the sitemap](https://www.masteringemacs.org/sitemap.xml) yielded 114 article
URLs, all fetched successfully. Their image elements referenced 113 unique
assets under `/static/uploads/`. Site logos, book covers and repeated decorative
fleurons under `/static/img/` were excluded from the theme evidence.

The 113 assets comprise 43 editorial JPEG illustrations, two terminal PNGs,
and **68 Emacs screenshots or animations** (18 PNGs, 22 SVGs, 28 GIFs).
The Emacs group includes non-code interfaces such as games, completion and Magit;
these help establish the background, text, cursor and mode-line styling.
All 91 raster assets and all 22 rendered SVGs were visually screened in contact
sheets. Selected syntax references were examined at full resolution.

For the 28 GIFs (727 frames in total), pixel analysis sampled the first, middle,
and last frame. The visual contact sheets use a middle frame. We did not watch
every animation continuously or inspect all 727 frames individually.
HTML code blocks are not treated as evidence of the author's editor faces.

The complete article and asset URL lists, hashes, file formats, and article-to-asset
relationships are in [source-inventory.json](docs/source-inventory.json).
The downloaded source media and contact sheets are not shipped in this repository.

## Primary visual references

- [Structured movement and editing with Combobulate](https://www.masteringemacs.org/article/combobulate-structured-movement-editing-treesitter):
  [full Emacs screenshot](https://www.masteringemacs.org/static/uploads/combobulate/combobulate.png),
  [multiple-cursor JSX demonstration](https://www.masteringemacs.org/static/uploads/combobulate/mc-edit-1.gif),
  [selection demonstration](https://www.masteringemacs.org/static/uploads/combobulate/expand-region.gif).
- [Combobulate query-builder SVG](https://www.masteringemacs.org/static/uploads/combobulate/combobulate-query-builder-popup.svg):
  lossless vector colours, syntax, popup and active/inactive mode lines.
- [HTML tree-sitter SVG](https://www.masteringemacs.org/static/uploads/html-ts-mode.svg):
  keywords, types, attributes and strings.
- [Older Iedit screenshot](https://www.masteringemacs.org/static/uploads/iedit.png):
  Lisp keywords, documentation strings, comments, function definitions, constants,
  selection and mode line.
- [Cascadia example SVG](https://www.masteringemacs.org/static/uploads/cascadia-example.svg):
  comments, main text, cursor and mode line.
- [Magit diff SVG](https://www.masteringemacs.org/static/uploads/magit-diff-hunk.svg):
  evidence that auxiliary interfaces have their own face colours; Quill keeps
  Modus's diff semantics rather than claiming to reconstruct all Magit settings.

## Palette decisions

These are observed RGB values, not values guessed from compressed video. SVG
percentage channels are converted to 8-bit RGB; PNG pixels provide corroboration.
Assigning a colour to an Emacs face is an interpretation of the visible syntax,
not access to Mickey's original Customize settings.

| Role | Quill value | Evidence / decision |
|---|---|---|
| Main background | `#000000` | Repeated across code and UI references |
| Main text | `#dcdcdc` | Gainsboro fills/pixels in SVG and PNG |
| Fringe | `#1a1a1a` | Repeated dark-grey gutters |
| Keywords / Lisp builtins | `#6a5acd` | SlateBlue, visible in Lisp forms and Python keywords |
| Strings | `#ff4500` | OrangeRed; SVG/PNG avoid GIF quantization to `#fe4500` |
| Comments | `#7cfc00` | LawnGreen, explicit in Iedit and Cascadia references |
| Lisp documentation strings | `#ffa500` | Orange in the Iedit example; language modes may differ |
| Function definitions | `#708090` | SlateGray in Lisp/Python references |
| Constants | `#00bfff` | DeepSkyBlue in quoted Lisp symbols and syntax examples |
| Variables | `#87ceeb` | SkyBlue is observed; role mapping is inferred from examples |
| Types / prompts | `#5f9ea0` | CadetBlue is observed; shared role mapping is inferred |
| Cursor | `#ff0000` | Red block across screenshots and vector captures |
| Active mode line | `#27408b` / `#f0ffff` | RoyalBlue4 / Azure |
| Inactive mode line | `#333333` / `#b3b3b3` | Grey inactive panes in vector screenshots |
| Region | `#0000ff` | Bright blue in Combobulate region demos; preserve syntax foreground |

Quill uses a complete Modus Vivendi core palette and layers these observations
over it. Headings, tab styling, completion, search, line numbers, current-line
background and other unobserved roles include our design choices. Error/diff
semantics and remaining package faces inherit Modus. This ensures coverage but
does not make those choices Mickey's settings.

Font, font size, line spacing, cursor shape and window layout are user settings.
They are deliberately not part of the theme. The package preview uses Consolas;
it does not claim that Mickey uses this font.

## Video evidence

No YouTube/Vimeo links or `video`, `source`, or `iframe` elements were found in
the fetched article HTML. The site's embedded demonstrations in this inventory
are animated GIFs. External search also located:

- [2014-08-10 Emacs Chat — Mickey Petersen](https://www.youtube.com/watch?v=JA4dqmDFt5Y),
  hosted by Sacha Chua, duration 53:36.
- [Interview transcript](https://emacslife.com/emacs-chats/chat-mickey-petersen.html).

The video was downloaded locally at 720p and visually sampled at 01:00, 03:00,
06:00, 09:00, 12:00, 15:00, 18:00, 21:00, 24:00, 27:00, 30:00, 33:00,
36:00, 39:00, 42:00, 45:00, 48:00 and 51:00. The screen-sharing samples show
the same black background, green comments, orange strings, blue mode line and
red cursor. Red transient selection/highlight overlays also appear; these are
not treated as the universal region setting.

Video compression is unsuitable for exact palette extraction. The recording
supports historical consistency, not exact pixel values. This is a sampled
visual review, not a claim to have watched every video featuring Mickey.
The vidIQ lookup was unavailable because its account had insufficient credits;
the primary video was retrieved directly instead.

Mickey describes his colours as predating packaged themes in the interview and
in [What's New in Emacs 27.1?](https://www.masteringemacs.org/article/whats-new-in-emacs-27-1).
That supports describing Quill as an independent reconstruction. It does not
establish whether he has subsequently published his current configuration.

## Attribution

Visual inspiration: **Mickey Petersen**, [GitHub](https://github.com/mickeynp),
[Mastering Emacs](https://www.masteringemacs.org/).
Mickey has not authored, maintained, reviewed, or endorsed this package.
No endorsement is implied, and no source screenshots or video frames are included.

Implementation foundation: **Protesilaos Stavrou's Modus Themes**;
[derivative-theme documentation](https://protesilaos.com/emacs/modus-themes).
Independent package implementation and maintenance: **Harry Berg**.
