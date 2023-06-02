;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Zhen Wu"
      user-mail-address "zhenwu@mit.edu")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face

(setq doom-font (font-spec :family "Iosevka"
                           :size 18 :weight 'normal :width 'expanded)
      doom-big-font (font-spec :family "Iosevka Slab"
                               :size 18 :weight 'normal :width 'expanded))

;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;;;;;;;;;;;;;;;;;;;;;
;; visual settings ;;
;;;;;;;;;;;;;;;;;;;;;

;; emacs start with window maximized
(add-hook 'window-setup-hook #'toggle-frame-maximized)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; line wrap
(use-package! olivetti
  :config
  (setq-default olivetti-body-width 80)
  (add-hook 'mixed-pitch-mode-hook
            (lambda () (setq-local olivetti-body-width 70))))

(use-package! auto-olivetti
  :custom
  (auto-olivetti-enabled-modes '(org-mode
                                 text-mode
                                 latex-mode
                                 helpful-mode))
  :config
  (auto-olivetti-mode))

;; Day and night themes
(defun my/apply-theme (appearance)
  "Load theme, taking current system APPEARANCE into consideration."
  (mapc #'disable-theme custom-enabled-themes)
  (pcase appearance
    ('light (load-theme 'doom-one-light t))
    ('dark (load-theme 'doom-palenight t))))
(add-hook 'ns-system-appearance-change-functions #'my/apply-theme)

;; dashborad
;; (setq fancy-splash-image (concat doom-private-dir "misc/darwin.png"))
(setq fancy-splash-image (concat doom-private-dir "misc/world.png"))
(defun splash-phrase-dashboard-insert ()
  "Insert the splash phrase surrounded by newlines."
  (insert "\n" (+doom-dashboard--center +doom-dashboard--width
                                        "Enjoy Modeling & Writing")))
