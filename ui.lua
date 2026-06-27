-- SimpleUI Library v1
local UI = {}
UI.__index = UI

local Players = game:GetService("Players")
local UserInput = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local function makeDraggable(frame, handle)
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInput.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                       startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function UI.new(title)
    local self = setmetatable({}, UI)
    local gui = Instance.new("ScreenGui")
    gui.Name = "SimpleUI"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = (gethui and gethui()) or game:GetService("CoreGui")

    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 240, 0, 320)
    main.Position = UDim2.new(0.5, -120, 0.5, -160)
    main.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
    main.BorderSizePixel = 0
    main.Parent = gui
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 6)

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 0, 32)
    bar.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
    bar.BorderSizePixel = 0
    bar.Parent = main
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = title or "Menu"
    label.TextColor3 = Color3.fromRGB(235, 235, 240)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.Parent = bar

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -16, 1, -44)
    container.Position = UDim2.new(0, 8, 0, 40)
    container.BackgroundTransparency = 1
    container.Parent = main

    local list = Instance.new("UIListLayout", container)
    list.Padding = UDim.new(0, 6)
    list.SortOrder = Enum.SortOrder.LayoutOrder

    makeDraggable(main, bar)
    self.container = container
    self.gui = gui
    return self
end

function UI:Button(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(230, 230, 235)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.Parent = self.container
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    btn.MouseButton1Click:Connect(function() pcall(callback) end)
    return btn
end

function UI:Toggle(text, default, callback)
    local state = default or false
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.TextColor3 = Color3.fromRGB(230, 230, 235)
    btn.Parent = self.container
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    local function refresh()
        btn.Text = text .. "  [" .. (state and "ON" or "OFF") .. "]"
        btn.BackgroundColor3 = state and Color3.fromRGB(50, 110, 70)
                                       or Color3.fromRGB(45, 45, 52)
    end
    refresh()
    btn.MouseButton1Click:Connect(function()
        state = not state
        refresh()
        pcall(callback, state)
    end)
    return btn
end

function UI:Slider(text, min, max, default, callback)
    local val = default or min
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 40)
    holder.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
    holder.BorderSizePixel = 0
    holder.Parent = self.container
    Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 4)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -10, 0, 18)
    lbl.Position = UDim2.new(0, 5, 0, 2)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(230, 230, 235)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = text .. ": " .. val
    lbl.Parent = holder

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -10, 0, 6)
    track.Position = UDim2.new(0, 5, 0, 26)
    track.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    track.BorderSizePixel = 0
    track.Parent = holder
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(90, 140, 210)
    fill.BorderSizePixel = 0
    fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local sliding = false
    local function update(x)
        local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        val = math.floor(min + (max - min) * rel)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        lbl.Text = text .. ": " .. val
        pcall(callback, val)
    end
    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true; update(i.Position.X) end
    end)
    UserInput.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
    end)
    UserInput.InputChanged:Connect(function(i)
        if sliding and i.UserInputType == Enum.UserInputType.MouseMovement then update(i.Position.X) end
    end)
    return holder
end

return UI