--[[
    H4dinooo UI Library
    Based on Speed Hub X V5.0
    Modified by: Dino / Doz Y / Violence District
    
    Features:
    - Adaptive DPI Scaling (HP, Tablet, PC konsisten)
    - Hijau-Putih Gradient Theme
    - Full white text
    - Professional & clean
    
    Usage:
        local Library = loadstring(game:HttpGet("YOUR_URL"))()
        local Window = Library:CreateWindow({
            Title = "H4dinooo",
            Description = "Game Name",
        })
]]

-- ============================================================
--  SERVICES
-- ============================================================
local Players         = game:GetService("Players")
local Player          = Players.LocalPlayer
local RunService      = game:GetService("RunService")
local TweenService    = game:GetService("TweenService")
local UserInputService= game:GetService("UserInputService")
local VirtualUser     = game:GetService("VirtualUser")

-- ============================================================
--  ADAPTIVE DPI SCALING SYSTEM
-- ============================================================
local DPI = {}

do
    -- Ambil info viewport
    local camera = workspace.CurrentCamera
    local vpSize = camera.ViewportSize

    -- Hitung "logical DPI" dari ukuran viewport
    -- Referensi: 1080p desktop = DPI ~96, iPhone ~460, iPad ~264
    -- Roblox pakai pixel fisik, kita estimasi dari tinggi layar
    local screenH = vpSize.Y
    local screenW = vpSize.X
    
    -- Estimasi DPI berdasarkan tinggi layar fisik
    -- HP biasanya 5-7 inch, tablet 8-12 inch, PC 21-27 inch
    -- Roblox tidak expose inch, jadi kita pakai heuristic:
    -- HP high-DPI:   layar kecil tapi resolusi tinggi → ratio W/H mendekati 9:16 + resolusi tinggi
    -- PC:            resolusi besar, aspect ratio landscape lebar
    local aspectRatio = screenW / screenH
    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    local isTablet = UserInputService.TouchEnabled and (screenH > 900 or screenW > 900)

    -- Base scale reference: desain dibuat untuk 1080x600 (PC sedang)
    local BASE_H = 600
    local BASE_W = 1080

    -- Hitung raw scale dari resolusi
    local rawScaleH = screenH / BASE_H
    local rawScaleW = screenW / BASE_W
    local rawScale  = math.min(rawScaleH, rawScaleW)

    -- DPI correction factor
    local dpiCorrection
    if isMobile and not isTablet then
        -- HP: DPI tinggi (400-600) → perkecil supaya tidak memenuhi layar
        if screenH >= 2400 then
            dpiCorrection = 0.52  -- HP flagship sangat tinggi res
        elseif screenH >= 1920 then
            dpiCorrection = 0.58  -- HP high-end
        elseif screenH >= 1280 then
            dpiCorrection = 0.65  -- HP mid-range
        else
            dpiCorrection = 0.72  -- HP resolusi rendah
        end
    elseif isTablet then
        -- Tablet: DPI sedang (200-300) → ukuran normal-sedikit diperkecil
        if screenH >= 2048 then
            dpiCorrection = 0.75
        else
            dpiCorrection = 0.82
        end
    else
        -- PC/Desktop: DPI rendah (72-120) → perbesar sedikit
        if screenH >= 2160 then
            dpiCorrection = 0.90  -- 4K monitor
        elseif screenH >= 1440 then
            dpiCorrection = 0.95  -- QHD
        else
            dpiCorrection = 1.00  -- FHD dan ke bawah, ukuran penuh
        end
    end

    -- Final scale: smooth clamp supaya tidak terlalu kecil/besar
    local finalScale = math.clamp(rawScale * dpiCorrection, 0.45, 1.35)

    -- Smooth lerp untuk menghindari lompatan drastis
    -- (finalScale sudah smooth karena math.clamp, tapi kita round ke 0.05)
    finalScale = math.floor(finalScale / 0.05 + 0.5) * 0.05

    DPI.scale = finalScale
    DPI.isMobile = isMobile
    DPI.isTablet = isTablet
    DPI.screenW = screenW
    DPI.screenH = screenH

    -- Helper: scale nilai angka
    function DPI:S(value)
        return math.round(value * self.scale)
    end

    -- Helper: scale UDim2 offset (scale part tetap sama)
    function DPI:U2(xs, xo, ys, yo)
        return UDim2.new(xs, math.round(xo * self.scale), ys, math.round(yo * self.scale))
    end

    -- Helper: scale UDim
    function DPI:U(scale, offset)
        return UDim.new(scale, math.round(offset * self.scale))
    end

    -- Helper: scale font size (minimum 8)
    function DPI:F(size)
        return math.max(8, math.round(size * self.scale))
    end

    -- Update jika window di-resize (PC)
    camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        local newVP = camera.ViewportSize
        -- Recalculate untuk PC resize (mobile tidak resize)
        if not isMobile and not isTablet then
            local newRawScale = math.min(newVP.Y / BASE_H, newVP.X / BASE_W)
            local newFinal = math.clamp(newRawScale, 0.45, 1.35)
            DPI.scale = math.floor(newFinal / 0.05 + 0.5) * 0.05
            DPI.screenW = newVP.X
            DPI.screenH = newVP.Y
        end
    end)
end

-- ============================================================
--  THEME : HIJAU - PUTIH GRADIENT
-- ============================================================
local Theme = {}

-- Warna utama (dipakai untuk accent, active state, highlight)
Theme.AccentGreen    = Color3.fromRGB(0, 200, 100)
Theme.AccentWhite    = Color3.fromRGB(255, 255, 255)

-- Background
Theme.BG             = Color3.fromRGB(13, 13, 13)      -- hampir hitam
Theme.BGSecondary    = Color3.fromRGB(20, 20, 20)
Theme.BGItem         = Color3.fromRGB(30, 30, 30)

-- Text
Theme.TextPrimary    = Color3.fromRGB(255, 255, 255)
Theme.TextSecondary  = Color3.fromRGB(180, 180, 180)
Theme.TextDim        = Color3.fromRGB(120, 120, 120)

-- Stroke / Border
Theme.Stroke         = Color3.fromRGB(50, 50, 50)
Theme.StrokeActive   = Theme.AccentGreen

-- Helper: gradient hijau ke putih (untuk UIGradient)
function Theme.GreenWhiteGradient()
    return ColorSequence.new({
        ColorSequenceKeypoint.new(0,   Theme.AccentGreen),
        ColorSequenceKeypoint.new(0.6, Color3.fromRGB(100, 220, 160)),
        ColorSequenceKeypoint.new(1,   Theme.AccentWhite),
    })
end

-- Helper: gradient hijau ke hitam (untuk divider/line)
function Theme.GreenBlackGradient()
    return ColorSequence.new({
        ColorSequenceKeypoint.new(0,   Color3.fromRGB(13, 13, 13)),
        ColorSequenceKeypoint.new(0.5, Theme.AccentGreen),
        ColorSequenceKeypoint.new(1,   Color3.fromRGB(13, 13, 13)),
    })
end

-- ============================================================
--  CUSTOM INSTANCE CREATOR
-- ============================================================
local Custom = {}

function Custom:Create(name, props, parent)
    local inst = Instance.new(name)
    if parent then inst.Parent = parent end
    for k, v in pairs(props) do
        inst[k] = v
    end
    return inst
end

function Custom:EnabledAFK()
    Player.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end

Custom:EnabledAFK()

-- ============================================================
--  RIPPLE CLICK EFFECT
-- ============================================================
local function CircleClick(button, x, y)
    task.spawn(function()
        button.ClipsDescendants = true
        local circle = Instance.new("ImageLabel")
        circle.Image            = "rbxassetid://106471194043211"
        circle.ImageColor3      = Color3.fromRGB(80, 80, 80)
        circle.ImageTransparency = 0.9
        circle.BackgroundTransparency = 1
        circle.ZIndex           = 10
        circle.Name             = "Circle"
        circle.Parent           = button

        local nx = x - button.AbsolutePosition.X
        local ny = y - button.AbsolutePosition.Y
        circle.Position = UDim2.new(0, nx, 0, ny)

        local sz = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 1.5
        local ti = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

        TweenService:Create(circle, ti, {
            Size = UDim2.new(0, sz, 0, sz),
            Position = UDim2.new(0.5, -sz/2, 0.5, -sz/2),
        }):Play()

        task.wait(0.5)
        for _ = 1, 10 do
            circle.ImageTransparency = circle.ImageTransparency + 0.01
            task.wait(0.05)
        end
        circle:Destroy()
    end)
end

-- ============================================================
--  OPEN/CLOSE TOGGLE BUTTON (minimize icon)
-- ============================================================
local function MakeOpenCloseButton()
    local sg = Custom:Create("ScreenGui", {
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, RunService:IsStudio() and Player.PlayerGui
        or (gethui and gethui())
        or (cloneref and cloneref(game:GetService("CoreGui")))
        or game:GetService("CoreGui"))

    local btn = Custom:Create("ImageButton", {
        BackgroundColor3     = Color3.fromRGB(0,0,0),
        BackgroundTransparency = 1,
        BorderColor3         = Theme.AccentGreen,
        Position             = DPI:U2(0.1, 0, 0.07, 0),
        Size                 = DPI:U2(0, 59, 0, 49),
        Image                = "rbxassetid://136890595976124",
        Visible              = false,
    }, sg)

    Custom:Create("UICorner", { CornerRadius = DPI:U(0, 9) }, btn)

    -- Draggable
    local dragging, dragStart, startPos = false, nil, nil
    btn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch
        or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = inp.Position
            startPos  = btn.Position
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    btn.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement
        or inp.UserInputType == Enum.UserInputType.Touch) then
            local d = inp.Position - dragStart
            btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                      startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)

    return btn
end

local OpenCloseBtn = MakeOpenCloseButton()

