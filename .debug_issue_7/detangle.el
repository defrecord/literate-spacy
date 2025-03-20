;; Detangle script

(require 'org)
(setq org-src-preserve-indentation t)
(setq org-src-fontify-natively t)
(setq org-confirm-babel-evaluate nil)

(defun my-explicit-detangle ()
  "Explicitly detangle test.py to test.org"
  (interactive)
  (let ((org-file "test.org")
        (src-file "test.py"))
    (find-file org-file)
    (message "Before detangle: org-file loaded")
    (org-babel-detangle src-file)
    (message "After detangle: completed detangle operation")
    (save-buffer)
    (kill-buffer)))

(my-explicit-detangle)