; Path: hal.com!decwrl!sdd.hp.com!spool.mu.edu!uunet!mnemosyne.cs.du.edu!usenet
; From: jlokier@isis.cs.du.edu (Jamie Lokier)
; Newsgroups: gnu.emacs.sources
; Subject: Folding mode (was Re: Origami Folding Editor ...)
; Date: 22 May 92 02:06:28 GMT
; Organization: Public Access Unix, Denver University
; 
; I haven't seen Origami, but I think I have something like the "origami
; mode" that several people have been looking for.
; 
; This is also a response to a request for a folding mode sent to
; gnu.epoch.misc.
; 
; I have produced a folding mode, which allows a file to be divided up,
; with titled subdivisions.  These "folds" can be further folded, with as
; many levels of nesting of folds as you like.  The folds are represented
; by special marker text recognized by folding mode, and otherwise the
; files are normal text files.  In fact, the source for folding mode is
; itself folded, and serves as a useful example for using the mode.
; 
; It is a minor mode, and can be used in conjunction with Emacs major
; modes for editing a wide variety of types of text.  It can cope with
; most programming languages, by hiding the fold markers (and their
; titles) as comments.  I find it very useful, and use it for almost all
; of my files.  Moving around a folded file is faster and easier than
; a normal file, and I'm convinced it increases productivity enormously.
; 
; It could do with being tidied up, but the code is stable and has been
; used for about six months without major problems.
; 
; I am writing an info file for folding mode, and I expect to release it
; along with a tidier, newer version of the mode soon.  I will submit the
; code to one of the Emacs-Lisp ftp sites when I have done so.
; 
; The best way to learn how to use folding mode after installing it is to
; find-file the source, M-x folding-mode, and move in and out of the
; folds.  Keys are documented under the function `folding-mode', though
; you'll probably want to customize them.
; 
; Please send suggestions/bug fixes to the address in the file.
; 
; Thanks.
; 
; Jamie
; --
; Wibble :-)
; 
; -Cut here-------------------------------------------------------------------
;; LCD Archive Entry:
;; folding|Jamie Lokier|u90jl@ecs.ox.ac.uk|
;; A folding-editor-like minor mode.|
;; 92-05-21|1.0|~/modes/folding.el.Z|

;; Copyright (C) 1992, Jamie Lokier.

;; This file is intended to be used with GNU Emacs.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY.  No author or distributor
;; accepts responsibility to anyone for the consequences of using it
;; or for whether it serves any particular purpose or works at all,
;; unless he says so in writing.  Refer to the GNU Emacs General Public
;; License for full details.

;; Everyone is granted permission to copy, modify and redistribute
;; this file, but only under the conditions described in the
;; GNU Emacs General Public License.   A copy of this license is
;; supposed to have been given to you along with GNU Emacs so you
;; can know your rights and responsibilities.  It should be in a
;; file named COPYING.  Among other things, the copyright notice
;; and this notice must be preserved on all copies.

;; This is version 1.0 of folding-mode, as of May 21, 1992.
;; It has been used extensively for about six months without
;; major problems, but could do with some tidying up.
;; A newer version will be released soon, along with an info file.

;; Inspiration and the term "folding mode" are due to Damian Cugley.
;; Thanks also to Dugan Porter for suggestions and for testing it
;; thoroughly.

;; Send suggestions and/or bug fixes to "u90jl@ecs.ox.ac.uk".

;; This file has been edited with a folding editor (itself! :-),
;; so please ignore the strange comments containing "{{{" or "}}}".

;;{{{ Starting folding mode, and related items

;;{{{ Declare `folding' as a feature

