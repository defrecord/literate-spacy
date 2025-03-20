#!/bin/bash
# Tangle a file using org-babel

emacs --batch --no-init-file \
    --eval "(progn
       (require 'org)
       (find-file \"final_test.org\")
       (org-babel-tangle)
       (kill-buffer))"