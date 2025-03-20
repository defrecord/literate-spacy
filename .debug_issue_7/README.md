# Org-babel-detangle Solution

This directory contains tests and examples for fixing the bidirectional tangle/detangle workflow (Issue #7).

## The Problem

We wanted bidirectional editing:
1. Edit org file → tangle → changes in Python file 
2. Edit Python file → detangle → changes in org file

However, the detangle step wasn't working - no matter what markers we used in the Python files.

## The Solution

After examining the org-mode source code and running various tests, we discovered:

1. The key is using the **`:comments link`** header argument when tangling:
   ```org
   #+begin_src python :tangle file.py :comments link
   ```

2. This generates special comments in the Python file that enable detangling:
   ```python
   # [[file:org-file.org::*Heading][Block Name]]
   # code here...
   # Block Name ends here
   ```

3. The `org-babel-detangle` function specifically looks for these link patterns to find the source org file and block.

## Working Example

1. `solution_test.org` - an org file with the `:comments link` header
2. `solution_test.py` - the tangled Python file with proper link comments
3. `solution_makefile` - example of how to run tangle/detangle properly
4. `debug_detangle.el` - debugging script showing it works

## How to Use

1. Update all org files to include `:comments link` in source blocks
2. Use the improved `detangle` target in the Makefile that:
   - Properly detangles each source file individually
   - Preserves indentation
   - Processes all generated files

## Implementation Notes

- `org-babel-detangle` is run from each source file back to the org file
- It follows the link in the comment to find the right code block
- The function returns the number of blocks detangled