# Backup Script with Version Control

This Bash script synchronizes files from a source directory to a destination directory using `rsync`, while keeping older versions of modified files. It appends a timestamp to old versions and stores them in a separate `older_versions` directory. After that, the script renames the older files by appending a 6-character MD5 hash for uniqueness, ensuring no file name conflicts.

## Features

- **File synchronization**: Syncs a source directory to a destination directory using `rsync`.
- **Version control**: Stores older versions of modified files in an `older_versions` directory within the destination.
- **File renaming**: Renames older files by appending the modification date (added by `rsync`) and a 6-character MD5 hash.
- **Unique file versions**: Ensures that older versions of the same file do not overwrite each other by including both the modification date and the MD5 hash.
- **Cleanup**: Removes empty directories from `older_versions` after renaming.
- **Verbose mode**: Displays renaming details if enabled.

## Usage

```bash
./sbackup.sh [-v] <source_dir> <dest_dir>
```

- `-v` (optional): Enables verbose mode, showing detailed output of renamed files.
- `<source_dir>`: Directory to back up.
- `<dest_dir>`: Directory where the files will be synchronized and older versions stored.

### Example

```bash
./sbackup.sh -v /path/to/source /path/to/destination
```

This will:

1. Sync `/path/to/source` to `/path/to/destination`.
2. Move older/modified files to the `older_versions` directory inside the destination.
3. Append a timestamp to older file versions (done by `rsync`).
4. Rename files in `older_versions` by appending a 6-character MD5 hash for uniqueness.
5. Clean up empty directories in `older_versions`.

## File Naming Convention

The script generates filenames in the `older_versions` directory with the format:

- For files **without extensions** (e.g., `.bashrc`):
  
  ```
  filename-YYYYMMDD-HHMMSS-MD5hash
  ```

- For files **with extensions** (e.g., `example.txt`):
  
  ```
  filename.ext-YYYYMMDD-HHMMSS-MD5hash
  ```

Here’s how it works:

- **`YYYYMMDD-HHMMSS`**: Date and time of the file version, appended by `rsync`.
- **`MD5hash`**: A 6-character truncated MD5 hash for uniqueness, appended by the script.

This naming scheme ensures that even if multiple versions of the same file exist, each version remains unique.

## Requirements

- **`rsync`** must be installed on your system.
- **`md5sum`** is used to generate the hash for file uniqueness.

## Script Breakdown

- **`get_md5_hash`**: Extracts the first 6 characters of the MD5 hash of a file.
- **`rsync`**: Synchronizes the source and destination directories. It moves modified files to `older_versions` with a timestamp (`YYYYMMDD-HHMMSS`) appended.
- **File renaming**: After `rsync` completes, the script further renames each older version in `older_versions` by adding a 6-character MD5 hash to avoid name collisions.
  
## Verbose Mode

When running the script with the `-v` flag, the script will output information about each renamed file, showing both the original and new filenames.

## Example Output

```bash
Running rsync...
Renaming files in /path/to/destination/older_versions...
Renamed file.txt-20230922-102030 to file.txt-20230922-102030-1a2b3c
Renamed .bashrc-20230922-102030 to .bashrc-20230922-102030-4d5e6f
Cleaning up empty directories in /path/to/destination/older_versions...
Synchronization and renaming complete.
```

## Error Handling

- The script exits with an error if the source or destination directories are not provided.
- It ensures that the source, destination, and `older_versions` directories exist before proceeding.

## License

This script is released under the MIT License. Feel free to use, modify, and distribute it as needed.
