;; Debug detangle script
(require 'org)
(setq debug-on-error t)

(defun my-debug-detangle-process ()
  "Debug the detangle process with verbose output."
  (let ((src-file "solution_test.py"))
    (message "Starting detangle of %s" src-file)
    (message "1. Current buffer: %s" (buffer-name))
    (find-file "solution_test.org")
    (message "2. Finding source file: %s" src-file)
    (message "3. Source file exists: %s" (file-exists-p src-file))
    (message "4. Org mode version: %s" (org-version))
    (message "5. Link search regexp: %s" org-link-bracket-re)
    (message "6. About to run org-babel-detangle")
    (let ((result (org-babel-detangle src-file)))
      (message "7. Detangle result: %s" result))
    (message "8. Saving buffer")
    (save-buffer)
    (message "9. Detangle process complete")))

(my-debug-detangle-process)