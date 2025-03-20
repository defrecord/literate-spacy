# Understanding Org-Mode Detangle Functionality

After examining the org-mode source code, particularly `ob-tangle.el`, I've discovered why our detangle attempts haven't been working.

## How Detangle Actually Works

The `org-babel-detangle` function (in `ob-tangle.el`) works by:

1. Searching for special tangle comments in the source code file
2. These comments must match a specific pattern:
   - Begin comment: `[[file:path/to/org/file.org::*Heading][Source Block Name]]` 
   - End comment: ` Source Block Name ends here`
3. When found, it follows the link back to the org file, finds the related code block, and updates it

## Why Our Approach Doesn't Work

Our current approach has been missing several key elements:

1. **Missing Tangle Comments**: Our tangled files don't have the begin/end link comments that `org-babel-detangle` looks for
2. **Using Wrong Header**: We've been using `tangle-source` header comments, but these aren't what detangle looks for
3. **Confusion about Direction**: We've been trying to detangle from the org file, but detangle should be run from the source file back to the org file

## Solution: Proper Tangle Comment Format

When tangling, we need to ensure comments are added with:

```
#+BEGIN_SRC python :tangle test.py :comments link
```

The `:comments link` option is critical - it generates the link comments that detangle uses.

## Example Implementation

1. Update our org file to include `:comments link` for each code block:

```org
#+BEGIN_SRC python :tangle test.py :comments link
def hello():
    """Say hello to the world."""
    print("Hello, world!")
    return "Hello, world!"
#+END_SRC
```

2. Run tangle - this will generate a Python file with comments like:

```python
# [[file:test.org::*Block Name][Block Name]]
def hello():
    """Say hello to the world."""
    print("Hello, world!")
    return "Hello, world!"
# Block Name ends here
```

3. When code is modified, run detangle on the source file back to the org file

## Updated Makefile

```makefile
tangle:
	@echo "Tangling org files with link comments..."
	@emacs --batch \
		--eval "(require 'org)" \
		--eval "(find-file \"test.org\")" \
		--eval "(org-babel-tangle)" \
		--eval "(kill-buffer)"

detangle:
	@echo "Detangling source files back to org files..."
	@emacs --batch \
		--eval "(require 'org)" \
		--eval "(org-babel-detangle \"test.py\")" \
		--eval "(message \"Detangle complete\")"
```

The key insight is that detangle must be called with the source file as an argument, not the org file, and the source file must contain the specially formatted link comments.