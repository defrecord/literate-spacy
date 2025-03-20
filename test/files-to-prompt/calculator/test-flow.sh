#!/bin/bash
# Complete test flow for files-to-prompt with Ollama

set -e  # Exit on error

# Get directory paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Locate files-to-org.sh script in the same dir, parent dir, or standard locations
FILES_TO_PROMPT_DIR="${SCRIPT_DIR}"
if [ -f "${SCRIPT_DIR}/../files-to-org.sh" ]; then
    FILES_TO_PROMPT_DIR="${SCRIPT_DIR}/.."
elif [ -f "/usr/local/bin/files-to-org.sh" ]; then
    FILES_TO_PROMPT_DIR="/usr/local/bin"
fi

# Create workspace directory
WORKSPACE_DIR="${SCRIPT_DIR}/.workspace"
mkdir -p "${WORKSPACE_DIR}"

# Add .gitkeep file if it doesn't exist
if [ ! -f "${WORKSPACE_DIR}/.gitkeep" ]; then
    echo "# This directory is for temporary files" > "${WORKSPACE_DIR}/.gitkeep"
    echo "# Contents should not be committed to git" >> "${WORKSPACE_DIR}/.gitkeep"
fi

# Clean previous test artifacts
rm -rf "${WORKSPACE_DIR}"/*

# Create test directory with timestamp
TEST_DIR="${WORKSPACE_DIR}/test_$(date +%Y%m%d_%H%M%S)"
mkdir -p "${TEST_DIR}"
echo "Created test directory: ${TEST_DIR}"

# Define files to use in relative paths
cd "${SCRIPT_DIR}"
FILES=(
  "src/polcalc.scm"
  "bin/run-calculator.sh"
  "Makefile"
)

echo ""
echo "===== PART 1: GENERATE ORG FROM FILES ====="
echo "Converting files to org format..."

# Create org file
ORG_FILE="${TEST_DIR}/calculator.org"
"${FILES_TO_PROMPT_DIR}/files-to-org.sh" "${ORG_FILE}" "${FILES[@]}"
echo "Created org file: ${ORG_FILE}"

echo ""
echo "===== PART 2: TANGLE ORG BACK TO FILES ====="

# Create directory for tangled files
TANGLE_DIR="${TEST_DIR}/tangled"
mkdir -p "${TANGLE_DIR}/src" "${TANGLE_DIR}/bin"

# Create a modified org file with correct tangle paths
FIXED_ORG="${TEST_DIR}/fixed-calculator.org"
echo "Creating org file with fixed tangle paths..."
sed "s|:tangle src/|:tangle ${TANGLE_DIR}/src/|g" "${ORG_FILE}" | \
    sed "s|:tangle bin/|:tangle ${TANGLE_DIR}/bin/|g" | \
    sed "s|:tangle Makefile|:tangle ${TANGLE_DIR}/Makefile|g" > "${FIXED_ORG}"

# Run tangle from the project root to ensure correct paths
cd "${SCRIPT_DIR}"
echo "Tangling org file to recreate source files..."
emacs --batch \
  --eval "(require 'org)" \
  --eval "(setq org-confirm-babel-evaluate nil)" \
  --eval "(find-file \"${FIXED_ORG}\")" \
  --eval "(org-babel-tangle)" \
  --eval "(kill-buffer)"

# Check results
echo "Checking tangled files:"
echo "Verifying bidirectional integrity:"

# Function to compare original and tangled file
compare_files() {
    local orig_file="$1"
    local tangled_file="$2"
    local file_name="$3"
    
    if [ -f "$tangled_file" ]; then
        echo "- $file_name: EXISTS"
        if diff -q "$orig_file" "$tangled_file" >/dev/null; then
            echo "  - Contents match original: YES"
        else
            echo "  - Contents match original: NO (differences detected)"
            echo "    Original: $orig_file"
            echo "    Tangled: $tangled_file"
        fi
    else
        echo "- $file_name: MISSING"
    fi
}

# Compare all files
compare_files "${SCRIPT_DIR}/src/polcalc.scm" "${TANGLE_DIR}/src/polcalc.scm" "src/polcalc.scm"
compare_files "${SCRIPT_DIR}/bin/run-calculator.sh" "${TANGLE_DIR}/bin/run-calculator.sh" "bin/run-calculator.sh"
compare_files "${SCRIPT_DIR}/Makefile" "${TANGLE_DIR}/Makefile" "Makefile"

# Count how many files were successfully tangled
TANGLED_COUNT=$(find "${TANGLE_DIR}" -type f | wc -l | tr -d ' ')
echo "Successfully tangled $TANGLED_COUNT out of 3 files."

echo ""
echo "===== PART 3: OLLAMA PROMPT CREATION ====="

# Create prompt for Ollama
PROMPT_FILE="${TEST_DIR}/prompt.md"
echo "Creating Ollama prompt file..."

cat > "${PROMPT_FILE}" << EOF
# Code Review Request with RPN Enhancement

I'm sending you my Polish notation calculator implementation. Please:

1. Review the code for correctness and best practices
2. Add a new function to handle reverse Polish notation (RPN)
3. Return your answer as a COMPLETE org-mode document with proper :tangle directives

Here's my current implementation:

$(cat "${ORG_FILE}")
EOF

echo "Created prompt file: ${PROMPT_FILE}"

echo ""
echo "===== PART 4: OLLAMA SIMULATION ====="

# Create a simulated Ollama response
RESPONSE_FILE="${TEST_DIR}/ollama_response.md"
echo "Creating simulated Ollama response..."

# Create a mock response with RPN support
cat > "${RESPONSE_FILE}" << EOF
Here's my review and improved implementation with RPN support:

\`\`\`org
#+TITLE: Enhanced Calculator
#+AUTHOR: AI Assistant
#+DATE: $(date +%Y-%m-%d)

* Project Structure

Files included in this document:

- src/polcalc.scm
- bin/run-calculator.sh
- Makefile

* src/polcalc.scm

#+begin_src scheme :tangle src/polcalc.scm :mkdirp yes :comments link
#!/usr/bin/env scheme-script
;; Polish/RPN Notation Calculator
;; Supports both prefix (Polish) and postfix (RPN) notation

(define (string->number-safe str)
  "Convert string to number safely, returning #f if not a number"
  (with-exception-handler
    (lambda (exn) #f)
    (lambda () (string->number str))))

(define (tokenize expr)
  "Split expression into tokens"
  (string-split expr char-whitespace?))

;; Original Polish notation calculator
(define (calculate-polish tokens)
  "Evaluate a list of tokens in Polish notation"
  (let loop ((tokens tokens)
             (stack '()))
    (cond
      ;; No more tokens and one result on stack
      ((and (null? tokens) (= (length stack) 1))
       (car stack))
      
      ;; No more tokens but incorrect number of values on stack
      ((null? tokens)
       (error "Invalid expression: too many or too few operands"))
      
      (else
        (let ((token (car tokens))
              (rest (cdr tokens)))
          
          ;; Check if token is an operator
          (case token
            ;; Addition
            (("+")
             (if (< (length stack) 2)
                 (error "Not enough operands for +")
                 (let ((b (cadr stack))
                       (a (car stack)))
                   (loop rest (cons (+ a b) (cddr stack))))))
            
            ;; Subtraction
            (("-")
             (if (< (length stack) 2)
                 (error "Not enough operands for -")
                 (let ((b (cadr stack))
                       (a (car stack)))
                   (loop rest (cons (- a b) (cddr stack))))))
            
            ;; Multiplication
            (("*")
             (if (< (length stack) 2)
                 (error "Not enough operands for *")
                 (let ((b (cadr stack))
                       (a (car stack)))
                   (loop rest (cons (* a b) (cddr stack))))))
            
            ;; Division
            (("/")
             (if (< (length stack) 2)
                 (error "Not enough operands for /")
                 (let ((b (cadr stack))
                       (a (car stack)))
                   (if (zero? a)
                       (error "Division by zero")
                       (loop rest (cons (/ a b) (cddr stack)))))))
            
            ;; If token is not an operator, try to parse as number
            (else
              (let ((num (string->number-safe token)))
                (if num
                    (loop rest (cons num stack))
                    (error (string-append "Unknown token: " token)))))))))))

;; NEW: RPN calculator implementation
(define (calculate-rpn tokens)
  "Evaluate a list of tokens in Reverse Polish Notation (postfix)"
  (let loop ((remaining-tokens tokens)
             (stack '()))
    (cond
      ;; If no more tokens and exactly one value on stack, return it
      ((and (null? remaining-tokens) (= (length stack) 1))
       (car stack))
      
      ;; If no more tokens but wrong number of values, error
      ((null? remaining-tokens)
       (error "RPN: Invalid expression - stack should have exactly one value"))
      
      ;; Process next token
      (else
       (let ((token (car remaining-tokens))
             (rest (cdr remaining-tokens)))
         
         (case token
           ;; Addition: pop two values, add, push result
           (("+")
            (if (< (length stack) 2)
                (error "RPN: Not enough operands for +")
                (let ((b (car stack))
                      (a (cadr stack)))
                  (loop rest (cons (+ a b) (cddr stack))))))
           
           ;; Subtraction: pop two values, subtract, push result
           (("-")
            (if (< (length stack) 2)
                (error "RPN: Not enough operands for -")
                (let ((b (car stack))
                      (a (cadr stack)))
                  (loop rest (cons (- a b) (cddr stack))))))
           
           ;; Multiplication: pop two values, multiply, push result
           (("*")
            (if (< (length stack) 2)
                (error "RPN: Not enough operands for *")
                (let ((b (car stack))
                      (a (cadr stack)))
                  (loop rest (cons (* a b) (cddr stack))))))
           
           ;; Division: pop two values, divide, push result
           (("/")
            (if (< (length stack) 2)
                (error "RPN: Not enough operands for /")
                (let ((b (car stack))
                      (a (cadr stack)))
                  (if (zero? b)
                      (error "RPN: Division by zero")
                      (loop rest (cons (/ a b) (cddr stack)))))))
           
           ;; If not an operator, try to parse as number and push to stack
           (else
            (let ((num (string->number-safe token)))
              (if num
                  (loop rest (cons num stack))
                  (error (string-append "RPN: Unknown token: " token))))))))))))

;; Combined evaluation function that supports both notations
(define (evaluate expr . options)
  "Evaluate expression in Polish or RPN notation.
   Options: #:mode 'polish or #:mode 'rpn"
  (let* ((mode (if (null? options) 'polish (car options))))
    (case mode
      ((polish) (calculate-polish (reverse (tokenize expr))))
      ((rpn) (calculate-rpn (tokenize expr)))
      (else (error "Unknown notation mode. Use 'polish or 'rpn")))))

;; Command-line interface
(define (main args)
  (if (null? args)
      (begin
        (display "Usage: polcalc.scm [--rpn] \"EXPRESSION\"\n")
        (display "Example (Polish): polcalc.scm \"+ 2 3\"\n")
        (display "Example (RPN): polcalc.scm --rpn \"2 3 +\"\n")
        (exit 1))
      (let* ((rpn-mode? (string=? (car args) "--rpn"))
             (expr (if rpn-mode? (cadr args) (car args)))
             (mode (if rpn-mode? 'rpn 'polish))
             (result (evaluate expr mode)))
        (display result)
        (newline))))

;; Run main function with command-line arguments
(main (cdr (command-line)))
#+end_src

* bin/run-calculator.sh

#+begin_src shell :tangle bin/run-calculator.sh :mkdirp yes :comments link
#!/bin/bash
# Script to run the Polish/RPN notation calculator

SCRIPT_DIR="\$(dirname "\$(readlink -f "\$0")")"
CALC_PATH="\$SCRIPT_DIR/../src/polcalc.scm"

# Check if Scheme is installed
if ! command -v scheme >/dev/null 2>&1; then
    echo "Error: Scheme interpreter not found. Please install a Scheme implementation."
    echo "Suggestion: Install Chez Scheme with 'brew install chezscheme' or similar."
    exit 1
fi

# Make sure calculator script is executable
if [ ! -x "\$CALC_PATH" ]; then
    chmod +x "\$CALC_PATH"
fi

# Function to print help
print_help() {
    echo "Polish/RPN Notation Calculator"
    echo "-----------------------------"
    echo "Usage: \$(basename "\$0") [--rpn] EXPRESSION"
    echo ""
    echo "Examples:"
    echo "  Polish notation (prefix):"
    echo "    \$(basename "\$0") '+ 2 3'        # 2 + 3 = 5"
    echo "    \$(basename "\$0") '* + 2 3 4'    # (2 + 3) * 4 = 20"
    echo ""
    echo "  RPN notation (postfix):"
    echo "    \$(basename "\$0") --rpn '2 3 +'    # 2 + 3 = 5" 
    echo "    \$(basename "\$0") --rpn '2 3 + 4 *' # (2 + 3) * 4 = 20"
    echo ""
    echo "Operators: +, -, *, /"
    exit 0
}

# Check for help flag
if [ "\$1" = "-h" ] || [ "\$1" = "--help" ]; then
    print_help
fi

# Check if an expression was provided
if [ \$# -eq 0 ]; then
    echo "Error: No expression provided."
    echo "Try '\$(basename "\$0") --help' for more information."
    exit 1
fi

# Check for RPN mode
if [ "\$1" = "--rpn" ]; then
    # Ensure expression is provided after --rpn flag
    if [ \$# -lt 2 ]; then
        echo "Error: No expression provided after --rpn flag."
        echo "Try '\$(basename "\$0") --help' for more information."
        exit 1
    fi
    
    # Combine all arguments after --rpn into a single expression
    shift  # Remove the --rpn argument
    EXPRESSION="\$*"
    
    # Run calculator in RPN mode
    "\$CALC_PATH" --rpn "\$EXPRESSION"
else
    # Run in standard Polish notation mode
    EXPRESSION="\$*"
    "\$CALC_PATH" "\$EXPRESSION"
fi

# Get exit code
exit_code=\$?

# Return the exit code from the calculator
exit \$exit_code
#+end_src

* Makefile

#+begin_src makefile :tangle Makefile :mkdirp yes :comments link
# Makefile for Polish/RPN Notation Calculator

# Variables
SCHEME = scheme
SRC_DIR = src
BIN_DIR = bin
CALC_SCRIPT = \$(SRC_DIR)/polcalc.scm
RUN_SCRIPT = \$(BIN_DIR)/run-calculator.sh

# Main targets
.PHONY: all test install clean help

all: test

# Make scripts executable
executable:
	@chmod +x \$(CALC_SCRIPT)
	@chmod +x \$(RUN_SCRIPT)

# Run tests
test: executable
	@echo "Running tests..."
	@echo "Test 1: Polish notation - Addition"
	@\$(RUN_SCRIPT) "+ 2 3" | grep -q "5" && echo "PASS" || echo "FAIL"
	@echo "Test 2: Polish notation - Nested operations"
	@\$(RUN_SCRIPT) "* + 2 3 4" | grep -q "20" && echo "PASS" || echo "FAIL"
	@echo "Test 3: Polish notation - Division"
	@\$(RUN_SCRIPT) "/ 10 - 6 2" | grep -q "2.5" && echo "PASS" || echo "FAIL"
	@echo "Test 4: RPN notation - Addition"
	@\$(RUN_SCRIPT) --rpn "2 3 +" | grep -q "5" && echo "PASS" || echo "FAIL"
	@echo "Test 5: RPN notation - Nested operations"
	@\$(RUN_SCRIPT) --rpn "2 3 + 4 *" | grep -q "20" && echo "PASS" || echo "FAIL"
	@echo "Test 6: RPN notation - Division"
	@\$(RUN_SCRIPT) --rpn "10 6 2 - /" | grep -q "2.5" && echo "PASS" || echo "FAIL"
	@echo "All tests completed."

# Install to /usr/local/bin (requires sudo)
install: executable
	@echo "Installing calculator..."
	@cp \$(CALC_SCRIPT) /usr/local/bin/polcalc
	@cp \$(RUN_SCRIPT) /usr/local/bin/polcalc-run
	@echo "Installation complete. You can now run 'polcalc-run'"

# Clean up
clean:
	@echo "Cleaning up..."
	@find . -name "*.log" -type f -delete
	@find . -name "*~" -type f -delete
	@echo "Cleanup complete."

# Help
help:
	@echo "Polish/RPN Notation Calculator Makefile"
	@echo "-------------------------------------"
	@echo "Targets:"
	@echo "  all       : Default target, runs tests"
	@echo "  executable: Make scripts executable"
	@echo "  test      : Run test suite"
	@echo "  install   : Install calculator to /usr/local/bin (requires sudo)"
	@echo "  clean     : Remove temporary files"
	@echo "  help      : Display this help message"
#+end_src
\`\`\`
EOF

# Extract org-mode content from the response
echo "Extracting org-mode content from response..."
MODIFIED_ORG_FILE="${TEST_DIR}/modified_calculator.org"

# Extract content between ```org and ``` markers
sed -n '/^```org$/,/^```$/p' "${RESPONSE_FILE}" | sed '1d;$d' > "${MODIFIED_ORG_FILE}"

# If extraction failed, try with backtick format
if [ ! -s "${MODIFIED_ORG_FILE}" ]; then
    echo "Using alternative extraction..."
    sed -n '/```org/,/```/p' "${RESPONSE_FILE}" | sed '1d;$d' > "${MODIFIED_ORG_FILE}"
fi

echo "Extracted modified org file with $(wc -l < "${MODIFIED_ORG_FILE}") lines"

echo ""
echo "===== PART 5: TANGLE MODIFIED ORG FILE ====="

# Create directory for modified tangled files
MOD_TANGLE_DIR="${TEST_DIR}/modified_tangled"
mkdir -p "${MOD_TANGLE_DIR}/src" "${MOD_TANGLE_DIR}/bin"

# Create a modified org file with correct tangle paths
FIXED_MOD_ORG="${TEST_DIR}/fixed-modified-calculator.org"
echo "Creating modified org file with fixed tangle paths..."
sed "s|:tangle src/|:tangle ${MOD_TANGLE_DIR}/src/|g" "${MODIFIED_ORG_FILE}" | \
    sed "s|:tangle bin/|:tangle ${MOD_TANGLE_DIR}/bin/|g" | \
    sed "s|:tangle Makefile|:tangle ${MOD_TANGLE_DIR}/Makefile|g" > "${FIXED_MOD_ORG}"

# Run tangle from the project root to ensure correct paths
cd "${SCRIPT_DIR}"
echo "Tangling modified org file..."
emacs --batch \
  --eval "(require 'org)" \
  --eval "(setq org-confirm-babel-evaluate nil)" \
  --eval "(find-file \"${FIXED_MOD_ORG}\")" \
  --eval "(org-babel-tangle)" \
  --eval "(kill-buffer)"

# Check results
echo "Checking modified tangled files:"
find "${MOD_TANGLE_DIR}" -type f | sort

# Check for expected files and features
if [ -f "${MOD_TANGLE_DIR}/src/polcalc.scm" ]; then
    echo "- Modified src/polcalc.scm: EXISTS"
    
    # Validate RPN features
    if grep -q "RPN" "${MOD_TANGLE_DIR}/src/polcalc.scm"; then
        echo "  - Contains RPN functionality: YES"
        
        # Count key RPN additions
        RPN_FUNCTION_COUNT=$(grep -c "calculate-rpn" "${MOD_TANGLE_DIR}/src/polcalc.scm")
        MODE_PARAM_COUNT=$(grep -c "rpn" "${MOD_TANGLE_DIR}/src/polcalc.scm")
        
        echo "  - RPN function implementation: $RPN_FUNCTION_COUNT"
        echo "  - RPN mode references: $MODE_PARAM_COUNT"
        
        # Verify the calculate-rpn function is complete
        if grep -q "calculate-rpn" "${MOD_TANGLE_DIR}/src/polcalc.scm" && \
           grep -q "evaluate.*rpn" "${MOD_TANGLE_DIR}/src/polcalc.scm"; then
            echo "  - Complete RPN implementation: YES"
        else
            echo "  - Complete RPN implementation: NO (missing key components)"
        fi
    else
        echo "  - Contains RPN functionality: NO"
    fi
else
    echo "- Modified src/polcalc.scm: MISSING"
fi

if [ -f "${MOD_TANGLE_DIR}/bin/run-calculator.sh" ]; then
    echo "- Modified bin/run-calculator.sh: EXISTS"
    
    # Check if shell script has been updated for RPN
    if grep -q "\-\-rpn" "${MOD_TANGLE_DIR}/bin/run-calculator.sh"; then
        echo "  - Shell script updated for RPN: YES"
    else
        echo "  - Shell script updated for RPN: NO"
    fi
else
    echo "- Modified bin/run-calculator.sh: MISSING"
fi

if [ -f "${MOD_TANGLE_DIR}/Makefile" ]; then
    echo "- Modified Makefile: EXISTS"
    
    # Check if Makefile has been updated with RPN tests
    if grep -q "RPN" "${MOD_TANGLE_DIR}/Makefile"; then
        echo "  - Makefile updated with RPN tests: YES"
    else
        echo "  - Makefile updated with RPN tests: NO"
    fi
else
    echo "- Modified Makefile: MISSING"
fi

# Count successfully modified files
MOD_TANGLED_COUNT=$(find "${MOD_TANGLE_DIR}" -type f | wc -l | tr -d ' ')
echo "Successfully tangled $MOD_TANGLED_COUNT modified files."

echo ""
echo "===== SUMMARY ====="
echo "Test directory: ${TEST_DIR}"
echo ""
echo "Files converted to org: ${FILES[*]}"
echo "Original org file: ${ORG_FILE}"
echo "Fixed org file with proper paths: ${FIXED_ORG}"
echo "Tangled files: ${TANGLE_DIR}"
echo ""
echo "Ollama prompt: ${PROMPT_FILE}"
echo "Ollama response: ${RESPONSE_FILE}"
echo "Modified org file: ${MODIFIED_ORG_FILE}"
echo "Fixed modified org file: ${FIXED_MOD_ORG}"
echo "Modified tangled files: ${MOD_TANGLE_DIR}"
echo ""
echo "All files preserved in: ${TEST_DIR}"
echo ""
echo "To execute the full flow with real Ollama:"
echo "cat \"${PROMPT_FILE}\" | ollama run llama3.2 > response.md"
echo "===== END OF TEST ====="