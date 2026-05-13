-- Auto Trade Script for Steal a Brainrot (Volt compatible)
-- 1. Auto-accept incoming trade requests
-- 2. Auto-ready when the other player offers a brainrot
-- 3. Auto-accept trade confirmation

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local CHECK_INTERVAL = 0.2

local function clickButton(button)
    if not button then return end

    -- Method 1: firesignal (most executors)
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

    -- Method 3: VirtualInputManager
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

    -- Method 5: fire all connections on MouseButton1Click
    pcall(function()
        if getconnections then
            for _, conn in ipairs(getconnections(button.MouseButton1Click)) do
                pcall(function()
                    conn:Fire()
                end)
            end
        end
    end)

    -- Method 6: fire MouseButton1Down + MouseButton1Up
    pcall(function()
        if firesignal then
            firesignal(button.MouseButton1Down)
            task.wait(0.05)
            firesignal(button.MouseButton1Up)
        end
    end)
end

local function findAllButtons(parent)
    local buttons = {}
    for _, desc in ipairs(parent:GetDescendants()) do
        if desc:IsA("TextButton") or desc:IsA("ImageButton") then
            table.insert(buttons, desc)
        end
    end
    return buttons
end

local function getButtonText(button)
    if button:IsA("TextButton") and button.Text ~= "" then
        return button.Text
    end
    for _, child in ipairs(button:GetDescendants()) do
        if child:IsA("TextLabel") and child.Text ~= "" then
            return child.Text
        end
    end
    return ""
end

local function findButtonByText(parent, targetText)
    local target = string.lower(targetText)
    for _, btn in ipairs(findAllButtons(parent)) do
        local text = string.lower(getButtonText(btn))
        if text == target then
            return btn
        end
    end
    return nil
end

local function hasText(parent, targetText)
    local target = string.lower(targetText)
    for _, desc in ipairs(parent:GetDescendants()) do
        if desc:IsA("TextLabel") or desc:IsA("TextButton") then
            if string.lower(desc.Text) == target then
                return true
            end
        end
    end
    return false
end

local function hasTextMatch(parent, pattern)
    for _, desc in ipairs(parent:GetDescendants()) do
        if desc:IsA("TextLabel") or desc:IsA("TextButton") then
            if string.match(desc.Text, pattern) then
                return true
            end
        end
    end
    return false
end

local function otherPlayerHasItems(gui)
    for _, desc in ipairs(gui:GetDescendants()) do
        if desc:IsA("TextLabel") and string.match(desc.Text, "@") and string.match(desc.Text, "Offer") then
            local countMatch = nil
            for _, d in ipairs(gui:GetDescendants()) do
                if d:IsA("TextLabel") then
                    local current, total = string.match(d.Text, "(%d+)/(%d+)")
                    if current and total and string.match(d.Text, "@") then
                        if tonumber(current) > 0 then
                            return true
                        end
                    end
                end
            end
        end
    end
    return false
end

-- Step 1: Auto-accept trade requests
local function stepAcceptRequest()
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            if hasText(gui, "Trade Request") or hasTextMatch(gui, "wants to trade") then
                local btn = findButtonByText(gui, "Accept")
                if btn then
                    print("[Auto Trade] Found Trade Request -> clicking Accept")
                    clickButton(btn)
                    return true
                end
            end
        end
    end
    return false
end

-- Step 2: Auto-ready when other player offered brainrots
local function stepAutoReady()
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            if hasText(gui, "Select Brainrots to offer") then
                if otherPlayerHasItems(gui) then
                    local btn = findButtonByText(gui, "READY")
                    if not btn then
                        btn = findButtonByText(gui, "Ready")
                    end
                    if btn then
                        print("[Auto Trade] Other player has items -> clicking READY")
                        clickButton(btn)
                        return true
                    end
                end
            end
        end
    end
    return false
end

-- Step 3: Auto-accept confirmation
local function stepAutoConfirm()
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            local hasConfirmed = hasText(gui, "Confirmed!")
            local hasTimer = hasTextMatch(gui, "%d+s Left")

            if hasConfirmed or hasTimer then
                local btn = findButtonByText(gui, "ACCEPT")
                if not btn then
                    btn = findButtonByText(gui, "Accept")
                end
                if btn then
                    local readyBtn = findButtonByText(gui, "READY")
                    if not readyBtn then
                        print("[Auto Trade] Trade confirmed -> clicking ACCEPT")
                        clickButton(btn)
                        return true
                    end
                end
            end
        end
    end
    return false
end

print("=============================================")
print("[Auto Trade] Script loaded! (Volt compatible)")
print("[Auto Trade] Auto Accept Trade Request: ON")
print("[Auto Trade] Auto Ready: ON")
print("[Auto Trade] Auto Confirm: ON")
print("=============================================")

while task.wait(CHECK_INTERVAL) do
    pcall(function()
        stepAcceptRequest()
        stepAutoReady()
        stepAutoConfirm()
    end)
end
