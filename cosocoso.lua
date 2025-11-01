    ---------------------------------------------Dungeon------------------------------------------------------------------------------------------------------------
local Library = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local options = Library.Options
warn("---------------------------------")

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local player = game.Players.LocalPlayer
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local selectedorbs = selectedorbs or {}


local client = Players.LocalPlayer
local playerValues = game:GetService("ReplicatedStorage").PlayerValues:WaitForChild(client.Name)
local distance = 15


local places = require(game:GetService("ReplicatedStorage").Modules.Global.Map_Locaations)
local bosses = {}


local tweento = function(coords)
    local Distance = (coords.Position - client.Character.HumanoidRootPart.Position).Magnitude
    local Speed = Distance/options["sTweenSpeed"].Value

    local tween = TweenService:Create(client.Character.HumanoidRootPart,
        TweenInfo.new(Speed, Enum.EasingStyle.Linear),
        { CFrame = coords}
    )

    tween:Play()
    return tween
end

function tpto(p1)
    pcall(function()
        client.Character.HumanoidRootPart.CFrame = p1
    end)
end

local counter = 0
local time = tick()

local function findBoss(name, hrp)
    for i, v in pairs(workspace.Mobs:GetDescendants()) do
        if v:IsA("Model") and v.Name == name and v:FindFirstChild("Humanoid") then
            if hrp then
                if v:FindFirstChild('HumanoidRootPart') then
                    return v
                end
            else
                return v
            end
        end
    end
end

function findMob(hrp)
    for i, v in pairs(workspace.Mobs:GetChildren()) do
        if v:IsA("Folder") and v:FindFirstChildWhichIsA("Model") then   
            local model = v:FindFirstChildWhichIsA("Model")
            if model:FindFirstChild("Humanoid") and model:FindFirstChild("Humanoid").Health > 0 then
                if hrp then
                    if model:FindFirstChild('HumanoidRootPart') then
                        return model
                    end
                else
                    return model
                end
            end
        end
    end
    return
end

local function noclip()
    for i, v in pairs(client.Character:GetChildren()) do
        if v:IsA("BasePart") then
            v.CanCollide = false
        end
    end
end





local Window;
if UserInputService.TouchEnabled then
    Window = Library:CreateWindow{
        Title = 'FireScripts | Project Slayer | Dungeon',
        TabWidth = 160,
        Size = UDim2.fromOffset(600, 300);
        Resize = true, 
        MinSize = Vector2.new(235, 190),
        Acrylic = true, 
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.RightShift 
    }
    
local ScreenGui = Instance.new("ScreenGui", gethui())
local Frame = Instance.new("ImageButton", ScreenGui)
Frame.Size = UDim2.fromOffset(60, 60)
Frame.Position = UDim2.fromOffset(30, 30)
Frame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
Frame.AutoButtonColor = false

Window.Root.Active = true

Frame.MouseButton1Click:Connect(function()
	Window:Minimize()
end)


local UIS = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos

local function update(input)
	local delta = input.Position - dragStart
	Frame.Position = UDim2.new(
		startPos.X.Scale, startPos.X.Offset + delta.X,
		startPos.Y.Scale, startPos.Y.Offset + delta.Y
	)
end

Frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = Frame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

Frame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UIS.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)

else
    Window = Library:CreateWindow{
        Title = 'FireScripts | Project Slayer | Dungeon',
        TabWidth = 160,
        Size = UDim2.fromOffset(830, 525),
        Resize = true, 
        MinSize = Vector2.new(470, 380),
        Acrylic = true, 
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.RightShift 
    }
end

Window.Root.Active = true

