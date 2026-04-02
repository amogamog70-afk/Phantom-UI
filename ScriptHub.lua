-- ScriptHub Library v2.4
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
    local v   = max
    local s   = max == 0 and 0 or (max-min)/max
    local h   = 0
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
    WindowBG      = Color3.fromRGB(8,8,8),
    TitleBG       = Color3.fromRGB(12,12,12),
    SectionBG     = Color3.fromRGB(12,12,12),
    SectionBorder = Color3.fromRGB(30,30,30),
    ButtonBG      = Color3.fromRGB(14,14,14),
    ButtonBorder  = Color3.fromRGB(35,35,35),
    ButtonText    = Color3.fromRGB(120,120,120),
    LabelText     = Color3.fromRGB(140,140,140),
    LabelOn       = Color3.fromRGB(220,220,220),
    SliderTrack   = Color3.fromRGB(18,18,18),
    ToggleBG      = Color3.fromRGB(18,18,18),
    ToggleOff     = Color3.fromRGB(35,35,35),
    StatusText    = Color3.fromRGB(45,45,45),
    WatermarkBG   = Color3.fromRGB(8,8,8),
}
local _themeListeners = {}

setmetatable(Theme, {
    __index    = function(_, k) return _themeValues[k] end,
    __newindex = function(_, k, v)
        _themeValues[k] = v
        if _themeListeners[k] then
            for _, fn in ipairs(_themeListeners[k]) do pcall(fn, v) end
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
ScreenGui.Name             = "ScriptHub"
ScreenGui.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn     = false
if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
end
ScreenGui.Parent = game:GetService("CoreGui")

-- ================================================================
-- ЗАГРУЗОЧНЫЙ ЭКРАН
-- ================================================================
local LoadGui = Instance.new("ScreenGui")
LoadGui.Name            = "ScriptHubLoader"
LoadGui.IgnoreGuiInset  = true
if syn and syn.protect_gui then syn.protect_gui(LoadGui) end
LoadGui.Parent = game:GetService("CoreGui")

local LoadBG = Instance.new("Frame")
LoadBG.Size              = UDim2.new(1,0,1,0)
LoadBG.BackgroundColor3  = Color3.fromRGB(5,5,5)
LoadBG.BorderSizePixel   = 0
LoadBG.Parent            = LoadGui

for i = 1, 10 do
    local sl = Instance.new("Frame")
    sl.Size             = UDim2.new(1,0,0,1)
    sl.Position         = UDim2.new(0,0, i/11, 0)
    sl.BackgroundColor3 = Color3.fromRGB(14,14,14)
    sl.BorderSizePixel  = 0
    sl.Parent           = LoadBG
end

local LoadBox = Instance.new("Frame")
LoadBox.Size            = UDim2.new(0,380,0,270)
LoadBox.Position        = UDim2.new(0.5,-190, 0.5,-135)
LoadBox.BackgroundColor3= Color3.fromRGB(8,8,8)
LoadBox.BorderSizePixel = 0
LoadBox.Parent          = LoadBG
do
    local s = Instance.new("UIStroke")
    s.Color             = Color3.fromRGB(255,255,255)
    s.Thickness         = 1
    s.ApplyStrokeMode   = Enum.ApplyStrokeMode.Border
    s.Parent            = LoadBox
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,2)
    c.Parent       = LoadBox
end

local function makeCornerAccent(parent, xScale, yScale, xFlip, yFlip)
    local corner = Instance.new("Frame")
    corner.BackgroundTransparency = 1
    corner.Size     = UDim2.new(0,24,0,24)
    corner.Position = UDim2.new(xScale, xFlip and -24 or 0, yScale, yFlip and -24 or 0)
    corner.Parent   = parent
    local hLine = Instance.new("Frame")
    hLine.Size             = UDim2.new(1,0,0,1)
    hLine.Position         = UDim2.new(0,0, yFlip and 1 or 0, 0)
    hLine.BackgroundColor3 = Color3.fromRGB(255,255,255)
    hLine.BorderSizePixel  = 0
    hLine.Parent           = corner
    local vLine = Instance.new("Frame")
    vLine.Size             = UDim2.new(0,1,1,0)
    vLine.Position         = UDim2.new(xFlip and 1 or 0,0,0,0)
    vLine.BackgroundColor3 = Color3.fromRGB(255,255,255)
    vLine.BorderSizePixel  = 0
    vLine.Parent           = corner
end
makeCornerAccent(LoadBox,0,0,false,false)
makeCornerAccent(LoadBox,1,0,true, false)
makeCornerAccent(LoadBox,0,1,false,true)
makeCornerAccent(LoadBox,1,1,true, true)

local LogoFrame = Instance.new("Frame")
LogoFrame.Size               = UDim2.new(0,44,0,44)
LogoFrame.Position           = UDim2.new(0.5,-22,0,24)
LogoFrame.BackgroundTransparency = 1
LogoFrame.Parent             = LoadBox

local DiamondParts = {
    {UDim2.new(0.5,-2,0,0),   UDim2.new(0,4,0.5,0)},
    {UDim2.new(0.5,-2,0.5,0), UDim2.new(0,4,0.5,0)},
    {UDim2.new(0,0,0.5,-2),   UDim2.new(0.5,0,0,4)},
    {UDim2.new(0.5,0,0.5,-2), UDim2.new(0.5,0,0,4)},
}
for _,d in ipairs(DiamondParts) do
    local f = Instance.new("Frame")
    f.Position          = d[1]; f.Size = d[2]
    f.BackgroundColor3  = Color3.fromRGB(255,255,255)
    f.BorderSizePixel   = 0; f.Parent = LogoFrame
end
local DiamondCenter = Instance.new("Frame")
DiamondCenter.Position         = UDim2.new(0.5,-3,0.5,-3)
DiamondCenter.Size             = UDim2.new(0,6,0,6)
DiamondCenter.BackgroundColor3 = Color3.fromRGB(255,255,255)
DiamondCenter.BorderSizePixel  = 0
DiamondCenter.Parent           = LogoFrame

local LoadTitle = Instance.new("TextLabel")
LoadTitle.Size               = UDim2.new(1,0,0,22)
LoadTitle.Position           = UDim2.new(0,0,0,78)
LoadTitle.BackgroundTransparency = 1
LoadTitle.Font               = Enum.Font.Code
LoadTitle.Text               = "SCRIPT HUB"
LoadTitle.TextColor3         = Color3.fromRGB(255,255,255)
LoadTitle.TextSize           = 22
LoadTitle.Parent             = LoadBox

local LoadVersion = Instance.new("TextLabel")
LoadVersion.Size               = UDim2.new(1,0,0,14)
LoadVersion.Position           = UDim2.new(0,0,0,103)
LoadVersion.BackgroundTransparency = 1
LoadVersion.Font               = Enum.Font.Code
LoadVersion.Text               = "v 2 . 4"
LoadVersion.TextColor3         = Color3.fromRGB(45,45,45)
LoadVersion.TextSize           = 10
LoadVersion.Parent             = LoadBox

local LoadDivider = Instance.new("Frame")
LoadDivider.Size            = UDim2.new(0,60,0,1)
LoadDivider.Position        = UDim2.new(0.5,-30,0,124)
LoadDivider.BackgroundColor3= Color3.fromRGB(35,35,35)
LoadDivider.BorderSizePixel = 0
LoadDivider.Parent          = LoadBox

local ThanksLabel = Instance.new("TextLabel")
ThanksLabel.Size               = UDim2.new(1,-40,0,28)
ThanksLabel.Position           = UDim2.new(0,20,0,132)
ThanksLabel.BackgroundTransparency = 1
ThanksLabel.Font               = Enum.Font.Code
ThanksLabel.Text               = "Спасибо, что используете наш продукт!"
ThanksLabel.TextColor3         = Color3.fromRGB(55,55,55)
ThanksLabel.TextSize           = 11
ThanksLabel.TextWrapped        = true
ThanksLabel.Parent             = LoadBox

local BarBG = Instance.new("Frame")
BarBG.Size            = UDim2.new(0,300,0,2)
BarBG.Position        = UDim2.new(0.5,-150,0,186)
BarBG.BackgroundColor3= Color3.fromRGB(16,16,16)
BarBG.BorderSizePixel = 0
BarBG.Parent          = LoadBox

local BarFill = Instance.new("Frame")
BarFill.Size            = UDim2.new(0,0,1,0)
BarFill.BackgroundColor3= Color3.fromRGB(255,255,255)
BarFill.BorderSizePixel = 0
BarFill.Parent          = BarBG

local LoadPct = Instance.new("TextLabel")
LoadPct.Size               = UDim2.new(1,0,0,12)
LoadPct.Position           = UDim2.new(0,0,0,168)
LoadPct.BackgroundTransparency = 1
LoadPct.Font               = Enum.Font.Code
LoadPct.Text               = "0%"
LoadPct.TextColor3         = Color3.fromRGB(70,70,70)
LoadPct.TextSize           = 10
LoadPct.Parent             = LoadBox

local LoadStatus = Instance.new("TextLabel")
LoadStatus.Size               = UDim2.new(1,-20,0,12)
LoadStatus.Position           = UDim2.new(0,10,0,202)
LoadStatus.BackgroundTransparency = 1
LoadStatus.Font               = Enum.Font.Code
LoadStatus.Text               = "Инициализация..."
LoadStatus.TextColor3         = Color3.fromRGB(40,40,40)
LoadStatus.TextSize           = 10
LoadStatus.TextXAlignment     = Enum.TextXAlignment.Left
LoadStatus.Parent             = LoadBox

local AuthorLabel = Instance.new("TextLabel")
AuthorLabel.Size               = UDim2.new(1,-20,0,12)
AuthorLabel.Position           = UDim2.new(0,10,0,240)
AuthorLabel.BackgroundTransparency = 1
AuthorLabel.Font               = Enum.Font.Code
AuthorLabel.Text               = "ScriptHub  ·  2024"
AuthorLabel.TextColor3         = Color3.fromRGB(28,28,28)
AuthorLabel.TextSize           = 10
AuthorLabel.TextXAlignment     = Enum.TextXAlignment.Right
AuthorLabel.Parent             = LoadBox

local PulseDot = Instance.new("Frame")
PulseDot.Size            = UDim2.new(0,4,0,4)
PulseDot.Position        = UDim2.new(1,-16,0,204)
PulseDot.BackgroundColor3= Color3.fromRGB(255,255,255)
PulseDot.BorderSizePixel = 0
PulseDot.Parent          = LoadBox
do local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(1,0); c.Parent=PulseDot end

task.spawn(function()
    while PulseDot and PulseDot.Parent do
        TweenService:Create(PulseDot,TweenInfo.new(0.6,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),
            {BackgroundTransparency=0.85}):Play()
        task.wait(0.6)
        TweenService:Create(PulseDot,TweenInfo.new(0.6,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),
            {BackgroundTransparency=0}):Play()
        task.wait(0.6)
    end
end)

local loadSteps = {
    {text="Загрузка ядра...",       pct=0.20},
    {text="Загрузка интерфейса...", pct=0.45},
    {text="Загрузка модулей...",    pct=0.68},
    {text="Загрузка конфигов...",   pct=0.88},
    {text="Готово!",                pct=1.00},
}

local function animateLoader(onDone)
    local i = 0
    local function step()
        i = i + 1
        if i > #loadSteps then
            task.wait(0.4)
            for _, child in ipairs(LoadBG:GetDescendants()) do
                if child:IsA("Frame") or child:IsA("TextLabel") then
                    pcall(function()
                        TweenService:Create(child, TweenInfo.new(0.5,Enum.EasingStyle.Quad),
                            {BackgroundTransparency=1}):Play()
                    end)
                end
            end
            TweenService:Create(LoadBG, TweenInfo.new(0.5,Enum.EasingStyle.Quad),
                {BackgroundTransparency=1}):Play()
            task.wait(0.55)
            LoadGui:Destroy()
            if onDone then onDone() end
            return
        end
        local st = loadSteps[i]
        LoadStatus.Text = st.text
        LoadPct.Text    = math.floor(st.pct*100).."%"
        TweenService:Create(BarFill,TweenInfo.new(0.3,Enum.EasingStyle.Quad),
            {Size=UDim2.new(st.pct,0,1,0)}):Play()
        task.wait(0.36)
        step()
    end
    task.spawn(step)
end

-- ================================================================
-- WATERMARK
-- ================================================================
local Watermark = Instance.new("Frame")
Watermark.BorderSizePixel = 0
Watermark.Position        = UDim2.new(0,8,0,8)
Watermark.Size            = UDim2.new(0,280,0,22)
Watermark.Parent          = ScreenGui
onTheme("WatermarkBG", function(c) Watermark.BackgroundColor3=c end)

local WMStroke = Instance.new("UIStroke")
WMStroke.Thickness      = 1.5
WMStroke.ApplyStrokeMode= Enum.ApplyStrokeMode.Border
WMStroke.Parent         = Watermark
onTheme("Accent", function(c) WMStroke.Color=c end)
do local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,2); c.Parent=Watermark end

