# -*- mode: python; tangle-source: "alt_test.org::example-python" -*-
"""
Test Python module for tangle/detangle.
"""

def hello():
    """Say hello to the world."""
    print("Hello world!")
    return "Hello world!"

def add(x, y):
    """Add two numbers and return the result."""
    result = x + y
    return result

if __name__ == "__main__":
    hello()
    print(f"2 + 3 = {add(2, 3)}")
