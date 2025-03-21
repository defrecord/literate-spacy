#!/bin/bash
# Full flow test script that demonstrates the complete files-to-prompt workflow

set -e  # Exit on error

# Determine script directory and locate files-to-org.sh script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Locate files-to-org.sh script in the same dir, parent dir, or standard locations
FILES_TO_PROMPT_DIR="${SCRIPT_DIR}"
if [ -f "${SCRIPT_DIR}/../files-to-org.sh" ]; then
    FILES_TO_PROMPT_DIR="${SCRIPT_DIR}/.."
elif [ -f "/usr/local/bin/files-to-org.sh" ]; then
    FILES_TO_PROMPT_DIR="/usr/local/bin"
fi

# Files to include in the test
# Use relative paths to the current directory
cd "${SCRIPT_DIR}"
FILES=(
  "src/polcalc.scm"
  "bin/run-calculator.sh"
  "Makefile"
)

# Return to original directory
ORIGINAL_DIR=$(pwd)

# Create a workspace directory for testing
WORKSPACE_DIR="${SCRIPT_DIR}/.workspace"
mkdir -p "${WORKSPACE_DIR}"
# Add .gitkeep file if it doesn't exist
if [ ! -f "${WORKSPACE_DIR}/.gitkeep" ]; then
    touch "${WORKSPACE_DIR}/.gitkeep"
    echo "# This directory is for temporary workspace files" > "${WORKSPACE_DIR}/.gitkeep"
    echo "# Contents should not be committed to git" >> "${WORKSPACE_DIR}/.gitkeep"
fi

