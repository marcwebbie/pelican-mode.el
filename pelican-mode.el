;;; pelican-mode.el --- Pelican static site generator mode for emacs

;; Copyright (C) 2014 Marcwebbie

;; Author: Marcwebbie <marcwebbie@gmail.com>
;; Version: 0.1
;; Keywords: pelican, python, blogs, sites, static
;; Package-Requires: ((cl-lib "0.5"))

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;; Code:

(require 's)


;; ========================
;; Misc functions
;; ========================

(defun pelican-timestamp-now ()
  "Generate a Pelican-compatible timestamp."
  (format-time-string "%Y-%m-%d %H:%M"))

(defun pelican-find-in-parents (file-name)
  "Find FILE-NAME in the default directory or one of its parents, or nil."
  (let* ((parent (expand-file-name default-directory)))
    (while (and (not (file-readable-p (concat parent file-name)))
                (not (string= parent (directory-file-name parent))))
      (setq parent (file-name-directory (directory-file-name parent))))
    (let ((found (concat parent file-name)))
      (if (file-readable-p found) found nil))))

(defun pelican-find-root ()
  "Return the root of the buffer's Pelican site, or nil."
  (let ((conf (pelican-find-in-parents "pelicanconf.py")))
    (if conf (file-name-directory conf))))


;; ========================
;; Confs functions
;; ========================

(defun pelican-find-conf-path ()
  "Return full path to pelicanconf.py"
  (expand-file-name "pelicanconf.py" (pelican-find-root)))

(defun pelican-find-publishconf-path ()
  "Return full path to publishconf.py"
  (expand-file-name "publishconf.py" (pelican-find-root)))

(defun pelican-open-conf ()
  "Open pelicanconf.py in a new buffer"
  (interactive)
  (if (pelican-find-root)
      (find-file (pelican-find-conf-path))
    (message "Couldn't find pelicanconf.py")))

(defun pelican-open-publishconf ()
  "Open pelicanconf.py in a new buffer"
  (interactive)
  (if (pelican-find-root)
      (find-file (pelican-find-publishconf-path))
    (message "Couldn't find publishconf.py")))

(defun pelican-conf-var (var)
  "Return the value of VAR set in pelicanconf.py"
  (let* ((cmd (format "cd %s && python -c '%s = str();from pelicanconf import *; print(%s)'"
                      (pelican-find-root)
                      var
                      var))
         (output (string-trim-right (shell-command-to-string cmd))))
    (if (equal "" output) nil output)))

(defun pelican-publishconf-var (var)
  "Return the value of VAR set in publishconf.py"
  (let* ((cmd (format "cd %s && python -c '%s = str();from publishconf import *; print(%s)'"
                      (pelican-find-root)
                      var
                      var))
         (output (string-trim-right (shell-command-to-string cmd))))
    (if (equal "" output) nil output)))

(defun pelican-conf-path ()
  "Return pelicanconf.py path"
  (let ((conf (pelican-find-in-parents "pelicanconf.py")))
    (if conf conf)))


;; ========================
;; Content functions
;; ========================

(defun pelican-field (name value)
  "Helper to format a field NAME and VALUE."
  (if value (format "%s: %s\n" name value) ""))


(defun pelican-rst-header (title date status category tags slug summary)
  "Generate a Pelican reStructuredText header.

All parameters but TITLE may be nil to omit them. DATE may be a
string or 't to use the current date and time."
  (let ((title (format "%s\n%s\n%s\n\n"
                       (make-string (string-width title) ?#)
                       title
                       (make-string (string-width title) ?#)))
        (title-field (pelican-field ":title" title))
        (status (pelican-field ":status" status))
        (category (pelican-field ":category" category))
        (tags (pelican-field ":tags" tags))
        (slug (pelican-field ":slug" slug))
        (date (if date (format ":date: %s\n"
                               (if (stringp date) date
                                 (pelican-timestamp-now))) ""))
        (summary (pelican-field ":summary" summary))
        )
    (concat title title-field date status tags category slug summary "\n")))


;; ========================
;; Make
;; ========================

(defun pelican-make (target)
  "Execute TARGET in a Makefile at the root of the site."
  (interactive "sMake Pelican target: ")
  (let ((default-directory (pelican-find-root)))
    (if default-directory
        (let ((output (get-buffer-create "*Pelican Output*")))
          (display-buffer output)
          (pop-to-buffer output)
          (compilation-mode)
          (start-process "Pelican Makefile" output "make" target))
      (message "This doesn't look like a Pelican site."))))

(defun pelican-make-html ()
  "Generate HTML via a Makefile at the root of the site."
  (interactive)
  (pelican-make "html"))

(defun pelican-make-publish ()
  "Generate Publish content via a Makefile at the root of the site."
  (interactive)
  (pelican-make "publish"))

(defun pelican-make-serve ()
  "Serve content locally via a Makefile at the root of the site."
  (interactive)
  (pelican-make "serve"))

(defun pelican-make-generate-serve ()
  "Generate html and run local server via a Makefile at the root of the site."
  (interactive)
  (progn
    (pelican-make "html")
    (pelican-make-serve)))


;; ========================
;; Posts
;; ========================

(defun pelican-new-post-draft (title)
  "Create new rst post draft and open it in a new buffer"
  (interactive "sPost title: ")
  (let* (
         (conf-content-var (pelican-conf-var "PATH"))
         (content-path (if conf-content-var conf-content-var "output"))
         (slug (s-dashed-words title))
         (draft-path (format "%s/content/%s.rst" (pelican-find-root) slug))
         (category "<CATEGORY>")
         (tags "<TAGS>")
         (summary "<SUMMARY>")
         (header (pelican-rst-header
                  title
                  (pelican-timestamp-now)
                  "draft"
                  category
                  tags
                  slug
                  summary)))
    (write-region header nil draft-path)
    (message "Created new rst draft at: %s" draft-path)
    (find-file draft-path)))


;; ========================
;; Define mode
;; ========================

;;;###autoload
(define-minor-mode pelican-mode
  "Toggle pelicanmode"
  :lighter " Pelican")

(defun pelican-mode-off ()
  "Disable `pelican-mode' minor mode."
  (pelican-mode -1))

;;;###autoload
(defun pelican-mode-on ()
  "Enable `pelican-mode' minor mode if this is a pelican project."
  (if (pelican-find-root) (pelican-mode +1) (pelican-mode -1)))


;; ========================
;; auto enabling pelican mode
;; ========================

(defadvice find-file (after defadvice-pelican-find-file (filename &optional wildcards) activate)
  (pelican-mode-on))

(if (fboundp 'ido-find-file)
    (defadvice ido-find-file (after defadvice-pelican-ido-find-file activate)
      (pelican-mode-on)))

(provide 'pelican-mode)
