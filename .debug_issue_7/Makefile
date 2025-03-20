.PHONY: tangle detangle clean

# Only two commands - tangle and detangle
tangle:
	@echo "Tangling test.org to test.py..."
	@emacs --batch \
		--eval "(require 'org)" \
		--eval "(find-file \"test.org\")" \
		--eval "(org-babel-tangle)" \
		--eval "(kill-buffer)"
	@echo "Tangle complete"

detangle:
	@echo "Detangling test.py back to test.org using script..."
	@emacs --batch -l detangle.el
	@echo "Detangle complete"

clean:
	@echo "Cleaning up..."
	@rm -f test.py