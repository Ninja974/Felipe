repeat task.wait() until game:IsLoaded()

local Library = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remote = ReplicatedStorage.Remotes:WaitForChild("To_Server"):WaitForChild("Handle_Initiate_S")

local function getSkinFolder()
    local pd = ReplicatedStorage:WaitForChild("Player_Data")
    local who = pd:WaitForChild(LocalPlayer.Name) -- <- clave: NO hardcode
    return who:WaitForChild("Customization"):WaitForChild("Skin_Color")
end

local Window = Library:CreateWindow({
    Title = "FireScripts | Project Slayers | Skin Color Selector",
    TabWidth = 160,
    Size = UDim2.fromOffset(800, 500),
    MinSize = Vector2.new(400, 300),
    Theme = "Dark",
    Acrylic = true,
    MinimizeKey = Enum.KeyCode.RightShift
})

local Tabs = {
    ["Main"] = Window:AddTab({ Title = "Main", Icon = "code" }),
    ["Settings"] = Window:AddTab({ Title = "Settings", Icon = "settings" }),
    ["Credits"] = Window:AddTab({ Title = "Credits", Icon = "heart" }),
}

Tabs["Main"]:AddParagraph({
    Title = "Info",
    Content = "This script changes your character's skin color."
})


local function setRGB(r, g, b)
    local Skin = getSkinFolder()
    Remote:FireServer("Change_Value", Skin.R, r)
    Remote:FireServer("Change_Value", Skin.G, g)
    Remote:FireServer("Change_Value", Skin.B, b)
end

Tabs["Main"]:AddButton({
    Title = "Change Skin Color To Black",
    Callback = function()
        setRGB(0, 0, 0)
    end
})

Tabs['Main']:AddButton({
    Title = 'Change Skin Color To White',
    Callback = function()
        setRGB(1, 1, 1)
    end
})

Tabs['Main']:AddButton({
    Title = 'Change Skin Color To Pink',
    Callback = function()
        -- Pink ≈ (1, 0.4, 0.7)
        setRGB(1, 0.4, 0.7)
    end
})

Tabs['Main']:AddButton({
    Title = 'Change Skin Color To Red',
    
})
local rainbowRunning = false
Tabs["Main"]:AddButton({
    Title = 'Change Skin Color To Rainbow',
    Description = 'Stops when you leave the game (run again to restart).',
    Callback = function()
        if rainbowRunning then return end
        rainbowRunning = true

        task.spawn(function()
            local Skin = getSkinFolder()
            while rainbowRunning do
                for h = 0, 1, 0.01 do
                    if not rainbowRunning then break end
                    local c = Color3.fromHSV(h, 1, 1)
                    Remote:FireServer("Change_Value", Skin.R, c.R)
                    Remote:FireServer("Change_Value", Skin.G, c.G)
                    Remote:FireServer("Change_Value", Skin.B, c.B)
                    task.wait(0.05)
                end
            end
        end)

    end
})


Tabs["Main"]:AddButton({
    Title = 'Stop Rainbow',
    Callback = function()
        rainbowRunning = false
    end
})

SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetFolder("FireScripts/NewScript")
SaveManager:BuildConfigSection(Tabs["Settings"])
SaveManager:LoadAutoloadConfig()

Tabs["Credits"]:AddParagraph({
    Title = "Credits",
    Content = "Developed by N1NJA974"
})

Tabs["Credits"]:AddButton({
    Title = "Copy Discord",
    Callback = function()
        setclipboard("https://discord.gg/ry9e3kSb3A")
        Library:Notify({ Title = "Copied", Content = "Invite copied!", Duration = 3 })
    end
})

Window:SelectTab(1)
