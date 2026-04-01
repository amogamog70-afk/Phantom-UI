-- ScriptHub Library v2.0
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
-- РЕЕСТР ЗНАЧЕНИЙ (система конфигов LinoriaLib-стиль)
-- ================================================================
-- registry[id] = { type="toggle"|"slider"|"dropdown"|"textbox"|"keybind"|"color",
--                   get=fn, set=fn }
local registry = {}
local function reg(id, rtype, getter, setter)
    if id and id ~= "" then
        registry[id] = { type = rtype, get = getter, set = setter }
    end
end

-- ================================================================
-- ЗАГРУЗОЧНЫЙ ЭКРАН
-- ================================================================
local LoadGui = Instance.new("ScreenGui")
LoadGui.Name = "ScriptHubLoader"
LoadGui.IgnoreGuiInset = true
if syn and syn.protect_gui then syn.protect_gui(LoadGui) end
LoadGui.Parent = game:GetService("CoreGui")

local LoadBG = Instance.new("Frame")
LoadBG.Size = UDim2.new(1,0,1,0)
LoadBG.BackgroundColor3 = Color3.fromRGB(5,5,5)
LoadBG.BorderSizePixel = 0
LoadBG.Parent = LoadGui

local LoadBox = Instance.new("Frame")
LoadBox.Size = UDim2.new(0,340,0,160)
LoadBox.Position = UDim2.new(0.5,-170,0.5,-80)
LoadBox.BackgroundColor3 = Color3.fromRGB(8,8,8)
LoadBox.BorderSizePixel = 0
LoadBox.Parent = LoadBG

do
    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(255,255,255); s.Thickness = 1.5
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.Parent = LoadBox
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,4); c.Parent = LoadBox
end

local LoadTitle = Instance.new("TextLabel")
LoadTitle.Size = UDim2.new(1,0,0,40); LoadTitle.Position = UDim2.new(0,0,0,18)
LoadTitle.BackgroundTransparency = 1; LoadTitle.Font = Enum.Font.Code
LoadTitle.Text = ":: SCRIPT HUB ::"; LoadTitle.TextColor3 = Color3.fromRGB(255,255,255)
LoadTitle.TextSize = 18; LoadTitle.Parent = LoadBox

local LoadSub = Instance.new("TextLabel")
LoadSub.Size = UDim2.new(1,0,0,16); LoadSub.Position = UDim2.new(0,0,0,58)
LoadSub.BackgroundTransparency = 1; LoadSub.Font = Enum.Font.Code
LoadSub.Text = "v2.0"; LoadSub.TextColor3 = Color3.fromRGB(60,60,60)
LoadSub.TextSize = 11; LoadSub.Parent = LoadBox

local BarBG = Instance.new("Frame")
BarBG.Size = UDim2.new(0,280,0,4); BarBG.Position = UDim2.new(0.5,-140,0,98)
BarBG.BackgroundColor3 = Color3.fromRGB(18,18,18); BarBG.BorderSizePixel = 0; BarBG.Parent = LoadBox
do
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1,0); c.Parent = BarBG
end

local BarFill = Instance.new("Frame")
BarFill.Size = UDim2.new(0,0,1,0); BarFill.BackgroundColor3 = Color3.fromRGB(255,255,255)
BarFill.BorderSizePixel = 0; BarFill.Parent = BarBG
do
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1,0); c.Parent = BarFill
end

local LoadStatus = Instance.new("TextLabel")
LoadStatus.Size = UDim2.new(1,-20,0,14); LoadStatus.Position = UDim2.new(0,10,0,112)
LoadStatus.BackgroundTransparency = 1; LoadStatus.Font = Enum.Font.Code
LoadStatus.Text = "Initializing..."; LoadStatus.TextColor3 = Color3.fromRGB(55,55,55)
LoadStatus.TextSize = 10; LoadStatus.TextXAlignment = Enum.TextXAlignment.Left
LoadStatus.Parent = LoadBox

local loadSteps = {
    {text = "Loading core...",    pct = 0.15},
    {text = "Loading UI...",      pct = 0.40},
    {text = "Loading modules...", pct = 0.65},
    {text = "Loading configs...", pct = 0.85},
    {text = "Done!",              pct = 1.00},
}

local function animateLoader(onDone)
    local i = 0
    local function step()
        i = i + 1
        if i > #loadSteps then
            task.wait(0.3)
            TweenService:Create(LoadBG,  TweenInfo.new(0.5), {BackgroundTransparency=1}):Play()
            TweenService:Create(LoadBox, TweenInfo.new(0.5), {BackgroundTransparency=1}):Play()
            task.wait(0.55)
            LoadGui:Destroy()
            if onDone then onDone() end
            return
        end
        local st = loadSteps[i]
        LoadStatus.Text = st.text
        TweenService:Create(BarFill, TweenInfo.new(0.3, Enum.EasingStyle.Quad),
            {Size = UDim2.new(st.pct,0,1,0)}):Play()
        task.wait(0.3)
        step()
    end
    task.spawn(step)
end

-- ================================================================
-- ТЕМА
-- ================================================================
local Theme = {
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

-- ================================================================
-- GUI ROOT
-- ================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ScriptHub"; ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false
if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end
ScreenGui.Parent = game:GetService("CoreGui")

-- WATERMARK
local Watermark = Instance.new("Frame")
Watermark.BackgroundColor3 = Theme.WatermarkBG; Watermark.BorderSizePixel = 0
Watermark.Position = UDim2.new(0,8,0,8); Watermark.Size = UDim2.new(0,280,0,22)
Watermark.Parent = ScreenGui

local WMStroke = Instance.new("UIStroke")
WMStroke.Color = Theme.Accent; WMStroke.Thickness = 1.5
WMStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; WMStroke.Parent = Watermark
do local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,2); c.Parent=Watermark end