(defun +doom-dashboard-benchmark-line ()
  "Insert the load time line."
  (when doom-init-time
    (insert
     "\n\n"
     (propertize
      (+doom-dashboard--center
       +doom-dashboard--width
       (doom-display-benchmark-h 'return))
      'face 'doom-dashboard-loaded))))
(setq +doom-dashboard-functions
      (list #'doom-dashboard-widget-banner
            #'splash-phrase-dashboard-insert
            #'+doom-dashboard-benchmark-line))

;; dashboard quick action
(defun +doom-dashboard-setup-modified-keymap ()
  (setq +doom-dashboard-mode-map (make-sparse-keymap))
  (map! :map +doom-dashboard-mode-map
        :desc "Find file" :ng "f" #'find-file
        :desc "Recent files" :ng "r" #'consult-recent-file
        :desc "Config dir" :ng "C" #'doom/open-private-config
        :desc "Open config.el" :ng "c" (cmd! (find-file
                                              (expand-file-name
                                               "config.el" doom-user-dir)))
        :desc "Notes (roam)" :ng "n" #'org-roam-node-find
        :desc "Bookmark" :ng "b" #'bookmark-jump
        :desc "Switch buffers (all)" :ng "B" #'consult-buffer
        :desc "IBuffer" :ng "i" #'ibuffer
        :desc "Previous buffer" :ng "p" #'previous-buffer
        :desc "Quit" :ng "Q" #'save-buffers-kill-terminal
        :desc "Show keybindings" :ng "h" (cmd! (which-key-show-keymap
                                                '+doom-dashboard-mode-map))))
(add-transient-hook! #'+doom-dashboard-mode
  (+doom-dashboard-setup-modified-keymap))
(add-transient-hook! #'+doom-dashboard-mode :append
                     (+doom-dashboard-setup-modified-keymap))
(add-hook! 'doom-init-ui-hook
           :append (+doom-dashboard-setup-modified-keymap))

(defun +doom-dashboard-tweak (&optional _)
  (with-current-buffer (get-buffer +doom-dashboard-name)
    (setq-local line-spacing 0.3
                mode-line-format nil
                evil-normal-state-cursor (list nil))))
(add-hook '+doom-dashboard-mode-hook #'+doom-dashboard-tweak)

;; modeline
(after! doom-modeline
  (setq doom-modeline-enable-word-count t)
  (setq doom-modeline-battery t)
  (setq doom-modeline-time t)
  (setq doom-modeline-persp-icon t))

;; PDF-tool crashes
(add-hook 'pdf-tools-enabled-hook 'pdf-view-dark-minor-mode)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; visual settings end here ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; evil escape
(use-package! key-chord
  :init
  (setq key-chord-two-keys-delay 0.2)
  (key-chord-define evil-insert-state-map "jk" 'evil-normal-state)
  (key-chord-mode 1))
(setq evil-escape-key-sequence nil)

;; spell check
(use-package! jinx
  :hook ((text-mode . jinx-mode)
         (org-mode . jinx-mode)
         (latex-mode . jinx-mode)
         (markdown-mode . jinx-mode))
  :bind ([remap ispell-word] . jinx-correct))

(setq ispell-dictionary "en-custom")
(setq ispell-personal-dictionary
      (expand-file-name "misc/ispell_personal" doom-private-dir))

;; Julia setup
(after! lsp-julia
  (setq lsp-julia-default-environment "~/.julia/environments/v1.9"))

;; Jupyter-Julia in org-babel
(after! org
  (require 'jupyter)
  (require 'ob-jupyter)
  (add-to-list 'org-babel-load-languages '(jupyter . t))
  (setq org-babel-default-header-args:jupyter-julia '((:session . "julia")
                                                      (:kernel  . "julia-1.9")
                                                      (:async   . "no")
                                                      (:results . "value")
                                                      (:exports . "both")
                                                      (:output  . "both"))))

;; yasnippet
(use-package! yasnippet
  :config
  ;; It will test whether it can expand, if yes, change cursor color
  (defun my/change-cursor-color-if-yasnippet-can-fire (&optional field)
    (interactive)
    (setq yas--condition-cache-timestamp (current-time))
    (let (templates-and-pos)
      (unless (and yas-expand-only-for-last-commands
                   (not (member last-command
                                yas-expand-only-for-last-commands)))
        (setq templates-and-pos (if field
                                    (save-restriction
                                      (narrow-to-region (yas--field-start field)
                                                        (yas--field-end field))
                                      (yas--templates-for-key-at-point))
                                  (yas--templates-for-key-at-point))))
      (set-cursor-color (if (and templates-and-pos (first templates-and-pos)
                                 (eq evil-state 'insert))
                            (doom-color 'red)
                          (face-attribute 'default :foreground)))))
  :hook (post-command . my/change-cursor-color-if-yasnippet-can-fire))

(use-package! cape-yasnippet
  :after (corfu yasnippet)
  :init
  (add-to-list 'completion-at-point-functions #'cape-yasnippet))

;;;;;;;;;;;;;;;;;;;;;;;
;; org mode settings ;;
;;;;;;;;;;;;;;;;;;;;;;;

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/Zhen_WU/org/")
(add-hook! 'org-mode-hook (electric-indent-local-mode -1))

(use-package! org-modern
  :hook ((org-modern-mode . my/org-modern-spacing)
         (org-mode . org-modern-mode))
  :config
  (defun my/org-modern-spacing ()
    (setq-local line-spacing
                (if org-modern-mode
                    0.1 0.1)))
  (setq org-modern-star '("◉" "○" "✸" "✿" "✤" "✜" "◆" "▶")
        org-modern-table-vertical 1
        org-modern-table-horizontal 0.2
        org-modern-list '((43 . "➤")
                          (45 . "–")
                          (42 . "•"))
        org-modern-todo-faces
        '(("TODO" :inverse-video t :inherit org-todo)
          ("PROJ" :inverse-video t :inherit +org-todo-project)
          ("STRT" :inverse-video t :inherit +org-todo-active)
          ("[-]"  :inverse-video t :inherit +org-todo-active)
          ("HOLD" :inverse-video t :inherit +org-todo-onhold)
          ("WAIT" :inverse-video t :inherit +org-todo-onhold)
          ("[?]"  :inverse-video t :inherit +org-todo-onhold)
          ("KILL" :inverse-video t :inherit +org-todo-cancel)
          ("NO"   :inverse-video t :inherit +org-todo-cancel))
        org-modern-footnote
        (cons nil (cadr org-script-display))
        org-modern-block-fringe nil
        org-modern-block-name
        '((t . t)
          ("src" "»" "«")
          ("example" "»–" "–«")
          ("quote" "❝" "❞")
          ("export" "⏩" "⏪"))
        org-modern-progress nil
        org-modern-priority nil
        org-modern-horizontal-rule (make-string 36 ?─)
        org-modern-keyword
        '((t . t)
          ("title" . "𝙏")
          ("subtitle" . "𝙩")
          ("author" . "𝘼")
          ("email" . #("" 0 1 (display (raise -0.14))))
          ("date" . "𝘿")
          ("property" . "☸")
          ("options" . "⌥")
          ("startup" . "⏻")
          ("macro" . "🄼")
          ("bind" . #("" 0 1 (display (raise -0.1))))
          ("bibliography" . "")
          ("print_bibliography" . #("" 0 1 (display (raise -0.1))))
          ("cite_export" . "⮭")
          ("print_glossary" . #("ᴬᶻ" 0 1 (display (raise -0.1))))
          ("glossary_sources" . #("" 0 1 (display (raise -0.14))))
          ("include" . "⇤")
          ("setupfile" . "⇚")
          ("html_head" . "🅷")
          ("html" . "🅗")
          ("latex_class" . "🄻")
          ("latex_class_options" . #("🄻" 1 2 (display (raise -0.14))))
          ("latex_header" . "🅻")
          ("latex_header_extra" . "🅻⁺")
          ("latex" . "🅛")
          ("beamer_theme" . "🄱")
          ("beamer_color_theme" . #("🄱" 1 2 (display (raise -0.12))))
          ("beamer_font_theme" . "🄱𝐀")
          ("beamer_header" . "🅱")
          ("beamer" . "🅑")
          ("attr_latex" . "🄛")
          ("attr_html" . "🄗")
          ("attr_org" . "⒪")
          ("call" . #("" 0 1 (display (raise -0.15))))
          ("name" . "⁍")
          ("header" . "›")
          ("caption" . "☰")
          ("results" . "➘")))
  (custom-set-faces! '(org-modern-statistics
                       :inherit org-checkbox-statistics-todo)))

(use-package! org-appear
  :hook
  (org-mode . org-appear-mode)
  :config
  (setq org-appear-autoemphasis t
        org-appear-autosubmarkers t
        org-appear-autolinks nil)
  ;; for proper first-time setup, `org-appear--set-elements'
  ;; needs to be run after other hooks have acted.
  (run-at-time nil nil #'org-appear--set-elements))

(after! org
  (after! org-noter
    (setq org-noter-hide-other nil
          org-noter-notes-search-path '("~/Zhen_WU/org/org-roam/notes/")
          org-noter-separate-notes-from-heading t
          org-noter-always-create-frame t)
    (map!
     :after org-noter
     :map org-noter-notes-mode-map
     :desc "Insert note"
     "C-M-i" #'org-noter-insert-note
     :desc "Insert precise note"
     "C-M-p" #'org-noter-insert-precise-note
     :desc "Go to previous note"
     "C-M-k" #'org-noter-sync-prev-note
     :desc "Go to next note"
     "C-M-j" #'org-noter-sync-next-note
     :desc "Create skeleton"
     "C-M-s" #'org-noter-create-skeleton
     :desc "Kill session"
     "C-M-q" #'org-noter-kill-session)
    (map!
     :after org-noter
     :map org-noter-doc-mode-map
     :desc "Insert note"
     "C-M-i" #'org-noter-insert-note
     :desc "Insert precise note"
     "C-M-p" #'org-noter-insert-precise-note
     :desc "Go to previous note"
     "C-M-k" #'org-noter-sync-prev-note
     :desc "Go to next note"
     "C-M-j" #'org-noter-sync-next-note
     :desc "Create skeleton"
     "C-M-s" #'org-noter-create-skeleton
     :desc "Kill session"
     "C-M-q" #'org-noter-kill-session)))
(after! org
  (after! org-roam
    (setq org-roam-directory "~/Zhen_WU/org/org-roam/")
    (add-hook 'after-init-hook 'org-roam-mode)
    ;; org-roam-bibtex stuff
    (use-package! org-roam-bibtex)
    (org-roam-bibtex-mode)
    (setq orb-preformat-keywords
          '("citekey" "title" "url" "author-or-editor" "keywords" "file")
          orb-process-file-keyword t
          orb-attached-file-extensions '("pdf"))
    ;; Function to capture quotes from pdf
    (defun org-roam-capture-pdf-active-region ()
      (let* ((pdf-buf-name (plist-get org-capture-plist :original-buffer))
             (pdf-buf (get-buffer pdf-buf-name)))
        (if (buffer-live-p pdf-buf)
            (with-current-buffer pdf-buf
              (car (pdf-view-active-region-text)))
          (user-error "Buffer %S not alive" pdf-buf-name))))
    ;; org-roam-ui
    (use-package! org-roam-ui
      :config
      (setq org-roam-ui-sync-theme t
            org-roam-ui-follow t
            org-roam-ui-update-on-save t))

    ;; Workaround for org-roam minibuffer issues
    (defun my/org-roam-node-read--to-candidate (node template)
      "Return a minibuffer completion candidate given NODE.
  TEMPLATE is the processed template used to format the entry."
      (let ((candidate-main (org-roam-node--format-entry
                             template
                             node
                             (1- (frame-width)))))
        (cons (propertize candidate-main 'node node) node)))
    (advice-add 'org-roam-node-read--to-candidate
                :override #'my/org-roam-node-read--to-candidate)))

(use-package! citar
  :hook
  (LaTeX-mode . citar-capf-setup)
  (org-mode . citar-capf-setup)
  :config
  (setq! citar-bibliography '("~/Zhen_WU/org/org-roam/library.bib"))
  (setq! citar-library-paths '("~/Zhen_WU/org/org-roam/files/")
         citar-notes-paths '("~/Zhen_WU/org/org-roam/notes/")))
(after! org-roam-bibtex
  (use-package! citar-org-roam
    :config
    (citar-register-notes-source
     'orb-citar-source (list :name "Org-Roam Notes"
                             :category 'org-roam-node
                             :items #'citar-org-roam--get-candidates
                             :hasitems #'citar-org-roam-has-notes
                             :open #'citar-org-roam-open-note
                             :create #'orb-citar-edit-note
                             :annotate #'citar-org-roam--annotate))
    (setq citar-notes-source 'orb-citar-source)
    (setq citar-org-roam-subdir "~/Zhen_WU/org/org-roam/notes/")
    (citar-org-roam-mode)
    (setq org-roam-capture-templates
          '(("d" "default" plain
             "%?"
             :target
             (file+head
              "%<%Y%m%d%H%M%S>-${slug}.org"
              "#+title: ${note-title}\n")
             :unnarrowed t)
            ("n" "literature note" plain
             "%?"
             :target
             (file+head
              "%(expand-file-name (or citar-org-roam-subdir \"\")
                 org-roam-directory)/${citekey}.org"
              "#+title: ${citekey} . ${note-title}.\n
               #+created: %U\n
               #+last_modified: %U\n\n")
             :unnarrowed t)))
    (setq citar-org-roam-capture-template-key "n")))

;; org latex preview
(use-package! org-latex-preview
  :after org
  :hook ((org-mode . org-latex-preview-auto-mode))
  :config
  (pushnew! org-latex-preview--ignored-faces 'org-list-dt 'fixed-pitch)
  (setq org-latex-preview-numbered     t
        org-startup-with-latex-preview t
        org-latex-preview-width 0.8
        org-latex-preview-processing-indicator 'face
        org-latex-preview-preamble
        "\\documentclass{article}\n[DEFAULT-PACKAGES]\n[PACKAGES]
         \\usepackage[dvipsnames,svgnames]{xcolor}
         \\usepackage[sfdefault]{AlegreyaSans}
         \\usepackage{newtxsf}"))
(after! org-src
  (add-to-list 'org-src-block-faces '("latex" (:inherit default :extend t))))
