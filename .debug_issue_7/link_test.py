#!/usr/bin/env python3
"""
Test file with explicit link.
"""
# Local Variables:
# eval: (setq-local org-src-preserve-indentation t)
# org-babel-tangle: "link_test.py"
# End:

def multiply(a, b):
    """Multiply two numbers and return the result."""
    product = a * b
    return product

def divide(a, b):
    """Divide a by b."""
    if b == 0:
        raise ValueError("Cannot divide by zero")
    return a / b

if __name__ == "__main__":
    print(f"5 * 3 = {multiply(5, 3)}")
    print(f"10 / 2 = {divide(10, 2)}")
