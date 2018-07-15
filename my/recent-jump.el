;;; point-undo.el --- undo/redo position

;;  Copyright (C) 2006,2008 rubikitch <rubikitch atmark ruby-lang.org>
;;  Version: $Id: point-undo.el,v 1.6 2009/10/16 20:37:37 rubikitch Exp rubikitch $

;;  This program is free software; you can redistribute it and/or modify
;;  it under the terms of the GNU General Public License as published by
;;  the Free Software Foundation; either version 2 of the License, or
;;  (at your option) any later version.
;;    This program is distributed in the hope that it will be useful,
;;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;  GNU General Public License for more details.
;;    You should have received a copy of the GNU General Public License
;;  along with this program; if not, write to the Free Software
;;  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

;;; Commentary:

;; This package allows you to undo/redo point and window-start.
;; It is like w3m's UNDO/REDO commands.

;;; Commands:
;;
;; Below are complete command list:
;;
;;  `point-undo'
;;    Undo position.
;;  `point-redo'
;;    Redo position.
;;
;;; Customizable Options:
;;
;; Below are customizable option list:
;;

;;; Setup:

;; (require 'point-undo)
;; (define-key global-map [f5] 'point-undo)
;; (define-key global-map [f6] 'point-redo)

;;; Bug Report:
;;
;; If you have problem, send a bug report via M-x point-undo-send-bug-report.
;; The step is:
;;  0) Setup mail in Emacs, the easiest way is:
;;       (setq user-mail-address "your@mail.address")
;;       (setq user-full-name "Your Full Name")
;;       (setq smtpmail-smtp-server "your.smtp.server.jp")
;;       (setq mail-user-agent 'message-user-agent)
;;       (setq message-send-mail-function 'message-smtpmail-send-it)
;;  1) Be sure to use the LATEST version of point-undo.el.
;;  2) Enable debugger. M-x toggle-debug-on-error or (setq debug-on-error t)
;;  3) Use Lisp version instead of compiled one: (load "point-undo.el")
;;  4) Do it!
;;  5) If you got an error, please do not close *Backtrace* buffer.
;;  6) M-x point-undo-send-bug-report and M-x insert-buffer *Backtrace*
;;  7) Describe the bug using a precise recipe.
;;  8) Type C-c C-c to send.
;;  # If you are a Japanese, please write in Japanese:-)

;;; History:
;; 
;; $Log: point-undo.el,v $
;; Revision 1.6  2009/10/16 20:37:37  rubikitch
;; point-undo-list records position info only when point is moved.
;;
;; Revision 1.5  2008/12/27 15:21:03  rubikitch
;; *** empty log message ***
;;
;; Revision 1.4  2008/12/27 15:20:26  rubikitch
;; *** empty log message ***
;;
;; Revision 1.3  2008/12/27 15:19:38  rubikitch
;; refactoring
;;
;; Revision 1.2  2008/12/27 14:53:54  rubikitch
;; undo/redo not only point but also window-start.
;;

;; 2006/02/27: initial version

;;; Code:
;; (eval-when-compile (require 'cl))

(setq recent-jump-hook-commands
  '(next-line
    previous-line
    isearch-forward
    isearch-backward
    end-of-buffer
    beginning-of-buffer
    pager-page-down
    pager-page-up
    beginning-of-defun
    end-of-defun
    forward-word
    backward-word
    forward-sexp
    backward-sexp
    scroll-up
    scroll-down
    find-tag
    mark-whole-buffer
    switch-to-buffer
    ido-switch-buffer
    imenu
    swiper
    goto-line
    my-hydra/counsel-gtags-find-reference-and-exit
    my-hydra/counsel-gtags-find-definition-and-exit
    my-hydra/counsel-gtags-find-symbol-and-exit
    my-hydra/gud-step
    my-hydra/gud-next
    my-hydra/gud-finish
    my-hydra/gud-until
    my-hydra/gud-refresh
    select-window
    select-window-0
    select-window-1
    select-window-2
    select-window-3
    select-window-4
    select-window-5
    select-window-6
    select-window-7
    select-window-8
    select-window-9
    ))

(setq rj-executed-commands nil)

(defun rj-start-record()
  (interactive)
  (setq rj-executed-commands (cons 'start rj-executed-commands)))

(setq rj-hook-command-executed nil)

(setq point-undo-list nil)

(setq point-redo-list nil)

(setq recent-jump-threshold 3)

;; The state of state machine.
;; The machine will be in command/undo/redo state, each after executing normal command/undo/redo
(setq rj-current-state 'initial)

(defun rj-forward ()
  (interactive)
  (unless (or (eq rj-current-state 'initial)
              (eq rj-current-state 'command))
    (rj-do-jump point-redo-list point-undo-list)
    (setq rj-current-state 'redo)
    ;;(rj-debug "rj-backward")
    ))

(defmacro rj-do-jump (list1 list2)
  `(when ,list1
     (destructuring-bind (p . rest) ,list1
       (setq ,list2 (cons (point-marker) ,list2))
       (setq ,list1 rest)
       (switch-to-buffer (marker-buffer p))
       (goto-char p))))

(defun rj-backward ()
  (interactive)
  (unless (eq rj-current-state 'initial)
    (rj-do-jump point-undo-list point-redo-list)
    (setq rj-current-state 'undo)
    ;;(rj-debug "rj-backward")
    ))

(defun rj-pre-command-hook-helper ()
  (setq point-undo-list (cons (point-marker) point-undo-list))
  (setq point-redo-list nil)
  (setq rj-current-state 'command)
  (setq rj-hook-command-executed nil)
  ;;(rj-debug "rj-pre-command-hook-helper")
  )

(defun system-buffer-p (buffer)
  (let ((buffer-name (buffer-name buffer)))
    (and (string-suffix-p "*" buffer-name)
         (string-prefix-p "*" buffer-name))))

(defun rj-pre-command-hook ()
  (setq rj-executed-commands (cons this-command rj-executed-commands))
  (when (memq this-command recent-jump-hook-commands)
    (setq rj-hook-command-executed 1))
  (unless (or (not rj-hook-command-executed)
              (eq this-command 'my-hydra/rj-backward)
              (eq this-command 'my-hydra/rj-forward)
              (eq this-command 'rj-backward)
              (eq this-command 'rj-backward)
              (active-minibuffer-window)
              (system-buffer-p (current-buffer))
              isearch-mode)
    (cond ((eq rj-current-state 'initial) (rj-pre-command-hook-helper))
          ((and (eq rj-current-state 'undo) (rj-is-big-jump (car point-redo-list)))
           (rj-pre-command-hook-helper))
          ((rj-is-big-jump (car point-undo-list)) (rj-pre-command-hook-helper)))))

(defun rj-is-big-jump (old-point)
  (let ((same-buffer (eq (marker-buffer old-point) (current-buffer))))
    (or (not same-buffer)
        (> (count-lines (point) old-point) recent-jump-threshold))))

(add-hook 'pre-command-hook 'rj-pre-command-hook)

(defun rj-debug-command ()
  (interactive)
  (rj-debug "manal-rj-debug"))

(defun rj-debug (title)
  (print title)
  (print point-redo-list)
  (print point-undo-list)
  (print rj-current-state))

(provide 'recent-jump)

;; How to save (DO NOT REMOVE!!)
;; (emacswiki-post "point-undo.el")
;;; point-undo.el ends here
