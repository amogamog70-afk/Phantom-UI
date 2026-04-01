-- Phantom-UI v1.0
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/ТВОЙник/ТВОЙреп/main/PhantomUI.lua"))()

local Library = {}
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

if not isfolder("PhantomUI") then makefolder("PhantomUI") end

-- ==============================
-- SCREEN GUI
-- ==============================
local ScreenGui = Instance.new("ScreenGui")
if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end
ScreenGui.Name = "PhantomUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game:GetService("CoreGui")

-- ==============================
-- WATERMARK
-- ==============================
local WMFrame = Instance.new("Frame")
local WMStroke = Instance.new("UIStroke")
local WMLabel = Instance.new("TextLabel")

WMFrame.Parent = ScreenGui
WMFrame.BackgroundColor3 = Color3.fromRGB(6, 6, 6)
WMFrame.Position = UDim2.new(0, 8, 0, 8)
WMFrame.Size = UDim2.new(0, 300, 0, 22)
WMFrame.BorderSizePixel = 0

WMStroke.Parent = WMFrame
WMStroke.Color = Color3.fromRGB(255, 255, 255)
WMStroke.Thickness = 0.8
WMStroke.Transparency = 0.6

WMLabel.Parent = WMFrame
WMLabel.BackgroundTransparency = 1
WMLabel.Size = UDim2.new(1, -8, 1, 0)
WMLabel.Position = UDim2.new(0, 6, 0, 0)
WMLabel.Font = Enum.Font.Code
WMLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
WMLabel.TextSize = 11
WMLabel.TextXAlignment = Enum.TextXAlignment.Left
WMLabel.Text = "PHANTOM-UI  |  ...  |  FPS: --  |  PING: --ms"

-- FPS + Ping обновление
local fpsCount, fpsTimer, currentFPS = 0, tick(), 60
RunService.RenderStepped:Connect(function()
    fpsCount += 1
    if tick() - fpsTimer >= 1 then
        currentFPS = fpsCount
        fpsCount = 0
        fpsTimer = tick()
    end
    local ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
    WMLabel.Text = "PHANTOM-UI  |  " .. LocalPlayer.Name .. "  |  FPS: " .. currentFPS .. "  |  PING: " .. ping .. "ms"
end)

-- ==============================
-- MAIN FRAME
-- ==============================
local MainFrame = Instance.new("Frame")
local MainStroke = Instance.new("UIStroke")

MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(6, 6, 6)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -210)
MainFrame.Size = UDim2.new(0, 580, 0, 430)
MainFrame.ClipsDescendants = true

-- Неоновая белая обводка
MainStroke.Parent = MainFrame
MainStroke.Color = Color3.fromRGB(255, 255, 255)
MainStroke.Thickness = 1
MainStroke.Transparency = 0.55
MainStroke.LineJoinMode = Enum.LineJoinMode.Round

-- Drag
do
    local drag, dragInput, dragStart, startPos
    MainFrame.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true; dragStart = i.Position; startPos = MainFrame.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then drag = false end
            end)
        end
    end)
    MainFrame.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement then dragInput = i end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and i == dragInput then
            local d = i.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

-- ==============================
-- TITLE BAR
-- ==============================
local TitleBar = Instance.new("Frame")
TitleBar.Parent = MainFrame
TitleBar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
TitleBar.BorderSizePixel = 0
TitleBar.Size = UDim2.new(1, 0, 0, 28)

local TitleDiv = Instance.new("Frame")
TitleDiv.Parent = TitleBar
TitleDiv.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TitleDiv.BorderSizePixel = 0
TitleDiv.Position = UDim2.new(0, 0, 1, -1)
TitleDiv.Size = UDim2.new(1, 0, 0, 1)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = TitleBar
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Font = Enum.Font.Code
TitleLabel.Text = ":: PHANTOM-UI ::"
TitleLabel.TextColor3 = Color3.fromRGB(90, 90, 90)
TitleLabel.TextSize = 11
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = TitleBar
CloseBtn.BackgroundTransparency = 1
CloseBtn.BorderSizePixel = 0
CloseBtn.Position = UDim2.new(1, -26, 0, 5)
CloseBtn.Size = UDim2.new(0, 18, 0, 18)
CloseBtn.Font = Enum.Font.Code
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(70, 70, 70)
CloseBtn.TextSize = 13
CloseBtn.MouseEnter:Connect(function() CloseBtn.TextColor3 = Color3.fromRGB(220,220,220) end)
CloseBtn.MouseLeave:Connect(function() CloseBtn.TextColor3 = Color3.fromRGB(70,70,70) end)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

