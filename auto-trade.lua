-- Auto Trade Script for Steal a Brainrot (Volt)
-- Fully automatic, trigger-based
-- Accept: when Trade Request appears
-- Ready/Confirm: when ReadyButton turns GREEN (BackgroundColor3 G > 140)

local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local VIM = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local guiInset = GuiService:GetGuiInset()

local function clickElement(element)
    if not element then return end
    local pos = element.AbsolutePosition
    local size = element.AbsoluteSize
    local x = pos.X + size.X / 2
    local y = pos.Y + size.Y / 2 + guiInset.Y

    -- VirtualInputManager mouse click
    pcall(function()
        VIM:SendMouseButtonEvent(x, y, 0, true, game, 1)
        task.wait(0.05)
        VIM:SendMouseButtonEvent(x, y, 0, false, game, 1)
    end)

    -- firesignal backup
    pcall(function()
        firesignal(element.MouseButton1Click)
    end)
    pcall(function()
        firesignal(element.MouseButton1Down)
        task.wait(0.05)
        firesignal(element.MouseButton1Up)
    end)
end

local function findByName(parent, className, name)
    for _, desc in ipairs(parent:GetDescendants()) do
        if desc:IsA(className) and desc.Name == name and desc.Visible then
            return desc
        end
    end
    return nil
end

-- Check if button is GREEN (G channel > 140, means opponent ready / can click)
local function isGreen(element)
    if not element then return false end
    local color = element.BackgroundColor3
    local g = math.floor(color.G * 255)
    local r = math.floor(color.R * 255)
    return g > 140 and g > r + 20
end

print("=============================================")
print("[Auto Trade] Script loaded! (Volt)")
print("[Auto Trade] Trigger: click when button turns GREEN")
print("[Auto Trade] Auto Accept + Ready + Confirm: ON")
print("=============================================")

-- Watch for ReadyButton color change
local function watchReadyButton(tlt)
    local readyBtn = findByName(tlt, "ImageButton", "ReadyButton")
    if not readyBtn then return end

    readyBtn:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
        if isGreen(readyBtn) then
            print("[Auto Trade] ReadyButton turned GREEN -> clicking!")
            task.wait(0.2)
            clickElement(readyBtn)
        end
    end)
end

-- Set up watcher when TradeLiveTrade appears
PlayerGui.ChildAdded:Connect(function(child)
    if child.Name == "TradeLiveTrade" then
        task.wait(0.5)
        pcall(function() watchReadyButton(child) end)
    end
end)

-- Set up watcher if TradeLiveTrade already exists
local existing = PlayerGui:FindFirstChild("TradeLiveTrade")
if existing then
    pcall(function() watchReadyButton(existing) end)
end

-- Polling loop for Accept + backup Ready check
while task.wait(0.5) do
    pcall(function()
        -- STAGE 1: Accept trade request
        local dmp = PlayerGui:FindFirstChild("DuelsMachinePrompt")
        if dmp then
            local yesBtn = findByName(dmp, "ImageButton", "Yes")
            if yesBtn then
                clickElement(yesBtn)
                task.wait(0.5)
            end
        end

        local tp = PlayerGui:FindFirstChild("TradePrompts")
        if tp then
            local yesBtn = findByName(tp, "ImageButton", "Yes")
            if yesBtn then
                clickElement(yesBtn)
                task.wait(0.5)
            end
        end

        -- STAGE 2+3: Backup polling - click ReadyButton only if GREEN
        local tlt = PlayerGui:FindFirstChild("TradeLiveTrade")
        if tlt then
            local readyBtn = findByName(tlt, "ImageButton", "ReadyButton")
            if readyBtn and isGreen(readyBtn) then
                print("[Auto Trade] ReadyButton is GREEN -> clicking!")
                clickElement(readyBtn)
            end
        end
    end)
end
