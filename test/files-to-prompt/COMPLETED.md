# Files-to-Prompt Feature Implementation

## Summary
This directory contains a complete implementation of the files-to-prompt feature for the literate-spacy project. The implementation enables a bidirectional workflow between source files and org-mode files, which can be used for AI prompting.

## What's Been Implemented

1. A shell script (`files-to-org.sh`) that converts multiple source files into a single org-mode document with:
   - Proper file hierarchical organization
   - Language-specific syntax highlighting
   - Bidirectional linking with `:comments link` for code that supports comments
   - Fallback to `:comments no` for file types that don't support comments

2. A Makefile with targets for:
   - `files-to-org`: Converting files to an org document
   - `org-to-files`: Tangling the org document back to source files
   - `clean`: Cleaning up generated files

3. A demo workflow script (`demo-workflow.sh`) that demonstrates:
   - Converting files to org format
   - Adding notes to the org file
   - Creating a complete prompt by combining system prompt, code content, and user prompt
   - Instructions for sending to Claude and applying changes back

4. Example files for testing:
   - Python script with documentation and functions
   - Shell script with error handling and command-line argument processing
   - Configuration file (.gitignore) as an example of a non-code file

5. Sample prompt templates:
   - System prompt with different reviewer personas
   - User message prompt requesting specific review focus

## How to Use

See the README.md for detailed usage instructions and workflow examples.

## Resolved Issues

- Fixed emacs tangling issue with text files by handling `:comments` directive differently based on file type
- Ensured bidirectional editing works by properly setting up the tangle/detangle process
- Added proper directory handling with the `:mkdirp yes` directive

## Conclusion

This implementation successfully addresses GitHub issue #9 by providing a complete files-to-prompt solution based on org-mode. The feature enables users to:

1. Convert any collection of source files to an org document
2. Edit and annotate the org document for AI prompting
3. Apply changes back to the original source files

The solution is simple, using shell scripts rather than Python, making it easier to maintain and extend.