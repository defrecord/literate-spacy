(require 'org)
(setq-default org-src-preserve-indentation t)

;; Open the org file
(find-file "../spacy-nlp-tool.org")

;; Force detangle
(let ((org-babel-tangle-uncomment-comments t))
  (org-babel-detangle))

;; Save the file
(save-buffer)
(kill-buffer)