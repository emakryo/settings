;; various

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector
   ["#242424" "#e5786d" "#95e454" "#cae682" "#8ac6f2" "#333366" "#ccaa8f" "#f6f3e8"])
 '(c-default-style
   (quote
    ((c-mode . "linux")
     (java-mode . "java")
     (awk-mode . "awk")
     (other . "gnu"))))
 '(column-number-mode t)
 '(cua-enable-cua-keys nil)
 '(cua-mode t nil (cua-base))
 '(custom-enabled-themes nil)
 '(display-time-24hr-format t)
 '(display-time-day-and-date t)
 '(display-time-format "%R %m/%e")
 '(display-time-mode t)
 '(gdb-many-windows nil)
 '(global-hl-line-mode t)
 '(global-linum-mode t)
 '(global-undo-tree-mode t)
 '(global-whitespace-mode t)
 '(helm-gtags-cache-select-result t)
 '(helm-mode-reverse-history nil)
 '(indent-tabs-mode nil)
 '(inhibit-startup-screen t)
 '(linum-format "%4d ")
 '(markdown-enable-math t)
 '(package-archives
   (quote
    (("marmalade" . "http://marmalade-repo.org/packages/")
     ("melpa" . "http://melpa.milkbox.net/packages/")
     ("gnu" . "http://elpa.gnu.org/packages/"))))
 '(shell-pop-shell-type (quote ("term" "*terminal*" (lambda nil (multi-term)))))
 '(tab-width 4)
 '(term-bind-key-alist
   (quote
    (("C-y" . term-paste)
     ("C-c C-c" lambda nil
      (interactive)
      (term-send-raw-string ""))
     ("C-c C-x" lambda nil
      (interactive)
      (term-send-raw-string ""))
     ("C-c C-e" . term-send-esc)
     ("C-s" . isearch-forward)
     ("C-r" . isearch-backward)
     ("C-m" . term-send-return)
     ("M-f" . term-send-forward-word)
     ("M-b" . term-send-backward-word)
     ("M-o" . term-send-backspace)
     ("M-p" . term-send-up)
     ("M-n" . term-send-down)
     ("M-M" . term-send-forward-kill-word)
     ("M-N" . term-send-backward-kill-word)
     ("<C-backspace>" . term-send-backward-kill-word)
     ("M-r" . term-send-reverse-search-history)
     ("M-," . term-send-raw)
     ("M-." . comint-dynamic-complete))))
 '(term-unbind-key-list (quote ("C-x" "C-c" "<ESC>")))
 '(tramp-default-method "ssh")
 '(web-mode-code-indent-offset 2)
 '(web-mode-css-indent-offset 2)
 '(web-mode-markup-indent-offset 2)
 '(web-mode-sql-indent-offset 2)
 '(whitespace-action (quote (auto-cleanup)))
 '(whitespace-display-mappings
   (quote
    ((space-mark 12288
                 [9633])
     (tab-mark 9
               [187 9]
               [92 9]))))
 '(whitespace-space-regexp "\\(　+\\)")
 '(whitespace-style
   (quote
    (face tabs spaces trailing space-before-tab empty space-after-tab space-mark tab-mark)))
 '(windmove-wrap-around t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(highlight ((t (:background "color-52"))))
 '(rainbow-delimiters-depth-1-face ((t (:foreground "red"))))
 '(rainbow-delimiters-depth-2-face ((t (:foreground "orange red"))))
 '(rainbow-delimiters-depth-3-face ((t (:foreground "orange"))))
 '(rainbow-delimiters-depth-4-face ((t (:foreground "yellow"))))
 '(rainbow-delimiters-depth-5-face ((t (:foreground "yellow green"))))
 '(rainbow-delimiters-depth-6-face ((t (:foreground "spring green"))))
 '(rainbow-delimiters-depth-7-face ((t (:foreground "cyan"))))
 '(rainbow-delimiters-depth-8-face ((t (:foreground "royal blue"))))
 '(rainbow-delimiters-depth-9-face ((t (:foreground "medium orchid"))))
 '(undo-tree-visualizer-active-branch-face ((t (:foreground "white" :weight bold))))
 '(whitespace-empty ((t (:background "dark gray"))))
 '(whitespace-space ((t (:background "#232323" :foreground "dark red" :weight bold))))
 '(whitespace-tab ((t (:background "#232323" :foreground "LightSkyBlue" :underline t))))
 '(whitespace-trailing ((t (:background "#232323" :foreground "DeepPink" :underline t :weight bold)))))

;; package
(defvar my/installed-packages
  '(auto-complete
    expand-region
    flycheck
;    haskell-mode
    helm
;    helm-gtags
;    tuareg            ;; for ocaml
;    markdown-mode
    magit
    multiple-cursors
    multi-term
;    php-mode
    rainbow-delimiters
    shell-pop
    undo-tree
    use-package
;    web-mode
    ))

