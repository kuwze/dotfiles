;;; Main options

;;; Minimal UI. Run early to hide it as soon as possible.
(setq inhibit-startup-screen t)
(menu-bar-mode -1)
;;; `tool-bar-mode' and `scroll-bar-mode' might not be compiled in.
(when (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))

;;; Remember last cursor position.
(require 'saveplace)
(setq save-place-file (concat emacs-cache-folder "saveplace"))
(setq-default save-place-mode t)
;;; When the daemon is killed abruptly, places are not saved. Adding this hook
;;; allows to save places at a strategic moment.
(add-hook 'before-save-hook 'save-place-kill-emacs-hook)

;;; url-cookie
(setq url-cookie-file (concat emacs-cache-folder "url.cookies"))

;;; Bookmark file to cache folder.
(setq bookmark-default-file (concat emacs-cache-folder "emacs.bmk"))

;;; Recent files.
(setq recentf-save-file (concat emacs-cache-folder "recentf"))

;;; Disable autosave features.
(setq auto-save-default nil)
(setq auto-save-list-file-prefix nil)

;;; Place backup files in specific directory.
(setq backup-directory-alist
      `(("." . ,(concat emacs-cache-folder "backups/"))))

;;; Default mode
(setq-default major-mode 'text-mode)

;;; Disable suspend key since it is useless on Emacs server.
(global-unset-key (kbd "C-z"))
(global-unset-key (kbd "C-x C-z"))

;;; Make questions less annoying.
(defalias 'yes-or-no-p 'y-or-n-p)

;;; Allow some protected functions.
(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)
(put 'narrow-to-page 'disabled nil)
(put 'dired-find-alternate-file 'disabled nil)

;;; Print column number in mode line.
(column-number-mode 1)

;;; Print buffer size in mode line.
(size-indication-mode 1)

;;; Kill whole line including \n.
(setq kill-whole-line t)

;;; Alternative scrolling
(setq scroll-error-top-bottom t)

;;; Narrow page navigation.
(define-key mickey-minor-mode-map (kbd "C-x M-n") (lambda () (interactive) (narrow-to-page 1)))
(define-key mickey-minor-mode-map (kbd "C-x M-p") (lambda () (interactive) (narrow-to-page -1)))

;;; Line numbers
;;; Adding to `find-file-hook' ensures it will work for every file, regardless of
;;; the mode, but it won't work for buffers without files nor on mode change.
(add-hook 'prog-mode-hook 'linum-mode)
(add-hook 'text-mode-hook 'linum-mode)
;;; Emacs-nox does not display a fringe after the linum: Setting linum-format in
;;; linum-before-numbering-hook is not the right approach as it will change the
;;; type of linum-format in the middle. See linum-update-window.
;;; See http://stackoverflow.com/questions/3626632/right-align-line-numbers-with-linum-mode
;;; and http://stackoverflow.com/questions/3626632/right-align-line-numbers-with-linum-mode.
;;; The complexity is not worth the benefit.

;;; Indentation
(setq-default tab-width 2)
(defvaralias 'standard-indent 'tab-width)
(setq-default indent-tabs-mode t)

;;; This needs to be set globally since they are defined as local variable and
;;; Emacs does not know how to set an alias on a local variable.
(defvaralias 'c-basic-offset 'tab-width)
(defvaralias 'sh-basic-offset 'tab-width)

;;; Line by line scrolling
(setq scroll-step 1)

;;; There is no prog-mode-hook on Emacs<24.
(require 'tool-page) ; for `page-number-mode'
(add-hook 'prog-mode-hook 'page-number-mode)

(define-key mickey-minor-mode-map (kbd "<f5>") 'whitespace-mode)
(setq
 whitespace-style
 '(face empty indentation space-after-tab space-before-tab tab-mark trailing))
;;; `whitespace-report' will mistakenly always report empty lines at
;;; beginning and end of buffer as long as there is at least one empty line.
;;; `whitespace-cleanup' works properly however.
;;; DONE: Reported at http://debbugs.gnu.org/cgi/bugreport.cgi?bug=23740.
;; (setq whitespace-action '(report-on-bogus))

;;; WARNING: this can break some configuration files needing whitespaces at the
;;; end. This can also slow down saving on big files.  Some modes (e.g. lisp) run
;;; `fmt' in their local hook, which is redundant with this.
;; (require 'functions) ; for `fmt'
;; (add-hook 'before-save-hook 'fmt)
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;;; Hippie expand
;; (define-key mickey-minor-mode-map (kbd "M-/") 'hippie-expand)

;;; Abbreviation support
(setq-default abbrev-mode t)

;;; Auto-fill
(when (getenv "MANWIDTH")
  (setq-default fill-column (string-to-number (getenv "MANWIDTH"))))
(add-hook 'text-mode-hook 'turn-on-auto-fill)
;; (setq sentence-end-double-space nil)

;;; Enforce horizontal splitting. 140 means that the window is large enough to
;;; hold 2 other windows of 70 columns.
(setq split-height-threshold nil)
(setq split-width-threshold 140)

;;; Windmove mode
;; By default, it allows easy window switching with Shift+arrows. I like to
;; stick to the home-row, but to avoid shadowing other binding I exceptionaly use
;; 'super' (normally reserved to the WM).
(when (fboundp 'windmove-default-keybindings)
  (define-key mickey-minor-mode-map (kbd "M-s-h") 'windmove-left)
  (define-key mickey-minor-mode-map (kbd "M-s-j") 'windmove-down)
  (define-key mickey-minor-mode-map (kbd "M-s-k") 'windmove-up)
  (define-key mickey-minor-mode-map (kbd "M-s-l") 'windmove-right))

;;; Make Emacs use environment browser, or w3m if BROWSER is not set.
(setq browse-url-generic-program
      (executable-find
       (let ((b (getenv "BROWSER")))
         (if b b "w3m" )))
      browse-url-browser-function 'browse-url-generic)

;;; Default ispell dictionary. If not set, Emacs uses the current locale.
(setq ispell-dictionary "english")

;;; Long paragraphs. Useful for quick navigation with backward-paragraph and
;;; forward-paragraph.
(setq paragraph-start "
")

;;; Show matching parenthesis
(show-paren-mode 1)
;;; By default, there’s a small delay before showing a matching parenthesis. Set
;;; it to 0 to deactivate.
(setq show-paren-delay 0)
(setq show-paren-when-point-inside-paren t)

;;; Electric Pairs to auto-complete () [] {} "" etc. You can use it on regions.
;; (if (>= emacs-major-version 24)
;;     (electric-pair-mode 1))

;;; Spawn terminal shortcut: WM's binding is s+RET.
(define-key mickey-minor-mode-map (kbd "C-x M-RET") 'spawn-terminal)

;;; Calendar ISO display.
(setq calendar-week-start-day 1)
(setq calendar-date-style 'iso)

;;; Compilation bindings and conveniences.
(setq compilation-ask-about-save nil)
(setq compilation-scroll-output 'first-error)
(with-eval-after-load 'compile
  ;; Making `compilation-directory' local only works with `recompile'
  ;; and if `compile' is never used. In such a scenario,
  ;; `compile-command' is not saved by `recompile' itself which adds a
  ;; lot of bookkeeping.
  ;; (make-variable-buffer-local 'compilation-directory)
  ;; (make-variable-buffer-local 'compile-history)
  (make-variable-buffer-local 'compile-command))
;;; Don't set these bindings in mickey as we might have to override them from
;;; mode hooks.
(global-set-key (kbd "C-<f10>") 'compile)
(global-set-key (kbd "<f10>") (lambda () (interactive) (compile compile-command))) ; Do not use recompile since we want to change de compilation folder to the current buffer.
(global-set-key (kbd "<f11>") 'previous-error)
(global-set-key (kbd "<f12>") 'next-error)

(defadvice desktop-owner (after pry-from-cold-dead-hands activate)
  "Don't allow dead emacsen to own the desktop file."
  (when (not (emacs-process-p ad-return-value))
    (setq ad-return-value nil)))

;;; Desktop-mode
;;; Let Emacs auto-load/save sessions only when running the daemon.
;;; `server-running-p' is only useful once the daemon is started and cannot be
;;; used for initialization. We use `daemonp' instead.
(when (daemonp)
  (setq history-length 250)
  (setq desktop-dirname (concat emacs-cache-folder "desktop"))
  (unless (file-directory-p desktop-dirname)
    (make-directory desktop-dirname t))
  (setq desktop-path (list desktop-dirname))
  ;; TODO: `compile-history' should be buffer local but that does not work.
  ;; http://user42.tuxfamily.org/compile-history-local/index.html
  ;; http://stackoverflow.com/questions/22995203/one-compile-command-per-buffer-not-directory
  ;; (add-to-list 'desktop-locals-to-save 'compile-history)
  (add-to-list 'desktop-locals-to-save 'compile-command)
  (add-to-list 'desktop-locals-to-save 'ispell-local-dictionary)
  (desktop-save-mode 1))

;;; GMP documentation
(with-eval-after-load "info-look"
  (let ((mode-value (assoc 'c-mode (assoc 'symbol info-lookup-alist))))
    (setcar (nthcdr 3 mode-value)
            (cons '("(gmp)Function Index" nil "^ -.* " "\\>")
                  (nth 3 mode-value)))))

;;; Buffer names.
(require 'uniquify)
(setq uniquify-buffer-name-style 'forward)

;;; Skeleton settings
(require 'functions)
;;; Do not expand abbrevs in skeletons.
(setq-default skeleton-further-elements '((abbrev-mode nil)))
(turn-on-skeleton-markers)
(define-key mickey-minor-mode-map (kbd "C->") 'skeleton-next-position)
(define-key mickey-minor-mode-map (kbd "C-<") (lambda () (interactive) (skeleton-next-position t)))

;;; Disable prompt (but leave warning) on git symlink.
(setq vc-follow-symlinks t)

;;; Clipboard and primary selection.
;; (setq select-enable-clipboard t)
(setq select-enable-primary t)

;;; Easy code folding toggle.
;; (add-hook 'prog-mode-hook 'hs-minor-mode)
;; (add-hook 'prog-mode-hook (lambda () (local-set-key (kbd "C-c h") 'hs-toggle-hiding)))

;;; Move mouse away.
;; (mouse-avoidance-mode 'banish)
;;; That binding is not very useful and gets in the way of C-<mouse-1>.
(global-unset-key (kbd "C-<down-mouse-1>"))

;;; Display defun in mode line.
(which-function-mode)

;;; Replace maximized binding for fullscreen.
;; (define-key mickey-minor-mode-map (kbd "M-<f10>") 'toggle-frame-fullscreen)

;;; Scroll zooming.
(define-key mickey-minor-mode-map (kbd "C-<wheel-down>") 'text-scale-decrease)
(define-key mickey-minor-mode-map (kbd "C-<mouse-5>") 'text-scale-decrease)
(define-key mickey-minor-mode-map (kbd "C-<wheel-up>") 'text-scale-increase)
(define-key mickey-minor-mode-map (kbd "C-<mouse-4>") 'text-scale-increase)
(setq text-scale-mode-step 1.1)

;;; Sort
(setq sort-fold-case t)

;;; Replace not-so-useful comment-dwim binding.
(define-key mickey-minor-mode-map "\M-;" 'comment-line)

;;; In case you find eldoc too distracting.
;; (global-eldoc-mode 0)

;;; Replace `kill-buffer' binding by `kill-this-buffer'.
(define-key mickey-minor-mode-map (kbd "C-x k") 'kill-this-buffer)

(setq ediff-window-setup-function 'ediff-setup-windows-plain
      ediff-split-window-function 'split-window-horizontally)

(provide 'main)
