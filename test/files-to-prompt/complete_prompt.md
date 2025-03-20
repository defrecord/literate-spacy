# Code Review System Prompt

You are an expert code reviewer with deep knowledge of software development best practices, software architecture, and code quality. Your task is to review the provided code files and provide constructive feedback.

## Personas Available for Review

### Security Specialist
- Focus on identifying security vulnerabilities
- Check for proper input validation
- Look for potential injection attacks
- Ensure secure handling of sensitive data

### Performance Expert
- Identify potential performance bottlenecks
- Look for inefficient algorithms
- Review resource usage and optimization
- Suggest performance improvements

### Maintainability Advocate
- Evaluate code readability and organization
- Check for proper documentation
- Review for consistent coding style
- Suggest improvements for long-term maintenance

## Review Guidelines

1. First understand the code's purpose and structure
2. Identify strengths and positive aspects of the code
3. Highlight areas for improvement with specific suggestions
4. Prioritize issues by severity and impact
5. Provide code examples for suggested improvements
6. Be constructive and respectful in all feedback

## Output Format

Structure your review in the following format:

1. **Summary**: Brief overview of the code and key findings
2. **Strengths**: What's working well
3. **Areas for Improvement**: Specific issues with suggestions
4. **Code Examples**: Example fixes for key issues
5. **Overall Assessment**: Final evaluation and next steps#+TITLE: Project Files
#+AUTHOR: Files-to-Prompt
#+DATE: 2025-03-20

* Project Structure

Files included in this document:

- scripts/python/example.py
- scripts/shell/example.sh
- config/.gitignore

* scripts/python/example.py
This is the main Python file for the project. Note the newly added capabilities in the analyze_text function.
#+begin_src python :tangle scripts/python/example.py :mkdirp yes :comments link
# [[file:../../project.org::*scripts/python/example.py][scripts/python/example.py:1]]
# [[file:../../project.org::*scripts/python/example.py][scripts/python/example.py:1]]
#!/usr/bin/env python3
"""
Example Python file for files-to-prompt test.
"""

def greet(name="World"):
    """Greet someone with a friendly message."""
    return f"Hello, {name}!"

def analyze_text(text):
    """Perform simple text analysis.
    
    Args:
        text: String to analyze
        
    Returns:
        Dictionary with word count, character count, and additional metrics
    """
    return {
        "word_count": len(text.split()),
        "char_count": len(text),
        "has_numbers": any(c.isdigit() for c in text),
        "has_uppercase": any(c.isupper() for c in text),
        "avg_word_length": sum(len(word) for word in text.split()) / len(text.split()) if text.split() else 0
    }

if __name__ == "__main__":
    print(greet("Files-to-Prompt"))
    result = analyze_text("Converting files to org-mode is useful for prompts!")
    print(f"Analysis: {result}")
# scripts/python/example.py:1 ends here
# scripts/python/example.py:1 ends here
#+end_src

* scripts/shell/example.sh

#+begin_src shell :tangle scripts/shell/example.sh :mkdirp yes :comments link
# [[file:../../project.org::*scripts/shell/example.sh][scripts/shell/example.sh:1]]
# [[file:../../project.org::*scripts/shell/example.sh][scripts/shell/example.sh:1]]
#!/bin/bash
# Example shell script for files-to-prompt test

# Print a greeting
echo "Converting files to org-mode format..."

# Function to convert files
convert_files() {
    local input_dir=$1
    local output_file=$2
    
    echo "Processing files in $input_dir"
    echo "Output will be written to $output_file"
    
    # Loop through files
    for file in "$input_dir"/*; do
        if [ -f "$file" ]; then
            echo "- Processing $file"
            # Process the file here
        fi
    done
    
    echo "Conversion complete!"
}

# Main execution
if [ $# -lt 2 ]; then
    echo "Usage: $0 <input_directory> <output_file>"
    exit 1
fi

convert_files "$1" "$2"
exit 0
# scripts/shell/example.sh:1 ends here
# scripts/shell/example.sh:1 ends here
#+end_src

* config/.gitignore

#+begin_src text :tangle config/.gitignore :mkdirp yes :comments no
# Generated org files
*.org

# Python artifacts
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
*.egg-info/
.installed.cfg
*.egg

# Editor files
.vscode/
.idea/
*.swp
*~

# OS specific files
.DS_Store
Thumbs.db
#+end_src
# Code Review Request

Please review the code in these files using the **Maintainability Advocate** persona. I'm particularly concerned about:

1. The organization of the code
2. Quality of documentation
3. Consistent style across files
4. Potential improvements for long-term maintenance

I would appreciate specific examples of how I could improve the code to make it more maintainable.

Thank you!