local Tabs = {
    ["Auto Farm"] = Window:AddTab({Title = "Auto Farm", Icon = "repeat"});
    ["Kill Auras"] = Window:AddTab({Title = "Kill Auras", Icon = "sword"});
    ["Dungeon"] = Window:AddTab({Title = "Dungeon", Icon = "skull"});
    ["Orbs"] = Window:AddTab({Title = "Orbs", Icon = "circle"});
    ["Misc"] = Window:AddTab({Title = "Misc", Icon = "feather"});
    ["Buffs"] = Window:AddTab({Title = "Buffs", Icon = "shield"});
    ["Webhook settings"] = Window:AddTab({Title = "Webhook settings", Icon = "cog"});
    ["Settings"] = Window:AddTab({Title = "UI Settings", Icon = "settings"});
    ["Credits"] = Window:AddTab({Title = "Credits", Icon = "book"});
}



local weapons = {
    ["Combat"] = "fist_combat";
    ["Scythe"] = "Scythe_Combat_Slash";
    ["Sword"] = "Sword_Combat_Slash";
    ["Fans"] = "fans_combat_slash";
    ["Claws"] = "claw_Combat_Slash";
}

Tabs["Auto Farm"]:AddDropdown("dWeaponSelect", {
    Title = "Select Macro",
    Values = {"Combat", "Scythe", "Sword", "Fans", "Claws"};
    Default = "Combat",
    Multi = false,
    Callback = function(Options) 
        
    end,
})

Tabs["Auto Farm"]:AddSlider("sTweenSpeed", {
    Title = "TweenSpeed",
    Description = "This is a slider",
    Default = 400,
    Min = 100,
    Max = 500,
    Rounding = 0,
    Callback = function(Value)
    end
})

Tabs["Auto Farm"]:AddToggle("tAutoBoss", {
    Title = "Auto Tween To Mobs (Below Map)",
    Default = false,
    Callback = function(Value)
        local _conn
        local antiFall -- BodyPosition para fijar posición

        if Value then
            task.spawn(function()
                _conn = RunService.Stepped:Connect(noclip)

                -- Crea BodyPosition para forzar abajo
                antiFall = Instance.new("BodyPosition")
                antiFall.Name = "AntiFallPosition"
                antiFall.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                antiFall.P = 1e5
                antiFall.D = 1000
                antiFall.Position = client.Character.HumanoidRootPart.Position
                antiFall.Parent = client.Character.HumanoidRootPart

                while options.tAutoBoss.Value do
                    local mobs = workspace.Mobs:GetChildren()

                    if #mobs == 0 then
                        task.wait(1)
                        continue
                    end

                    for _, v in mobs do
                        local targetCFrame

                        local model = v:FindFirstChildWhichIsA("Model")
                        if model and model:FindFirstChild("HumanoidRootPart") then
                            targetCFrame = model.HumanoidRootPart.CFrame
                        else
                            local config = v:FindFirstChild("Npc_Configuration")
                            if config then
                                local spawnLoc = config:FindFirstChild("spawnlocaitonasd123")
                                if spawnLoc then
                                    targetCFrame = CFrame.new(spawnLoc.Value)
                                end
                            end
                        end

                        if targetCFrame then
                            -- Siempre debajo del mapa
                            local offsetBelowMap = CFrame.new(0, -100, 0)
                            local angle = CFrame.Angles(math.rad(-90), 0, 0)
                            local finalCFrame = targetCFrame * offsetBelowMap * angle

                            -- Tween
                            local tween = tweento(finalCFrame)
                            antiFall.Position = finalCFrame.Position

                            tween.Completed:Wait()
                            task.wait(0.3)
                        end
                    end

                    task.wait(0.2)
                end

                _conn:Disconnect()
                if antiFall then antiFall:Destroy() end

                -- Subir al desactivar
                local hrp = client.Character and client.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = hrp.CFrame + Vector3.new(0, 150, 0)
                end
            end)
        end
    end
})









