--[[
    =============================================
    Survive Disaster for Brainrots and Fish!
    Script by: Chat AI (Deep Flow)
    Platform: Android (Mobile Executor)
    GitHub Ready
    =============================================
    Features:
    1. Auto Farm (Coins)
    2. Auto Rebirth
    3. Remove/Dodge Disaster
    4. Mobile GUI
    =============================================
]]

-- // Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- // Settings
local Settings = {
    AutoFarm = false,
    AutoRebirth = false,
    RemoveDisaster = false,
    FarmSpeed = 0.1,
    SafeZonePosition = Vector3.new(0, 50, 0) -- fallback safe zone
}

-- // Reconnect on respawn
Player.CharacterAdded:Connect(function(char)
    Character = char
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
    Humanoid = char:WaitForChild("Humanoid")
    task.wait(1)
end)

-- =============================================
-- // MOBILE GUI
-- =============================================
local function CreateGUI()
    -- Destroy old GUI if exists
    if Player.PlayerGui:FindFirstChild("DisasterHub") then
        Player.PlayerGui:FindFirstChild("DisasterHub"):Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "DisasterHub"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = Player.PlayerGui

    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 260, 0, 280)
    MainFrame.Position = UDim2.new(0.5, -130, 0.5, -140)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = MainFrame

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(100, 50, 255)
    UIStroke.Thickness = 2
    UIStroke.Parent = MainFrame

    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame

    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 10)
    TitleCorner.Parent = TitleBar

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -40, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "🌪️ Disaster Hub"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 16
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleBar

    -- Minimize Button
    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 30, 0, 30)
    MinBtn.Position = UDim2.new(1, -35, 0, 5)
    MinBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
    MinBtn.Text = "−"
    MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinBtn.TextSize = 18
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.BorderSizePixel = 0
    MinBtn.Parent = TitleBar

    local MinCorner = Instance.new("UICorner")
    MinCorner.CornerRadius = UDim.new(0, 6)
    MinCorner.Parent = MinBtn

    -- Content Frame
    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -20, 1, -55)
    Content.Position = UDim2.new(0, 10, 0, 48)
    Content.BackgroundTransparency = 1
    Content.Parent = MainFrame

    local UIList = Instance.new("UIListLayout")
    UIList.Padding = UDim.new(0, 8)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Parent = Content

    -- Toggle Button Creator
    local function CreateToggle(name, order, callback)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Size = UDim2.new(1, 0, 0, 45)
        ToggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        ToggleFrame.BorderSizePixel = 0
        ToggleFrame.LayoutOrder = order
        ToggleFrame.Parent = Content

        local TC = Instance.new("UICorner")
        TC.CornerRadius = UDim.new(0, 8)
        TC.Parent = ToggleFrame

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -70, 1, 0)
        Label.Position = UDim2.new(0, 12, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = name
        Label.TextColor3 = Color3.fromRGB(220, 220, 220)
        Label.TextSize = 14
        Label.Font = Enum.Font.GothamSemibold
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = ToggleFrame

        local ToggleBtn = Instance.new("TextButton")
        ToggleBtn.Size = UDim2.new(0, 50, 0, 26)
        ToggleBtn.Position = UDim2.new(1, -60, 0.5, -13)
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
        ToggleBtn.Text = "OFF"
        ToggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        ToggleBtn.TextSize = 12
        ToggleBtn.Font = Enum.Font.GothamBold
        ToggleBtn.BorderSizePixel = 0
        ToggleBtn.Parent = ToggleFrame

        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 6)
        BtnCorner.Parent = ToggleBtn

        local toggled = false
        ToggleBtn.MouseButton1Click:Connect(function()
            toggled = not toggled
            if toggled then
                ToggleBtn.Text = "ON"
                ToggleBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
                ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 40)
            else
                ToggleBtn.Text = "OFF"
                ToggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
                ToggleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
            end
            callback(toggled)
        end)

        return ToggleBtn
    end

    -- Create Toggles
    CreateToggle("💰 Auto Farm", 1, function(state)
        Settings.AutoFarm = state
    end)

    CreateToggle("🔄 Auto Rebirth", 2, function(state)
        Settings.AutoRebirth = state
    end)

    CreateToggle("🛡️ Remove Disaster", 3, function(state)
        Settings.RemoveDisaster = state
    end)

    -- Status Label
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, 0, 0, 30)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "Status: Idle"
    StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 180)
    StatusLabel.TextSize = 12
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.LayoutOrder = 4
    StatusLabel.Parent = Content

    -- Minimize/Maximize Logic
    local minimized = false
    local OpenBtn = Instance.new("TextButton")
    OpenBtn.Size = UDim2.new(0, 50, 0, 50)
    OpenBtn.Position = UDim2.new(0, 10, 0.5, -25)
    OpenBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 255)
    OpenBtn.Text = "🌪️"
    OpenBtn.TextSize = 22
    OpenBtn.BorderSizePixel = 0
    OpenBtn.Visible = false
    OpenBtn.Parent = ScreenGui
    OpenBtn.Draggable = true

    local OpenCorner = Instance.new("UICorner")
    OpenCorner.CornerRadius = UDim.new(0, 25)
    OpenCorner.Parent = OpenBtn

    MinBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
        OpenBtn.Visible = true
    end)

    OpenBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = true
        OpenBtn.Visible = false
    end)

    return StatusLabel
