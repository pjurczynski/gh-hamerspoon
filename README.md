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

### Quick Install (Recommended)

```bash
# Run the install script
./install.sh
```

### Manual Install

1. **Copy all files to your Hammerspoon directory**:
   ```bash
   # Create Hammerspoon config directory if it doesn't exist
   mkdir -p ~/.hammerspoon
   
   # Copy the PR script (required)
   cp list-prs-awaiting-my-review.js ~/.hammerspoon/
   
   # Option 1: Use basic configuration
   cp init.lua ~/.hammerspoon/init.lua
   
   # Option 2: Use enhanced configuration (recommended)
   cp enhanced-init.lua ~/.hammerspoon/init.lua
   
   # Option 3: If you already have a Hammerspoon config, append:
   cat enhanced-init.lua >> ~/.hammerspoon/init.lua
   ```

2. **The script paths are automatically detected**: 
   The configuration will look for `list-prs-awaiting-my-review.js` in your `~/.hammerspoon` directory.

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