-- ScriptHub Library v2.3
-- loadstring(game:HttpGet("URL"))()

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local LocalPlayer      = Players.LocalPlayer

-- ================================================================
-- УТИЛИТЫ
-- ================================================================
local function HSVtoRGB(h, s, v)
    if s == 0 then return v, v, v end
    h = h * 6
    local i = math.floor(h)
    local f = h - i
    local p = v * (1 - s)
    local q = v * (1 - s * f)
    local t = v * (1 - s * (1 - f))
    local r, g, b
    if i == 0 then r,g,b = v,t,p
    elseif i == 1 then r,g,b = q,v,p
    elseif i == 2 then r,g,b = p,v,t
    elseif i == 3 then r,g,b = p,q,v
    elseif i == 4 then r,g,b = t,p,v
    else r,g,b = v,p,q end
    return r, g, b
end

local function RGBtoHSV(r, g, b)
    local max = math.max(r,g,b)
    local min = math.min(r,g,b)
    local v = max
    local s = max == 0 and 0 or (max-min)/max
    local h = 0
    if max ~= min then
        local d = max - min
        if max == r then h = (g-b)/d + (g < b and 6 or 0)
        elseif max == g then h = (b-r)/d + 2
        else h = (r-g)/d + 4 end
        h = h / 6
    end
    return h, s, v
end

-- ================================================================
-- РЕЕСТР ЗНАЧЕНИЙ
-- ================================================================
local registry = {}
local function reg(id, rtype, getter, setter)
    if id and id ~= "" then
        registry[id] = { type = rtype, get = getter, set = setter }
    end
end

-- ================================================================
-- ТЕМА + РЕАКТИВНОСТЬ
-- ================================================================
local Theme = {}
local _themeValues = {
    Accent        = Color3.fromRGB(255,255,255),
    WindowBG      = Color3.fromRGB(15,15,20),
    TitleBG       = Color3.fromRGB(10,10,14),
    SectionBG     = Color3.fromRGB(18,18,24),
    SectionBorder = Color3.fromRGB(35,35,50),
    ButtonBG      = Color3.fromRGB(20,20,28),
    ButtonBorder  = Color3.fromRGB(40,40,55),
    ButtonText    = Color3.fromRGB(130,130,160),
    LabelText     = Color3.fromRGB(150,150,180),
    LabelOn       = Color3.fromRGB(230,230,255),
    SliderTrack   = Color3.fromRGB(22,22,30),
    ToggleBG      = Color3.fromRGB(22,22,30),
    ToggleOff     = Color3.fromRGB(40,40,55),
    StatusText    = Color3.fromRGB(50,50,70),
    WatermarkBG   = Color3.fromRGB(10,10,14),
}
local _themeListeners = {}

setmetatable(Theme, {
    __index = function(_, k) return _themeValues[k] end,
    __newindex = function(_, k, v)
        _themeValues[k] = v
        if _themeListeners[k] then
            for _, fn in ipairs(_themeListeners[k]) do
                pcall(fn, v)
            end
        end
    end,
})

local function onTheme(key, fn)
    if not _themeListeners[key] then _themeListeners[key] = {} end
    table.insert(_themeListeners[key], fn)
    fn(_themeValues[key])
end

-- ================================================================
-- GUI ROOT
-- ================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ScriptHub"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false
if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end
ScreenGui.Parent = game:GetService("CoreGui")

-- ================================================================
-- ЗАГРУЗОЧНЫЙ ЭКРАН (новый, стильный)
-- ================================================================
local LoadGui = Instance.new("ScreenGui")
LoadGui.Name = "ScriptHubLoader"
LoadGui.IgnoreGuiInset = true
if syn and syn.protect_gui then syn.protect_gui(LoadGui) end
LoadGui.Parent = game:GetService("CoreGui")

-- Тёмный фон
local LoadBG = Instance.new("Frame")
LoadBG.Size = UDim2.new(1,0,1,0)
LoadBG.BackgroundColor3 = Color3.fromRGB(8,8,12)
LoadBG.BorderSizePixel = 0
LoadBG.Parent = LoadGui

-- Вертикальные декоративные линии (тонкие, едва заметные)
for i = 1, 12 do
    local vl = Instance.new("Frame")
    vl.Size = UDim2.new(0,1,1,0)
    vl.Position = UDim2.new(i/13,0,0,0)
    vl.BackgroundColor3 = Color3.fromRGB(18,18,28)
    vl.BorderSizePixel = 0
    vl.Parent = LoadBG
end

-- Горизонтальная светящаяся полоса посередине
local glowLine = Instance.new("Frame")
glowLine.Size = UDim2.new(1,0,0,1)
glowLine.Position = UDim2.new(0,0,0.5,0)
glowLine.BackgroundColor3 = Color3.fromRGB(60,60,100)
glowLine.BorderSizePixel = 0
glowLine.Parent = LoadBG

-- Центральный блок
local LoadBox = Instance.new("Frame")
LoadBox.Size = UDim2.new(0,420,0,260)
LoadBox.Position = UDim2.new(0.5,-210,0.5,-130)
LoadBox.BackgroundColor3 = Color3.fromRGB(12,12,18)
LoadBox.BorderSizePixel = 0
LoadBox.Parent = LoadBG
do
    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(60,60,100)
    s.Thickness = 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = LoadBox
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,4)
    c.Parent = LoadBox
end

-- Верхняя полоска-акцент
local topAccent = Instance.new("Frame")
topAccent.Size = UDim2.new(0,80,0,2)
topAccent.Position = UDim2.new(0.5,-40,0,0)
topAccent.BackgroundColor3 = Color3.fromRGB(255,255,255)
topAccent.BorderSizePixel = 0
topAccent.Parent = LoadBox
do local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,1); c.Parent=topAccent end

-- Логотип (ромб из 4 треугольных линий)
local LogoFrame = Instance.new("Frame")
LogoFrame.Size = UDim2.new(0,40,0,40)
LogoFrame.Position = UDim2.new(0.5,-20,0,30)
LogoFrame.BackgroundTransparency = 1
LogoFrame.Parent = LoadBox

-- Ромб: 4 линии
local diamondLines = {
    -- верх-лево → центр (диагональ)
    {pos=UDim2.new(0,0,0,20), size=UDim2.new(0,20,0,1), rot=45},
    {pos=UDim2.new(0,20,0,0), size=UDim2.new(0,20,0,1), rot=-45},
    {pos=UDim2.new(0,0,0,20), size=UDim2.new(0,20,0,1), rot=-45},
    {pos=UDim2.new(0,20,0,20), size=UDim2.new(0,20,0,1), rot=45},
}
for _, d in ipairs(diamondLines) do
    local f = Instance.new("Frame")
    f.Position = d.pos; f.Size = d.size
    f.Rotation = d.rot
    f.BackgroundColor3 = Color3.fromRGB(200,200,255)
    f.BorderSizePixel = 0
    f.Parent = LogoFrame
end

-- Название
local LoadTitle = Instance.new("TextLabel")
LoadTitle.Size = UDim2.new(1,0,0,28)
LoadTitle.Position = UDim2.new(0,0,0,80)
LoadTitle.BackgroundTransparency = 1
LoadTitle.Font = Enum.Font.GothamBold
LoadTitle.Text = "SCRIPT HUB"
LoadTitle.TextColor3 = Color3.fromRGB(240,240,255)
LoadTitle.TextSize = 22
LoadTitle.Parent = LoadBox

-- Версия
local LoadVersion = Instance.new("TextLabel")
LoadVersion.Size = UDim2.new(1,0,0,16)
LoadVersion.Position = UDim2.new(0,0,0,110)
LoadVersion.BackgroundTransparency = 1
LoadVersion.Font = Enum.Font.Code
LoadVersion.Text = "VERSION  2.3"
LoadVersion.TextColor3 = Color3.fromRGB(60,60,90)
LoadVersion.TextSize = 10
LoadVersion.Parent = LoadBox

