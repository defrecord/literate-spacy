.PHONY: tangle detangle clean

# Variables
EMACS := emacs
ORG_FILE := test.org
GENERATED_DIR := ../generated

# Tangle org file to generate code files
tangle:
	@echo "Tangling $(ORG_FILE) to generate code files..."
	@$(EMACS) --batch \
		--eval "(require 'org)" \
		--eval "(setq org-confirm-babel-evaluate nil)" \
		--eval "(find-file \"$(ORG_FILE)\")" \
		--eval "(org-babel-tangle)" \
		--eval "(kill-buffer)"
	@echo "Tangle complete."

# Detangle code files back to org file
detangle:
	@echo "Detangling code files back to $(ORG_FILE)..."
	@$(EMACS) --batch \
		--eval "(require 'org)" \
		--eval "(setq org-confirm-babel-evaluate nil)" \
		--eval "(setq org-src-preserve-indentation t)" \
		--eval "(find-file \"$(ORG_FILE)\")" \
		--eval "(org-babel-detangle)" \
		--eval "(save-buffer)" \
		--eval "(kill-buffer)"
	@echo "Detangle complete."

# Show tangle/detangle status
status:
	@echo "Checking status of tangled files..."
	@ls -la $(GENERATED_DIR)/test.*

# Clean generated files
clean:
	@echo "Cleaning generated files..."
	@rm -f $(GENERATED_DIR)/test.*