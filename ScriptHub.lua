-- ScriptHub Library v1.0
-- Загрузка: loadstring(game:HttpGet("https://raw.githubusercontent.com/ТВОЙ_НИК/ТВОЙ_РЕП/main/ScriptHub.lua"))()

local Library = {}
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- GUI
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TitleBar = Instance.new("Frame")
local TitleLabel = Instance.new("TextLabel")
local CloseBtn = Instance.new("TextButton")
local TabHolder = Instance.new("Frame")
local TabLayout = Instance.new("UIListLayout")
local ContentHolder = Instance.new("Frame")
local StatusBar = Instance.new("Frame")
local StatusLabel = Instance.new("TextLabel")
local Watermark = Instance.new("Frame")
local WatermarkLabel = Instance.new("TextLabel")

-- Защита GUI
if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
end
ScreenGui.Name = "ScriptHub"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

-- Watermark (верхний левый угол)
Watermark.Name = "Watermark"
Watermark.Parent = ScreenGui
Watermark.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
Watermark.BorderColor3 = Color3.fromRGB(50, 50, 50)
Watermark.BorderSizePixel = 1
Watermark.Position = UDim2.new(0, 8, 0, 8)
Watermark.Size = UDim2.new(0, 280, 0, 22)

WatermarkLabel.Parent = Watermark
WatermarkLabel.BackgroundTransparency = 1
WatermarkLabel.Size = UDim2.new(1, 0, 1, 0)
WatermarkLabel.Font = Enum.Font.Code
WatermarkLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
WatermarkLabel.TextSize = 11
WatermarkLabel.TextXAlignment = Enum.TextXAlignment.Left
WatermarkLabel.Text = "  SCRIPT HUB  |  PLAYER  |  FPS: 60  |  PING: 0ms"

-- Обновление watermark в реальном времени
local fps = 60
local frameCount = 0
local lastTime = tick()
RunService.RenderStepped:Connect(function()
    frameCount += 1
    local now = tick()
    if now - lastTime >= 1 then
        fps = frameCount
        frameCount = 0
        lastTime = now
    end
    local ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
    local name = LocalPlayer.Name
    WatermarkLabel.Text = "  " .. name .. "  |  FPS: " .. fps .. "  |  PING: " .. ping .. "ms"
end)

-- Главное окно
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
MainFrame.BorderColor3 = Color3.fromRGB(55, 55, 55)
MainFrame.BorderSizePixel = 1
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -200)
MainFrame.Size = UDim2.new(0, 580, 0, 420)
MainFrame.ClipsDescendants = true

-- Drag
do
    local dragging, dragInput, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Title Bar
TitleBar.Parent = MainFrame
TitleBar.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
TitleBar.BorderColor3 = Color3.fromRGB(30, 30, 30)
TitleBar.BorderSizePixel = 1
TitleBar.Size = UDim2.new(1, 0, 0, 28)

TitleLabel.Parent = TitleBar
TitleLabel.BackgroundTransparency = 1
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.Font = Enum.Font.Code
TitleLabel.Text = ":: SCRIPT HUB ::"
TitleLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
TitleLabel.TextSize = 11
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.TextStrokeTransparency = 0.8

CloseBtn.Parent = TitleBar
CloseBtn.BackgroundTransparency = 1
CloseBtn.Position = UDim2.new(1, -24, 0, 6)
CloseBtn.Size = UDim2.new(0, 16, 0, 16)
CloseBtn.Font = Enum.Font.Code
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(80, 80, 80)
CloseBtn.TextSize = 11
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- Tab Holder
TabHolder.Parent = MainFrame
TabHolder.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
TabHolder.BorderColor3 = Color3.fromRGB(25, 25, 25)
TabHolder.BorderSizePixel = 1
TabHolder.Position = UDim2.new(0, 0, 0, 28)
TabHolder.Size = UDim2.new(1, 0, 0, 24)

TabLayout.Parent = TabHolder
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Content
ContentHolder.Parent = MainFrame
ContentHolder.BackgroundTransparency = 1
ContentHolder.Position = UDim2.new(0, 0, 0, 52)
ContentHolder.Size = UDim2.new(1, 0, 1, -72)

