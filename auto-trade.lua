-- Auto Trade Script for Steal a Brainrot (Volt compatible)
-- Keybind: R — accepts trade request, clicks ready, confirms trade
-- GUI: DuelsMachinePrompt

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local KEYBIND = Enum.KeyCode.R

local function clickElement(element)
    if not element then return end

    local button = element
    if not (button:IsA("TextButton") or button:IsA("ImageButton") or button:IsA("GuiButton")) then
        button = element.Parent
    end

    pcall(function()
        if firesignal then
            firesignal(button.MouseButton1Click)
        end
    end)

    pcall(function()
        if fireclick then
            fireclick(button)
        end
    end)

    pcall(function()
        local pos = button.AbsolutePosition
        local size = button.AbsoluteSize
        local x = pos.X + size.X / 2
        local y = pos.Y + size.Y / 2
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 1)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 1)
    end)

    pcall(function()
        button:Activate()
    end)

    pcall(function()
        if getconnections then
            for _, conn in ipairs(getconnections(button.MouseButton1Click)) do
                pcall(function()
                    conn:Fire()
                end)
            end
        end
    end)

    pcall(function()
        if firesignal then
            firesignal(button.MouseButton1Down)
            task.wait(0.05)
            firesignal(button.MouseButton1Up)
        end
    end)

    -- Also try clicking the element itself if it's different from button
    if element ~= button then
        pcall(function()
            local pos = element.AbsolutePosition
            local size = element.AbsoluteSize
            local x = pos.X + size.X / 2
            local y = pos.Y + size.Y / 2
            VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 1)
            task.wait(0.05)
            VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 1)
        end)

        pcall(function()
            if firesignal and element:IsA("GuiObject") then
                firesignal(element.MouseButton1Click)
            end
        end)

        pcall(function()
            if getconnections then
                for _, conn in ipairs(getconnections(element.MouseButton1Click)) do
                    pcall(function()
                        conn:Fire()
                    end)
                end
            end
        end)
    end
end

local function findTextElement(parent, targetText)
    local target = string.lower(targetText)
    for _, desc in ipairs(parent:GetDescendants()) do
        if desc:IsA("TextLabel") or desc:IsA("TextButton") then
            if string.lower(desc.Text) == target then
                return desc
            end
        end
    end
    return nil
end

local function findTextMatch(parent, pattern)
    for _, desc in ipairs(parent:GetDescendants()) do
        if desc:IsA("TextLabel") or desc:IsA("TextButton") then
            if string.match(desc.Text, pattern) then
                return desc
            end
        end
    end
    return nil
end

local function onKeyPress()
    -- Look for DuelsMachinePrompt GUI specifically
    local tradeGui = PlayerGui:FindFirstChild("DuelsMachinePrompt")

    if tradeGui then
        -- 1: Trade Request popup -> click Accept
        local tradeRequestLabel = findTextElement(tradeGui, "Trade Request")
        if tradeRequestLabel then
            local acceptLabel = findTextElement(tradeGui, "Accept")
            if acceptLabel then
                print("[Auto Trade] R -> Accepting Trade Request!")
                clickElement(acceptLabel)
                return
            end
        end

        -- 2: Trade menu -> click READY
        local selectLabel = findTextElement(tradeGui, "Select Brainrots to offer")
        if selectLabel then
            local readyLabel = findTextElement(tradeGui, "READY")
            if not readyLabel then
                readyLabel = findTextElement(tradeGui, "Ready")
            end
            if readyLabel then
                print("[Auto Trade] R -> Clicking READY!")
                clickElement(readyLabel)
                return
            end
        end

        -- 3: Confirmation -> click ACCEPT
        local confirmedLabel = findTextElement(tradeGui, "Confirmed!")
        local timerLabel = findTextMatch(tradeGui, "%d+s Left")
        if confirmedLabel or timerLabel then
            local acceptLabel = findTextElement(tradeGui, "ACCEPT")
            if not acceptLabel then
                acceptLabel = findTextElement(tradeGui, "Accept")
            end
            if acceptLabel then
                print("[Auto Trade] R -> Confirming Trade!")
                clickElement(acceptLabel)
                return
            end
        end
    end

    -- Fallback: search all GUIs
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if not gui:IsA("ScreenGui") then continue end

        local tradeRequestLabel = findTextElement(gui, "Trade Request")
        if tradeRequestLabel then
            local acceptLabel = findTextElement(gui, "Accept")
            if acceptLabel then
                print("[Auto Trade] R -> Accepting Trade Request! (fallback)")
                clickElement(acceptLabel)
                return
            end
        end

        local selectLabel = findTextElement(gui, "Select Brainrots to offer")
        if selectLabel then
            local readyLabel = findTextElement(gui, "READY") or findTextElement(gui, "Ready")
            if readyLabel then
                print("[Auto Trade] R -> Clicking READY! (fallback)")
                clickElement(readyLabel)
                return
            end
        end

        local confirmedLabel = findTextElement(gui, "Confirmed!")
        local timerLabel = findTextMatch(gui, "%d+s Left")
        if confirmedLabel or timerLabel then
            local acceptLabel = findTextElement(gui, "ACCEPT") or findTextElement(gui, "Accept")
            if acceptLabel then
                print("[Auto Trade] R -> Confirming Trade! (fallback)")
                clickElement(acceptLabel)
                return
            end
        end
    end

    print("[Auto Trade] R pressed -> No trade UI found")
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == KEYBIND then
        pcall(onKeyPress)
    end
end)

print("=============================================")
print("[Auto Trade] Script loaded! (Volt compatible)")
print("[Auto Trade] GUI: DuelsMachinePrompt")
print("[Auto Trade] Keybind: R")
print("[Auto Trade] Press R to:")
print("  - Accept trade requests")
print("  - Click Ready in trade menu")
print("  - Confirm trade")
print("=============================================")