-- Разделитель
local LoadDivider = Instance.new("Frame")
LoadDivider.Size = UDim2.new(0,180,0,1)
LoadDivider.Position = UDim2.new(0.5,-90,0,132)
LoadDivider.BackgroundColor3 = Color3.fromRGB(35,35,55)
LoadDivider.BorderSizePixel = 0
LoadDivider.Parent = LoadBox

-- Благодарственный текст
local ThanksLabel = Instance.new("TextLabel")
ThanksLabel.Size = UDim2.new(1,-40,0,30)
ThanksLabel.Position = UDim2.new(0,20,0,140)
ThanksLabel.BackgroundTransparency = 1
ThanksLabel.Font = Enum.Font.Gotham
ThanksLabel.Text = "Спасибо, что используете наш продукт!\nМы рады видеть вас здесь."
ThanksLabel.TextColor3 = Color3.fromRGB(100,100,140)
ThanksLabel.TextSize = 11
ThanksLabel.TextWrapped = true
ThanksLabel.LineHeight = 1.4
ThanksLabel.Parent = LoadBox

-- Прогресс-бар (фон)
local BarBG = Instance.new("Frame")
BarBG.Size = UDim2.new(0,340,0,3)
BarBG.Position = UDim2.new(0.5,-170,0,195)
BarBG.BackgroundColor3 = Color3.fromRGB(22,22,35)
BarBG.BorderSizePixel = 0
BarBG.Parent = LoadBox
do local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(1,0); c.Parent=BarBG end

local BarFill = Instance.new("Frame")
BarFill.Size = UDim2.new(0,0,1,0)
BarFill.BackgroundColor3 = Color3.fromRGB(255,255,255)
BarFill.BorderSizePixel = 0
BarFill.Parent = BarBG
do local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(1,0); c.Parent=BarFill end

-- Процент
local LoadPct = Instance.new("TextLabel")
LoadPct.Size = UDim2.new(1,0,0,14)
LoadPct.Position = UDim2.new(0,0,0,204)
LoadPct.BackgroundTransparency = 1
LoadPct.Font = Enum.Font.Code
LoadPct.Text = "0%"
LoadPct.TextColor3 = Color3.fromRGB(70,70,100)
LoadPct.TextSize = 10
LoadPct.Parent = LoadBox

-- Статус
local LoadStatus = Instance.new("TextLabel")
LoadStatus.Size = UDim2.new(1,-40,0,14)
LoadStatus.Position = UDim2.new(0,20,0,222)
LoadStatus.BackgroundTransparency = 1
LoadStatus.Font = Enum.Font.Code
LoadStatus.Text = "Инициализация..."
LoadStatus.TextColor3 = Color3.fromRGB(50,50,75)
LoadStatus.TextSize = 9
LoadStatus.TextXAlignment = Enum.TextXAlignment.Left
LoadStatus.Parent = LoadBox

-- Мигающая точка
local PulseDot = Instance.new("Frame")
PulseDot.Size = UDim2.new(0,4,0,4)
PulseDot.Position = UDim2.new(1,-22,0,224)
PulseDot.BackgroundColor3 = Color3.fromRGB(180,180,255)
PulseDot.BorderSizePixel = 0
PulseDot.Parent = LoadBox
do local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(1,0); c.Parent=PulseDot end

task.spawn(function()
    while PulseDot and PulseDot.Parent do
        TweenService:Create(PulseDot,TweenInfo.new(0.7,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),
            {BackgroundTransparency=0.9}):Play()
        task.wait(0.7)
        TweenService:Create(PulseDot,TweenInfo.new(0.7,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),
            {BackgroundTransparency=0}):Play()
        task.wait(0.7)
    end
end)

local loadSteps = {
    {text="Загрузка ядра...",     pct=0.20},
    {text="Загрузка интерфейса...", pct=0.45},
    {text="Загрузка модулей...",   pct=0.68},
    {text="Загрузка конфигов...",  pct=0.88},
    {text="Готово!",               pct=1.00},
}

local function animateLoader(onDone)
    local i = 0
    local function step()
        i = i + 1
        if i > #loadSteps then
            task.wait(0.5)
            TweenService:Create(LoadBox,TweenInfo.new(0.5,Enum.EasingStyle.Quad),
                {Position=UDim2.new(0.5,-210,0.4,-130), BackgroundTransparency=1}):Play()
            TweenService:Create(LoadBG,TweenInfo.new(0.5,Enum.EasingStyle.Quad),
                {BackgroundTransparency=1}):Play()
            task.wait(0.6)
            LoadGui:Destroy()
            if onDone then onDone() end
            return
        end
        local st = loadSteps[i]
        LoadStatus.Text = st.text
        LoadPct.Text = math.floor(st.pct*100).."%"
        TweenService:Create(BarFill,TweenInfo.new(0.3,Enum.EasingStyle.Quad),
            {Size=UDim2.new(st.pct,0,1,0)}):Play()
        task.wait(0.38)
        step()
    end
    task.spawn(step)
end

-- ================================================================
-- WATERMARK
-- ================================================================
local Watermark = Instance.new("Frame")
Watermark.BorderSizePixel = 0
Watermark.Position = UDim2.new(0,8,0,8)
Watermark.Size = UDim2.new(0,280,0,22)
Watermark.Parent = ScreenGui
onTheme("WatermarkBG", function(c) Watermark.BackgroundColor3 = c end)

local WMStroke = Instance.new("UIStroke")
WMStroke.Thickness = 1
WMStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
WMStroke.Parent = Watermark
onTheme("Accent", function(c) WMStroke.Color = c end)
do local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,3); c.Parent=Watermark end

local WMLabel = Instance.new("TextLabel")
WMLabel.BackgroundTransparency = 1
WMLabel.Size = UDim2.new(1,0,1,0)
WMLabel.Font = Enum.Font.Code
WMLabel.TextColor3 = Color3.fromRGB(160,160,190)
WMLabel.TextSize = 11
WMLabel.TextXAlignment = Enum.TextXAlignment.Left
WMLabel.Parent = Watermark
do local p=Instance.new("UIPadding"); p.PaddingLeft=UDim.new(0,8); p.Parent=WMLabel end

local fps2, frameCount2, lastTime2 = 60, 0, tick()
RunService.RenderStepped:Connect(function()
    frameCount2 = frameCount2 + 1
    local now = tick()
    if now - lastTime2 >= 1 then fps2=frameCount2; frameCount2=0; lastTime2=now end
    local ping = math.floor(LocalPlayer:GetNetworkPing()*1000)
    WMLabel.Text = LocalPlayer.Name.."  |  FPS: "..fps2.."  |  PING: "..ping.."ms"
end)

-- ================================================================
-- MAIN FRAME
-- ================================================================
local MainFrame = Instance.new("Frame")
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5,-290,0.5,-200)
MainFrame.Size = UDim2.new(0,580,0,420)
MainFrame.ClipsDescendants = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
onTheme("WindowBG", function(c) MainFrame.BackgroundColor3=c end)

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 1
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainStroke.Parent = MainFrame
onTheme("Accent", function(c) MainStroke.Color=c end)
do local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,4); c.Parent=MainFrame end

-- Drag
do
    local dragging, dragInput, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 then
            dragging=true; dragStart=input.Position; startPos=MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState==Enum.UserInputState.End then dragging=false end
            end)
        end
    end)
    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseMovement then dragInput=input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input==dragInput and dragging then
            local d = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X,
                                           startPos.Y.Scale, startPos.Y.Offset+d.Y)
        end
    end)
end

