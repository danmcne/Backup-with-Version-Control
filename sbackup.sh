#!/bin/bash

set -e

# Function to get MD5 hash of a file
get_md5_hash() {
    md5sum "$1" | cut -d ' ' -f 1 | cut -c1-6
}

# Function to format modification date as YYYY-MM-DD
format_date() {
    date -r "$1" +"%Y-%m-%d"
}

# Parse command line options
VERBOSE=false
while getopts "v" opt; do
    case $opt in
        v) VERBOSE=true ;;
        *) echo "Usage: $0 [-v] <source_dir> <dest_dir>"; exit 1 ;;
    esac
done
shift $((OPTIND-1))

# Check if source and destination are provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 [-v] <source_dir> <dest_dir>"
    exit 1
fi

SOURCE_DIR="$1"
DEST_DIR="$2"
DEST_DIR="${DEST_DIR%/}"
OLDER_VERSIONS_DIR="$DEST_DIR/older_versions"

# Ensure directories exist
mkdir -p "$SOURCE_DIR" "$DEST_DIR" "$OLDER_VERSIONS_DIR"

# Run rsync to sync files and move older versions with datetime appended
echo "Running rsync..."
rsync -avz --progress --checksum --backup --backup-dir=older_versions \
  --suffix="-$(date +%Y%m%d-%H%M%S)" \
  "$SOURCE_DIR/" "$DEST_DIR/"

# Post-processing: Rename files in the older_versions directory
echo "Renaming files in $OLDER_VERSIONS_DIR..."

find "$OLDER_VERSIONS_DIR" -type f | while read -r file; do
    dir=$(dirname "$file")
    base=$(basename "$file")
    

    # Get the shortened hash to append
    hash=$(get_md5_hash "$file")

    # Create the new filename in the desired format
    new_name="${dir}/${base}-${hash}"

    # Rename the file
    mv "$file" "$new_name"
    
    if [ "$VERBOSE" = true ]; then
        echo "Renamed $file to $new_name"
    fi
done

# Clean up empty directories in the older_versions dir
echo "Cleaning up empty directories in $OLDER_VERSIONS_DIR..."
find "$OLDER_VERSIONS_DIR" -type d -empty -delete

echo "Synchronization and renaming complete."

