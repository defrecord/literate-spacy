# [[file:.workspace/20250320_171642/calculator.org::*/Users/jasonwalsh/projects/defrecord/literate-spacy/test/files-to-prompt/calculator/Makefile][/Users/jasonwalsh/projects/defrecord/literate-spacy/test/files-to-prompt/calculator/Makefile:1]]
# [[file:../../../../../../../../var/folders/9z/9bvmr7bs731_0ps9m4yhb3380000gn/T/tmp.zVm7sfJiQh/calculator.org::*/Users/jasonwalsh/projects/defrecord/literate-spacy/test/files-to-prompt/calculator/Makefile][/Users/jasonwalsh/projects/defrecord/literate-spacy/test/files-to-prompt/calculator/Makefile:1]]
# Makefile for Polish Notation Calculator

# Variables
SCHEME = scheme
SRC_DIR = src
BIN_DIR = bin
CALC_SCRIPT = $(SRC_DIR)/polcalc.scm
RUN_SCRIPT = $(BIN_DIR)/run-calculator.sh

# Main targets
.PHONY: all test test-flow test-review full-test install clean help

all: test

# Full testing suite
full-test: test test-flow test-review

# Make scripts executable
executable:
	@chmod +x $(CALC_SCRIPT)
	@chmod +x $(RUN_SCRIPT)

# Run tests
test: executable
	@echo "Running tests..."
	@echo "Test 1: Addition"
	@$(RUN_SCRIPT) "+ 2 3" | grep -q "5" && echo "PASS" || echo "FAIL"
	@echo "Test 2: Nested operations"
	@$(RUN_SCRIPT) "* + 2 3 4" | grep -q "20" && echo "PASS" || echo "FAIL"
	@echo "Test 3: Division"
	@$(RUN_SCRIPT) "/ 10 - 6 2" | grep -q "2.5" && echo "PASS" || echo "FAIL"
	@echo "All tests completed."

# Install to /usr/local/bin (requires sudo)
install: executable
	@echo "Installing calculator..."
	@cp $(CALC_SCRIPT) /usr/local/bin/polcalc
	@cp $(RUN_SCRIPT) /usr/local/bin/polcalc-run
	@echo "Installation complete. You can now run 'polcalc-run'"

# Clean up
clean:
	@echo "Cleaning up..."
	@find . -name "*.log" -type f -delete
	@find . -name "*~" -type f -delete
	@rm -rf .workspace/*
	@echo "Cleanup complete."

# Flow testing targets
test-flow:
	@echo "Running flow test..."
	@./test-flow.sh

test-review:
	@echo "Running review test..."
	@./test-review.sh

# Help
help:
	@echo "Polish Notation Calculator Makefile"
	@echo "---------------------------------"
	@echo "Targets:"
	@echo "  all       : Default target, runs tests"
	@echo "  executable: Make scripts executable"
	@echo "  test      : Run basic test suite"
	@echo "  test-flow : Run the flow test to verify org tangling"
	@echo "  test-review: Run the review test to verify prompt creation"
	@echo "  full-test : Run all tests (basic tests + flow testing + review testing)"
	@echo "  install   : Install calculator to /usr/local/bin (requires sudo)"
	@echo "  clean     : Remove temporary files"
	@echo "  help      : Display this help message"
# /Users/jasonwalsh/projects/defrecord/literate-spacy/test/files-to-prompt/calculator/Makefile:1 ends here
# /Users/jasonwalsh/projects/defrecord/literate-spacy/test/files-to-prompt/calculator/Makefile:1 ends here