-- TITLE BAR
local TitleBar = Instance.new("Frame")
TitleBar.BorderColor3 = Color3.fromRGB(30,30,45)
TitleBar.BorderSizePixel = 1
TitleBar.Size = UDim2.new(1,0,0,30)
TitleBar.Parent = MainFrame
onTheme("TitleBG", function(c) TitleBar.BackgroundColor3=c end)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.BackgroundTransparency = 1
TitleLabel.Size = UDim2.new(1,-40,1,0)
TitleLabel.Position = UDim2.new(0,12,0,0)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "SCRIPT HUB"
TitleLabel.TextColor3 = Color3.fromRGB(180,180,220)
TitleLabel.TextSize = 11
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.BackgroundTransparency = 1
CloseBtn.Position = UDim2.new(1,-24,0,7)
CloseBtn.Size = UDim2.new(0,16,0,16)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(80,80,110)
CloseBtn.TextSize = 15
CloseBtn.Parent = TitleBar
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible=false end)

-- ТАБ ХОЛДЕР (стиль LinoriaLib)
local TabHolder = Instance.new("Frame")
TabHolder.BackgroundColor3 = Color3.fromRGB(12,12,18)
TabHolder.BorderColor3 = Color3.fromRGB(28,28,42)
TabHolder.BorderSizePixel = 1
TabHolder.Position = UDim2.new(0,0,0,30)
TabHolder.Size = UDim2.new(1,0,0,26)
TabHolder.Parent = MainFrame

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Parent = TabHolder

local ContentHolder = Instance.new("Frame")
ContentHolder.BackgroundTransparency = 1
ContentHolder.Position = UDim2.new(0,0,0,56)
ContentHolder.Size = UDim2.new(1,0,1,-76)
ContentHolder.Parent = MainFrame

local StatusBar = Instance.new("Frame")
StatusBar.BackgroundColor3 = Color3.fromRGB(10,10,16)
StatusBar.BorderColor3 = Color3.fromRGB(25,25,38)
StatusBar.BorderSizePixel = 1
StatusBar.Position = UDim2.new(0,0,1,-20)
StatusBar.Size = UDim2.new(1,0,0,20)
StatusBar.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.BackgroundTransparency = 1
StatusLabel.Size = UDim2.new(1,-10,1,0)
StatusLabel.Position = UDim2.new(0,8,0,0)
StatusLabel.Font = Enum.Font.Code
StatusLabel.Text = ":: SCRIPT HUB v2.3   |   RSHIFT — TOGGLE"
StatusLabel.TextSize = 10
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = StatusBar
onTheme("StatusText", function(c) StatusLabel.TextColor3=c end)

local menuBind = Enum.KeyCode.RightShift
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode==menuBind then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- ================================================================
-- COLOR PICKER — ПОЛНОСТЬЮ ПЕРЕПИСАН
-- Использует UIGradient вместо rbxassetid (работает везде)
-- ================================================================
local activeCP = nil

