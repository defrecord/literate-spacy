#!/bin/bash
# Convert files to org-mode format

# Check if we have at least 2 arguments (output file and at least one input file)
if [ $# -lt 2 ]; then
  echo "Usage: $0 output.org file1 [file2 ...]"
  exit 1
fi

# First argument is the output org file
output_file="$1"
shift

# Create the org file header
cat > "$output_file" << EOF
#+TITLE: Project Files
#+AUTHOR: Files-to-Prompt
#+DATE: $(date "+%Y-%m-%d")

* Project Structure

Files included in this document:

EOF

# Add list of files
for file in "$@"; do
  echo "- $file" >> "$output_file"
done

# Add each file as a source block
for file in "$@"; do
  if [ ! -f "$file" ]; then
    echo "Warning: File $file not found. Skipping."
    continue
  fi

  # Get file name and directory
  file_name=$(basename "$file")
  dir_name=$(dirname "$file")
  
  # Use relative paths rather than absolute ones for the section title
  # Extract just the last component of the directory path
  short_dir=$(basename "$dir_name")
  if [ "$short_dir" = "." ]; then
    section_title="$file_name"
  else
    section_title="$short_dir/$file_name"
  fi

  # Determine language for syntax highlighting
  ext="${file_name##*.}"
  case "$ext" in
    py)
      lang="python"
      comments="link"
      ;;
    sh|bash)
      lang="shell"
      comments="link"
      ;;
    js)
      lang="javascript"
      comments="link"
      ;;
    java)
      lang="java"
      comments="link"
      ;;
    c|h)
      lang="c"
      comments="link"
      ;;
    cpp|hpp)
      lang="cpp"
      comments="link"
      ;;
    md)
      lang="markdown"
      comments="link"
      ;;
    html)
      lang="html"
      comments="link"
      ;;
    css)
      lang="css"
      comments="link"
      ;;
    *)
      # Handle special filenames and extensions
      if [ "$file_name" = ".gitignore" ]; then
        lang="text"
        comments="no"
      elif [ "$file_name" = "Makefile" ]; then
        lang="makefile"
        comments="link"
      elif [ "$file_name" = "polcalc.scm" ] || [[ "$file_name" == *.scm ]]; then
        lang="scheme"
        comments="link"
      else
        lang="text"
        comments="no"
      fi
      ;;
  esac

  # Append section header and begin source block
  cat >> "$output_file" << EOF

* $section_title

#+begin_src $lang :tangle $file :mkdirp yes :comments $comments
$(cat "$file")
#+end_src
EOF
done

echo "Created org file: $output_file"