-- Status bar
StatusBar.Parent = MainFrame
StatusBar.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
StatusBar.BorderColor3 = Color3.fromRGB(25, 25, 25)
StatusBar.BorderSizePixel = 1
StatusBar.Position = UDim2.new(0, 0, 1, -20)
StatusBar.Size = UDim2.new(1, 0, 0, 20)

StatusLabel.Parent = StatusBar
StatusLabel.BackgroundTransparency = 1
StatusLabel.Size = UDim2.new(1, -10, 1, 0)
StatusLabel.Position = UDim2.new(0, 8, 0, 0)
StatusLabel.Font = Enum.Font.Code
StatusLabel.Text = ":: SCRIPT HUB v1.0   |   RSHIFT — TOGGLE"
StatusLabel.TextColor3 = Color3.fromRGB(45, 45, 45)
StatusLabel.TextSize = 10
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Keybind toggle
local menuBind = Enum.KeyCode.RightShift
UserInputService.InputBegan:Connect(function(input, gpe)
    if input.KeyCode == menuBind then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- ==============================
-- LIBRARY FUNCTIONS
-- ==============================

local accentColor = Color3.fromRGB(255, 255, 255)
local tabs = {}
local currentTab = nil

local function makeTab(name)
    local tabBtn = Instance.new("TextButton")
    local tabPage = Instance.new("ScrollingFrame")
    local leftCol = Instance.new("Frame")
    local rightCol = Instance.new("Frame")
    local leftLayout = Instance.new("UIListLayout")
    local rightLayout = Instance.new("UIListLayout")

    tabBtn.Parent = TabHolder
    tabBtn.BackgroundTransparency = 1
    tabBtn.Size = UDim2.new(0, 80, 1, 0)
    tabBtn.Font = Enum.Font.Code
    tabBtn.Text = name:upper()
    tabBtn.TextColor3 = Color3.fromRGB(60, 60, 60)
    tabBtn.TextSize = 10
    tabBtn.BorderSizePixel = 0

    tabPage.Parent = ContentHolder
    tabPage.BackgroundTransparency = 1
    tabPage.BorderSizePixel = 0
    tabPage.Size = UDim2.new(1, 0, 1, 0)
    tabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabPage.ScrollBarThickness = 2
    tabPage.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 50)
    tabPage.Visible = false

    leftCol.Parent = tabPage
    leftCol.BackgroundTransparency = 1
    leftCol.Position = UDim2.new(0, 8, 0, 8)
    leftCol.Size = UDim2.new(0.5, -12, 1, 0)

    leftLayout.Parent = leftCol
    leftLayout.SortOrder = Enum.SortOrder.LayoutOrder
    leftLayout.Padding = UDim.new(0, 8)

    rightCol.Parent = tabPage
    rightCol.BackgroundTransparency = 1
    rightCol.Position = UDim2.new(0.5, 4, 0, 8)
    rightCol.Size = UDim2.new(0.5, -12, 1, 0)

    rightLayout.Parent = rightCol
    rightLayout.SortOrder = Enum.SortOrder.LayoutOrder
    rightLayout.Padding = UDim.new(0, 8)

    tabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do
            t.page.Visible = false
            t.btn.TextColor3 = Color3.fromRGB(60, 60, 60)
            t.btn.BorderSizePixel = 0
        end
        tabPage.Visible = true
        tabBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
        tabBtn.BorderSizePixel = 1
        tabBtn.BorderColor3 = Color3.fromRGB(80, 80, 80)
    end)

    local tab = {btn = tabBtn, page = tabPage, left = leftCol, right = rightCol}
    table.insert(tabs, tab)

    if #tabs == 1 then
        tabPage.Visible = true
        tabBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
    end

    local section = {}

    function section:Section(name, side)
        local col = side == "Right" and rightCol or leftCol
        local frame = Instance.new("Frame")
        local title = Instance.new("TextLabel")
        local body = Instance.new("Frame")
        local bodyLayout = Instance.new("UIListLayout")
        local bodyPad = Instance.new("UIPadding")

        frame.Parent = col
        frame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
        frame.BorderColor3 = Color3.fromRGB(30, 30, 30)
        frame.BorderSizePixel = 1
        frame.Size = UDim2.new(1, 0, 0, 28)
        frame.ClipsDescendants = false

        title.Parent = frame
        title.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
        title.BorderColor3 = Color3.fromRGB(25, 25, 25)
        title.BorderSizePixel = 1
        title.Size = UDim2.new(1, 0, 0, 18)
        title.Font = Enum.Font.Code
        title.Text = "// " .. name:upper()
        title.TextColor3 = Color3.fromRGB(70, 70, 70)
        title.TextSize = 9
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.TextStrokeTransparency = 0.8

        local titlePad = Instance.new("UIPadding")
        titlePad.Parent = title
        titlePad.PaddingLeft = UDim.new(0, 8)

        body.Parent = frame
        body.BackgroundTransparency = 1
        body.Position = UDim2.new(0, 0, 0, 18)
        body.Size = UDim2.new(1, 0, 0, 0)

        bodyLayout.Parent = body
        bodyLayout.SortOrder = Enum.SortOrder.LayoutOrder
        bodyLayout.Padding = UDim.new(0, 2)

        bodyPad.Parent = body
        bodyPad.PaddingLeft = UDim.new(0, 8)
        bodyPad.PaddingRight = UDim.new(0, 8)
        bodyPad.PaddingTop = UDim.new(0, 5)
        bodyPad.PaddingBottom = UDim.new(0, 5)

        local function updateSize()
            local h = bodyLayout.AbsoluteContentSize.Y + 28 + 10
            frame.Size = UDim2.new(1, 0, 0, h)
            body.Size = UDim2.new(1, 0, 0, h - 18)
            local total = leftCol:FindFirstChildOfClass("UIListLayout") and leftCol.UIListLayout.AbsoluteContentSize.Y or 0
            tabPage.CanvasSize = UDim2.new(0, 0, 0, total + 20)
        end

        bodyLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSize)

        local sec = {}

        function sec:Toggle(name, default, callback)
            local row = Instance.new("Frame")
            local lbl = Instance.new("TextLabel")
            local togFrame = Instance.new("Frame")
            local togInner = Instance.new("Frame")
            local togBtn = Instance.new("TextButton")

            row.Parent = body
            row.BackgroundTransparency = 1
            row.Size = UDim2.new(1, 0, 0, 18)

            lbl.Parent = row
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(0.7, 0, 1, 0)
            lbl.Font = Enum.Font.Code
            lbl.Text = name
            lbl.TextColor3 = Color3.fromRGB(140, 140, 140)
            lbl.TextSize = 11
            lbl.TextXAlignment = Enum.TextXAlignment.Left

            togFrame.Parent = row
            togFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
            togFrame.BorderColor3 = Color3.fromRGB(40, 40, 40)
            togFrame.BorderSizePixel = 1
            togFrame.Position = UDim2.new(1, -28, 0.5, -7)
            togFrame.Size = UDim2.new(0, 28, 0, 14)

            togInner.Parent = togFrame
            togInner.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            togInner.BorderSizePixel = 0
            togInner.Size = UDim2.new(0, 10, 0, 10)
            togInner.Position = UDim2.new(0, 1, 0.5, -5)

            togBtn.Parent = togFrame
            togBtn.BackgroundTransparency = 1
            togBtn.BorderSizePixel = 0
            togBtn.Size = UDim2.new(1, 0, 1, 0)
            togBtn.Text = ""

            local state = default or false
            local function updateVisual()
                if state then
                    TweenService:Create(togInner, TweenInfo.new(0.1), {Position = UDim2.new(0, 15, 0.5, -5), BackgroundColor3 = accentColor}):Play()
                    TweenService:Create(togFrame, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(20, 20, 20)}):Play()
                    lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
                else
                    TweenService:Create(togInner, TweenInfo.new(0.1), {Position = UDim2.new(0, 1, 0.5, -5), BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
                    lbl.TextColor3 = Color3.fromRGB(140, 140, 140)
                end
            end
            updateVisual()
            togBtn.MouseButton1Click:Connect(function()
                state = not state
                updateVisual()
                if callback then callback(state) end
            end)
            return togBtn
        end

        function sec:Slider(name, min, max, default, suffix, callback)
            local wrap = Instance.new("Frame")
            local lbl = Instance.new("TextLabel")
            local valLbl = Instance.new("TextLabel")
            local track = Instance.new("Frame")
            local fill = Instance.new("Frame")
            local btn = Instance.new("TextButton")

            suffix = suffix or ""

            wrap.Parent = body
            wrap.BackgroundTransparency = 1
            wrap.Size = UDim2.new(1, 0, 0, 28)

            lbl.Parent = wrap
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(0.6, 0, 0, 14)
            lbl.Font = Enum.Font.Code
            lbl.Text = name
            lbl.TextColor3 = Color3.fromRGB(140, 140, 140)
            lbl.TextSize = 11
            lbl.TextXAlignment = Enum.TextXAlignment.Left

            valLbl.Parent = wrap
            valLbl.BackgroundTransparency = 1
            valLbl.Position = UDim2.new(0.6, 0, 0, 0)
            valLbl.Size = UDim2.new(0.4, 0, 0, 14)
            valLbl.Font = Enum.Font.Code
            valLbl.Text = tostring(default or min) .. suffix
            valLbl.TextColor3 = Color3.fromRGB(100, 100, 100)
            valLbl.TextSize = 10
            valLbl.TextXAlignment = Enum.TextXAlignment.Right

            track.Parent = wrap
            track.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
            track.BorderColor3 = Color3.fromRGB(30, 30, 30)
            track.BorderSizePixel = 1
            track.Position = UDim2.new(0, 0, 0, 17)
            track.Size = UDim2.new(1, 0, 0, 6)

            fill.Parent = track
            fill.BackgroundColor3 = accentColor
            fill.BorderSizePixel = 0
            fill.Size = UDim2.new(((default or min) - min) / (max - min), 0, 1, 0)

            btn.Parent = track
            btn.BackgroundTransparency = 1
            btn.BorderSizePixel = 0
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.Text = ""

            local sliding = false
            btn.MouseButton1Down:Connect(function()
                sliding = true
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if sliding and i.UserInputType == Enum.UserInputType.MouseMovement then
                    local abs = track.AbsolutePosition
                    local sz = track.AbsoluteSize
                    local pct = math.clamp((i.Position.X - abs.X) / sz.X, 0, 1)
                    local val = math.floor(min + pct * (max - min))
                    fill.Size = UDim2.new(pct, 0, 1, 0)
                    valLbl.Text = tostring(val) .. suffix
                    if callback then callback(val) end
                end
            end)
        end

        function sec:Button(name, callback)
            local btn = Instance.new("TextButton")
            btn.Parent = body
            btn.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
            btn.BorderColor3 = Color3.fromRGB(35, 35, 35)
            btn.BorderSizePixel = 1
            btn.Size = UDim2.new(1, 0, 0, 18)
            btn.Font = Enum.Font.Code
            btn.Text = name:upper()
            btn.TextColor3 = Color3.fromRGB(120, 120, 120)
            btn.TextSize = 10
            btn.MouseEnter:Connect(function()
                btn.TextColor3 = Color3.fromRGB(220, 220, 220)
                btn.BorderColor3 = Color3.fromRGB(80, 80, 80)
            end)
            btn.MouseLeave:Connect(function()
                btn.TextColor3 = Color3.fromRGB(120, 120, 120)
                btn.BorderColor3 = Color3.fromRGB(35, 35, 35)
            end)
            btn.MouseButton1Click:Connect(function()
                if callback then callback() end
            end)
        end

        function sec:Dropdown(name, options, callback)
            local wrap = Instance.new("Frame")
            local lbl = Instance.new("TextLabel")
            local box = Instance.new("TextButton")
            local boxLbl = Instance.new("TextLabel")
            local optHolder = Instance.new("Frame")
            local optLayout = Instance.new("UIListLayout")

            wrap.Parent = body
            wrap.BackgroundTransparency = 1
            wrap.Size = UDim2.new(1, 0, 0, 18)
            wrap.ClipsDescendants = false
            wrap.ZIndex = 5

            lbl.Parent = wrap
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(0.5, 0, 1, 0)
            lbl.Font = Enum.Font.Code
            lbl.Text = name
            lbl.TextColor3 = Color3.fromRGB(140, 140, 140)
            lbl.TextSize = 11
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.ZIndex = 5

            box.Parent = wrap
            box.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
            box.BorderColor3 = Color3.fromRGB(35, 35, 35)
            box.BorderSizePixel = 1
            box.Position = UDim2.new(0.5, 0, 0, 0)
            box.Size = UDim2.new(0.5, 0, 1, 0)
            box.Font = Enum.Font.Code
            box.Text = ""
            box.ZIndex = 5

            boxLbl.Parent = box
            boxLbl.BackgroundTransparency = 1
            boxLbl.Size = UDim2.new(1, -6, 1, 0)
            boxLbl.Position = UDim2.new(0, 4, 0, 0)
            boxLbl.Font = Enum.Font.Code
            boxLbl.Text = options[1] or ""
            boxLbl.TextColor3 = Color3.fromRGB(160, 160, 160)
            boxLbl.TextSize = 10
            boxLbl.TextXAlignment = Enum.TextXAlignment.Left
            boxLbl.ZIndex = 5

            optHolder.Parent = wrap
            optHolder.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
            optHolder.BorderColor3 = Color3.fromRGB(45, 45, 45)
            optHolder.BorderSizePixel = 1
            optHolder.Position = UDim2.new(0.5, 0, 1, 0)
            optHolder.Size = UDim2.new(0.5, 0, 0, #options * 18)
            optHolder.Visible = false
            optHolder.ZIndex = 10

            optLayout.Parent = optHolder
            optLayout.SortOrder = Enum.SortOrder.LayoutOrder

            for _, opt in ipairs(options) do
                local ob = Instance.new("TextButton")
                ob.Parent = optHolder
                ob.BackgroundTransparency = 1
                ob.BorderSizePixel = 0
                ob.Size = UDim2.new(1, 0, 0, 18)
                ob.Font = Enum.Font.Code
                ob.Text = opt
                ob.TextColor3 = Color3.fromRGB(120, 120, 120)
                ob.TextSize = 10
                ob.ZIndex = 10
                ob.MouseEnter:Connect(function() ob.TextColor3 = Color3.fromRGB(220,220,220) end)
                ob.MouseLeave:Connect(function() ob.TextColor3 = Color3.fromRGB(120,120,120) end)
                ob.MouseButton1Click:Connect(function()
                    boxLbl.Text = opt
                    optHolder.Visible = false
                    if callback then callback(opt) end
                end)
            end

            box.MouseButton1Click:Connect(function()
                optHolder.Visible = not optHolder.Visible
            end)
        end

        function sec:Textbox(name, placeholder, callback)
            local wrap = Instance.new("Frame")
            local lbl = Instance.new("TextLabel")
            local box = Instance.new("TextBox")

            wrap.Parent = body
            wrap.BackgroundTransparency = 1
            wrap.Size = UDim2.new(1, 0, 0, 28)

            lbl.Parent = wrap
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(1, 0, 0, 12)
            lbl.Font = Enum.Font.Code
            lbl.Text = name
            lbl.TextColor3 = Color3.fromRGB(100, 100, 100)
            lbl.TextSize = 10
            lbl.TextXAlignment = Enum.TextXAlignment.Left

            box.Parent = wrap
            box.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
            box.BorderColor3 = Color3.fromRGB(35, 35, 35)
            box.BorderSizePixel = 1
            box.Position = UDim2.new(0, 0, 0, 13)
            box.Size = UDim2.new(1, 0, 0, 14)
            box.Font = Enum.Font.Code
            box.PlaceholderText = placeholder or ""
            box.PlaceholderColor3 = Color3.fromRGB(55, 55, 55)
            box.Text = ""
            box.TextColor3 = Color3.fromRGB(180, 180, 180)
            box.TextSize = 10
            box.TextXAlignment = Enum.TextXAlignment.Left
            box.ClearTextOnFocus = false

            local pad = Instance.new("UIPadding")
            pad.Parent = box
            pad.PaddingLeft = UDim.new(0, 4)

            box:GetPropertyChangedSignal("Text"):Connect(function()
                if callback then callback(box.Text) end
            end)
        end

        function sec:Keybind(name, default, callback)
            local row = Instance.new("Frame")
            local lbl = Instance.new("TextLabel")
            local kb = Instance.new("TextButton")
            local waiting = false

            row.Parent = body
            row.BackgroundTransparency = 1
            row.Size = UDim2.new(1, 0, 0, 18)

            lbl.Parent = row
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(0.65, 0, 1, 0)
            lbl.Font = Enum.Font.Code
            lbl.Text = name
            lbl.TextColor3 = Color3.fromRGB(140, 140, 140)
            lbl.TextSize = 11
            lbl.TextXAlignment = Enum.TextXAlignment.Left

            kb.Parent = row
            kb.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
            kb.BorderColor3 = Color3.fromRGB(35, 35, 35)
            kb.BorderSizePixel = 1
            kb.Position = UDim2.new(0.65, 0, 0.5, -8)
            kb.Size = UDim2.new(0.35, 0, 0, 16)
            kb.Font = Enum.Font.Code
            kb.Text = default and tostring(default):gsub("Enum.KeyCode.","") or "--"
            kb.TextColor3 = Color3.fromRGB(100, 100, 100)
            kb.TextSize = 9

            kb.MouseButton1Click:Connect(function()
                waiting = true
                kb.Text = "..."
                kb.TextColor3 = Color3.fromRGB(200, 200, 200)
            end)

            UserInputService.InputBegan:Connect(function(input, gpe)
                if waiting and input.KeyCode ~= Enum.KeyCode.Unknown then
                    waiting = false
                    local keyName = tostring(input.KeyCode):gsub("Enum.KeyCode.","")
                    kb.Text = keyName
                    kb.TextColor3 = Color3.fromRGB(100, 100, 100)
                    if callback then callback(input.KeyCode) end
                end
            end)
        end

        function sec:ColorPicker(name, default, callback)
            local row = Instance.new("Frame")
            local lbl = Instance.new("TextLabel")
            local box = Instance.new("Frame")
            local btn = Instance.new("TextButton")

            row.Parent = body
            row.BackgroundTransparency = 1
            row.Size = UDim2.new(1, 0, 0, 18)

            lbl.Parent = row
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(0.75, 0, 1, 0)
            lbl.Font = Enum.Font.Code
            lbl.Text = name
            lbl.TextColor3 = Color3.fromRGB(140, 140, 140)
            lbl.TextSize = 11
            lbl.TextXAlignment = Enum.TextXAlignment.Left

            box.Parent = row
            box.BackgroundColor3 = default or Color3.fromRGB(255, 255, 255)
            box.BorderColor3 = Color3.fromRGB(60, 60, 60)
            box.BorderSizePixel = 1
            box.Position = UDim2.new(1, -18, 0.5, -7)
            box.Size = UDim2.new(0, 18, 0, 14)

            btn.Parent = box
            btn.BackgroundTransparency = 1
            btn.BorderSizePixel = 0
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.Text = ""
        end

        function sec:Divider()
            local div = Instance.new("Frame")
            div.Parent = body
            div.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            div.BorderSizePixel = 0
            div.Size = UDim2.new(1, 0, 0, 1)
        end

        return sec
    end

    return section
end

-- ==============================
-- TABS
-- ==============================
local combatTab = makeTab("Combat")
local visualTab = makeTab("Visual")
local cosmTab   = makeTab("Cosmetics")
local moveTab   = makeTab("Movement")
local miscTab   = makeTab("Misc")
local setTab    = makeTab("Settings")

-- COMBAT
local aimSec  = combatTab:Section("Aimbot", "Left")
local predSec = combatTab:Section("Prediction", "Right")

aimSec:Toggle("Aimbot", false, function(v) end)
aimSec:Toggle("Silent Aim", false, function(v) end)
aimSec:Toggle("Triggerbot", false, function(v) end)
aimSec:Divider()
aimSec:Slider("FOV", 1, 360, 90, "°", function(v) end)
aimSec:Slider("Silent Chance", 0, 100, 100, "%", function(v) end)
aimSec:Dropdown("Aim Part", {"Head","Torso","HumanoidRootPart"}, function(v) end)

predSec:Toggle("Prediction", false, function(v) end)
predSec:Slider("Pred Value", 0, 100, 14, "", function(v) end)
predSec:Toggle("Check Walls", true, function(v) end)
predSec:Toggle("Team Check", true, function(v) end)

-- VISUAL
local espSec   = visualTab:Section("ESP", "Left")
local chamsSec = visualTab:Section("Chams", "Right")

espSec:Toggle("ESP", false, function(v) end)
espSec:Toggle("Box ESP", false, function(v) end)
espSec:Toggle("Name ESP", false, function(v) end)
espSec:Toggle("Health Bar", false, function(v) end)
espSec:Toggle("Distance", false, function(v) end)
espSec:Divider()
espSec:Slider("Max Distance", 0, 1000, 500, "st", function(v) end)
espSec:ColorPicker("ESP Color", Color3.fromRGB(255,255,255), function(v) end)

chamsSec:Toggle("Chams", false, function(v) end)
chamsSec:Toggle("Visible Only", false, function(v) end)
chamsSec:ColorPicker("Chams Color", Color3.fromRGB(200,200,200), function(v) end)

-- COSMETICS
local chatSec = cosmTab:Section("Chat", "Left")
local charSec = cosmTab:Section("Character", "Right")

chatSec:Toggle("Chat Prefix", false, function(v) end)
chatSec:Textbox("Prefix Text", "[SCRIPT]", function(v) end)
chatSec:Toggle("Chat Suffix", false, function(v) end)
chatSec:Textbox("Suffix Text", "suffix...", function(v) end)

charSec:Toggle("Hide Accessories", false, function(v) end)
charSec:Toggle("Custom Body Color", false, function(v) end)
charSec:ColorPicker("Body Color", Color3.fromRGB(255,200,150), function(v) end)

-- MOVEMENT
local spdSec = moveTab:Section("Speed", "Left")
local flySec = moveTab:Section("Fly", "Right")

spdSec:Toggle("Speed Hack", false, function(v) end)
spdSec:Slider("Speed", 0, 100, 16, "", function(v)
    if v and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v end
    end
end)
spdSec:Dropdown("Speed Mode", {"Default","Custom","Fly"}, function(v) end)

flySec:Toggle("Fly", false, function(v) end)
flySec:Slider("Fly Speed", 0, 200, 50, "", function(v) end)
flySec:Toggle("Noclip", false, function(v) end)
flySec:Toggle("Infinite Jump", false, function(v)
    if v then
        UserInputService.JumpRequest:Connect(function()
            if LocalPlayer.Character then
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end)
    end
end)

-- MISC
local miscSec = miscTab:Section("Misc", "Left")
local spamSec = miscTab:Section("Chat Spam", "Right")

miscSec:Toggle("Anti-AFK", false, function(v) end)
miscSec:Toggle("Fullbright", false, function(v)
    game:GetService("Lighting").Brightness = v and 10 or 1
end)
miscSec:Toggle("Unlock FPS", false, function(v)
    if setfpscap then setfpscap(v and 0 or 60) end
end)
miscSec:Divider()
miscSec:Button("Copy JobId", function()
    if setclipboard then setclipboard(game.JobId) end
end)
miscSec:Button("Rejoin", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId)
end)

spamSec:Toggle("Chat Spam", false, function(v) end)
spamSec:Textbox("Message", "Message...", function(v) end)
spamSec:Slider("Delay", 1, 10, 2, "s", function(v) end)

-- SETTINGS
local bindSec   = setTab:Section("Keybinds", "Left")
local themeSec  = setTab:Section("Theme", "Left")
local cfgSec    = setTab:Section("Configs", "Right")

bindSec:Keybind("Toggle Menu", Enum.KeyCode.RightShift, function(key)
    menuBind = key
end)
bindSec:Keybind("Aimbot Key", nil, function(key) end)

themeSec:ColorPicker("Accent Color", Color3.fromRGB(255,255,255), function(color)
    accentColor = color
end)
themeSec:Toggle("Show Watermark", true, function(v)
    Watermark.Visible = v
end)

-- Config система
local configs = {}
if not isfolder("ScriptHub") then makefolder("ScriptHub") end

local function refreshConfigs()
    configs = {}
    for _, f in ipairs(listfiles("ScriptHub")) do
        table.insert(configs, f:gsub("ScriptHub/",""):gsub("ScriptHub\\",""))
    end
end

refreshConfigs()

cfgSec:Textbox("Config Name", "myconfig", function(v) end)
cfgSec:Button("Save Config", function()
    -- логика сохранения конфига
end)
cfgSec:Button("Load Config", function()
    -- логика загрузки конфига
end)
cfgSec:Button("Delete Config", function()
    -- логика удаления конфига
end)
