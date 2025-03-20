.PHONY: files-to-org org-to-files clean

# Variables
EMACS := emacs
ORG_FILE := project.org
SOURCE_FILES := scripts/python/example.py \
	scripts/shell/example.sh \
	config/.gitignore

# Convert files to org-mode
files-to-org:
	@echo "Converting files to org-mode format..."
	@./files-to-org.sh $(ORG_FILE) $(SOURCE_FILES)
	@echo "Created $(ORG_FILE) from source files."

# Convert org-mode back to files
org-to-files:
	@echo "Tangling org-mode file to source files..."
	@$(EMACS) --batch \
		--eval "(require 'org)" \
		--eval "(setq org-confirm-babel-evaluate nil)" \
		--eval "(find-file \"$(ORG_FILE)\")" \
		--eval "(org-babel-tangle)" \
		--eval "(kill-buffer)"
	@echo "Tangled files from $(ORG_FILE)."

# Clean generated files
clean:
	@echo "Cleaning up..."
	@rm -f $(ORG_FILE)
	@echo "Cleaned."