end

local StatusLabel = CreateGUI()

-- =============================================
-- // CORE FUNCTIONS
-- =============================================

-- Helper: Safe teleport using tween
local function TweenTo(position)
    if not HumanoidRootPart or not HumanoidRootPart.Parent then return end
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(HumanoidRootPart, tweenInfo, {CFrame = CFrame.new(position)})
    tween:Play()
    tween.Completed:Wait()
end

-- Find coins/collectibles in workspace
local function GetCollectibles()
    local collectibles = {}
    
    -- Common folder names for collectibles in disaster games
    local searchFolders = {"Coins", "Collectibles", "Drops", "Items", "Orbs", "Cash", "Money"}
    
    for _, folderName in ipairs(searchFolders) do
        local folder = Workspace:FindFirstChild(folderName)
        if folder then
            for _, item in ipairs(folder:GetChildren()) do
                if item:IsA("BasePart") or item:IsA("Model") then
                    table.insert(collectibles, item)
                end
            end
        end
    end
    
    -- Also search for TouchInterest parts (clickable/touchable items)
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("TouchTransmitter") and obj.Parent and obj.Parent:IsA("BasePart") then
            table.insert(collectibles, obj.Parent)
        end
    end
    
    return collectibles
end

-- Get nearest collectible
local function GetNearest(collectibles)
    local nearest = nil
    local nearestDist = math.huge
    local playerPos = HumanoidRootPart.Position
    
    for _, item in ipairs(collectibles) do
        if item and item.Parent then
            local pos
            if item:IsA("Model") then
                local primary = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
                if primary then pos = primary.Position end
            elseif item:IsA("BasePart") then
                pos = item.Position
            end
            
            if pos then
                local dist = (pos - playerPos).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearest = item
                    end
            end
        end
    end
    
    return nearest, nearestDist
end

-- Fire touch interest
local function TouchPart(part)
    if not part or not part.Parent then return end
    firetouchinterest(HumanoidRootPart, part, 0)
    task.wait()
    firetouchinterest(HumanoidRootPart, part, 1)
end

-- =============================================
-- // AUTO FARM
-- =============================================
local function AutoFarmLoop()
    while task.wait(Settings.FarmSpeed) do
        if Settings.AutoFarm and Character and HumanoidRootPart and HumanoidRootPart.Parent then
            pcall(function()
                local collectibles = GetCollectibles()
                local nearest, dist = GetNearest(collectibles)
                
                if nearest then
                    local targetPos
                    if nearest:IsA("Model") then
                        local primary = nearest.PrimaryPart or nearest:FindFirstChildWhichIsA("BasePart")
                        if primary then targetPos = primary.Position end
                    elseif nearest:IsA("BasePart") then
                        targetPos = nearest.Position
                    end
                    
                    if targetPos then
                        TweenTo(targetPos)
                        
                        -- Try to touch/collect
                        if nearest:IsA("BasePart") then
                            TouchPart(nearest)
                        elseif nearest:IsA("Model") then
                            for _, p in ipairs(nearest:GetDescendants()) do
                                if p:IsA("BasePart") then
                                    TouchPart(p)
                                    break
                                end
                            end
                        end
                    end
                    
                    if StatusLabel then
                        StatusLabel.Text = "Status: Farming... (" .. #collectibles .. " items)"
                    end
                else
                    if StatusLabel then
                        StatusLabel.Text = "Status: Searching for items..."
                    end
                end
            end)
        end
    end
end