local WMLabel = Instance.new("TextLabel")
WMLabel.BackgroundTransparency = 1
WMLabel.Size              = UDim2.new(1,0,1,0)
WMLabel.Font              = Enum.Font.Code
WMLabel.TextColor3        = Color3.fromRGB(180,180,180)
WMLabel.TextSize          = 11
WMLabel.TextXAlignment    = Enum.TextXAlignment.Left
WMLabel.Parent            = Watermark
do local p=Instance.new("UIPadding"); p.PaddingLeft=UDim.new(0,8); p.Parent=WMLabel end

local fps2,frameCount2,lastTime2 = 60,0,tick()
RunService.RenderStepped:Connect(function()
    frameCount2 = frameCount2+1
    local now = tick()
    if now-lastTime2 >= 1 then fps2=frameCount2; frameCount2=0; lastTime2=now end
    local ping = math.floor(LocalPlayer:GetNetworkPing()*1000)
    WMLabel.Text = LocalPlayer.Name.."  |  FPS: "..fps2.."  |  PING: "..ping.."ms"
end)

-- ================================================================
-- MAIN FRAME
-- ================================================================
local MainFrame = Instance.new("Frame")
MainFrame.BorderSizePixel  = 0
MainFrame.Position         = UDim2.new(0.5,-290,0.5,-200)
MainFrame.Size             = UDim2.new(0,580,0,420)
MainFrame.ClipsDescendants = true
MainFrame.Visible          = false
MainFrame.Parent           = ScreenGui
onTheme("WindowBG", function(c) MainFrame.BackgroundColor3=c end)

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness      = 1.5
MainStroke.ApplyStrokeMode= Enum.ApplyStrokeMode.Border
MainStroke.Parent         = MainFrame
onTheme("Accent", function(c) MainStroke.Color=c end)
do local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,3); c.Parent=MainFrame end

-- Drag
do
    local dragging,dragInput,dragStart,startPos
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
            local d = input.Position-dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,
                                           startPos.Y.Scale,startPos.Y.Offset+d.Y)
        end
    end)
end

