-- Auto Trade Script for Steal a Brainrot (Volt)
-- Fully automatic, smart triggers
-- 1. Accept only when Trade Request appears
-- 2. READY only when opponent offers a brainrot
-- 3. ACCEPT only on trade confirmation

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

local function hasTextLabel(parent, text)
    local target = string.lower(text)
    for _, desc in ipairs(parent:GetDescendants()) do
        if desc:IsA("TextLabel") and string.lower(desc.Text) == target then
            return true
        end
    end
    return false
end

local function hasTextMatch(parent, pattern)
    for _, desc in ipairs(parent:GetDescendants()) do
        if desc:IsA("TextLabel") and string.match(desc.Text, pattern) then
            return true
        end
    end
    return false
end

-- Check if opponent has offered items
-- Looks inside TradeLiveTrade -> Other -> ScrollingFrame for Template children (items)
local function opponentHasItems(tlt)
    for _, desc in ipairs(tlt:GetDescendants()) do
        if desc.Name == "Other" then
            for _, child in ipairs(desc:GetDescendants()) do
                if child:IsA("ScrollingFrame") then
                    for _, item in ipairs(child:GetChildren()) do
                        if item.Name == "Template" and item.Visible then
                            return true
                        end
                    end
                end
            end
        end
    end
    return false
end

print("=============================================")
print("[Auto Trade] Script loaded! (Volt)")
print("[Auto Trade] Smart triggers:")
print("  1. Accept on Trade Request")
print("  2. Ready when opponent offers brainrot")
print("  3. Accept on confirmation")
print("=============================================")

while task.wait(0.5) do
    pcall(function()
        -- STAGE 1: Accept trade request (only when "Trade Request" + "wants to trade" visible)
        local dmp = PlayerGui:FindFirstChild("DuelsMachinePrompt")
        if dmp then
            if hasTextLabel(dmp, "Trade Request") and hasTextMatch(dmp, "wants to trade") then
                local yesBtn = findByName(dmp, "ImageButton", "Yes")
                if yesBtn then
                    print("[Auto Trade] Trade Request detected -> Accepting!")
                    clickElement(yesBtn)
                    task.wait(1)
                    return
                end
            end
        end

        local tp = PlayerGui:FindFirstChild("TradePrompts")
        if tp then
            if hasTextLabel(tp, "Trade Request") and hasTextMatch(tp, "wants to trade") then
                local yesBtn = findByName(tp, "ImageButton", "Yes")
                if yesBtn then
                    print("[Auto Trade] Trade Request detected -> Accepting! (TradePrompts)")
                    clickElement(yesBtn)
                    task.wait(1)
                    return
                end
            end
        end

        -- STAGE 2+3: Trade menu
        local tlt = PlayerGui:FindFirstChild("TradeLiveTrade")
        if not tlt then return end

        -- STAGE 3: Confirmation -> click ACCEPT (check first, higher priority)
        if hasTextLabel(tlt, "Confirmed!") or hasTextMatch(tlt, "%d+s Left") then
            local readyBtn = findByName(tlt, "ImageButton", "ReadyButton")
            if readyBtn then
                print("[Auto Trade] Confirmation detected -> Accepting!")
                clickElement(readyBtn)
                return
            end
        end

        -- STAGE 2: Click READY only when opponent has offered items
        if opponentHasItems(tlt) then
            local readyBtn = findByName(tlt, "ImageButton", "ReadyButton")
            if readyBtn then
                print("[Auto Trade] Opponent offered brainrot -> Clicking READY!")
                clickElement(readyBtn)
                return
            end
        end
    end)
end
