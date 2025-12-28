#!/bin/bash

# monitor-folders.sh
# Monitors a directory for new folder creation and automatically initializes GitHub repos

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if fswatch is installed
if ! command -v fswatch &> /dev/null; then
    print_error "fswatch is not installed."
    echo ""
    echo "Install it using Homebrew:"
    echo "  brew install fswatch"
    echo ""
    exit 1
fi

# Get the directory to monitor
WATCH_DIR="${1:-.}"

if [ ! -d "$WATCH_DIR" ]; then
    print_error "Directory does not exist: $WATCH_DIR"
    exit 1
fi

# Convert to absolute path
WATCH_DIR=$(cd "$WATCH_DIR" && pwd)

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INIT_SCRIPT="$SCRIPT_DIR/init-repo.sh"

if [ ! -f "$INIT_SCRIPT" ]; then
    print_error "init-repo.sh not found at: $INIT_SCRIPT"
    exit 1
fi

# Default visibility for new repos
VISIBILITY="${2:-public}"

print_info "Starting folder monitor..."
print_info "Watching directory: $WATCH_DIR"
print_info "New repositories will be created as: $VISIBILITY"
print_info "Press Ctrl+C to stop monitoring"
echo ""

# Store existing directories
declare -A existing_dirs
while IFS= read -r -d '' dir; do
    existing_dirs["$dir"]=1
done < <(find "$WATCH_DIR" -mindepth 1 -maxdepth 1 -type d -print0)

# Monitor for changes
fswatch -0 -r --event Created --event-flags "$WATCH_DIR" | while read -d "" event; do
    # Extract the path and flags
    EVENT_PATH=$(echo "$event" | cut -f1)

    # Check if it's a new directory in the watched folder (not subdirectories)
    if [ -d "$EVENT_PATH" ]; then
        # Get parent directory
        PARENT_DIR=$(dirname "$EVENT_PATH")

        # Only process if it's a direct child of WATCH_DIR
        if [ "$PARENT_DIR" = "$WATCH_DIR" ]; then
            # Check if we've already processed this directory
            if [ -z "${existing_dirs[$EVENT_PATH]}" ]; then
                existing_dirs["$EVENT_PATH"]=1

                FOLDER_NAME=$(basename "$EVENT_PATH")
                print_info "New folder detected: $FOLDER_NAME"

                # Small delay to ensure folder is fully created
                sleep 1

                # Check if it's not already a git repository
                if [ ! -d "$EVENT_PATH/.git" ]; then
                    print_info "Initializing repository for: $FOLDER_NAME"

                    # Run the init script
                    if bash "$INIT_SCRIPT" "$EVENT_PATH" "$VISIBILITY"; then
                        print_info "Successfully initialized: $FOLDER_NAME"
                        echo ""
                    else
                        print_error "Failed to initialize: $FOLDER_NAME"
                        echo ""
                    fi
                else
                    print_warning "Folder already contains a git repository: $FOLDER_NAME"
                    echo ""
                fi
            fi
        fi
    fi
done
