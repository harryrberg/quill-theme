;;; quill-theme.el --- A Mastering Emacs inspired dark theme -*- lexical-binding: t; -*-

;; Copyright (C) 2026 Harry Berg
;; Author: Harry Berg
;; Maintainer: Harry Berg <https://github.com/harryrberg>
;; URL: https://github.com/harryrberg/quill-theme
;; Version: 0.2.0
;; Package-Requires: ((emacs "29.1") (modus-themes "5.2.0"))
;; Keywords: faces, theme
;; SPDX-License-Identifier: GPL-3.0-or-later

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;; This program is distributed WITHOUT ANY WARRANTY; without even the
;; implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
;; See the GNU General Public License for more details.
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Quill is an unofficial reconstruction inspired by Mickey Petersen's
;; personal Emacs colour scheme, as shown on https://www.masteringemacs.org/.
;; Credit for the visual inspiration belongs to Mickey Petersen.  He is
;; not the author or maintainer of this package and has not endorsed it.
;; Face coverage is provided by Protesilaos Stavrou's Modus Themes.
;; See SOURCES.md for observations, inferred choices, and coverage limits.
;;
;; Install Modus Themes >= 5.2.0, then use (load-theme 'quill t).
;; Quill respects Modus styling options and common palette overrides.
;; Customize `quill-palette-overrides' and reload to adjust colours.

;;; Code:

(declare-function modus-themes-theme "modus-themes"
                  (name family description background-mode core-palette
                        user-palette overrides-palette &optional
                        custom-faces custom-variables))
(declare-function modus-themes-get-color-value "modus-themes"
                  (color &optional with-overrides theme))

(when (< emacs-major-version 29)
  (error "Quill requires Emacs 29.1 or newer for derivative theme properties"))

(unless (require 'modus-themes nil t)
  (require-theme 'modus-themes))

(unless (and (fboundp 'modus-themes-theme)
             (boundp 'modus-themes-vivendi-palette)
             (fboundp 'modus-themes-generate-palette))
  (error "Quill requires Modus Themes 5.2.0 or newer; upgrade and restart Emacs"))

(defgroup quill-theme nil
  "A dark theme inspired by Mickey Petersen's Emacs screenshots."
  :group 'faces
  :prefix "quill-")

(defcustom quill-palette-overrides nil
  "Palette entries overriding Quill's defaults.
Each entry has the form (NAME VALUE), where VALUE is a colour string
or another palette name.  Reload Quill after changing this option.
For example: ((keyword \"#9580ff\") (bg-region \"#203060\")).
Quill does not inherit the contrast guarantees of the original Modus themes."
  :group 'quill-theme
  :type '(repeat (list symbol (choice string symbol))))

(defun quill--set-minimal-ui (symbol value)
  "Set SYMBOL to VALUE and refresh Quill when it is active."
  (set-default symbol value)
  (when (and (fboundp 'quill--apply) (memq 'quill custom-enabled-themes))
    (quill--apply)))

(defcustom quill-minimal-ui nil
  "Use black fringes and a black inactive mode line.
Keep the active mode line blue and window separators visible.
Changes made through Customize take effect immediately when Quill is active.
Explicit `quill-palette-overrides' still take precedence.

This option changes colours, not divider widths.  For one-pixel dividers,
set `window-divider-default-right-width' and
`window-divider-default-bottom-width' to 1, set
`window-divider-default-places' to t, and enable `window-divider-mode'."
  :group 'quill-theme
  :type 'boolean
  :set #'quill--set-minimal-ui)

;;;###autoload
(defun quill-toggle-minimal-ui (&optional arg)
  "Toggle `quill-minimal-ui' for this session.
With prefix ARG, enable if ARG is positive, otherwise disable.
Refresh Quill immediately if active; do not activate an inactive theme.
Use Customize or your init file to make the setting persistent."
  (interactive "P")
  (customize-set-variable
   'quill-minimal-ui
   (if arg (> (prefix-numeric-value arg) 0) (not quill-minimal-ui)))
  (when (called-interactively-p 'interactive)
    (message "Quill minimal UI %s%s"
             (if quill-minimal-ui "enabled" "disabled")
             (if (memq 'quill custom-enabled-themes) "" "; load Quill to see it"))))

(defconst quill-palette
  '((bg-main "#000000")
    (fg-main "#dcdcdc")
    (bg-dim "#1a1a1a")
    (fg-dim "#a6a6a6")
    (bg-active "#333333")
    (bg-inactive "#1a1a1a")
    (border "#333333")
    (cursor "#ff0000")
    (quill-violet "#6a5acd")
    (quill-orange "#ff4500")
    (quill-green "#7cfc00")
    (quill-slate "#708090")
    (quill-cyan "#00bfff")
    (quill-blue "#87ceeb")
    (quill-cadet "#5f9ea0")
    (quill-gold "#ffa500")
    (quill-modeline "#27408b")
    (quill-azure "#f0ffff")
    (fringe bg-dim)
    (bg-hl-line "#101010")
    (bg-region "#0000ff")
    (fg-region unspecified)
    (bg-mode-line-active quill-modeline)
    (fg-mode-line-active quill-azure)
    (border-mode-line-active unspecified)
    (bg-mode-line-inactive "#333333")
    (fg-mode-line-inactive "#b3b3b3")
    (border-mode-line-inactive unspecified)
    (bg-tab-bar bg-dim)
    (bg-tab-current quill-modeline)
    (fg-tab-current quill-azure)
    (bg-tab-other bg-dim)
    (fg-tab-other fg-dim)
    (builtin quill-violet)
    (comment quill-green)
    (constant quill-cyan)
    (docstring quill-gold)
    (docmarkup quill-cyan)
    (fnname quill-slate)
    (fnname-call fg-main)
    (keyword quill-violet)
    (preprocessor quill-violet)
    (property quill-cyan)
    (string quill-orange)
    (type quill-cadet)
    (variable quill-blue)
    (variable-use fg-main)
    (number fg-main)
    (operator fg-main)
    (bracket fg-main)
    (delimiter fg-main)
    (punctuation fg-main)
    (fg-prompt quill-cadet)
    (fg-link quill-cyan)
    (underline-link quill-cyan)
    (fg-link-visited quill-violet)
    (fg-completion-match-0 quill-cyan)
    (fg-completion-match-1 quill-gold)
    (fg-completion-match-2 quill-green)
    (fg-completion-match-3 quill-blue)
    (bg-completion "#00008b")
    (bg-paren-match "#00008b")
    (fg-paren-match quill-azure)
    (bg-search-current "#705000")
    (fg-search-current quill-azure)
    (bg-search-lazy "#27408b")
    (fg-search-lazy quill-azure)
    (fg-heading-1 quill-blue)
    (fg-heading-2 quill-gold)
    (fg-heading-3 quill-cadet)
    (fg-heading-4 quill-green)
    (fg-heading-5 quill-cyan)
    (fg-heading-6 fg-main)
    (fg-heading-7 quill-blue)
    (fg-heading-8 quill-gold)
    (fg-prose-code quill-cyan)
    (fg-prose-verbatim quill-gold)
    (bg-prose-block-contents bg-main)
    (bg-prose-block-delimiter bg-main)
    (bg-line-number-active bg-main)
    (bg-line-number-inactive bg-main)
    (fg-line-number-active fg-main)
    (fg-line-number-inactive quill-slate))
  "Observed colours and semantic mappings layered over Modus Vivendi.
Core syntax and mode-line colours are grounded in public screenshots.
Unobserved interfaces use matching choices or the Modus fallback palette.
See SOURCES.md for the distinction.")

(defvar quill--effective-palette nil
  "Quill palette with the selected UI variant applied.")

(defun quill--apply ()
  "Define or refresh Quill using its current options."
  (setq quill--effective-palette
        (append (when quill-minimal-ui
                  '((fringe bg-main)
                    (bg-mode-line-inactive bg-main)))
                quill-palette))
  (modus-themes-theme
   'quill 'quill-theme
   "Unofficial dark theme inspired by Mickey Petersen's Mastering Emacs."
   'dark
   'modus-themes-vivendi-palette
   'quill--effective-palette
   'quill-palette-overrides)
  (when quill-minimal-ui
    (let ((border (modus-themes-get-color-value 'border t 'quill)))
      (custom-theme-set-faces
       'quill
       `(window-divider-first-pixel
         ((((class color) (min-colors 256)) :foreground ,border)))
       `(window-divider-last-pixel
         ((((class color) (min-colors 256)) :foreground ,border)))))))

(quill--apply)

;;;###autoload
(when load-file-name
  (add-to-list 'custom-theme-load-path (file-name-directory load-file-name)))

(provide 'quill-theme)
;;; quill-theme.el ends here