local WMLabel = Instance.new("TextLabel")
WMLabel.BackgroundTransparency=1; WMLabel.Size=UDim2.new(1,0,1,0)
WMLabel.Font=Enum.Font.Code; WMLabel.TextColor3=Color3.fromRGB(180,180,180)
WMLabel.TextSize=11; WMLabel.TextXAlignment=Enum.TextXAlignment.Left; WMLabel.Parent=Watermark
do local p=Instance.new("UIPadding"); p.PaddingLeft=UDim.new(0,8); p.Parent=WMLabel end

local fps2,frameCount2,lastTime2 = 60,0,tick()
RunService.RenderStepped:Connect(function()
    frameCount2=frameCount2+1
    local now=tick()
    if now-lastTime2>=1 then fps2=frameCount2; frameCount2=0; lastTime2=now end
    local ping=math.floor(LocalPlayer:GetNetworkPing()*1000)
    WMLabel.Text=LocalPlayer.Name.."  |  FPS: "..fps2.."  |  PING: "..ping.."ms"
end)

-- MAIN FRAME
local MainFrame = Instance.new("Frame")
MainFrame.BackgroundColor3=Theme.WindowBG; MainFrame.BorderSizePixel=0
MainFrame.Position=UDim2.new(0.5,-290,0.5,-200); MainFrame.Size=UDim2.new(0,580,0,420)
MainFrame.ClipsDescendants=true; MainFrame.Visible=false; MainFrame.Parent=ScreenGui

local MainStroke = Instance.new("UIStroke")
MainStroke.Color=Theme.Accent; MainStroke.Thickness=1.5
MainStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; MainStroke.Parent=MainFrame
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
            local d=input.Position-dragStart
            MainFrame.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,
                                          startPos.Y.Scale,startPos.Y.Offset+d.Y)
        end
    end)
end

-- TITLE BAR
local TitleBar = Instance.new("Frame")
TitleBar.BackgroundColor3=Theme.TitleBG; TitleBar.BorderColor3=Color3.fromRGB(30,30,30)
TitleBar.BorderSizePixel=1; TitleBar.Size=UDim2.new(1,0,0,28); TitleBar.Parent=MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.BackgroundTransparency=1; TitleLabel.Size=UDim2.new(1,-40,1,0)
TitleLabel.Position=UDim2.new(0,12,0,0); TitleLabel.Font=Enum.Font.Code
TitleLabel.Text=":: SCRIPT HUB ::"; TitleLabel.TextColor3=Color3.fromRGB(100,100,100)
TitleLabel.TextSize=11; TitleLabel.TextXAlignment=Enum.TextXAlignment.Left; TitleLabel.Parent=TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.BackgroundTransparency=1; CloseBtn.Position=UDim2.new(1,-24,0,6)
CloseBtn.Size=UDim2.new(0,16,0,16); CloseBtn.Font=Enum.Font.Code; CloseBtn.Text="×"
CloseBtn.TextColor3=Color3.fromRGB(80,80,80); CloseBtn.TextSize=14; CloseBtn.Parent=TitleBar
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible=false end)

-- TAB HOLDER
local TabHolder = Instance.new("Frame")
TabHolder.BackgroundColor3=Color3.fromRGB(10,10,10); TabHolder.BorderColor3=Color3.fromRGB(25,25,25)
TabHolder.BorderSizePixel=1; TabHolder.Position=UDim2.new(0,0,0,28)
TabHolder.Size=UDim2.new(1,0,0,24); TabHolder.Parent=MainFrame
local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection=Enum.FillDirection.Horizontal
TabLayout.SortOrder=Enum.SortOrder.LayoutOrder; TabLayout.Parent=TabHolder

-- CONTENT HOLDER
local ContentHolder = Instance.new("Frame")
ContentHolder.BackgroundTransparency=1; ContentHolder.Position=UDim2.new(0,0,0,52)
ContentHolder.Size=UDim2.new(1,0,1,-72); ContentHolder.Parent=MainFrame

-- STATUS BAR
local StatusBar = Instance.new("Frame")
StatusBar.BackgroundColor3=Color3.fromRGB(8,8,8); StatusBar.BorderColor3=Color3.fromRGB(25,25,25)
StatusBar.BorderSizePixel=1; StatusBar.Position=UDim2.new(0,0,1,-20)
StatusBar.Size=UDim2.new(1,0,0,20); StatusBar.Parent=MainFrame
local StatusLabel = Instance.new("TextLabel")
StatusLabel.BackgroundTransparency=1; StatusLabel.Size=UDim2.new(1,-10,1,0)
StatusLabel.Position=UDim2.new(0,8,0,0); StatusLabel.Font=Enum.Font.Code
StatusLabel.Text=":: SCRIPT HUB v2.0   |   RSHIFT — TOGGLE"; StatusLabel.TextColor3=Theme.StatusText
StatusLabel.TextSize=10; StatusLabel.TextXAlignment=Enum.TextXAlignment.Left; StatusLabel.Parent=StatusBar

local menuBind = Enum.KeyCode.RightShift
UserInputService.InputBegan:Connect(function(input,gpe)
    if not gpe and input.KeyCode==menuBind then
        MainFrame.Visible=not MainFrame.Visible
    end
end)

-- ================================================================
-- COLOR PICKER (полноценный HSV попап)
-- ================================================================
local activeCP = nil

