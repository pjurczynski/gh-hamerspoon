# Hammerspoon GitHub PR Menu Bar

This Hammerspoon configuration displays GitHub pull requests awaiting your review in the macOS menu bar.

## Features

- Shows PR count in menu bar (✓ No PRs or 🔍 X PRs)
- Categorizes PRs as "Fresh Reviews" or "Re-requested"
- Searches across all repositories you have access to
- Auto-refreshes every hour
- Manual refresh option
- Quick link to GitHub review page

## Project Files

- `init.lua` - Basic Hammerspoon configuration
- `enhanced-init.lua` - Advanced version with clickable PR URLs  
- `list-prs-awaiting-my-review.js` - GitHub PR listing script
- `pr-check-wrapper.js` - Directory-independent wrapper script

## Prerequisites

1. **Hammerspoon**: Download and install from [hammerspoon.org](https://www.hammerspoon.org/)
2. **GitHub CLI**: Install and authenticate with `gh auth login`
3. **Node.js**: Required to run the PR listing script

## Installation

1. **Copy the configuration**:
   ```bash
   # If you don't have a Hammerspoon config yet:
   mkdir -p ~/.hammerspoon
   cp init.lua ~/.hammerspoon/init.lua
   
   # If you already have Hammerspoon config, append to existing init.lua:
   cat init.lua >> ~/.hammerspoon/init.lua
   ```

2. **The script path is already configured**: 
   The `prScriptPath` variable in both `init.lua` files points to the included `list-prs-awaiting-my-review.js` script.

3. **Reload Hammerspoon**: 
   - Open Hammerspoon app
   - Click "Reload Config" or press ⌘+R

## Usage

- The menu bar will show either:
  - `✓ No PRs` when you have no pending reviews
  - `🔍 X PRs` when you have PRs to review

- Click the menu bar item to see:
  - List of fresh PRs (never reviewed)
  - List of re-requested PRs (previously reviewed)
  - Manual refresh option
  - Link to GitHub reviews page

## Customization

You can modify these settings in `init.lua`:

- `refreshInterval`: Change update frequency (default: 3600 seconds = 1 hour)
- `noPRsText`: Customize text shown when no PRs are pending
- `hasPRsText`: Customize text pattern for PR count display

## Troubleshooting

- Check Hammerspoon console for error messages
- Ensure GitHub CLI is authenticated: `gh auth status`
- Verify Node.js can run the PR script: `node /path/to/list-prs-awaiting-my-review.js`
- Make sure the script path in `init.lua` is correct and accessible