local function makeColorPicker(parentRow, default, onChange)
    local currentColor = default or Color3.fromRGB(255,255,255)

    -- Превью кнопка
    local previewFrame = Instance.new("Frame")
    previewFrame.BackgroundColor3 = currentColor
    previewFrame.BorderColor3 = Color3.fromRGB(55,55,80)
    previewFrame.BorderSizePixel = 1
    previewFrame.Position = UDim2.new(1,-24,0.5,-8)
    previewFrame.Size = UDim2.new(0,24,0,16)
    previewFrame.Parent = parentRow
    do local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,2); c.Parent=previewFrame end

    local previewBtn = Instance.new("TextButton")
    previewBtn.BackgroundTransparency = 1
    previewBtn.Size = UDim2.new(1,0,1,0)
    previewBtn.Text = ""
    previewBtn.ZIndex = 6
    previewBtn.Parent = previewFrame

    -- ── ПОПАП ─────────────────────────────────────────────────────
    local PW, PH = 236, 220
    local SV_X, SV_Y, SV_W, SV_H = 10, 10, 168, 156
    local HUE_X = 184
    local HUE_W = 20
    local BOTTOM_Y = SV_Y + SV_H + 10 -- 176

    local popup = Instance.new("Frame")
    popup.Size = UDim2.new(0,PW,0,PH)
    popup.BackgroundColor3 = Color3.fromRGB(13,13,20)
    popup.BorderSizePixel = 0
    popup.Visible = false
    popup.ZIndex = 200
    popup.Parent = ScreenGui
    do
        local s=Instance.new("UIStroke"); s.Color=Color3.fromRGB(55,55,90)
        s.Thickness=1; s.Parent=popup
        local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,5); c.Parent=popup
    end

    -- ── SV ОБЛАСТЬ ──────────────────────────────────────────────
    -- Используем UIGradient — работает без интернета и в любом executor'е

    -- Контейнер SV
    local svContainer = Instance.new("Frame")
    svContainer.Position = UDim2.new(0,SV_X,0,SV_Y)
    svContainer.Size = UDim2.new(0,SV_W,0,SV_H)
    svContainer.BorderSizePixel = 0
    svContainer.ZIndex = 201
    svContainer.Parent = popup
    do local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,3); c.Parent=svContainer end

    -- Слой 1: чистый hue-цвет (фон)
    local svColorBG = Instance.new("Frame")
    svColorBG.Size = UDim2.new(1,0,1,0)
    svColorBG.BorderSizePixel = 0
    svColorBG.ZIndex = 201
    svColorBG.Parent = svContainer
    do local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,3); c.Parent=svColorBG end

    -- Слой 2: Горизонтальный градиент белый→прозрачный (saturation) через UIGradient
    local svSatFrame = Instance.new("Frame")
    svSatFrame.Size = UDim2.new(1,0,1,0)
    svSatFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
    svSatFrame.BorderSizePixel = 0
    svSatFrame.ZIndex = 202
    svSatFrame.Parent = svContainer
    do local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,3); c.Parent=svSatFrame end
    local satGrad = Instance.new("UIGradient")
    satGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255)),
    })
    satGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1),
    })
    satGrad.Rotation = 0 -- слева (белый) → вправо (прозрачный)
    satGrad.Parent = svSatFrame

    -- Слой 3: Вертикальный градиент прозрачный→чёрный (value) через UIGradient
    local svValFrame = Instance.new("Frame")
    svValFrame.Size = UDim2.new(1,0,1,0)
    svValFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
    svValFrame.BorderSizePixel = 0
    svValFrame.ZIndex = 203
    svValFrame.Parent = svContainer
    do local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,3); c.Parent=svValFrame end
    local valGrad = Instance.new("UIGradient")
    valGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0,0,0)),
    })
    valGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0),
    })
    valGrad.Rotation = 90 -- сверху (прозрачный) → снизу (чёрный)
    valGrad.Parent = svValFrame

    -- Хитбокс SV
    local svHitbox = Instance.new("TextButton")
    svHitbox.Size = UDim2.new(1,0,1,0)
    svHitbox.BackgroundTransparency = 1
    svHitbox.Text = ""
    svHitbox.ZIndex = 205
    svHitbox.Parent = svContainer

    -- Курсор SV
    local svCursor = Instance.new("Frame")
    svCursor.Size = UDim2.new(0,10,0,10)
    svCursor.AnchorPoint = Vector2.new(0.5,0.5)
    svCursor.BackgroundColor3 = Color3.fromRGB(255,255,255)
    svCursor.BorderColor3 = Color3.fromRGB(0,0,0)
    svCursor.BorderSizePixel = 1
    svCursor.ZIndex = 210
    svCursor.Parent = svContainer
    do local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(1,0); c.Parent=svCursor end

    -- ── HUE BAR ──────────────────────────────────────────────────
    -- Рисуем через набор Frame с UIGradient по сегментам
    local hueFrame = Instance.new("Frame")
    hueFrame.Size = UDim2.new(0,HUE_W,0,SV_H)
    hueFrame.Position = UDim2.new(0,HUE_X,0,SV_Y)
    hueFrame.BackgroundTransparency = 1
    hueFrame.BorderSizePixel = 0
    hueFrame.ZIndex = 201
    hueFrame.Parent = popup
    do local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,3); c.Parent=hueFrame end

    -- Сегменты hue: 0→60→120→180→240→300→360
    local hueColors = {
        {Color3.fromRGB(255,0,0),   Color3.fromRGB(255,255,0)},
        {Color3.fromRGB(255,255,0), Color3.fromRGB(0,255,0)},
        {Color3.fromRGB(0,255,0),   Color3.fromRGB(0,255,255)},
        {Color3.fromRGB(0,255,255), Color3.fromRGB(0,0,255)},
        {Color3.fromRGB(0,0,255),   Color3.fromRGB(255,0,255)},
        {Color3.fromRGB(255,0,255), Color3.fromRGB(255,0,0)},
    }
    local segH = SV_H / #hueColors
    for i2, pair in ipairs(hueColors) do
        local seg = Instance.new("Frame")
        seg.Size = UDim2.new(1,0,0,math.ceil(segH)+1)
        seg.Position = UDim2.new(0,0,0,math.floor((i2-1)*segH))
        seg.BackgroundColor3 = pair[1]
        seg.BorderSizePixel = 0
        seg.ZIndex = 202
        seg.Parent = hueFrame
        local g = Instance.new("UIGradient")
        g.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, pair[1]),
            ColorSequenceKeypoint.new(1, pair[2]),
        })
        g.Rotation = 90
        g.Parent = seg
    end

    -- Хитбокс hue
    local hueHitbox = Instance.new("TextButton")
    hueHitbox.Size = UDim2.new(1,0,1,0)
    hueHitbox.BackgroundTransparency = 1
    hueHitbox.Text = ""
    hueHitbox.ZIndex = 204
    hueHitbox.Parent = hueFrame

    -- Курсор hue — горизонтальная полоса
    local hueCursor = Instance.new("Frame")
    hueCursor.Size = UDim2.new(1,8,0,4)
    hueCursor.AnchorPoint = Vector2.new(0,0.5)
    hueCursor.Position = UDim2.new(0,-4,0,0)
    hueCursor.BackgroundColor3 = Color3.fromRGB(255,255,255)
    hueCursor.BorderColor3 = Color3.fromRGB(0,0,0)
    hueCursor.BorderSizePixel = 1
    hueCursor.ZIndex = 205
    hueCursor.Parent = hueFrame
    do local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,2); c.Parent=hueCursor end

    -- ── НИЖНЯЯ СТРОКА ────────────────────────────────────────────
    local hexBG = Instance.new("Frame")
    hexBG.Size = UDim2.new(0,106,0,20)
    hexBG.Position = UDim2.new(0,SV_X,0,BOTTOM_Y)
    hexBG.BackgroundColor3 = Color3.fromRGB(18,18,28)
    hexBG.BorderColor3 = Color3.fromRGB(40,40,60)
    hexBG.BorderSizePixel = 1
    hexBG.ZIndex = 201
    hexBG.Parent = popup
    do local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,3); c.Parent=hexBG end

    local hexLabel = Instance.new("TextLabel")
    hexLabel.Size = UDim2.new(0,14,1,0)
    hexLabel.Position = UDim2.new(0,6,0,0)
    hexLabel.BackgroundTransparency = 1
    hexLabel.Font = Enum.Font.Code
    hexLabel.Text = "#"
    hexLabel.TextColor3 = Color3.fromRGB(60,60,90)
    hexLabel.TextSize = 11
    hexLabel.ZIndex = 202
    hexLabel.Parent = hexBG

    local hexBox = Instance.new("TextBox")
    hexBox.Size = UDim2.new(1,-22,1,-4)
    hexBox.Position = UDim2.new(0,20,0,2)
    hexBox.BackgroundTransparency = 1
    hexBox.BorderSizePixel = 0
    hexBox.Font = Enum.Font.Code
    hexBox.Text = ""
    hexBox.TextColor3 = Color3.fromRGB(200,200,230)
    hexBox.TextSize = 11
    hexBox.TextXAlignment = Enum.TextXAlignment.Left
    hexBox.ClearTextOnFocus = false
    hexBox.ZIndex = 202
    hexBox.Parent = hexBG

    -- Большой превью
    local bigPreview = Instance.new("Frame")
    bigPreview.Size = UDim2.new(0,PW-SV_X-106-12,0,20)
    bigPreview.Position = UDim2.new(0,SV_X+106+6,0,BOTTOM_Y)
    bigPreview.BorderColor3 = Color3.fromRGB(40,40,60)
    bigPreview.BorderSizePixel = 1
    bigPreview.ZIndex = 201
    bigPreview.Parent = popup
    do local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,3); c.Parent=bigPreview end

    -- Кнопка закрыть
    local closeCP = Instance.new("TextButton")
    closeCP.Size = UDim2.new(0,14,0,14)
    closeCP.Position = UDim2.new(1,-17,0,4)
    closeCP.BackgroundTransparency = 1
    closeCP.Font = Enum.Font.GothamBold
    closeCP.Text = "×"
    closeCP.TextColor3 = Color3.fromRGB(70,70,100)
    closeCP.TextSize = 13
    closeCP.ZIndex = 215
    closeCP.Parent = popup

    -- ── ЛОГИКА ───────────────────────────────────────────────────
    local hv, sv, vv = RGBtoHSV(currentColor.R, currentColor.G, currentColor.B)
    local pickerOpen = false

    local function colorToHex(c)
        return string.format("%02X%02X%02X",
            math.floor(c.R*255+0.5),
            math.floor(c.G*255+0.5),
            math.floor(c.B*255+0.5))
    end

    local function updateUI()
        local r2,g2,b2 = HSVtoRGB(hv,sv,vv)
        currentColor = Color3.new(r2,g2,b2)
        previewFrame.BackgroundColor3 = currentColor
        bigPreview.BackgroundColor3   = currentColor
        hexBox.Text = colorToHex(currentColor)

        -- Обновляем фон SV зоны (чистый hue)
        local hr,hg,hb = HSVtoRGB(hv,1,1)
        svColorBG.BackgroundColor3 = Color3.new(hr,hg,hb)

        -- Позиция курсора SV (в пикселях внутри контейнера)
        svCursor.Position = UDim2.new(0, math.clamp(math.floor(sv*SV_W), 0, SV_W),
                                       0, math.clamp(math.floor((1-vv)*SV_H), 0, SV_H))

        -- Позиция курсора hue
        hueCursor.Position = UDim2.new(0,-4, 0, math.clamp(math.floor(hv*SV_H)-2, 0, SV_H-4))

        if onChange then onChange(currentColor) end
    end

    updateUI()

    -- Hex ввод
    hexBox.FocusLost:Connect(function()
        local txt = hexBox.Text:gsub("#",""):gsub("%s",""):upper()
        if #txt == 6 then
            local rr = tonumber(txt:sub(1,2),16)
            local gg = tonumber(txt:sub(3,4),16)
            local bb = tonumber(txt:sub(5,6),16)
            if rr and gg and bb then
                hv,sv,vv = RGBtoHSV(rr/255,gg/255,bb/255)
                updateUI()
            end
        end
    end)

    -- SV drag
    local svDrag = false
    svHitbox.MouseButton1Down:Connect(function(x,y)
        svDrag = true
        local ab = svContainer.AbsolutePosition
        local sz = svContainer.AbsoluteSize
        sv = math.clamp((x-ab.X)/sz.X,0,1)
        vv = 1-math.clamp((y-ab.Y)/sz.Y,0,1)
        updateUI()
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then svDrag=false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if svDrag and i.UserInputType==Enum.UserInputType.MouseMovement then
            local ab = svContainer.AbsolutePosition
            local sz = svContainer.AbsoluteSize
            sv = math.clamp((i.Position.X-ab.X)/sz.X,0,1)
            vv = 1-math.clamp((i.Position.Y-ab.Y)/sz.Y,0,1)
            updateUI()
        end
    end)

    -- Hue drag
    local hueDrag = false
    hueHitbox.MouseButton1Down:Connect(function(x,y)
        hueDrag = true
        local ab = hueFrame.AbsolutePosition
        local sz = hueFrame.AbsoluteSize
        hv = math.clamp((y-ab.Y)/sz.Y,0,1)
        updateUI()
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then hueDrag=false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if hueDrag and i.UserInputType==Enum.UserInputType.MouseMovement then
            local ab = hueFrame.AbsolutePosition
            local sz = hueFrame.AbsoluteSize
            hv = math.clamp((i.Position.Y-ab.Y)/sz.Y,0,1)
            updateUI()
        end
    end)

    local function openPopup()
        if activeCP and activeCP ~= popup then activeCP.Visible=false end
        pickerOpen = true
        popup.Visible = true
        activeCP = popup
        local vp = workspace.CurrentCamera.ViewportSize
        local absPos = previewFrame.AbsolutePosition
        local sx = math.clamp(absPos.X - PW - 6, 4, vp.X - PW - 4)
        local sy = math.clamp(absPos.Y - PH/2, 4, vp.Y - PH - 4)
        popup.Position = UDim2.new(0,sx,0,sy)
    end

    local function closePopup()
        pickerOpen = false
        popup.Visible = false
        if activeCP==popup then activeCP=nil end
    end

    previewBtn.MouseButton1Click:Connect(function()
        if pickerOpen then closePopup() else openPopup() end
    end)
    closeCP.MouseButton1Click:Connect(closePopup)

    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 and pickerOpen then
            local mp = input.Position
            local pp = popup.AbsolutePosition
            local ps = popup.AbsoluteSize
            local inside = mp.X>=pp.X and mp.X<=pp.X+ps.X and mp.Y>=pp.Y and mp.Y<=pp.Y+ps.Y
            local vp2 = previewFrame.AbsolutePosition
            local vs = previewFrame.AbsoluteSize
            local onPrev = mp.X>=vp2.X and mp.X<=vp2.X+vs.X and mp.Y>=vp2.Y and mp.Y<=vp2.Y+vs.Y
            if not inside and not onPrev then closePopup() end
        end
    end)

    local ctrl = {}
    function ctrl:GetColor() return currentColor end
    function ctrl:SetColor(c)
        currentColor=c; hv,sv,vv=RGBtoHSV(c.R,c.G,c.B); updateUI()
    end
    return ctrl