local function makeColorPicker(parentRow, default, onChange)
    local currentColor = default or Color3.fromRGB(255,255,255)

    -- превью кнопка (справа в строке)
    local previewFrame = Instance.new("Frame")
    previewFrame.BackgroundColor3 = currentColor
    previewFrame.BorderColor3 = Color3.fromRGB(60,60,60); previewFrame.BorderSizePixel=1
    previewFrame.Position=UDim2.new(1,-20,0.5,-7); previewFrame.Size=UDim2.new(0,20,0,14)
    previewFrame.Parent=parentRow

    local previewBtn = Instance.new("TextButton")
    previewBtn.BackgroundTransparency=1; previewBtn.Size=UDim2.new(1,0,1,0)
    previewBtn.Text=""; previewBtn.ZIndex=6; previewBtn.Parent=previewFrame

    -- POPUP (крепим к ScreenGui чтобы не обрезался)
    local popup = Instance.new("Frame")
    popup.Size=UDim2.new(0,200,0,188)
    popup.BackgroundColor3=Color3.fromRGB(10,10,10)
    popup.BorderSizePixel=0; popup.Visible=false; popup.ZIndex=60
    popup.Parent=ScreenGui
    do
        local s=Instance.new("UIStroke"); s.Color=Color3.fromRGB(55,55,55)
        s.Thickness=1; s.Parent=popup
        local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,3); c.Parent=popup
    end

    -- SV AREA (Saturation/Value)
    local svFrame = Instance.new("Frame")
    svFrame.Size=UDim2.new(0,154,0,134); svFrame.Position=UDim2.new(0,8,0,8)
    svFrame.BorderSizePixel=0; svFrame.ZIndex=61; svFrame.Parent=popup

    -- белый и чёрный градиент поверх цвета
    local svColorBG = Instance.new("Frame")
    svColorBG.Size=UDim2.new(1,0,1,0); svColorBG.BorderSizePixel=0
    svColorBG.ZIndex=61; svColorBG.Parent=svFrame

    local svWhite = Instance.new("ImageLabel")
    svWhite.Size=UDim2.new(1,0,1,0); svWhite.BackgroundTransparency=1
    svWhite.Image="rbxassetid://698009843"; svWhite.ZIndex=62; svWhite.Parent=svFrame

    local svBlack = Instance.new("ImageLabel")
    svBlack.Size=UDim2.new(1,0,1,0); svBlack.BackgroundTransparency=1
    svBlack.Image="rbxassetid://698012279"; svBlack.ZIndex=63; svBlack.Parent=svFrame

    local svHitbox = Instance.new("TextButton")
    svHitbox.Size=UDim2.new(1,0,1,0); svHitbox.BackgroundTransparency=1
    svHitbox.Text=""; svHitbox.ZIndex=64; svHitbox.Parent=svFrame

    -- курсор
    local svCursor = Instance.new("Frame")
    svCursor.Size=UDim2.new(0,8,0,8); svCursor.AnchorPoint=Vector2.new(0.5,0.5)
    svCursor.BackgroundTransparency=1; svCursor.ZIndex=65; svCursor.Parent=svFrame
    local svCursorBorder = Instance.new("Frame")
    svCursorBorder.Size=UDim2.new(0,8,0,8); svCursorBorder.BackgroundTransparency=1
    svCursorBorder.BorderColor3=Color3.fromRGB(255,255,255); svCursorBorder.BorderSizePixel=1
    svCursorBorder.ZIndex=65; svCursorBorder.Parent=svCursor

    -- HUE BAR
    local hueFrame = Instance.new("ImageLabel")
    hueFrame.Size=UDim2.new(0,16,0,134); hueFrame.Position=UDim2.new(0,170,0,8)
    hueFrame.Image="rbxassetid://698010952"; hueFrame.BorderSizePixel=0
    hueFrame.ZIndex=61; hueFrame.Parent=popup

    local hueHitbox = Instance.new("TextButton")
    hueHitbox.Size=UDim2.new(1,0,1,0); hueHitbox.BackgroundTransparency=1
    hueHitbox.Text=""; hueHitbox.ZIndex=62; hueHitbox.Parent=hueFrame

    local hueCursor = Instance.new("Frame")
    hueCursor.Size=UDim2.new(1,4,0,2); hueCursor.Position=UDim2.new(0,-2,0,0)
    hueCursor.BackgroundColor3=Color3.fromRGB(255,255,255); hueCursor.BorderSizePixel=0
    hueCursor.ZIndex=63; hueCursor.Parent=hueFrame

    -- HEX BOX
    local hexBox = Instance.new("TextBox")
    hexBox.Size=UDim2.new(0,104,0,16); hexBox.Position=UDim2.new(0,8,0,150)
    hexBox.BackgroundColor3=Color3.fromRGB(14,14,14)
    hexBox.BorderColor3=Color3.fromRGB(35,35,35); hexBox.BorderSizePixel=1
    hexBox.Font=Enum.Font.Code; hexBox.Text=""
    hexBox.TextColor3=Color3.fromRGB(180,180,180); hexBox.TextSize=10
    hexBox.TextXAlignment=Enum.TextXAlignment.Left
    hexBox.ClearTextOnFocus=false; hexBox.ZIndex=61; hexBox.Parent=popup
    do local p=Instance.new("UIPadding"); p.PaddingLeft=UDim.new(0,4); p.Parent=hexBox end

    -- PREVIEW LARGE
    local bigPreview = Instance.new("Frame")
    bigPreview.Size=UDim2.new(0,54,0,16); bigPreview.Position=UDim2.new(0,120,0,150)
    bigPreview.BorderColor3=Color3.fromRGB(40,40,40); bigPreview.BorderSizePixel=1
    bigPreview.ZIndex=61; bigPreview.Parent=popup

    -- ЗАКРЫТЬ BTN
    local closeCP = Instance.new("TextButton")
    closeCP.Size=UDim2.new(0,12,0,12); closeCP.Position=UDim2.new(1,-14,0,2)
    closeCP.BackgroundTransparency=1; closeCP.Font=Enum.Font.Code
    closeCP.Text="×"; closeCP.TextColor3=Color3.fromRGB(80,80,80)
    closeCP.TextSize=11; closeCP.ZIndex=61; closeCP.Parent=popup

    -- === ЛОГИКА ===
    local h, s, v = RGBtoHSV(currentColor.R, currentColor.G, currentColor.B)
    local pickerOpen = false

    local function colorToHex(c)
        return string.format("%02X%02X%02X",
            math.floor(c.R*255+0.5),
            math.floor(c.G*255+0.5),
            math.floor(c.B*255+0.5))
    end

    local function updateUI()
        local r2,g2,b2 = HSVtoRGB(h,s,v)
        currentColor = Color3.new(r2,g2,b2)
        previewFrame.BackgroundColor3 = currentColor
        bigPreview.BackgroundColor3   = currentColor
        hexBox.Text = colorToHex(currentColor)
        -- hue color для SV bg
        local hr,hg,hb = HSVtoRGB(h,1,1)
        svColorBG.BackgroundColor3 = Color3.new(hr,hg,hb)
        -- позиции курсоров
        svCursor.Position = UDim2.new(s,-4,1-v,-4)
        hueCursor.Position = UDim2.new(0,-2,h,-1)
        if onChange then onChange(currentColor) end
    end

    updateUI()

    hexBox.FocusLost:Connect(function()
        local txt = hexBox.Text:gsub("#",""):upper()
        if #txt == 6 then
            local rr = tonumber(txt:sub(1,2),16)
            local gg = tonumber(txt:sub(3,4),16)
            local bb = tonumber(txt:sub(5,6),16)
            if rr and gg and bb then
                h,s,v = RGBtoHSV(rr/255,gg/255,bb/255)
                updateUI()
            end
        end
    end)

    -- SV drag
    local svDrag = false
    svHitbox.MouseButton1Down:Connect(function() svDrag=true end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then svDrag=false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if svDrag and i.UserInputType==Enum.UserInputType.MouseMovement then
            local ab=svFrame.AbsolutePosition; local sz=svFrame.AbsoluteSize
            s = math.clamp((i.Position.X-ab.X)/sz.X,0,1)
            v = 1 - math.clamp((i.Position.Y-ab.Y)/sz.Y,0,1)
            updateUI()
        end
    end)

    -- Hue drag
    local hueDrag = false
    hueHitbox.MouseButton1Down:Connect(function() hueDrag=true end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then hueDrag=false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if hueDrag and i.UserInputType==Enum.UserInputType.MouseMovement then
            local ab=hueFrame.AbsolutePosition; local sz=hueFrame.AbsoluteSize
            h = math.clamp((i.Position.Y-ab.Y)/sz.Y,0,1)
            updateUI()
        end
    end)

    local function openPopup()
        if activeCP and activeCP ~= popup then activeCP.Visible=false end
        pickerOpen = true; popup.Visible=true; activeCP=popup
        local absPos = previewFrame.AbsolutePosition
        local sx = math.clamp(absPos.X + 24, 0, workspace.CurrentCamera.ViewportSize.X - 210)
        local sy = math.clamp(absPos.Y - 95, 0, workspace.CurrentCamera.ViewportSize.Y - 200)
        popup.Position = UDim2.new(0,sx,0,sy)
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
            local pp=popup.AbsolutePosition; local ps=popup.AbsoluteSize
            local inside = mp.X>=pp.X and mp.X<=pp.X+ps.X and mp.Y>=pp.Y and mp.Y<=pp.Y+ps.Y
            local vp=previewFrame.AbsolutePosition; local vs=previewFrame.AbsoluteSize
            local onPrev = mp.X>=vp.X and mp.X<=vp.X+vs.X and mp.Y>=vp.Y and mp.Y<=vp.Y+vs.Y
            if not inside and not onPrev then closePopup() end
        end
    end)

    local ctrl = {}
    function ctrl:GetColor() return currentColor end
    function ctrl:SetColor(c)
        currentColor=c; h,s,v=RGBtoHSV(c.R,c.G,c.B); updateUI()
    end
    return ctrl
