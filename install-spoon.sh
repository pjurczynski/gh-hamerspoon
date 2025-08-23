#!/bin/bash

# GitHubPRMenu Spoon - Installation Script

set -e

echo "🔧 Installing GitHubPRMenu Spoon..."

# Create Spoons directory
mkdir -p ~/.hammerspoon/Spoons

# Copy the entire Spoon
echo "📦 Copying GitHubPRMenu.spoon..."
cp -r GitHubPRMenu.spoon ~/.hammerspoon/Spoons/

echo "📝 Adding to Hammerspoon configuration..."

# Configuration to add
CONFIG='
-- GitHubPRMenu Spoon Configuration
hs.loadSpoon("GitHubPRMenu")
spoon.GitHubPRMenu:start()

-- Optional: Customize refresh interval (default: 3600 seconds = 1 hour)
-- spoon.GitHubPRMenu:setRefreshInterval(1800)  -- 30 minutes
'

# Check if init.lua exists
if [ -f ~/.hammerspoon/init.lua ]; then
    echo "⚠️  Existing Hammerspoon configuration found."
    echo "📝 Appending GitHubPRMenu Spoon configuration..."
    echo "$CONFIG" >> ~/.hammerspoon/init.lua
    echo "✅ Configuration appended to existing init.lua"
else
    echo "📝 Creating new Hammerspoon configuration..."
    echo "$CONFIG" > ~/.hammerspoon/init.lua
    echo "✅ Configuration installed as init.lua"
fi

echo ""
echo "🎉 GitHubPRMenu Spoon installation complete!"
echo ""
echo "Next steps:"
echo "1. Make sure Hammerspoon is installed (https://www.hammerspoon.org/)"
echo "2. Make sure GitHub CLI is authenticated (gh auth status)"
echo "3. Open Hammerspoon and reload the configuration (⌘+R)"
echo "4. Look for the PR indicator in your menu bar!"
echo ""
echo "To customize:"
echo "- Edit ~/.hammerspoon/Spoons/GitHubPRMenu.spoon/init.lua"
echo "- Or use spoon.GitHubPRMenu:setRefreshInterval(seconds) in your config"
echo ""