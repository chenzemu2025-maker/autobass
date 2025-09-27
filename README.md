# autobass
## This is a project wrote by Keqian Chen 117585825 
CSE 337 assignment 1

## Overview
A minimal Bash backup script.  
It accepts a source and target directory, creates a timestamped backup folder (or tar.gz), and copies the source into it.  
Supports dry-run, exclusion rules, and config file.  
Designed as a learning project for CSE 337.

## Features
- **Compression and Logging**  
  - Creates a compressed `.tar.gz` archive with timestamped filename.  
  - Logs all events to both terminal and `archive.log`.  
  - Logs include: script start, permission checks, source/target validation, backup confirmation, completion (success/failure), and dry-run notices.  

- **Configuration File (`archive.conf`)**  
  - User may specify source and target directories in a config file.  
  - If run with arguments:  
    ```bash
    ./archive.sh /path/to/source /path/to/target
    ```  
    → Command-line arguments override config file.  
  - If run without arguments:  
    ```bash
    ./archive.sh
    ```  
    → Script falls back to reading `archive.conf`.  

  - **Format of `archive.conf`:**  
    ```
    /absolute/path/to/source
    /absolute/path/to/target
    ```
    - First line = source directory  
    - Second line = target directory  

  - Invalid config file (missing lines, invalid paths) → script logs error and exits.

- **Exclusions (`.bassignore`)**  
  - List patterns of files/directories to exclude.  
  - Example `.bassignore`:  
    ```
    *.log
    *.tmp
    tmp/
    ```
  - Script passes these patterns to `tar --exclude-from`.

- **Dry-run (`-d` / `--dry-run`)**  
  - Simulates backup process without creating archive.  
  - Logs what *would* be backed up.  

## Usage
```bash
# Show help
./archive.sh -h

# Run with arguments
./archive.sh ~/Documents ~/Backups

# Run without arguments (uses archive.conf)
./archive.sh

# Simulate with dry-run
./archive.sh ~/Documents ~/Backups -d

## Installation
```bash
git clone https://github.com/chenzemu2025-maker/autobass.git
cd autobass
chmod +x archive.sh
