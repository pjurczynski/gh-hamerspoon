-- Hammerspoon GitHub PR Menu Bar Configuration
-- Displays pull requests awaiting your review in the macOS menu bar

local menu = hs.menubar.new()
local refreshInterval = 3600 -- 1 hour in seconds
-- Get the directory where this config file is located
local configDir = hs.configdir or os.getenv("HOME") .. "/.hammerspoon"
local prScriptPath = configDir .. "/list-prs-awaiting-my-review.js"
-- No default repo - will search across all repositories you have access to

-- Menu bar item text when there are no PRs
local noPRsText = "✓ No PRs"
-- Menu bar item text when there are PRs (will show count)
local hasPRsText = "🔍 %d PRs"

function updatePRMenu()
    -- Call script without repo argument to get PRs from all repositories
    local output, status = hs.execute("node \"" .. prScriptPath .. "\"")
    
    if not status then
        menu:setTitle("❌ Error")
        menu:setMenu({
            { title = "Script execution failed", disabled = true },
            { title = "" },
            { title = "Check Hammerspoon console for details", disabled = true }
        })
        print("Hammerspoon GitHub PR: Script execution failed")
        return
    end
    
    -- Parse the output to count and categorize PRs
    local freshPRs = {}
    local reRequestedPRs = {}
    local currentSection = nil
    
    for line in output:gmatch("[^\r\n]+") do
        if line:match("^PRs where you have never reviewed") then
            currentSection = "fresh"
        elseif line:match("^PRs where your review was re%-requested") then
            currentSection = "rerequested"
        elseif line:match("^No fresh PRs") or line:match("^No PRs with re%-requested") then
            currentSection = nil
        elseif line:match("^%- ") and currentSection then
            -- Extract PR title from line like "- PR Title"
            local prTitle = line:match("^%- (.+)$")
            if currentSection == "fresh" then
                table.insert(freshPRs, prTitle)
            elseif currentSection == "rerequested" then
                table.insert(reRequestedPRs, prTitle)
            end
        end
    end
    
    local totalPRs = #freshPRs + #reRequestedPRs
    
    -- Update menu bar title
    if totalPRs == 0 then
        menu:setTitle(noPRsText)
    else
        menu:setTitle(string.format(hasPRsText, totalPRs))
    end
    
    -- Build menu items
    local menuItems = {}
    
    if totalPRs == 0 then
        table.insert(menuItems, { title = "No PRs awaiting review", disabled = true })
    else
        -- Add fresh PRs section
        if #freshPRs > 0 then
            table.insert(menuItems, { title = "🆕 Fresh Reviews (" .. #freshPRs .. ")", disabled = true })
            for _, prTitle in ipairs(freshPRs) do
                table.insert(menuItems, { title = "  " .. prTitle, disabled = true })
            end
            if #reRequestedPRs > 0 then
                table.insert(menuItems, { title = "" }) -- separator
            end
        end
        
        -- Add re-requested PRs section  
        if #reRequestedPRs > 0 then
            table.insert(menuItems, { title = "🔄 Re-requested (" .. #reRequestedPRs .. ")", disabled = true })
            for _, prTitle in ipairs(reRequestedPRs) do
                table.insert(menuItems, { title = "  " .. prTitle, disabled = true })
            end
        end
    end
    
    -- Add separator and actions
    table.insert(menuItems, { title = "" })
    table.insert(menuItems, { 
        title = "🔄 Refresh Now", 
        fn = function() updatePRMenu() end 
    })
    table.insert(menuItems, { 
        title = "⚙️ Open GitHub", 
        fn = function() hs.execute("open https://github.com/pulls/review-requested") end 
    })
    
    menu:setMenu(menuItems)
    
    print("Hammerspoon GitHub PR: Updated - " .. totalPRs .. " PRs found across all repositories")
end

-- Initial update
updatePRMenu()

-- Set up periodic refresh
hs.timer.doEvery(refreshInterval, updatePRMenu)

print("Hammerspoon GitHub PR monitor loaded. Monitoring all repositories. Refresh interval: " .. refreshInterval .. "s")