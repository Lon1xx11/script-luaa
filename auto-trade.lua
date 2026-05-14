-- Auto Trade Script for Steal a Brainrot (Volt)
-- Fully automatic: no keybind needed
-- Auto-accepts trade requests + auto-confirms trade
-- Click method: firesignal (confirmed working in Volt)
-- Path: PlayerGui.DuelsMachinePrompt.DuelsMachinePrompt.InviteTemplate.Yes

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local function clickBtn(btn)
    if not btn then return end
    pcall(function() firesignal(btn.MouseButton1Click) end)
    pcall(function()
        firesignal(btn.MouseButton1Down)
        task.wait(0.05)
        firesignal(btn.MouseButton1Up)
    end)
end

local function findImageButton(parent, name)
    for _, desc in ipairs(parent:GetDescendants()) do
        if desc:IsA("ImageButton") and desc.Name == name then
            return desc
        end
    end
    return nil
end

local function findButtonByChildText(parent, text)
    local target = string.lower(text)
    for _, desc in ipairs(parent:GetDescendants()) do
        if desc:IsA("ImageButton") or desc:IsA("TextButton") then
            for _, child in ipairs(desc:GetChildren()) do
                if child:IsA("TextLabel") and string.lower(child.Text) == target then
                    return desc
                end
            end
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

local function hasTextMatch(parent, pattern)
    for _, desc in ipairs(parent:GetDescendants()) do
        if desc:IsA("TextLabel") and string.match(desc.Text, pattern) then
            return true
        end
    end
    return false
end

local function tryAcceptTradeRequest(tradeGui)
    if not hasText(tradeGui, "Trade Request") then return false end
    if not hasTextMatch(tradeGui, "wants to trade") then return false end

    local yesBtn = findImageButton(tradeGui, "Yes")
    if not yesBtn then
        yesBtn = findButtonByChildText(tradeGui, "Accept")
    end
    if yesBtn then
        print("[Auto Trade] Auto-accepting trade request!")
        clickBtn(yesBtn)
        return true
    end
    return false
end

local function tryClickReady(tradeGui)
    if not hasText(tradeGui, "Select Brainrots to offer") then return false end
    if hasText(tradeGui, "Confirmed!") then return false end
    if hasTextMatch(tradeGui, "%d+s Left") then return false end

    local readyBtn = findButtonByChildText(tradeGui, "READY")
    if not readyBtn then
        readyBtn = findButtonByChildText(tradeGui, "Ready")
    end
    if readyBtn then
        print("[Auto Trade] Auto-clicking READY!")
        clickBtn(readyBtn)
        return true
    end
    return false
end

local function tryConfirmTrade(tradeGui)
    if not (hasText(tradeGui, "Confirmed!") or hasTextMatch(tradeGui, "%d+s Left")) then return false end

    local acceptBtn = findButtonByChildText(tradeGui, "ACCEPT")
    if not acceptBtn then
        acceptBtn = findButtonByChildText(tradeGui, "Accept")
    end
    if not acceptBtn then
        acceptBtn = findImageButton(tradeGui, "Yes")
    end
    if acceptBtn then
        print("[Auto Trade] Auto-confirming trade!")
        clickBtn(acceptBtn)
        return true
    end
    return false
end

local function checkAndAct()
    local tradeGui = PlayerGui:FindFirstChild("DuelsMachinePrompt")
    if not tradeGui then return end

    if tryAcceptTradeRequest(tradeGui) then return end
    if tryClickReady(tradeGui) then return end
    if tryConfirmTrade(tradeGui) then return end
end

-- Event triggers for instant reaction
local function setupEvents(gui)
    gui.DescendantAdded:Connect(function(desc)
        task.wait(0.15)
        pcall(checkAndAct)
    end)
end

for _, gui in ipairs(PlayerGui:GetChildren()) do
    if gui.Name == "DuelsMachinePrompt" then
        pcall(function() setupEvents(gui) end)
    end
end

PlayerGui.ChildAdded:Connect(function(gui)
    if gui.Name == "DuelsMachinePrompt" then
        task.wait(0.1)
        pcall(function() setupEvents(gui) end)
        pcall(checkAndAct)
    end
end)

-- Backup polling loop
spawn(function()
    while task.wait(0.3) do
        pcall(checkAndAct)
    end
end)

print("=============================================")
print("[Auto Trade] Script loaded! (Volt)")
print("[Auto Trade] Mode: FULLY AUTOMATIC")
print("[Auto Trade] Click: firesignal")
print("[Auto Trade] Auto Accept: ON")
print("[Auto Trade] Auto Ready: ON")
print("[Auto Trade] Auto Confirm: ON")
print("=============================================")
