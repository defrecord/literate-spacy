# [[file:../../project.org::*scripts/shell/example.sh][scripts/shell/example.sh:1]]
# [[file:../../project.org::*scripts/shell/example.sh][scripts/shell/example.sh:1]]
#!/bin/bash
# Example shell script for files-to-prompt test

# Print a greeting
echo "Converting files to org-mode format..."

# Function to convert files
convert_files() {
    local input_dir=$1
    local output_file=$2
    
    echo "Processing files in $input_dir"
    echo "Output will be written to $output_file"
    
    # Loop through files
    for file in "$input_dir"/*; do
        if [ -f "$file" ]; then
            echo "- Processing $file"
            # Process the file here
        fi
    done
    
    echo "Conversion complete!"
}

# Main execution
if [ $# -lt 2 ]; then
    echo "Usage: $0 <input_directory> <output_file>"
    exit 1
fi

convert_files "$1" "$2"
exit 0
# scripts/shell/example.sh:1 ends here
# scripts/shell/example.sh:1 ends here
