-- Auto Trade Script for Steal a Brainrot (Volt)
-- Uses RemoteEvents directly (no GUI clicking needed!)
-- TradeService/Accept -> accept invite
-- TradeService/Ready -> click ready
-- TradeService/Accept -> confirm trade
-- DuelsMachineService/AcceptInvite -> accept duel invite

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Find RemoteEvents
local Net = RS:WaitForChild("Packages"):WaitForChild("Net")
local RE = Net:WaitForChild("RE")
local RF = Net:WaitForChild("RF")

local tradeReady = RE:FindFirstChild("TradeService/Ready")
local tradeAccept = RE:FindFirstChild("TradeService/Accept")
local duelAcceptInvite = RE:FindFirstChild("DuelsMachineService/AcceptInvite")

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

-- Check if ReadyButton is green
local function isGreen(element)
    if not element then return false end
    local color = element.BackgroundColor3
    local g = math.floor(color.G * 255)
    local r = math.floor(color.R * 255)
    return g > 140 and g > r + 20
end

local readyFired = false

print("=============================================")
print("[Auto Trade] Script loaded! (Volt)")
print("[Auto Trade] Method: RemoteEvent FireServer")
print("[Auto Trade] TradeService/Ready: " .. tostring(tradeReady ~= nil))
print("[Auto Trade] TradeService/Accept: " .. tostring(tradeAccept ~= nil))
print("[Auto Trade] DuelsMachineService/AcceptInvite: " .. tostring(duelAcceptInvite ~= nil))
print("[Auto Trade] Triggers:")
print("  1. Accept trade request")
print("  2. Ready when button turns green")
print("  3. Accept confirmation")
print("=============================================")

-- Watch for ReadyButton color change -> fire Ready
local function watchReadyButton(tlt)
    local readyBtn = findByName(tlt, "ImageButton", "ReadyButton")
    if not readyBtn then return end

    readyBtn:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
        if isGreen(readyBtn) and not readyFired then
            readyFired = true
            print("[Auto Trade] ReadyButton GREEN -> firing TradeService/Ready!")
            if tradeReady then
                pcall(function() tradeReady:FireServer() end)
            end
        end
    end)
end

PlayerGui.ChildAdded:Connect(function(child)
    if child.Name == "TradeLiveTrade" then
        readyFired = false
        task.wait(0.5)
        pcall(function() watchReadyButton(child) end)
    end
end)

local existing = PlayerGui:FindFirstChild("TradeLiveTrade")
if existing then
    pcall(function() watchReadyButton(existing) end)
end

-- Main loop
while task.wait(0.5) do
    pcall(function()
        -- STAGE 1: Accept trade request
        local dmp = PlayerGui:FindFirstChild("DuelsMachinePrompt")
        if dmp then
            if hasTextLabel(dmp, "Trade Request") and hasTextMatch(dmp, "wants to trade") then
                print("[Auto Trade] Trade Request -> AcceptInvite!")
                if duelAcceptInvite then
                    pcall(function() duelAcceptInvite:FireServer() end)
                end
                task.wait(1)
                return
            end
        end

        local tp = PlayerGui:FindFirstChild("TradePrompts")
        if tp then
            if hasTextLabel(tp, "Trade Request") and hasTextMatch(tp, "wants to trade") then
                print("[Auto Trade] Trade Request -> AcceptInvite! (TradePrompts)")
                if duelAcceptInvite then
                    pcall(function() duelAcceptInvite:FireServer() end)
                end
                task.wait(1)
                return
            end
        end

        -- STAGE 2+3: Trade menu
        local tlt = PlayerGui:FindFirstChild("TradeLiveTrade")
        if tlt then
            -- Confirmation stage -> Accept
            if hasTextLabel(tlt, "Confirmed!") or hasTextMatch(tlt, "%d+s Left") then
                print("[Auto Trade] Confirmation -> TradeService/Accept!")
                if tradeAccept then
                    pcall(function() tradeAccept:FireServer() end)
                end
                return
            end

            -- Ready stage -> backup polling
            local readyBtn = findByName(tlt, "ImageButton", "ReadyButton")
            if readyBtn and isGreen(readyBtn) and not readyFired then
                readyFired = true
                print("[Auto Trade] ReadyButton GREEN -> TradeService/Ready!")
                if tradeReady then
                    pcall(function() tradeReady:FireServer() end)
                end
            end
        else
            readyFired = false
        end
    end)
end
