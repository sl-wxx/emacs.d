;; color theme
(add-to-list 'custom-theme-load-path "~/.emacs.d/my/")
(load-theme 'plan9 t)

(add-to-list 'load-path "~/.emacs.d/my")

;; set recent-jump
(require 'recent-jump)

(if (file-exists-p "~/.emacs.d/my/keybind.el") (load-file "~/.emacs.d/my/keybind.el"))


