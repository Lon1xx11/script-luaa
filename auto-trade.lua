-- Auto Trade Script for Steal a Brainrot (Volt)
-- Works like an auto-clicker: finds button position and clicks there
-- Uses VirtualInputManager to simulate real mouse clicks

local Players = game:GetService("Players")
local VIM = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Simulate a real mouse click at screen position (x, y)
local function mouseClick(x, y)
    VIM:SendMouseButtonEvent(x, y, 0, true, game, 1)
    task.wait(0.05)
    VIM:SendMouseButtonEvent(x, y, 0, false, game, 1)
end

-- Get the center position of a GUI element on screen
local function getCenter(element)
    local pos = element.AbsolutePosition
    local size = element.AbsoluteSize
    return pos.X + size.X / 2, pos.Y + size.Y / 2
end

-- Find an ImageButton by name inside a parent
local function findButton(parent, name)
    for _, desc in ipairs(parent:GetDescendants()) do
        if desc:IsA("ImageButton") and desc.Name == name and desc.Visible then
            return desc
        end
    end
    return nil
end

-- Find a button that has a child TextLabel with specific text
local function findButtonByText(parent, text)
    local target = string.lower(text)
    for _, desc in ipairs(parent:GetDescendants()) do
        if (desc:IsA("ImageButton") or desc:IsA("TextButton")) and desc.Visible then
            for _, child in ipairs(desc:GetChildren()) do
                if child:IsA("TextLabel") and string.lower(child.Text) == target then
                    return desc
                end
            end
        end
    end
    return nil
end

-- Check if a TextLabel with specific text exists
local function hasText(parent, text)
    local target = string.lower(text)
    for _, desc in ipairs(parent:GetDescendants()) do
        if desc:IsA("TextLabel") and string.lower(desc.Text) == target then
            return true
        end
    end
    return false
end

-- Check if a TextLabel matches a pattern
local function hasPattern(parent, pattern)
    for _, desc in ipairs(parent:GetDescendants()) do
        if desc:IsA("TextLabel") and string.match(desc.Text, pattern) then
            return true
        end
    end
    return false
end

-- Click a button using mouse simulation at its screen position
local function clickButton(btn)
    if not btn then return false end
    local x, y = getCenter(btn)
    if x > 0 and y > 0 then
        mouseClick(x, y)
        return true
    end
    return false
end

print("=============================================")
print("[Auto Trade] Script loaded! (Volt)")
print("[Auto Trade] Mode: Auto-Clicker")
print("[Auto Trade] Method: VirtualInputManager")
print("[Auto Trade] Auto Accept: ON")
print("[Auto Trade] Auto Ready: ON")  
print("[Auto Trade] Auto Confirm: ON")
print("=============================================")

-- Main auto-clicker loop
while task.wait(0.15) do
    pcall(function()
        local gui = PlayerGui:FindFirstChild("DuelsMachinePrompt")
        if not gui then return end

        -- STAGE 1: Trade Request -> click Accept (ImageButton "Yes")
        if hasText(gui, "Trade Request") and hasPattern(gui, "wants to trade") then
            local yesBtn = findButton(gui, "Yes")
            if not yesBtn then
                yesBtn = findButtonByText(gui, "Accept")
            end
            if yesBtn then
                print("[Auto Trade] Clicking Accept!")
                clickButton(yesBtn)
                task.wait(0.3)
                return
            end
        end

        -- STAGE 2: Trade menu -> SPAM READY
        local readyBtn = findButtonByText(gui, "READY")
        if not readyBtn then
            readyBtn = findButtonByText(gui, "Ready")
        end
        if readyBtn then
            print("[Auto Trade] Spamming READY!")
            clickButton(readyBtn)
            return
        end

        -- STAGE 3: Confirmation -> SPAM ACCEPT
        local acceptBtn = findButtonByText(gui, "ACCEPT")
        if acceptBtn then
            print("[Auto Trade] Clicking ACCEPT!")
            clickButton(acceptBtn)
            return
        end
    end)
end