-- TITLE BAR
local TitleBar = Instance.new("Frame")
TitleBar.BorderColor3  = Color3.fromRGB(30,30,30)
TitleBar.BorderSizePixel=1
TitleBar.Size          = UDim2.new(1,0,0,28)
TitleBar.Parent        = MainFrame
onTheme("TitleBG", function(c) TitleBar.BackgroundColor3=c end)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.BackgroundTransparency=1
TitleLabel.Size              = UDim2.new(1,-40,1,0)
TitleLabel.Position          = UDim2.new(0,12,0,0)
TitleLabel.Font              = Enum.Font.Code
TitleLabel.Text              = ":: SCRIPT HUB ::"
TitleLabel.TextColor3        = Color3.fromRGB(100,100,100)
TitleLabel.TextSize          = 11
TitleLabel.TextXAlignment    = Enum.TextXAlignment.Left
TitleLabel.Parent            = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.BackgroundTransparency=1
CloseBtn.Position  = UDim2.new(1,-24,0,6)
CloseBtn.Size      = UDim2.new(0,16,0,16)
CloseBtn.Font      = Enum.Font.Code
CloseBtn.Text      = "×"
CloseBtn.TextColor3= Color3.fromRGB(80,80,80)
CloseBtn.TextSize  = 14
CloseBtn.Parent    = TitleBar
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible=false end)

local TabHolder = Instance.new("Frame")
TabHolder.BackgroundColor3= Color3.fromRGB(10,10,10)
TabHolder.BorderColor3    = Color3.fromRGB(25,25,25)
TabHolder.BorderSizePixel = 1
TabHolder.Position        = UDim2.new(0,0,0,28)
TabHolder.Size            = UDim2.new(1,0,0,24)
TabHolder.Parent          = MainFrame
local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.SortOrder     = Enum.SortOrder.LayoutOrder
TabLayout.Parent        = TabHolder

local ContentHolder = Instance.new("Frame")
ContentHolder.BackgroundTransparency=1
ContentHolder.Position = UDim2.new(0,0,0,52)
ContentHolder.Size     = UDim2.new(1,0,1,-72)
ContentHolder.Parent   = MainFrame

local StatusBar = Instance.new("Frame")
StatusBar.BackgroundColor3= Color3.fromRGB(8,8,8)
StatusBar.BorderColor3    = Color3.fromRGB(25,25,25)
StatusBar.BorderSizePixel = 1
StatusBar.Position        = UDim2.new(0,0,1,-20)
StatusBar.Size            = UDim2.new(1,0,0,20)
StatusBar.Parent          = MainFrame
local StatusLabel = Instance.new("TextLabel")
StatusLabel.BackgroundTransparency=1
StatusLabel.Size          = UDim2.new(1,-10,1,0)
StatusLabel.Position      = UDim2.new(0,8,0,0)
StatusLabel.Font          = Enum.Font.Code
StatusLabel.Text          = ":: SCRIPT HUB v2.4   |   RSHIFT — TOGGLE"
StatusLabel.TextSize      = 10
StatusLabel.TextXAlignment= Enum.TextXAlignment.Left
StatusLabel.Parent        = StatusBar
onTheme("StatusText", function(c) StatusLabel.TextColor3=c end)

local menuBind = Enum.KeyCode.RightShift
UserInputService.InputBegan:Connect(function(input,gpe)
    if not gpe and input.KeyCode==menuBind then
        MainFrame.Visible=not MainFrame.Visible
    end
end)

-- ================================================================
-- COLOR PICKER
-- ================================================================
local activeCP = nil

