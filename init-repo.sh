#!/bin/bash

# init-repo.sh
# Initializes a git repository and creates a corresponding GitHub repository

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# Get the directory to initialize (default: current directory)
TARGET_DIR="${1:-.}"
cd "$TARGET_DIR" || exit 1

# Get the folder name (this will be the repo name)
REPO_NAME=$(basename "$(pwd)")

print_info "Initializing repository for: $REPO_NAME"

# Check if already a git repository
if [ -d ".git" ]; then
    print_warning "Already a git repository. Skipping git init."
else
    print_info "Initializing git repository..."
    git init
fi

# Check if GitHub CLI is authenticated
if ! gh auth status &>/dev/null; then
    print_error "GitHub CLI is not authenticated. Run 'gh auth login' first."
    exit 1
fi

# Check if remote repository already exists
if gh repo view "$REPO_NAME" &>/dev/null; then
    print_warning "GitHub repository '$REPO_NAME' already exists."

    # Check if remote is already set
    if ! git remote get-url origin &>/dev/null; then
        print_info "Adding remote origin..."
        gh repo view "$REPO_NAME" --json sshUrl -q .sshUrl | xargs git remote add origin
    fi
else
    # Ask user for repository visibility
    VISIBILITY="${2:-public}"

    print_info "Creating GitHub repository as $VISIBILITY..."

    # Create the repository on GitHub
    if [ "$VISIBILITY" = "private" ]; then
        gh repo create "$REPO_NAME" --private --source=. --remote=origin
    else
        gh repo create "$REPO_NAME" --public --source=. --remote=origin
    fi
fi

# Create initial commit if no commits exist
if ! git rev-parse HEAD &>/dev/null; then
    print_info "Creating initial commit..."

    # Create a basic .gitignore if it doesn't exist
    if [ ! -f ".gitignore" ]; then
        cat > .gitignore << 'EOF'
# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# IDE
.vscode/
.idea/
*.swp
*.swo

# Dependencies
node_modules/
vendor/

# Environment
.env
.env.local
EOF
    fi

    # Create a basic README if it doesn't exist
    if [ ! -f "README.md" ]; then
        echo "# $REPO_NAME" > README.md
        echo "" >> README.md
        echo "This repository was automatically initialized." >> README.md
    fi

    git add .
    git commit -m "Initial commit"

    print_info "Pushing initial commit to GitHub..."
    git branch -M main
    git push -u origin main
fi

print_info "Repository setup complete!"
print_info "GitHub URL: $(gh repo view --json url -q .url)"