Tabs["Auto Farm"]:AddToggle("tAutoM1", {
	Title = "Weapon KillAura",
	Default = false,
    Callback = function(Value)
        task.spawn(function()
            if Value then
                while options.tAutoM1.Value do
                    if not options["tGodMode"].Value then distance = 7 end
                    task.wait(0.1)
                    for i = 1, 8 do
                        game:GetService("ReplicatedStorage").Remotes.To_Server.Handle_Initiate_S:FireServer(weapons[options.dWeaponSelect.Value], client, client.Character, client.Character.HumanoidRootPart, client.Character.Humanoid, 919)
                        game:GetService("ReplicatedStorage").Remotes.To_Server.Handle_Initiate_S:FireServer(weapons[options.dWeaponSelect.Value], client, client.Character, client.Character.HumanoidRootPart, client.Character.Humanoid, math.huge)
                    end
                    task.wait(0.1)
                    if not options["tGodMode"].Value then distance = 15 end
                    task.wait(1)
                    repeat task.wait() until client.combotangasd123.Value == 0 and not playerValues:FindFirstChild("Stun")
                end
            end
        end)
    end
})

Tabs["Auto Farm"]:AddToggle("tAutoChest", {
	Title = "Auto Collect Chests",
	Default = false,
    Callback = function(Value)
        if Value then
            task.spawn(function()
                while options.tAutoChest.Value do
                    for a, b in pairs(game.Workspace.Debree:GetChildren()) do
                        if b.Name == "Loot_Chest" then
                            for c, d in pairs(b.Drops:GetChildren()) do
                                b.Add_To_Inventory:InvokeServer(d.Name)
                            end
                            b:Destroy()
                        end
                    end
                    task.wait()
                end
            end)
        end
    end
})




Tabs["Orbs"]:AddToggle("orb_DoublePoints", {
    Title = "DoublePoints",
    Default = false,
    Callback = function(Value)
        selectedorbs["DoublePoints"] = Value
    end
})

Tabs["Orbs"]:AddToggle("orb_StaminaRegen", {
    Title = "StaminaRegen",
    Default = false,
    Callback = function(Value)
        selectedorbs["StaminaRegen"] = Value
    end
})

Tabs["Orbs"]:AddToggle("orb_HealthRegen", {
    Title = "HealthRegen",
    Default = false,
    Callback = function(Value)
        selectedorbs["HealthRegen"] = Value
    end
})

Tabs["Orbs"]:AddToggle("orb_BloodMoney", {
    Title = "BloodMoney",
    Default = false,
    Callback = function(Value)
        selectedorbs["BloodMoney"] = Value
    end
})

Tabs["Orbs"]:AddToggle("orb_InstaKill", {
    Title = "InstaKill",
    Default = false,
    Callback = function(Value)
        selectedorbs["InstaKill"] = Value
    end
})

Tabs["Orbs"]:AddToggle("orb_MobCamouflage", {
    Title = "MobCamouflage",
    Default = false,
    Callback = function(Value)
        selectedorbs["MobCamouflage"] = Value
    end
})




Tabs["Dungeon"]:AddToggle("tAutoOrbs", {
    Title = "Auto Collect Orbs",
    Default = false,
    Callback = function(Value)
        autoorb = Value
        task.spawn(function()
            while autoorb do
                local oldpos = client.Character.HumanoidRootPart.CFrame
                local tped = false

                for _, v in pairs(workspace.Map:GetChildren()) do
                    if v:IsA("Model") and selectedorbs[v.Name] then
                        local tween = tweento(v:GetModelCFrame())
                        tween.Completed:Wait()
                        task.wait(0.3)
                        v:Destroy()
                        tped = true
                    end
                end

                if tped and client.Character.HumanoidRootPart:FindFirstChild("DungAntiFall") then
                    local back = tweento(oldpos)
                    back.Completed:Wait()
                end

                task.wait(1)
            end
        end)
    end
})

Tabs["Dungeon"]:AddButton({
    Title = 'Stuck In Air',
    Callback = function()
        local antifall = Instance.new("BodyVelocity")
        antifall.Velocity = Vector3.new(0, 0, 0)
        antifall.Name = "DungAntiFall"
        antifall.Parent = player.Character.HumanoidRootPart
    end
})