end

-- ================================================================
-- ПОСТРОИТЕЛЬ ВКЛАДОК
-- ================================================================
local allTabs = {}

local function makeTab(name)
    local tabBtn = Instance.new("TextButton")
    local tabPage = Instance.new("ScrollingFrame")
    local leftCol = Instance.new("Frame")
    local rightCol = Instance.new("Frame")

    tabBtn.Parent=TabHolder; tabBtn.BackgroundTransparency=1
    tabBtn.Size=UDim2.new(0,80,1,0); tabBtn.Font=Enum.Font.Code
    tabBtn.Text=name:upper(); tabBtn.TextColor3=Color3.fromRGB(60,60,60)
    tabBtn.TextSize=10; tabBtn.BorderSizePixel=0

    tabPage.Parent=ContentHolder; tabPage.BackgroundTransparency=1
    tabPage.BorderSizePixel=0; tabPage.Size=UDim2.new(1,0,1,0)
    tabPage.CanvasSize=UDim2.new(0,0,0,0); tabPage.ScrollBarThickness=2
    tabPage.ScrollBarImageColor3=Color3.fromRGB(50,50,50); tabPage.Visible=false

    leftCol.Parent=tabPage; leftCol.BackgroundTransparency=1
    leftCol.Position=UDim2.new(0,8,0,8); leftCol.Size=UDim2.new(0.5,-12,1,0)
    local ll=Instance.new("UIListLayout"); ll.SortOrder=Enum.SortOrder.LayoutOrder
    ll.Padding=UDim.new(0,8); ll.Parent=leftCol

    rightCol.Parent=tabPage; rightCol.BackgroundTransparency=1
    rightCol.Position=UDim2.new(0.5,4,0,8); rightCol.Size=UDim2.new(0.5,-12,1,0)
    local rl=Instance.new("UIListLayout"); rl.SortOrder=Enum.SortOrder.LayoutOrder
    rl.Padding=UDim.new(0,8); rl.Parent=rightCol

    tabBtn.MouseButton1Click:Connect(function()
        for _,t in pairs(allTabs) do
            t.page.Visible=false; t.btn.TextColor3=Color3.fromRGB(60,60,60); t.btn.BorderSizePixel=0
        end
        tabPage.Visible=true; tabBtn.TextColor3=Color3.fromRGB(220,220,220)
        tabBtn.BorderSizePixel=1; tabBtn.BorderColor3=Color3.fromRGB(80,80,80)
    end)

    local tabObj = {btn=tabBtn, page=tabPage, left=leftCol, right=rightCol}
    table.insert(allTabs, tabObj)
    if #allTabs==1 then tabPage.Visible=true; tabBtn.TextColor3=Color3.fromRGB(220,220,220) end

    local tabAPI = {}

    function tabAPI:Section(sName, side)
        local col = side=="Right" and rightCol or leftCol
        local colLayout = col:FindFirstChildOfClass("UIListLayout")

        local frame = Instance.new("Frame")
        local titleLbl = Instance.new("TextLabel")
        local body = Instance.new("Frame")
        local bodyLayout = Instance.new("UIListLayout")
        local bodyPad = Instance.new("UIPadding")

        frame.Parent=col; frame.BackgroundColor3=Theme.SectionBG
        frame.BorderColor3=Theme.SectionBorder; frame.BorderSizePixel=1
        frame.Size=UDim2.new(1,0,0,28); frame.ClipsDescendants=false

        titleLbl.Parent=frame; titleLbl.BackgroundColor3=Color3.fromRGB(14,14,14)
        titleLbl.BorderColor3=Color3.fromRGB(25,25,25); titleLbl.BorderSizePixel=1
        titleLbl.Size=UDim2.new(1,0,0,18); titleLbl.Font=Enum.Font.Code
        titleLbl.Text="// "..sName:upper(); titleLbl.TextColor3=Color3.fromRGB(70,70,70)
        titleLbl.TextSize=9; titleLbl.TextXAlignment=Enum.TextXAlignment.Left
        do local p=Instance.new("UIPadding"); p.PaddingLeft=UDim.new(0,8); p.Parent=titleLbl end

        body.Parent=frame; body.BackgroundTransparency=1
        body.Position=UDim2.new(0,0,0,18); body.Size=UDim2.new(1,0,0,0)

        bodyLayout.Parent=body; bodyLayout.SortOrder=Enum.SortOrder.LayoutOrder
        bodyLayout.Padding=UDim.new(0,2)

        bodyPad.Parent=body; bodyPad.PaddingLeft=UDim.new(0,8)
        bodyPad.PaddingRight=UDim.new(0,8); bodyPad.PaddingTop=UDim.new(0,5)
        bodyPad.PaddingBottom=UDim.new(0,5)

        local function resize()
            local h2 = bodyLayout.AbsoluteContentSize.Y + 28 + 10
            frame.Size=UDim2.new(1,0,0,h2); body.Size=UDim2.new(1,0,0,h2-18)
            if colLayout then
                tabPage.CanvasSize=UDim2.new(0,0,0,colLayout.AbsoluteContentSize.Y+20)
            end
        end
        bodyLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resize)

        local sec = {}

        -- TOGGLE
        function sec:Toggle(id, tName, default, cb)
            local row=Instance.new("Frame"); row.Parent=body
            row.BackgroundTransparency=1; row.Size=UDim2.new(1,0,0,18)

            local lbl=Instance.new("TextLabel"); lbl.Parent=row
            lbl.BackgroundTransparency=1; lbl.Size=UDim2.new(0.7,0,1,0)
            lbl.Font=Enum.Font.Code; lbl.Text=tName; lbl.TextColor3=Theme.LabelText
            lbl.TextSize=11; lbl.TextXAlignment=Enum.TextXAlignment.Left

            local tf=Instance.new("Frame"); tf.Parent=row
            tf.BackgroundColor3=Theme.ToggleBG; tf.BorderColor3=Color3.fromRGB(40,40,40)
            tf.BorderSizePixel=1; tf.Position=UDim2.new(1,-28,0.5,-7); tf.Size=UDim2.new(0,28,0,14)

            local ti=Instance.new("Frame"); ti.Parent=tf
            ti.BackgroundColor3=Theme.ToggleOff; ti.BorderSizePixel=0
            ti.Size=UDim2.new(0,10,0,10); ti.Position=UDim2.new(0,1,0.5,-5)

            local tb=Instance.new("TextButton"); tb.Parent=tf
            tb.BackgroundTransparency=1; tb.BorderSizePixel=0
            tb.Size=UDim2.new(1,0,1,0); tb.Text=""

            local state = default or false
            local function refresh()
                if state then
                    TweenService:Create(ti,TweenInfo.new(0.1),{Position=UDim2.new(0,15,0.5,-5),BackgroundColor3=Theme.Accent}):Play()
                    lbl.TextColor3=Theme.LabelOn
                else
                    TweenService:Create(ti,TweenInfo.new(0.1),{Position=UDim2.new(0,1,0.5,-5),BackgroundColor3=Theme.ToggleOff}):Play()
                    lbl.TextColor3=Theme.LabelText
                end
            end
            refresh()
            tb.MouseButton1Click:Connect(function()
                state=not state; refresh(); if cb then cb(state) end
            end)
            reg(id,"toggle",function() return state end, function(val)
                state = (val=="true" or val==true); refresh(); if cb then cb(state) end
            end)
        end

        -- SLIDER
        function sec:Slider(id, sName, mn, mx, default, suffix, cb)
            local wrap=Instance.new("Frame"); wrap.Parent=body
            wrap.BackgroundTransparency=1; wrap.Size=UDim2.new(1,0,0,28)
            suffix=suffix or ""
            local curVal = default or mn

            local lbl=Instance.new("TextLabel"); lbl.Parent=wrap
            lbl.BackgroundTransparency=1; lbl.Size=UDim2.new(0.6,0,0,14)
            lbl.Font=Enum.Font.Code; lbl.Text=sName; lbl.TextColor3=Theme.LabelText
            lbl.TextSize=11; lbl.TextXAlignment=Enum.TextXAlignment.Left

            local valLbl=Instance.new("TextLabel"); valLbl.Parent=wrap
            valLbl.BackgroundTransparency=1; valLbl.Position=UDim2.new(0.6,0,0,0)
            valLbl.Size=UDim2.new(0.4,0,0,14); valLbl.Font=Enum.Font.Code
            valLbl.Text=tostring(curVal)..suffix; valLbl.TextColor3=Color3.fromRGB(100,100,100)
            valLbl.TextSize=10; valLbl.TextXAlignment=Enum.TextXAlignment.Right

            local track=Instance.new("Frame"); track.Parent=wrap
            track.BackgroundColor3=Theme.SliderTrack; track.BorderColor3=Color3.fromRGB(30,30,30)
            track.BorderSizePixel=1; track.Position=UDim2.new(0,0,0,17); track.Size=UDim2.new(1,0,0,6)

            local fill=Instance.new("Frame"); fill.Parent=track
            fill.BackgroundColor3=Theme.Accent; fill.BorderSizePixel=0
            fill.Size=UDim2.new((curVal-mn)/(mx-mn),0,1,0)

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
                setVal(math.clamp(math.floor(tonumber(val) or mn), mn, mx))
            end)
        end

        -- BUTTON
        function sec:Button(bName, cb)
            local btn=Instance.new("TextButton"); btn.Parent=body
            btn.BackgroundColor3=Theme.ButtonBG; btn.BorderColor3=Theme.ButtonBorder
            btn.BorderSizePixel=1; btn.Size=UDim2.new(1,0,0,18)
            btn.Font=Enum.Font.Code; btn.Text=bName:upper()
            btn.TextColor3=Theme.ButtonText; btn.TextSize=10
            btn.MouseEnter:Connect(function() btn.TextColor3=Color3.fromRGB(220,220,220); btn.BorderColor3=Color3.fromRGB(80,80,80) end)
            btn.MouseLeave:Connect(function() btn.TextColor3=Theme.ButtonText; btn.BorderColor3=Theme.ButtonBorder end)
            btn.MouseButton1Click:Connect(function() if cb then cb() end end)
        end

        -- DROPDOWN
        function sec:Dropdown(id, dName, options, cb)
            local wrap=Instance.new("Frame"); wrap.Parent=body
            wrap.BackgroundTransparency=1; wrap.Size=UDim2.new(1,0,0,18)
            wrap.ClipsDescendants=false; wrap.ZIndex=5
            local selected = options[1] or ""

            local lbl=Instance.new("TextLabel"); lbl.Parent=wrap
            lbl.BackgroundTransparency=1; lbl.Size=UDim2.new(0.5,0,1,0)
            lbl.Font=Enum.Font.Code; lbl.Text=dName; lbl.TextColor3=Theme.LabelText
            lbl.TextSize=11; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=5

            local box=Instance.new("TextButton"); box.Parent=wrap
            box.BackgroundColor3=Theme.ButtonBG; box.BorderColor3=Theme.ButtonBorder
            box.BorderSizePixel=1; box.Position=UDim2.new(0.5,0,0,0)
            box.Size=UDim2.new(0.5,0,1,0); box.Font=Enum.Font.Code; box.Text=""; box.ZIndex=5

            local boxLbl=Instance.new("TextLabel"); boxLbl.Parent=box
            boxLbl.BackgroundTransparency=1; boxLbl.Size=UDim2.new(1,-6,1,0)
            boxLbl.Position=UDim2.new(0,4,0,0); boxLbl.Font=Enum.Font.Code
            boxLbl.Text=selected; boxLbl.TextColor3=Color3.fromRGB(160,160,160)
            boxLbl.TextSize=10; boxLbl.TextXAlignment=Enum.TextXAlignment.Left; boxLbl.ZIndex=5

            local optHolder=Instance.new("Frame"); optHolder.Parent=wrap
            optHolder.BackgroundColor3=Color3.fromRGB(12,12,12)
            optHolder.BorderColor3=Color3.fromRGB(45,45,45); optHolder.BorderSizePixel=1
            optHolder.Position=UDim2.new(0.5,0,1,0)
            optHolder.Size=UDim2.new(0.5,0,0,#options*18)
            optHolder.Visible=false; optHolder.ZIndex=20
            local ol=Instance.new("UIListLayout"); ol.SortOrder=Enum.SortOrder.LayoutOrder; ol.Parent=optHolder

            local function buildOpts(opts)
                for _,c2 in ipairs(optHolder:GetChildren()) do
                    if c2:IsA("TextButton") then c2:Destroy() end
                end
                optHolder.Size=UDim2.new(0.5,0,0,#opts*18)
                for _,opt in ipairs(opts) do
                    local ob=Instance.new("TextButton"); ob.Parent=optHolder
                    ob.BackgroundTransparency=1; ob.BorderSizePixel=0
                    ob.Size=UDim2.new(1,0,0,18); ob.Font=Enum.Font.Code
                    ob.Text=opt; ob.TextColor3=Color3.fromRGB(120,120,120)
                    ob.TextSize=10; ob.ZIndex=20
                    ob.MouseEnter:Connect(function() ob.TextColor3=Color3.fromRGB(220,220,220) end)
                    ob.MouseLeave:Connect(function() ob.TextColor3=Color3.fromRGB(120,120,120) end)
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

            -- контроллер для конфигов (обновление опций)
            local ctrl = {}
            function ctrl:SetOptions(opts) buildOpts(opts) end
            function ctrl:GetSelected() return selected end
            return ctrl
        end

        -- TEXTBOX
        function sec:Textbox(id, tName, placeholder, cb)
            local wrap=Instance.new("Frame"); wrap.Parent=body
            wrap.BackgroundTransparency=1; wrap.Size=UDim2.new(1,0,0,28)

            local lbl=Instance.new("TextLabel"); lbl.Parent=wrap
            lbl.BackgroundTransparency=1; lbl.Size=UDim2.new(1,0,0,12)
            lbl.Font=Enum.Font.Code; lbl.Text=tName; lbl.TextColor3=Color3.fromRGB(100,100,100)
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

            reg(id,"textbox",function() return box.Text end, function(val)
                box.Text=tostring(val); if cb then cb(box.Text) end
            end)
        end

        -- KEYBIND
        function sec:Keybind(id, kName, default, cb)
            local row=Instance.new("Frame"); row.Parent=body
            row.BackgroundTransparency=1; row.Size=UDim2.new(1,0,0,18)
            local boundKey=default; local waiting=false

            local lbl=Instance.new("TextLabel"); lbl.Parent=row
            lbl.BackgroundTransparency=1; lbl.Size=UDim2.new(0.65,0,1,0)
            lbl.Font=Enum.Font.Code; lbl.Text=kName; lbl.TextColor3=Theme.LabelText
            lbl.TextSize=11; lbl.TextXAlignment=Enum.TextXAlignment.Left

            local kb=Instance.new("TextButton"); kb.Parent=row
            kb.BackgroundColor3=Theme.ButtonBG; kb.BorderColor3=Theme.ButtonBorder
            kb.BorderSizePixel=1; kb.Position=UDim2.new(0.65,0,0.5,-8)
            kb.Size=UDim2.new(0.35,0,0,16); kb.Font=Enum.Font.Code
            kb.Text=default and tostring(default):gsub("Enum.KeyCode.","") or "--"
            kb.TextColor3=Color3.fromRGB(100,100,100); kb.TextSize=9

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
                    local keyStr = tostring(val)
                    kb.Text = keyStr
                    local ok,kc = pcall(function() return Enum.KeyCode[keyStr] end)
                    if ok and kc then boundKey=kc; if cb then cb(kc) end end
                end
            )
        end

        -- COLOR PICKER
        function sec:ColorPicker(id, cpName, default, cb)
            local row=Instance.new("Frame"); row.Parent=body
            row.BackgroundTransparency=1; row.Size=UDim2.new(1,0,0,18)

            local lbl=Instance.new("TextLabel"); lbl.Parent=row
            lbl.BackgroundTransparency=1; lbl.Size=UDim2.new(0.75,0,1,0)
            lbl.Font=Enum.Font.Code; lbl.Text=cpName; lbl.TextColor3=Theme.LabelText
            lbl.TextSize=11; lbl.TextXAlignment=Enum.TextXAlignment.Left

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
-- COMBAT
-- ================================================================
local aimSec  = combatTab:Section("Aimbot",     "Left")
local predSec = combatTab:Section("Prediction", "Right")

aimSec:Toggle("aimbot_on",     "Aimbot",        false, function(v) end)
aimSec:Toggle("silent_aim",    "Silent Aim",    false, function(v) end)
aimSec:Toggle("triggerbot",    "Triggerbot",    false, function(v) end)
aimSec:Divider()
aimSec:Slider("aim_fov",       "FOV",           1, 360, 90,  "°", function(v) end)
aimSec:Slider("silent_chance", "Silent Chance", 0, 100, 100, "%", function(v) end)
aimSec:Dropdown("aim_part",    "Aim Part",      {"Head","Torso","HumanoidRootPart"}, function(v) end)

predSec:Toggle("prediction_on", "Prediction",  false, function(v) end)
predSec:Slider("pred_value",    "Pred Value",  0, 100, 14, "", function(v) end)
predSec:Toggle("check_walls",   "Check Walls", true,  function(v) end)
predSec:Toggle("team_check",    "Team Check",  true,  function(v) end)

-- ================================================================
-- VISUAL
-- ================================================================
local espSec   = visualTab:Section("ESP",   "Left")
local chamsSec = visualTab:Section("Chams", "Right")

espSec:Toggle("esp_on",       "ESP",         false, function(v) end)
espSec:Toggle("box_esp",      "Box ESP",     false, function(v) end)
espSec:Toggle("name_esp",     "Name ESP",    false, function(v) end)
espSec:Toggle("health_bar",   "Health Bar",  false, function(v) end)
espSec:Toggle("distance_esp", "Distance",   false, function(v) end)
espSec:Divider()
espSec:Slider("esp_distance",    "Max Distance", 0, 1000, 500, "st", function(v) end)
espSec:ColorPicker("esp_color",  "ESP Color",   Color3.fromRGB(255,255,255), function(v) end)

chamsSec:Toggle("chams_on",         "Chams",        false, function(v) end)
chamsSec:Toggle("chams_visible",    "Visible Only", false, function(v) end)
chamsSec:ColorPicker("chams_color", "Chams Color",  Color3.fromRGB(200,200,200), function(v) end)

-- ================================================================
-- COSMETICS
-- ================================================================
local chatSec = cosmTab:Section("Chat",      "Left")
local charSec = cosmTab:Section("Character", "Right")

chatSec:Toggle("chat_prefix",  "Chat Prefix", false, function(v) end)
chatSec:Textbox("prefix_text", "Prefix Text", "[SCRIPT]", function(v) end)
chatSec:Toggle("chat_suffix",  "Chat Suffix", false, function(v) end)
chatSec:Textbox("suffix_text", "Suffix Text", "suffix...", function(v) end)

charSec:Toggle("hide_accs",         "Hide Accessories",  false, function(v) end)
charSec:Toggle("custom_body_color", "Custom Body Color", false, function(v) end)
charSec:ColorPicker("body_color",   "Body Color", Color3.fromRGB(255,200,150), function(v) end)

-- ================================================================
-- MOVEMENT
-- ================================================================
local spdSec = moveTab:Section("Speed", "Left")
local flySec = moveTab:Section("Fly",   "Right")

spdSec:Toggle("speed_on",   "Speed Hack", false, function(v) end)
spdSec:Slider("speed_val",  "Speed",      0, 100, 16, "", function(v)
    if LocalPlayer.Character then
        local hum=LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed=v end
    end
end)
spdSec:Dropdown("speed_mode", "Speed Mode", {"Default","Custom","Fly"}, function(v) end)

flySec:Toggle("fly_on",    "Fly",           false, function(v) end)
flySec:Slider("fly_speed", "Fly Speed",     0, 200, 50, "", function(v) end)
flySec:Toggle("noclip",    "Noclip",        false, function(v) end)
flySec:Toggle("inf_jump",  "Infinite Jump", false, function(v)
    if v then
        UserInputService.JumpRequest:Connect(function()
            if LocalPlayer.Character then
                local hum=LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end)
    end
end)

-- ================================================================
-- MISC
-- ================================================================
local miscSec = miscTab:Section("Misc",      "Left")
local spamSec = miscTab:Section("Chat Spam", "Right")

miscSec:Toggle("anti_afk",   "Anti-AFK",   false, function(v) end)
miscSec:Toggle("fullbright",  "Fullbright", false, function(v)
    game:GetService("Lighting").Brightness = v and 10 or 1
end)
miscSec:Toggle("unlock_fps",  "Unlock FPS", false, function(v)
    if setfpscap then setfpscap(v and 0 or 60) end
end)
miscSec:Divider()
miscSec:Button("Copy JobId", function()
    if setclipboard then setclipboard(game.JobId) end
end)
miscSec:Button("Rejoin", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId)
end)