-- ==============================
-- TAB BAR
-- ==============================
local TabBar = Instance.new("Frame")
TabBar.Parent = MainFrame
TabBar.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
TabBar.BorderSizePixel = 0
TabBar.Position = UDim2.new(0, 0, 0, 28)
TabBar.Size = UDim2.new(1, 0, 0, 24)

local TabDiv = Instance.new("Frame")
TabDiv.Parent = TabBar
TabDiv.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
TabDiv.BorderSizePixel = 0
TabDiv.Position = UDim2.new(0, 0, 1, -1)
TabDiv.Size = UDim2.new(1, 0, 0, 1)

local TabLayout = Instance.new("UIListLayout")
TabLayout.Parent = TabBar
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- ==============================
-- CONTENT
-- ==============================
local ContentFrame = Instance.new("Frame")
ContentFrame.Parent = MainFrame
ContentFrame.BackgroundTransparency = 1
ContentFrame.Position = UDim2.new(0, 0, 0, 52)
ContentFrame.Size = UDim2.new(1, 0, 1, -72)

-- ==============================
-- STATUS BAR
-- ==============================
local StatusBar = Instance.new("Frame")
StatusBar.Parent = MainFrame
StatusBar.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
StatusBar.BorderSizePixel = 0
StatusBar.Position = UDim2.new(0, 0, 1, -20)
StatusBar.Size = UDim2.new(1, 0, 0, 20)

local StatusDiv = Instance.new("Frame")
StatusDiv.Parent = StatusBar
StatusDiv.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
StatusDiv.BorderSizePixel = 0
StatusDiv.Size = UDim2.new(1, 0, 0, 1)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Parent = StatusBar
StatusLabel.BackgroundTransparency = 1
StatusLabel.Position = UDim2.new(0, 10, 0, 0)
StatusLabel.Size = UDim2.new(1, -10, 1, 0)
StatusLabel.Font = Enum.Font.Code
StatusLabel.Text = "PHANTOM-UI v1.0  //  RSHIFT — TOGGLE"
StatusLabel.TextColor3 = Color3.fromRGB(38, 38, 38)
StatusLabel.TextSize = 10
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

-- ==============================
-- ACCENT COLOR (глобальный)
-- ==============================
local accentColor = Color3.fromRGB(255, 255, 255)
local accentObjects = {} -- все объекты с акцентом

local function setAccent(color)
    accentColor = color
    for _, obj in ipairs(accentObjects) do
        pcall(function()
            if obj.type == "toggle_on" then
                if obj.state then obj.fill.BackgroundColor3 = color end
            elseif obj.type == "slider_fill" then
                obj.ref.BackgroundColor3 = color
            elseif obj.type == "tab_active" then
                if obj.active then obj.ref.BackgroundColor3 = color end
            end
        end)
    end
    MainStroke.Color = color
    WMStroke.Color = color
end

-- ==============================
-- TOGGLE MENU KEYBIND
-- ==============================
local menuBind = Enum.KeyCode.RightShift
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == menuBind then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- ==============================
-- TAB SYSTEM
-- ==============================
local allTabs = {}