Tabs["Dungeon"]:AddButton({
    Title = 'Unstuck',
    Callback = function()
        player.Character.HumanoidRootPart:FindFirstChild("DungAntiFall"):Destroy()
    end
})

Tabs["Dungeon"]:AddButton({
    Title = 'Start Normal',
    Callback = function()
        local args = {
            "Normal"
        }
        game:GetService("ReplicatedStorage"):WaitForChild("TeleportCirclesEvent"):FireServer(unpack(args))
    end
})

Tabs["Dungeon"]:AddButton({
    Title = 'Start Comp',
    Callback = function()
        local args = {
            "Competitive"
        }
        game:GetService("ReplicatedStorage"):WaitForChild("TeleportCirclesEvent"):FireServer(unpack(args))
    end
})

local function createScreenCover()
    local gui = Instance.new("ScreenGui")
    gui.Name = "ScreenCover"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    gui.DisplayOrder = 999

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.Position = UDim2.new(0, 0, 0, 0)
    frame.BackgroundColor3 = Color3.new(0, 0, 0)
    frame.BackgroundTransparency = 0
    frame.ZIndex = 999
    frame.Parent = gui

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.Position = UDim2.new(0, 0, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "Top Secret\nWe Need To Keep It Private\nSorry"
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.Font = Enum.Font.GothamBlack
    textLabel.TextScaled = true
    textLabel.TextStrokeTransparency = 0.3
    textLabel.ZIndex = 1000
    textLabel.Parent = gui

    gui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    return gui
end

local function removeScreenCover()
    local playerGui = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        local cover = playerGui:FindFirstChild("ScreenCover")
        if cover then
            cover:Destroy()
        end
    end
end

Tabs["Dungeon"]:AddButton({
    Title = 'Bug Combo',
    Description = '(BETA) Currently Under Developing,If U Wanna Use It Please Ask For Tutorial On FS Support',
    Callback = function()
        local VIM = game:GetService("VirtualInputManager")
        local char = client.Character or client.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")

        -- Mostrar cover
        local cover = createScreenCover()

        -- Mantener V
        VIM:SendKeyEvent(true, Enum.KeyCode.V, false, game)
        task.wait(0.2)

        -- Activar Bring Mobs
        options["tPiercingArrow"]:SetValue(true)

        -- Esperar V
        task.wait(1.5)

        -- Soltar V
        VIM:SendKeyEvent(false, Enum.KeyCode.V, false, game)

        task.wait(3.5)

        -- Apagar Bring Mobs
        options["tPiercingArrow"]:SetValue(false)

        task.wait(2)
        -- Quitar cover
        removeScreenCover()
    end
})


Tabs["Kill Auras"]:AddSlider("sArrowKADelay2", {
    Title = "Arrow KA Damage Delay (seconds)",
    Description = "Delay between arrow hits",
    Default = 0.36,
    Min = 0.05,
    Max = 2,
    Rounding = 2,
    Callback = function(Value)
    end
})

Tabs["Kill Auras"]:AddToggle("tArrowKA", {
    Title = 'Arrow KA (Arrow BDA Is Required)',
    Default = false,
    Callback = function(Value)
        if Value then
            task.spawn(function()
                while options.tArrowKA.Value do
                    local args = {
                        [1] = "skil_ting_asd",
                        [2] = client,
                        [3] = "arrow_knock_back",
                        [4] = 5
                    }

                    game:GetService("ReplicatedStorage").Remotes.To_Server.Handle_Initiate_S_:InvokeServer(unpack(args))
                    task.wait(6)
                end
            end)
            task.spawn(function()
                while options.tArrowKA.Value do 
                    local target = findMob(true)
                    if target then
                        local args = {
                            [1] = "arrow_knock_back_damage",
                            [2] = client.Character,
                            [3] = target:GetModelCFrame(),
                            [4] = target,
                            [5] = math.huge,
                            [6] = math.huge
                        }

                        game:GetService("ReplicatedStorage").Remotes.To_Server.Handle_Initiate_S:FireServer(unpack(args))
                    end
                    task.wait(options["sArrowKADelay2"].Value)
                end
            end)
        end
    end
})


Tabs["Kill Auras"]:AddToggle("tPiercingArrow", {
    Title = 'Bring Mobs',
    Description = 'Arrow BDA Is Required',
    Default = false,
    Callback = function(Value)
        if Value then
            task.spawn(function()
                while options.tPiercingArrow.Value do 
                    local target = findMob(true)
                    if target then
                        repeat task.wait()
                            local args = {
                                [1] = "piercing_arrow_damage",
                                [2] = client,
                                [3] = target:GetModelCFrame(),
                                [4] = math.huge
                            }
                            game:GetService("ReplicatedStorage").Remotes.To_Server.Handle_Initiate_S_:InvokeServer(unpack(args))
                        until target.Humanoid.Health <= 0 or not options.tPiercingArrow.Value
                    end
                    task.wait()
                end
            end)
            task.spawn(function()
                while options.tPiercingArrow.Value do
                    local args = {
                        [1] = "skil_ting_asd",
                        [2] = client,
                        [3] = "arrow_knock_back",
                        [4] = 5
                    }
                    game:GetService("ReplicatedStorage").Remotes.To_Server.Handle_Initiate_S_:InvokeServer(unpack(args))
                    task.wait(6)
                end
            end)
        end
    end
})

local VIM = game:GetService("VirtualInputManager")
local client = game.Players.LocalPlayer

Tabs["Misc"]:AddToggle("tAntiAFK", {
    Title = "Anti-AFK (Global)",
    Default = true,
    Callback = function(Value)
        if Value then
            task.spawn(function()
                local char = client.Character or client.CharacterAdded:Wait()
                local hrp = char:WaitForChild("HumanoidRootPart")

                while options.tAntiAFK.Value do
                    -- Saltito para simular actividad
                    VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                    task.wait(0.05)
                    VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)

                    -- Movimiento leve del mouse
                    VIM:SendMouseMoveEvent(math.random(-5, 5), math.random(-5, 5), false)

                    -- Click falso
                    VIM:SendMouseButtonEvent(0, 1, true, game, 0)
                    task.wait(0.1)
                    VIM:SendMouseButtonEvent(0, 1, false, game, 0)

                    -- Esperar un tiempo aleatorio para simular mejor
                    task.wait(math.random(25, 40))
                end
            end)
        end
    end
})



