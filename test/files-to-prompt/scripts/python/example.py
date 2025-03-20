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