-- ============================================================
--  MAKE DRAGGABLE (untuk main window)
-- ============================================================
local function MakeDraggable(topbar, frame)
    local dragging, dragStart, startPos = false, nil, nil
    topbar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = inp.Position
            startPos  = frame.Position
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    topbar.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement
        or inp.UserInputType == Enum.UserInputType.Touch) then
            local d = inp.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                        startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

-- ============================================================
--  LIBRARY MAIN TABLE
-- ============================================================
local H4Library = {}
local Notification = {}
H4Library.Unloaded = false

-- ============================================================
--  NOTIFICATION SYSTEM
-- ============================================================
function H4Library:SetNotification(cfg)
    local Title       = cfg[1] or cfg.Title or ""
    local Description = cfg[2] or cfg.Description or ""
    local Content     = cfg[3] or cfg.Content or ""
    local Time        = cfg[5] or cfg.Time or 0.5
    local Delay       = cfg[6] or cfg.Delay or 5

    local notifGui = Custom:Create("ScreenGui", {
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, RunService:IsStudio() and Player.PlayerGui
        or (gethui and gethui())
        or (cloneref and cloneref(game:GetService("CoreGui")))
        or game:GetService("CoreGui"))

    local layout = Custom:Create("Frame", {
        AnchorPoint          = Vector2.new(1,1),
        BackgroundTransparency = 0.999,
        BorderSizePixel      = 0,
        Position             = DPI:U2(1, -30, 1, -30),
        Size                 = DPI:U2(0, 320, 1, 0),
        Name                 = "NotificationLayout",
    }, notifGui)

    local count = 0
    layout.ChildRemoved:Connect(function()
        count = 0
        local ti = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
        for _, v in ipairs(layout:GetChildren()) do
            TweenService:Create(v, ti, {
                Position = UDim2.new(0, 0, 1, -((v.Size.Y.Offset + 12) * count))
            }):Play()
            count += 1
        end
    end)

    local _count = 0
    for _, v in ipairs(layout:GetChildren()) do
        _count = -(v.Position.Y.Offset) + v.Size.Y.Offset + 12
    end

    local notifFrame = Custom:Create("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Size                   = DPI:U2(1, 0, 0, 150),
        AnchorPoint            = Vector2.new(0,1),
        Position               = UDim2.new(0, 0, 1, -_count),
        Name                   = "NotificationFrame",
    }, layout)

    local notifReal = Custom:Create("Frame", {
        BackgroundColor3  = Theme.BGItem,
        BorderSizePixel   = 0,
        Position          = DPI:U2(0, 400, 0, 0),
        Size              = UDim2.new(1, 0, 1, 0),
        Name              = "NotificationFrameReal",
    }, notifFrame)
    Custom:Create("UICorner", { CornerRadius = DPI:U(0,8) }, notifReal)

    -- Top bar
    local top = Custom:Create("Frame", {
        BackgroundTransparency = 0.999,
        BorderSizePixel        = 0,
        Size                   = DPI:U2(1, 0, 0, 36),
        Name                   = "Top",
    }, notifReal)

    local titleLbl = Custom:Create("TextLabel", {
        Font                 = Enum.Font.GothamBold,
        Text                 = Title,
        TextColor3           = Theme.TextPrimary,
        TextSize             = DPI:F(14),
        TextXAlignment       = Enum.TextXAlignment.Left,
        BackgroundTransparency = 0.999,
        BorderSizePixel      = 0,
        Size                 = UDim2.new(1, 0, 1, 0),
        Position             = DPI:U2(0, 10, 0, 0),
    }, top)

    -- Gradient label untuk description
    local descLbl = Custom:Create("TextLabel", {
        Font                 = Enum.Font.GothamBold,
        Text                 = Description,
        TextColor3           = Theme.AccentGreen,
        TextSize             = DPI:F(14),
        TextXAlignment       = Enum.TextXAlignment.Left,
        BackgroundTransparency = 0.999,
        BorderSizePixel      = 0,
        Size                 = UDim2.new(1, 0, 1, 0),
        Position             = DPI:U2(0, titleLbl.TextBounds.X + 15, 0, 0),
    }, top)
    Custom:Create("UIStroke", { Color = Theme.AccentGreen, Thickness = 0.4 }, descLbl)

    local closeBtn = Custom:Create("TextButton", {
        Font                 = Enum.Font.SourceSans,
        Text                 = "X",
        TextColor3           = Theme.TextPrimary,
        TextSize             = DPI:F(18),
        AnchorPoint          = Vector2.new(1, 0.5),
        BackgroundTransparency = 0.999,
        BorderSizePixel      = 0,
        Position             = UDim2.new(1, -5, 0.5, 0),
        Size                 = DPI:U2(0, 25, 0, 25),
    }, top)

    local contentLbl = Custom:Create("TextLabel", {
        Font                 = Enum.Font.GothamBold,
        Text                 = Content,
        TextColor3           = Theme.TextSecondary,
        TextSize             = DPI:F(13),
        TextXAlignment       = Enum.TextXAlignment.Left,
        TextYAlignment       = Enum.TextYAlignment.Top,
        BackgroundTransparency = 0.999,
        BorderSizePixel      = 0,
        Position             = DPI:U2(0, 10, 0, 27),
        Size                 = DPI:U2(1, -20, 0, 13),
    }, notifReal)
    contentLbl.Size = DPI:U2(1, -20, 0, 13 + (13 * (contentLbl.TextBounds.X // contentLbl.AbsoluteSize.X)))
    contentLbl.TextWrapped = true

    if contentLbl.AbsoluteSize.Y < 27 then
        notifFrame.Size = DPI:U2(1, 0, 0, 65)
    else
        notifFrame.Size = DPI:U2(1, 0, 0, contentLbl.AbsoluteSize.Y + 40)
    end

    local waited = false
    function Notification:Close()
        if waited then return end
        waited = true
        TweenService:Create(notifReal, TweenInfo.new(tonumber(Time), Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
            { Position = DPI:U2(0, 400, 0, 0) }):Play()
        task.wait(tonumber(Time) / 1.2)
        notifFrame:Destroy()
        waited = false
    end

    closeBtn.Activated:Connect(function() Notification:Close() end)
    TweenService:Create(notifReal, TweenInfo.new(tonumber(Time), Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
        { Position = UDim2.new(0, 0, 0, 0) }):Play()
    task.wait(tonumber(Delay))
    Notification:Close()

    return Notification
end

-- ============================================================
--  CREATE WINDOW
-- ============================================================
function H4Library:CreateWindow(cfg)
    -- Window size adaptive: base 550x315, scale dengan DPI
    local baseW  = cfg[4] and cfg[4].X.Offset or 550
    local baseH  = cfg[4] and cfg[4].Y.Offset or 315
    local TabW   = cfg[3] or cfg["Tab Width"] or 120

    local Title       = cfg[1] or cfg.Title or "H4dinooo"
    local Description = cfg[2] or cfg.Description or ""

    local scaledW = DPI:S(baseW)
    local scaledH = DPI:S(baseH)
    local scaledTabW = DPI:S(TabW)

    local SizeUi = UDim2.fromOffset(scaledW, scaledH)

    local Funcs = {}

    -- Root ScreenGui
    local rootGui = Custom:Create("ScreenGui", {
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, RunService:IsStudio() and Player.PlayerGui
        or (gethui and gethui())
        or (cloneref and cloneref(game:GetService("CoreGui")))
        or game:GetService("CoreGui"))

    -- Drop shadow holder
    local shadowHolder = Custom:Create("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        AnchorPoint            = Vector2.new(0.5, 0.5),
        Size                   = UDim2.fromOffset(scaledW + DPI:S(50), scaledH + DPI:S(50)),
        ZIndex                 = 1,
        Name                   = "DropShadowHolder",
        Position               = UDim2.new(0.5, 0, 0.5, 0),
    }, rootGui)

    local dropShadow = Custom:Create("ImageLabel", {
        Image               = "",
        ImageColor3         = Color3.fromRGB(0,0,0),
        ImageTransparency   = 0.5,
        ScaleType           = Enum.ScaleType.Slice,
        SliceCenter         = Rect.new(49,49,450,450),
        AnchorPoint         = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel     = 0,
        Position            = UDim2.new(0.5, 0, 0.5, 0),
        Size                = SizeUi,
        ZIndex              = 1,
        Name                = "DropShadow",
    }, shadowHolder)

    -- Main frame
    local Main = Custom:Create("Frame", {
        AnchorPoint          = Vector2.new(0.5, 0.5),
        BackgroundColor3     = Theme.BG,
        BackgroundTransparency = 0.05,
        BorderSizePixel      = 0,
        Position             = UDim2.new(0.5, 0, 0.5, 0),
        Size                 = SizeUi,
        Name                 = "Main",
    }, dropShadow)
    Custom:Create("UICorner", { CornerRadius = DPI:U(0, 8) }, Main)
    Custom:Create("UIStroke", { Color = Theme.Stroke, Thickness = 1.5 }, Main)

    -- ── TOP BAR ──────────────────────────────────────────────
    local Top = Custom:Create("Frame", {
        BackgroundTransparency = 0.999,
        BorderSizePixel        = 0,
        Size                   = DPI:U2(1, 0, 0, 38),
        Name                   = "Top",
    }, Main)
    Custom:Create("UICorner", { CornerRadius = DPI:U(0, 5) }, Top)

    -- Title label (hijau-putih gradient pakai UIGradient on TextLabel trick)
    local titleFrame = Custom:Create("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Position               = DPI:U2(0, 10, 0, 0),
        Size                   = DPI:U2(0, 160, 1, 0),
        Name                   = "TitleFrame",
    }, Top)

    local titleLbl = Custom:Create("TextLabel", {
        Font                   = Enum.Font.GothamBold,
        Text                   = Title,
        TextColor3             = Theme.TextPrimary,
        TextSize               = DPI:F(14),
        TextXAlignment         = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Size                   = UDim2.new(1, 0, 1, 0),
        Name                   = "TitleLabel",
    }, titleFrame)
    -- Gradient text effect (UIGradient pada TextLabel)
    Custom:Create("UIGradient", {
        Color    = Theme.GreenWhiteGradient(),
        Rotation = 0,
    }, titleLbl)

    -- Description label
    local descLbl = Custom:Create("TextLabel", {
        Font                   = Enum.Font.GothamBold,
        Text                   = Description,
        TextColor3             = Theme.TextPrimary,
        TextSize               = DPI:F(14),
        TextXAlignment         = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Size                   = DPI:U2(1, -(titleLbl.TextBounds.X + 104), 1, 0),
        Position               = DPI:U2(0, titleLbl.TextBounds.X + 15, 0, 0),
        Name                   = "DescLabel",
    }, Top)
    Custom:Create("UIStroke", { Color = Theme.AccentGreen, Thickness = 0.4 }, descLbl)

    -- Close button
    local CloseBtn = Custom:Create("TextButton", {
        Font                   = Enum.Font.SourceSans,
        Text                   = "X",
        TextColor3             = Theme.TextPrimary,
        TextSize               = DPI:F(18),
        AnchorPoint            = Vector2.new(1, 0.5),
        BackgroundTransparency = 0.999,
        BorderSizePixel        = 0,
        Position               = UDim2.new(1, -DPI:S(8), 0.5, 0),
        Size                   = DPI:U2(0, 25, 0, 25),
        Name                   = "Close",
    }, Top)

    -- Minimize button
    local MinBtn = Custom:Create("TextButton", {
        Font                   = Enum.Font.SourceSans,
        Text                   = "−",
        TextColor3             = Theme.TextPrimary,
        TextSize               = DPI:F(18),
        AnchorPoint            = Vector2.new(1, 0.5),
        BackgroundTransparency = 0.999,
        BorderSizePixel        = 0,
        Position               = UDim2.new(1, -DPI:S(42), 0.5, 0),
        Size                   = DPI:U2(0, 25, 0, 25),
        Name                   = "Min",
    }, Top)

    -- Divider bawah top bar
    Custom:Create("Frame", {
        AnchorPoint          = Vector2.new(0.5, 0),
        BackgroundColor3     = Theme.TextPrimary,
        BackgroundTransparency = 0.85,
        BorderSizePixel      = 0,
        Position             = UDim2.new(0.5, 0, 0, DPI:S(38)),
        Size                 = DPI:U2(1, 0, 0, 1),
        Name                 = "DecideFrame",
    }, Main)

    -- ── TAB SIDEBAR ──────────────────────────────────────────
    local LayersTab = Custom:Create("Frame", {
        BackgroundTransparency = 0.999,
        BorderSizePixel        = 0,
        Position               = DPI:U2(0, 9, 0, 50),
        Size                   = UDim2.new(0, scaledTabW, 1, -DPI:S(59)),
        Name                   = "LayersTab",
    }, Main)
    Custom:Create("UICorner", { CornerRadius = DPI:U(0, 2) }, LayersTab)

    -- Vertical divider antara tab & content
    local tabDivider = Custom:Create("Frame", {
        BackgroundColor3     = Theme.Stroke,
        BackgroundTransparency = 0.3,
        BorderSizePixel      = 0,
        Position             = UDim2.new(0, scaledTabW + DPI:S(9), 0, DPI:S(50)),
        Size                 = DPI:U2(0, 1, 1, -DPI:S(59)),
        Name                 = "TabDivider",
    }, Main)

    -- ── CONTENT AREA ─────────────────────────────────────────
    local Layers = Custom:Create("Frame", {
        BackgroundTransparency = 0.999,
        BorderSizePixel        = 0,
        Position               = UDim2.new(0, scaledTabW + DPI:S(18), 0, DPI:S(50)),
        Size                   = UDim2.new(1, -(scaledTabW + DPI:S(9) + DPI:S(18)), 1, -DPI:S(59)),
        Name                   = "Layers",
    }, Main)
    Custom:Create("UICorner", { CornerRadius = DPI:U(0, 2) }, Layers)

    local NameTab = Custom:Create("TextLabel", {
        Font                   = Enum.Font.GothamBold,
        Text                   = "",
        TextColor3             = Theme.TextPrimary,
        TextSize               = DPI:F(24),
        TextWrapped            = true,
        TextXAlignment         = Enum.TextXAlignment.Left,
        BackgroundTransparency = 0.999,
        BorderSizePixel        = 0,
        Size                   = DPI:U2(1, 0, 0, 30),
        Name                   = "NameTab",
    }, Layers)

    local LayersReal = Custom:Create("Frame", {
        AnchorPoint            = Vector2.new(0, 1),
        BackgroundTransparency = 0.999,
        BorderSizePixel        = 0,
        ClipsDescendants       = true,
        Position               = UDim2.new(0, 0, 1, 0),
        Size                   = DPI:U2(1, 0, 1, -33),
        Name                   = "LayersReal",
    }, Layers)

    local LayersFolder = Custom:Create("Folder", { Name = "LayersFolder" }, LayersReal)

    local LayersPageLayout = Custom:Create("UIPageLayout", {
        SortOrder        = Enum.SortOrder.LayoutOrder,
        TweenTime        = 0.4,
        EasingDirection  = Enum.EasingDirection.InOut,
        EasingStyle      = Enum.EasingStyle.Quad,
        Name             = "LayersPageLayout",
    }, LayersFolder)

    -- Scroll untuk tab buttons di sidebar
    local ScrollTab = Custom:Create("ScrollingFrame", {
        CanvasSize             = UDim2.new(0, 0, 2, 0),
        ScrollBarImageColor3   = Color3.fromRGB(0,0,0),
        ScrollBarThickness     = 0,
        Active                 = true,
        BackgroundTransparency = 0.999,
        BorderSizePixel        = 0,
        Size                   = DPI:U2(1, 0, 1, -10),
        Name                   = "ScrollTab",
    }, LayersTab)

    Custom:Create("UIListLayout", {
        Padding     = UDim.new(0, 0),
        SortOrder   = Enum.SortOrder.LayoutOrder,
    }, ScrollTab)

    local function UpdateScrollTabSize()
        local total = 0
        for _, v in pairs(ScrollTab:GetChildren()) do
            if v.Name ~= "UIListLayout" then
                total = total + DPI:S(3) + v.Size.Y.Offset
            end
        end
        ScrollTab.CanvasSize = UDim2.new(0, 0, 0, total)
    end
    ScrollTab.ChildAdded:Connect(UpdateScrollTabSize)
    ScrollTab.ChildRemoved:Connect(UpdateScrollTabSize)

    -- ── DROPDOWN BLUR OVERLAY ────────────────────────────────
    local MoreBlur = Custom:Create("Frame", {
        AnchorPoint          = Vector2.new(1, 0.5),
        BackgroundColor3     = Color3.fromRGB(0,0,0),
        BackgroundTransparency = 1,
        BorderSizePixel      = 0,
        ClipsDescendants     = true,
        Position             = DPI:U2(1, 8, 0.5, 0),
        Size                 = DPI:U2(1, 154, 1, 54),
        Visible              = false,
        Name                 = "MoreBlur",
    }, Layers)
    Custom:Create("UICorner", { CornerRadius = DPI:U(0, 4) }, MoreBlur)

    local ConnectButton = Custom:Create("TextButton", {
        Text                 = "",
        BackgroundTransparency = 0.999,
        BorderSizePixel      = 0,
        Size                 = UDim2.new(1, 0, 1, 0),
        Name                 = "ConnectButton",
    }, MoreBlur)

    local DropdownSelect = Custom:Create("Frame", {
        AnchorPoint          = Vector2.new(1, 0.5),
        BackgroundColor3     = Theme.BGItem,
        BorderSizePixel      = 0,
        LayoutOrder          = 1,
        Position             = DPI:U2(1, 172, 0.5, 0),
        Size                 = DPI:U2(0, 160, 1, -16),
        ClipsDescendants     = true,
        Name                 = "DropdownSelect",
    }, MoreBlur)
    Custom:Create("UICorner", { CornerRadius = DPI:U(0, 3) }, DropdownSelect)
    Custom:Create("UIStroke", {
        Color        = Theme.AccentGreen,
        Thickness    = 2,
        Transparency = 0.6,
    }, DropdownSelect)

    local DropdownSelectReal = Custom:Create("Frame", {
        AnchorPoint          = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 0.999,
        BorderSizePixel      = 0,
        Position             = UDim2.new(0.5, 0, 0.5, 0),
        Size                 = DPI:U2(1, -10, 1, -10),
        Name                 = "DropdownSelectReal",
    }, DropdownSelect)

    local DropdownFolder = Custom:Create("Folder", { Name = "DropdownFolder" }, DropdownSelectReal)
    local DropPageLayout = Custom:Create("UIPageLayout", {
        EasingDirection  = Enum.EasingDirection.InOut,
        EasingStyle      = Enum.EasingStyle.Quad,
        TweenTime        = 0.01,
        SortOrder        = Enum.SortOrder.LayoutOrder,
        Name             = "DropPageLayout",
    }, DropdownFolder)

    ConnectButton.Activated:Connect(function()
        if MoreBlur.Visible then
            local ti = TweenInfo.new(0.2)
            TweenService:Create(MoreBlur, ti, {BackgroundTransparency = 0.999}):Play()
            TweenService:Create(DropdownSelect, ti, {Position = DPI:U2(1, 172, 0.5, 0)}):Play()
            task.wait(0.2)
            MoreBlur.Visible = false
        end
    end)

    -- ── MINIMIZE / CLOSE ─────────────────────────────────────
    MinBtn.Activated:Connect(function()
        CircleClick(MinBtn, Player:GetMouse().X, Player:GetMouse().Y)
        shadowHolder.Visible = false
        if not OpenCloseBtn.Visible then OpenCloseBtn.Visible = true end
    end)
    OpenCloseBtn.Activated:Connect(function()
        shadowHolder.Visible = true
        OpenCloseBtn.Visible = false
    end)
    CloseBtn.Activated:Connect(function()
        CircleClick(CloseBtn, Player:GetMouse().X, Player:GetMouse().Y)
        if rootGui then rootGui:Destroy() end
        if not H4Library.Unloaded then H4Library.Unloaded = true end
    end)

    -- Resize shadow holder setelah render (TextBounds butuh 1 frame)
    task.defer(function()
        shadowHolder.Size = UDim2.fromOffset(scaledW + DPI:S(50), scaledH + DPI:S(50))
    end)
    MakeDraggable(Top, shadowHolder)

    -- ============================================================
    --  CREATE TAB
    -- ============================================================
    local Tabs = {}
    local CountTab = 0
    local CountDropdown = 0

    function Tabs:CreateTab(cfg2)
        local _Name  = cfg2[1] or cfg2.Name or ""
        local _Icon  = cfg2[2] or cfg2.Icon or ""

        -- Content scroll untuk tab ini
        local ScrolLayers = Custom:Create("ScrollingFrame", {
            ScrollBarImageColor3   = Theme.AccentGreen,
            ScrollBarThickness     = DPI:S(2),
            Active                 = true,
            LayoutOrder            = CountTab,
            BackgroundTransparency = 0.999,
            BorderSizePixel        = 0,
            Size                   = UDim2.new(1, 0, 1, 0),
            Name                   = "ScrolLayers",
        }, LayersFolder)
        Custom:Create("UIListLayout", {
            Padding   = UDim.new(0, DPI:S(3)),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }, ScrolLayers)

        -- Tab button di sidebar
        local Tab = Custom:Create("Frame", {
            BackgroundColor3     = Theme.TextPrimary,
            BackgroundTransparency = CountTab == 0 and 0.92 or 0.999,
            BorderSizePixel      = 0,
            LayoutOrder          = CountTab,
            Size                 = DPI:U2(1, 0, 0, 30),
            Name                 = "Tab",
        }, ScrollTab)
        Custom:Create("UICorner", { CornerRadius = DPI:U(0, 4) }, Tab)

        local TabButton = Custom:Create("TextButton", {
            Font                   = Enum.Font.GothamBold,
            Text                   = "",
            BackgroundTransparency = 0.999,
            BorderSizePixel        = 0,
            Size                   = UDim2.new(1, 0, 1, 0),
            Name                   = "TabButton",
        }, Tab)

        Custom:Create("TextLabel", {
            Font                   = Enum.Font.GothamBold,
            Text                   = _Name,
            TextColor3             = Theme.TextPrimary,
            TextSize               = DPI:F(13),
            TextXAlignment         = Enum.TextXAlignment.Left,
            BackgroundTransparency = 0.999,
            BorderSizePixel        = 0,
            Size                   = UDim2.new(1, 0, 1, 0),
            Position               = DPI:U2(0, 30, 0, 0),
            Name                   = "TabName",
        }, Tab)

        Custom:Create("ImageLabel", {
            Image                  = _Icon,
            BackgroundTransparency = 0.999,
            BorderSizePixel        = 0,
            Position               = DPI:U2(0, 9, 0, 7),
            Size                   = DPI:U2(0, 16, 0, 16),
            Name                   = "FeatureImg",
        }, Tab)

        -- Active indicator (gradient hijau-putih bar kiri)
        if CountTab == 0 then
            LayersPageLayout:JumpToIndex(0)
            NameTab.Text = _Name

            local activeBar = Custom:Create("Frame", {
                BackgroundColor3 = Theme.AccentGreen,
                BorderSizePixel  = 0,
                Position         = DPI:U2(0, 2, 0, 9),
                Size             = DPI:U2(0, 2, 0, 12),
                Name             = "ChooseFrame",
            }, Tab)
            Custom:Create("UIGradient", {
                Color    = Theme.GreenWhiteGradient(),
                Rotation = 90,
            }, activeBar)
            Custom:Create("UIStroke", {
                Color     = Theme.AccentGreen,
                Thickness = 1.5,
            }, activeBar)
            Custom:Create("UICorner", {}, activeBar)
        end

        TabButton.Activated:Connect(function()
            CircleClick(TabButton, Player:GetMouse().X, Player:GetMouse().Y)
            local FrameChoose = nil
            for _, s in pairs(ScrollTab:GetChildren()) do
                for _, v in pairs(s:GetChildren()) do
                    if v.Name == "ChooseFrame" then FrameChoose = v; break end
                end
                if FrameChoose then break end
            end

            if FrameChoose and Tab.LayoutOrder ~= LayersPageLayout.CurrentPage.LayoutOrder then
                for _, tf in pairs(ScrollTab:GetChildren()) do
                    if tf.Name == "Tab" then
                        TweenService:Create(tf, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
                            { BackgroundTransparency = 0.999 }):Play()
                    end
                end
                TweenService:Create(Tab, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
                    { BackgroundTransparency = 0.92 }):Play()
                TweenService:Create(FrameChoose, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                    { Position = DPI:U2(0, 2, 0, 9 + (DPI:S(33) * Tab.LayoutOrder)) }):Play()
                LayersPageLayout:JumpToIndex(Tab.LayoutOrder)
                task.wait(0.05)
                NameTab.Text = _Name
                TweenService:Create(FrameChoose, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                    { Size = DPI:U2(0, 2, 0, 20) }):Play()
                task.wait(0.2)
                TweenService:Create(FrameChoose, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                    { Size = DPI:U2(0, 2, 0, 12) }):Play()
            end
        end)

        -- ── SECTIONS ─────────────────────────────────────────
        local Sections  = {}
        local CountSection = 0

        function Sections:AddSection(Title, OpenSection)
            Title       = Title or ""
            OpenSection = OpenSection or false

            local Section = Custom:Create("Frame", {
                BackgroundTransparency = 0.999,
                BorderSizePixel        = 0,
                ClipsDescendants       = true,
                LayoutOrder            = CountSection,
                Size                   = DPI:U2(1, 0, 0, 30),
                Name                   = "Section",
            }, ScrolLayers)

            local SectionReal = Custom:Create("Frame", {
                AnchorPoint          = Vector2.new(0.5, 0),
                BackgroundColor3     = Theme.BGSecondary,
                BackgroundTransparency = 0.3,
                BorderSizePixel      = 0,
                LayoutOrder          = 1,
                Position             = UDim2.new(0.5, 0, 0, 0),
                Size                 = DPI:U2(1, 1, 0, 30),
                Name                 = "SectionReal",
            }, Section)
            Custom:Create("UICorner", { CornerRadius = DPI:U(0, 4) }, SectionReal)

            -- Gradient stripe di kiri section header
            local sectionAccent = Custom:Create("Frame", {
                BackgroundColor3 = Theme.AccentGreen,
                BorderSizePixel  = 0,
                Position         = DPI:U2(0, 0, 0, 4),
                Size             = DPI:U2(0, 2, 1, -8),
                Name             = "SectionAccent",
            }, SectionReal)
            Custom:Create("UIGradient", {
                Color    = Theme.GreenWhiteGradient(),
                Rotation = 90,
            }, sectionAccent)
            Custom:Create("UICorner", {}, sectionAccent)

            local SectionButton = Custom:Create("TextButton", {
                Font                   = Enum.Font.SourceSans,
                Text                   = "",
                BackgroundTransparency = 0.999,
                BorderSizePixel        = 0,
                Size                   = UDim2.new(1, 0, 1, 0),
                Name                   = "SectionButton",
            }, SectionReal)

            local FeatureFrame = Custom:Create("Frame", {
                AnchorPoint          = Vector2.new(1, 0.5),
                BackgroundTransparency = 0.999,
                BorderSizePixel      = 0,
                Position             = UDim2.new(1, -DPI:S(5), 0.5, 0),
                Size                 = DPI:U2(0, 20, 0, 20),
                Name                 = "FeatureFrame",
            }, SectionReal)

            Custom:Create("ImageLabel", {
                Image                  = "rbxassetid://125609963478878",
                ImageColor3            = Theme.AccentGreen,
                AnchorPoint            = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 0.999,
                BorderSizePixel        = 0,
                Position               = UDim2.new(0.5, 0, 0.5, 0),
                Rotation               = -90,
                Size                   = DPI:U2(1, 6, 1, 6),
                Name                   = "FeatureImg",
            }, FeatureFrame)

            local SectionTitle = Custom:Create("TextLabel", {
                Font                   = Enum.Font.GothamBold,
                Text                   = Title,
                TextColor3             = Theme.TextPrimary,
                TextSize               = DPI:F(13),
                TextXAlignment         = Enum.TextXAlignment.Left,
                TextYAlignment         = Enum.TextYAlignment.Top,
                AnchorPoint            = Vector2.new(0, 0.5),
                BackgroundTransparency = 0.999,
                BorderSizePixel        = 0,
                Position               = DPI:U2(0, 14, 0.5, 0),
                Size                   = DPI:U2(1, -50, 0, 13),
                Name                   = "SectionTitle",
            }, SectionReal)

            -- Divider line gradient bawah section header
            local SectionDecide = Custom:Create("Frame", {
                BackgroundColor3     = Theme.TextPrimary,
                BorderSizePixel      = 0,
                AnchorPoint          = Vector2.new(0.5, 0),
                Position             = UDim2.new(0.5, 0, 0, DPI:S(33)),
                Size                 = DPI:U2(0, 0, 0, 2),
                Name                 = "SectionDecideFrame",
            }, Section)
            Custom:Create("UICorner", {}, SectionDecide)
            Custom:Create("UIGradient", {
                Color = Theme.GreenBlackGradient(),
            }, SectionDecide)

            local SectionAdd = Custom:Create("Frame", {
                AnchorPoint          = Vector2.new(0.5, 0),
                BackgroundTransparency = 0.999,
                BorderSizePixel      = 0,
                ClipsDescendants     = true,
                LayoutOrder          = 1,
                Position             = UDim2.new(0.5, 0, 0, DPI:S(38)),
                Size                 = DPI:U2(1, 0, 0, 100),
                Name                 = "SectionAdd",
            }, Section)
            Custom:Create("UICorner", { CornerRadius = DPI:U(0, 2) }, SectionAdd)
            Custom:Create("UIListLayout", {
                Padding   = UDim.new(0, DPI:S(3)),
                SortOrder = Enum.SortOrder.LayoutOrder,
            }, SectionAdd)

            local function UpdateSizeScroll()
                local off = 0
                for _, child in pairs(ScrolLayers:GetChildren()) do
                    if child.Name ~= "UIListLayout" then
                        off = off + DPI:S(3) + child.Size.Y.Offset
                    end
                end
                ScrolLayers.CanvasSize = UDim2.new(0, 0, 0, off)
            end

            local function UpdateSizeSection()
                if OpenSection then
                    local sz = DPI:S(38)
                    for _, v in pairs(SectionAdd:GetChildren()) do
                        if v.Name ~= "UIListLayout" and v.Name ~= "UICorner" then
                            sz = sz + v.Size.Y.Offset + DPI:S(3)
                        end
                    end
                    TweenService:Create(FeatureFrame, TweenInfo.new(0.1), {Rotation = 90}):Play()
                    TweenService:Create(Section, TweenInfo.new(0.1), {Size = DPI:U2(1, 1, 0, sz)}):Play()
                    TweenService:Create(SectionAdd, TweenInfo.new(0.1), {Size = DPI:U2(1, 0, 0, sz - DPI:S(38))}):Play()
                    TweenService:Create(SectionDecide, TweenInfo.new(0.1), {Size = DPI:U2(1, 0, 0, 2)}):Play()
                    task.wait(0.5)
                    UpdateSizeScroll()
                end
            end

            local function ToggleSection()
                CircleClick(SectionButton, Player:GetMouse().X, Player:GetMouse().Y)
                if OpenSection then
                    TweenService:Create(FeatureFrame, TweenInfo.new(0.1), {Rotation = 0}):Play()
                    TweenService:Create(Section, TweenInfo.new(0.1), {Size = DPI:U2(1, 1, 0, 30)}):Play()
                    TweenService:Create(SectionDecide, TweenInfo.new(0.1), {Size = DPI:U2(0, 0, 0, 2)}):Play()
                    OpenSection = false
                    task.wait(0.1)
                    UpdateSizeScroll()
                else
                    OpenSection = true
                    UpdateSizeSection()
                end
            end

            SectionButton.Activated:Connect(ToggleSection)
            SectionAdd.ChildAdded:Connect(UpdateSizeSection)
            SectionAdd.ChildRemoved:Connect(UpdateSizeSection)
            UpdateSizeScroll()

            -- ── ITEMS ────────────────────────────────────────
            local Item, ItemCount = {}, 0

            -- Helper buat item frame dasar
            local function MakeItemBase(name, order)
                local f = Custom:Create("Frame", {
                    BackgroundColor3     = Theme.BGItem,
                    BackgroundTransparency = 0.1,
                    BorderSizePixel      = 0,
                    LayoutOrder          = order,
                    Size                 = DPI:U2(1, 0, 0, 35),
                    Name                 = name,
                }, SectionAdd)
                Custom:Create("UICorner", { CornerRadius = DPI:U(0, 4) }, f)
                return f
            end

            -- AddParagraph
            function Item:AddParagraph(cfg3)
                local PTitle   = cfg3[1] or cfg3.Title or ""
                local PContent = cfg3[2] or cfg3.Content or ""
                local sFuncs   = {}

                local P = MakeItemBase("Paragraph", ItemCount)
                local ptLbl = Custom:Create("TextLabel", {
                    Font                   = Enum.Font.GothamBold,
                    Text                   = PTitle,
                    TextColor3             = Theme.TextPrimary,
                    TextSize               = DPI:F(13),
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    TextYAlignment         = Enum.TextYAlignment.Top,
                    BackgroundTransparency = 0.999,
                    BorderSizePixel        = 0,
                    Position               = DPI:U2(0, 10, 0, 10),
                    Size                   = DPI:U2(1, -16, 0, 13),
                    Name                   = "ParagraphTitle",
                }, P)
                local pcLbl = Custom:Create("TextLabel", {
                    Font                   = Enum.Font.GothamBold,
                    Text                   = PContent,
                    TextColor3             = Theme.TextSecondary,
                    TextSize               = DPI:F(12),
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    TextYAlignment         = Enum.TextYAlignment.Bottom,
                    BackgroundTransparency = 0.999,
                    BorderSizePixel        = 0,
                    Position               = DPI:U2(0, 10, 0, 23),
                    Name                   = "ParagraphContent",
                }, P)

                local function UpdateP()
                    pcLbl.TextWrapped = false
                    local lines = math.ceil(pcLbl.TextBounds.X / math.max(pcLbl.AbsoluteSize.X, 1))
                    pcLbl.Size = DPI:U2(1, -16, 0, DPI:S(12) + (DPI:S(12) * lines))
                    P.Size = DPI:U2(1, 0, 0, pcLbl.AbsoluteSize.Y + DPI:S(33))
                    pcLbl.TextWrapped = true
                    UpdateSizeSection()
                end
                UpdateP()
                pcLbl:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateP)

                function sFuncs:Set(c)
                    ptLbl.Text = c[1] or c.Title or ""
                    pcLbl.Text = c[2] or c.Content or ""
                    UpdateP()
                end
                ItemCount += 1
                return sFuncs
            end

            -- AddSeperator
            function Item:AddSeperator(cfg3)
                local STitle = cfg3[1] or cfg3.Title or ""
                local sFuncs = {}
                local Sep = MakeItemBase("Seperator", ItemCount)
                Sep.BackgroundColor3 = Theme.BGSecondary
                sep_gradient = Custom:Create("UIGradient", {
                    Color    = Theme.GreenBlackGradient(),
                    Rotation = 90,
                }, Sep)
                Custom:Create("TextLabel", {
                    Font                   = Enum.Font.GothamBold,
                    Text                   = STitle,
                    TextColor3             = Theme.TextPrimary,
                    TextStrokeColor3       = Color3.fromRGB(0,0,0),
                    TextStrokeTransparency = 0.8,
                    TextSize               = DPI:F(14),
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    TextYAlignment         = Enum.TextYAlignment.Center,
                    BackgroundTransparency = 1,
                    BorderSizePixel        = 0,
                    Position               = DPI:U2(0, 12, 0, 0),
                    Size                   = DPI:U2(1, -16, 1, 0),
                    Name                   = "SeperatorTitle",
                }, Sep)
                function sFuncs:Set(c)
                    Sep:FindFirstChild("SeperatorTitle").Text = c[1] or c.Title or ""
                end
                ItemCount += 1
                return sFuncs
            end

            -- AddLine
            function Item:AddLine()
                local Line = Custom:Create("Frame", {
                    BackgroundColor3     = Theme.AccentGreen,
                    BackgroundTransparency = 0.5,
                    BorderSizePixel      = 0,
                    LayoutOrder          = ItemCount,
                    Size                 = DPI:U2(1, 0, 0, 3),
                    Name                 = "Line",
                }, SectionAdd)
                Custom:Create("UICorner", { CornerRadius = DPI:U(0, 2) }, Line)
                Custom:Create("UIGradient", { Color = Theme.GreenBlackGradient() }, Line)
                ItemCount += 1
                return {}
            end

            -- AddButton
            function Item:AddButton(cfg3)
                local BTitle    = cfg3[1] or cfg3.Title or ""
                local BContent  = cfg3[2] or cfg3.Content or ""
                local BIcon     = cfg3[3] or cfg3.Icon or "rbxassetid://7734010488"
                local BCallback = cfg3[4] or cfg3.Callback or function() end
                local bFuncs    = {}

                local Btn = MakeItemBase("Button", ItemCount)
                Custom:Create("TextLabel", {
                    Font                   = Enum.Font.GothamBold,
                    Text                   = BTitle,
                    TextColor3             = Theme.TextPrimary,
                    TextSize               = DPI:F(13),
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    TextYAlignment         = Enum.TextYAlignment.Top,
                    BackgroundTransparency = 0.999,
                    BorderSizePixel        = 0,
                    Position               = DPI:U2(0, 10, 0, 10),
                    Size                   = DPI:U2(1, -100, 0, 13),
                    Name                   = "ButtonTitle",
                }, Btn)
                local bCont = Custom:Create("TextLabel", {
                    Font                   = Enum.Font.GothamBold,
                    Text                   = BContent,
                    TextColor3             = Theme.TextSecondary,
                    TextSize               = DPI:F(12),
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    TextYAlignment         = Enum.TextYAlignment.Bottom,
                    BackgroundTransparency = 0.999,
                    BorderSizePixel        = 0,
                    Position               = DPI:U2(0, 10, 0, 23),
                    Size                   = DPI:U2(1, -100, 0, 12),
                    Name                   = "ButtonContent",
                }, Btn)
                local function UpdateBtn()
                    local h = DPI:S(12) + (DPI:S(12) * (bCont.TextBounds.X // math.max(bCont.AbsoluteSize.X, 1)))
                    bCont.Size = DPI:U2(1, -100, 0, h)
                    Btn.Size   = DPI:U2(1, 0, 0, bCont.AbsoluteSize.Y + DPI:S(33))
                end
                bCont.TextWrapped = true
                UpdateBtn()
                bCont:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                    bCont.TextWrapped = false; UpdateBtn(); bCont.TextWrapped = true
                    UpdateSizeSection()
                end)
                local bBtnReal = Custom:Create("TextButton", {
                    Text                   = "",
                    BackgroundTransparency = 0.999,
                    BorderSizePixel        = 0,
                    Size                   = UDim2.new(1, 0, 1, 0),
                    Name                   = "ButtonButton",
                }, Btn)
                local iconFrame = Custom:Create("Frame", {
                    AnchorPoint          = Vector2.new(1, 0.5),
                    BackgroundTransparency = 0.999,
                    BorderSizePixel      = 0,
                    Position             = UDim2.new(1, -DPI:S(15), 0.5, 0),
                    Size                 = DPI:U2(0, 25, 0, 25),
                }, Btn)
                Custom:Create("ImageLabel", {
                    Image                  = BIcon,
                    AnchorPoint            = Vector2.new(0.5, 0.5),
                    BackgroundTransparency = 0.999,
                    BorderSizePixel        = 0,
                    Position               = UDim2.new(0.5, 0, 0.5, 0),
                    Size                   = UDim2.new(1, 0, 1, 0),
                }, iconFrame)
                bBtnReal.Activated:Connect(function()
                    CircleClick(bBtnReal, Player:GetMouse().X, Player:GetMouse().Y)
                    BCallback()
                end)
                ItemCount += 1
                return bFuncs
            end

            -- AddToggle
            function Item:AddToggle(cfg3)
                local TgTitle    = cfg3[1] or cfg3.Title or ""
                local TgContent  = cfg3[2] or cfg3.Content or ""
                local TgDefault  = cfg3[3] or cfg3.Default or false
                local TgCallback = cfg3[4] or cfg3.Callback or function() end
                local tFuncs     = { Value = TgDefault }

                local Tog = MakeItemBase("Toggle", ItemCount)
                local tgTitle = Custom:Create("TextLabel", {
                    Font                   = Enum.Font.GothamBold,
                    Text                   = TgTitle,
                    TextColor3             = Theme.TextPrimary,
                    TextSize               = DPI:F(13),
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    TextYAlignment         = Enum.TextYAlignment.Top,
                    BackgroundTransparency = 0.999,
                    BorderSizePixel        = 0,
                    Position               = DPI:U2(0, 10, 0, 10),
                    Size                   = DPI:U2(1, -100, 0, 13),
                    Name                   = "ToggleTitle",
                }, Tog)
                local tgCont = Custom:Create("TextLabel", {
                    Font                   = Enum.Font.GothamBold,
                    Text                   = TgContent,
                    TextColor3             = Theme.TextSecondary,
                    TextSize               = DPI:F(12),
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    TextYAlignment         = Enum.TextYAlignment.Bottom,
                    BackgroundTransparency = 0.999,
                    BorderSizePixel        = 0,
                    Position               = DPI:U2(0, 10, 0, 23),
                    Size                   = DPI:U2(1, -100, 0, 12),
                    Name                   = "ToggleContent",
                }, Tog)
                local function UpdateTg()
                    tgCont.TextWrapped = false
                    local ratio = tgCont.TextBounds.X / math.max(tgCont.AbsoluteSize.X, 1)
                    tgCont.Size = DPI:U2(1, -100, 0, DPI:S(12) + (DPI:S(12) * math.ceil(ratio)))
                    Tog.Size    = DPI:U2(1, 0, 0, tgCont.AbsoluteSize.Y + DPI:S(33))
                    tgCont.TextWrapped = true
                end
                UpdateTg()
                tgCont:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                    UpdateTg(); UpdateSizeSection()
                end)

                local tgBtnReal = Custom:Create("TextButton", {
                    Text                   = "",
                    BackgroundTransparency = 0.999,
                    BorderSizePixel        = 0,
                    Size                   = UDim2.new(1, 0, 1, 0),
                    Name                   = "ToggleButton",
                }, Tog)

                -- Switch pill
                local pill = Custom:Create("Frame", {
                    AnchorPoint          = Vector2.new(1, 0.5),
                    BackgroundColor3     = Theme.TextPrimary,
                    BackgroundTransparency = 0.92,
                    BorderSizePixel      = 0,
                    Position             = UDim2.new(1, -DPI:S(15), 0.5, 0),
                    Size                 = DPI:U2(0, 30, 0, 15),
                    Name                 = "TogglePill",
                }, Tog)
                Custom:Create("UICorner", { CornerRadius = DPI:U(0, 8) }, pill)
                local pillStroke = Custom:Create("UIStroke", {
                    Color        = Theme.TextPrimary,
                    Thickness    = 1.5,
                    Transparency = 0.9,
                }, pill)

                local circle = Custom:Create("Frame", {
                    BackgroundColor3 = Theme.TextSecondary,
                    BorderSizePixel  = 0,
                    Size             = DPI:U2(0, 14, 0, 14),
                    Position         = DPI:U2(0, 0, 0, 0),
                    Name             = "ToggleCircle",
                }, pill)
                Custom:Create("UICorner", { CornerRadius = DPI:U(0, 15) }, circle)

                local function ToggleAnim(on)
                    local ti = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
                    TweenService:Create(tgTitle, ti, {
                        TextColor3 = on and Theme.AccentGreen or Theme.TextPrimary,
                    }):Play()
                    TweenService:Create(circle, ti, {
                        Position = on and DPI:U2(0, 15, 0, 0) or DPI:U2(0, 0, 0, 0),
                        BackgroundColor3 = on and Theme.AccentGreen or Theme.TextSecondary,
                    }):Play()
                    TweenService:Create(pillStroke, ti, {
                        Color        = on and Theme.AccentGreen or Theme.TextPrimary,
                        Transparency = on and 0 or 0.9,
                    }):Play()
                    TweenService:Create(pill, ti, {
                        BackgroundColor3     = on and Theme.AccentGreen or Theme.TextPrimary,
                        BackgroundTransparency = on and 0 or 0.92,
                    }):Play()
                end

                tgBtnReal.Activated:Connect(function()
                    CircleClick(tgBtnReal, Player:GetMouse().X, Player:GetMouse().Y)
                    tFuncs.Value = not tFuncs.Value
                    tFuncs:Set(tFuncs.Value)
                end)
                function tFuncs:Set(val)
                    TgCallback(val)
                    ToggleAnim(val)
                end
                tFuncs:Set(tFuncs.Value)

                ItemCount += 1
                return tFuncs
            end

            -- AddSlider
            function Item:AddSlider(cfg3)
                local SLTitle    = cfg3[1] or cfg3.Title or ""
                local SLContent  = cfg3[2] or cfg3.Content or ""
                local SLInc      = cfg3[3] or cfg3.Increment or 1
                local SLMin      = cfg3[4] or cfg3.Min or 0
                local SLMax      = cfg3[5] or cfg3.Max or 100
                local SLDefault  = cfg3[6] or cfg3.Default or 50
                local SLCallback = cfg3[7] or cfg3.Callback or function() end
                local slFuncs    = { Value = SLDefault }

                local Slid = MakeItemBase("Slider", ItemCount)
                Custom:Create("TextLabel", {
                    Font                   = Enum.Font.GothamBold,
                    Text                   = SLTitle,
                    TextColor3             = Theme.TextPrimary,
                    TextSize               = DPI:F(13),
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    TextYAlignment         = Enum.TextYAlignment.Top,
                    BackgroundTransparency = 0.999,
                    BorderSizePixel        = 0,
                    Position               = DPI:U2(0, 10, 0, 10),
                    Size                   = DPI:U2(1, -180, 0, 13),
                    Name                   = "SliderTitle",
                }, Slid)
                local slCont = Custom:Create("TextLabel", {
                    Font                   = Enum.Font.GothamBold,
                    Text                   = SLContent,
                    TextColor3             = Theme.TextSecondary,
                    TextSize               = DPI:F(12),
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    TextYAlignment         = Enum.TextYAlignment.Bottom,
                    BackgroundTransparency = 0.999,
                    BorderSizePixel        = 0,
                    Position               = DPI:U2(0, 10, 0, 23),
                    Size                   = DPI:U2(1, -180, 0, 12),
                    Name                   = "SliderContent",
                }, Slid)
                local function UpdateSlid()
                    slCont.TextWrapped = false
                    slCont.Size = DPI:U2(1, -180, 0, DPI:S(12) + (DPI:S(12) * math.floor(slCont.TextBounds.X / math.max(slCont.AbsoluteSize.X, 1))))
                    Slid.Size   = DPI:U2(1, 0, 0, slCont.AbsoluteSize.Y + DPI:S(33))
                    slCont.TextWrapped = true
                end
                slCont:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                    UpdateSlid(); UpdateSizeSection()
                end)
                UpdateSlid()

                -- Value textbox
                local slInput = Custom:Create("Frame", {
                    AnchorPoint          = Vector2.new(0, 0.5),
                    BackgroundColor3     = Theme.AccentGreen,
                    BorderSizePixel      = 0,
                    Position             = UDim2.new(1, -DPI:S(155), 0.5, 0),
                    Size                 = DPI:U2(0, 30, 0, 20),
                    Name                 = "SliderInput",
                }, Slid)
                Custom:Create("UICorner", { CornerRadius = DPI:U(0, 2) }, slInput)
                -- Gradient pada input box
                Custom:Create("UIGradient", {
                    Color    = Theme.GreenWhiteGradient(),
                    Rotation = 0,
                }, slInput)

                local textBox = Custom:Create("TextBox", {
                    Font                   = Enum.Font.GothamBold,
                    Text                   = "0",
                    TextColor3             = Theme.BG,
                    TextSize               = DPI:F(13),
                    TextWrapped            = true,
                    BackgroundTransparency = 0.999,
                    BorderSizePixel        = 0,
                    Size                   = UDim2.new(1, 0, 1, 0),
                }, slInput)

                -- Track bar
                local trackFrame = Custom:Create("Frame", {
                    AnchorPoint          = Vector2.new(1, 0.5),
                    BackgroundColor3     = Theme.TextPrimary,
                    BackgroundTransparency = 0.8,
                    BorderSizePixel      = 0,
                    Position             = UDim2.new(1, -DPI:S(20), 0.5, 0),
                    Size                 = DPI:U2(0, 100, 0, 3),
                    Name                 = "SliderFrame",
                }, Slid)
                Custom:Create("UICorner", {}, trackFrame)

                local fillBar = Custom:Create("Frame", {
                    AnchorPoint      = Vector2.new(0, 0.5),
                    BackgroundColor3 = Theme.AccentGreen,
                    BorderSizePixel  = 0,
                    Position         = UDim2.new(0, 0, 0.5, 0),
                    Size             = UDim2.fromScale(0.5, 1),
                    Name             = "SliderDraggable",
                }, trackFrame)
                Custom:Create("UICorner", {}, fillBar)
                Custom:Create("UIGradient", {
                    Color    = Theme.GreenWhiteGradient(),
                    Rotation = 0,
                }, fillBar)

                local dot = Custom:Create("Frame", {
                    AnchorPoint      = Vector2.new(1, 0.5),
                    BackgroundColor3 = Theme.AccentWhite,
                    BorderSizePixel  = 0,
                    Position         = UDim2.new(1, DPI:S(4), 0.5, 0),
                    Size             = DPI:U2(0, 8, 0, 8),
                    Name             = "SliderCircle",
                }, fillBar)
                Custom:Create("UICorner", {}, dot)
                Custom:Create("UIStroke", { Color = Theme.AccentGreen }, dot)

                local dragging = false

                local function Round(n, f)
                    local r = math.floor(n/f + (math.sign(n)*0.5)) * f
                    if r < 0 then r = r + f end
                    return r
                end

                function slFuncs:Set(val)
                    val = math.clamp(Round(val, SLInc), SLMin, SLMax)
                    slFuncs.Value = val
                    textBox.Text = tostring(val)
                    TweenService:Create(fillBar, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        { Size = UDim2.fromScale((val - SLMin) / (SLMax - SLMin), 1) }):Play()
                end

                trackFrame.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1
                    or i.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                    end
                end)
                trackFrame.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1
                    or i.UserInputType == Enum.UserInputType.Touch then
                        dragging = false; SLCallback(slFuncs.Value)
                    end
                end)
                local lastX
                UserInputService.InputChanged:Connect(function(i)
                    if dragging then
                        local cx = i.Position.X
                        if cx ~= lastX then
                            lastX = cx
                            local sc = math.clamp((cx - trackFrame.AbsolutePosition.X) / math.max(trackFrame.AbsoluteSize.X, 1), 0, 1)
                            slFuncs:Set(SLMin + ((SLMax - SLMin) * sc))
                        end
                    end
                end)
                textBox:GetPropertyChangedSignal("Text"):Connect(function()
                    local v = textBox.Text:gsub("[^%d]","")
                    if v ~= "" then
                        textBox.Text = tostring(math.min(tonumber(v), SLMax))
                    else
                        textBox.Text = "0"
                    end
                end)
                textBox.FocusLost:Connect(function()
                    slFuncs:Set(tonumber(textBox.Text) or 0)
                    SLCallback(slFuncs.Value)
                end)
                slFuncs:Set(SLDefault)
                SLCallback(slFuncs.Value)

                ItemCount += 1
                return slFuncs
            end

            -- AddInput
            function Item:AddInput(cfg3)
                local ITitle    = cfg3[1] or cfg3.Title or ""
                local IContent  = cfg3[2] or cfg3.Content or ""
                local IDefault  = cfg3[3] or cfg3.Default or ""
                local ICallback = cfg3[4] or cfg3.Callback or function() end
                local iFuncs    = { Value = IDefault }

                local Inp = MakeItemBase("Input", ItemCount)
                Custom:Create("TextLabel", {
                    Font                   = Enum.Font.GothamBold,
                    Text                   = ITitle,
                    TextColor3             = Theme.TextPrimary,
                    TextSize               = DPI:F(13),
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    TextYAlignment         = Enum.TextYAlignment.Top,
                    BackgroundTransparency = 0.999,
                    BorderSizePixel        = 0,
                    Position               = DPI:U2(0, 10, 0, 10),
                    Size                   = DPI:U2(1, -180, 0, 13),
                    Name                   = "InputTitle",
                }, Inp)
                local iCont = Custom:Create("TextLabel", {
                    Font                   = Enum.Font.GothamBold,
                    Text                   = IContent,
                    TextColor3             = Theme.TextSecondary,
                    TextSize               = DPI:F(12),
                    TextWrapped            = true,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    TextYAlignment         = Enum.TextYAlignment.Bottom,
                    BackgroundTransparency = 0.999,
                    BorderSizePixel        = 0,
                    Position               = DPI:U2(0, 10, 0, 23),
                    Size                   = DPI:U2(1, -180, 0, 12),
                    Name                   = "InputContent",
                }, Inp)
                local function UpdateInp()
                    local ratio = iCont.TextBounds.X / math.max(iCont.AbsoluteSize.X, 1)
                    iCont.Size = DPI:U2(1, -180, 0, DPI:S(12) + (DPI:S(12) * math.floor(ratio)))
                    Inp.Size   = DPI:U2(1, 0, 0, iCont.AbsoluteSize.Y + DPI:S(33))
                end
                UpdateInp()
                iCont:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                    iCont.TextWrapped = false; UpdateInp(); iCont.TextWrapped = true
                    UpdateSizeSection()
                end)

                local inpFrame = Custom:Create("Frame", {
                    AnchorPoint          = Vector2.new(1, 0.5),
                    BackgroundColor3     = Theme.BGSecondary,
                    BackgroundTransparency = 0.3,
                    BorderSizePixel      = 0,
                    ClipsDescendants     = true,
                    Position             = UDim2.new(1, -DPI:S(7), 0.5, 0),
                    Size                 = DPI:U2(0, 148, 0, 30),
                    Name                 = "InputFrame",
                }, Inp)
                Custom:Create("UICorner", { CornerRadius = DPI:U(0, 4) }, inpFrame)
                Custom:Create("UIStroke", { Color = Theme.Stroke, Thickness = 1 }, inpFrame)

                local iBox = Custom:Create("TextBox", {
                    CursorPosition       = -1,
                    Font                 = Enum.Font.GothamBold,
                    PlaceholderColor3    = Theme.TextDim,
                    PlaceholderText      = "Type here...",
                    Text                 = "",
                    TextColor3           = Theme.TextPrimary,
                    TextSize             = DPI:F(12),
                    TextXAlignment       = Enum.TextXAlignment.Left,
                    AnchorPoint          = Vector2.new(0, 0.5),
                    BackgroundTransparency = 0.999,
                    BorderSizePixel      = 0,
                    Position             = DPI:U2(0, 5, 0.5, 0),
                    Size                 = DPI:U2(1, -10, 1, -8),
                    Name                 = "InputTextBox",
                }, inpFrame)

                -- Accent border saat focused
                iBox.Focused:Connect(function()
                    TweenService:Create(inpFrame:FindFirstChildOfClass("UIStroke"), TweenInfo.new(0.2),
                        { Color = Theme.AccentGreen }):Play()
                end)
                iBox.FocusLost:Connect(function()
                    TweenService:Create(inpFrame:FindFirstChildOfClass("UIStroke"), TweenInfo.new(0.2),
                        { Color = Theme.Stroke }):Play()
                    iFuncs:Set(iBox.Text)
                end)

                function iFuncs:Set(val)
                    iBox.Text = val
                    iFuncs.Value = val
                    ICallback(val)
                end
                iFuncs:Set(IDefault)

                ItemCount += 1
                return iFuncs
            end

            -- AddDropdown
            function Item:AddDropdown(cfg3)
                local DTitle    = cfg3[1] or cfg3.Title or ""
                local DContent  = cfg3[2] or cfg3.Content or ""
                local DMulti    = cfg3[3] or cfg3.Multi or false
                local DOptions  = cfg3[4] or cfg3.Options or {}
                local DDefault  = cfg3[5] or cfg3.Default or {}
                local DCallback = cfg3[6] or cfg3.Callback or function() end
                local dFuncs    = { Value = DDefault, Options = DOptions }

                local Drop = MakeItemBase("Dropdown", ItemCount)
                local dBtn = Custom:Create("TextButton", {
                    Text                   = "",
                    BackgroundTransparency = 0.999,
                    BorderSizePixel        = 0,
                    Size                   = UDim2.new(1, 0, 1, 0),
                    Name                   = "ToggleButton",
                }, Drop)
                Custom:Create("TextLabel", {
                    Font                   = Enum.Font.GothamBold,
                    Text                   = DTitle,
                    TextColor3             = Theme.TextPrimary,
                    TextSize               = DPI:F(13),
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    TextYAlignment         = Enum.TextYAlignment.Top,
                    BackgroundTransparency = 0.999,
                    BorderSizePixel        = 0,
                    Position               = DPI:U2(0, 10, 0, 10),
                    Size                   = DPI:U2(1, -180, 0, 13),
                    Name                   = "DropdownTitle",
                }, Drop)
                local dCont = Custom:Create("TextLabel", {
                    Font                   = Enum.Font.GothamBold,
                    Text                   = DContent,
                    TextColor3             = Theme.TextSecondary,
                    TextSize               = DPI:F(12),
                    TextWrapped            = true,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    TextYAlignment         = Enum.TextYAlignment.Bottom,
                    BackgroundTransparency = 0.999,
                    BorderSizePixel        = 0,
                    Position               = DPI:U2(0, 10, 0, 23),
                    Size                   = DPI:U2(1, -180, 0, 12),
                    Name                   = "DropdownContent",
                }, Drop)
                dCont.Size = DPI:U2(1, -180, 0, DPI:S(12) + (DPI:S(12) * (dCont.TextBounds.X // math.max(dCont.AbsoluteSize.X,1))))
                dCont.TextWrapped = true
                Drop.Size = DPI:U2(1, 0, 0, dCont.AbsoluteSize.Y + DPI:S(33))
                dCont:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                    dCont.TextWrapped = false
                    dCont.Size = DPI:U2(1,-180,0,DPI:S(12)+(DPI:S(12)*(dCont.TextBounds.X // math.max(dCont.AbsoluteSize.X,1))))
                    Drop.Size  = DPI:U2(1,0,0,dCont.AbsoluteSize.Y + DPI:S(33))
                    dCont.TextWrapped = true
                    UpdateSizeSection()
                end)

                local selFrame = Custom:Create("Frame", {
                    AnchorPoint          = Vector2.new(1, 0.5),
                    BackgroundColor3     = Theme.BGSecondary,
                    BackgroundTransparency = 0.3,
                    BorderSizePixel      = 0,
                    Position             = UDim2.new(1, -DPI:S(7), 0.5, 0),
                    Size                 = DPI:U2(0, 148, 0, 30),
                    LayoutOrder          = CountDropdown,
                    Name                 = "SelectOptionsFrame",
                }, Drop)
                Custom:Create("UICorner", { CornerRadius = DPI:U(0, 4) }, selFrame)
                Custom:Create("UIStroke", { Color = Theme.Stroke, Thickness = 1 }, selFrame)

                dBtn.Activated:Connect(function()
                    if not MoreBlur.Visible then
                        MoreBlur.Visible = true
                        local ti = TweenInfo.new(0.1)
                        DropPageLayout:JumpToIndex(selFrame.LayoutOrder)
                        TweenService:Create(MoreBlur, ti, {BackgroundTransparency = 0.7}):Play()
                        TweenService:Create(DropdownSelect, ti, {Position = DPI:U2(1,-11,0.5,0)}):Play()
                    end
                end)

                local optLabel = Custom:Create("TextLabel", {
                    Font                   = Enum.Font.GothamBold,
                    Text                   = "",
                    TextColor3             = Theme.TextSecondary,
                    TextSize               = DPI:F(12),
                    TextWrapped            = true,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    AnchorPoint            = Vector2.new(0, 0.5),
                    BackgroundTransparency = 0.999,
                    BorderSizePixel        = 0,
                    Position               = DPI:U2(0, 5, 0.5, 0),
                    Size                   = DPI:U2(1, -30, 1, -8),
                    Name                   = "OptionSelecting",
                }, selFrame)
                Custom:Create("ImageLabel", {
                    Image                  = "rbxassetid://90200523188815",
                    ImageColor3            = Theme.AccentGreen,
                    AnchorPoint            = Vector2.new(1, 0.5),
                    BackgroundTransparency = 0.999,
                    BorderSizePixel        = 0,
                    Position               = UDim2.new(1, 0, 0.5, 0),
                    Size                   = DPI:U2(0, 25, 0, 25),
                }, selFrame)

                local scrollSel = Custom:Create("ScrollingFrame", {
                    CanvasSize             = UDim2.new(0,0,0,0),
                    ScrollBarImageColor3   = Theme.AccentGreen,
                    ScrollBarThickness     = DPI:S(2),
                    Active                 = true,
                    LayoutOrder            = CountDropdown,
                    BackgroundTransparency = 0.999,
                    BorderSizePixel        = 0,
                    Size                   = UDim2.new(1,0,1,0),
                    Name                   = "ScrollSelect",
                }, DropdownFolder)
                Custom:Create("UIListLayout", {
                    Padding   = UDim.new(0, DPI:S(3)),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                }, scrollSel)

                local searchBar = Custom:Create("TextBox", {
                    Font                 = Enum.Font.GothamBold,
                    PlaceholderText      = "Search...",
                    PlaceholderColor3    = Theme.TextDim,
                    Text                 = "",
                    TextColor3           = Theme.TextPrimary,
                    TextSize             = DPI:F(12),
                    BackgroundColor3     = Theme.BGSecondary,
                    BackgroundTransparency = 0.5,
                    BorderSizePixel      = 0,
                    Size                 = DPI:U2(1, 0, 0, 20),
                    Name                 = "SearchBar",
                }, scrollSel)
                Custom:Create("UIStroke", { Color = Theme.AccentGreen, Thickness = 1, Transparency = 0.5 }, searchBar)

                searchBar:GetPropertyChangedSignal("Text"):Connect(function()
                    local q = string.lower(searchBar.Text)
                    for _, v in pairs(scrollSel:GetChildren()) do
                        if v:IsA("Frame") and v.Name == "Option" then
                            local t = v:FindFirstChild("OptionText")
                            if t then v.Visible = string.find(string.lower(t.Text), q) ~= nil end
                        end
                    end
                end)

                local DropCount = 0

                function dFuncs:Clear()
                    for _, f in pairs(scrollSel:GetChildren()) do
                        if f.Name == "Option" then
                            dFuncs.Value   = {}
                            dFuncs.Options = {}
                            optLabel.Text  = "Select Options"
                            f:Destroy()
                        end
                    end
                end

                function dFuncs:Set(val)
                    dFuncs.Value = val or dFuncs.Value
                    for _, opt in pairs(scrollSel:GetChildren()) do
                        if opt.Name ~= "UIListLayout" and opt.Name ~= "SearchBar" then
                            local optTextInst = opt:FindFirstChild("OptionText")
                            local found = optTextInst and table.find(dFuncs.Value, optTextInst.Text)
                            local ti = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
                            TweenService:Create(opt.ChooseFrame, ti, {
                                Size = found and DPI:U2(0,2,0,12) or DPI:U2(0,0,0,0),
                            }):Play()
                            TweenService:Create(opt.ChooseFrame.UIStroke, ti, {
                                Transparency = found and 0 or 0.999,
                            }):Play()
                            TweenService:Create(opt, ti, {
                                BackgroundTransparency = found and 0.1 or 0.999,
                            }):Play()
                        end
                    end
                    local joined = table.concat(dFuncs.Value, ", ")
                    optLabel.Text = joined ~= "" and joined or "Select Options"
                    DCallback(dFuncs.Value)
                end

                function dFuncs:AddOption(optName)
                    optName = optName or "Option"
                    local Opt = Custom:Create("Frame", {
                        BackgroundTransparency = 0.999,
                        BorderSizePixel        = 0,
                        LayoutOrder            = DropCount,
                        Size                   = DPI:U2(1, 0, 0, 30),
                        Name                   = "Option",
                    }, scrollSel)
                    Custom:Create("UICorner", { CornerRadius = DPI:U(0, 3) }, Opt)
                    local optBtn = Custom:Create("TextButton", {
                        Text                   = "",
                        BackgroundTransparency = 0.999,
                        BorderSizePixel        = 0,
                        Size                   = UDim2.new(1, 0, 1, 0),
                        Name                   = "OptionButton",
                    }, Opt)
                    Custom:Create("TextLabel", {
                        Font                   = Enum.Font.GothamBold,
                        Text                   = optName,
                        TextSize               = DPI:F(13),
                        TextColor3             = Theme.TextPrimary,
                        TextXAlignment         = Enum.TextXAlignment.Left,
                        TextYAlignment         = Enum.TextYAlignment.Top,
                        BackgroundTransparency = 0.999,
                        BorderSizePixel        = 0,
                        Position               = DPI:U2(0, 8, 0, 8),
                        Size                   = DPI:U2(1, -100, 0, 13),
                        Name                   = "OptionText",
                    }, Opt)
                    local cf = Custom:Create("Frame", {
                        AnchorPoint      = Vector2.new(0, 0.5),
                        BackgroundColor3 = Theme.AccentGreen,
                        BorderSizePixel  = 0,
                        Position         = DPI:U2(0, 2, 0.5, 0),
                        Size             = DPI:U2(0, 0, 0, 0),
                        Name             = "ChooseFrame",
                    }, Opt)
                    Custom:Create("UIGradient", { Color = Theme.GreenWhiteGradient(), Rotation = 90 }, cf)
                    Custom:Create("UIStroke", { Color = Theme.AccentGreen, Thickness = 1.5, Transparency = 0.999 }, cf)
                    Custom:Create("UICorner", {}, cf)

                    optBtn.Activated:Connect(function()
                        CircleClick(optBtn, Player:GetMouse().X, Player:GetMouse().Y)
                        local alreadySel = table.find(dFuncs.Value, optName) ~= nil
                        if DMulti then
                            if not alreadySel then
                                table.insert(dFuncs.Value, optName)
                            else
                                for i, v in ipairs(dFuncs.Value) do
                                    if v == optName then table.remove(dFuncs.Value, i); break end
                                end
                            end
                        else
                            dFuncs.Value = {optName}
                        end
                        dFuncs:Set(dFuncs.Value)
                    end)

                    local function UpdateCanvas()
                        local off = 0
                        for _, ch in ipairs(scrollSel:GetChildren()) do
                            if ch.Name ~= "UIListLayout" and ch.Name ~= "SearchBar" then
                                off = off + DPI:S(5) + ch.Size.Y.Offset
                            end
                        end
                        scrollSel.CanvasSize = UDim2.new(0,0,0,off)
                    end
                    UpdateCanvas()
                    DropCount += 1
                end

                function dFuncs:Refresh(list, selecting)
                    list = list or {}
                    selecting = selecting or {}
                    dFuncs:Clear()
                    for _, v in ipairs(list) do dFuncs:AddOption(v) end
                    dFuncs.Options = list
                    dFuncs:Set(selecting)
                end
                dFuncs:Refresh(dFuncs.Options, dFuncs.Value)

                ItemCount    += 1
                CountDropdown += 1
                return dFuncs
            end

            CountSection += 1
            return Item
        end

        CountTab += 1
        return Sections
    end

    return Tabs
end

return H4Library
