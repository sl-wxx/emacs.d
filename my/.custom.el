;; color theme
(add-to-list 'custom-theme-load-path "~/.emacs.d/my/")
(load-theme 'plan9 t)

(add-to-list 'load-path "~/.emacs.d/my")

;; set recent-jump
(require 'recent-jump)
(global-set-key (kbd "C-o") 'recent-jump-jump-backward)
(global-set-key (kbd "M-o") 'recent-jump-jump-forward)

;; set sdcv key
(global-set-key (kbd "C-h <tab>") 'sdcv-search-pointer)

