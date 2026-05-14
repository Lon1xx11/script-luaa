-- Auto Trade Script for Steal a Brainrot (Volt)
-- Fully automatic, no keybind
-- Accept: DuelsMachinePrompt -> Yes or TradePrompts -> Yes
-- Ready/Confirm: TradeLiveTrade -> ReadyButton

local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local VIM = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local guiInset = GuiService:GetGuiInset()

local function clickElement(element)
    if not element then return end
    local pos = element.AbsolutePosition
    local size = element.AbsoluteSize
    local x = pos.X + size.X / 2
    local y = pos.Y + size.Y / 2 + guiInset.Y

    -- VirtualInputManager mouse click
    pcall(function()
        VIM:SendMouseButtonEvent(x, y, 0, true, game, 1)
        task.wait(0.05)
        VIM:SendMouseButtonEvent(x, y, 0, false, game, 1)
    end)

    -- firesignal backup
    pcall(function()
        firesignal(element.MouseButton1Click)
    end)
    pcall(function()
        firesignal(element.MouseButton1Down)
        task.wait(0.05)
        firesignal(element.MouseButton1Up)
    end)
end

local function findByName(parent, className, name)
    for _, desc in ipairs(parent:GetDescendants()) do
        if desc:IsA(className) and desc.Name == name and desc.Visible then
            return desc
        end
    end
    return nil
end

print("=============================================")
print("[Auto Trade] Script loaded! (Volt)")
print("[Auto Trade] GuiInset Y = " .. guiInset.Y)
print("[Auto Trade] Auto Accept + Ready + Confirm: ON")
print("=============================================")

while task.wait(0.5) do
    pcall(function()
        -- STAGE 1: Accept trade request
        local dmp = PlayerGui:FindFirstChild("DuelsMachinePrompt")
        if dmp then
            local yesBtn = findByName(dmp, "ImageButton", "Yes")
            if yesBtn then
                clickElement(yesBtn)
                task.wait(0.5)
            end
        end

        local tp = PlayerGui:FindFirstChild("TradePrompts")
        if tp then
            local yesBtn = findByName(tp, "ImageButton", "Yes")
            if yesBtn then
                clickElement(yesBtn)
                task.wait(0.5)
            end
        end

        -- STAGE 2+3: Ready / Accept confirmation
        local tlt = PlayerGui:FindFirstChild("TradeLiveTrade")
        if tlt then
            local readyBtn = findByName(tlt, "ImageButton", "ReadyButton")
            if readyBtn then
                clickElement(readyBtn)
            end
        end
    end)
end
