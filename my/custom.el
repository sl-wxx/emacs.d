;; color theme
(add-to-list 'custom-theme-load-path "~/.emacs.d/my/")
(load-theme 'plan9 t)

(add-to-list 'load-path "~/.emacs.d/my")

;; set recent-jump
(require 'recent-jump)

(if (file-exists-p "~/.emacs.d/my/key-binding.el") (load-file "~/.emacs.d/my/key-binding.el"))

(defun _set-src-buffer-read-only ()
  (let ((file-name (concat (buffer-file-name (current-buffer)))))
    (if (or
         (string-suffix-p ".c" file-name)
         (string-suffix-p ".cpp" file-name)
         (string-suffix-p ".h" file-name)
         (string-suffix-p ".hpp" file-name)
         (string-suffix-p ".java" file-name))
        (read-only-mode 1))))

(defun set-src-buffer-read-only ()
  (interactive)
  (add-hook 'find-file-hook '_set-src-buffer-read-only t))

(defun set-src-buffer-read-only-off ()
  (interactive)
  (remove-hook 'find-file-hook '_set-src-buffer-read-only))

(defun my-gud-find-file (file)
  ;; Don't get confused by double slashes in the name that comes from GDB.
  (let ((minor-mode gud-minor-mode)
        (buf (and (file-readable-p file) (find-file-noselect file 'nowarn))))
    (when buf
      (with-selected-window gdb-source-window (set-window-buffer gdb-source-window buf))
      buf)))