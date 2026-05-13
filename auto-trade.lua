-- Auto Trade Script for Steal a Brainrot (Volt compatible)
-- Keybind: R — accepts trade request, clicks ready, confirms trade
-- 1. Press R to accept incoming trade request
-- 2. Press R to click Ready in trade menu
-- 3. Press R to accept/confirm trade

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local KEYBIND = Enum.KeyCode.R

local function clickButton(button)
    if not button then return end

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
end

local function getButtonText(button)
    if button:IsA("TextButton") and button.Text ~= "" then
        return string.lower(button.Text)
    end
    for _, child in ipairs(button:GetDescendants()) do
        if child:IsA("TextLabel") and child.Text ~= "" then
            return string.lower(child.Text)
        end
    end
    return ""
end

local function findButtonInParent(parent, targetText)
    local target = string.lower(targetText)
    for _, desc in ipairs(parent:GetDescendants()) do
        if desc:IsA("TextButton") or desc:IsA("ImageButton") then
            if getButtonText(desc) == target then
                return desc
            end
        end
    end
    return nil
end

local function findTextInParent(parent, targetText)
    local target = string.lower(targetText)
    for _, desc in ipairs(parent:GetDescendants()) do
        if (desc:IsA("TextLabel") or desc:IsA("TextButton")) then
            if string.lower(desc.Text) == target then
                return desc
            end
        end
    end
    return nil
end

local function findTextMatchInParent(parent, pattern)
    for _, desc in ipairs(parent:GetDescendants()) do
        if (desc:IsA("TextLabel") or desc:IsA("TextButton")) then
            if string.match(desc.Text, pattern) then
                return desc
            end
        end
    end
    return nil
end

local function onKeyPress()
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if not gui:IsA("ScreenGui") then continue end

        -- 1: Trade Request popup -> click Accept
        if findTextInParent(gui, "Trade Request") or findTextMatchInParent(gui, "wants to trade") then
            local acceptBtn = findButtonInParent(gui, "accept")
            if acceptBtn then
                print("[Auto Trade] R pressed -> Accepting Trade Request!")
                clickButton(acceptBtn)
                return
            end
        end

        -- 2: Trade menu open -> click READY
        if findTextInParent(gui, "Select Brainrots to offer") then
            local readyBtn = findButtonInParent(gui, "ready")
            if readyBtn then
                print("[Auto Trade] R pressed -> Clicking READY!")
                clickButton(readyBtn)
                return
            end
        end

        -- 3: Confirmation stage -> click ACCEPT
        if findTextInParent(gui, "Confirmed!") or findTextMatchInParent(gui, "%d+s Left") then
            local acceptBtn = findButtonInParent(gui, "accept")
            if acceptBtn then
                print("[Auto Trade] R pressed -> Confirming Trade!")
                clickButton(acceptBtn)
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
print("[Auto Trade] Keybind: R")
print("[Auto Trade] Press R to:")
print("  - Accept trade requests")
print("  - Click Ready in trade menu")
print("  - Confirm trade")
print("=============================================")