spamSec:Toggle("spam_on",    "Chat Spam", false, function(v) end)
spamSec:Textbox("spam_msg",  "Message",   "Message...", function(v) end)
spamSec:Slider("spam_delay", "Delay",     1, 10, 2, "s", function(v) end)

-- ================================================================
-- SETTINGS
-- ================================================================
local bindSec  = setTab:Section("Keybinds", "Left")
local themeSec = setTab:Section("Theme",    "Left")
local cfgSec   = setTab:Section("Configs",  "Right")

-- KEYBINDS
bindSec:Keybind("menu_bind", "Toggle Menu", Enum.KeyCode.RightShift, function(key)
    menuBind = key
end)

-- THEME ColorPickers
themeSec:ColorPicker("theme_accent",     "Accent / Neon",  Color3.fromRGB(255,255,255), function(c)
    Theme.Accent=c; MainStroke.Color=c; WMStroke.Color=c
end)
themeSec:ColorPicker("theme_btn_bg",     "Button BG",      Color3.fromRGB(14,14,14),    function(c) Theme.ButtonBG=c end)
themeSec:ColorPicker("theme_btn_border", "Button Border",  Color3.fromRGB(35,35,35),    function(c) Theme.ButtonBorder=c end)
themeSec:ColorPicker("theme_btn_text",   "Button Text",    Color3.fromRGB(120,120,120), function(c) Theme.ButtonText=c end)
themeSec:ColorPicker("theme_label",      "Label Text",     Color3.fromRGB(140,140,140), function(c) Theme.LabelText=c end)
themeSec:ColorPicker("theme_window_bg",  "Window BG",      Color3.fromRGB(8,8,8),       function(c)
    Theme.WindowBG=c; MainFrame.BackgroundColor3=c; Watermark.BackgroundColor3=c
end)
themeSec:Toggle("show_watermark", "Show Watermark", true, function(v)
    Watermark.Visible=v
end)

