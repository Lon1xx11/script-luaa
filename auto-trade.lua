-- Auto Trade Script for Steal a Brainrot (Volt compatible)
-- Keybind: R
-- GUI path: PlayerGui.DuelsMachinePrompt
-- Accept = ImageButton "Yes", Decline = ImageButton "No"

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local KEYBIND = Enum.KeyCode.R

local function clickButton(button)
    if not button then return false end

    -- Method 1: firesignal MouseButton1Click
    pcall(function()
        if firesignal then
            firesignal(button.MouseButton1Click)
        end
    end)

    -- Method 2: fireclick
    pcall(function()
        if fireclick then
            fireclick(button)
        end
    end)

    -- Method 3: VirtualInputManager (simulate mouse click at button center)
    pcall(function()
        local pos = button.AbsolutePosition
        local size = button.AbsoluteSize
        local x = pos.X + size.X / 2
        local y = pos.Y + size.Y / 2
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 1)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 1)
    end)

    -- Method 4: Activate
    pcall(function()
        button:Activate()
    end)

    -- Method 5: getconnections + Fire
    pcall(function()
        if getconnections then
            for _, conn in ipairs(getconnections(button.MouseButton1Click)) do
                pcall(function()
                    conn:Fire()
                end)
            end
        end
    end)

    -- Method 6: MouseButton1Down + MouseButton1Up
    pcall(function()
        if firesignal then
            firesignal(button.MouseButton1Down)
            task.wait(0.05)
            firesignal(button.MouseButton1Up)
        end
    end)

    return true
end

local function findImageButtonByName(parent, name)
    for _, desc in ipairs(parent:GetDescendants()) do
        if desc:IsA("ImageButton") and desc.Name == name then
            return desc
        end
    end
    return nil
end

local function findImageButtonByChildText(parent, childText)
    local target = string.lower(childText)
    for _, desc in ipairs(parent:GetDescendants()) do
        if desc:IsA("ImageButton") then
            for _, child in ipairs(desc:GetChildren()) do
                if (child:IsA("TextLabel") or child:IsA("TextButton")) then
                    if string.lower(child.Text) == target then
                        return desc
                    end
                end
            end
        end
    end
    return nil
end

local function hasTextLabel(parent, targetText)
    local target = string.lower(targetText)
    for _, desc in ipairs(parent:GetDescendants()) do
        if desc:IsA("TextLabel") then
            if string.lower(desc.Text) == target then
                return true
            end
        end
    end
    return false
end

local function hasTextMatch(parent, pattern)
    for _, desc in ipairs(parent:GetDescendants()) do
        if desc:IsA("TextLabel") then
            if string.match(desc.Text, pattern) then
                return true
            end
        end
    end
    return false
end

local function onKeyPress()
    local tradeGui = PlayerGui:FindFirstChild("DuelsMachinePrompt")
    if not tradeGui then
        print("[Auto Trade] R pressed -> DuelsMachinePrompt not found")
        return
    end

    -- STAGE 1: Trade Request popup -> click "Yes" (Accept)
    if hasTextLabel(tradeGui, "Trade Request") and hasTextMatch(tradeGui, "wants to trade") then
        -- Try by name first
        local yesBtn = findImageButtonByName(tradeGui, "Yes")
        if not yesBtn then
            yesBtn = findImageButtonByChildText(tradeGui, "Accept")
        end
        if yesBtn then
            print("[Auto Trade] R -> Accepting Trade Request! (clicking 'Yes' ImageButton)")
            clickButton(yesBtn)
            return
        else
            print("[Auto Trade] R -> Trade Request found but 'Yes' button not found!")
        end
    end

    -- STAGE 2: Trade menu -> click READY
    if hasTextLabel(tradeGui, "Select Brainrots to offer") then
        local readyBtn = findImageButtonByChildText(tradeGui, "READY")
        if not readyBtn then
            readyBtn = findImageButtonByChildText(tradeGui, "Ready")
        end
        if not readyBtn then
            readyBtn = findImageButtonByName(tradeGui, "Ready")
        end
        if readyBtn then
            print("[Auto Trade] R -> Clicking READY!")
            clickButton(readyBtn)
            return
        else
            print("[Auto Trade] R -> Trade menu found but READY button not found!")
        end
    end

    -- STAGE 3: Confirmation -> click ACCEPT
    if hasTextLabel(tradeGui, "Confirmed!") or hasTextMatch(tradeGui, "%d+s Left") then
        local acceptBtn = findImageButtonByChildText(tradeGui, "ACCEPT")
        if not acceptBtn then
            acceptBtn = findImageButtonByChildText(tradeGui, "Accept")
        end
        if not acceptBtn then
            acceptBtn = findImageButtonByName(tradeGui, "Yes")
        end
        if acceptBtn then
            print("[Auto Trade] R -> Confirming Trade!")
            clickButton(acceptBtn)
            return
        else
            print("[Auto Trade] R -> Confirmation found but ACCEPT button not found!")
        end
    end

    print("[Auto Trade] R pressed -> No active trade stage detected")
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == KEYBIND then
        pcall(onKeyPress)
    end
end)

print("=============================================")
print("[Auto Trade] Script loaded! (Volt)")
print("[Auto Trade] GUI: DuelsMachinePrompt")
print("[Auto Trade] Buttons: ImageButton 'Yes'/'No'")
print("[Auto Trade] Keybind: R")
print("[Auto Trade] Press R to:")
print("  - Accept trade requests")
print("  - Click Ready in trade menu")
print("  - Confirm trade")
print("=============================================")