end

-- ================================================================
-- ПОСТРОИТЕЛЬ ВКЛАДОК (стиль LinoriaLib)
-- ================================================================
local allTabs = {}

local function makeTab(name)
    local tabBtn  = Instance.new("TextButton")
    local tabPage = Instance.new("ScrollingFrame")
    local leftCol  = Instance.new("Frame")
    local rightCol = Instance.new("Frame")

    tabBtn.Parent = TabHolder
    tabBtn.BackgroundTransparency = 1
    tabBtn.Size = UDim2.new(0,90,1,0)
    tabBtn.Font = Enum.Font.GothamSemibold
    tabBtn.Text = name:upper()
    tabBtn.TextColor3 = Color3.fromRGB(55,55,80)
    tabBtn.TextSize = 10
    tabBtn.BorderSizePixel = 0

    tabPage.Parent = ContentHolder
    tabPage.BackgroundTransparency = 1
    tabPage.BorderSizePixel = 0
    tabPage.Size = UDim2.new(1,0,1,0)
    tabPage.CanvasSize = UDim2.new(0,0,0,0)
    tabPage.ScrollBarThickness = 2
    tabPage.ScrollBarImageColor3 = Color3.fromRGB(55,55,90)
    tabPage.Visible = false

    leftCol.Parent = tabPage
    leftCol.BackgroundTransparency = 1
    leftCol.Position = UDim2.new(0,8,0,8)
    leftCol.Size = UDim2.new(0.5,-12,1,0)
    local ll=Instance.new("UIListLayout"); ll.SortOrder=Enum.SortOrder.LayoutOrder
    ll.Padding=UDim.new(0,8); ll.Parent=leftCol

    rightCol.Parent = tabPage
    rightCol.BackgroundTransparency = 1
    rightCol.Position = UDim2.new(0.5,4,0,8)
    rightCol.Size = UDim2.new(0.5,-12,1,0)
    local rl=Instance.new("UIListLayout"); rl.SortOrder=Enum.SortOrder.LayoutOrder
    rl.Padding=UDim.new(0,8); rl.Parent=rightCol

    -- Нижняя подсветка активной вкладки
    local tabUnderline = Instance.new("Frame")
    tabUnderline.Size = UDim2.new(0.7,0,0,1)
    tabUnderline.Position = UDim2.new(0.15,0,1,-1)
    tabUnderline.BackgroundColor3 = Color3.fromRGB(255,255,255)
    tabUnderline.BackgroundTransparency = 1
    tabUnderline.BorderSizePixel = 0
    tabUnderline.Parent = tabBtn

    tabBtn.MouseButton1Click:Connect(function()
        for _,t in pairs(allTabs) do
            t.page.Visible = false
            t.btn.TextColor3 = Color3.fromRGB(55,55,80)
            t.underline.BackgroundTransparency = 1
        end
        tabPage.Visible = true
        tabBtn.TextColor3 = Color3.fromRGB(220,220,255)
        tabUnderline.BackgroundTransparency = 0
    end)

    local tabObj = {btn=tabBtn, page=tabPage, left=leftCol, right=rightCol, underline=tabUnderline}
    table.insert(allTabs, tabObj)
    if #allTabs==1 then
        tabPage.Visible=true
        tabBtn.TextColor3=Color3.fromRGB(220,220,255)
        tabUnderline.BackgroundTransparency=0
    end

    local tabAPI = {}

    function tabAPI:Section(sName, side)
        local col = side=="Right" and rightCol or leftCol
        local colLayout = col:FindFirstChildOfClass("UIListLayout")

        local frame = Instance.new("Frame")
        frame.Parent = col
        frame.BorderSizePixel = 1
        frame.Size = UDim2.new(1,0,0,30)
        frame.ClipsDescendants = false
        onTheme("SectionBG",     function(c) frame.BackgroundColor3=c end)
        onTheme("SectionBorder", function(c) frame.BorderColor3=c end)
        do local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,4); c.Parent=frame end

        local titleLbl = Instance.new("TextLabel")
        titleLbl.Parent = frame
        titleLbl.BorderSizePixel = 0
        titleLbl.Size = UDim2.new(1,0,0,20)
        titleLbl.Font = Enum.Font.GothamSemibold
        titleLbl.Text = sName:upper()
        titleLbl.TextColor3 = Color3.fromRGB(110,110,150)
        titleLbl.TextSize = 9
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left
        titleLbl.BackgroundTransparency = 1
        do local p=Instance.new("UIPadding"); p.PaddingLeft=UDim.new(0,10); p.Parent=titleLbl end

        -- Тонкая линия под заголовком секции
        local secDivider = Instance.new("Frame")
        secDivider.Size = UDim2.new(1,0,0,1)
        secDivider.Position = UDim2.new(0,0,0,20)
        secDivider.BorderSizePixel = 0
        secDivider.BackgroundColor3 = Color3.fromRGB(30,30,45)
        secDivider.Parent = frame

        local body = Instance.new("Frame")
        body.Parent = frame
        body.BackgroundTransparency = 1
        body.Position = UDim2.new(0,0,0,21)
        body.Size = UDim2.new(1,0,0,0)

        local bodyLayout = Instance.new("UIListLayout")
        bodyLayout.Parent = body
        bodyLayout.SortOrder = Enum.SortOrder.LayoutOrder
        bodyLayout.Padding = UDim.new(0,2)

        local bodyPad = Instance.new("UIPadding")
        bodyPad.Parent = body
        bodyPad.PaddingLeft = UDim.new(0,8)
        bodyPad.PaddingRight = UDim.new(0,8)
        bodyPad.PaddingTop = UDim.new(0,6)
        bodyPad.PaddingBottom = UDim.new(0,6)

        local function resize()
            local h2 = bodyLayout.AbsoluteContentSize.Y + 21 + 12
            frame.Size = UDim2.new(1,0,0,h2)
            body.Size = UDim2.new(1,0,0,h2-21)
            if colLayout then
                tabPage.CanvasSize = UDim2.new(0,0,0,colLayout.AbsoluteContentSize.Y+20)
            end
        end
        bodyLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resize)

        local sec = {}

        -- TOGGLE
        function sec:Toggle(id, tName, default, cb)
            local row=Instance.new("Frame"); row.Parent=body
            row.BackgroundTransparency=1; row.Size=UDim2.new(1,0,0,20)

            local lbl=Instance.new("TextLabel"); lbl.Parent=row
            lbl.BackgroundTransparency=1; lbl.Size=UDim2.new(0.7,0,1,0)
            lbl.Font=Enum.Font.Gotham; lbl.Text=tName
            lbl.TextSize=11; lbl.TextXAlignment=Enum.TextXAlignment.Left

            local tf=Instance.new("Frame"); tf.Parent=row
            tf.BorderSizePixel=0
            tf.Position=UDim2.new(1,-30,0.5,-8); tf.Size=UDim2.new(0,30,0,16)
            onTheme("ToggleBG", function(c) tf.BackgroundColor3=c end)
            do local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(1,0); c.Parent=tf end

            local ti=Instance.new("Frame"); ti.Parent=tf
            ti.BorderSizePixel=0
            ti.Size=UDim2.new(0,12,0,12); ti.Position=UDim2.new(0,2,0.5,-6)
            do local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(1,0); c.Parent=ti end

            local tb=Instance.new("TextButton"); tb.Parent=tf
            tb.BackgroundTransparency=1; tb.BorderSizePixel=0
            tb.Size=UDim2.new(1,0,1,0); tb.Text=""

            local state = default or false
            local function refresh()
                if state then
                    TweenService:Create(ti,TweenInfo.new(0.12),
                        {Position=UDim2.new(0,16,0.5,-6), BackgroundColor3=Theme.Accent}):Play()
                    lbl.TextColor3 = Theme.LabelOn
                else
                    TweenService:Create(ti,TweenInfo.new(0.12),
                        {Position=UDim2.new(0,2,0.5,-6), BackgroundColor3=Theme.ToggleOff}):Play()
                    lbl.TextColor3 = Theme.LabelText
                end
            end

            onTheme("LabelText", function(c) if not state then lbl.TextColor3=c end end)
            onTheme("LabelOn",   function(c) if state then lbl.TextColor3=c end end)
            onTheme("Accent",    function(c) if state then ti.BackgroundColor3=c end end)
            onTheme("ToggleOff", function(c) if not state then ti.BackgroundColor3=c end end)

            refresh()
            tb.MouseButton1Click:Connect(function()
                state=not state; refresh(); if cb then cb(state) end
            end)
            reg(id,"toggle",function() return state end, function(val)
                state=(val=="true" or val==true); refresh(); if cb then cb(state) end
            end)
        end

        -- SLIDER
        function sec:Slider(id, sName, mn, mx, default, suffix, cb)
            local wrap=Instance.new("Frame"); wrap.Parent=body
            wrap.BackgroundTransparency=1; wrap.Size=UDim2.new(1,0,0,30)
            suffix=suffix or ""
            local curVal = default or mn

            local lbl=Instance.new("TextLabel"); lbl.Parent=wrap
            lbl.BackgroundTransparency=1; lbl.Size=UDim2.new(0.65,0,0,15)
            lbl.Font=Enum.Font.Gotham; lbl.Text=sName
            lbl.TextSize=11; lbl.TextXAlignment=Enum.TextXAlignment.Left
            onTheme("LabelText", function(c) lbl.TextColor3=c end)

            local valLbl=Instance.new("TextLabel"); valLbl.Parent=wrap
            valLbl.BackgroundTransparency=1; valLbl.Position=UDim2.new(0.65,0,0,0)
            valLbl.Size=UDim2.new(0.35,0,0,15); valLbl.Font=Enum.Font.Code
            valLbl.Text=tostring(curVal)..suffix
            valLbl.TextColor3=Color3.fromRGB(100,100,140)
            valLbl.TextSize=10; valLbl.TextXAlignment=Enum.TextXAlignment.Right

            local track=Instance.new("Frame"); track.Parent=wrap
            track.BorderSizePixel=0
            track.Position=UDim2.new(0,0,0,19); track.Size=UDim2.new(1,0,0,5)
            onTheme("SliderTrack", function(c) track.BackgroundColor3=c end)
            do local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(1,0); c.Parent=track end

            local fill=Instance.new("Frame"); fill.Parent=track
            fill.BorderSizePixel=0
            fill.Size=UDim2.new((curVal-mn)/(mx-mn),0,1,0)
            onTheme("Accent", function(c) fill.BackgroundColor3=c end)
            do local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(1,0); c.Parent=fill end

            local btn=Instance.new("TextButton"); btn.Parent=track
            btn.BackgroundTransparency=1; btn.BorderSizePixel=0
            btn.Size=UDim2.new(1,0,1,0); btn.Text=""

            local function setVal(val)
                curVal=val
                fill.Size=UDim2.new((curVal-mn)/(mx-mn),0,1,0)
                valLbl.Text=tostring(curVal)..suffix
                if cb then cb(curVal) end
            end

            local sliding=false
            btn.MouseButton1Down:Connect(function() sliding=true end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=false end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if sliding and i.UserInputType==Enum.UserInputType.MouseMovement then
                    local ab=track.AbsolutePosition; local sz=track.AbsoluteSize
                    local pct=math.clamp((i.Position.X-ab.X)/sz.X,0,1)
                    setVal(math.floor(mn+pct*(mx-mn)))
                end
            end)

            reg(id,"slider",function() return curVal end, function(val)
                setVal(math.clamp(math.floor(tonumber(val) or mn),mn,mx))
            end)
        end

        -- BUTTON
        function sec:Button(bName, cb)
            local btn=Instance.new("TextButton"); btn.Parent=body
            btn.BorderSizePixel=1; btn.Size=UDim2.new(1,0,0,20)
            btn.Font=Enum.Font.GothamSemibold; btn.Text=bName:upper(); btn.TextSize=10
            onTheme("ButtonBG",     function(c) btn.BackgroundColor3=c end)
            onTheme("ButtonBorder", function(c) btn.BorderColor3=c end)
            onTheme("ButtonText",   function(c) btn.TextColor3=c end)
            do local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,3); c.Parent=btn end
            btn.MouseEnter:Connect(function()
                btn.TextColor3=Color3.fromRGB(230,230,255)
                btn.BorderColor3=Color3.fromRGB(90,90,130)
            end)
            btn.MouseLeave:Connect(function()
                btn.TextColor3=Theme.ButtonText
                btn.BorderColor3=Theme.ButtonBorder
            end)
            btn.MouseButton1Click:Connect(function() if cb then cb() end end)
        end

        -- DROPDOWN
        function sec:Dropdown(id, dName, options, cb)
            local wrap=Instance.new("Frame"); wrap.Parent=body
            wrap.BackgroundTransparency=1; wrap.Size=UDim2.new(1,0,0,20)
            wrap.ClipsDescendants=false; wrap.ZIndex=5
            local selected = options[1] or ""

            local lbl=Instance.new("TextLabel"); lbl.Parent=wrap
            lbl.BackgroundTransparency=1; lbl.Size=UDim2.new(0.45,0,1,0)
            lbl.Font=Enum.Font.Gotham; lbl.Text=dName
            lbl.TextSize=11; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=5
            onTheme("LabelText", function(c) lbl.TextColor3=c end)

            local box=Instance.new("TextButton"); box.Parent=wrap
            box.BorderSizePixel=1; box.Position=UDim2.new(0.45,0,0,0)
            box.Size=UDim2.new(0.55,0,1,0); box.Font=Enum.Font.Gotham; box.Text=""; box.ZIndex=5
            onTheme("ButtonBG",     function(c) box.BackgroundColor3=c end)
            onTheme("ButtonBorder", function(c) box.BorderColor3=c end)
            do local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,3); c.Parent=box end

            local boxLbl=Instance.new("TextLabel"); boxLbl.Parent=box
            boxLbl.BackgroundTransparency=1; boxLbl.Size=UDim2.new(1,-6,1,0)
            boxLbl.Position=UDim2.new(0,5,0,0); boxLbl.Font=Enum.Font.Code
            boxLbl.Text=selected; boxLbl.TextColor3=Color3.fromRGB(160,160,200)
            boxLbl.TextSize=10; boxLbl.TextXAlignment=Enum.TextXAlignment.Left; boxLbl.ZIndex=5

            -- Стрелка
            local arrow=Instance.new("TextLabel"); arrow.Parent=box
            arrow.BackgroundTransparency=1; arrow.Size=UDim2.new(0,14,1,0)
            arrow.Position=UDim2.new(1,-14,0,0); arrow.Font=Enum.Font.Code
            arrow.Text="▾"; arrow.TextColor3=Color3.fromRGB(80,80,120)
            arrow.TextSize=11; arrow.ZIndex=5

            local optHolder=Instance.new("Frame"); optHolder.Parent=wrap
            optHolder.BackgroundColor3=Color3.fromRGB(14,14,22)
            optHolder.BorderColor3=Color3.fromRGB(50,50,75); optHolder.BorderSizePixel=1
            optHolder.Position=UDim2.new(0.45,0,1,0)
            optHolder.Size=UDim2.new(0.55,0,0,#options*20)
            optHolder.Visible=false; optHolder.ZIndex=20
            do local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,3); c.Parent=optHolder end
            local ol=Instance.new("UIListLayout"); ol.SortOrder=Enum.SortOrder.LayoutOrder; ol.Parent=optHolder

            local function buildOpts(opts)
                for _,c2 in ipairs(optHolder:GetChildren()) do
                    if c2:IsA("TextButton") then c2:Destroy() end
                end
                optHolder.Size=UDim2.new(0.55,0,0,#opts*20)
                for _,opt in ipairs(opts) do
                    local ob=Instance.new("TextButton"); ob.Parent=optHolder
                    ob.BackgroundTransparency=1; ob.BorderSizePixel=0
                    ob.Size=UDim2.new(1,0,0,20); ob.Font=Enum.Font.Gotham
                    ob.Text=opt; ob.TextColor3=Color3.fromRGB(120,120,160)
                    ob.TextSize=10; ob.ZIndex=20
                    do local p=Instance.new("UIPadding"); p.PaddingLeft=UDim.new(0,6); p.Parent=ob end
                    ob.MouseEnter:Connect(function() ob.TextColor3=Color3.fromRGB(220,220,255) end)
                    ob.MouseLeave:Connect(function() ob.TextColor3=Color3.fromRGB(120,120,160) end)
                    ob.MouseButton1Click:Connect(function()
                        selected=opt; boxLbl.Text=opt; optHolder.Visible=false
                        if cb then cb(opt) end
                    end)
                end
                if #opts>0 then selected=opts[1]; boxLbl.Text=opts[1] end
            end
            buildOpts(options)
            box.MouseButton1Click:Connect(function() optHolder.Visible=not optHolder.Visible end)

            reg(id,"dropdown",function() return selected end, function(val)
                selected=val; boxLbl.Text=val; if cb then cb(val) end
            end)

            local ctrl = {}
            function ctrl:SetOptions(opts) buildOpts(opts) end
            function ctrl:GetSelected() return selected end
            return ctrl
        end

        -- TEXTBOX
        function sec:Textbox(id, tName, placeholder, cb)
            local wrap=Instance.new("Frame"); wrap.Parent=body
            wrap.BackgroundTransparency=1; wrap.Size=UDim2.new(1,0,0,30)

            local lbl=Instance.new("TextLabel"); lbl.Parent=wrap
            lbl.BackgroundTransparency=1; lbl.Size=UDim2.new(1,0,0,13)
            lbl.Font=Enum.Font.Gotham; lbl.Text=tName
            lbl.TextColor3=Color3.fromRGB(100,100,140)
            lbl.TextSize=10; lbl.TextXAlignment=Enum.TextXAlignment.Left

            local box=Instance.new("TextBox"); box.Parent=wrap
            box.BackgroundColor3=Color3.fromRGB(14,14,22)
            box.BorderColor3=Color3.fromRGB(38,38,58); box.BorderSizePixel=1
            box.Position=UDim2.new(0,0,0,14); box.Size=UDim2.new(1,0,0,15)
            box.Font=Enum.Font.Code; box.PlaceholderText=placeholder or ""
            box.PlaceholderColor3=Color3.fromRGB(55,55,80); box.Text=""
            box.TextColor3=Color3.fromRGB(180,180,220); box.TextSize=10
            box.TextXAlignment=Enum.TextXAlignment.Left; box.ClearTextOnFocus=false
            do local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,3); c.Parent=box end
            do local p=Instance.new("UIPadding"); p.PaddingLeft=UDim.new(0,5); p.Parent=box end

            box:GetPropertyChangedSignal("Text"):Connect(function()
                if cb then cb(box.Text) end
            end)

            reg(id,"textbox",function() return box.Text end, function(val)
                box.Text=tostring(val); if cb then cb(box.Text) end
            end)
        end

        -- KEYBIND
        function sec:Keybind(id, kName, default, cb)
            local row=Instance.new("Frame"); row.Parent=body
            row.BackgroundTransparency=1; row.Size=UDim2.new(1,0,0,20)
            local boundKey=default; local waiting=false

            local lbl=Instance.new("TextLabel"); lbl.Parent=row
            lbl.BackgroundTransparency=1; lbl.Size=UDim2.new(0.6,0,1,0)
            lbl.Font=Enum.Font.Gotham; lbl.Text=kName
            lbl.TextSize=11; lbl.TextXAlignment=Enum.TextXAlignment.Left
            onTheme("LabelText", function(c) lbl.TextColor3=c end)

            local kb=Instance.new("TextButton"); kb.Parent=row
            kb.BorderSizePixel=1; kb.Position=UDim2.new(0.6,0,0.5,-9)
            kb.Size=UDim2.new(0.4,0,0,18); kb.Font=Enum.Font.Code
            kb.Text=default and tostring(default):gsub("Enum.KeyCode.","") or "--"
            kb.TextColor3=Color3.fromRGB(100,100,140); kb.TextSize=9
            onTheme("ButtonBG",     function(c) kb.BackgroundColor3=c end)
            onTheme("ButtonBorder", function(c) kb.BorderColor3=c end)
            do local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,3); c.Parent=kb end

            kb.MouseButton1Click:Connect(function()
                waiting=true; kb.Text="..."; kb.TextColor3=Color3.fromRGB(200,200,255)
            end)
            UserInputService.InputBegan:Connect(function(input,gpe2)
                if waiting and not gpe2 and input.KeyCode~=Enum.KeyCode.Unknown then
                    waiting=false; boundKey=input.KeyCode
                    kb.Text=tostring(input.KeyCode):gsub("Enum.KeyCode.","")
                    kb.TextColor3=Color3.fromRGB(100,100,140)
                    if cb then cb(input.KeyCode) end
                end
            end)

            reg(id,"keybind",
                function() return boundKey and tostring(boundKey):gsub("Enum.KeyCode.","") or "--" end,
                function(val)
                    local keyStr=tostring(val); kb.Text=keyStr
                    local ok,kc=pcall(function() return Enum.KeyCode[keyStr] end)
                    if ok and kc then boundKey=kc; if cb then cb(kc) end end
                end
            )
        end

        -- COLOR PICKER
        function sec:ColorPicker(id, cpName, default, cb)
            local row=Instance.new("Frame"); row.Parent=body
            row.BackgroundTransparency=1; row.Size=UDim2.new(1,0,0,20)

            local lbl=Instance.new("TextLabel"); lbl.Parent=row
            lbl.BackgroundTransparency=1; lbl.Size=UDim2.new(0.75,0,1,0)
            lbl.Font=Enum.Font.Gotham; lbl.Text=cpName
            lbl.TextSize=11; lbl.TextXAlignment=Enum.TextXAlignment.Left
            onTheme("LabelText", function(c) lbl.TextColor3=c end)

            local cpCtrl = makeColorPicker(row, default, cb)

            reg(id,"color",
                function()
                    local c=cpCtrl:GetColor()
                    return math.floor(c.R*255+0.5)..","..math.floor(c.G*255+0.5)..","..math.floor(c.B*255+0.5)
                end,
                function(val)
                    local r2,g2,b2=val:match("(%d+),(%d+),(%d+)")
                    if r2 then
                        local nc=Color3.fromRGB(tonumber(r2),tonumber(g2),tonumber(b2))
                        cpCtrl:SetColor(nc); if cb then cb(nc) end
                    end
                end
            )
            return cpCtrl
        end

        -- DIVIDER
        function sec:Divider()
            local div=Instance.new("Frame"); div.Parent=body
            div.BackgroundColor3=Color3.fromRGB(28,28,42)
            div.BorderSizePixel=0; div.Size=UDim2.new(1,0,0,1)
        end

        return sec
    end

    return tabAPI
