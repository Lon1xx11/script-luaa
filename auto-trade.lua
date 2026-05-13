-- Auto Trade Script for Steal a Brainrot
-- 1. Auto-accept incoming trade requests
-- 2. Auto-ready when the other player offers a brainrot
-- 3. Auto-accept trade confirmation

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local CHECK_INTERVAL = 0.15

local function findButtonByText(parent, targetText)
    for _, desc in ipairs(parent:GetDescendants()) do
        if (desc:IsA("TextButton") or desc:IsA("ImageButton")) and desc.Visible then
            local textLabel = desc:FindFirstChildOfClass("TextLabel")
            if textLabel and string.lower(textLabel.Text) == string.lower(targetText) then
                return desc
            end
            if desc:IsA("TextButton") and string.lower(desc.Text) == string.lower(targetText) then
                return desc
            end
        end
    end
    return nil
end

local function findVisibleFrameWithText(parent, targetText)
    for _, desc in ipairs(parent:GetDescendants()) do
        if desc:IsA("TextLabel") and string.lower(desc.Text) == string.lower(targetText) then
            return desc
        end
    end
    return nil
end

local function hasOtherPlayerOfferedItems(tradeGui)
    for _, desc in ipairs(tradeGui:GetDescendants()) do
        if desc:IsA("TextLabel") then
            local text = desc.Text
            if string.match(text, "Offer") and string.match(text, "@") then
                local parent = desc.Parent
                if parent then
                    for _, child in ipairs(parent:GetDescendants()) do
                        if (child:IsA("ImageLabel") or child:IsA("Frame")) and child.Visible then
                            local nameLabel = child:FindFirstChildOfClass("TextLabel")
                            if nameLabel and nameLabel.Text ~= "" and not string.match(nameLabel.Text, "Offer") then
                                return true
                            end
                        end
                    end
                end
            end
        end
    end
    return false
end

local function clickButton(button)
    if button and button:IsA("GuiButton") then
        local connection
        local clicked = false
        pcall(function()
            button:Activate()
            clicked = true
        end)
        if not clicked then
            pcall(function()
                firesignal(button.MouseButton1Click)
            end)
        end
        if not clicked then
            pcall(function()
                fireclickdetector(button)
            end)
        end
    end
end

local autoAcceptEnabled = true
local autoReadyEnabled = true
local autoConfirmEnabled = true

local function checkTradeRequest()
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled then
            local tradeRequestLabel = findVisibleFrameWithText(gui, "Trade Request")
            if not tradeRequestLabel then
                for _, desc in ipairs(gui:GetDescendants()) do
                    if desc:IsA("TextLabel") and string.match(desc.Text, "wants to trade") then
                        tradeRequestLabel = desc
                        break
                    end
                end
            end

            if tradeRequestLabel then
                local acceptBtn = findButtonByText(gui, "Accept")
                if acceptBtn then
                    return acceptBtn
                end
            end
        end
    end
    return nil
end

local function checkTradeReady()
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled then
            local tradeLabel = findVisibleFrameWithText(gui, "Trade")
            local selectLabel = findVisibleFrameWithText(gui, "Select Brainrots to offer")

            if tradeLabel and selectLabel then
                if hasOtherPlayerOfferedItems(gui) then
                    local readyBtn = findButtonByText(gui, "READY")
                    if readyBtn then
                        return readyBtn
                    end
                end
            end
        end
    end
    return nil
end

local function checkTradeConfirmation()
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled then
            local confirmedLabel = findVisibleFrameWithText(gui, "Confirmed!")
            if confirmedLabel then
                local acceptBtn = findButtonByText(gui, "ACCEPT")
                if acceptBtn then
                    return acceptBtn
                end
            end

            for _, desc in ipairs(gui:GetDescendants()) do
                if desc:IsA("TextLabel") and string.match(desc.Text, "%d+s Left") then
                    local acceptBtn = findButtonByText(gui, "ACCEPT")
                    if acceptBtn then
                        local readyBtn = findButtonByText(gui, "READY")
                        if not readyBtn then
                            return acceptBtn
                        end
                    end
                end
            end
        end
    end
    return nil
end

print("[Auto Trade] Script loaded!")
print("[Auto Trade] Auto Accept: ON")
print("[Auto Trade] Auto Ready: ON")
print("[Auto Trade] Auto Confirm: ON")

while task.wait(CHECK_INTERVAL) do
    pcall(function()
        if autoAcceptEnabled then
            local acceptBtn = checkTradeRequest()
            if acceptBtn then
                print("[Auto Trade] Accepting trade request...")
                clickButton(acceptBtn)
                task.wait(0.5)
            end
        end

        if autoReadyEnabled then
            local readyBtn = checkTradeReady()
            if readyBtn then
                print("[Auto Trade] Other player offered items, clicking Ready...")
                clickButton(readyBtn)
                task.wait(0.5)
            end
        end

        if autoConfirmEnabled then
            local confirmBtn = checkTradeConfirmation()
            if confirmBtn then
                print("[Auto Trade] Confirming trade...")
                clickButton(confirmBtn)
                task.wait(0.5)
            end
        end
    end)
end
