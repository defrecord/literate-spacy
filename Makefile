.PHONY: setup download-models run-server run-client test clean

# Variables
PYTHON := python3
PIP := $(PYTHON) -m pip
MODELS := en_core_web_sm

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
