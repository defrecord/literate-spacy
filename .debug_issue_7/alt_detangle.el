;; Simple detangle script
(require 'org)
(setq org-src-preserve-indentation t)
(setq org-src-fontify-natively t)
(setq org-confirm-babel-evaluate nil)

(find-file "alt_test.org")
(message "Starting detangle")
(org-babel-detangle "alt_test.py")
(message "Completed detangle operation")
(save-buffer)
(kill-buffer)