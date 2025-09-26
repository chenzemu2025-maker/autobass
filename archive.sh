show_help() {
    echo "Usage: $0 [source_directory] [target_directory]"
    echo "Options:"
    echo "  -h, --help    Show this help message"
}

# help 开关
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi
24dbde9 (Add basic script skeleton and --help/-h option)
