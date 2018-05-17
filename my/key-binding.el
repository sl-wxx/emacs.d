(defun insert-comma-space ()
  (interactive)
  (insert ", "))

(defun insert-comma ()
  (interactive)
  (insert ","))

(defhydra my-hydra (:color pink
                             :hint nil)
  "
^Insert^                   ^Find^                    ^Jump^                  ^Dictionary
^^^^^^^^------------------------------------------------------------------------------------
_,_: insert-comma          _d_: find-definition      _f_: jump-forward       _<tab>_: sdcv-search-pointer
_ _: insert-comma-space    _r_: find-reference       _b_: jump-backward      ^ ^
"
  ("," insert-comma)
  (" " insert-comma-space)
  ("d" counsel-gtags-find-definition :color blue)
  ("r" counsel-gtags-find-reference :color blue)
  ("f" recent-jump-jump-forward)
  ("b" recent-jump-jump-backward)
  ("<tab>" sdcv-search-pointer :color blue)
)


;; --------create a minor-mode to make our key-binding take precedence --------------------

(defvar my-hydra-minor-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd ",") 'my-hydra/body)
    map)
  "my-hydra-minor-mode keymap.")

(define-minor-mode my-hydra-minor-mode
  "A minor mode so that my key settings override annoying major modes."
  :init-value t
  :lighter " my-hydra"
  :keymap my-hydra-minor-mode-map)

(defun my-hydra-minibuffer-setup-hook ()
  (my-hydra-minor-mode 0))

(add-hook 'minibuffer-setup-hook 'my-hydra-minibuffer-setup-hook)

(add-hook 'change-major-mode-hook 'my-hydra-have-priority t)

(defun my-hydra-have-priority ()
  "Try to ensure that my keybindings retain priority over other minor modes."
  (unless (eq (caar minor-mode-map-alist) 'my-hydra-minor-mode)
    (let ((mykeys (assq 'my-hydra-minor-mode minor-mode-map-alist)))
      (assq-delete-all 'my-hydra-minor-mode minor-mode-map-alist)
      (add-to-list 'minor-mode-map-alist mykeys))))

(defun my-hydra-have-priority2 ()
  (unless minor-mode-overriding-map-alist
    (setq minor-mode-overriding-map-alist
          (list (cons 'my-hydra-minor-mode my-hydra-minor-mode-map)))))