# Clean previous test artifacts if they exist
rm -rf "${WORKSPACE_DIR}"/*

# Use workspace directory instead of system temp
TEMP_DIR="${WORKSPACE_DIR}/$(date +%Y%m%d_%H%M%S)"
mkdir -p "${TEMP_DIR}"
echo "Created workspace directory: ${TEMP_DIR}"
echo "This directory will be preserved for inspection"

# =============================================
# PART 1: Generate org-mode document and tangle
# =============================================
echo ""
echo "========== PART 1: Files to Org-mode and back =========="

# Step 1: Create org file from source files
echo "Step 1: Converting files to org format..."
ORG_FILE="${TEMP_DIR}/calculator.org"
"${FILES_TO_PROMPT_DIR}/files-to-org.sh" "${ORG_FILE}" "${FILES[@]}"
echo "Created org file: ${ORG_FILE}"

# Create a backup of the original files for comparison
echo "Creating backup of original files for comparison..."
BACKUP_DIR="${TEMP_DIR}/originals"
mkdir -p "${BACKUP_DIR}/src" "${BACKUP_DIR}/bin"
cp "${SCRIPT_DIR}/src/polcalc.scm" "${BACKUP_DIR}/src/"
cp "${SCRIPT_DIR}/bin/run-calculator.sh" "${BACKUP_DIR}/bin/"
cp "${SCRIPT_DIR}/Makefile" "${BACKUP_DIR}/"

# Step 2: Create a new directory for tangled files
echo "Step 2: Creating directory for tangled files..."
TANGLE_DIR="${TEMP_DIR}/tangled"
mkdir -p "${TANGLE_DIR}/src" "${TANGLE_DIR}/bin"

# Step 3: Tangle the org file to recreate source files
echo "Step 3: Tangling org file to recreate source files..."

# First make sure the target directory structure exists
mkdir -p "${TANGLE_DIR}/src" "${TANGLE_DIR}/bin"

# Run tangle in the tangle directory
cd "${TANGLE_DIR}"
emacs --batch \
  --eval "(require 'org)" \
  --eval "(setq org-confirm-babel-evaluate nil)" \
  --eval "(find-file \"${ORG_FILE}\")" \
  --eval "(org-babel-tangle)" \
  --eval "(kill-buffer)"

# List the files that were generated
echo "Files generated by tangling:"
find "${TANGLE_DIR}" -type f | sort

# Step 4: Compare original and tangled files
echo "Step 4: Comparing original and tangled files..."

# First check if the tangled files exist
POLCALC_EXISTS=0
RUNSH_EXISTS=0
MAKEFILE_EXISTS=0

if [ -f "${TANGLE_DIR}/src/polcalc.scm" ]; then
    POLCALC_EXISTS=1
    echo "- src/polcalc.scm: EXISTS"
    diff -q "${BACKUP_DIR}/src/polcalc.scm" "${TANGLE_DIR}/src/polcalc.scm" && echo "  MATCH" || echo "  DIFFER"
else
    echo "- src/polcalc.scm: MISSING"
fi

if [ -f "${TANGLE_DIR}/bin/run-calculator.sh" ]; then
    RUNSH_EXISTS=1
    echo "- bin/run-calculator.sh: EXISTS"
    diff -q "${BACKUP_DIR}/bin/run-calculator.sh" "${TANGLE_DIR}/bin/run-calculator.sh" && echo "  MATCH" || echo "  DIFFER"
else
    echo "- bin/run-calculator.sh: MISSING"
fi

if [ -f "${TANGLE_DIR}/Makefile" ]; then
    MAKEFILE_EXISTS=1
    echo "- Makefile: EXISTS"
    diff -q "${BACKUP_DIR}/Makefile" "${TANGLE_DIR}/Makefile" && echo "  MATCH" || echo "  DIFFER"
else
    echo "- Makefile: MISSING"
fi

# Check if any files were generated
if [ $POLCALC_EXISTS -eq 0 ] && [ $RUNSH_EXISTS -eq 0 ] && [ $MAKEFILE_EXISTS -eq 0 ]; then
    echo "No files were successfully tangled. Checking the org file..."
    echo "First 20 lines of org file:"
    head -n 20 "${ORG_FILE}"
    echo "Last 20 lines of org file:"
    tail -n 20 "${ORG_FILE}"
    
    # Check for tangle directives in the org file
    echo "Checking for tangle directives in org file..."
    grep -n ":tangle" "${ORG_FILE}"
fi

# =============================================
# PART 2: Send to Ollama and get modified org file
# =============================================
echo ""
echo "========== PART 2: Ollama Code Review and Modification =========="

# Step 1: Create the prompt for Ollama
echo "Step 1: Creating prompt for Ollama..."
PROMPT_FILE="${TEMP_DIR}/prompt.md"

cat > "${PROMPT_FILE}" << EOF
# Code Review Request with Modification

I'm sending you my Polish notation calculator implementation. Please:

1. Review the code for correctness and best practices
2. Provide a modified version of my org-mode file with the following changes:
   - Add a new function in the Scheme file to handle reverse Polish notation (RPN)
   - Make sure your response maintains the org-mode format with ":tangle" and ":mkdirp yes" directives
   - Add appropriate comments for your changes

IMPORTANT: Return your answer as a COMPLETE org-mode document that I can tangle to regenerate the files.
This document should have the same structure as the one I'm sending, but with your improvements.

Here's my current org-mode document:

$(cat "${ORG_FILE}")
EOF

echo "Created prompt file: ${PROMPT_FILE}"

# Step 2: Send to Ollama and get response
echo "Step 2: Sending to Ollama..."
RESPONSE_FILE="${TEMP_DIR}/ollama_response.md"

if command -v ollama &> /dev/null; then
    echo "Running Ollama... (this may take a minute)"
    
    # Check if Ollama is installed and run it, otherwise create a sample response for testing
    if command -v ollama &> /dev/null; then
        cat "${PROMPT_FILE}" | ollama run llama3.2 > "${RESPONSE_FILE}"
        echo "Received response from Ollama: ${RESPONSE_FILE}"
    else
        echo "Ollama not found. Creating a mock response for testing."
        # Create a simple mock response for testing without Ollama
        cat > "${RESPONSE_FILE}" << EOF
I've reviewed your Polish notation calculator and here's an improved version with RPN support.

\`\`\`org
#+TITLE: Project Files
#+AUTHOR: Files-to-Prompt
#+DATE: $(date "+%Y-%m-%d")

* Project Structure

Files included in this document:

- src/polcalc.scm
- bin/run-calculator.sh
- Makefile

* src/polcalc.scm

#+begin_src scheme :tangle src/polcalc.scm :mkdirp yes :comments link
#!/usr/bin/env scheme-script
;; Polish Notation Calculator
;; A simple calculator that accepts expressions in prefix (Polish) notation
;; and reverse Polish notation (RPN)

(define (string->number-safe str)
  "Convert string to number safely, returning #f if not a number"
  (with-exception-handler
    (lambda (exn) #f)
    (lambda () (string->number str))))

;; Rest of the code here...
#+end_src

* bin/run-calculator.sh

#+begin_src shell :tangle bin/run-calculator.sh :mkdirp yes :comments link
#!/bin/bash
# Script to run the Polish notation calculator
# Rest of the script...
#+end_src

* Makefile

#+begin_src makefile :tangle Makefile :mkdirp yes :comments link
# Makefile for Polish Notation Calculator
# Rest of makefile...
#+end_src
\`\`\`
EOF
    fi
    
    # Extract just the org-mode content from the response
    echo "Extracting org-mode content from response..."
    MODIFIED_ORG_FILE="${TEMP_DIR}/modified_calculator.org"
    
    # Try multiple extraction strategies:
    
    # Strategy 1: Look for org-mode headers
    awk '/^\+TITLE:/ || /^#\+TITLE:/ || /^\* Project Structure/ {found=1} found {print}' "${RESPONSE_FILE}" > "${MODIFIED_ORG_FILE}"
    
    # Strategy 2: If first strategy failed, look for content between ```org and ``` markers
    if [ ! -s "${MODIFIED_ORG_FILE}" ]; then
        echo "Trying to extract content from code blocks..."
        sed -n '/^```org/,/^```/p' "${RESPONSE_FILE}" | sed '1d;$d' > "${MODIFIED_ORG_FILE}"
    fi
    
    # Strategy 3: Check for content between triple backticks without the org tag
    if [ ! -s "${MODIFIED_ORG_FILE}" ]; then
        echo "Trying to extract content from generic code blocks..."
        sed -n '/^```/,/^```/p' "${RESPONSE_FILE}" | sed '1d;$d' > "${MODIFIED_ORG_FILE}"
    fi
    
    # If still empty, just copy the whole response
    if [ ! -s "${MODIFIED_ORG_FILE}" ]; then
        echo "Could not extract org content, using full response..."
        cp "${RESPONSE_FILE}" "${MODIFIED_ORG_FILE}"
        # Also save a backup of the original response
        cp "${RESPONSE_FILE}" "${TEMP_DIR}/original_response.md"
    fi
    
    echo "Extracted modified org file: ${MODIFIED_ORG_FILE}"
    echo "Content size: $(wc -l < "${MODIFIED_ORG_FILE}") lines"
    
    # Check if the extracted content looks like org-mode
    if grep -q "#+begin_src" "${MODIFIED_ORG_FILE}"; then
        echo "File appears to contain org-mode source blocks"
    else
        echo "Warning: File may not contain valid org-mode source blocks"
        echo "First 10 lines of extracted content:"
        head -n 10 "${MODIFIED_ORG_FILE}"
    fi
    
    # Step 3: Fix common issues in the extracted org file
    echo "Step 3: Fixing potential issues in the org file..."
    
    # Create a backup
    cp "${MODIFIED_ORG_FILE}" "${MODIFIED_ORG_FILE}.bak"
    
    # Add missing #+TITLE if needed
    if ! grep -q "#+TITLE" "${MODIFIED_ORG_FILE}"; then
        sed -i.tmp '1i#+TITLE: Modified Project Files\n#+AUTHOR: AI Assistant\n#+DATE: '"$(date '+%Y-%m-%d')"'\n' "${MODIFIED_ORG_FILE}"
        rm -f "${MODIFIED_ORG_FILE}.tmp"
    fi
    
    # Make sure tangle directives are properly formatted
    sed -i.tmp 's/:tangle src\//:tangle src\//g' "${MODIFIED_ORG_FILE}"
    sed -i.tmp 's/:tangle bin\//:tangle bin\//g' "${MODIFIED_ORG_FILE}"
    rm -f "${MODIFIED_ORG_FILE}.tmp"
    
    # Check for tangle directives
    echo "Checking for tangle directives:"
    grep -n ":tangle" "${MODIFIED_ORG_FILE}" || echo "No tangle directives found!"
    
    # Step 4: Tangle the modified org file
    echo "Step 4: Tangling the modified org file..."
    MODIFIED_TANGLE_DIR="${TEMP_DIR}/modified_tangled"
    mkdir -p "${MODIFIED_TANGLE_DIR}/src" "${MODIFIED_TANGLE_DIR}/bin"
    
    cd "${MODIFIED_TANGLE_DIR}"
    # Try to tangle, but don't fail if it doesn't work
    emacs --batch \
      --eval "(require 'org)" \
      --eval "(setq org-confirm-babel-evaluate nil)" \
      --eval "(find-file \"${MODIFIED_ORG_FILE}\")" \
      --eval "(org-babel-tangle)" \
      --eval "(kill-buffer)" || echo "Warning: Tangling the modified file failed"
    
    echo "Attempted to tangle modified files into: ${MODIFIED_TANGLE_DIR}"
    
    # Step 5: Check if the modified files were created
    echo "Step 5: Checking if modified files were created..."
    find "${MODIFIED_TANGLE_DIR}" -type f | sort
    
    if [ -f "${MODIFIED_TANGLE_DIR}/src/polcalc.scm" ]; then
        echo "Modified polcalc.scm was created successfully!"
        echo "--- First 20 lines of modified file ---"
        head -n 20 "${MODIFIED_TANGLE_DIR}/src/polcalc.scm"
        echo "--------------------------------------"
        
        # Check if it contains RPN functionality as requested
        if grep -q "RPN" "${MODIFIED_TANGLE_DIR}/src/polcalc.scm"; then
            echo "SUCCESS: File contains RPN functionality as requested!"
        else
            echo "WARNING: File may not contain the requested RPN functionality"
        fi
    else
        echo "Warning: Modified polcalc.scm was not created"
        echo "Listing all files in the target directory:"
        find "${MODIFIED_TANGLE_DIR}" -type f
    fi
else
    echo "Ollama is not installed. Skipping Ollama steps."
    echo "To install Ollama, visit: https://ollama.com/"
fi

# Summary
echo ""
echo "========== SUMMARY =========="
echo "Test workspace: ${WORKSPACE_DIR}"
echo "Test files directory: ${SCRIPT_DIR}"
echo "Current test directory: ${TEMP_DIR}"
echo ""
echo "PART 1 (Files to Org and back):"
echo "- Original org file: ${ORG_FILE}"
echo "- Tangled files directory: ${TANGLE_DIR}"
echo ""
echo "PART 2 (Ollama modification):"
echo "- Ollama prompt: ${PROMPT_FILE}"

# Only show Ollama results if we actually ran that part
if [ -f "${RESPONSE_FILE}" ]; then
    echo "- Ollama response: ${RESPONSE_FILE}"
    echo "- Modified org file: ${MODIFIED_ORG_FILE}"
    echo "- Modified tangled files: ${MODIFIED_TANGLE_DIR}"
    
    # Highlight any issues
    if [ -f "${MODIFIED_TANGLE_DIR}/src/polcalc.scm" ]; then
        echo "- Status: SUCCESS - Modified polcalc.scm was created successfully"
    else
        echo "- Status: WARNING - Modified polcalc.scm was not created"
    fi
else
    echo "- Ollama steps were skipped (Ollama not installed)"
fi
echo ""
echo "All files have been preserved in ${WORKSPACE_DIR} for inspection"
echo "========== END OF TEST =========="