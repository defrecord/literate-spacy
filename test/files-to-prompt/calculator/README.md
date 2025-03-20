# Polish Notation Calculator Test

This directory contains a test case for the files-to-prompt feature, using a Polish notation calculator implemented in Scheme. It demonstrates a complete bidirectional workflow for code review and enhancement using org-mode as an intermediate format.

## Summary of Features

This calculator example demonstrates:

1. Bidirectional synchronization between source files and org-mode documents
2. Generation of prompts for AI code review via Ollama
3. Processing of AI responses to extract and tangle changes back to source files
4. Comprehensive testing of the complete workflow
5. Portability to enable easy use in new repositories

## Components

### Core Files
- `src/polcalc.scm`: The Scheme implementation of a Polish notation calculator
- `bin/run-calculator.sh`: Shell script wrapper to run the calculator
- `Makefile`: Build and test automation

### Prompt Files
- `system_prompt.md`: System prompt template for code review
- `message_prompt.md`: User message template for code review

### Workflow Scripts
- `files-to-org.sh`: Creates org-mode files from source files (copied locally for portability)
- `code-review.sh`: Script to generate an org file and pipe to Ollama
- `test-flow.sh`: Script to test the complete bidirectional workflow
- `test-review.sh`: Script to test prompt creation without running Ollama
- `full-flow-test.sh`: Comprehensive test script with detailed verification

## Running the Code Review

To run the code review with Ollama:

```bash
./code-review.sh
```

This script will:
1. Convert the calculator files to an org-mode document
2. Combine it with the system and user prompts
3. Pipe the complete prompt to Ollama's llama3.2 model

## Tangle/Detangle Workflow

The central feature of this example is demonstrating the bidirectional synchronization (tangle/detangle) between source files and org-mode documents:

1. **Files → Org** (Detangle): The `files-to-org.sh` script converts source files to a structured org-mode document
2. **Org → Files** (Tangle): The org-mode document can be tangled to regenerate the original source files
3. **Modified Org → Modified Files**: Changes to the org-mode document (such as adding RPN support) flow back to source files

For a complete test of this bidirectional workflow:

```bash
./test-flow.sh
```

This script demonstrates the entire workflow:
1. Converting source files to org-mode
2. Tangling org-mode back to source files (bidirectional sync)
3. Creating a prompt for Ollama with the org content
4. Simulating an Ollama response with enhanced functionality (RPN support)
5. Tangling the modified org file to create updated source files
6. Verifying the enhancements were properly implemented

All files are preserved in a timestamped `.workspace` directory for inspection.

## Testing the Calculator

If you want to try the calculator directly:

```bash
# Make scripts executable
chmod +x src/polcalc.scm bin/run-calculator.sh

# Run a simple calculation
./bin/run-calculator.sh "+ 2 3"      # Results in 5

# Run a more complex calculation
./bin/run-calculator.sh "/ 10 - 6 2" # Results in 2.5

# Get help
./bin/run-calculator.sh --help
```

## Running the Tests

The Makefile includes various test targets:

```bash
# Run basic calculator tests
make test

# Run flow test to verify org tangling
make test-flow

# Run review test to verify prompt creation
make test-review

# Run all tests
make full-test
```

The test targets verify different aspects of the system:

- `test`: Runs basic calculator functionality tests
- `test-flow`: Tests the bidirectional workflow (files → org → files → Ollama → modified org → modified files)
- `test-review`: Tests prompt creation for code review without running Ollama
- `full-test`: Runs all tests in sequence

## Cleaning Up

To clean up test artifacts:

```bash
make clean
```

This removes log files and workspace test directories.

## Portability and New Repository Usage

The calculator example is designed to be portable and easy to use in a new repository. The key files are:

1. `files-to-org.sh`: The core script that converts source files to org-mode format
2. Source files: `src/polcalc.scm`, `bin/run-calculator.sh`, `Makefile`
3. Prompt templates: `system_prompt.md`, `message_prompt.md`
4. Workflow scripts: `code-review.sh`, `test-flow.sh`, `test-review.sh`

To use in a new repository:

1. Copy all files to the new location
2. Run `files-to-org.sh` to create an org-mode document from your source files
3. Use the test scripts to verify the bidirectional workflow

All scripts have been updated to automatically locate the `files-to-org.sh` script in the same directory, parent directory, or standard locations, so they work without modification in a new repository structure.

## Recent Updates

Recent improvements to this example include:

1. Added proper integration of test scripts into the Makefile with `test-flow`, `test-review`, and `full-test` targets
2. Improved portability by updating scripts to use relative paths and find dependencies locally
3. Updated Scheme implementation to work with Guile by default
4. Ensured proper bidirectional synchronization with `:comments link` directive
5. Added comprehensive documentation about the workflow and testing
6. Created a workspace directory structure for test artifacts with proper .gitignore rules