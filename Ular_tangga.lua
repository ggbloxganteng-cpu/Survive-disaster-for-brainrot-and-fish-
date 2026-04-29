-- ============================================================
-- Ular Tangga Script by Dhany
-- Game: Ular Tangga by Shinji Sho (Roblox)
-- Features: Auto Win, Auto Roll, Teleport, God Mode, Anti Ular,
--           Always Ladder, Infinite Turn, Speed Hack, GUI Modern
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- ============================================================
-- SETTINGS
-- ============================================================
local Settings = {
    AutoRoll      = false,
    AutoWin       = false,
    AntiUlar      = false,
    AlwaysLadder  = false,
    InfiniteTurn  = false,
    SpeedHack     = false,
    GodMode       = false,
    TeleportWin   = false,
    WalkSpeed     = 100,
    RollDelay     = 1.0,
}

-- ============================================================
-- UTILITIES
-- ============================================================
local function Notify(msg)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "🎲 Ular Tangga Script",
        Text  = msg,
        Duration = 3,
    })
end

local function SafeCall(fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then warn("[UlarTangga] " .. tostring(err)) end
end

local function Tween(obj, props, duration)
    TweenService:Create(obj, TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
end

local function FindRemote(keyword)
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if (v:IsA("RemoteEvent") or v:IsA("RemoteFunction")) then
            if v.Name:lower():find(keyword:lower()) then
                return v
            end
        end
    end
    for _, v in pairs(Workspace:GetDescendants()) do
        if (v:IsA("RemoteEvent") or v:IsA("RemoteFunction")) then
            if v.Name:lower():find(keyword:lower()) then
                return v
            end
        end
    end
    return nil
end

local function FireRemote(remote, ...)
    if not remote then return end
    SafeCall(function()
        if remote:IsA("RemoteEvent") then
            remote:FireServer(...)
        elseif remote:IsA("RemoteFunction") then
            remote:InvokeServer(...)
        end
    end)
end

local function FindWinTile()
    for _, obj in pairs(Workspace:GetDescendants()) do
        local n = obj.Name:lower()
        if n:find("finish") or n:find("win") or n:find("goal") or n:find("100") or n:find("end") then
            if obj:IsA("BasePart") or obj:IsA("Model") then
                local part = obj:IsA("Model") and
                    (obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart"))
                    or obj
                return part
            end
        end
    end
end

-- ============================================================
-- AUTO ROLL
-- ============================================================
task.spawn(function()
    while true do
        task.wait(Settings.RollDelay)
        if Settings.AutoRoll then
            SafeCall(function()
                local rollRemote = FindRemote("roll")
                    or FindRemote("dice")
                    or FindRemote("dadu")
                    or FindRemote("turn")
                    or FindRemote("play")
                if rollRemote then
                    FireRemote(rollRemote)
                else
                    -- Fallback: cari tombol roll di GUI
                    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                    if playerGui then
                        for _, gui in pairs(playerGui:GetDescendants()) do
                            if gui:IsA("TextButton") or gui:IsA("ImageButton") then
                                local n = gui.Name:lower()
                                if n:find("roll") or n:find("dice") or n:find("dadu") or n:find("play") then
                                    gui.MouseButton1Click:Fire()
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ============================================================
-- AUTO WIN (Teleport ke finish)
-- ============================================================
task.spawn(function()
    while true do
        task.wait(0.5)
        if Settings.AutoWin or Settings.TeleportWin then
            SafeCall(function()
                -- Coba remote win dulu
                local winRemote = FindRemote("win")
                    or FindRemote("finish")
                    or FindRemote("complete")
                if winRemote then
                    FireRemote(winRemote)
                end
                -- Teleport ke tile finish
                local winTile = FindWinTile()
                if winTile then
                    HumanoidRootPart.CFrame = winTile.CFrame + Vector3.new(0, 3, 0)
                    Notify("Teleport ke finish! 🏆")
                end
            end)
        end
    end
end)

-- ============================================================
-- ANTI ULAR (Block snake remote)
-- ============================================================
local snakeBlocked = false
task.spawn(function()
    while true do
        task.wait(0.1)
        if Settings.AntiUlar and not snakeBlocked then
            snakeBlocked = true
            SafeCall(function()
                -- Hook remote ular dan block
                for _, v in pairs(ReplicatedStorage:GetDescendants()) do
                    if v:IsA("RemoteEvent") then
                        local n = v.Name:lower()
                        if n:find("snake") or n:find("ular") or n:find("down") or n:find("fall") then
                            -- Override dengan metatable hook
                            local oldFire = v.OnClientEvent
                            v.OnClientEvent:Connect(function(...)
                                -- Block event ular
                                return
                            end)
                        end
                    end
                end
            end)
        end
    end
end)

-- ============================================================
-- ALWAYS LADDER (Selalu dapat tangga)
-- ============================================================
task.spawn(function()
    while true do
        task.wait(0.3)
        if Settings.AlwaysLadder then
            SafeCall(function()
                local ladderRemote = FindRemote("ladder")
                    or FindRemote("tangga")
                    or FindRemote("up")
                    or FindRemote("climb")
                if ladderRemote then
                    FireRemote(ladderRemote)
                end
                -- Cari tile tangga dan teleport ke atasnya
                for _, obj in pairs(Workspace:GetDescendants()) do
                    local n = obj.Name:lower()
                    if n:find("ladder") or n:find("tangga") then
                        local part = obj:IsA("Model") and
                            (obj:FindFirstChild("Top") or obj:FindFirstChildWhichIsA("BasePart"))
                            or obj
                        if part and part:IsA("BasePart") then
                            HumanoidRootPart.CFrame = part.CFrame + Vector3.new(0, 3, 0)
                            task.wait(0.1)
                            break
                        end
                    end
                end
            end)
        end
    end
end)

-- ============================================================
-- INFINITE TURN
-- ============================================================
task.spawn(function()
    while true do
        task.wait(0.2)
        if Settings.InfiniteTurn then
            SafeCall(function()
                local turnRemote = FindRemote("turn")
                    or FindRemote("extra")
                    or FindRemote("again")
                if turnRemote then
                    FireRemote(turnRemote)
                end
            end)
        end
    end
end)

-- ============================================================
-- SPEED HACK
-- ============================================================
local function ApplySpeedHack(active)
    SafeCall(function()
        if active then
            Humanoid.WalkSpeed = Settings.WalkSpeed
            Notify("Speed Hack ON ⚡ | Speed: " .. Settings.WalkSpeed)
        else
            Humanoid.WalkSpeed = 16
            Notify("Speed Hack OFF")
        end
    end)
end

-- ============================================================
-- GOD MODE
-- ============================================================
local godConn
local function ApplyGodMode(active)
    SafeCall(function()
        if active then
            Humanoid.MaxHealth = math.huge
            Humanoid.Health = math.huge
            godConn = RunService.Heartbeat:Connect(function()
                if Humanoid then
                    Humanoid.Health = Humanoid.MaxHealth
                end
            end)
            Notify("God Mode ON 🛡️")
        else
            if godConn then godConn:Disconnect() godConn = nil end
            Humanoid.MaxHealth = 100
            Humanoid.Health = 100
            Notify("God Mode OFF")
        end
    end)
end

-- ============================================================
-- GUI
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UlarTanggaGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 520)
MainFrame.Position = UDim2.new(0, 20, 0.5, -260)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 14, 10)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)

local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Color = Color3.fromRGB(50, 200, 80)
Stroke.Thickness = 1.5
Stroke.Transparency = 0.3

-- Shadow
local Shadow = Instance.new("ImageLabel")
Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow.BackgroundTransparency = 1
Shadow.Position = UDim2.new(0.5, 0, 0.5, 10)
Shadow.Size = UDim2.new(1, 40, 1, 40)
Shadow.ZIndex = -1
Shadow.Image = "rbxassetid://6014261993"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.5
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(49, 49, 450, 450)
Shadow.Parent = MainFrame

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 52)
Header.BackgroundColor3 = Color3.fromRGB(12, 22, 12)
Header.BorderSizePixel = 0
Header.Parent = MainFrame
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 16)