end

-- ================================================================
-- СОЗДАНИЕ ТОЛЬКО ВКЛАДКИ SETTINGS (постоянная, неудаляемая)
-- ================================================================
local setTab = makeTab("Settings")

-- ================================================================
-- SETTINGS
-- ================================================================
local bindSec  = setTab:Section("Keybinds", "Left")
local themeSec = setTab:Section("Theme",    "Left")
local cfgSec   = setTab:Section("Configs",  "Right")

bindSec:Keybind("menu_bind", "Toggle Menu", Enum.KeyCode.RightShift, function(key)
    menuBind = key
end)

themeSec:ColorPicker("theme_accent",     "Accent / Neon",  Color3.fromRGB(255,255,255), function(c)
    Theme.Accent = c
end)
themeSec:ColorPicker("theme_btn_bg",     "Button BG",      Color3.fromRGB(20,20,28),    function(c)
    Theme.ButtonBG = c
end)
themeSec:ColorPicker("theme_btn_border", "Button Border",  Color3.fromRGB(40,40,55),    function(c)
    Theme.ButtonBorder = c
end)
themeSec:ColorPicker("theme_btn_text",   "Button Text",    Color3.fromRGB(130,130,160), function(c)
    Theme.ButtonText = c
end)
themeSec:ColorPicker("theme_label",      "Label Text",     Color3.fromRGB(150,150,180), function(c)
    Theme.LabelText = c
end)
themeSec:ColorPicker("theme_window_bg",  "Window BG",      Color3.fromRGB(15,15,20),    function(c)
    Theme.WindowBG = c
end)
themeSec:Toggle("show_watermark", "Show Watermark", true, function(v)
    Watermark.Visible = v
end)

