.PHONY: setup download-models run-server run-client test clean tangle detangle status

# Variables
PYTHON := python3
PIP := $(PYTHON) -m pip
MODELS := en_core_web_sm
EMACS := emacs
ORG_FILE := spacy-nlp-tool.org
GENERATED_FILES := src/client/__init__.py src/client/client.py \
	src/server/__init__.py src/server/server.py \
	src/model/__init__.py src/model/processor.py \
	scripts/download_models.py scripts/setup.py

# Setup the environment
setup:
	$(PIP) install -e .
	$(MAKE) download-models

# Download spaCy models
download-models:
	$(PYTHON) scripts/download_models.py --models $(MODELS)

# Run the server
run-server:
	$(PYTHON) -m src.server.server

# Run the client
run-client:
	$(PYTHON) -m src.client.client

# Clean artifacts
clean:
	rm -rf __pycache__
	rm -rf src/__pycache__
	rm -rf src/*/__pycache__
	rm -rf *.egg-info
	rm -rf build dist

# Development tasks
dev-setup: setup
	$(PIP) install pytest black isort flake8

format:
	isort src scripts
	black src scripts

lint:
	flake8 src scripts
	isort --check src scripts
	black --check src scripts

test:
	pytest tests/

# Org-mode tasks - extract code from org files
tangle:
	@echo "Tangling $(ORG_FILE) to generate code files..."
	@$(EMACS) --batch \
		--eval "(require 'org)" \
		--eval "(setq org-confirm-babel-evaluate nil)" \
		--eval "(find-file \"$(ORG_FILE)\")" \
		--eval "(org-babel-tangle)" \
		--eval "(kill-buffer)"
	@echo "Tangle complete."

# Org-mode tasks - update org files from source code
detangle:
	@echo "Detangling generated files back to $(ORG_FILE)..."
	@$(EMACS) --batch \
		--eval "(require 'org)" \
		--eval "(setq org-confirm-babel-evaluate nil)" \
		--eval "(setq org-src-preserve-indentation t)" \
		--eval "(message \"Processing files...\")" \
		$(foreach file,$(GENERATED_FILES),--eval "(when (file-exists-p \"$(file)\") (message \"Detangling $(file)...\") (org-babel-detangle \"$(file)\"))" )
	@echo "Detangle complete."

# Show tangle/detangle status
status:
	@echo "Checking status of tangled files vs org file..."
	@for file in $(GENERATED_FILES); do \
		if [ -f "$$file" ]; then \
			if [ "$$file" -nt "$(ORG_FILE)" ]; then \
				echo "$$file is newer than $(ORG_FILE) - needs detangle"; \
			elif [ "$(ORG_FILE)" -nt "$$file" ]; then \
				echo "$(ORG_FILE) is newer than $$file - needs tangle"; \
			else \
				echo "$$file is in sync with $(ORG_FILE)"; \
			fi; \
		else \
			echo "$$file does not exist - needs tangle"; \
		fi; \
	done