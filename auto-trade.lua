-- Auto Trade Script for Steal a Brainrot (Volt)
-- Fully automatic, trigger-based
-- Accept: when Trade Request appears
-- Ready/Confirm: 1 click when ReadyButton turns GREEN

local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local VIM = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local guiInset = GuiService:GetGuiInset()
local clickedReady = false

local function clickElement(element)
    if not element then return end
    local pos = element.AbsolutePosition
    local size = element.AbsoluteSize
    local x = pos.X + size.X / 2
    local y = pos.Y + size.Y / 2 + guiInset.Y

    pcall(function()
        VIM:SendMouseButtonEvent(x, y, 0, true, game, 1)
        task.wait(0.05)
        VIM:SendMouseButtonEvent(x, y, 0, false, game, 1)
    end)

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

local function isGreen(element)
    if not element then return false end
    local color = element.BackgroundColor3
    local g = math.floor(color.G * 255)
    local r = math.floor(color.R * 255)
    return g > 140 and g > r + 20
end

print("=============================================")
print("[Auto Trade] Script loaded! (Volt)")
print("[Auto Trade] 1 click when button turns GREEN")
print("=============================================")

-- Event: click once when ReadyButton turns green
local function watchReadyButton(tlt)
    local readyBtn = findByName(tlt, "ImageButton", "ReadyButton")
    if not readyBtn then return end

    readyBtn:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
        if isGreen(readyBtn) and not clickedReady then
            clickedReady = true
            print("[Auto Trade] GREEN -> 1 click!")
            task.wait(0.2)
            clickElement(readyBtn)
        end
    end)
end

PlayerGui.ChildAdded:Connect(function(child)
    if child.Name == "TradeLiveTrade" then
        clickedReady = false
        task.wait(0.5)
        pcall(function() watchReadyButton(child) end)
    end
end)

local existing = PlayerGui:FindFirstChild("TradeLiveTrade")
if existing then
    pcall(function() watchReadyButton(existing) end)
end

while task.wait(4) do
    pcall(function()
        -- Accept trade request
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

        -- Backup: 1 click if green and not clicked yet
        local tlt = PlayerGui:FindFirstChild("TradeLiveTrade")
        if tlt then
            local readyBtn = findByName(tlt, "ImageButton", "ReadyButton")
            if readyBtn and isGreen(readyBtn) and not clickedReady then
                clickedReady = true
                print("[Auto Trade] GREEN -> 1 click! (poll)")
                clickElement(readyBtn)
            end
        else
            clickedReady = false
        end
    end)
end
