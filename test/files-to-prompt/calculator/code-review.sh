#!/bin/bash
# Code review script that uses files-to-org to create a prompt for Ollama

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

# Files to include in the review
FILES=(
  "${SCRIPT_DIR}/src/polcalc.scm"
  "${SCRIPT_DIR}/bin/run-calculator.sh"
  "${SCRIPT_DIR}/Makefile"
)

# Create a temporary directory
TEMP_DIR=$(mktemp -d)
trap 'rm -rf ${TEMP_DIR}' EXIT  # Clean up temp dir on exit

# Create org file from the calculator files
echo "Converting files to org format..."
"${FILES_TO_PROMPT_DIR}/files-to-org.sh" "${TEMP_DIR}/calculator.org" "${FILES[@]}"

# Create combined prompt file
echo "Creating combined prompt file..."
cat "${SCRIPT_DIR}/system_prompt.md" "${TEMP_DIR}/calculator.org" "${SCRIPT_DIR}/message_prompt.md" > "${TEMP_DIR}/prompt.md"

# Check if Ollama is installed
if ! command -v ollama &> /dev/null; then
    echo "Error: Ollama is not installed or not in PATH."
    echo "Please install Ollama: https://ollama.com/"
    exit 1
fi

# Display command that will run
echo "Running code review with Ollama..."
echo "Command: cat ${TEMP_DIR}/prompt.md | ollama run llama3.2"
echo ""
echo "================ EXECUTING OLLAMA REVIEW ================"
echo ""

# Check if Ollama is actually installed before trying to run it
if command -v ollama &> /dev/null; then
    # Run the review
    cat "${TEMP_DIR}/prompt.md" | ollama run llama3.2
else
    echo "WARNING: Ollama not found. Would execute the command if installed."
    echo "To install Ollama, visit: https://ollama.com/"
    # Save the prompt so it can be reviewed
    cp "${TEMP_DIR}/prompt.md" "${SCRIPT_DIR}/last_prompt.md"
    echo "Saved prompt to: ${SCRIPT_DIR}/last_prompt.md"
fi
echo ""
echo "================ REVIEW COMPLETE ================"

# Provide instructions for manual review if needed
echo ""
echo "The prompt file is available at: ${TEMP_DIR}/prompt.md"
echo "To run the review manually, use:"
echo "cat ${TEMP_DIR}/prompt.md | ollama run llama3.2"
echo ""
echo "Don't forget: the temp directory will be deleted when this script exits."