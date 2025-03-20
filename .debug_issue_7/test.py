# -*- tangle-source: "test.org::*Simple Test" -*-
"""
Simple test file for tangle/detangle.
"""

def hello():
    """Say hello to the world."""
    message = "Hello, world!"
    print(message)
    return message

def add(a, b):
    """Add two numbers."""
    sum = a + b
    return sum

if __name__ == "__main__":
    hello()
    print(f"1 + 2 = {add(1, 2)}")
