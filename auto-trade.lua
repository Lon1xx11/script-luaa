-- Auto Trade Script for Steal a Brainrot (Volt)
-- Fully automatic, trigger-based
-- Accept: when Trade Request appears
-- Ready/Confirm: 1 click when ReadyButton turns GREEN
-- Click method: VIM + GuiInset (confirmed working)

local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local VIM = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local guiInset = GuiService:GetGuiInset()
local clickCount = 0

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
print("[Auto Trade] Method: VIM + GuiInset")
print("=============================================")

-- Event: 1 click each time ReadyButton turns green
-- Click 1 = READY, Click 2 = ACCEPT
local function watchReadyButton(tlt)
    local readyBtn = findByName(tlt, "ImageButton", "ReadyButton")
    if not readyBtn then return end
    local lastGreen = false

    readyBtn:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
        local green = isGreen(readyBtn)
        if green and not lastGreen then
            lastGreen = true
            clickCount = clickCount + 1
            print("[Auto Trade] GREEN -> click #" .. clickCount)
            task.wait(0.2)
            clickElement(readyBtn)
        elseif not green then
            lastGreen = false
        end
    end)
end

PlayerGui.ChildAdded:Connect(function(child)
    if child.Name == "TradeLiveTrade" then
        clickCount = 0
        task.wait(0.5)
        pcall(function() watchReadyButton(child) end)
    end
end)

local existing = PlayerGui:FindFirstChild("TradeLiveTrade")
if existing then
    pcall(function() watchReadyButton(existing) end)
end

-- Polling loop
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

        -- Reset on trade close
        local tlt = PlayerGui:FindFirstChild("TradeLiveTrade")
        if not tlt then
            clickCount = 0
        end
    end)
end
