;; muf-mode.el:  GNU Emacs major mode for editing muf source
;;
;; A token muf-mode which exists only so folding.el can key on
;; it when selecting foldmarks;  it is otherwise functionally
;; identical to text-mode.
;;
;; Copyright {c} 1995, by Cynbe ru Taren.
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU Library General Public License as
;; published by	the Free Software Foundation; either version 2, or at
;; your option	any later version.
;;
;;   This program is distributed in the hope that it will be useful,
;;   but WITHOUT ANY WARRANTY; without even the implied warranty of
;;   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;   GNU Library General Public License for more details.
;;
;;   You should have received a copy of the GNU General Public License
;;   along with this program: COPYING.LIB; if not, write to:
;;      Free Software Foundation, Inc.
;;      675 Mass Ave, Cambridge, MA 02139, USA.
;;
;; CYNBE RU TAREN DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,
;; INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN
;; NO EVENT SHALL CYNBE RU TAREN BE LIABLE FOR ANY SPECIAL, INDIRECT OR
;; CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS
;; OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,
;; NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION
;; WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
;;
;; Please send bug reports/fixes etc to cynbe@qwest.tcp.com.

(provide 'muf-mode)

(defvar muf-mode-abbrev-table nil
  "Abbrev table used while in muf mode.")

(defvar muf-mode-map nil
     "Major mode keymap for muf-mode buffers")
(if (not muf-mode-map)
    (progn
      (setq muf-mode-map (make-sparse-keymap))))

(defun muf-mode ()
  "Major mode for editing Muq muf source.
\\{muf-mode-map}
Turning on Muf mode runs muf-mode-hook."
  (interactive)
  (kill-all-local-variables)
  (use-local-map muf-mode-map)
  (setq mode-name "Muf")
  (setq major-mode 'muf-mode)
  (set-syntax-table c-mode-syntax-table)
  (setq local-abbrev-table muf-mode-abbrev-table)
  (run-hooks 'muf-mode-hook))

