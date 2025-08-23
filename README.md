# GitHubPRMenu.spoon

A Hammerspoon Spoon that displays GitHub pull requests awaiting your review in the macOS menu bar.

## Features

- Shows PR count in menu bar (✓ No PRs or 🔍 X PRs)
- Categorizes PRs as "Fresh Reviews" or "Re-requested"
- Searches across all repositories you have access to
- Auto-refreshes every hour (configurable)
- Clickable PR URLs to open directly in browser
- Manual refresh and quick GitHub access
- Proper Hammerspoon Spoon packaging

## Project Files

- `GitHubPRMenu.spoon/` - Main Spoon package directory
  - `init.lua` - Spoon implementation
  - `list-prs-awaiting-my-review.js` - GitHub PR listing script
- `install-spoon.sh` - Automated installation script
- Legacy files (for reference):
  - `init.lua` - Basic standalone configuration
  - `enhanced-init.lua` - Advanced standalone configuration

## Prerequisites

1. **Hammerspoon**: Download and install from [hammerspoon.org](https://www.hammerspoon.org/)
2. **GitHub CLI**: Install and authenticate with `gh auth login`
3. **Node.js**: Required to run the PR listing script

## Installation

### Quick Install (Recommended)

```bash
# Run the Spoon install script
./install-spoon.sh
```

### Manual Install

1. **Copy the Spoon to Hammerspoon**:
   ```bash
   # Create Spoons directory if it doesn't exist
   mkdir -p ~/.hammerspoon/Spoons
   
   # Copy the entire Spoon
   cp -r GitHubPRMenu.spoon ~/.hammerspoon/Spoons/
   ```

2. **Add to your Hammerspoon configuration**:
   Add this to your `~/.hammerspoon/init.lua`:
   ```lua
   hs.loadSpoon("GitHubPRMenu")
   spoon.GitHubPRMenu:start()
   ```

3. **Reload Hammerspoon**: 
   - Open Hammerspoon app
   - Click "Reload Config" or press ⌘+R

## Usage

- The menu bar will show either:
  - `✓ No PRs` when you have no pending reviews
  - `🔍 X PRs` when you have PRs to review

- Click the menu bar item to see:
  - List of fresh PRs (never reviewed) - clickable
  - List of re-requested PRs (previously reviewed) - clickable
  - Manual refresh option
  - Link to GitHub reviews page
  - Copy summary to clipboard

## Configuration

You can customize the Spoon behavior:

```lua
-- Load and start the Spoon
hs.loadSpoon("GitHubPRMenu")

-- Customize refresh interval (default: 3600 seconds = 1 hour)
spoon.GitHubPRMenu:setRefreshInterval(1800)  -- 30 minutes

-- Start monitoring
spoon.GitHubPRMenu:start()
```

You can also modify the Spoon's properties directly:
- `spoon.GitHubPRMenu.noPRsText` - Text shown when no PRs (default: "✓ No PRs")
- `spoon.GitHubPRMenu.hasPRsText` - Text pattern for PR count (default: "🔍 %d PRs")

## Troubleshooting

- Check Hammerspoon console for error messages
- Ensure GitHub CLI is authenticated: `gh auth status`
- Verify Node.js can run the PR script: `node ~/.hammerspoon/Spoons/GitHubPRMenu.spoon/list-prs-awaiting-my-review.js`
- Check that the Spoon loaded: Look for "GitHubPRMenu" in Hammerspoon console

## Spoon Methods

- `spoon.GitHubPRMenu:start()` - Start PR monitoring
- `spoon.GitHubPRMenu:stop()` - Stop PR monitoring  
- `spoon.GitHubPRMenu:setRefreshInterval(seconds)` - Change refresh rate