;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Emacs config
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Global variables.

(defvar my-keys-minor-mode-map (make-keymap)
  "Keymap for my-keys-minor-mode. See its docstring for more
details.")

(define-minor-mode my-keys-minor-mode
  "A minor mode so that all bindings assingned on the
my-keys-minor-mode-map override undesired major modes
bindings. We use a minor mode to override global keys. This is
also rather useful to list all personal global bindings: just
rgrep `my-keys-minor-mode-map' over `~/.emacs.d'.

Example: to assign some-function to C-i, use

  (define-key my-keys-minor-mode-map (kbd \"C-i\") 'some-function)"
  t " my-keys" 'my-keys-minor-mode-map)
(add-hook 'minibuffer-setup-hook (lambda () (my-keys-minor-mode 0)))

(defvar emacs-cache-folder "~/.cache/emacs/"
  "Cache folder is everything we do not want to track along with
  the configuration files.")
(if (not (file-directory-p emacs-cache-folder))
    (make-directory emacs-cache-folder t))

;; Load config easily.
(add-to-list 'load-path "~/.emacs.d/lisp")

;; Local plugin folder for quick install. All files in this folder will be
;; accessible to Emacs config. This is done to separate the versioned config
;; files from the external packages. For instance you can put package.el in
;; there for Emacs <24.
(add-to-list 'load-path "~/.emacs.d/local")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load main config

(require 'functions nil t)
(require 'main nil t)
(require 'theme nil t)
(require 'personal nil t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Vanilla

;; Major modes
(add-hook 'awk-mode-hook      (lambda () (require 'mode-awk)))
(add-hook 'c++-mode-hook      (lambda () (require 'mode-cc)))
(add-hook 'c-mode-hook        (lambda () (require 'mode-cc)))
(add-hook 'sgml-mode-hook     (lambda () (require 'mode-sgml)))
(add-hook 'js-mode-hook       (lambda () (require 'mode-js)))
(add-hook 'latex-mode-hook    (lambda () (require 'mode-latex)))
(add-hook 'makefile-mode-hook (lambda () (require 'mode-makefile)))
(add-hook 'nroff-mode-hook    (lambda () (require 'mode-nroff)))
(add-hook 'perl-mode-hook     (lambda () (require 'mode-perl)))
(add-hook 'python-mode-hook   (lambda () (require 'mode-python)))
(add-hook 'sh-mode-hook       (lambda () (require 'mode-sh)))
(add-hook 'tex-mode-hook      (lambda () (require 'mode-tex)))
(add-hook 'texinfo-mode-hook  (lambda () (require 'mode-texinfo)))

;; Minor modes
(add-hook 'dired-mode-hook  (lambda () (require 'mode-dired)))
(add-hook 'ediff-mode-hook  (lambda () (require 'mode-ediff)))
(add-hook 'eshell-mode-hook (lambda () (require 'mode-eshell)))
(add-hook 'gud-mode-hook    (lambda () (require 'mode-gud)))
(add-hook 'octave-mode-hook (lambda () (require 'mode-octave)))
(add-hook 'org-mode-hook    (lambda () (require 'mode-org)))