-- ================================================================
-- CONFIGS (LinoriaLib стиль)
-- ================================================================
local FOLDER = "ScriptHub"
if not isfolder(FOLDER) then makefolder(FOLDER) end

local currentCfgName = ""
local cfgDropHandle  = nil  -- контроллер дропдауна

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

-- Сохранить: все значения из registry → файл
local function saveConfig(name)
    if not name or name=="" or name=="-- empty --" then return end
    local lines={}
    for id,entry in pairs(registry) do
        -- пропускаем служебные ключи конфигов
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

-- Загрузить: читаем файл и применяем к registry
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

-- UI
cfgSec:Textbox("cfg_name", "Config Name", "myconfig", function(v)
    currentCfgName = v
end)

cfgDropHandle = cfgSec:Dropdown("cfg_select", "Select Config",
    (function() local l=getCfgList(); return #l>0 and l or {"-- empty --"} end)(),
    function(v)
        if v~="-- empty --" then
            currentCfgName=v
            -- подставим имя в textbox
            if registry["cfg_name"] then pcall(registry["cfg_name"].set, v) end
        end
    end
)

cfgSec:Button("Save Config", function()
    if currentCfgName=="" or currentCfgName=="-- empty --" then return end
    saveConfig(currentCfgName)
    refreshDrop()
end)

cfgSec:Button("Load Config", function()
    if currentCfgName=="" or currentCfgName=="-- empty --" then return end
    loadConfig(currentCfgName)
end)

cfgSec:Button("Delete Config", function()
    if currentCfgName=="" or currentCfgName=="-- empty --" then return end
    deleteConfig(currentCfgName)
    currentCfgName=""
    if registry["cfg_name"] then pcall(registry["cfg_name"].set,"") end
    refreshDrop()
end)

task.defer(refreshDrop)

-- ================================================================
-- ЗАПУСК
-- ================================================================
animateLoader(function()
    MainFrame.Visible = true
end)
