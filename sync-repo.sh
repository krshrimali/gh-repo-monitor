#!/bin/bash

# sync-repo.sh
# Commits and pushes changes to GitHub with a custom or default message

set -e

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

print_status() {
    echo -e "${BLUE}[STATUS]${NC} $1"
}

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    print_error "Not a git repository. Run init-repo.sh first."
    exit 1
fi

# Get custom commit message or use default
DEFAULT_MESSAGE="Auto-sync: $(date '+%Y-%m-%d %H:%M:%S')"
COMMIT_MESSAGE="${1:-$DEFAULT_MESSAGE}"

# Get repository name
REPO_NAME=$(basename "$(git rev-parse --show-toplevel)")

print_info "Syncing repository: $REPO_NAME"

# Check for changes
if git diff-index --quiet HEAD -- 2>/dev/null && [ -z "$(git ls-files --others --exclude-standard)" ]; then
    print_warning "No changes to commit."
    exit 0
fi

# Show status
print_status "Changes to be committed:"
git status --short

echo ""

# Stage all changes
print_info "Staging all changes..."
git add .

# Show what will be committed
CHANGED_FILES=$(git diff --cached --name-only | wc -l | tr -d ' ')
print_info "Files changed: $CHANGED_FILES"

# Create commit
print_info "Creating commit with message: '$COMMIT_MESSAGE'"
git commit -m "$COMMIT_MESSAGE"

# Push to remote
print_info "Pushing to GitHub..."
CURRENT_BRANCH=$(git branch --show-current)

if git push origin "$CURRENT_BRANCH" 2>&1; then
    print_info "Successfully synced to GitHub!"

    # Show GitHub URL
    if command -v gh &> /dev/null; then
        REPO_URL=$(gh repo view --json url -q .url 2>/dev/null || echo "")
        if [ -n "$REPO_URL" ]; then
            print_info "View at: $REPO_URL"
        fi
    fi
else
    # If push fails, try to set upstream
    print_warning "Failed to push. Trying to set upstream..."
    git push -u origin "$CURRENT_BRANCH"
    print_info "Successfully synced to GitHub!"
fi
