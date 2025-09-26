show_help() {
    echo "Usage: $0 [source_directory] [target_directory]"
    echo "Options:"
    echo "  -h, --help    Show this help message"
}

# help 
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

# Two argument
if [[ $# -ne 2 ]]; then
    echo "Error: You must provide a source and a target directory."
    show_help
    exit 1
fi

SOURCE=$1
TARGET=$2

# Source dirction must exist
if [[ ! -d "$SOURCE" ]]; then
    echo "Error: Source directory does not exist: $SOURCE"
    exit 1
fi