local skillMod = require(game:GetService("ReplicatedStorage").Modules.Server.Skills_Modules_Handler).Skills
local gmSkills = {
    "scythe_asteroid_reap";
    "Water_Surface_Slash";
    "insect_breathing_dance_of_the_centipede";
    "blood_burst_explosive_choke_slam";
    "Wind_breathing_black_wind_mountain_mist";
    "snow_breatihng_layers_frost";
    "flame_breathing_flaming_eruption";
    "Beast_breathing_devouring_slash";
    "akaza_flashing_williow_skillasd";
    "dream_bda_flesh_monster";
    "swamp_bda_swamp_domain";
    "sound_breathing_smoke_screen";
    "ice_demon_art_bodhisatva";
}
local newtbl = {}
for i, v in gmSkills do
	for a, b in game:GetService("Players").LocalPlayer.PlayerGui.Power_Adder:GetChildren() do
		if b:IsA("Configuration") and b.Mastery_Equiped.Value == skillMod[v]["Mastery"] then
			for c, d in b["Skills"]:GetChildren() do
				if d.Actual_Skill_Name.Value == v then
					table.insert(newtbl, string.format('%s -- %s', tostring(skillMod[v]["Mastery"]), tostring(d:FindFirstChild("Locked_Txt") and"Ult Unlocked" or string.format('Mas %s', tostring(skillMod[v]["MasteryNeed"])))))
				end
			end
		end
	end