local HeaderFix = Instance.new("Frame")
HeaderFix.Size = UDim2.new(1, 0, 0, 16)
HeaderFix.Position = UDim2.new(0, 0, 1, -16)
HeaderFix.BackgroundColor3 = Color3.fromRGB(12, 22, 12)
HeaderFix.BorderSizePixel = 0
HeaderFix.Parent = Header

local Title = Instance.new("TextLabel")
Title.Text = "🎲  Ular Tangga Script"
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 16, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- Minimize
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 26, 0, 26)
MinBtn.BackgroundColor3 = Color3.fromRGB(20, 40, 20)
MinBtn.Text = "−"
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 16
MinBtn.TextColor3 = Color3.fromRGB(100, 255, 120)
MinBtn.BorderSizePixel = 0
MinBtn.Parent = MainFrame
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 8)
MinBtn.Position = UDim2.new(1, -36, 0, 13)

-- Credit
local Sub = Instance.new("TextLabel")
Sub.Text = "by Dhany  •  Shinji Sho"
Sub.Size = UDim2.new(1, -16, 0, 14)
Sub.Position = UDim2.new(0, 16, 0, 54)
Sub.BackgroundTransparency = 1
Sub.Font = Enum.Font.Gotham
Sub.TextSize = 10
Sub.TextColor3 = Color3.fromRGB(50, 120, 60)
Sub.TextXAlignment = Enum.TextXAlignment.Left
Sub.Parent = MainFrame