-- ================================================================
-- CONFIGS
-- ================================================================
local FOLDER = "ScriptHub"
if not isfolder(FOLDER) then makefolder(FOLDER) end

local currentCfgName = ""
local cfgDropHandle  = nil

local function getCfgList()
    local list = {}
    if isfolder(FOLDER) then
        for _,f in ipairs(listfiles(FOLDER)) do
            local fname = f:match("([^/\\]+)$") or f
            if fname:sub(-4)==".cfg" then
                table.insert(list, fname:sub(1,-5))
            end
        end
    end
    return list
end

local function refreshDrop()
    if cfgDropHandle then
        local lst = getCfgList()
        if #lst==0 then lst={"-- empty --"} end
        cfgDropHandle:SetOptions(lst)
    end
end

local function saveConfig(name)
    if not name or name=="" or name=="-- empty --" then return end
    local lines={}
    for id,entry in pairs(registry) do
        if id~="cfg_name" then
            local ok,val=pcall(entry.get)
            if ok and val~=nil then
                table.insert(lines, id.."="..tostring(val))
            end
        end
    end
    table.sort(lines)
    writefile(FOLDER.."/"..name..".cfg", table.concat(lines,"\n"))
end

local function loadConfig(name)
    if not name or name=="" or name=="-- empty --" then return end
    local path=FOLDER.."/"..name..".cfg"
    if not isfile(path) then return end
    local content=readfile(path)
    for line in content:gmatch("[^\n\r]+") do
        local id,val=line:match("^(.-)=(.+)$")
        if id and val and registry[id] then
            pcall(registry[id].set, val)
        end
    end
