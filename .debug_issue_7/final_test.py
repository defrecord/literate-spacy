#!/usr/bin/env python
"""
Test module for bidirectional editing.
"""

def greet(name="World"):
    """Greet someone."""
    return f"Hello, {name}!"

def calculate_sum(numbers):
    """Calculate sum of numbers."""
    return sum(numbers)

if __name__ == "__main__":
    print(greet())
    print(f"Sum of [1,2,3]: {calculate_sum([1,2,3])}")
