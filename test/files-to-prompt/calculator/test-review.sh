#!/bin/bash
# Test script for code-review.sh that shows the prompt without running Ollama

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

# Display summary of the prompt
echo "---------------------------------"
echo "PROMPT SUMMARY"
echo "---------------------------------"
echo "System prompt:"
head -n 5 "${SCRIPT_DIR}/system_prompt.md"
echo "..."
echo ""

echo "Files included in org format:"
for file in "${FILES[@]}"; do
  echo "- $(basename "$file")"
done
echo ""

echo "User message:"
cat "${SCRIPT_DIR}/message_prompt.md"
echo ""

echo "---------------------------------"
echo "The complete prompt has been saved to: ${TEMP_DIR}/prompt.md"
echo "This file would be piped to Ollama in a real run."
echo "---------------------------------"

# Display the command that would run in a real scenario
echo "In a real run, the following command would execute:"
echo "cat ${TEMP_DIR}/prompt.md | ollama run llama3.2"