(package-initialize)
(unless (null (delq t (mapcar 'package-installed-p my/installed-packages)))
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))
(require 'bind-key)

;; auto-complete
(use-package auto-complete-config
  :ensure auto-complete
  :config
  (add-to-list 'ac-dictionary-directories "~/.emacs.d/ac-dict")
  (ac-config-default))

;; expand-region
(use-package expand-region
  :ensure t
  :bind (("C-." . er/expand-region)
         ("C-," . er/contract-region)))

;; multiple-cursors
(use-package multiple-cursors
  :ensure t
  :bind (("M-RET" . mc/edit-lines)
         ("C-c p ." . mc/mark-next-like-this)
         ("C-c p ," . mc/mark-previous-like-this)
         ("C-c p ]" . mc/mark-all-like-this)))

;; flycheck
(use-package flycheck
  :ensure t
  :config
  (add-hook 'after-init-hook #'global-flycheck-mode))

;; haskell
(use-package haskell-mode
;  :ensure t
  :config
  (add-hook 'haskell-mode-hook 'turn-on-haskell-indentation)
)

;; helm
(use-package helm-config
  :ensure helm
  :config
  (helm-mode 1))

(use-package helm-gtags
;  :ensure t
  :bind (("C-c C-t C-f" . helm-gtags-find-tag)
         ("C-c C-t C-r" . helm-gtags-find-rtag)
         ("C-c C-t C-s" . helm-gtags-find-symbol)
         ("C-c C-t C-p" . helm-gtags-pop-stack))
  :config
  (add-hook 'c-mode-hook 'helm-gtags-mode)
  (add-hook 'asm-mode-hook 'helm-gtags-mode))

;; magit
(if (version<= "24.4" emacs-version)
    (use-package magit
      :ensure t
      :config
      (setq magit-last-seen-setup-instructions "1.4.0")))


;; markdown mode
(use-package markdown-mode
;  :ensure t
  :mode "\\.md\\'"
  :config
  (bind-key "C-c C-p" 'browse-url-of-buffer markdown-mode-map)
  (add-hook 'markdown-mode-hook
            '(lambda () (setq-local whitespace-action nil)))) ;; fixme

(use-package multi-term
  :ensure t
  :bind* ("C-x t" . multi-term))

;; rainbow-delimiters
(use-package rainbow-delimiters
  :ensure t
  :config
  (add-hook 'prog-mode-hook #'rainbow-delimiters-mode))

;; shell-pop
(use-package shell-pop
  :ensure t
  :commands shell-pop
  :bind* ("C-x C-x" . shell-pop))

;; undo tree
(use-package undo-tree
  :ensure t
  :config
  (global-undo-tree-mode))


;; web-mode
(use-package web-mode
;  :ensure t
  :mode "\\.html?$")


;; move window by cursor
(windmove-default-keybindings)

;; tramp
(require 'tramp)
(defadvice tramp-do-copy-or-rename-file-out-of-band
  (around ad-tramp-do-copy-or-rename-file-out-of-band activate)
  (let ((default-directory "/"))
    (unless (tramp-tramp-file-p (ad-get-arg 1))
      (ad-set-arg 1 (substring
                     (shell-command-to-string
                      (concat "cygpath -u " (shell-quote-argument (ad-get-arg 1))))
                     0 -1)))
    (unless (tramp-tramp-file-p (ad-get-arg 2))
      (ad-set-arg 2 (substring
                     (shell-command-to-string
                      (concat "cygpath -u " (shell-quote-argument (ad-get-arg 2))))
                     0 -1))))
  ad-do-it
  (sit-for 0.1))

;; hs-minor-mode
(use-package hideshow
  :commands hs-minor-mode
  :bind (("C-c C-h C-t" . hs-toggle-hiding)
         ("C-c C-h C-a" . hs-hide-all))
  :init
  (add-hook 'c-mode-common-hook 'hs-minor-mode)
  (add-hook 'js-mode-hook 'hs-minor-mode))

;; octave
(use-package octave-mode
  :mode "\\.m$")

;; misc
(defun my/run-make ()
  (interactive) (compile "make"))
(bind-key* "C-x m" 'my/run-make)
(prefer-coding-system 'utf-8)

;; c and assembly indent with tab
(add-hook 'asm-mode-hook
          '(lambda ()
             (setq indent-tabs-mode t)))
(add-hook 'c-mode-hook
          '(lambda ()
             (setq indent-tabs-mode t)))


;; open file using sudo
;; https://tsdh.wordpress.com/2008/08/20/re-open-read-only-files-as-root-automagically/
(defadvice find-file (around my/find-file activate)
  "Open FILENAME using tramp's sudo method if it's read-only."
  (if (and (not (file-writable-p (ad-get-arg 0)))
           (y-or-n-p (concat "File "
                             (ad-get-arg 0)
                             " is read-only.  Open it as root? ")))
      (my/find-file-sudo (ad-get-arg 0))
    ad-do-it))

(defun my/find-file-sudo (file)
  "Opens FILE with root privileges."
  (interactive "F")
  (set-buffer (find-file (concat "/sudo::" file))))

;; customize

;; load local settings
(if window-system
    (load (concat (getenv "HOME") "/.emacs.d/local_init.el")))