-- =============================================
-- // AUTO REBIRTH
-- =============================================
local function AutoRebirthLoop()
    while task.wait(1) do
        if Settings.AutoRebirth then
            pcall(function()
                -- Method 1: Remote Events
                local remotes = ReplicatedStorage:GetDescendants()
                for _, remote in ipairs(remotes) do
                    if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                        local name = remote.Name:lower()
                        if name:find("rebirth") or name:find("reborn") or name:find("prestige") or name:find("reset") then
                            if remote:IsA("RemoteEvent") then
                                remote:FireServer()
                            elseif remote:IsA("RemoteFunction") then
                                pcall(function()
                                    remote:InvokeServer()
                                end)
                            end
                            
                            if StatusLabel then
                                StatusLabel.Text = "Status: Rebirth triggered!"
                            end
                        end
                    end
                end
                
                -- Method 2: Click rebirth buttons in GUI
                for _, gui in ipairs(Player.PlayerGui:GetDescendants()) do
                    if gui:IsA("TextButton") or gui:IsA("ImageButton") then
                        local txt = ""
                        if gui:IsA("TextButton") then txt = gui.Text:lower() end
                        if gui.Name:lower():find("rebirth") or txt:find("rebirth") then
                            -- Simulate GUI button press
                            pcall(function()
                                gui.Visible = true
                                fireclick(gui)
                            end)
                        end
                    end
                end
            end)
        end
    end
end

-- =============================================
-- // REMOVE DISASTER
-- =============================================
local function RemoveDisasterLoop()
    while task.wait(0.5) do
        if Settings.RemoveDisaster then
            pcall(function()
                -- Common disaster-related keywords
                local disasterKeywords = {
                    "disaster", "flood", "fire", "tornado", "meteor",
                    "earthquake", "tsunami", "lava", "acid", "bomb",
                    "explosion", "lightning", "storm", "boulder", "spike",
                    "danger", "hazard", "kill", "damage", "harmful",
                    "poison", "nuke", "sandstorm", "blizzard", "volcano"
                }
                
                local removed = 0
                
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") or obj:IsA("Model") then
                        local objName = obj.Name:lower()
                        for _, keyword in ipairs(disasterKeywords) do
                            if objName:find(keyword) then
                                -- Don't remove the safe zone or map
                                if not objName:find("safe") and not objName:find("spawn") and not objName:find("lobby") then
                                    pcall(function()
                                        if obj:IsA("BasePart") then
                                            obj.CanCollide = false
                                            obj.Transparency = 1
                                            obj.Size = Vector3.new(0, 0, 0)
                                            obj.Position = Vector3.new(0, -500, 0)
                                        elseif obj:IsA("Model") then
                                            obj:Destroy()
                                        end
                                        removed = removed + 1
                                    end)
                                end
                                break
                            end
                        end
                    end
                end
                
                -- Also remove parts that deal damage (TouchInterest with damage scripts)
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("Script") or obj:IsA("LocalScript") then
                        local src = ""
                        pcall(function() src = obj.Source:lower() end)
                        if src:find("damage") or src:find("kill") or src:find("health") then
                            pcall(function()
                                obj.Disabled = true
                            end)
                        end
                    end
                end
                
                if StatusLabel and removed > 0 then
                    StatusLabel.Text = "Status: Removed " .. removed .. " disaster objects"
                end
            end)
        end
    end
end

-- =============================================
-- // ANTI-DEATH (Bonus Safety Feature)
-- =============================================
local function AntiDeathLoop()
    while task.wait(0.1) do
        pcall(function()
            if Character and Humanoid and Humanoid.Parent then
                if Settings.RemoveDisaster then
                    -- Keep health maxed when remove disaster is on
                    if Humanoid.Health < Humanoid.MaxHealth then
                        Humanoid.Health = Humanoid.MaxHealth
                    end
                end
            end
        end)
    end
end

-- =============================================
-- // START ALL LOOPS
-- =============================================
task.spawn(AutoFarmLoop)
task.spawn(AutoRebirthLoop)
task.spawn(RemoveDisasterLoop)
task.spawn(AntiDeathLoop)

-- =============================================
-- // NOTIFICATION
-- =============================================
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "🌪️ Disaster Hub",
        Text = "Script loaded! Drag the GUI to move it.",
        Duration = 5
    })
end)

print("[Disaster Hub] Script loaded successfully!")
print("[Disaster Hub] Game: Survive Disaster for Brainrots and Fish!")
print("[Disaster Hub] Features: Auto Farm | Auto Rebirth | Remove Disaster")
