-- Auto Trade Script for Steal a Brainrot (Volt)
-- Fully automatic, no keybind
-- Accept: DuelsMachinePrompt -> Yes (ImageButton) or TradePrompts -> Yes
-- Ready: TradeLiveTrade -> ReadyButton (ImageButton)
-- Confirm: TradeLiveTrade -> ReadyButton (changes to ACCEPT after both ready)

local Players = game:GetService("Players")
local VIM = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local function mouseClick(x, y)
    VIM:SendMouseButtonEvent(x, y, 0, true, game, 1)
    task.wait(0.05)
    VIM:SendMouseButtonEvent(x, y, 0, false, game, 1)
end

local function clickAtCenter(element)
    if not element then return false end
    local pos = element.AbsolutePosition
    local size = element.AbsoluteSize
    local x = pos.X + size.X / 2
    local y = pos.Y + size.Y / 2
    if x > 0 and y > 0 then
        mouseClick(x, y)
        return true
    end
    return false
end

local function findByName(parent, className, name)
    for _, desc in ipairs(parent:GetDescendants()) do
        if desc:IsA(className) and desc.Name == name and desc.Visible then
            return desc
        end
    end
    return nil
end

print("=============================================")
print("[Auto Trade] Script loaded! (Volt)")
print("[Auto Trade] Auto Accept: ON (DuelsMachinePrompt/TradePrompts)")
print("[Auto Trade] Auto Ready: ON (TradeLiveTrade -> ReadyButton)")
print("[Auto Trade] Auto Confirm: ON")
print("=============================================")

while task.wait(0.5) do
    pcall(function()
        -- STAGE 1: Auto-accept trade request
        -- Check DuelsMachinePrompt
        local dmp = PlayerGui:FindFirstChild("DuelsMachinePrompt")
        if dmp then
            local yesBtn = findByName(dmp, "ImageButton", "Yes")
            if yesBtn then
                print("[Auto Trade] Accepting trade! (DuelsMachinePrompt)")
                clickAtCenter(yesBtn)
                task.wait(0.5)
            end
        end

        -- Check TradePrompts
        local tp = PlayerGui:FindFirstChild("TradePrompts")
        if tp then
            local yesBtn = findByName(tp, "ImageButton", "Yes")
            if yesBtn then
                print("[Auto Trade] Accepting trade! (TradePrompts)")
                clickAtCenter(yesBtn)
                task.wait(0.5)
            end
        end

        -- STAGE 2+3: Auto-click ReadyButton (READY / ACCEPT)
        local tlt = PlayerGui:FindFirstChild("TradeLiveTrade")
        if tlt then
            local readyBtn = findByName(tlt, "ImageButton", "ReadyButton")
            if readyBtn then
                print("[Auto Trade] Clicking ReadyButton!")
                clickAtCenter(readyBtn)
            end
        end
    end)
end