end

local function deleteConfig(name)
    if not name or name=="" or name=="-- empty --" then return end
    local path=FOLDER.."/"..name..".cfg"
    if isfile(path) then delfile(path) end
end

cfgSec:Textbox("cfg_name", "Config Name", "myconfig", function(v)
    currentCfgName = v
end)

cfgDropHandle = cfgSec:Dropdown("cfg_select", "Select Config",
    (function() local l=getCfgList(); return #l>0 and l or {"-- empty --"} end)(),
    function(v)
        if v~="-- empty --" then
            currentCfgName=v
            if registry["cfg_name"] then pcall(registry["cfg_name"].set,v) end
        end
    end
)

cfgSec:Button("Save Config", function()
    if currentCfgName=="" or currentCfgName=="-- empty --" then return end
    saveConfig(currentCfgName); refreshDrop()
end)
cfgSec:Button("Load Config", function()
    if currentCfgName=="" or currentCfgName=="-- empty --" then return end
    loadConfig(currentCfgName)
end)
cfgSec:Button("Delete Config", function()
    if currentCfgName=="" or currentCfgName=="-- empty --" then return end
    deleteConfig(currentCfgName); currentCfgName=""
    if registry["cfg_name"] then pcall(registry["cfg_name"].set,"") end
    refreshDrop()
end)

task.defer(refreshDrop)

-- ================================================================
-- КАК ДОБАВЛЯТЬ СВОИ ВКЛАДКИ (пример для разработчиков)
-- ================================================================
--[[
    Чтобы добавить новую вкладку с функциями, используй:

    local myTab = makeTab("MyCoolTab")

    local mySection = myTab:Section("My Section", "Left")

    mySection:Toggle("my_toggle", "Enable Feature", false, function(enabled)
        -- твой код
    end)

    mySection:Slider("my_slider", "Speed", 0, 100, 50, "", function(val)
        -- твой код
    end)

    mySection:Button("Do Something", function()
        -- твой код
    end)

    mySection:ColorPicker("my_color", "Color", Color3.fromRGB(255,0,0), function(color)
        -- твой код
    end)

    mySection:Keybind("my_key", "Hotkey", Enum.KeyCode.F, function(key)
        -- твой код
    end)

    mySection:Dropdown("my_drop", "Mode", {"Option1","Option2"}, function(selected)
        -- твой код
    end)

    Правая колонка: myTab:Section("Name", "Right")
    Дизайн и функционал полностью соответствуют Settings вкладке.
]]--

-- ================================================================
-- ЗАПУСК
-- ================================================================
animateLoader(function()
    MainFrame.Visible = true
end)