local function makeColorPicker(parentRow, default, onChange)
    local currentColor = default or Color3.fromRGB(255,255,255)

    local previewFrame = Instance.new("Frame")
    previewFrame.BackgroundColor3 = currentColor
    previewFrame.BorderColor3     = Color3.fromRGB(60,60,60)
    previewFrame.BorderSizePixel  = 1
    previewFrame.Position         = UDim2.new(1,-22,0.5,-8)
    previewFrame.Size             = UDim2.new(0,22,0,16)
    previewFrame.Parent           = parentRow

    local previewBtn = Instance.new("TextButton")
    previewBtn.BackgroundTransparency=1
    previewBtn.Size   = UDim2.new(1,0,1,0)
    previewBtn.Text   = ""
    previewBtn.ZIndex = 6
    previewBtn.Parent = previewFrame

    local PW,PH         = 230,214
    local SV_X,SV_Y     = 10,10
    local SV_W,SV_H     = 170,160
    local HUE_X,HUE_W   = 188,20
    local BOTTOM_Y      = SV_Y+SV_H+8

    local popup = Instance.new("Frame")
    popup.Size            = UDim2.new(0,PW,0,PH)
    popup.BackgroundColor3= Color3.fromRGB(11,11,11)
    popup.BorderSizePixel = 0
    popup.Visible         = false
    popup.ZIndex          = 100
    popup.Parent          = ScreenGui
    do
        local s=Instance.new("UIStroke"); s.Color=Color3.fromRGB(60,60,60)
        s.Thickness=1; s.Parent=popup
        local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,4); c.Parent=popup
    end

    local svContainer = Instance.new("Frame")
    svContainer.Position        = UDim2.new(0,SV_X,0,SV_Y)
    svContainer.Size            = UDim2.new(0,SV_W,0,SV_H)
    svContainer.BorderSizePixel = 0
    svContainer.ZIndex          = 101
    svContainer.Parent          = popup
    do local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,3); c.Parent=svContainer end

    local svHueLayer = Instance.new("Frame")
    svHueLayer.Size            = UDim2.new(1,0,1,0)
    svHueLayer.BorderSizePixel = 0
    svHueLayer.ZIndex          = 101
    svHueLayer.Parent          = svContainer
    do local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,3); c.Parent=svHueLayer end

    local svSatLayer = Instance.new("Frame")
    svSatLayer.Size            = UDim2.new(1,0,1,0)
    svSatLayer.BackgroundColor3= Color3.fromRGB(255,255,255)
    svSatLayer.BorderSizePixel = 0
    svSatLayer.ZIndex          = 102
    svSatLayer.Parent          = svContainer
    do local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,3); c.Parent=svSatLayer end
    local satGrad = Instance.new("UIGradient")
    satGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1),
    })
    satGrad.Rotation = 0
    satGrad.Parent   = svSatLayer

    local svValLayer = Instance.new("Frame")
    svValLayer.Size            = UDim2.new(1,0,1,0)
    svValLayer.BackgroundColor3= Color3.fromRGB(0,0,0)
    svValLayer.BorderSizePixel = 0
    svValLayer.ZIndex          = 103
    svValLayer.Parent          = svContainer
    do local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,3); c.Parent=svValLayer end
    local valGrad = Instance.new("UIGradient")
    valGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0),
    })
    valGrad.Rotation = 90
    valGrad.Parent   = svValLayer

    local svHitbox = Instance.new("TextButton")
    svHitbox.Size               = UDim2.new(1,0,1,0)
    svHitbox.BackgroundTransparency=1
    svHitbox.Text               = ""
    svHitbox.ZIndex             = 105
    svHitbox.Parent             = svContainer

    local svCursorOuter = Instance.new("Frame")
    svCursorOuter.Size            = UDim2.new(0,12,0,12)
    svCursorOuter.AnchorPoint     = Vector2.new(0.5,0.5)
    svCursorOuter.BackgroundColor3= Color3.fromRGB(255,255,255)
    svCursorOuter.BorderSizePixel = 0
    svCursorOuter.ZIndex          = 106
    svCursorOuter.Parent          = svContainer
    do local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(1,0); c.Parent=svCursorOuter end

    local svCursorInner = Instance.new("Frame")
    svCursorInner.Size            = UDim2.new(0,8,0,8)
    svCursorInner.AnchorPoint     = Vector2.new(0.5,0.5)
    svCursorInner.Position        = UDim2.new(0.5,0,0.5,0)
    svCursorInner.BackgroundColor3= Color3.fromRGB(0,0,0)
    svCursorInner.BorderSizePixel = 0
    svCursorInner.ZIndex          = 107
    svCursorInner.Parent          = svCursorOuter
    do local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(1,0); c.Parent=svCursorInner end

    local hueFrame = Instance.new("Frame")
    hueFrame.Size               = UDim2.new(0,HUE_W,0,SV_H)
    hueFrame.Position           = UDim2.new(0,HUE_X,0,SV_Y)
    hueFrame.BackgroundTransparency=1
    hueFrame.BorderSizePixel    = 0
    hueFrame.ZIndex             = 101
    hueFrame.Parent             = popup
    do local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,3); c.Parent=hueFrame end

    local hueClip = Instance.new("Frame")
    hueClip.Size               = UDim2.new(1,0,1,0)
    hueClip.BackgroundTransparency=1
    hueClip.BorderSizePixel    = 0
    hueClip.ClipsDescendants   = true
    hueClip.ZIndex             = 101
    hueClip.Parent             = hueFrame
    do local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,3); c.Parent=hueClip end

    local hueSegments = {
        {Color3.fromRGB(255,0,0),   Color3.fromRGB(255,255,0)},
        {Color3.fromRGB(255,255,0), Color3.fromRGB(0,255,0)},
        {Color3.fromRGB(0,255,0),   Color3.fromRGB(0,255,255)},
        {Color3.fromRGB(0,255,255), Color3.fromRGB(0,0,255)},
        {Color3.fromRGB(0,0,255),   Color3.fromRGB(255,0,255)},
        {Color3.fromRGB(255,0,255), Color3.fromRGB(255,0,0)},
    }
    local segH = SV_H/#hueSegments
    for i2, pair in ipairs(hueSegments) do
        local seg = Instance.new("Frame")
        seg.Size            = UDim2.new(1,0,0,math.ceil(segH)+1)
        seg.Position        = UDim2.new(0,0,0,math.floor((i2-1)*segH))
        seg.BackgroundColor3= pair[1]
        seg.BorderSizePixel = 0
        seg.ZIndex          = 102
        seg.Parent          = hueClip
        local g = Instance.new("UIGradient")
        g.Color    = ColorSequence.new(pair[1], pair[2])
        g.Rotation = 90
        g.Parent   = seg
    end

    local hueHitbox = Instance.new("TextButton")
    hueHitbox.Size                = UDim2.new(1,0,1,0)
    hueHitbox.BackgroundTransparency=1
    hueHitbox.Text                = ""
    hueHitbox.ZIndex              = 103
    hueHitbox.Parent              = hueFrame

    local hueCursorOuter = Instance.new("Frame")
    hueCursorOuter.Size            = UDim2.new(1,6,0,6)
    hueCursorOuter.AnchorPoint     = Vector2.new(0,0.5)
    hueCursorOuter.Position        = UDim2.new(0,-3,0,0)
    hueCursorOuter.BackgroundColor3= Color3.fromRGB(255,255,255)
    hueCursorOuter.BorderSizePixel = 0
    hueCursorOuter.ZIndex          = 104
    hueCursorOuter.Parent          = hueFrame
    do local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,2); c.Parent=hueCursorOuter end

    local hueCursorInner = Instance.new("Frame")
    hueCursorInner.Size            = UDim2.new(1,-4,0,2)
    hueCursorInner.AnchorPoint     = Vector2.new(0,0.5)
    hueCursorInner.Position        = UDim2.new(0,2,0.5,0)
    hueCursorInner.BackgroundColor3= Color3.fromRGB(0,0,0)
    hueCursorInner.BorderSizePixel = 0
    hueCursorInner.ZIndex          = 105
    hueCursorInner.Parent          = hueCursorOuter
    do local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,1); c.Parent=hueCursorInner end

    local hexBG = Instance.new("Frame")
    hexBG.Size            = UDim2.new(0,110,0,20)
    hexBG.Position        = UDim2.new(0,SV_X,0,BOTTOM_Y)
    hexBG.BackgroundColor3= Color3.fromRGB(16,16,16)
    hexBG.BorderColor3    = Color3.fromRGB(40,40,40)
    hexBG.BorderSizePixel = 1
    hexBG.ZIndex          = 101
    hexBG.Parent          = popup
    do local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,3); c.Parent=hexBG end

    local hexLabel = Instance.new("TextLabel")
    hexLabel.Size                = UDim2.new(0,14,1,0)
    hexLabel.Position            = UDim2.new(0,6,0,0)
    hexLabel.BackgroundTransparency=1
    hexLabel.Font                = Enum.Font.Code
    hexLabel.Text                = "#"
    hexLabel.TextColor3          = Color3.fromRGB(55,55,55)
    hexLabel.TextSize            = 11
    hexLabel.ZIndex              = 102
    hexLabel.Parent              = hexBG

    local hexBox = Instance.new("TextBox")
    hexBox.Size               = UDim2.new(1,-22,1,-4)
    hexBox.Position           = UDim2.new(0,20,0,2)
    hexBox.BackgroundTransparency=1
    hexBox.BorderSizePixel    = 0
    hexBox.Font               = Enum.Font.Code
    hexBox.Text               = ""
    hexBox.TextColor3         = Color3.fromRGB(200,200,200)
    hexBox.TextSize           = 11
    hexBox.TextXAlignment     = Enum.TextXAlignment.Left
    hexBox.ClearTextOnFocus   = false
    hexBox.ZIndex             = 102
    hexBox.Parent             = hexBG

    local bigPreview = Instance.new("Frame")
    bigPreview.Size           = UDim2.new(0,PW-SV_X-110-12,0,20)
    bigPreview.Position       = UDim2.new(0,SV_X+110+6,0,BOTTOM_Y)
    bigPreview.BorderColor3   = Color3.fromRGB(40,40,40)
    bigPreview.BorderSizePixel= 1
    bigPreview.ZIndex         = 101
    bigPreview.Parent         = popup
    do local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,3); c.Parent=bigPreview end

    local closeCP = Instance.new("TextButton")
    closeCP.Size                = UDim2.new(0,14,0,14)
    closeCP.Position            = UDim2.new(1,-16,0,3)
    closeCP.BackgroundTransparency=1
    closeCP.Font                = Enum.Font.Code
    closeCP.Text                = "×"
    closeCP.TextColor3          = Color3.fromRGB(70,70,70)
    closeCP.TextSize            = 13
    closeCP.ZIndex              = 115
    closeCP.Parent              = popup

    local hv,sv,vv = RGBtoHSV(currentColor.R, currentColor.G, currentColor.B)
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
        svCursorInner.BackgroundColor3= currentColor
        hexBox.Text = colorToHex(currentColor)
        local hr,hg,hb = HSVtoRGB(hv,1,1)
        svHueLayer.BackgroundColor3 = Color3.new(hr,hg,hb)
        svCursorOuter.Position = UDim2.new(
            0, math.clamp(math.floor(sv*SV_W), 0, SV_W),
            0, math.clamp(math.floor((1-vv)*SV_H), 0, SV_H))
        hueCursorOuter.Position = UDim2.new(0,-3, 0,
            math.clamp(math.floor(hv*SV_H)-3, 0, SV_H-6))
        if onChange then onChange(currentColor) end
    end

    updateUI()

    hexBox.FocusLost:Connect(function()
        local txt = hexBox.Text:gsub("#",""):gsub("%s",""):upper()
        if #txt==6 then
            local rr=tonumber(txt:sub(1,2),16)
            local gg=tonumber(txt:sub(3,4),16)
            local bb=tonumber(txt:sub(5,6),16)
            if rr and gg and bb then
                hv,sv,vv = RGBtoHSV(rr/255,gg/255,bb/255); updateUI()
            end
        end
    end)

    local svDrag=false
    svHitbox.MouseButton1Down:Connect(function(x,y)
        svDrag=true
        local ab=svContainer.AbsolutePosition; local sz=svContainer.AbsoluteSize
        sv=math.clamp((x-ab.X)/sz.X,0,1)
        vv=1-math.clamp((y-ab.Y)/sz.Y,0,1)
        updateUI()
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then svDrag=false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if svDrag and i.UserInputType==Enum.UserInputType.MouseMovement then
            local ab=svContainer.AbsolutePosition; local sz=svContainer.AbsoluteSize
            sv=math.clamp((i.Position.X-ab.X)/sz.X,0,1)
            vv=1-math.clamp((i.Position.Y-ab.Y)/sz.Y,0,1)
            updateUI()
        end
    end)

    local hueDrag=false
    hueHitbox.MouseButton1Down:Connect(function(x,y)
        hueDrag=true
        local ab=hueFrame.AbsolutePosition; local sz=hueFrame.AbsoluteSize
        hv=math.clamp((y-ab.Y)/sz.Y,0,1)
        updateUI()
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then hueDrag=false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if hueDrag and i.UserInputType==Enum.UserInputType.MouseMovement then
            local ab=hueFrame.AbsolutePosition; local sz=hueFrame.AbsoluteSize
            hv=math.clamp((i.Position.Y-ab.Y)/sz.Y,0,1)
            updateUI()
        end
    end)

    local function openPopup()
        if activeCP and activeCP~=popup and activeCP.Parent then
            activeCP.Visible=false
        end
        pickerOpen=true; popup.Visible=true; activeCP=popup
        local vp=workspace.CurrentCamera.ViewportSize
        local absPos=previewFrame.AbsolutePosition
        local sx=math.clamp(absPos.X-PW-4, 4, vp.X-PW-4)
        local sy=math.clamp(absPos.Y-PH/2, 4, vp.Y-PH-4)
        popup.Position=UDim2.new(0,sx,0,sy)
    end

    local function closePopup()
        pickerOpen=false; popup.Visible=false
        if activeCP==popup then activeCP=nil end
    end

    previewBtn.MouseButton1Click:Connect(function()
        if pickerOpen then closePopup() else openPopup() end
    end)
    closeCP.MouseButton1Click:Connect(closePopup)

    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 and pickerOpen then
            local mp=input.Position
            if not popup or not popup.Parent then return end
            local pp=popup.AbsolutePosition; local ps=popup.AbsoluteSize
            local inside=mp.X>=pp.X and mp.X<=pp.X+ps.X and mp.Y>=pp.Y and mp.Y<=pp.Y+ps.Y
            local vp2=previewFrame.AbsolutePosition; local vs=previewFrame.AbsoluteSize
            local onPrev=mp.X>=vp2.X and mp.X<=vp2.X+vs.X and mp.Y>=vp2.Y and mp.Y<=vp2.Y+vs.Y
            if not inside and not onPrev then closePopup() end
        end
    end)

    local ctrl={}
    function ctrl:GetColor() return currentColor end
    function ctrl:SetColor(c)
        currentColor=c; hv,sv,vv=RGBtoHSV(c.R,c.G,c.B); updateUI()
    end
    return ctrl
