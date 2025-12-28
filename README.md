# Auto GitHub Repository Manager

Made with Claude-Code

Automatically create GitHub repositories when you create new folders, and easily sync them with simple commands.

## Features

- **Automatic Repository Creation**: Monitor a directory and automatically create GitHub repos for new folders
- **Easy Syncing**: Commit and push changes with a single command
- **Customizable**: Choose between public/private repos, custom commit messages
- **Smart**: Detects existing repos and handles edge cases gracefully

## Prerequisites

1. **Git** (already installed on your system)
2. **GitHub CLI (gh)** (already installed on your system)
3. **fswatch** (needs installation)

### Installing fswatch

```bash
brew install fswatch
```

### Authenticating GitHub CLI

If you haven't already, authenticate with GitHub:

```bash
gh auth login
```

Follow the prompts to complete authentication.

## Scripts Overview

### 1. `init-repo.sh`

Initializes a git repository and creates a corresponding GitHub repository.

**Usage:**
```bash
./init-repo.sh [directory] [public|private]
```

**Examples:**
```bash
# Initialize current directory as public repo
./init-repo.sh

# Initialize specific directory as public repo
./init-repo.sh ~/Projects/my-project

# Initialize current directory as private repo
./init-repo.sh . private
```

**What it does:**
- Initializes git repository (if not already initialized)
- Creates GitHub repository
- Creates basic .gitignore and README.md
- Makes initial commit and pushes to GitHub

### 2. `sync-repo.sh`

Commits and pushes changes to GitHub.

**Usage:**
```bash
./sync-repo.sh [commit-message]
```

**Examples:**
```bash
# Sync with auto-generated message (includes timestamp)
./sync-repo.sh

# Sync with custom message
./sync-repo.sh "Added new features"

# Sync with multi-word message
./sync-repo.sh "Fixed bug in authentication flow"
```

**What it does:**
- Checks for changes
- Stages all modifications
- Creates commit with provided or default message
- Pushes to GitHub
- Shows repository URL

### 3. `monitor-folders.sh`

Monitors a directory for new folder creation and automatically initializes GitHub repos.

**Usage:**
```bash
./monitor-folders.sh [directory] [public|private]
```

**Examples:**
```bash
# Monitor current directory, create public repos
./monitor-folders.sh

# Monitor specific directory, create public repos
./monitor-folders.sh ~/Documents/Projects

# Monitor directory, create private repos
./monitor-folders.sh ~/Documents/Projects private
```

**What it does:**
- Continuously monitors the specified directory
- Detects when new folders are created
- Automatically runs init-repo.sh for each new folder
- Creates repositories with specified visibility

## Quick Start

### Setup

1. Make scripts executable:
```bash
chmod +x init-repo.sh sync-repo.sh monitor-folders.sh
```

2. Install fswatch:
```bash
brew install fswatch
```

3. Ensure GitHub CLI is authenticated:
```bash
gh auth status
# If not authenticated, run: gh auth login
```

### Workflow 1: Manual Initialization

```bash
# Create a new folder
mkdir my-new-project
cd my-new-project

# Initialize as GitHub repo
../init-repo.sh

# Do some work...
echo "console.log('Hello');" > index.js

# Sync changes
../sync-repo.sh "Added index.js"
```

### Workflow 2: Automatic Monitoring

```bash
# Terminal 1: Start monitoring
./monitor-folders.sh ~/Documents/Projects private

# Terminal 2: Create new folders
cd ~/Documents/Projects
mkdir awesome-project
# GitHub repo is automatically created!

cd awesome-project
# Do some work...

# Sync when ready
~/Documents/Projects/Innovations/sync-repo.sh "Initial features"
```

## Tips

### Add to PATH

To use these scripts from anywhere, add them to your PATH:

```bash
# Add to your ~/.zshrc or ~/.bashrc
export PATH="$PATH:/Users/krshrimali/Documents/Projects/Innovations"
```

Then reload your shell or run:
```bash
source ~/.zshrc  # or source ~/.bashrc
```

Now you can use the scripts from anywhere:
```bash
cd ~/any/directory
init-repo.sh
sync-repo.sh "My changes"
```

### Create Aliases

Add convenient aliases to your shell config:

```bash
# Add to ~/.zshrc or ~/.bashrc
alias gr-init='~/Documents/Projects/Innovations/init-repo.sh'
alias gr-sync='~/Documents/Projects/Innovations/sync-repo.sh'
alias gr-monitor='~/Documents/Projects/Innovations/monitor-folders.sh'
```

Usage after reload:
```bash
gr-init
gr-sync "Update documentation"
gr-monitor ~/Projects private
```

### Background Monitoring with launchd

For permanent background monitoring, you can create a launchd service:

1. Create a plist file at `~/Library/LaunchAgents/com.user.folder-monitor.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.folder-monitor</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Users/krshrimali/Documents/Projects/Innovations/monitor-folders.sh</string>
        <string>/Users/krshrimali/Documents/Projects</string>
        <string>private</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/folder-monitor.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/folder-monitor.err</string>
</dict>
</plist>
```

2. Load the service:
```bash
launchctl load ~/Library/LaunchAgents/com.user.folder-monitor.plist
```

3. Check logs:
```bash
tail -f /tmp/folder-monitor.log
```

## Troubleshooting

### "GitHub CLI is not authenticated"

Run:
```bash
gh auth login
```

### "fswatch not found"

Install fswatch:
```bash
brew install fswatch
```

### "Permission denied"

Make scripts executable:
```bash
chmod +x *.sh
```

### Script creates duplicate repos

The script checks if a repo already exists before creating. If you're seeing duplicates, ensure you're using unique folder names.

## Security Notes

- Scripts will respect your GitHub authentication
- Private repos remain private
- No credentials are stored by these scripts
- Uses official GitHub CLI for all GitHub operations

## License

Free to use and modify as needed.
