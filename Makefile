.PHONY: setup download-models run-server run-client test clean tangle detangle

# Variables
PYTHON := python3
PIP := $(PYTHON) -m pip
MODELS := en_core_web_sm
EMACS := emacs
ORG_FILE := spacy-nlp-tool.org

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

# Org-mode tasks
tangle:
	$(EMACS) --batch --eval "(require 'org)" --eval "(progn (find-file \"$(ORG_FILE)\") (org-babel-tangle) (kill-buffer))"

detangle:
	$(EMACS) --batch --eval "(require 'org)" --eval "(progn (find-file \"$(ORG_FILE)\") (org-babel-detangle) (save-buffer) (kill-buffer))"