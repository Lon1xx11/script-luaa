-- Auto Trade Script for Steal a Brainrot (Volt compatible)
-- Uses event triggers (DescendantAdded) for instant reaction
-- 1. Auto-accept incoming trade requests
-- 2. Auto-ready when the other player offers a brainrot
-- 3. Auto-accept trade confirmation

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

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

local function otherPlayerHasItems(gui)
    for _, desc in ipairs(gui:GetDescendants()) do
        if desc:IsA("TextLabel") then
            local text = desc.Text
            if string.match(text, "@") then
                local current, total = string.match(text, "(%d+)/(%d+)")
                if current and total and tonumber(current) > 0 then
                    return true
                end
            end
        end
    end
    return false
end

local function processGui(gui)
    if not gui:IsA("ScreenGui") then return end

    -- TRIGGER 1: Trade Request popup -> click Accept
    if findTextInParent(gui, "Trade Request") or findTextMatchInParent(gui, "wants to trade") then
        task.wait(0.1)
        local acceptBtn = findButtonInParent(gui, "accept")
        if acceptBtn then
            print("[Auto Trade] TRIGGER: Trade Request detected -> clicking Accept!")
            clickButton(acceptBtn)
            return
        end
    end

    -- TRIGGER 3: Confirmation stage -> click ACCEPT
    if findTextInParent(gui, "Confirmed!") or findTextMatchInParent(gui, "%d+s Left") then
        local acceptBtn = findButtonInParent(gui, "accept")
        if acceptBtn then
            local readyBtn = findButtonInParent(gui, "ready")
            if not readyBtn then
                print("[Auto Trade] TRIGGER: Confirmation detected -> clicking ACCEPT!")
                clickButton(acceptBtn)
                return
            end
        end
    end
end

local function setupTriggers(gui)
    if not gui:IsA("ScreenGui") then return end

    processGui(gui)

    gui.DescendantAdded:Connect(function(desc)
        task.wait(0.1)

        -- TRIGGER 1: Trade Request appeared
        if desc:IsA("TextLabel") then
            if string.lower(desc.Text) == "trade request" or string.match(desc.Text, "wants to trade") then
                task.wait(0.15)
                local acceptBtn = findButtonInParent(gui, "accept")
                if acceptBtn then
                    print("[Auto Trade] TRIGGER: Trade Request detected -> clicking Accept!")
                    clickButton(acceptBtn)
                end
            end
        end

        if (desc:IsA("TextButton") or desc:IsA("ImageButton")) then
            local text = getButtonText(desc)
            if text == "accept" then
                if findTextInParent(gui, "Trade Request") or findTextMatchInParent(gui, "wants to trade") then
                    print("[Auto Trade] TRIGGER: Accept button appeared on Trade Request -> clicking!")
                    task.wait(0.1)
                    clickButton(desc)
                end
            end
        end

        -- TRIGGER 2: Other player added items -> click READY
        if desc:IsA("TextLabel") or desc:IsA("ImageLabel") or desc:IsA("Frame") then
            if findTextInParent(gui, "Select Brainrots to offer") then
                if otherPlayerHasItems(gui) then
                    local readyBtn = findButtonInParent(gui, "ready")
                    if readyBtn then
                        print("[Auto Trade] TRIGGER: Other player added items -> clicking READY!")
                        clickButton(readyBtn)
                    end
                end
            end
        end

        -- TRIGGER 3: Confirmation -> click ACCEPT
        if desc:IsA("TextLabel") then
            if desc.Text == "Confirmed!" or string.match(desc.Text, "%d+s Left") then
                task.wait(0.1)
                local acceptBtn = findButtonInParent(gui, "accept")
                if acceptBtn then
                    local readyBtn = findButtonInParent(gui, "ready")
                    if not readyBtn then
                        print("[Auto Trade] TRIGGER: Confirmation detected -> clicking ACCEPT!")
                        clickButton(acceptBtn)
                    end
                end
            end
        end
    end)
end

-- Setup triggers for existing GUIs
for _, gui in ipairs(PlayerGui:GetChildren()) do
    pcall(function()
        setupTriggers(gui)
    end)
end

-- Setup triggers for any new GUIs that appear
PlayerGui.ChildAdded:Connect(function(gui)
    pcall(function()
        task.wait(0.1)
        setupTriggers(gui)
    end)
end)

-- Backup polling loop (in case events miss something)
spawn(function()
    while task.wait(0.5) do
        pcall(function()
            for _, gui in ipairs(PlayerGui:GetChildren()) do
                if gui:IsA("ScreenGui") then
                    -- Check for trade request
                    if findTextInParent(gui, "Trade Request") or findTextMatchInParent(gui, "wants to trade") then
                        local acceptBtn = findButtonInParent(gui, "accept")
                        if acceptBtn then
                            print("[Auto Trade] BACKUP: Trade Request found -> clicking Accept!")
                            clickButton(acceptBtn)
                        end
                    end

                    -- Check for ready
                    if findTextInParent(gui, "Select Brainrots to offer") then
                        if otherPlayerHasItems(gui) then
                            local readyBtn = findButtonInParent(gui, "ready")
                            if readyBtn then
                                print("[Auto Trade] BACKUP: Ready available -> clicking READY!")
                                clickButton(readyBtn)
                            end
                        end
                    end

                    -- Check for confirmation
                    if findTextInParent(gui, "Confirmed!") or findTextMatchInParent(gui, "%d+s Left") then
                        local acceptBtn = findButtonInParent(gui, "accept")
                        if acceptBtn then
                            local readyBtn = findButtonInParent(gui, "ready")
                            if not readyBtn then
                                print("[Auto Trade] BACKUP: Confirmation found -> clicking ACCEPT!")
                                clickButton(acceptBtn)
                            end
                        end
                    end
                end
            end
        end)
    end
end)

print("=============================================")
print("[Auto Trade] Script loaded! (Volt compatible)")
print("[Auto Trade] Event triggers: ACTIVE")
print("[Auto Trade] Backup polling: ACTIVE")
print("[Auto Trade] Auto Accept Trade Request: ON")
print("[Auto Trade] Auto Ready: ON")
print("[Auto Trade] Auto Confirm: ON")
print("=============================================")
