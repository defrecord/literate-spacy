.PHONY: setup download-models run-server run-client test clean tangle detangle

# Variables
PYTHON := python3
PIP := $(PYTHON) -m pip
MODELS := en_core_web_sm
EMACS := emacs
ORG_FILES := spacy-nlp-tool.org
GENERATED_FILES := Makefile \
	src/client/__init__.py src/client/client.py \
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

# Example client command
run-client:
	$(PYTHON) -m src.client.client

# Clean artifacts
clean:
	rm -rf __pycache__
	rm -rf src/__pycache__
	rm -rf src/*/__pycache__
	rm -rf *.egg-info
	rm -rf build dist

# Install development dependencies
dev-setup: setup
	$(PIP) install pytest black isort flake8

# Format code
format:
	isort src scripts
	black src scripts

# Check code quality
lint:
	flake8 src scripts
	isort --check src scripts
	black --check src scripts

# Run tests
test:
	pytest tests/

# Tangle Org files to generate code files
tangle:
	$(EMACS) --batch --eval "(require 'org)" --eval "(dolist (file '($(ORG_FILES))) (find-file file) (org-babel-tangle) (kill-buffer))"

# Detangle code files back to Org files
detangle:
	@for file in $(GENERATED_FILES); do \
		if [ -f "$$file" ]; then \
			if [ "$$file" -nt "$(ORG_FILES)" ]; then \
				echo "$$file is newer than $(ORG_FILES), detangling..."; \
				$(EMACS) --batch --eval "(require 'org)" --eval "(find-file \"$(ORG_FILES)\")" --eval "(org-babel-detangle)" --eval "(save-buffer)" --eval "(kill-buffer)"; \
				break; \
			fi; \
		fi; \
	done

# Make generated files depend on tangle
$(GENERATED_FILES): tangle