(provide 'folding)

;;}}}
;;{{{ folding-mode

;;{{{ As a variable

(defvar folding-mode nil
  "Start folding mode on finding file if non-nil local value.
In other words, as a variable, if this value is non-nil when
`folding-mode-find-file-hook' is called, folding mode is started.

By putting the above function into `find-file-hooks', you can have
folded files automatically enter folding mode when they are found, if
they set the `folding-mode' variable to t in the local variables
section.

The way to do this is to put the following in your .emacs:

\(defun folding-mode-find-file-hook ()
  \"One of the hooks called whenever a `find-file' is successful.\"
  (and (assq 'folded-file (buffer-local-variables))
       folded-file
       (folding-mode 1)
       (kill-local-variable 'folded-file)))
\(or (memq 'folding-mode-find-file-hook find-file-hooks)
    (setq find-file-hooks (append find-file-hooks
 				  '(folding-mode-find-file-hook))))
\(setq inhibit-local-variables nil)

Note that setting `inhibit-local-variables' to nil renders you open to
attack if you find a file that someone has maliciously prepared for you.
I've never met anything like this, but I have heard of it.  It doesn't
worry me, anyway.  The next release of folding mode will have a more
sophisticated method for checking the file, so you won't have to clear
`inhibit-local-variables' if you don't want to.  But that's in the next
one, not this one...

See also `folding-mode-find-file-hook'.")

(make-variable-buffer-local 'folding-mode)
(set-default 'folding-mode nil)

;;}}}
;;{{{ As a function

(defun folding-mode (&optional arg inter)
  "Turns folding-mode (a minor mode) on and off.
As a variable, non-nil means folding-mode is active in the current buffer.

These are the basic commands that folding-mode provides:

C-c C-\\  ---  fold-enter         ---  Enters the fold that the point is on.
C-c C-/  ---  fold-exit          ---  Exits the current fold.
C-c C-t  ---  fold-top-level     ---  Exit all folds.
C-c C-f  ---  fold-fold-region   ---  Surrounds the region with a fold.
C-c C-s  ---  fold-show          ---  Opens the fold, but does not enter it.
C-c C-h  ---  fold-hide          ---  Closes the fold, exiting if necessary.
C-c C-w  ---  fold-whole-buffer  ---  Folds the whole buffer.
C-c C-o  ---  fold-open-buffer   ---  Opens the whole buffer.
C-c C-r  ---  fold-remove-folds  ---  Makes a ready-to-print unfolded copy.

Read the documentation for the above functions for more information.
There will soon be a texinfo file available which explains how to use
folding mode, but there isn't one yet...

For most folded files, lines representing folds have \"{{{\" near the
beginning.  To enter a fold, move the point to the folded line and type
\"C-c C-\\ \" (that is, control-C followed by control-backslash).  You
will not be able to see the rest of the file now, just the contents of
the fold, which you couldn't see before.  You can use \"C-c C-/\" to
leave a fold, and you can enter and exit folds to move around the
structure of the file.

All of the text is present in a folded file all of the time.  It is just
hidden.  Folded text shows up as a line with \"...\" at the end.  If you
are in a fold, the mode line displays `Narrow', because the buffer is
narrowed, so you can't see outside of the current fold's text.

By arranging sections of a large file in folds, and maybe subsections in
sub-folds, you can move around a file quickly and easily, and only have
to scroll through a couple of pages at a time.  If you pick the titles
for the folds carefully, they can be a useful form of documentation, and
make moving though the file a lot easier.  In general, searching through
a folded file for a particular item is much easier than without folds.

To make a new fold, set the mark at one end of the text you want in the
new fold, and move to the other end.  Then type \"C-c C-f\" (or whatever
key you use for `fold-fold-region').  The text you selected will be made
into a fold, and the fold will be entered (*).  If you just want a new,
empty fold, set the mark where you want the fold, and then create a new
fold there without moving the point.  Don't worry if the point is in the
middle of a line of text, fold-fold-region will not break text in the
middle of a line.  After making a fold, the fold is entered (*), and the
point is positioned ready to enter a title for the fold.  Do not delete
the fold marks, which are usually something like \"{{{\" and \"}}}\".
There may also be a bit of fold marker which goes after the fold name.

If the fold markers get messed up, or you just want to see the whole
unfolded file, use \"C-c C-o\" to unfolded the whole file, so you can
see all the text and all the marks.  This is useful for
checking/correcting unbalanced fold markers, and for searching for
things.

`fold-exit' will attempt to tidy the current fold just before exiting
it.  It will remove any extra blank lines at the top and bottom,
\(outside the fold markers).  It will then ensure that markers exists,
and if they are not, will add them (after asking!).  Finally, the number
of blank lines between the fold marks and the contents of the fold is
set to 1 (*).

If the fold marks are not set on entry to folding-mode, they are set to
a default for current major mode, as defined by `fold-mode-marks-alist'
or to \"{{{ \" and \"}}}\" if none are specified.  The hook
`folding-mode-hook' and another hook `<major-mode-name>-folding-hook'
are called before folding the buffer.

You can make folded files start folding mode automatically when they are
found by setting `folding-mode' to t in the Emacs local variables
section of the file, and by having the appropriate hook set up.  Look up
`folding-mode-find-file-hook' for further details.

If calling mode is not called interactively (interactive-p is nil), and
it is called with two or less arguments, all of which are nil, then the
point will not be altered if fold-fold-on-startup is set and so
fold-whole-buffer is called.  This is generally not a good thing, as it
can leave the point inside a hidden region of a fold, though it is
required if the local variables set the mode to folding when the file is
first read (see `hack-local-variables').

Not that you should ever want to, but to call folding-mode from a
program with the default behaviour (toggling the mode), call it with
something like:

  (folding-mode nil t)

\(*): Default behaviour, if you haven't altered the folding-mode
settings.

Other keys bound by default in folding mode are:

C-f  ---  fold-forward-char   ---  Forward character, skipping folded text.
C-b  ---  fold-backward-char  ---  Backward character, skipping folded text.
M-f  ---  fold-forward-word   ---  Forward word, skipping folded text.
M-b  ---  fold-backward-word  ---  Backward word, skipping folded text.
M-g  ---  fold-goto-line      ---  Go to line, entering folds as appropriate.
C-e  ---  fold-end-of-line    ---  Go to end of line, but before folded text."
  (interactive)
  (let ((new-folding-mode
	 (if (not arg) (not folding-mode)
	   (> (prefix-numeric-value arg) 0))))
    (or (eq new-folding-mode
	    folding-mode)
	(if folding-mode
	    (progn
	      (setq selective-display nil)
	      (fold-clear-stack)
	      (widen)
	      (fold-subst-newlines (point-min) (point-max) ?\r ?\n)
	      (use-local-map fold-saved-local-keymap)
	      (kill-local-variable 'fold-saved-local-keymap))
	  (make-local-variable 'fold-saved-local-keymap)
	  (use-local-map (if (setq fold-saved-local-keymap (current-local-map))
			     (copy-keymap fold-saved-local-keymap)
			   (make-sparse-keymap)))
	  (or fold-dont-bind-keys
	      (progn (local-set-key "\C-c\\" 'fold-enter)
		     (local-set-key "\C-c/" 'fold-exit)
	             (local-set-key "\C-c\C-e" 'fold-enter) ; jsp addition
		     (local-set-key "\C-c\C-x" 'fold-exit)  ; jsp addition
		     (local-set-key "\C-c\C-t" 'fold-top-level)
		     (local-set-key "\C-c\C-f" 'fold-fold-region)
		     (local-set-key "\C-c\C-s" 'fold-show)
		     (local-set-key "\C-c\C-h" 'fold-hide)
		     (local-set-key "\C-c\C-o" 'fold-open-buffer)
		     (local-set-key "\C-c\C-w" 'fold-whole-buffer)
		     (local-set-key "\C-c\C-r" 'fold-remove-folds)
		     (local-set-key "\C-f" 'fold-forward-char)
		     (local-set-key "\C-b" 'fold-backward-char)
		     (local-set-key "\M-f" 'fold-forward-word)
		     (local-set-key "\M-b" 'fold-backward-word)
		     (local-set-key "\M-g" 'fold-goto-line)
		     (local-set-key "\C-e" 'fold-end-of-line)))
	  (setq selective-display t)
	  (setq selective-display-ellipses t)
	  (widen)
	  (make-local-variable 'fold-stack)
	  (setq fold-stack nil)
	  (make-local-variable 'fold-top-mark)
	  (make-local-variable 'fold-secondary-top-mark)
	  (make-local-variable 'fold-top-regexp)
	  (make-local-variable 'fold-bottom-mark)
	  (make-local-variable 'fold-bottom-regexp)
	  (make-local-variable 'fold-regexp)
	  (or (and (boundp 'fold-top-regexp)
		   fold-top-regexp
		   (boundp 'fold-bottom-regexp)
		   fold-bottom-regexp)
	      (let ((fold-marks (assq major-mode
				      fold-mode-marks-list)))
		(if fold-marks
		    (setq fold-marks (cdr fold-marks))
		  (setq fold-marks '("{{{ " "}}}")))
		(apply 'fold-set-marks fold-marks)))
	  (run-hooks 'folding-mode-hook)
	  (let ((hook-symbol (intern-soft
			      (concat
			       (symbol-name major-mode)
			       "-folding-hook"))))
	    (and hook-symbol
		 (run-hooks hook-symbol)))
	  (or fold-inhibit-startup-message
	      (interactive-p)
	      arg
	      inter
	      executing-macro
	      (fold-display-brief-message))
(or fold-inhibit-startup-message                                        ; jsp hack
	  (message "Folding with fold marks \"%s%s\" and \"%s\"."
		   fold-top-mark
		   (or fold-secondary-top-mark
		       "")
		   fold-bottom-mark)
)									; jsp hack
	  (fold-set-mode-line)
	  (and fold-fold-on-startup
	       (if (or (interactive-p)
		       arg
		       inter)
		   (fold-whole-buffer)
		 (save-excursion
		   (fold-whole-buffer))))
	  (recenter '(4))))
    (setq folding-mode new-folding-mode)))

;;}}}

;;}}}
;;{{{ fold-display-brief-message

(defun fold-display-brief-message ()
  "Display a brief help message in folding mode."
  (let ((inhibit-quit t)
	(modified (buffer-modified-p)))
    (save-window-excursion
      (save-excursion
	(save-restriction
	  (widen)
	  (switch-to-buffer (current-buffer) t)
	  (fold-set-mode-line)
	  (delete-other-windows)
	  (beginning-of-buffer)
	  (set-window-start (selected-window) 1)
	  (insert "\n"
		  "
This file is intended to be edited in folding mode, and so
folding mode has been started for this file.  Folding mode
can be confusing if you don't know about it, which is the
reason for this message.

To find out how to use folding mode, read the documentation
for the function `folding-mode' by typing the key sequence
\"C-h f folding-mode RET\".

To prevent this message occuring again, put the following
line in your .emacs file:

\(setq fold-inhibit-startup-message t)"
		  "\n\n\n")
	  (or modified
	      (set-buffer-modified-p nil))
	  (sit-for 0)
	  (save-excursion
	    (goto-char (point-min))
	    (insert "Read this before continuing"))
	  (backward-char)
	  (insert "End of message")
	  (or modified
	      (set-buffer-modified-p nil))
	  (let ((inverse-video (not inverse-video)))
	    (sit-for 0))
	  (message "Press Space to continue")
	  (let ((char (read-char)))
	    (or (= char ?\ )
		(setq unread-command-char char)))
	  (delete-region (point-min)
			 (1+ (point)))
	  (or modified
	      (set-buffer-modified-p nil)))))))

;;}}}
;;{{{ fold-stack

(defvar fold-stack nil
  "This is a list of structures which keep track of folds being entered
and exited. It is a list of (MARKER . MARKER) pairs, followed by the symbol
`folded'.  The first of these represents the fold containing the current one.
If the view is currently outside all folds, this variable has value nil.")

;;}}}
;;{{{ fold-clear-stack

(defun fold-clear-stack ()
  "Clear the fold stack, and release all the markers it refers to."
  (while (and fold-stack
	      (not (eq 'folded (car fold-stack))))
    (set-marker (car (car fold-stack)) nil)
    (set-marker (cdr (car fold-stack)) nil)
    (setq fold-stack (cdr fold-stack)))
  (setq fold-stack nil))

;;}}}
;;{{{ fold-mode-string

(defvar fold-mode-string nil
  "Buffer-local variable that holds the fold nest depth string.")

(set-default 'fold-mode-string " Folding")

;;}}}
;;{{{ minor-mode-alist

(or (assq 'folding-mode minor-mode-alist)
    (setq minor-mode-alist
		(cons '(folding-mode fold-mode-string)
		      minor-mode-alist)))

;;}}}
;;{{{ kill-all-local-variables-hooks

;; This does not normally have any effect in Emacs.  In my setup,
;; this hook is called when the major mode changes, and it gives
;; folding-mode a chance to clear up first, due to popular demand...

(and (boundp 'kill-all-local-variables-hooks)
     (or (memq 'fold-end-mode-quickly
	       kill-all-local-variables-hooks)
	 (setq kill-all-local-variables-hooks
	       (cons 'fold-end-mode-quickly
		     kill-all-local-variables-hooks))))

;;}}}
;;{{{ list-buffers-mode-alist

;; Also has no effect in standard Emacs.  With this variable set,
;; my setup shows "Folding" in the mode name part of the buffer list,
;; which looks nice :-).

(and (boundp 'list-buffers-mode-alist)
     (or (assq 'folding-mode list-buffers-mode-alist)
	 (setq list-buffers-mode-alist
	       (cons '(folding-mode "Folding")
		     list-buffers-mode-alist))))

;;}}}
;;{{{ fold-end-mode-quickly

(defun fold-end-mode-quickly ()
  "Replaces all ^M's with linefeeds and widen a folded buffer.
Only has any effect if folding mode is active.

This should not in general be used for anything.  It is used when changing
major modes, by being placed in kill-mode-tidy-alist, to tidy the buffer
slightly.  It is similar to (folding-mode 0), except that it does not
restore saved keymaps etc.  Repeat: Do not use this function.  Its
behaviour is liable to change."
  (and (boundp 'folding-mode)
       (assq 'folding-mode
	     (buffer-local-variables))
       folding-mode
       (progn
	 (widen)
	 (fold-clear-stack)
	 (fold-subst-newlines (point-min) (point-max) ?\r ?\n))))

;;}}}
;;{{{ fold-set-mode-line

(defun fold-set-mode-line ()
  "Sets `fold-mode-string' appropriately.
This allows the folding mode description in the mode line to reflect the
current fold depth."
  (if (null fold-stack)
      (kill-local-variable 'fold-mode-string)
    (make-local-variable 'fold-mode-string)
    (setq fold-mode-string (if (eq 'folded (car fold-stack))
				  " inside 1 fold"
				(concat " inside "
					(length fold-stack)
					" folds")))))

;;}}}

;;}}}
;;{{{ Hooks and variables

;;{{{ folding-mode-hook

(defvar folding-mode-hook nil
  "Hook called when folding mode is entered.
A hook named {major mode name}-folding-hook is also called, if it exits.
eg. c-mode-folding-hook is called when folding-mode is entered.

For example, this is the standard c-mode-folding-hook:

(setq c-mode-folding-hook
      (function
       (lambda ()
	 (setq fold-extract-file-name 'c-mode-extract-file-name))))")

;;}}}
;;{{{ fold-inhibit-startup-message

(defvar fold-inhibit-startup-message nil
  "*If nil, folding-mode displays a momentary help message.

Because a folded file can be a confusing thing if you don't know about
folding mode, and sometimes a finding a file will set folding mode and
fold the file, folding mode normally displays a momentary help message.

It only does this if it is called non-interactively, as it is when file
local variables are read or find-file-hooks is called.  If it is called
interactively, it is assumed that you know what you are doing.

Once you understand folding mode, there is no need for you to see this
message.  Setting this variable will prevent the message from appearing
when you find a folded file in future, and can be done by putting the
following line in your .emacs file:

(setq fold-inhibit-startup-message t)")

;;}}}
;;{{{ fold-dont-bind-keys

(defvar fold-dont-bind-keys nil
  "*If non-nil, folding-mode does not bind keys when started.
This might be desirable if the default folding-mode keys interfere with
some other settings.  Whether they do or not, you probably want to set
`folding-mode-hook' to set some more comfortable keys, particularly for
the `fold-enter' and `fold-exit' keys which are used very often.

A copy of the local keymap is made and used regardless of the value of
this variable, so you can set specific folding-mode keys in a hook
without interfering with the local map used in other non-folded buffers.")

;;}}}
;;{{{ fold-fold-on-startup

(defvar fold-fold-on-startup t
  "*If this value is non-nil, the buffer is folded on entry to
folding-mode.")

;;}}}
;;{{{ fold-enter-on-create

(defvar fold-enter-on-create t
  "*If this value is non-nil, fold-region enters the fold it creates.")

;;}}}
;;{{{ fold-mode-marks-list

(defvar fold-mode-marks-list nil
  "List of (major-mode, fold marks) default combinations to use.
When folding-mode is started, the major mode is checked, and if there
are fold marks for that major mode stored in `fold-mode-marks-list',
those marks are used by default.  If none are found, the default values
of \"{{{ \" and \"}}}\" are used.")

;;}}}
;;{{{ fold-extract-file-name

(defvar fold-extract-file-name nil
  "Function to extract a filename if there is no fold to enter.
This is a buffer-local variable, intended to be mode-specific.  It is
usually set by another hook, eg. c-mode-folding-hook.

It is called by funcall, not run-hooks.  It should contain a symbol, which
is the name of a mode-specific function to be called.

It is called by fold-enter if the point is not on a fold to enter.
If it returns nil, fold-enter fails with an error.  Otherwise, if the
variable fold-query-enter-file is non-nil, the find-file prompt is
presented, with that file name as default.  Otherwise the file is found
without querying.

The hook may move the point -- it is called from within a save-excursion.")

(make-variable-buffer-local 'fold-extract-file-name)

;;}}}
;;{{{ fold-query-enter-file

(defvar fold-query-enter-file nil
  "*If this is non-nil, query before finding a file from fold-enter.")

;;}}}

;;}}}
;;{{{ Regular expressions for matching fold marks

;;{{{ fold-set-marks

(defun fold-set-marks (top bottom &optional secondary)
  "Sets the folding top and bottom marks for the current buffer.
The fold top mark is set to TOP, and the fold bottom mark is set to BOTTOM.
And optional secondary top mark can also be specified --- this is insert by
fold-fold-region after the fold top mark, and is presumed to be put after
the title of the fold.  This is not necessary with the bottom mark because
it has no title.
Various regular expressions are set with this function, so don't set the
mark variables directly."
  (set (make-local-variable 'fold-top-mark)
       top)
  (set (make-local-variable 'fold-bottom-mark)
       bottom)
  (set (make-local-variable 'fold-secondary-top-mark)
       secondary)
  (set (make-local-variable 'fold-top-regexp)
       (concat "\\(^\\|\r\\)\\([ \t]*\\)"
	       (regexp-quote fold-top-mark)))
  (set (make-local-variable 'fold-bottom-regexp)
       (concat "\\(^\\|\r\\)\\([ \t]*\\)"
	       (regexp-quote fold-bottom-mark)
	       "[ \t]*\\(\\)\\($\\|\r\\)"))
  (set (make-local-variable 'fold-regexp)
       (concat "\\(^\\|\r\\)\\([ \t]*\\)\\(\\("
	       (regexp-quote fold-top-mark)
	       "\\)\\|\\("
	       (regexp-quote fold-bottom-mark)
	       "[ \t]*\\(\\)\\($\\|\r\\)\\)\\)")))

;;}}}

;;}}}
;;{{{ Cursor movement that skips folded regions

;;{{{ fold-forward-char

(defun fold-forward-char (&optional arg)
  "Move point right ARG characters, skipping hidden folded regions.
Moves left if ARG is negative.  On reaching end of buffer, stop and
signal error."
  (interactive "p")
  (cond (arg
	 (if (> 0 arg)
	     (fold-backward-char (- arg))
	   (while (< 0 arg)
	     (setq arg (1- arg))
	     (fold-forward-char))))
	((or
	  (eobp)
	  (if (eq ?\r (char-after (point)))
	      (not (search-forward "\n" (point-max) t))
	    (forward-char)))
	 (error "End of buffer"))))

;;}}}
;;{{{ fold-backward-char

(defun fold-backward-char (&optional arg)
  "Move point left ARG characters, skipping hidden folded regions.
Moves right if ARG is negative.  On reaching beginning of buffer,
stop and signal error."
  (interactive "P")
  (cond (arg (setq arg (prefix-numeric-value arg))
	     (if (> 0 arg)
		 (fold-forward-char (- arg))
	       (while (< 0 arg)
		 (setq arg (1- arg))
		 (fold-backward-char))
	       (fold-skip-ellipsis-backward)))
	((fold-skip-ellipsis-backward)
	 (message "Exited folded region represented by ellipsis (...)"))
	((or (bobp)
	    (if (let ((ch (char-after (1- (point)))))
		  (or (eq ?\n ch)
		      (eq ?\r ch)))
		(let ((saved-point (point)))
		  (beginning-of-line 0)
		  (search-forward "\r" saved-point 0)
		  (backward-char))
	      (backward-char)))
	 (error "Beginning of buffer"))))

;;}}}
;;{{{ fold-forward-word

(defun fold-forward-word (&optional arg)
  "Move point forward ARG words, skipping hidden folded regions.
Moves backward if ARG is negative.  Normally returns t, but on
reaching end of buffer, the point is left there and nil is returned.
The point will not be taken past a fold, if that is the very last
thing in the buffer."
  (interactive "p")
  (if arg
      (if (> 0 arg)
	  (fold-backward-word (- arg))
	(let ((temp t))
	  (while (< 0 arg)
	    (setq arg (1- arg))
	    (setq temp (fold-forward-word)))
	  temp))
    (let (temp-char)
      (while (and (setq temp-char (char-after (point)))
		  (not (eq ?\r temp-char))
		  (not (eq ?w (char-syntax temp-char))))
	(skip-chars-forward (concat "\\" (char-to-string temp-char))))
      (and temp-char
	   (if (eq ?\r temp-char)
	       (search-forward "\n" (point-max) t)
	     (forward-word 1))))))

;;}}}
;;{{{ fold-backward-word

(defun fold-backward-word (&optional arg)
  "Move point backward ARG words, skipping hidden folded regions.
Moves forward if ARG is negative.  Normally returns t, but on reaching
beginning of buffer, the point is left there and nil returned."
  (interactive "P")
  (if arg
      (progn
	(setq arg (prefix-numeric-value arg))
	(if (> 0 arg)
	    (fold-forward-word (- arg))
	  (let ((temp t))
	    (while (< 0 arg)
	      (setq arg (1- arg))
	      (setq temp (fold-backward-word)))
	    (fold-skip-ellipsis-backward)
	    temp)))
    (if (fold-skip-ellipsis-backward)
	(message "Exited folded region represented by ellipsis (...)")
      (let (temp-char (temp-flag t) saved-point)
	(while (and (not (bobp))
		    (setq temp-char (char-after (1- (point))))
		    (not (eq ?w (char-syntax temp-char)))
		    (and (or (eq ?\r temp-char)
			     (eq ?\n temp-char))
			 (progn
			   (setq saved-point (point))
			   (beginning-of-line 0)
			   (setq temp-flag
				 (not (search-forward "\r" saved-point 0)))
			   (backward-char)
			   temp-flag)))
	  (skip-chars-backward (concat "\\" (char-to-string temp-char))))
	(setq temp-char (char-after (point)))
	(and temp-char
	     (or (not temp-flag)
		 (forward-word -1)))))))

;;}}}
;;{{{ fold-end-of-line

(defun fold-end-of-line (&optional arg)
  "Move point to end of current line, but before folded region.
Has the same behavior as end-of-line, except that if the current line
ends with some folded text represented by an ellipsis, the point is
position just before it.  This prevents the point from being placed
inside the folded text, which is not normally what is wanted."
  (interactive "p")
  (end-of-line arg)
  (fold-skip-ellipsis-backward))

;;}}}
;;{{{ fold-skip-ellipsis-backward

(defun fold-skip-ellipsis-backward ()
  "Moves the point out of folded text.
If the point is inside a folded region, the cursor is displayed at
the end of the ellipsis representing the folded part.  These function
checks to see if this is the case, and if so, moves the point just
outside this region.  This moves the displayed cursor to the position
just before the ellipsis.

Returns t if the point was moved, nil otherwise."
  (interactive)
  (and (save-excursion
	 (skip-chars-backward "^\n\r")
	 (eq (preceding-char) ?\r))
       (progn (skip-chars-backward "^\n")
	      (skip-chars-forward "^\r")
	      t)))

;;}}}

;;}}}
;;{{{ Moving in and out of folds

;;{{{ fold-enter

(defun fold-enter (&optional noerror nofile)
  "Open and enter the fold at or around the point.
Enters the fold that the point is inside, wherever the point is inside the
fold, provided it is a valid fold, with balanced top and bottom marks.
Returns nil if the fold entered contains no sub-folds, t otherwise.
If an optional argument NOERROR is non-nil, returns nil if there are no
folds to enter, instead of causing an error.

If the point is inside a folded, hidden region (as represented by an
ellipsis), the position of the point in the buffer is preserved, and as many
folds as necessary are entered to make the surrounding text visible.  This
is useful after some commands eg. search commands.

If there is no fold to enter, then the hook fold-extract-file-name-hook
is called.  If it returns a file name, that file is found, otherwise an
error condition is signaled.  See fold-extract-file-name-hook for more
details.

The above hook is not called if the second optional argument NOFILE is
non-nil."
  (interactive)
  (let ((goal-point (point)))
    (if (fold-skip-ellipsis-backward)
	(while (prog2 (beginning-of-line)
		      (fold-enter t)
		      (goto-char goal-point)))
      (let ((fold-position-list (fold-find-containing-fold))
	    fold-start
	    fold-end
	    fold-entered)
	(if (and fold-position-list
		 (or (<= (point-min) 1)
		     (not (eq (point-min) (car fold-position-list)))))
	    (progn
	      (setq fold-entered (and (nthcdr 2 fold-position-list) t))
	      (setq fold-start (car fold-position-list))
	      (while fold-position-list
		(setq fold-end (nth 1 fold-position-list))
		(fold-subst-newlines (car fold-position-list)
					fold-end ?\r ?\n)
		(setq fold-position-list (nthcdr 2 fold-position-list)))
	      (setq fold-stack
		    (if fold-stack
			(cons (cons (point-min-marker) (point-max-marker))
			      fold-stack)
		      '(folded)))
	      (narrow-to-region fold-start fold-end)
	      (fold-set-mode-line)
	      fold-entered)
	  (let ((file-name (and
			    (not nofile)
			    fold-extract-file-name
			    (save-excursion
			      (funcall fold-extract-file-name)))))
	    (if file-name
		(progn (find-file-other-window
			(if fold-query-enter-file
			    (read-file-name (concat "Find file (default "
						    (file-name-nondirectory file-name)
						    "): ")
					    (file-name-directory file-name)
					    file-name
					    t)
			  file-name)))
	      (or noerror (error "Not on or in a fold, and no file to enter."))))
	  nil)))))

;;}}}
;;{{{ fold-exit

(defun fold-exit ()
  "Exits the current fold."
  (interactive)
  (if fold-stack
      (progn
	(fold-tidy-inside)
	(fold-subst-newlines (point-min) (point-max) ?\n ?\r)
	(if (eq (car fold-stack) 'folded)
	    (widen)
	  (narrow-to-region (marker-position (car (car fold-stack)))
			    (marker-position (cdr (car fold-stack)))))
	(beginning-of-line)
	(and (consp (car fold-stack))
	     (set-marker (car (car fold-stack)) nil)
	     (set-marker (cdr (car fold-stack)) nil))
	(setq fold-stack (cdr fold-stack)))
    (error "Outside all folds."))
  (fold-set-mode-line)
  (recenter '(4)))

;;}}}
;;{{{ fold-top-level

(defun fold-top-level ()
  "Exits all folds, to the top level."
  (interactive)
  (while fold-stack
    (fold-exit)))

;;}}}
;;{{{ fold-show

(defun fold-show ()
  "Opens the fold at or around the point, but does not enter it."
  (interactive)
  (fold-skip-ellipsis-backward)
  (let ((fold-position-list (fold-find-containing-fold))
	fold-start
	fold-end)
    (if (and fold-position-list
	     (not (eq (point-min) (car fold-position-list))))
	(progn
	  (setq fold-start (car fold-position-list))
	  (while fold-position-list
	    (setq fold-end (nth 1 fold-position-list))
	    (fold-subst-newlines (car fold-position-list)
				    fold-end ?\r ?\n)
	    (setq fold-position-list (nthcdr 2 fold-position-list))))
      (error "Not on or in a fold (invisible mismatched parentheses perhaps?)"))))

;;}}}
;;{{{ fold-hide

(defun fold-hide ()
  "Close the fold around the point, moving up a level if necessary."
  (interactive)
  (fold-enter t)
  (fold-exit))

;;}}}
;;{{{ fold-goto-line

(defun fold-goto-line (line)
  "Go to line ARG, entering as many folds as possible."
  (interactive "nGoto line: ")
  (while fold-stack (fold-exit))
  (widen)
  (goto-char 1)
  (and (< 1 line)
       (re-search-forward "\r\\|\n" nil 0 (1- line)))
  (let ((goal-point (point)))
    (while (prog2 (beginning-of-line)
		  (fold-enter t)
		  (goto-char goal-point))))
  (recenter '(4)))

;;}}}

;;}}}
;;{{{ Extracting file names from the buffer text

;;{{{ C mode file name extraction

;;{{{ c-mode-folding-hook

(defvar c-mode-folding-hook
  (function
   (lambda ()
     (setq fold-extract-file-name 'c-mode-extract-file-name)))
  "Hook called when folding mode is entered from C mode.")

;;}}}
;;{{{ c-mode-extract-file-name

(defun c-mode-extract-file-name ()
  "Extracts a file name to find from a C source file.
If the point is on a line that starts with a #include, this function attempts
to extract a filename from it.  If the name is in angled brackets (< and >),
then a list of directories in c-mode-include-path is searched for the file.
Otherwise, the current directory is searched for the file.  If a suitable file
is found, the name is returned, otherwise nil is returned.

Comments after the #include are ignored, though other rubbish will not be."
  (beginning-of-line)
  (and (looking-at "^[ \t]*#include[ \t]*\\(\\(\"\\(.*\\)\"\\)\\|\\(<\\(.*\\)>\\)\\|\\([^ \t\"<].*[^ \t\">]\\)\\)[ \t]*\\(/\\*[^\\(\\*/\\)]*\\*/[ \t]*\\)*\\(/\\*[^\\(\\*/\\)]*\\)?$")
       (cond
	((match-beginning 3)
	 (buffer-substring
	  (match-beginning 3)
	  (match-end 3)))
	((match-beginning 6)
	 (buffer-substring
	  (match-beginning 6)
	  (match-end 6)))
	((match-beginning 5)
	 (let* ((name (buffer-substring
		       (match-beginning 5)
		       (match-end 5)))
		(path c-mode-include-path)
		(full-name (catch 'loop
			     (while path
			       (let ((full-name (concat
						 (car path)
						 name)))
				 (and (file-exists-p full-name)
				      (not (file-directory-p full-name))
				      (throw 'loop full-name)))
			       (setq path (cdr path)))
			     nil)))
	   (if full-name
	       full-name
	     (error "<%s> not found on include path." name)))))))

;;}}}
;;{{{ c-mode-fetch-include-path

(defun c-mode-fetch-include-path ()
  "Extracts names of include file directories from environments variables.
Returns a list of these, followed by the ones in c-mode-default-include-area.
Duplicates are removed. (will be!)"
  (let (line
	(path c-mode-default-include-area))
    (mapcar
     (function
      (lambda (name)
	(and (setq line (getenv name))
	     (while (string-match "\\(^\\|[ \t]\\)-I\\([^ \t]+\\)[ \t]*" line)
	       (setq path
		     (cons
		      (let ((directory
			     (substring line
					(match-beginning 2)
					(match-end 2)))) 
			(if (equal "/"
				   (substring directory -1))
			    directory
			  (concat directory
				  "/")))
		      path))
	       (setq line (substring line (match-end 0)))))))
     '("CC"
       "CFLAGS"))
    path))

;;}}}
;;{{{ c-mode-default-include-area

(defvar c-mode-default-include-area '("/usr/include/"
				      "/usr/5include/"
				      "/usr/include/X11/")
  "The standard are where system include files are kept.  Nearly.")

;;}}}
;;{{{ c-mode-include-path

(defvar c-mode-include-path (c-mode-fetch-include-path)
  "A list of directories to be searched for include files.
By default, it is initialised from a combination of standard locations and
flags in the environment variables CC and CFLAGS")

;;}}}

;;}}}
;;{{{ Shellscript mode file name extraction

;;{{{ shellscript-mode-folding-hook

(defvar shellscript-mode-folding-hook
  (function
   (lambda ()
     (setq fold-extract-file-name 'shellscript-mode-extract-file-name)))
  "Hook called when folding-mode is entered from shellscript-mode.")

;;}}}
;;{{{ shellscript-mode-extract-file-name

(defun shellscript-mode-extract-file-name ()
  "Extracts a file name to find from a shell script.
Searches for something like 'source filename' anywhere on the current line.
The filename can be inside single or double quotes -- no other interpreting
of the text is done.  Quoted quotes may not be interpreted correctly.

If a name is successfully found, it is returned, otherwise nil is returned.
If there are several matching expressions on the same line, the one nearest
the point is used."
  (let (subposition
	best-subposition
	(original-point (* 2 (point)))
	(bound (save-excursion (end-of-line) (point))))
    (beginning-of-line)
    (while (re-search-forward "source\\(\\([^ \t0-9A-Za-z'\"]\\)\\|[ \t]*\\(\\([ \t]\\([^ \t;'\"|><#{}`]*\\)\\([ \t]\\|$\\)\\)\\|\\(\\(['\"]\\)\\([^\\8]*\\)\\8\\)\\)\\)" bound t)
      (setq subposition
	    (cond ((match-beginning 2)
		   (list (+ (match-beginning 0)
			    (match-end 2))))
		  ((match-beginning 5)
		   (list (+ (match-beginning 0)
			    (match-end 5))
			 (match-beginning 5)
			 (match-end 5)))
		  ((match-beginning 9)
		   (list (+ (match-beginning 0)
			    (match-end 7))
			 (match-beginning 9)
			 (match-end 9)))))
      (if (> original-point (car subposition))
	  (setcar subposition (- original-point
				 (car subposition)))
	(setcar subposition (- (car subposition)
			       original-point)))
      (and (or (null best-subposition)
	       (< (car subposition)
		  (car best-subposition)))
	   (setq best-subposition subposition))
      (goto-char (match-beginning 1)))
    (and best-subposition
	 (if (cdr best-subposition)
	     (buffer-substring (car (cdr best-subposition))
			       (car (cdr (cdr best-subposition))))
	   (error "Expression too complex -- Unable to extract filename from source command.")))))

;;}}}

;;}}}

;;}}}
;;{{{ Searching for fold boundaries

;;{{{ fold-find-containg-fold

(defun fold-find-containing-fold ()
  "Returns information about the fold surrounding the point.
Returns a list of buffer positions, or nil if the point is not inside a fold.
If there are no folds inside this fold, the list contains just two numbers,
the start and end of the fold.  If there are folds in this fold, the start
and end positions of those folds are also returned.  The resulting list is
in numerical order."
  (save-restriction
    (save-excursion
      (widen)
      (and (eq ?\r (preceding-char))
	   (backward-char))
      (let ((temp1 (save-excursion (fold-search-backward)))
	    temp2)
	(and
	 temp1
	 (append temp1 (fold-search-forward)))))))

;;}}}
;;{{{ fold-search-backward

(defun fold-search-backward ()
  (skip-chars-backward "^\r\n")
  (and (eq (preceding-char) ?\r)
       (backward-char))
  (and (looking-at fold-top-regexp)
       (progn (skip-chars-forward "^\r\n")
	      (and (eq (following-char) ?\r)
		   (forward-char))))
  (let (fold-position-list
	(depth 1))
    (while (and (< 0 depth)
		(re-search-backward fold-regexp nil t))
      (goto-char (match-beginning 2))
      (if (match-beginning 4)
	  (and (eq 1 (setq depth (1- depth)))
	       (setq fold-position-list (cons (point)
					      fold-position-list)))
	(and (eq 2 (setq depth (1+ depth)))
	     (setq fold-position-list (cons (match-beginning 6)
					    fold-position-list)))))
    (and (eq 0 depth)
	 (cons (point) fold-position-list))))

;;}}}
;;{{{ fold-search-forward

(defun fold-search-forward (&optional flag)
  (skip-chars-backward "^\r\n")
  (and (not flag)
       (progn
	 (and (eq (preceding-char) ?\r)
	      (backward-char))
	 (and (looking-at fold-top-regexp)
	      (skip-chars-forward "^\r\n"))))
  (let (fold-position-list
	(depth 1))
    (while (and (< 0 depth)
		(re-search-forward fold-regexp nil t))
      (if (match-beginning 4)
	  (and (eq 2 (setq depth (1+ depth)))
	       (setq fold-position-list (cons (match-beginning 2)
					      fold-position-list)))
	(goto-char (match-beginning 6))
	(and (eq 1 (setq depth (1- depth)))
	     (setq fold-position-list (cons (point)
					    fold-position-list)))))
    (and (if flag (not (eq 0 depth))
	   (eq 0 depth))
	 (nreverse (cons (point) fold-position-list)))))

;;}}}

;;}}}
;;{{{ Functions that actually modify the buffer

;;{{{ fold-subst-newlines

(defun fold-subst-newlines (start end find replace)
  "Substitutes one character for another, even in a read-only buffer.
In the region specified by START and END, every character FIND is replaced
by the character REPLACE.  The buffer-modified flag is not affected, undo
information is not kept for the change, and the function works on read-only
files."
  (let ((read-only buffer-read-only))
    (setq buffer-read-only nil)
    (subst-char-in-region start end find replace t)
    (setq buffer-read-only read-only)))

;;}}}
;;{{{ fold-fold-region

(defun fold-fold-region (start end)
  "Places fold marks at the beginning and end of a specified region.
The region is specified by two arguments START and END.  If
`fold-enter-on-create' is non-nil, enter the fold after making it.  The
point is left just after the top fold mark, in an appropriate position
to enter a title for the fold."
  (interactive "r")
  (and (< end start)
       (setq start (prog1 end
		     (setq end start))))
  (setq end (set-marker (make-marker) end))
  (goto-char start)
  (beginning-of-line)
  (setq start (point))
  (insert-before-markers fold-top-mark)
  (let ((saved-point (point)))
    (and fold-secondary-top-mark
	 (insert-before-markers fold-secondary-top-mark))
    (insert-before-markers ?\n)
    (goto-char (marker-position end))
    (set-marker end nil)
    (and (not (bolp))
	 (eq 0 (forward-line))
	 (eobp)
	 (insert ?\n))
    (insert fold-bottom-mark)
    (insert ?\n)
    (setq fold-stack (if fold-stack
			    (cons (cons (point-min-marker)
					(point-max-marker))
				  fold-stack)
			  '(folded)))
    (narrow-to-region start (1- (point)))
    (goto-char saved-point)
    (fold-set-mode-line))
  (save-excursion (fold-tidy-inside))
  (or fold-enter-on-create
      (if (eq 'folded (car fold-stack))
	  (progn
	    (widen)
	    (setq fold-stack nil))
	(narrow-to-region (marker-position (car (car fold-stack)))
			  (marker-position (cdr (car fold-stack))))
	(set-marker (car (car fold-stack)) nil)
	(set-marker (cdr (car fold-stack)) nil)
	(setq fold-stack (cdr fold-stack)))))

;;}}}
;;{{{ fold-tidy-inside

(defun fold-tidy-inside ()
  "Adds or removes blank lines at the top and bottom of the current fold.
Also adds fold marks at the top and bottom (after asking), if they are not
there already.  The amount of space left depends on the variable
`fold-internal-margins', which is one by default."
  (if buffer-read-only nil
    (goto-char (point-min))
    (and (eolp)
	 (progn (skip-chars-forward "\n")
		(delete-region (point-min) (point))))
    (and (if (looking-at fold-top-regexp)
	     (progn (forward-line 1)
		    (and (eobp) (insert ?\n))
		    t)
	   (and (y-or-n-p "Insert missing fold-top-mark? ")
		(progn (insert (concat fold-top-mark
				       "<Replaced missing fold top mark>"
				       (or fold-secondary-top-mark "")
				       "\n"))
		       t)))
	 fold-internal-margins
	 (<= 0 fold-internal-margins)
	 (let ((temp (point)))
	   (skip-chars-forward "\n")
	   (if (< 0 (setq temp (+ (- temp (point)) fold-internal-margins)))
	       (while (<= 0 (setq temp (1- temp))) (insert ?\n))
	     (or (eq 0 temp)
		 (delete-region (+ (point) temp) (point))))))
    (goto-char (point-max))
    (and (bolp)
	 (progn (skip-chars-backward "\n")
		(delete-region (point) (point-max))))
    (beginning-of-line)
    (and (or (looking-at fold-bottom-regexp)
	     (progn (goto-char (point-max)) nil)
	     (and (y-or-n-p "Insert missing fold-bottom-mark? ")
		  (progn
		    (insert (concat "\n" fold-bottom-mark))
		    (beginning-of-line)
		    t)))
	 fold-internal-margins
	 (<= 0 fold-internal-margins)
	 (let ((temp (point)))
	   (skip-chars-backward "\n")
	   (if (<= 0 (setq temp (+ (- (point) temp) fold-internal-margins)))
	       (while (<= 0 temp)
		 (setq temp (1- temp))
		 (insert ?\n))
	     (or (eq -1 temp)
		 (delete-region (point) (- (point) (1+ temp)))))))))

;;}}}
;;{{{ fold-internal-margins

(defvar fold-internal-margins 1
  "*Number of lines added just inside the fold marks when tidying folds.
This is also done when folds are exited.  First, any extra blank lines
are removed from the top or bottom of the current fold (outside the fold
marks).  Then, if the number of blank lines just inside each of the
marks is not equal to the value of fold-internal-margins, lines are
added or removed.

If this value is nil or negative, no blank lines are added or removed
inside the fold marks.  A value of 0 (zero) is valid, meaning leave no
blank lines.")

;;}}}

;;}}}
;;{{{ Operations on the whole buffer

;;{{{ fold-whole-buffer

(defun fold-whole-buffer ()
  "Folds every fold in the current buffer.
Fails if the fold markers are not balanced correctly.
If the buffer is folded, folds are recursively exited to get to the top
level first.  The buffer modification flag is not affected, and this
function will work on read-only buffers."
  (interactive)
  (message "Folding buffer...")
  (let (fold-position-list
	(narrow-min (point-min))
	(narrow-max (point-max)))
    (widen)
    (save-excursion
      (goto-char (point-min))
      (if (setq fold-position-list (fold-search-forward t))
	  (progn (while fold-stack (fold-exit))
		 (setq fold-position-list (cons 1 fold-position-list))
		 (while fold-position-list
		   (and (nthcdr 2 fold-position-list)
			(fold-subst-newlines (nth 1 fold-position-list)
						(nth 2 fold-position-list)
						?\n ?\r))
		   (fold-subst-newlines (car fold-position-list)
					   (nth 1 fold-position-list) ?\r ?\n)
		   (setq fold-position-list (nthcdr 2 fold-position-list))))
	(narrow-to-region narrow-min narrow-max)
	(error "Cannot fold whole buffer --- fold markers are not balanced.")))
    (beginning-of-line)
    (message "Folding buffer... Done")))

;;}}}
;;{{{ fold-open-buffer

(defun fold-open-buffer ()
  "Unfolds the entire buffer, leaving the point where it is.
Does not affect the buffer-modified flag, and can be used on read-only
buffers."
  (interactive)
  (fold-clear-stack)
  (widen)
  (fold-subst-newlines (point-min) (point-max) ?\r ?\n)
  (fold-set-mode-line)
  (recenter '(4)))

;;}}}
;;{{{ fold-remove-folds

(defun fold-remove-folds (&optional buffer pre-title post-title pad)
  "Removes folds from a buffer, for printing.

It copies the contents of the (hopefully) folded buffer BUFFER into a
buffer called `*Unfolded: <Original-name>*', removing all of the fold
marks.  It keeps the titles of the folds, however, and numbers them.
Subfolds are numbered in the form 5.1, 5.2, 5.3 etc., and the titles are
indented to eleven characters.

It accepts four arguments.  BUFFER is the name of the buffer to be
operated on, or a buffer.  nil means use the current buffer.  PRE-TITLE
is the text to go before the replacement fold titles, POST-TITLE is the
text to go afterwards.  Finally, if PAD is non-nil, the titles are all
indented to the same column, which is eleven plus the length of
PRE-TITLE.  Otherwise just one space is placed between the number and
the title."
  (interactive (list (read-buffer "Remove folds from buffer: "
				  (buffer-name)
				  t)
		     (read-string "String to go before enumerated titles: ")
		     (read-string "String to go after enumerated titles: ")
		     (y-or-n-p "Pad section numbers with spaces? ")))
  (set-buffer (setq buffer (get-buffer buffer)))
  (setq pre-title (or pre-title "")
	post-title (or post-title ""))
  (or folding-mode
      (error "Must be in folding mode before removing folds."))
  (let ((new-buffer (get-buffer-create (concat "*Unfolded: "
					       (buffer-name buffer)
					       "*")))
	(section-list '(1))
	(section-prefix-list '(""))
	title
	(secondary-mark-length (length fold-secondary-top-mark))
	(regexp fold-regexp)
	(secondary-mark fold-secondary-top-mark)
	prefix
	(mode major-mode))
    (buffer-flush-undo new-buffer)
    (save-excursion
      (set-buffer new-buffer)
      (delete-region (point-min)
		     (point-max)))
    (save-restriction
      (widen)
      (copy-to-buffer new-buffer (point-min) (point-max)))
    (display-buffer new-buffer t)
    (set-buffer new-buffer)
    (subst-char-in-region (point-min) (point-max) ?\r ?\n)
    (funcall mode)
    (while (re-search-forward regexp nil t)
      (if (match-beginning 4)
	  (progn
	    (goto-char (match-end 4))
	    (setq title
		  (buffer-substring (point)
				    (progn (end-of-line)
					   (point))))
	    (delete-region (save-excursion
			     (goto-char (match-beginning 4))
			     (skip-chars-backward "\n\r")
			     (point))
			   (progn
			     (skip-chars-forward "\n\r")
			     (point)))
	    (and (<= secondary-mark-length
		     (length title))
		 (string-equal secondary-mark
			       (substring title
					  (- secondary-mark-length)))
		 (setq title (substring title
					0
					(- secondary-mark-length))))
	    (setq section-prefix-list
		  (cons (setq prefix (concat (car section-prefix-list)
					     (int-to-string (car section-list))
					     "."))
			section-prefix-list))
	    (or (cdr section-list)
		(insert ?\n))
	    (setq section-list
		  (cons 1
			(cons (1+ (car section-list))
			      (cdr section-list))))
	    (setq title (concat prefix
				(if pad
				    (make-string (max 2 (- 8 (length prefix))) ? )
				  " ")
				title))
	    (message "Reformatting: %s%s%s"
		     pre-title
		     title
		     post-title)
	    (insert "\n\n"
		    pre-title
		    title
		    post-title
		    "\n\n"))
	(goto-char (match-beginning 5))
	(or (setq section-list (cdr section-list))
	    (error "Too many bottom-of-fold marks."))
	(setq section-prefix-list (cdr section-prefix-list))
	(delete-region (point)
		       (progn
			 (forward-line 1)
			 (point)))))
    (and (cdr section-list)
	 (error "Too many top-of-fold marks -- reached end of file prematurely."))
    (goto-char (point-min))
    (buffer-enable-undo)
    (set-buffer-modified-p nil)
    (message "All folds reformatted.")))

;;}}}

;;}}}
;;{{{ Standard fold marks for various major modes

;;{{{ A function to set default marks, `fold-add-to-marks-list'

(defun fold-add-to-marks-list (mode top bottom
				    &optional secondary noforce message)
  "Add/set fold marks for a particular major mode.
When called interactively, asks for a major-mode name, and for
fold marks to be used in that mode.  It adds the new set to
`fold-mode-marks-list', and if the mode name is the same as the current
major mode for the current buffer, the marks in use are also changed.

If called non-interactively, arguments are MODE, TOP, BOTTOM and
SECONDARY.  MODE is the symbol for the major mode for which marks are
being set.  TOP, BOTTOM and SECONDARY are strings, the three fold marks
to be used.  SECONDARY may be nil (as opposed to the empty string), but
the other two must be non-empty strings, and is an optional argument.

Two other optional arguments are NOFORCE, meaning do not change the
marks if marks are already set for the specified mode if non-nil, and
MESSAGE, which causes a message to be displayed if it is non-nil.  This
is also the message displayed if the function is called interactively.

To set default fold marks for a particular mode, put something like the
following in your .emacs:

\(fold-add-to-marks-list 'major-mode \"(** {{{ \" \"(** }}} **)\" \" **)\")

Look at the variable `fold-mode-marks-list' to see what default settings
already apply.

`fold-set-marks' can be used to set the fold marks in use in the current
buffer without affecting the default value for a particular mode."
  (interactive
   (let* ((mode (completing-read
		 (concat "Add fold marks for major mode ("
			 (symbol-name major-mode)
			 "): ")
		 obarray
		 (function
		  (lambda (arg)
		    (and (commandp arg)
			 (string-match "-mode\\'"
				       (symbol-name arg)))))
		 t))
	  (mode (if (equal mode "")
		    major-mode
		  (intern mode)))
	  (object (assq mode fold-mode-marks-list))
	  (old-top (and object
		   (nth 1 object)))
	  top
	  (old-bottom (and object
		      (nth 2 object)))
	  bottom
	  (secondary (and object
			 (nth 3 object)))
	  (prompt "Top fold marker: "))
     (and (equal secondary "")
	  (setq secondary nil))
     (while (not top)
       (setq top (read-string prompt (or old-top "{{{ ")))
       (and (equal top "")
	    (setq top nil)))
     (setq prompt (concat prompt
			  top
			  ", Bottom marker: "))
     (while (not bottom)
       (setq bottom (read-string prompt (or old-bottom "}}}")))
       (and (equal bottom "")
	    (setq bottom nil)))
     (setq prompt (concat prompt
			  bottom
			  (if secondary
			      ", Secondary marker: "
			    ", Secondary marker (none): "))
	   secondary (read-string prompt secondary))
     (and (equal secondary "")
	  (setq secondary nil))
     (list mode top bottom secondary nil t)))
  (let ((object (assq mode fold-mode-marks-list)))
    (if (and object
	     noforce
	     message)
	(message "Fold markers for `%s' are already set."
		 (symbol-name mode))
      (if object
	  (or noforce
	      (setcdr object (if secondary
				 (list top bottom secondary)
			       (list top bottom))))
	(setq fold-mode-marks-list
	      (cons (if secondary
			(list mode top bottom secondary)
		      (list mode top bottom))
		    fold-mode-marks-list)))
      (and message
	     (message "Set fold marks for `%s' to \"%s\" and \"%s\"."
		      (symbol-name mode)
		      (if secondary
			  (concat top "name" secondary)
			(concat top "name"))
		      bottom)
	     (and (eq major-mode mode)
		  (fold-set-marks top bottom secondary))))))

;;}}}
;;{{{ Set some useful default fold marks

(fold-add-to-marks-list 'c-mode "/* {{{ " "/* }}} */" " */" t)
(fold-add-to-marks-list 'emacs-lisp-mode ";;{{{ " ";;}}}" nil t)
(fold-add-to-marks-list 'lisp-interaction-mode ";;{{{ " ";;}}}" nil t)
(fold-add-to-marks-list 'plain-tex-mode "%{{{ " "%}}}" nil t)
(fold-add-to-marks-list 'plain-TeX-mode "%{{{ " "%}}}" nil t)
(fold-add-to-marks-list 'latex-mode "%{{{ " "%}}}" nil t)
(fold-add-to-marks-list 'LaTeX-mode "%{{{ " "%}}}" nil t)
(fold-add-to-marks-list 'orwell-mode "{{{ " "}}}" nil t)
(fold-add-to-marks-list 'gofer-mode "{{{- " "{--}}}" " -}" t)
(fold-add-to-marks-list 'fundamental-mode "{{{ " "}}}" nil t)
(fold-add-to-marks-list 'modula-2-mode "(* {{{ " "(* }}} *)" " *)" t)
(fold-add-to-marks-list 'shellscript-mode "# {{{ " "# }}}" nil t)
(fold-add-to-marks-list 'perl-mode "# {{{ " "# }}}" nil t)
(fold-add-to-marks-list 'texinfo-mode "@c {{{ " "@c {{{endfold}}}" " }}}" t)
(fold-add-to-marks-list 'occam-mode "-- {{{ " "-- }}}" nil t)

;;}}}

;;}}}
;;{{{ Start folding mode automatically for folded files

;;{{{ folding-mode-find-file-hook

(defun folding-mode-find-file-hook ()
  "One of the hooks called whenever a `find-file' is successful.
It checks to see if `folded-file' has been set as a buffer-local
variable, and starts folding mode if it has.

To make this hook effective, the symbol `folding-mode-find-file-hook'
should be placed at the end of `find-file-hooks'.  If you have
some other hook in the list, for example a hook to automatically
uncompress or decrypt a buffer, it should go earlier on in the list
so that the file can be folded after the buffer has been modified.

Note that if folding mode is started, the buffer does get modified.
Emacs reverse the effects of folding mode if it writes the file,
but it would not be desirable on, for example, a binary file.

See also `folding-mode-add-find-file-hook'."
  (and (assq 'folded-file (buffer-local-variables))
       folded-file
       (folding-mode 1)
       (kill-local-variable 'folded-file)))

;;}}}
;;{{{ folding-mode-add-find-file-hook

(defun folding-mode-add-find-file-hook ()
  "Adds `folding-mode-find-file-hook' to the list `find-file-hooks'.
This has the effect that when a folded file is found (with `find-file'),
and if the Emacs local variables are written appropriately in the file,
folding mode is started automatically.

If `inhibit-local-variables' is non-nil, this will not happen regardless
of the setting of `find-file-hooks'.

To declare a file to be folded, put \"folded-file: t\" in the file's
local variables. eg. at the end of a C file (^L is typed using C-q C-l):

/*
^L
Local variables:
folded-file: t
*/

The local variables can be inside a fold."
  (interactive)
  (or (memq 'folding-mode-find-file-hook find-file-hooks)
      (setq find-file-hooks (cons 'folding-mode-find-file-hook
				  find-file-hooks))))

;;}}}

;;}}}
;;{{{ Miscellaneous

;;{{{ eval-current-buffer-open-folds

(defun eval-current-buffer-open-folds (&optional printflag)
  "Evaluate all of a folded buffer as Lisp code.
Unlike `eval-current-buffer', this function will evaluate all of a
buffer, even if it is folded.  It will also work correctly on non-folded
buffers, so is a good candidate for being bound to a key if you program
in Emacs-Lisp.

It works by making a copy of the current buffer in another buffer,
unfolding it and evaluating it.  It then deletes the copy.

Programs can pass argument PRINTFLAG which controls printing of output:
nil means discard it; anything else is stream for print."
  (interactive)
  (if (or (and (boundp 'folding-mode-flag)
	       folding-mode-flag)
	  (and (boundp 'folding-mode)
	       folding-mode))
      (let ((temp-buffer
	     (generate-new-buffer (buffer-name))))
	(message "Evaluating unfolded buffer...")
	(save-restriction
	  (widen)
	  (copy-to-buffer temp-buffer (point-min) (point-max)))
	(set-buffer temp-buffer)
	(subst-char-in-region (point-min) (point-max) ?\r ?\n)
	(let ((real-message-def (symbol-function 'message))
	      (suppress-eval-message))
	  (fset 'message
		(function
		 (lambda (&rest args)
		   (setq suppress-eval-message t)
		   (fset 'message real-message-def)
		   (apply 'message args))))
	  (unwind-protect
	      (eval-current-buffer printflag)
	    (fset 'message real-message-def)
	    (kill-buffer temp-buffer))
	  (or suppress-eval-message
	      (message "Evaluating unfolded buffer... Done"))))
    (eval-current-buffer printflag)))

;;}}}

;;}}}

;;{{{ The infamous Emacs local variables


;; Local variables:
;; mode: folding
;; end:

;;}}}
