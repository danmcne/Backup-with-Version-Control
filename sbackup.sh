#!/bin/bash

set -e

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

# Run rsync to sync files and move older versions with date and UUID appended
echo "Running rsync..."
rsync -avz --progress --checksum --backup --backup-dir="older_versions" \
  --suffix="~$(date +%Y-%m-%d)-$(uuidgen | cut -c1-8)" \
  "$SOURCE_DIR/" "$DEST_DIR/"

echo "Synchronization complete."