-- Content
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, 0, 1, -72)
Content.Position = UDim2.new(0, 0, 0, 72)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

local UIList = Instance.new("UIListLayout", Content)
UIList.Padding = UDim.new(0, 7)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local UIPad = Instance.new("UIPadding", Content)
UIPad.PaddingLeft = UDim.new(0, 12)
UIPad.PaddingRight = UDim.new(0, 12)
UIPad.PaddingTop = UDim.new(0, 6)

-- ============================================================
-- TOGGLE BUILDER
-- ============================================================
local function MakeToggle(labelText, icon, settingKey, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 46)
    Row.BackgroundColor3 = Color3.fromRGB(14, 20, 14)
    Row.BorderSizePixel = 0
    Row.Parent = Content
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 10)

    local Icon = Instance.new("TextLabel")
    Icon.Text = icon
    Icon.Size = UDim2.new(0, 30, 1, 0)
    Icon.Position = UDim2.new(0, 10, 0, 0)
    Icon.BackgroundTransparency = 1
    Icon.Font = Enum.Font.Gotham
    Icon.TextSize = 18
    Icon.TextColor3 = Color3.fromRGB(255,255,255)
    Icon.Parent = Row

    local Label = Instance.new("TextLabel")
    Label.Text = labelText
    Label.Size = UDim2.new(1, -96, 1, 0)
    Label.Position = UDim2.new(0, 46, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 13
    Label.TextColor3 = Color3.fromRGB(180, 230, 180)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(0, 44, 0, 22)
    Track.Position = UDim2.new(1, -54, 0.5, -11)
    Track.BackgroundColor3 = Color3.fromRGB(30, 50, 30)
    Track.BorderSizePixel = 0
    Track.Parent = Row
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 16, 0, 16)
    Knob.Position = UDim2.new(0, 3, 0.5, -8)
    Knob.BackgroundColor3 = Color3.fromRGB(80, 140, 80)
    Knob.BorderSizePixel = 0
    Knob.Parent = Track
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    local state = Settings[settingKey]

    local function Refresh()
        if state then
            Tween(Track, {BackgroundColor3 = Color3.fromRGB(40, 200, 70)}, 0.18)
            Tween(Knob, {Position = UDim2.new(0, 25, 0.5, -8), BackgroundColor3 = Color3.fromRGB(255,255,255)}, 0.18)
            Tween(Row, {BackgroundColor3 = Color3.fromRGB(16, 28, 16)}, 0.18)
        else
            Tween(Track, {BackgroundColor3 = Color3.fromRGB(30, 50, 30)}, 0.18)
            Tween(Knob, {Position = UDim2.new(0, 3, 0.5, -8), BackgroundColor3 = Color3.fromRGB(80,140,80)}, 0.18)
            Tween(Row, {BackgroundColor3 = Color3.fromRGB(14, 20, 14)}, 0.18)
        end
    end
    Refresh()

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""
    Btn.Parent = Row

    Btn.MouseButton1Click:Connect(function()
        state = not state
        Settings[settingKey] = state
        Refresh()
        if callback then SafeCall(callback, state) end
        Notify(labelText .. ": " .. (state and "ON ✅" or "OFF ❌"))
    end)
end

-- ============================================================
-- BUILD TOGGLES
-- ============================================================
MakeToggle("Auto Roll Dadu",   "🎲", "AutoRoll",     function(v) end)
MakeToggle("Auto Win",         "🏆", "AutoWin",      function(v) end)
MakeToggle("Teleport Finish",  "🚀", "TeleportWin",  function(v) end)
MakeToggle("Anti Ular",        "🐍", "AntiUlar",     function(v) end)
MakeToggle("Always Ladder",    "🪜", "AlwaysLadder", function(v) end)
MakeToggle("Infinite Turn",    "♾️", "InfiniteTurn", function(v) end)
MakeToggle("Speed Hack",       "⚡", "SpeedHack",    ApplySpeedHack)
MakeToggle("God Mode",         "🛡️", "GodMode",      ApplyGodMode)

-- ============================================================
-- MINIMIZE + DRAG
-- ============================================================
local minimized = false
local fullH = 520
local miniH = 52

MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        Content.Visible = false
        Sub.Visible = false
        Tween(MainFrame, {Size = UDim2.new(0, 300, 0, miniH)}, 0.25)
        MinBtn.Text = "+"
    else
        Content.Visible = true
        Sub.Visible = true
        Tween(MainFrame, {Size = UDim2.new(0, 300, 0, fullH)}, 0.25)
        MinBtn.Text = "−"
    end
end)

local dragging, dragStart, startPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
       or input.UserInputType == Enum.UserInputType.Touch then
        dragging  = true
        dragStart = input.Position
        startPos  = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
       or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- ============================================================
-- DONE
-- ============================================================
Notify("Ular Tangga Script Ready! 🎲")
