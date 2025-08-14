#!/bin/bash

# Hammerspoon GitHub PR Menu - Installation Script

set -e

echo "🔧 Installing Hammerspoon GitHub PR Menu..."

# Create Hammerspoon config directory
mkdir -p ~/.hammerspoon

# Copy the PR script
echo "📄 Copying GitHub PR script..."
cp list-prs-awaiting-my-review.js ~/.hammerspoon/

# Check if init.lua already exists
if [ -f ~/.hammerspoon/init.lua ]; then
    echo "⚠️  Existing Hammerspoon configuration found."
    echo "📝 Appending GitHub PR menu configuration..."
    echo "" >> ~/.hammerspoon/init.lua
    echo "-- GitHub PR Menu Configuration" >> ~/.hammerspoon/init.lua
    cat enhanced-init.lua >> ~/.hammerspoon/init.lua
    echo "✅ Configuration appended to existing init.lua"
else
    echo "📝 Creating new Hammerspoon configuration..."
    cp enhanced-init.lua ~/.hammerspoon/init.lua
    echo "✅ Configuration installed as init.lua"
fi

echo ""
echo "🎉 Installation complete!"
echo ""
echo "Next steps:"
echo "1. Make sure Hammerspoon is installed (https://www.hammerspoon.org/)"
echo "2. Make sure GitHub CLI is authenticated (gh auth status)"
echo "3. Open Hammerspoon and reload the configuration (⌘+R)"
echo "4. Look for the PR indicator in your menu bar!"
echo ""