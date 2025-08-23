-- Debug version of GitHubPRMenu for troubleshooting

local obj = {}
obj.__index = obj
obj.name = "GitHubPRMenuDebug"
obj.logger = hs.logger.new('GitHubPRMenuDebug')

local menu = nil
local spoonPath = nil

function obj:init()
    spoonPath = hs.spoons.scriptPath("GitHubPRMenu")
    self.logger.i("=== GitHubPRMenu Debug Init ===")
    self.logger.i("Spoon path: " .. (spoonPath or "nil"))
    
    if spoonPath then
        local scriptPath = spoonPath .. "/list-prs-awaiting-my-review.js"
        self.logger.i("Script path: " .. scriptPath)
        
        -- Check if script exists
        local file = io.open(scriptPath, "r")
        if file then
            file:close()
            self.logger.i("✅ Script file exists")
        else
            self.logger.e("❌ Script file not found")
        end
    end
end

function obj:testScript()
    if not spoonPath then
        self.logger.e("No spoon path available")
        return false
    end
    
    local scriptPath = spoonPath .. "/list-prs-awaiting-my-review.js"
    self.logger.i("Testing script execution...")
    
    -- Test from different directories
    local testDirs = {
        os.getenv("HOME"),
        os.getenv("HOME") .. "/code/pix/platform-cloud-django",
        os.getenv("HOME") .. "/code/pix/cloud-js"
    }
    
    for _, testDir in ipairs(testDirs) do
        self.logger.i("Testing from directory: " .. testDir)
        local command = "cd \"" .. testDir .. "\" && node \"" .. scriptPath .. "\" 2>&1"
        local output, status = hs.execute(command)
        
        self.logger.i("  Status: " .. tostring(status))
        self.logger.i("  Output: " .. (output or "no output"))
        
        if status then
            self.logger.i("✅ Script works from: " .. testDir)
            return true, testDir, output
        end
    end
    
    return false
end

function obj:start()
    self.logger.i("=== Starting Debug Version ===")
    
    menu = hs.menubar.new()
    menu:setTitle("🔍 Debug")
    
    local success, workingDir, output = self:testScript()
    
    if success then
        menu:setTitle("✅ Working")
        menu:setMenu({
            { title = "Script test successful!", disabled = true },
            { title = "Working directory: " .. (workingDir or "unknown"), disabled = true },
            { title = "", disabled = true },
            { title = "Output:", disabled = true },
            { title = tostring(output):sub(1, 100), disabled = true }
        })
        self.logger.i("✅ Debug test passed")
    else
        menu:setTitle("❌ Failed")
        menu:setMenu({
            { title = "Script test failed!", disabled = true },
            { title = "Check Hammerspoon console", disabled = true }
        })
        self.logger.e("❌ Debug test failed")
    end
    
    return self
end

function obj:stop()
    if menu then
        menu:delete()
        menu = nil
    end
    return self
end

return obj