end

Tabs["Buffs"]:AddDropdown("dGodMode", {
    Title = "Select Method",
    Values = newtbl;
    Default = nil,
    Multi = false
})

Tabs["Buffs"]:AddToggle("tGodMode", {
    Title = "Toggle God Mode",
    Default = false,
    Callback = function(Value)
        if Value then
            task.spawn(function()
                distance = 6
                while options["tGodMode"].Value do
                    local skillName = gmSkills[table.find(newtbl, options["dGodMode"].Value)]
                    local args = {
                        [1] = "skil_ting_asd",
                        [2] = client,
                        [3] = skillName,
                        [4] = 1
                    }
                    
                    game:GetService("ReplicatedStorage").Remotes.To_Server.Handle_Initiate_S:FireServer(unpack(args))  
                    task.wait(skillMod[skillName]["addiframefor"])
                end
                distance = 7
            end)
        end
    end
})

Tabs["Buffs"]:AddToggle("tWarDrum", {
    Title = "War Drum Buff",
    Default = false,
    Callback = function(Value)
        if Value then
            task.spawn(function()
                while options["tWarDrum"].Value do
                    game:GetService("ReplicatedStorage").Remotes.war_Drums_remote:FireServer(true)
                    task.wait(20)
                end
            end)
        end
    end
})
options["tWarDrum"]:SetValue(true)

Tabs["Buffs"]:AddToggle("tSunImm", {
    Title = "Sun Immunity",
    Default = true,
    Callback = function(Value)
        client.PlayerScripts.Small_Scripts.Gameplay.Sun_Damage.Disabled = Value
    end
})

Tabs["Buffs"]:AddToggle("theartabl", {
    Title = "Heart Ablaze (Only Human)",
    Default = false,
    Callback = function(Value)
        if Value then
            game:GetService("ReplicatedStorage").Remotes.heart_ablaze_mode_remote:FireServer(true)
        else
            game:GetService("ReplicatedStorage").Remotes.heart_ablaze_mode_remote:FireServer(false)
        end
    end
})


Tabs["Buffs"]:AddToggle("tgodspeed", {
	Title = "GodSpeed (Only Human)",
	Default = false,
	Callback = function(Value)
	    if Value then
	       game:GetService("ReplicatedStorage").Remotes.thundertang123:FireServer(true)
        else
            game:GetService("ReplicatedStorage").Remotes.thundertang123:FireServer(false)
        end
    end
    })

Tabs["Buffs"]:AddToggle("tgodspeed", {
	Title = "KamadoGod (Only Kamado Clan)",
	Default = false,
	Callback = function(Value)
	    if Value then
	       game:GetService("ReplicatedStorage").Remotes.heal_tang123asd:FireServer(true)
        else
            game:GetService("ReplicatedStorage").Remotes.heal_tang123asd:FireServer(false)
        end
    end
    })

SaveManager:SetLibrary(Library)
SaveManager:SetFolder("FireScripts")
SaveManager:BuildConfigSection(Tabs["Settings"])
Tabs["Settings"]:AddToggle("tAutoExec", {
    Title = "Auto Execute Script On Rejoin";
    Default = true;
    Callback = function(Value)
        getgenv().AutoExecCloudy = Value
    end
})
SaveManager:LoadAutoloadConfig()

Window:SelectTab(1)
Tabs["Credits"]:AddParagraph({
  Title = "Credits",
  Content = "Developed by Ninja974\n" .. version .. "\nEnjoy Fire Scripts!"
})

Tabs["Credits"]:AddButton({
  Title = "Copy Discord Invite!",
  Callback = function()
    setclipboard("https://discord.com/invite/ry9e3kSb3A")
    Library:Notify({
      Title = "Copied!",
      Content = "Discord invite copied to clipboard.",
      Duration = 4
    })
  end
})
