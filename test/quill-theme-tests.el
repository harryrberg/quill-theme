;;; quill-theme-tests.el --- Quill integration tests -*- lexical-binding: t; -*-

(require 'ert)
(require 'cl-lib)
(require 'package)
(defconst quill-test-root
  (file-name-directory
   (directory-file-name
    (file-name-directory (or load-file-name buffer-file-name)))))
(add-to-list 'custom-theme-load-path quill-test-root)

(ert-deftest quill-load-disable-and-reload ()
  "Loading works repeatedly and disabling restores the previous face spec."
  (let ((before (face-attribute 'default :foreground))
        (before-bg (face-attribute 'default :background)))
    (unwind-protect
        (progn
          (load-theme 'quill t)
          (should (memq 'quill custom-enabled-themes))
          (should (eq (plist-get (get 'quill 'theme-properties) :family)
                      'quill-theme))
          (load-theme 'quill t)
          (should (= 1 (cl-count 'quill custom-enabled-themes)))
          (disable-theme 'quill)
          (should (equal before (face-attribute 'default :foreground)))
          (should (equal before-bg (face-attribute 'default :background))))
      (when (memq 'quill custom-enabled-themes) (disable-theme 'quill)))))

(ert-deftest quill-palette-is-complete-and-resolvable ()
  "Every palette reference resolves; upstream coverage is retained."
  (load-theme 'quill t)
  (let ((palette (modus-themes-get-theme-palette 'quill t t)))
    (dolist (entry palette)
      (let ((value (modus-themes-get-color-value (car entry) nil 'quill)))
        (should (or (stringp value) (eq value 'unspecified))))))
  (dolist (face '(default font-lock-keyword-face font-lock-string-face
                 font-lock-comment-face mode-line mode-line-active
                 mode-line-inactive org-level-1 magit-section-heading
                 diff-added region isearch completions-common-part))
    (should (assq face (mapcar (lambda (setting)
                               (cons (nth 1 setting) (nthcdr 2 setting)))
                             (get 'quill 'theme-settings))))))

(ert-deftest quill-overrides-work-without-changing-modus ()
  "User palette changes survive reload without mutating the upstream palette."
  (load-theme 'quill t)
  (let ((baseline (copy-tree modus-themes-vivendi-palette))
        (quill-palette-overrides '((keyword "#abcdef"))))
    (unwind-protect
        (progn
          (load-theme 'quill t)
          (should (equal "#abcdef"
                         (modus-themes-get-color-value 'keyword t 'quill)))
          (should (equal baseline modus-themes-vivendi-palette)))
      (setq quill-palette-overrides nil)
      (load-theme 'quill t))))

(ert-deftest quill-observed-colors-and-no-font-lock-in ()
  "Check the observed anchors and keep typography under user control."
  (load-theme 'quill t)
  (dolist (entry '((bg-main "#000000") (fg-main "#dcdcdc")
                   (keyword "#6a5acd") (string "#ff4500")
                   (comment "#7cfc00") (cursor "#ff0000")
                   (bg-mode-line-active "#27408b")))
    (should (equal (cadr entry)
                   (modus-themes-get-color-value (car entry) nil 'quill))))
  (let ((settings (get 'quill 'theme-settings)))
    (should-not (cl-find 'default-frame-alist settings :key #'cadr))
    (should-not (cl-find 'cursor-type settings :key #'cadr))))

(ert-deftest quill-single-file-package-metadata ()
  "The distributed file is recognized by package.el with dependencies."
  (with-temp-buffer
    (insert-file-contents
     (expand-file-name "quill-theme.el" quill-test-root))
    (emacs-lisp-mode)
    (let ((desc (package-buffer-info)))
      (should (eq (package-desc-name desc) 'quill-theme))
      (should (equal (cadr (assq 'modus-themes (package-desc-reqs desc)))
                     '(5 2 0))))))

;;; quill-theme-tests.el ends here