local function createTab(name)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Parent = TabBar
    tabBtn.BackgroundTransparency = 1
    tabBtn.BorderSizePixel = 0
    tabBtn.Size = UDim2.new(0, 82, 1, 0)
    tabBtn.Font = Enum.Font.Code
    tabBtn.Text = name:upper()
    tabBtn.TextColor3 = Color3.fromRGB(55, 55, 55)
    tabBtn.TextSize = 10

    local tabUnderline = Instance.new("Frame")
    tabUnderline.Parent = tabBtn
    tabUnderline.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    tabUnderline.BorderSizePixel = 0
    tabUnderline.Position = UDim2.new(0, 6, 1, -2)
    tabUnderline.Size = UDim2.new(1, -12, 0, 1)
    tabUnderline.Visible = false

    local page = Instance.new("ScrollingFrame")
    page.Parent = ContentFrame
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.Size = UDim2.new(1, 0, 1, 0)
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.ScrollBarThickness = 2
    page.ScrollBarImageColor3 = Color3.fromRGB(40, 40, 40)
    page.Visible = false

    local leftCol = Instance.new("Frame")
    leftCol.Parent = page
    leftCol.BackgroundTransparency = 1
    leftCol.Position = UDim2.new(0, 10, 0, 8)
    leftCol.Size = UDim2.new(0.5, -14, 1, 0)

    local leftLayout = Instance.new("UIListLayout")
    leftLayout.Parent = leftCol
    leftLayout.SortOrder = Enum.SortOrder.LayoutOrder
    leftLayout.Padding = UDim.new(0, 8)

    local rightCol = Instance.new("Frame")
    rightCol.Parent = page
    rightCol.BackgroundTransparency = 1
    rightCol.Position = UDim2.new(0.5, 4, 0, 8)
    rightCol.Size = UDim2.new(0.5, -14, 1, 0)

    local rightLayout = Instance.new("UIListLayout")
    rightLayout.Parent = rightCol
    rightLayout.SortOrder = Enum.SortOrder.LayoutOrder
    rightLayout.Padding = UDim.new(0, 8)

    local function updateCanvas()
        local lh = leftLayout.AbsoluteContentSize.Y
        local rh = rightLayout.AbsoluteContentSize.Y
        page.CanvasSize = UDim2.new(0, 0, 0, math.max(lh, rh) + 20)
    end
    leftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
    rightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)

    local tabObj = {btn = tabBtn, line = tabUnderline, page = page, left = leftCol, right = rightCol}
    table.insert(allTabs, tabObj)

    tabBtn.MouseButton1Click:Connect(function()
        for _, t in ipairs(allTabs) do
            t.page.Visible = false
            t.btn.TextColor3 = Color3.fromRGB(55, 55, 55)
            t.line.Visible = false
        end
        page.Visible = true
        tabBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
        tabUnderline.Visible = true
        tabUnderline.BackgroundColor3 = accentColor
    end)

    if #allTabs == 1 then
        page.Visible = true
        tabBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
        tabUnderline.Visible = true
    end

    -- ==============================
    -- SECTION BUILDER
    -- ==============================
    local tabAPI = {}

    function tabAPI:Section(sectionName, side)
        local col = (side == "Right") and rightCol or leftCol

        local frame = Instance.new("Frame")
        frame.Parent = col
        frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
        frame.BorderSizePixel = 0
        frame.Size = UDim2.new(1, 0, 0, 22)
        frame.ClipsDescendants = false

        local fStroke = Instance.new("UIStroke")
        fStroke.Parent = frame
        fStroke.Color = Color3.fromRGB(28, 28, 28)
        fStroke.Thickness = 1

        local secTitle = Instance.new("TextLabel")
        secTitle.Parent = frame
        secTitle.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
        secTitle.BorderSizePixel = 0
        secTitle.Size = UDim2.new(1, 0, 0, 18)
        secTitle.Font = Enum.Font.Code
        secTitle.Text = "// " .. sectionName:upper()
        secTitle.TextColor3 = Color3.fromRGB(60, 60, 60)
        secTitle.TextSize = 9
        secTitle.TextXAlignment = Enum.TextXAlignment.Left

        local stPad = Instance.new("UIPadding")
        stPad.Parent = secTitle
        stPad.PaddingLeft = UDim.new(0, 8)

        local body = Instance.new("Frame")
        body.Parent = frame
        body.BackgroundTransparency = 1
        body.Position = UDim2.new(0, 0, 0, 18)
        body.Size = UDim2.new(1, 0, 0, 0)

        local bodyLayout = Instance.new("UIListLayout")
        bodyLayout.Parent = body
        bodyLayout.SortOrder = Enum.SortOrder.LayoutOrder
        bodyLayout.Padding = UDim.new(0, 2)

        local bodyPad = Instance.new("UIPadding")
        bodyPad.Parent = body
        bodyPad.PaddingLeft = UDim.new(0, 8)
        bodyPad.PaddingRight = UDim.new(0, 8)
        bodyPad.PaddingTop = UDim.new(0, 5)
        bodyPad.PaddingBottom = UDim.new(0, 6)

        local function updateFrameSize()
            local bh = bodyLayout.AbsoluteContentSize.Y + 10
            body.Size = UDim2.new(1, 0, 0, bh)
            frame.Size = UDim2.new(1, 0, 0, 18 + bh)
        end
        bodyLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateFrameSize)

        local sec = {}

        -- TOGGLE
        function sec:Toggle(name, default, callback)
            local row = Instance.new("Frame")
            row.Parent = body
            row.BackgroundTransparency = 1
            row.Size = UDim2.new(1, 0, 0, 18)

            local lbl = Instance.new("TextLabel")
            lbl.Parent = row
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(1, -34, 1, 0)
            lbl.Font = Enum.Font.Code
            lbl.Text = name
            lbl.TextColor3 = Color3.fromRGB(130, 130, 130)
            lbl.TextSize = 11
            lbl.TextXAlignment = Enum.TextXAlignment.Left

            local track = Instance.new("Frame")
            track.Parent = row
            track.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
            track.BorderSizePixel = 0
            track.Position = UDim2.new(1, -30, 0.5, -7)
            track.Size = UDim2.new(0, 30, 0, 14)

            local tStroke = Instance.new("UIStroke")
            tStroke.Parent = track
            tStroke.Color = Color3.fromRGB(35, 35, 35)
            tStroke.Thickness = 1

            local tCorner = Instance.new("UICorner")
            tCorner.CornerRadius = UDim.new(1, 0)
            tCorner.Parent = track

            local knob = Instance.new("Frame")
            knob.Parent = track
            knob.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            knob.BorderSizePixel = 0
            knob.Position = UDim2.new(0, 2, 0.5, -5)
            knob.Size = UDim2.new(0, 10, 0, 10)

            local kCorner = Instance.new("UICorner")
            kCorner.CornerRadius = UDim.new(1, 0)
            kCorner.Parent = knob

            local btn = Instance.new("TextButton")
            btn.Parent = track
            btn.BackgroundTransparency = 1
            btn.BorderSizePixel = 0
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.Text = ""

            local state = default or false
            local togData = {type = "toggle_on", state = state, fill = knob}
            table.insert(accentObjects, togData)

            local function refresh()
                if state then
                    TweenService:Create(knob, TweenInfo.new(0.12), {
                        Position = UDim2.new(0, 18, 0.5, -5),
                        BackgroundColor3 = accentColor
                    }):Play()
                    lbl.TextColor3 = Color3.fromRGB(210, 210, 210)
                    tStroke.Color = Color3.fromRGB(60, 60, 60)
                else
                    TweenService:Create(knob, TweenInfo.new(0.12), {
                        Position = UDim2.new(0, 2, 0.5, -5),
                        BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                    }):Play()
                    lbl.TextColor3 = Color3.fromRGB(130, 130, 130)
                    tStroke.Color = Color3.fromRGB(35, 35, 35)
                end
                togData.state = state
            end
            refresh()

            btn.MouseButton1Click:Connect(function()
                state = not state
                refresh()
                if callback then callback(state) end
            end)
        end

        -- SLIDER
        function sec:Slider(name, min, max, default, suffix, callback)
            suffix = suffix or ""
            local wrap = Instance.new("Frame")
            wrap.Parent = body
            wrap.BackgroundTransparency = 1
            wrap.Size = UDim2.new(1, 0, 0, 28)

            local topRow = Instance.new("Frame")
            topRow.Parent = wrap
            topRow.BackgroundTransparency = 1
            topRow.Size = UDim2.new(1, 0, 0, 13)

            local lbl = Instance.new("TextLabel")
            lbl.Parent = topRow
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(0.65, 0, 1, 0)
            lbl.Font = Enum.Font.Code
            lbl.Text = name
            lbl.TextColor3 = Color3.fromRGB(130, 130, 130)
            lbl.TextSize = 11
            lbl.TextXAlignment = Enum.TextXAlignment.Left

            local valLbl = Instance.new("TextLabel")
            valLbl.Parent = topRow
            valLbl.BackgroundTransparency = 1
            valLbl.Position = UDim2.new(0.65, 0, 0, 0)
            valLbl.Size = UDim2.new(0.35, 0, 1, 0)
            valLbl.Font = Enum.Font.Code
            valLbl.Text = tostring(default or min) .. suffix
            valLbl.TextColor3 = Color3.fromRGB(80, 80, 80)
            valLbl.TextSize = 10
            valLbl.TextXAlignment = Enum.TextXAlignment.Right

            local track = Instance.new("Frame")
            track.Parent = wrap
            track.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
            track.BorderSizePixel = 0
            track.Position = UDim2.new(0, 0, 0, 17)
            track.Size = UDim2.new(1, 0, 0, 6)

            local tStroke = Instance.new("UIStroke")
            tStroke.Parent = track
            tStroke.Color = Color3.fromRGB(28, 28, 28)
            tStroke.Thickness = 1

            local tCorner = Instance.new("UICorner")
            tCorner.CornerRadius = UDim.new(1, 0)
            tCorner.Parent = track

            local fill = Instance.new("Frame")
            fill.Parent = track
            fill.BackgroundColor3 = accentColor
            fill.BorderSizePixel = 0
            fill.Size = UDim2.new(((default or min) - min) / math.max(max - min, 1), 0, 1, 0)

            local fCorner = Instance.new("UICorner")
            fCorner.CornerRadius = UDim.new(1, 0)
            fCorner.Parent = fill

            table.insert(accentObjects, {type = "slider_fill", ref = fill})

            local slideBtn = Instance.new("TextButton")
            slideBtn.Parent = track
            slideBtn.BackgroundTransparency = 1
            slideBtn.BorderSizePixel = 0
            slideBtn.Size = UDim2.new(1, 0, 3, -6)
            slideBtn.Position = UDim2.new(0, 0, 0, -6)
            slideBtn.Text = ""

            local sliding = false
            slideBtn.MouseButton1Down:Connect(function() sliding = true end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if sliding and i.UserInputType == Enum.UserInputType.MouseMovement then
                    local pct = math.clamp((i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                    local val = math.floor(min + pct * (max - min))
                    fill.Size = UDim2.new(pct, 0, 1, 0)
                    valLbl.Text = tostring(val) .. suffix
                    if callback then callback(val) end
                end
            end)
        end

        -- BUTTON
        function sec:Button(name, callback)
            local btn = Instance.new("TextButton")
            btn.Parent = body
            btn.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
            btn.BorderSizePixel = 0
            btn.Size = UDim2.new(1, 0, 0, 18)
            btn.Font = Enum.Font.Code
            btn.Text = name:upper()
            btn.TextColor3 = Color3.fromRGB(110, 110, 110)
            btn.TextSize = 10

            local bStroke = Instance.new("UIStroke")
            bStroke.Parent = btn
            bStroke.Color = Color3.fromRGB(30, 30, 30)
            bStroke.Thickness = 1

            btn.MouseEnter:Connect(function()
                btn.TextColor3 = Color3.fromRGB(220, 220, 220)
                bStroke.Color = Color3.fromRGB(70, 70, 70)
            end)
            btn.MouseLeave:Connect(function()
                btn.TextColor3 = Color3.fromRGB(110, 110, 110)
                bStroke.Color = Color3.fromRGB(30, 30, 30)
            end)
            btn.MouseButton1Click:Connect(function()
                if callback then callback() end
            end)
        end

        -- DROPDOWN
        function sec:Dropdown(name, options, callback)
            local wrap = Instance.new("Frame")
            wrap.Parent = body
            wrap.BackgroundTransparency = 1
            wrap.Size = UDim2.new(1, 0, 0, 18)
            wrap.ZIndex = 5
            wrap.ClipsDescendants = false

            local lbl = Instance.new("TextLabel")
            lbl.Parent = wrap
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(0.48, 0, 1, 0)
            lbl.Font = Enum.Font.Code
            lbl.Text = name
            lbl.TextColor3 = Color3.fromRGB(130, 130, 130)
            lbl.TextSize = 11
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.ZIndex = 5

            local box = Instance.new("TextButton")
            box.Parent = wrap
            box.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
            box.BorderSizePixel = 0
            box.Position = UDim2.new(0.5, 0, 0, 0)
            box.Size = UDim2.new(0.5, 0, 1, 0)
            box.Font = Enum.Font.Code
            box.Text = options[1] or ""
            box.TextColor3 = Color3.fromRGB(140, 140, 140)
            box.TextSize = 10
            box.ZIndex = 5

            local bStroke = Instance.new("UIStroke")
            bStroke.Parent = box
            bStroke.Color = Color3.fromRGB(30, 30, 30)
            bStroke.Thickness = 1

            local dropdown = Instance.new("Frame")
            dropdown.Parent = wrap
            dropdown.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
            dropdown.BorderSizePixel = 0
            dropdown.Position = UDim2.new(0.5, 0, 1, 2)
            dropdown.Size = UDim2.new(0.5, 0, 0, #options * 18)
            dropdown.Visible = false
            dropdown.ZIndex = 20

            local dStroke = Instance.new("UIStroke")
            dStroke.Parent = dropdown
            dStroke.Color = Color3.fromRGB(35, 35, 35)
            dStroke.Thickness = 1

            local dLayout = Instance.new("UIListLayout")
            dLayout.Parent = dropdown
            dLayout.SortOrder = Enum.SortOrder.LayoutOrder

            for _, opt in ipairs(options) do
                local ob = Instance.new("TextButton")
                ob.Parent = dropdown
                ob.BackgroundTransparency = 1
                ob.BorderSizePixel = 0
                ob.Size = UDim2.new(1, 0, 0, 18)
                ob.Font = Enum.Font.Code
                ob.Text = opt
                ob.TextColor3 = Color3.fromRGB(100, 100, 100)
                ob.TextSize = 10
                ob.ZIndex = 20
                ob.MouseEnter:Connect(function() ob.TextColor3 = Color3.fromRGB(220,220,220) end)
                ob.MouseLeave:Connect(function() ob.TextColor3 = Color3.fromRGB(100,100,100) end)
                ob.MouseButton1Click:Connect(function()
                    box.Text = opt
                    dropdown.Visible = false
                    bStroke.Color = Color3.fromRGB(30, 30, 30)
                    if callback then callback(opt) end
                end)
            end

            box.MouseButton1Click:Connect(function()
                dropdown.Visible = not dropdown.Visible
                bStroke.Color = dropdown.Visible and Color3.fromRGB(80,80,80) or Color3.fromRGB(30,30,30)
            end)
        end

        -- TEXTBOX
        function sec:Textbox(name, placeholder, callback)
            local wrap = Instance.new("Frame")
            wrap.Parent = body
            wrap.BackgroundTransparency = 1
            wrap.Size = UDim2.new(1, 0, 0, 28)

            local lbl = Instance.new("TextLabel")
            lbl.Parent = wrap
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(1, 0, 0, 12)
            lbl.Font = Enum.Font.Code
            lbl.Text = name
            lbl.TextColor3 = Color3.fromRGB(90, 90, 90)
            lbl.TextSize = 10
            lbl.TextXAlignment = Enum.TextXAlignment.Left

            local box = Instance.new("TextBox")
            box.Parent = wrap
            box.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
            box.BorderSizePixel = 0
            box.Position = UDim2.new(0, 0, 0, 13)
            box.Size = UDim2.new(1, 0, 0, 14)
            box.Font = Enum.Font.Code
            box.PlaceholderText = placeholder or ""
            box.PlaceholderColor3 = Color3.fromRGB(45, 45, 45)
            box.Text = ""
            box.TextColor3 = Color3.fromRGB(170, 170, 170)
            box.TextSize = 10
            box.TextXAlignment = Enum.TextXAlignment.Left
            box.ClearTextOnFocus = false

            local bPad = Instance.new("UIPadding")
            bPad.Parent = box
            bPad.PaddingLeft = UDim.new(0, 4)

            local bStroke = Instance.new("UIStroke")
            bStroke.Parent = box
            bStroke.Color = Color3.fromRGB(28, 28, 28)
            bStroke.Thickness = 1

            box.Focused:Connect(function() bStroke.Color = Color3.fromRGB(70,70,70) end)
            box.FocusLost:Connect(function() bStroke.Color = Color3.fromRGB(28,28,28) end)
            box:GetPropertyChangedSignal("Text"):Connect(function()
                if callback then callback(box.Text) end
            end)
            return box
        end

        -- KEYBIND
        function sec:Keybind(name, default, callback)
            local row = Instance.new("Frame")
            row.Parent = body
            row.BackgroundTransparency = 1
            row.Size = UDim2.new(1, 0, 0, 18)

            local lbl = Instance.new("TextLabel")
            lbl.Parent = row
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(0.6, 0, 1, 0)
            lbl.Font = Enum.Font.Code
            lbl.Text = name
            lbl.TextColor3 = Color3.fromRGB(130, 130, 130)
            lbl.TextSize = 11
            lbl.TextXAlignment = Enum.TextXAlignment.Left

            local kb = Instance.new("TextButton")
            kb.Parent = row
            kb.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
            kb.BorderSizePixel = 0
            kb.Position = UDim2.new(0.62, 0, 0.5, -8)
            kb.Size = UDim2.new(0.38, 0, 0, 16)
            kb.Font = Enum.Font.Code
            kb.Text = default and tostring(default):gsub("Enum.KeyCode.","") or "--"
            kb.TextColor3 = Color3.fromRGB(100, 100, 100)
            kb.TextSize = 9

            local kbStroke = Instance.new("UIStroke")
            kbStroke.Parent = kb
            kbStroke.Color = Color3.fromRGB(30, 30, 30)
            kbStroke.Thickness = 1

            local waiting = false
            kb.MouseButton1Click:Connect(function()
                waiting = true
                kb.Text = "..."
                kb.TextColor3 = Color3.fromRGB(200, 200, 200)
                kbStroke.Color = Color3.fromRGB(80, 80, 80)
            end)
            UserInputService.InputBegan:Connect(function(input, gpe)
                if waiting and input.KeyCode ~= Enum.KeyCode.Unknown then
                    waiting = false
                    local n = tostring(input.KeyCode):gsub("Enum.KeyCode.","")
                    kb.Text = n
                    kb.TextColor3 = Color3.fromRGB(100, 100, 100)
                    kbStroke.Color = Color3.fromRGB(30, 30, 30)
                    if callback then callback(input.KeyCode) end
                end
            end)
        end

        -- COLOR PICKER (простой)
        function sec:ColorPicker(name, default, callback)
            local row = Instance.new("Frame")
            row.Parent = body
            row.BackgroundTransparency = 1
            row.Size = UDim2.new(1, 0, 0, 18)

            local lbl = Instance.new("TextLabel")
            lbl.Parent = row
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(0.75, 0, 1, 0)
            lbl.Font = Enum.Font.Code
            lbl.Text = name
            lbl.TextColor3 = Color3.fromRGB(130, 130, 130)
            lbl.TextSize = 11
            lbl.TextXAlignment = Enum.TextXAlignment.Left

            local swatch = Instance.new("Frame")
            swatch.Parent = row
            swatch.BackgroundColor3 = default or Color3.fromRGB(255, 255, 255)
            swatch.BorderSizePixel = 0
            swatch.Position = UDim2.new(1, -20, 0.5, -7)
            swatch.Size = UDim2.new(0, 20, 0, 14)

            local swStroke = Instance.new("UIStroke")
            swStroke.Parent = swatch
            swStroke.Color = Color3.fromRGB(55, 55, 55)
            swStroke.Thickness = 1
        end

        -- DIVIDER
        function sec:Divider()
            local d = Instance.new("Frame")
            d.Parent = body
            d.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            d.BorderSizePixel = 0
            d.Size = UDim2.new(1, 0, 0, 1)
        end

        return sec
    end

    return tabAPI
end

-- ==============================
-- СОЗДАЁМ ВКЛАДКИ
-- ==============================
local combatTab   = createTab("Combat")
local visualTab   = createTab("Visual")
local cosmTab     = createTab("Cosmetics")
local moveTab     = createTab("Movement")
local miscTab     = createTab("Misc")
local settingsTab = createTab("Settings")

-- ==============================
-- COMBAT
-- ==============================
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

-- ==============================
-- VISUAL
-- ==============================
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

-- ==============================
-- COSMETICS
-- ==============================
local chatSec = cosmTab:Section("Chat", "Left")
local charSec = cosmTab:Section("Character", "Right")

chatSec:Toggle("Chat Prefix", false, function(v) end)
chatSec:Textbox("Prefix Text", "[PHANTOM]", function(v) end)
chatSec:Toggle("Chat Suffix", false, function(v) end)
chatSec:Textbox("Suffix Text", "suffix...", function(v) end)

charSec:Toggle("Hide Accessories", false, function(v) end)
charSec:Toggle("Custom Body Color", false, function(v) end)
charSec:ColorPicker("Body Color", Color3.fromRGB(255,200,150), function(v) end)

-- ==============================
-- MOVEMENT
-- ==============================
local spdSec = moveTab:Section("Speed", "Left")
local flySec = moveTab:Section("Fly", "Right")

spdSec:Toggle("Speed Hack", false, function(v) end)
spdSec:Slider("Speed", 0, 100, 16, "", function(v)
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
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
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end)
    end
end)

-- ==============================
-- MISC
-- ==============================
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

-- ==============================
-- SETTINGS
-- ==============================
local bindSec  = settingsTab:Section("Keybinds", "Left")
local themeSec = settingsTab:Section("Theme", "Left")
local cfgSec   = settingsTab:Section("Configs", "Right")

-- Keybinds (только toggle menu)
bindSec:Keybind("Toggle Menu", Enum.KeyCode.RightShift, function(key)
    menuBind = key
end)

-- Theme — смена цвета всех элементов
themeSec:Toggle("Show Watermark", true, function(v)
    WMFrame.Visible = v
end)

local themePresets = {
    White  = Color3.fromRGB(255, 255, 255),
    Red    = Color3.fromRGB(220, 50,  50),
    Blue   = Color3.fromRGB(80,  140, 255),
    Green  = Color3.fromRGB(60,  210, 100),
    Purple = Color3.fromRGB(160, 80,  255),
    Orange = Color3.fromRGB(255, 140, 40),
}

themeSec:Dropdown("Accent Preset", {"White","Red","Blue","Green","Purple","Orange"}, function(v)
    if themePresets[v] then setAccent(themePresets[v]) end
end)

-- Configs
local selectedConfig = ""
local cfgListBox = cfgSec:Textbox("Select Config", "click save/load", function(v)
    selectedConfig = v
end)

cfgSec:Divider()
cfgSec:Button("Save Config", function()
    if selectedConfig == "" then return end
    local data = {}
    -- сохраняем флаги
    writefile("PhantomUI/" .. selectedConfig .. ".cfg", HttpService:JSONEncode(data))
end)
cfgSec:Button("Load Config", function()
    if selectedConfig == "" then return end
    local path = "PhantomUI/" .. selectedConfig .. ".cfg"
    if isfile(path) then
        local data = HttpService:JSONDecode(readfile(path))
    end
end)
cfgSec:Button("Delete Config", function()
    if selectedConfig == "" then return end
    local path = "PhantomUI/" .. selectedConfig .. ".cfg"
    if isfile(path) then
        delfile(path)
    end
end)
cfgSec:Button("List Configs", function()
    local files = listfiles("PhantomUI")
    local names = {}
    for _, f in ipairs(files) do
        table.insert(names, f:gsub("PhantomUI/",""):gsub("PhantomUI\\",""))
    end
    if setclipboard then
        setclipboard(table.concat(names, ", "))
    end
end)
