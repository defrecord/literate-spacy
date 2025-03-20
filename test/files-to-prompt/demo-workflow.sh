#!/bin/bash
# Demo script showing the full files-to-prompt workflow

# Step 1: Clean up any previous run
echo "Cleaning up previous runs..."
make clean

# Step 2: Convert our sample files to an org file
echo "Converting sample files to org format..."
make files-to-org

# Step 3: At this point, you could edit the project.org file manually
# For this demo, we'll automatically add a note above the Python file
echo "Adding a note to the org file..."
sed -i.bak '/\* scripts\/python\/example.py/a\
This is the main Python file for the project. Note the newly added capabilities in the analyze_text function.' project.org
rm project.org.bak  # Remove backup file created by sed

# Step 4: Create a combined prompt file
echo "Creating combined prompt file..."
cat system_prompt.md project.org message_prompt.md > complete_prompt.md
echo "Created complete_prompt.md"

# Step 5: Show the command to send to Claude
echo ""
echo "To send this prompt to Claude, run:"
echo "claude complete_prompt.md"
echo ""

# Step 6: Demo modifying and tangling back
echo "After receiving code modifications from Claude, you would:"
echo "1. Update your project.org file with the changes"
echo "2. Run 'make org-to-files' to apply the changes to source files"
echo ""

echo "Workflow demonstration complete!"