# [[file:solution_test.org::*Simple Test][Simple Test:1]]
#!/usr/bin/env python
"""
Solution test file for proper detangling.
"""

def hello():
    """Say hello."""
    print("Hello, world!")
    return "Hello, world!"

def add(a, b):
    """Add two numbers and return the result."""
    result = a + b
    return result

if __name__ == "__main__":
    hello()
    print(f"1 + 2 = {add(1, 2)}")
# Simple Test:1 ends here
