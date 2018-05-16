;; my leader key
(define-prefix-command 'my-leader)
(global-set-key (kbd ",") 'my-leader)

;; define ", " to insert ","
(define-key my-leader (kbd "SPC") 'insert-comma-space)
(defun insert-comma-space ()
  (interactive)
  (insert ", "))

;; sdcv
(define-key my-leader (kbd "<tab>") 'sdcv-search-pointer)

;; jump: recent-jump & gtags
(define-prefix-command 'my-leader-jump)
(define-key my-leader (kbd "j") 'my-leader-jump)
(define-key my-leader-jump (kbd "d") 'cousel-gtags-find-definition)
(define-key my-leader-jump (kbd "r") 'cousel-gtags-find-reference)
(define-key my-leader-jump (kbd "f") 'recent-jump-jump-forward)
(define-key my-leader-jump (kbd "b") 'recent-jump-jump-backward)