;; Tools
(autoload 'pdf-view "tool-pdf" nil t)
(autoload 'pdf-compress "tool-pdf" nil t)

(autoload 'itranslate "tool-itranslate" nil t)
(autoload 'itranslate-lines "tool-itranslate" nil t)
(autoload 'itranslate-region "tool-itranslate" nil t)

(require 'smiext "tool-smiext")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; External

(when (require 'package nil t)
  ;; (add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/"))
  (add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/"))
  (setq package-user-dir (concat emacs-cache-folder "elpa"))
  (setq package-pinned-packages '())

  (defun init-extra-packages ()
    (interactive)
    (unless (file-exists-p package-user-dir)
      (package-refresh-contents))
    (let ((pkglist package-pinned-packages))
      (while pkglist
        (when (not (package-installed-p (car pkglist)))
          (package-install (car pkglist)))
        (setq pkglist (cdr pkglist)))))

  (package-initialize))

;;------------------------------------------------------------------------------
;; External modes

(add-to-list 'load-path "/usr/share/asymptote")
(autoload 'asy-mode "asy-mode.el" "Asymptote major mode." t)
(autoload 'lasy-mode "asy-mode.el" "Hybrid Asymptote/Latex major mode." t)
(autoload 'asy-insinuate-latex "asy-mode.el" "Asymptote insinuate LaTeX." t)
(add-to-list 'auto-mode-alist '("\\.asy$" . asy-mode))

(autoload 'maxima-mode "maxima" "Maxima mode" t)
(autoload 'maxima "maxima" "Maxima interaction" t)
(setq auto-mode-alist (cons '("\\.mac" . maxima-mode) auto-mode-alist))

(load-external "\\.bbcode\\'" 'bbcode-mode)
(add-hook 'bbcode-mode-hook (lambda () (require 'mode-bbcode)))

(load-external "\\.l\\'" 'flex-mode nil 'c-mode)
(load-external "\\.yy?\\'" 'bison-mode nil 'c-mode)

(load-external "\\.vert\\'\\|\\.frag\\'\\|\\.glsl\\'" 'glsl-mode nil 'c-mode)

(add-to-list 'package-pinned-packages 'go-mode)
(load-external "\\.go\\'" 'go-mode)
(add-hook 'go-mode-hook (lambda () (require 'mode-go)))

(load-external "\\.dot\\'" 'graphviz-dot-mode)
(add-hook 'graphviz-dot-mode-hook (lambda () (require 'mode-dot)))

(add-to-list 'package-pinned-packages 'lua-mode)
(load-external "\\.lua\\'" 'lua-mode nil 'sh-mode)
(add-hook 'lua-mode-hook (lambda () (require 'mode-lua)))

(add-to-list 'package-pinned-packages 'markdown-mode)
(load-external "\\.md\\'\\|\\.markdown\\'" 'markdown-mode)
;; If we need more option, add it to a dedicated file.
(add-hook 'markdown-mode-hook (lambda () (set (make-local-variable 'paragraph-start) "
")))

(load-external "\\.wiki\\'" 'mediawiki 'mediawiki-mode)
(add-hook 'mediawiki-mode-hook (lambda () (require 'mode-mediawiki)))

;; .po support. This mode has no hooks.
(load-external "\\.po\\'\\|\\.po\\." 'po-mode)
(when (fboundp 'po-find-file-coding-system)
  (modify-coding-system-alist 'file "\\.po\\'\\|\\.po\\." 'po-find-file-coding-system))

;;------------------------------------------------------------------------------
;; External tools

;; (autoload 'guess-style-set-variable "guess-style" nil t)
;; (autoload 'guess-style-guess-variable "guess-style")
;; (autoload 'guess-style-guess-all "guess-style" nil t)
;; (setq guess-style-info-mode 1)
;; (add-hook 'prog-mode-hook (lambda () (ignore-errors (guess-style-guess-all))))

(add-to-list 'package-pinned-packages 'multiple-cursors)
(add-to-list 'package-pinned-packages 'phi-search)
(when (require 'multiple-cursors nil t)
  (setq mc/list-file (concat emacs-cache-folder "mc-lists.el"))
  ;; Load the file at the new location.
  (load mc/list-file t)
  (global-unset-key (kbd "C-<down-mouse-1>"))
  (define-key my-keys-minor-mode-map (kbd "C-<mouse-1>") 'mc/add-cursor-on-click)
  (define-key my-keys-minor-mode-map (kbd "C-x M-r") 'mc/edit-lines)
  (define-key my-keys-minor-mode-map (kbd "C-x M-m") 'mc/mark-more-like-this-extended)
  (define-key my-keys-minor-mode-map (kbd "C-x M-l") 'mc/mark-all-like-this-dwim)
  ;; Search compatible with mc.
  (require 'phi-search nil t))

(when (require 'dired+ nil t)
  (toggle-diredp-find-file-reuse-dir 1))

(when (require 'powerline nil t)
  (powerline-default-theme))

(when (require 'helm-fuzzy-find nil t)
  (define-key my-keys-minor-mode-map (kbd "C-c C-/") 'helm-fuzzy-find))

;; TODO: fzf and helm-fuzzy-find are in direct competition. Test and pick the best.
;; helm-ff has better integration, but does not print anything initially.
(require 'fzf nil t)

(when (require 'auto-complete-config nil t)
  (ac-config-default))

;; Other:
;; go-scratch, fuzzy (for auto-complete).

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; We need to put it at the end to make sure it doesn't get overriden by other
;; minor modes.
(my-keys-minor-mode 1)

;; Local hook. You can use it to set system specific variables, such as the
;; external web browser or pdf viewer. You can also backport feature for old
;; Emacs. For instance:
; (setq pdf-viewer "evince")
; (setq pdf-viewer-args nil)
; (mapcar
;  (lambda (mode-hook)
;    (add-hook mode-hook (lambda () (run-hooks 'prog-mode-hook))))
;  '(asm-mode-hook awk-mode-hook c++-mode-hook c-mode-hook
;                  emacs-lisp-mode-hook lisp-mode-hook lua-mode-hook
;                  makefile-mode-hook octave-mode-hook perl-mode-hook
;                  python-mode-hook scheme-mode-hook sh-mode-hook))
(load "local" t t)

;; End of file
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