end

-- ================================================================
-- ПОСТРОИТЕЛЬ ВКЛАДОК
-- ================================================================
local allTabs={}

local function makeTab(name)
    local tabBtn  = Instance.new("TextButton")
    local tabPage = Instance.new("ScrollingFrame")
    local leftCol  = Instance.new("Frame")
    local rightCol = Instance.new("Frame")

    tabBtn.Parent             = TabHolder
    tabBtn.BackgroundTransparency=1
    tabBtn.Size               = UDim2.new(0,80,1,0)
    tabBtn.Font               = Enum.Font.Code
    tabBtn.Text               = name:upper()
    tabBtn.TextColor3         = Color3.fromRGB(60,60,60)
    tabBtn.TextSize           = 10
    tabBtn.BorderSizePixel    = 0

    tabPage.Parent            = ContentHolder
    tabPage.BackgroundTransparency=1
    tabPage.BorderSizePixel   = 0
    tabPage.Size              = UDim2.new(1,0,1,0)
    tabPage.CanvasSize        = UDim2.new(0,0,0,0)
    tabPage.ScrollBarThickness= 2
    tabPage.ScrollBarImageColor3=Color3.fromRGB(50,50,50)
    tabPage.ScrollingDirection = Enum.ScrollingDirection.Y
    tabPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabPage.Visible           = false

    leftCol.Parent            = tabPage
    leftCol.BackgroundTransparency=1
    leftCol.Position          = UDim2.new(0,8,0,8)
    leftCol.Size              = UDim2.new(0.5,-12,0,0)
    leftCol.AutomaticSize     = Enum.AutomaticSize.Y
    local ll=Instance.new("UIListLayout"); ll.SortOrder=Enum.SortOrder.LayoutOrder
    ll.Padding=UDim.new(0,8); ll.Parent=leftCol

    rightCol.Parent           = tabPage
    rightCol.BackgroundTransparency=1
    rightCol.Position         = UDim2.new(0.5,4,0,8)
    rightCol.Size             = UDim2.new(0.5,-12,0,0)
    rightCol.AutomaticSize    = Enum.AutomaticSize.Y
    local rl=Instance.new("UIListLayout"); rl.SortOrder=Enum.SortOrder.LayoutOrder
    rl.Padding=UDim.new(0,8); rl.Parent=rightCol

    tabBtn.MouseButton1Click:Connect(function()
        for _,t in pairs(allTabs) do
            t.page.Visible=false
            t.btn.TextColor3=Color3.fromRGB(60,60,60)
            t.btn.BorderSizePixel=0
        end
        tabPage.Visible=true
        tabBtn.TextColor3=Color3.fromRGB(220,220,220)
        tabBtn.BorderSizePixel=1
        tabBtn.BorderColor3=Color3.fromRGB(80,80,80)
    end)

    local tabObj={btn=tabBtn,page=tabPage,left=leftCol,right=rightCol}
    table.insert(allTabs,tabObj)
    if #allTabs==1 then
        tabPage.Visible=true
        tabBtn.TextColor3=Color3.fromRGB(220,220,220)
    end

    local tabAPI={}

    function tabAPI:Section(sName,side)
        local col=side=="Right" and rightCol or leftCol

        local frame=Instance.new("Frame")
        frame.Parent=col; frame.BorderSizePixel=1
        frame.Size=UDim2.new(1,0,0,28)
        frame.AutomaticSize=Enum.AutomaticSize.Y
        frame.ClipsDescendants=false
        onTheme("SectionBG",     function(c) frame.BackgroundColor3=c end)
        onTheme("SectionBorder", function(c) frame.BorderColor3=c end)

        local titleLbl=Instance.new("TextLabel")
        titleLbl.Parent=frame; titleLbl.BorderSizePixel=1
        titleLbl.Size=UDim2.new(1,0,0,18); titleLbl.Font=Enum.Font.Code
        titleLbl.Text="// "..sName:upper(); titleLbl.TextColor3=Color3.fromRGB(70,70,70)
        titleLbl.TextSize=9; titleLbl.TextXAlignment=Enum.TextXAlignment.Left
        titleLbl.BackgroundColor3=Color3.fromRGB(14,14,14)
        titleLbl.BorderColor3=Color3.fromRGB(25,25,25)
        do local p=Instance.new("UIPadding"); p.PaddingLeft=UDim.new(0,8); p.Parent=titleLbl end

        local body=Instance.new("Frame")
        body.Parent=frame; body.BackgroundTransparency=1
        body.Position=UDim2.new(0,0,0,18)
        body.Size=UDim2.new(1,0,0,0)
        body.AutomaticSize=Enum.AutomaticSize.Y

        local bodyLayout=Instance.new("UIListLayout")
        bodyLayout.Parent=body; bodyLayout.SortOrder=Enum.SortOrder.LayoutOrder
        bodyLayout.Padding=UDim.new(0,2)

        local bodyPad=Instance.new("UIPadding")
        bodyPad.Parent=body; bodyPad.PaddingLeft=UDim.new(0,8)
        bodyPad.PaddingRight=UDim.new(0,8); bodyPad.PaddingTop=UDim.new(0,5)
        bodyPad.PaddingBottom=UDim.new(0,5)

        local sec={}

        function sec:Toggle(id,tName,default,cb)
            local row=Instance.new("Frame"); row.Parent=body
            row.BackgroundTransparency=1; row.Size=UDim2.new(1,0,0,18)

            local lbl=Instance.new("TextLabel"); lbl.Parent=row
            lbl.BackgroundTransparency=1; lbl.Size=UDim2.new(0.7,0,1,0)
            lbl.Font=Enum.Font.Code; lbl.Text=tName
            lbl.TextSize=11; lbl.TextXAlignment=Enum.TextXAlignment.Left

            local tf=Instance.new("Frame"); tf.Parent=row
            tf.BorderColor3=Color3.fromRGB(40,40,40); tf.BorderSizePixel=1
            tf.Position=UDim2.new(1,-28,0.5,-7); tf.Size=UDim2.new(0,28,0,14)
            onTheme("ToggleBG", function(c) tf.BackgroundColor3=c end)

            local ti=Instance.new("Frame"); ti.Parent=tf
            ti.BorderSizePixel=0
            ti.Size=UDim2.new(0,10,0,10); ti.Position=UDim2.new(0,1,0.5,-5)

            local tb=Instance.new("TextButton"); tb.Parent=tf
            tb.BackgroundTransparency=1; tb.BorderSizePixel=0
            tb.Size=UDim2.new(1,0,1,0); tb.Text=""

            local state=default or false
            local function refresh()
                if state then
                    TweenService:Create(ti,TweenInfo.new(0.1),
                        {Position=UDim2.new(0,15,0.5,-5),BackgroundColor3=Theme.Accent}):Play()
                    lbl.TextColor3=Theme.LabelOn
                else
                    TweenService:Create(ti,TweenInfo.new(0.1),
                        {Position=UDim2.new(0,1,0.5,-5),BackgroundColor3=Theme.ToggleOff}):Play()
                    lbl.TextColor3=Theme.LabelText
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
            reg(id,"toggle",function() return state end,function(val)
                state=(val=="true" or val==true); refresh(); if cb then cb(state) end
            end)
        end

        function sec:Slider(id,sName,mn,mx,default,suffix,cb)
            local wrap=Instance.new("Frame"); wrap.Parent=body
            wrap.BackgroundTransparency=1; wrap.Size=UDim2.new(1,0,0,28)
            suffix=suffix or ""
            local curVal=default or mn

            local lbl=Instance.new("TextLabel"); lbl.Parent=wrap
            lbl.BackgroundTransparency=1; lbl.Size=UDim2.new(0.6,0,0,14)
            lbl.Font=Enum.Font.Code; lbl.Text=sName
            lbl.TextSize=11; lbl.TextXAlignment=Enum.TextXAlignment.Left
            onTheme("LabelText",function(c) lbl.TextColor3=c end)

            local valLbl=Instance.new("TextLabel"); valLbl.Parent=wrap
            valLbl.BackgroundTransparency=1; valLbl.Position=UDim2.new(0.6,0,0,0)
            valLbl.Size=UDim2.new(0.4,0,0,14); valLbl.Font=Enum.Font.Code
            valLbl.Text=tostring(curVal)..suffix
            valLbl.TextColor3=Color3.fromRGB(100,100,100)
            valLbl.TextSize=10; valLbl.TextXAlignment=Enum.TextXAlignment.Right

            local track=Instance.new("Frame"); track.Parent=wrap
            track.BorderColor3=Color3.fromRGB(30,30,30); track.BorderSizePixel=1
            track.Position=UDim2.new(0,0,0,17); track.Size=UDim2.new(1,0,0,6)
            onTheme("SliderTrack",function(c) track.BackgroundColor3=c end)

            local fill=Instance.new("Frame"); fill.Parent=track
            fill.BorderSizePixel=0
            fill.Size=UDim2.new((curVal-mn)/(mx-mn),0,1,0)
            onTheme("Accent",function(c) fill.BackgroundColor3=c end)

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

            reg(id,"slider",function() return curVal end,function(val)
                setVal(math.clamp(math.floor(tonumber(val) or mn),mn,mx))
            end)
        end

        function sec:Button(bName,cb)
            local btn=Instance.new("TextButton"); btn.Parent=body
            btn.BorderSizePixel=1; btn.Size=UDim2.new(1,0,0,18)
            btn.Font=Enum.Font.Code; btn.Text=bName:upper(); btn.TextSize=10
            onTheme("ButtonBG",     function(c) btn.BackgroundColor3=c end)
            onTheme("ButtonBorder", function(c) btn.BorderColor3=c end)
            onTheme("ButtonText",   function(c) btn.TextColor3=c end)
            btn.MouseEnter:Connect(function()
                btn.TextColor3=Color3.fromRGB(220,220,220)
                btn.BorderColor3=Color3.fromRGB(80,80,80)
            end)
            btn.MouseLeave:Connect(function()
                btn.TextColor3=Theme.ButtonText
                btn.BorderColor3=Theme.ButtonBorder
            end)
            btn.MouseButton1Click:Connect(function() if cb then cb() end end)
        end

        function sec:Dropdown(id,dName,options,cb)
            local wrap=Instance.new("Frame"); wrap.Parent=body
            wrap.BackgroundTransparency=1; wrap.Size=UDim2.new(1,0,0,18)
            wrap.ClipsDescendants=false; wrap.ZIndex=5
            local selected=options[1] or ""

            local lbl=Instance.new("TextLabel"); lbl.Parent=wrap
            lbl.BackgroundTransparency=1; lbl.Size=UDim2.new(0.5,0,1,0)
            lbl.Font=Enum.Font.Code; lbl.Text=dName
            lbl.TextSize=11; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=5
            onTheme("LabelText",function(c) lbl.TextColor3=c end)

            local box=Instance.new("TextButton"); box.Parent=wrap
            box.BorderSizePixel=1; box.Position=UDim2.new(0.5,0,0,0)
            box.Size=UDim2.new(0.5,0,1,0); box.Font=Enum.Font.Code; box.Text=""; box.ZIndex=5
            onTheme("ButtonBG",     function(c) box.BackgroundColor3=c end)
            onTheme("ButtonBorder", function(c) box.BorderColor3=c end)

            local boxLbl=Instance.new("TextLabel"); boxLbl.Parent=box
            boxLbl.BackgroundTransparency=1; boxLbl.Size=UDim2.new(1,-6,1,0)
            boxLbl.Position=UDim2.new(0,4,0,0); boxLbl.Font=Enum.Font.Code
            boxLbl.Text=selected; boxLbl.TextColor3=Color3.fromRGB(160,160,160)
            boxLbl.TextSize=10; boxLbl.TextXAlignment=Enum.TextXAlignment.Left; boxLbl.ZIndex=5

            local optHolder=Instance.new("Frame"); optHolder.Parent=ScreenGui
            optHolder.BackgroundColor3=Color3.fromRGB(12,12,12)
            optHolder.BorderColor3=Color3.fromRGB(45,45,45); optHolder.BorderSizePixel=1
            optHolder.Size=UDim2.new(0,80,0,#options*18)
            optHolder.Visible=false; optHolder.ZIndex=200
            local ol=Instance.new("UIListLayout"); ol.SortOrder=Enum.SortOrder.LayoutOrder; ol.Parent=optHolder

            local function updateOptPos()
                local abs=box.AbsolutePosition; local sz=box.AbsoluteSize
                optHolder.Position=UDim2.new(0,abs.X,0,abs.Y+sz.Y)
                optHolder.Size=UDim2.new(0,sz.X,0,#optHolder:GetChildren()*18)
            end

            local function buildOpts(opts)
                for _,c2 in ipairs(optHolder:GetChildren()) do
                    if c2:IsA("TextButton") then c2:Destroy() end
                end
                for _,opt in ipairs(opts) do
                    local ob=Instance.new("TextButton"); ob.Parent=optHolder
                    ob.BackgroundTransparency=1; ob.BorderSizePixel=0
                    ob.Size=UDim2.new(1,0,0,18); ob.Font=Enum.Font.Code
                    ob.Text=opt; ob.TextColor3=Color3.fromRGB(120,120,120)
                    ob.TextSize=10; ob.ZIndex=200
                    ob.MouseEnter:Connect(function() ob.TextColor3=Color3.fromRGB(220,220,220) end)
                    ob.MouseLeave:Connect(function() ob.TextColor3=Color3.fromRGB(120,120,120) end)
                    ob.MouseButton1Click:Connect(function()
                        selected=opt; boxLbl.Text=opt; optHolder.Visible=false
                        if cb then cb(opt) end
                    end)
                end
                if #opts>0 then selected=opts[1]; boxLbl.Text=opts[1] end
                optHolder.Size=UDim2.new(0,100,0,#opts*18)
            end
            buildOpts(options)

            box.MouseButton1Click:Connect(function()
                updateOptPos()
                optHolder.Visible=not optHolder.Visible
            end)

            UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType==Enum.UserInputType.MouseButton1 and optHolder.Visible then
                    local mp=input.Position
                    local op=optHolder.AbsolutePosition; local os=optHolder.AbsoluteSize
                    local inside=mp.X>=op.X and mp.X<=op.X+os.X and mp.Y>=op.Y and mp.Y<=op.Y+os.Y
                    if not inside then optHolder.Visible=false end
                end
            end)

            reg(id,"dropdown",function() return selected end,function(val)
                selected=val; boxLbl.Text=val; if cb then cb(val) end
            end)

            local ctrl={}
            function ctrl:SetOptions(opts) buildOpts(opts) end
            function ctrl:GetSelected() return selected end
            return ctrl
        end

        function sec:Textbox(id,tName,placeholder,cb)
            local wrap=Instance.new("Frame"); wrap.Parent=body
            wrap.BackgroundTransparency=1; wrap.Size=UDim2.new(1,0,0,28)

            local lbl=Instance.new("TextLabel"); lbl.Parent=wrap
            lbl.BackgroundTransparency=1; lbl.Size=UDim2.new(1,0,0,12)
            lbl.Font=Enum.Font.Code; lbl.Text=tName
            lbl.TextColor3=Color3.fromRGB(100,100,100)
            lbl.TextSize=10; lbl.TextXAlignment=Enum.TextXAlignment.Left

            local box=Instance.new("TextBox"); box.Parent=wrap
            box.BackgroundColor3=Color3.fromRGB(10,10,10)
            box.BorderColor3=Color3.fromRGB(35,35,35); box.BorderSizePixel=1
            box.Position=UDim2.new(0,0,0,13); box.Size=UDim2.new(1,0,0,14)
            box.Font=Enum.Font.Code; box.PlaceholderText=placeholder or ""
            box.PlaceholderColor3=Color3.fromRGB(55,55,55); box.Text=""
            box.TextColor3=Color3.fromRGB(180,180,180); box.TextSize=10
            box.TextXAlignment=Enum.TextXAlignment.Left; box.ClearTextOnFocus=false
            do local p=Instance.new("UIPadding"); p.PaddingLeft=UDim.new(0,4); p.Parent=box end

            box:GetPropertyChangedSignal("Text"):Connect(function()
                if cb then cb(box.Text) end
            end)
            reg(id,"textbox",function() return box.Text end,function(val)
                box.Text=tostring(val); if cb then cb(box.Text) end
            end)
        end

        function sec:Keybind(id,kName,default,cb)
            local row=Instance.new("Frame"); row.Parent=body
            row.BackgroundTransparency=1; row.Size=UDim2.new(1,0,0,18)
            local boundKey=default; local waiting=false

            local lbl=Instance.new("TextLabel"); lbl.Parent=row
            lbl.BackgroundTransparency=1; lbl.Size=UDim2.new(0.65,0,1,0)
            lbl.Font=Enum.Font.Code; lbl.Text=kName
            lbl.TextSize=11; lbl.TextXAlignment=Enum.TextXAlignment.Left
            onTheme("LabelText",function(c) lbl.TextColor3=c end)

            local kb=Instance.new("TextButton"); kb.Parent=row
            kb.BorderSizePixel=1; kb.Position=UDim2.new(0.65,0,0.5,-8)
            kb.Size=UDim2.new(0.35,0,0,16); kb.Font=Enum.Font.Code
            kb.Text=default and tostring(default):gsub("Enum.KeyCode.","") or "--"
            kb.TextColor3=Color3.fromRGB(100,100,100); kb.TextSize=9
            onTheme("ButtonBG",     function(c) kb.BackgroundColor3=c end)
            onTheme("ButtonBorder", function(c) kb.BorderColor3=c end)

            kb.MouseButton1Click:Connect(function()
                waiting=true; kb.Text="..."; kb.TextColor3=Color3.fromRGB(200,200,200)
            end)
            UserInputService.InputBegan:Connect(function(input,gpe2)
                if waiting and not gpe2 and input.KeyCode~=Enum.KeyCode.Unknown then
                    waiting=false; boundKey=input.KeyCode
                    kb.Text=tostring(input.KeyCode):gsub("Enum.KeyCode.","")
                    kb.TextColor3=Color3.fromRGB(100,100,100)
                    if cb then cb(input.KeyCode) end
                end
            end)
            reg(id,"keybind",
                function() return boundKey and tostring(boundKey):gsub("Enum.KeyCode.","") or "--" end,
                function(val)
                    local keyStr=tostring(val); kb.Text=keyStr
                    local ok,kc=pcall(function() return Enum.KeyCode[keyStr] end)
                    if ok and kc then boundKey=kc; if cb then cb(kc) end end
                end)
        end

        function sec:ColorPicker(id,cpName,default,cb)
            local row=Instance.new("Frame"); row.Parent=body
            row.BackgroundTransparency=1; row.Size=UDim2.new(1,0,0,18)

            local lbl=Instance.new("TextLabel"); lbl.Parent=row
            lbl.BackgroundTransparency=1; lbl.Size=UDim2.new(0.75,0,1,0)
            lbl.Font=Enum.Font.Code; lbl.Text=cpName
            lbl.TextSize=11; lbl.TextXAlignment=Enum.TextXAlignment.Left
            onTheme("LabelText",function(c) lbl.TextColor3=c end)

            local cpCtrl=makeColorPicker(row,default,cb)
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
                end)
            return cpCtrl
        end

        function sec:Divider()
            local div=Instance.new("Frame"); div.Parent=body
            div.BackgroundColor3=Color3.fromRGB(22,22,22)
            div.BorderSizePixel=0; div.Size=UDim2.new(1,0,0,1)
        end

        return sec
    end

    return tabAPI
end

-- ================================================================
-- СОЗДАНИЕ ВКЛАДОК
-- ================================================================
local combatTab = makeTab("Combat")
local visualTab = makeTab("Visual")
local cosmTab   = makeTab("Cosmetics")
local moveTab   = makeTab("Movement")
local miscTab   = makeTab("Misc")
local setTab    = makeTab("Settings")

-- ================================================================
-- COMBAT — пустая вкладка (добавляй свои функции сюда)
-- ================================================================
-- local aimSec = combatTab:Section("Aimbot", "Left")
-- aimSec:Toggle("aimbot_on", "Aimbot", false, function(v) end)
-- ...

-- ================================================================
-- VISUAL — пустая вкладка
-- ================================================================

-- ================================================================
-- COSMETICS — пустая вкладка
-- ================================================================

-- ================================================================
-- MOVEMENT — пустая вкладка
-- ================================================================

-- ================================================================
-- MISC — пустая вкладка
-- ================================================================

-- ================================================================
-- SETTINGS
-- ================================================================
local bindSec  = setTab:Section("Keybinds", "Left")
local themeSec = setTab:Section("Theme",    "Left")
local cfgSec   = setTab:Section("Configs",  "Right")

bindSec:Keybind("menu_bind","Toggle Menu",Enum.KeyCode.RightShift,function(key)
    menuBind=key
end)

themeSec:ColorPicker("theme_accent",      "Accent / Neon",    Color3.fromRGB(255,255,255), function(c) Theme.Accent=c        end)
themeSec:ColorPicker("theme_window_bg",   "Window BG",        Color3.fromRGB(8,8,8),       function(c) Theme.WindowBG=c      end)
themeSec:ColorPicker("theme_title_bg",    "Title BG",         Color3.fromRGB(12,12,12),    function(c) Theme.TitleBG=c       end)
themeSec:ColorPicker("theme_section_bg",  "Section BG",       Color3.fromRGB(12,12,12),    function(c) Theme.SectionBG=c     end)
themeSec:ColorPicker("theme_section_brd", "Section Border",   Color3.fromRGB(30,30,30),    function(c) Theme.SectionBorder=c end)
themeSec:ColorPicker("theme_btn_bg",      "Button BG",        Color3.fromRGB(14,14,14),    function(c) Theme.ButtonBG=c      end)
themeSec:ColorPicker("theme_btn_border",  "Button Border",    Color3.fromRGB(35,35,35),    function(c) Theme.ButtonBorder=c  end)
themeSec:ColorPicker("theme_btn_text",    "Button Text",      Color3.fromRGB(120,120,120), function(c) Theme.ButtonText=c    end)
themeSec:ColorPicker("theme_label",       "Label Text",       Color3.fromRGB(140,140,140), function(c) Theme.LabelText=c     end)
themeSec:ColorPicker("theme_label_on",    "Label On",         Color3.fromRGB(220,220,220), function(c) Theme.LabelOn=c       end)
themeSec:ColorPicker("theme_slider",      "Slider Track",     Color3.fromRGB(18,18,18),    function(c) Theme.SliderTrack=c   end)
themeSec:ColorPicker("theme_toggle_bg",   "Toggle BG",        Color3.fromRGB(18,18,18),    function(c) Theme.ToggleBG=c      end)
themeSec:ColorPicker("theme_toggle_off",  "Toggle Off",       Color3.fromRGB(35,35,35),    function(c) Theme.ToggleOff=c     end)
themeSec:ColorPicker("theme_status",      "Status Text",      Color3.fromRGB(45,45,45),    function(c) Theme.StatusText=c    end)
themeSec:ColorPicker("theme_watermark",   "Watermark BG",     Color3.fromRGB(8,8,8),       function(c) Theme.WatermarkBG=c   end)
themeSec:Toggle("show_watermark","Show Watermark",true,function(v)
    Watermark.Visible=v
end)

-- ================================================================
-- КОНФИГИ — ПЕРСОНАЛЬНАЯ ПАПКА ДЛЯ КАЖДОГО ИГРОКА ПО UserId
-- Структура: ScriptHub / <UserId> / <name>.cfg
-- Каждый игрок видит ТОЛЬКО свои конфиги — никакой путаницы
-- ================================================================

-- Корневая папка хаба
local ROOT_FOLDER = "ScriptHub"
if not isfolder(ROOT_FOLDER) then makefolder(ROOT_FOLDER) end

-- Персональная папка: ScriptHub/<UserId>
local USER_FOLDER = ROOT_FOLDER .. "/" .. tostring(LocalPlayer.UserId)
if not isfolder(USER_FOLDER) then makefolder(USER_FOLDER) end

local currentCfgName = ""
local cfgDropHandle  = nil

-- Список конфигов ТОЛЬКО этого игрока
local function getCfgList()
    local list = {}
    if isfolder(USER_FOLDER) then
        for _, f in ipairs(listfiles(USER_FOLDER)) do
            local fname = f:match("([^/\\]+)$") or f
            if fname:sub(-4) == ".cfg" then
                table.insert(list, fname:sub(1, -5))
            end
        end
    end
    return list
end

local function refreshDrop()
    if cfgDropHandle then
        local lst = getCfgList()
        if #lst == 0 then lst = {"-- empty --"} end
        cfgDropHandle:SetOptions(lst)
    end
end

local function saveConfig(name)
    if not name or name == "" or name == "-- empty --" then return end
    local lines = {}
    for id, entry in pairs(registry) do
        if id ~= "cfg_name" then
            local ok, val = pcall(entry.get)
            if ok and val ~= nil then
                table.insert(lines, id .. "=" .. tostring(val))
            end
        end
    end
    table.sort(lines)
    writefile(USER_FOLDER .. "/" .. name .. ".cfg", table.concat(lines, "\n"))
end

local function loadConfig(name)
    if not name or name == "" or name == "-- empty --" then return end
    local path = USER_FOLDER .. "/" .. name .. ".cfg"
    if not isfile(path) then return end
    local content = readfile(path)
    for line in content:gmatch("[^\n\r]+") do
        local id, val = line:match("^(.-)=(.+)$")
        if id and val and registry[id] then
            pcall(registry[id].set, val)
        end
    end
end

local function deleteConfig(name)
    if not name or name == "" or name == "-- empty --" then return end
    local path = USER_FOLDER .. "/" .. name .. ".cfg"
    if isfile(path) then delfile(path) end
end

cfgSec:Textbox("cfg_name", "Config Name", "myconfig", function(v)
    currentCfgName = v
end)

cfgDropHandle = cfgSec:Dropdown("cfg_select", "Select Config",
    (function()
        local l = getCfgList()
        return #l > 0 and l or {"-- empty --"}
    end)(),
    function(v)
        if v ~= "-- empty --" then
            currentCfgName = v
            if registry["cfg_name"] then
                pcall(registry["cfg_name"].set, v)
            end
        end
    end
)

cfgSec:Button("Save Config", function()
    if currentCfgName == "" or currentCfgName == "-- empty --" then return end
    saveConfig(currentCfgName)
    refreshDrop()
end)

cfgSec:Button("Load Config", function()
    if currentCfgName == "" or currentCfgName == "-- empty --" then return end
    loadConfig(currentCfgName)
end)

cfgSec:Button("Delete Config", function()
    if currentCfgName == "" or currentCfgName == "-- empty --" then return end
    deleteConfig(currentCfgName)
    currentCfgName = ""
    if registry["cfg_name"] then pcall(registry["cfg_name"].set, "") end
    refreshDrop()
end)

task.defer(refreshDrop)

-- ================================================================
-- ЗАПУСК
-- ================================================================
animateLoader(function()
    MainFrame.Visible = true
end)
