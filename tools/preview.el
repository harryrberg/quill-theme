;;; preview.el --- Render Quill's own sample buffers -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'json)
(require 'color)
(defvar quill-minimal-ui)
(defvar quill-palette)
(declare-function modus-themes-get-theme-palette "modus-themes"
                  (&optional theme with-overrides with-user-palette))
(declare-function modus-themes-get-color-value "modus-themes"
                  (color &optional with-overrides theme))
(defvar quill-preview-root
  (file-name-directory (directory-file-name
                        (file-name-directory load-file-name))))
(add-to-list 'custom-theme-load-path quill-preview-root)
(setq quill-minimal-ui t)
(load-theme 'quill t)
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(blink-cursor-mode -1)
(set-frame-parameter nil 'undecorated t)
(set-frame-size (selected-frame) 112 35)
(set-frame-position (selected-frame) 80 80)
(setq inhibit-startup-screen t initial-scratch-message nil)
(defun quill-preview-add-swatches ()
  "Append every distinct literal Quill colour to the sample buffer."
  (goto-char (point-max))
  (insert "\nQUILL PALETTE - colour samples, not syntax highlighting\n")
  (let ((seen nil) (column 0))
    (dolist (entry quill-palette)
      (let ((colour (cadr entry)))
        (when (and (stringp colour) (string-prefix-p "#" colour)
                   (not (member colour seen)))
          (push colour seen)
          (let ((start (point))
                (label (or (cdr (assq (car entry)
                                     '((fg-mode-line-inactive . "inactive text")
                                       (bg-search-current . "current search")
                                       (bg-completion . "completion"))))
                           (replace-regexp-in-string "^quill-" "" (symbol-name (car entry))))))
            (insert "    ")
            (overlay-put (make-overlay start (point)) 'face
                         `(:background ,colour :foreground ,colour
                           :box (:line-width 1 :color "#555555")))
            (insert (format " %-7s %-14s" colour (truncate-string-to-width label 14))))
          (setq column (1+ column))
          (when (= column 4) (insert "\n") (setq column 0)))))
    (unless (= column 0) (insert "\n"))))

(defun quill-preview-export-palette ()
  "Export all resolved colour entries, including inherited Modus roles."
  (let (entries)
    (dolist (entry (modus-themes-get-theme-palette 'quill t t))
      (let ((value (modus-themes-get-color-value (car entry) t 'quill)))
        (when (stringp value)
          (let ((rgb (color-name-to-rgb value)))
            (when rgb
              (push `((name . ,(symbol-name (car entry)))
                      (color . ,(apply #'color-rgb-to-hex (append rgb '(2)))))
                    entries))))))
    (with-temp-file (expand-file-name "docs/palette.json" quill-preview-root)
      (insert (json-encode (nreverse entries)) "\n"))))

(defun quill-preview-render ()
  "Export a genuine Emacs GUI frame containing original sample code."
  (condition-case err
      (progn
        (unless (member "MonoLisa Variable" (font-family-list))
          (error "Preview requires the installed MonoLisa Variable font"))
        (set-frame-font (font-spec :family "MonoLisa Variable" :size 12.0
                                  :weight 'normal) nil t)
        (delete-other-windows)
        (switch-to-buffer (get-buffer-create "perceptron.el"))
        (erase-buffer)
        (insert-file-contents
         (expand-file-name "examples/perceptron.el" quill-preview-root))
        (emacs-lisp-mode)
        (quill-preview-add-swatches)
        (font-lock-ensure)
        (set-frame-size nil 112 (+ 3 (count-lines (point-min) (point-max))))
        (set-frame-position nil 80 0)
        (setq-local mode-line-format
                    '("  Quill   " mode-line-buffer-identification
                      "     " mode-name "     %l:%c     Mickey-inspired / Modus-powered"))
        (goto-char (point-min))
        (forward-line 4)
        (make-frame-visible)
        (message " ")
        (redisplay t)
        (sit-for 1)
        (make-directory (expand-file-name "docs" quill-preview-root) t)
        (make-directory (expand-file-name ".research" quill-preview-root) t)
        (quill-preview-export-palette)
        (let (families)
          (dotimes (offset (1- (point-max)))
            (let ((position (1+ offset)))
              (unless (memq (char-after position) '(?\n ?\s))
                (let ((font (font-at position)))
                  (unless font (error "No rendered font at %s" position))
                  (cl-pushnew (font-get font :family) families :test #'equal)))))
          (unless (and families
                       (cl-every (lambda (family)
                                   (string-equal (downcase (format "%s" family))
                                                 "monolisa variable"))
                                 families))
            (error "Unexpected rendered font families: %S" families))
          (with-temp-file (expand-file-name "docs/preview-font.txt" quill-preview-root)
            (insert "Preview font: MonoLisa Variable, Regular, 12 pt\n"
                    "Verified with Emacs font-at for every non-space, non-newline\n"
                    "character in the displayed sample buffer before frame export.\n"
                    (format "Resolved families: %S\n" families))))
        (unless (w32-export-frame nil (expand-file-name "docs/perceptron-palette-minimal.png" quill-preview-root) 'png)
          (error "Default preview export failed"))
        (customize-set-variable 'quill-minimal-ui nil)
        (redisplay t)
        (sit-for 0.5)
        (unless (w32-export-frame nil (expand-file-name "docs/perceptron-palette-mickey.png" quill-preview-root) 'png)
          (error "Alternative preview export failed"))
        (with-temp-file (expand-file-name ".research/gui-check.txt" quill-preview-root)
          (dolist (face '(default font-lock-keyword-face font-lock-string-face
                         font-lock-comment-face font-lock-function-name-face
                         mode-line mode-line-active mode-line-inactive cursor))
            (insert (format "%s fg=%s bg=%s\n" face
                            (face-attribute face :foreground nil t)
                            (face-attribute face :background nil t)))))
        (kill-emacs 0))
    (error
     (with-temp-file (expand-file-name ".research/preview-error.txt" quill-preview-root)
       (prin1 err (current-buffer)))
     (kill-emacs 1))))
(run-at-time 1 nil #'quill-preview-render)
;;; preview.el ends here
