;; Simple tangle script
(require 'org)
(find-file "alt_test.org")
(org-babel-tangle)
(kill-buffer)