--- === GitHubPRMenu ===
---
--- Display GitHub pull requests awaiting your review in the macOS menu bar
---
--- Download: https://github.com/your-username/GitHubPRMenu.spoon
--- Author: Your Name
--- License: MIT

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "GitHubPRMenu"
obj.version = "1.0"
obj.author = "Your Name"
obj.homepage = "https://github.com/your-username/GitHubPRMenu.spoon"
obj.license = "MIT"

obj.logger = hs.logger.new('GitHubPRMenu')

-- Configuration
obj.refreshInterval = 3600 -- 1 hour in seconds
obj.noPRsText = "✓ No PRs"
obj.hasPRsText = "🔍 %d PRs"

-- Internal variables
local menu = nil
local timer = nil
local spoonPath = nil

function obj:init()
    spoonPath = hs.spoons.scriptPath()
    self.logger.i("GitHubPRMenu initialized from: " .. spoonPath)
end

function obj:parseScriptOutput(output)
    local freshPRs = {}
    local reRequestedPRs = {}
    local currentSection = nil
    local currentPR = nil
    
    for line in output:gmatch("[^\r\n]+") do
        if line:match("^PRs where you have never reviewed") then
            currentSection = "fresh"
        elseif line:match("^PRs where your review was re%-requested") then
            currentSection = "rerequested"
        elseif line:match("^No fresh PRs") or line:match("^No PRs with re%-requested") then
            currentSection = nil
        elseif line:match("^%- ") and currentSection then
            -- New PR entry
            local prTitle = line:match("^%- (.+)$")
            currentPR = { title = prTitle, author = "", url = "", created = "" }
        elseif line:match("^  Author: ") and currentPR then
            currentPR.author = line:match("^  Author: (.+)$")
        elseif line:match("^  Created: ") and currentPR then
            currentPR.created = line:match("^  Created: (.+)$")
        elseif line:match("^  URL: ") and currentPR then
            currentPR.url = line:match("^  URL: (.+)$")
            -- PR is complete, add to appropriate section
            if currentSection == "fresh" then
                table.insert(freshPRs, currentPR)
            elseif currentSection == "rerequested" then
                table.insert(reRequestedPRs, currentPR)
            end
            currentPR = nil
        end
    end
    
    return freshPRs, reRequestedPRs
end

function obj:updatePRMenu()
    local scriptPath = spoonPath .. "/list-prs-awaiting-my-review.js"
    local output, status = hs.execute("node \"" .. scriptPath .. "\"")
    
    if not status then
        menu:setTitle("❌ Error")
        menu:setMenu({
            { title = "Script execution failed", disabled = true },
            { title = "" },
            { title = "Check Hammerspoon console for details", disabled = true }
        })
        self.logger.e("Script execution failed: " .. (output or "no output"))
        return
    end
    
    local freshPRs, reRequestedPRs = self:parseScriptOutput(output)
    local totalPRs = #freshPRs + #reRequestedPRs
    
    -- Update menu bar title
    if totalPRs == 0 then
        menu:setTitle(self.noPRsText)
    else
        menu:setTitle(string.format(self.hasPRsText, totalPRs))
    end
    
    -- Build menu items
    local menuItems = {}
    
    if totalPRs == 0 then
        table.insert(menuItems, { title = "No PRs awaiting review", disabled = true })
    else
        -- Add fresh PRs section
        if #freshPRs > 0 then
            table.insert(menuItems, { title = "🆕 Fresh Reviews (" .. #freshPRs .. ")", disabled = true })
            for _, pr in ipairs(freshPRs) do
                local displayText = string.format("%s (by %s)", pr.title, pr.author)
                if #displayText > 60 then
                    displayText = string.sub(displayText, 1, 57) .. "..."
                end
                table.insert(menuItems, { 
                    title = "  " .. displayText,
                    fn = function() hs.execute("open '" .. pr.url .. "'") end
                })
            end
            if #reRequestedPRs > 0 then
                table.insert(menuItems, { title = "" }) -- separator
            end
        end
        
        -- Add re-requested PRs section  
        if #reRequestedPRs > 0 then
            table.insert(menuItems, { title = "🔄 Re-requested (" .. #reRequestedPRs .. ")", disabled = true })
            for _, pr in ipairs(reRequestedPRs) do
                local displayText = string.format("%s (by %s)", pr.title, pr.author)
                if #displayText > 60 then
                    displayText = string.sub(displayText, 1, 57) .. "..."
                end
                table.insert(menuItems, { 
                    title = "  " .. displayText,
                    fn = function() hs.execute("open '" .. pr.url .. "'") end
                })
            end
        end
    end
    
    -- Add separator and actions
    table.insert(menuItems, { title = "" })
    table.insert(menuItems, { 
        title = "🔄 Refresh Now", 
        fn = function() self:updatePRMenu() end 
    })
    table.insert(menuItems, { 
        title = "⚙️ Open GitHub Reviews", 
        fn = function() hs.execute("open https://github.com/pulls/review-requested") end 
    })
    table.insert(menuItems, { 
        title = "📋 Copy Summary", 
        fn = function() 
            local summary = string.format("GitHub PRs: %d fresh, %d re-requested", #freshPRs, #reRequestedPRs)
            hs.pasteboard.setContents(summary)
        end 
    })
    
    menu:setMenu(menuItems)
    
    self.logger.i("Updated - " .. totalPRs .. " PRs found across all repositories")
end

--- GitHubPRMenu:start()
--- Method
--- Start the GitHub PR menu monitoring
---
--- Parameters:
---  * None
---
--- Returns:
---  * The GitHubPRMenu object
function obj:start()
    if menu then
        self:stop()
    end
    
    menu = hs.menubar.new()
    self:updatePRMenu()
    
    -- Set up periodic refresh
    timer = hs.timer.doEvery(self.refreshInterval, function() self:updatePRMenu() end)
    
    self.logger.i("Started GitHub PR monitoring. Refresh interval: " .. self.refreshInterval .. "s")
    return self
end

--- GitHubPRMenu:stop()
--- Method
--- Stop the GitHub PR menu monitoring
---
--- Parameters:
---  * None
---
--- Returns:
---  * The GitHubPRMenu object
function obj:stop()
    if timer then
        timer:stop()
        timer = nil
    end
    
    if menu then
        menu:delete()
        menu = nil
    end
    
    self.logger.i("Stopped GitHub PR monitoring")
    return self
end

--- GitHubPRMenu:setRefreshInterval(seconds)
--- Method
--- Set the refresh interval for checking PRs
---
--- Parameters:
---  * seconds - number of seconds between refreshes (default: 3600)
---
--- Returns:
---  * The GitHubPRMenu object
function obj:setRefreshInterval(seconds)
    self.refreshInterval = seconds
    if timer then
        timer:stop()
        timer = hs.timer.doEvery(self.refreshInterval, function() self:updatePRMenu() end)
    end
    self.logger.i("Refresh interval set to: " .. seconds .. "s")
    return self
end

return obj