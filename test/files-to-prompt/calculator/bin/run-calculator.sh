# [[file:../.workspace/20250320_171642/calculator.org::*/Users/jasonwalsh/projects/defrecord/literate-spacy/test/files-to-prompt/calculator/bin/run-calculator.sh][/Users/jasonwalsh/projects/defrecord/literate-spacy/test/files-to-prompt/calculator/bin/run-calculator.sh:1]]
# [[file:../../../../../../../../../var/folders/9z/9bvmr7bs731_0ps9m4yhb3380000gn/T/tmp.zVm7sfJiQh/calculator.org::*/Users/jasonwalsh/projects/defrecord/literate-spacy/test/files-to-prompt/calculator/bin/run-calculator.sh][/Users/jasonwalsh/projects/defrecord/literate-spacy/test/files-to-prompt/calculator/bin/run-calculator.sh:1]]
#!/bin/bash
# Script to run the Polish notation calculator

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
CALC_PATH="$SCRIPT_DIR/../src/polcalc.scm"

# Check if Scheme is installed
if ! command -v scheme >/dev/null 2>&1; then
    echo "Error: Scheme interpreter not found. Please install a Scheme implementation."
    echo "Suggestion: Install Chez Scheme with 'brew install chezscheme' or similar."
    exit 1
fi

# Make sure calculator script is executable
if [ ! -x "$CALC_PATH" ]; then
    chmod +x "$CALC_PATH"
fi

# Function to print help
print_help() {
    echo "Polish Notation Calculator"
    echo "-------------------------"
    echo "Usage: $(basename "$0") EXPRESSION"
    echo ""
    echo "Examples:"
    echo "  $(basename "$0") '+ 2 3'         # Addition: 5"
    echo "  $(basename "$0") '* + 2 3 4'     # (2 + 3) * 4 = 20"
    echo "  $(basename "$0") '/ 10 - 6 2'    # 10 / (6 - 2) = 2.5"
    echo ""
    echo "Operators: +, -, *, /"
    echo "Note: All expressions must use prefix (Polish) notation."
    exit 0
}

# Check for help flag
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    print_help
fi

# Check if an expression was provided
if [ $# -eq 0 ]; then
    echo "Error: No expression provided."
    echo "Try '$(basename "$0") --help' for more information."
    exit 1
fi

# Combine all arguments into a single expression
EXPRESSION="$*"

# Run the calculator
"$CALC_PATH" "$EXPRESSION"
exit_code=$?

# Return the exit code from the calculator
exit $exit_code
# /Users/jasonwalsh/projects/defrecord/literate-spacy/test/files-to-prompt/calculator/bin/run-calculator.sh:1 ends here
# /Users/jasonwalsh/projects/defrecord/literate-spacy/test/files-to-prompt/calculator/bin/run-calculator.sh:1 ends here
