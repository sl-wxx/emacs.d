(define-prefix-command 'my-leading-key)

;; 由于,用作leading key, 这里提供输入,的命令
(define-key my-leading-key (kbd "SPC") 'insert-comma-space)
(defun insert-comma-space ()
  (interactive)
  (insert ", "))
(define-key my-leading-key (kbd ",") 'insert-comma)
(defun insert-comma ()
  (interactive)
  (insert ","))

;; sdcv
(define-key my-leading-key (kbd "<tab>") 'sdcv-search-pointer)

;; jump: recent-jump & gtags
(define-prefix-command 'my-leading-key-jump)
(define-key my-leading-key (kbd "j") 'my-leading-key-jump)
(define-key my-leading-key-jump (kbd "d") 'cousel-gtags-find-definition)
(define-key my-leading-key-jump (kbd "r") 'cousel-gtags-find-reference)
(define-key my-leading-key-jump (kbd "f") 'recent-jump-jump-forward)
(define-key my-leading-key-jump (kbd "b") 'recent-jump-jump-backward)




;; --------create a minor-mode to make our key-binding take precedence --------------------

(defvar my-leading-key-minor-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd ",") 'my-leading-key)
    map)
  "my-leading-key-minor-mode keymap.")

(define-minor-mode my-leading-key-minor-mode
  "A minor mode so that my key settings override annoying major modes."
  :init-value t
  :lighter " my-leading-key"
  :keymap my-leading-key-minor-mode-map)

(defun my-leading-key-minibuffer-setup-hook ()
  (my-leading-key-minor-mode 0))

(add-hook 'minibuffer-setup-hook 'my-leading-key-minibuffer-setup-hook)

(add-hook 'change-major-mode-hook 'my-leading-key-have-priority)

(defun my-leading-key-have-priority ()
  "Try to ensure that my keybindings retain priority over other minor modes."
  (unless (eq (caar minor-mode-map-alist) 'my-leading-key-minor-mode)
    (let ((mykeys (assq 'my-leading-key-minor-mode minor-mode-map-alist)))
      (assq-delete-all 'my-leading-key-minor-mode minor-mode-map-alist)
      (add-to-list 'minor-mode-map-alist mykeys))))

(defun my-leading-key-have-priority2 ()
  (unless minor-mode-overriding-map-alist
    (setq minor-mode-overriding-map-alist
          (list (cons 'my-leading-key-minor-mode my-leading-key-minor-mode-map)))))
