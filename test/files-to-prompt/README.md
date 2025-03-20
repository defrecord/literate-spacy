# Files-to-Prompt with Org Mode

This directory demonstrates a simple approach to use org-mode for files-to-prompt workflows. It allows you to:

1. Convert multiple source files into a single org-mode document
2. Generate files back from the org-mode document
3. Use the org-mode document for AI prompts with code context

## Contents

- `files-to-org.sh`: Shell script to convert files to an org-mode document
- `Makefile`: Provides commands for the conversion workflow
- Sample files:
  - `scripts/python/example.py`: Example Python script
  - `scripts/shell/example.sh`: Example shell script
  - `config/.gitignore`: Example configuration file
- Prompt files:
  - `system_prompt.md`: Example system prompt for code review
  - `message_prompt.md`: Example message prompt requesting specific review

## Usage

### Convert Files to Org-Mode

```bash
make files-to-org
```

This creates `project.org` containing all the specified source files as org-mode source blocks.

### Convert Org-Mode Back to Files

```bash
make org-to-files
```

This tangles the org-mode file back to the original source files.

### Clean Up

```bash
make clean
```

Removes the generated org file.

### Complete Example Workflow

Here's a complete example of how to use this for AI prompting:

1. Generate an org file from your source code:
   ```bash
   ./files-to-org.sh my_project.org src/main.py src/utils.py tests/test_main.py
   ```

2. Make edits to the org file content (optional)
   - You can edit the file to focus on specific parts
   - Add explanatory notes between code blocks
   - Highlight areas of interest

3. Create your prompt file with org content:
   ```bash
   cat system_prompt.md my_project.org message_prompt.md > prompt.md
   ```

4. Send the combined prompt to your AI assistant:
   ```bash
   claude prompt.md
   ```

5. Apply changes back to source files (if you received code modifications):
   - Copy modified code blocks back to your org file
   - Run `make org-to-files` to tangle the updates back to source files

## How It Works

1. The `files-to-org.sh` script:
   - Takes an output filename and a list of input files
   - Creates an org-mode document with proper headers
   - For each file, creates a source block with:
     - Appropriate language detection
     - `:tangle` directive pointing to the original path
     - `:mkdirp yes` to ensure directories are created
     - `:comments link` to support bidirectional editing

2. The org-mode file can be used directly for prompting, or edited and then tangled back to source files.

3. The workflow preserves directory structure, file paths, and language-specific syntax highlighting.

## Advanced Example: Ollama Code Review

The `calculator/` directory contains a complete example of using files-to-prompt with Ollama:

```bash
cd calculator
./code-review.sh
```

This example:
1. Converts a Scheme calculator, shell script wrapper, and Makefile to org format
2. Combines them with code review prompts
3. Pipes the resulting file to Ollama's llama3.2 model for a code review

This demonstrates a complete end-to-end workflow for using files-to-prompt with AI tools.