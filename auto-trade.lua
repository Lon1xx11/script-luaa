-- Auto Trade Script for Steal a Brainrot (Volt)
-- Auto-clicker: spams click at button positions
-- Stage 1: Auto-accept trade request (ImageButton "Yes")
-- Stage 2+3: Spam click at READY/ACCEPT position

local Players = game:GetService("Players")
local VIM = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local function mouseClick(x, y)
    VIM:SendMouseButtonEvent(x, y, 0, true, game, 1)
    task.wait(0.05)
    VIM:SendMouseButtonEvent(x, y, 0, false, game, 1)
end

local function getCenter(element)
    local pos = element.AbsolutePosition
    local size = element.AbsoluteSize
    return pos.X + size.X / 2, pos.Y + size.Y / 2
end

local function findButton(parent, name)
    for _, desc in ipairs(parent:GetDescendants()) do
        if desc:IsA("ImageButton") and desc.Name == name and desc.Visible then
            return desc
        end
    end
    return nil
end

local function hasText(parent, text)
    local target = string.lower(text)
    for _, desc in ipairs(parent:GetDescendants()) do
        if desc:IsA("TextLabel") and string.lower(desc.Text) == target then
            return true
        end
    end
    return false
end

local function hasPattern(parent, pattern)
    for _, desc in ipairs(parent:GetDescendants()) do
        if desc:IsA("TextLabel") and string.match(desc.Text, pattern) then
            return true
        end
    end
    return false
end

print("=============================================")
print("[Auto Trade] Script loaded! (Volt)")
print("[Auto Trade] Auto Accept: ON")
print("[Auto Trade] Auto Ready/Confirm spam: ON")
print("=============================================")

while task.wait(1) do
    pcall(function()
        local gui = PlayerGui:FindFirstChild("DuelsMachinePrompt")
        if not gui then return end

        -- Stage 1: Trade Request -> click Accept button
        if hasText(gui, "Trade Request") and hasPattern(gui, "wants to trade") then
            local yesBtn = findButton(gui, "Yes")
            if yesBtn then
                local x, y = getCenter(yesBtn)
                mouseClick(x, y)
                task.wait(0.3)
                return
            end
        end

        -- Stage 2+3: Spam click at READY/ACCEPT position (998, 744)
        mouseClick(998, 744)
    end)
end
