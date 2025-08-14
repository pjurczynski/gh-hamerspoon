-- Enhanced Hammerspoon GitHub PR Menu Bar Configuration
-- Displays pull requests awaiting your review with clickable URLs

local menu = hs.menubar.new()
local refreshInterval = 3600 -- 1 hour in seconds
local prScriptPath = "/Users/pjurczyn/code/pix/list-prs-awaiting-my-review.js"

-- Menu bar item text when there are no PRs
local noPRsText = "✓ No PRs"
-- Menu bar item text when there are PRs (will show count)
local hasPRsText = "🔍 %d PRs"

function parseScriptOutput(output)
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

function updatePRMenu()
    local output, status = hs.execute("node \"" .. prScriptPath .. "\"")
    
    if not status then
        menu:setTitle("❌ Error")
        menu:setMenu({
            { title = "Script execution failed", disabled = true },
            { title = "" },
            { title = "Check Hammerspoon console for details", disabled = true }
        })
        print("Hammerspoon GitHub PR: Script execution failed")
        print("Output:", output)
        return
    end
    
    local freshPRs, reRequestedPRs = parseScriptOutput(output)
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
        fn = function() updatePRMenu() end 
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
    
    print("Hammerspoon GitHub PR: Updated - " .. totalPRs .. " PRs found across all repositories")
end

-- Initial update
updatePRMenu()

-- Set up periodic refresh
hs.timer.doEvery(refreshInterval, updatePRMenu)

print("Enhanced Hammerspoon GitHub PR monitor loaded. Monitoring all repositories. Refresh interval: " .. refreshInterval .. "s")