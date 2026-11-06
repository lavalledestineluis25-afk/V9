--[[
    DH UI Library  v7.1  -  LOGIC FILE
    Host this file (GitHub raw etc.) and load it from the usage file with loadstring.

    local Window = Library:CreateWindow({
        Title = "DEXPS", Tag = "v6.0", LogoText = "DX",
        Theme = "Black" | "BlackOrg" | "Crimson" | "Violet" | "Ocean" | "Emerald" | "Rose" | "Sunset" | "Gold" | "Cyber",   -- the outer glow follows it
        Style = "Linoria"  or  Styles = {Linoria = true},            -- window style: Linoria, Obsidian, Terminal, Soft, Compact
        Width = 780, Height = 480, ToggleKey = Enum.KeyCode.RightShift,   -- hides / shows (minimizes) the GUI
        ConfigFolder = "DHUI",
        Dashboard = "Dashboard",        -- the tab that shows the Information panel (false = off)
        Loader = true (false = no loading screen), LoadingTitle, LoadingSubtitle, LoadingTime = 2.8, LoadingStatus = {...}, LoadingTips = {...},
        Snow = false | {Enabled = true, Count = 90, Wind = 0},       -- snow inside the window
        ScreenSnow = true,                                           -- snow over the whole screen while open
        Blur = true, BlurSize = 40, Dim = 0.45,                      -- real blur (BlurEffect + DepthOfField) while open
        MaxNotifications = 5, OnClose = function() end,
    })

    Minimize button  -> the GUI turns into a small draggable button (shows the Title). Click it to open the GUI again.
    Dashboard tab    -> the Information panel: player, game, server, live stats + customize toggles (Highlight Tab, Glow, ...).

    local Tab = Window:CreateTab("Name")
    local Section = Tab:CreateSection({Name = "Title", Side = "Left" | "Right", Collapsed = false})
        Section:CreateLabel(text)               Section:CreateParagraph({Title, Content})
        Section:CreateButton({Name, Description, Tooltip, Callback})
        Section:CreateToggle({Name, Description, Tooltip, Default, Flag, Callback})
        Section:CreateSlider({Name, Range = {min, max}, Increment, Suffix, Default, Flag, Callback})
        Section:CreateDropdown({Name, Options, Default, Multi, Search, Flag, Callback})
        Section:CreateTextbox({Name, Placeholder, Default, Flag, Callback})
        Section:CreateKeybind({Name, Default, Flag, Callback, Changed})
        Section:CreateDivider()
        Section:SetCollapsed(bool)   Section:Toggle()   Section:SetTitle(text)
    Tab:CreateLeftSection(o)  Tab:CreateRightSection(o)  Tab:Select()

    Window:Notify({Title, Content, Duration = 4, Type = "Info" | "Success" | "Warning" | "Error"})   -- colored card, icon, time bar + countdown
        handle:Dismiss()   handle:Update({Title, Content})
    Window:SetTheme(name)  Window:SetSnow(bool)  Window:SetSnowCount(n)  Window:SetScreenSnow(bool)
    Window:SetBlur(bool)   Window:SetBlurSize(n)  Window:SetDim(alpha)
    Window:Minimize()  Window:Restore()  Window:SetVisible(bool)  Window:Toggle()  Window:SetToggleKey(key)
    Window:SetTitle(text)  Window:SaveConfig(name)  Window:LoadConfig(name)  Window:Destroy()
    Library:GetThemes()  Library:GetStyles()  Library.Flags

    Library:KeySystem({...})   -- ordinary key window, see the Key system section near the end of this file
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local GuiService = game:GetService("GuiService")
local Lighting = game:GetService("Lighting")
local MarketplaceService = game:GetService("MarketplaceService")
local LocalizationService = game:GetService("LocalizationService")
local Stats = game:GetService("Stats")

local Library = {Flags = {}, Version = "7.1"}

---------------------------------------------------------------------
-- Themes (Black / BlackOrg / Crimson / Violet / Ocean / Emerald / Rose / Sunset / Gold / Cyber)
---------------------------------------------------------------------

local function rgb(r, g, b)
    return Color3.fromRGB(r, g, b)
end

local Base = {
    Success = rgb(96, 236, 150),
    Warning = rgb(255, 194, 76),
    Error = rgb(255, 86, 102),
}

local function makeTheme(t)
    for k, v in pairs(Base) do
        if t[k] == nil then
            t[k] = v
        end
    end
    return t
end

local Themes = {
    Black = makeTheme({
        Background = rgb(7, 7, 9), Background2 = rgb(18, 18, 23),
        Topbar = rgb(12, 12, 15), Section = rgb(14, 14, 18),
        Element = rgb(22, 22, 28), ElementHover = rgb(34, 34, 42), Stroke = rgb(48, 48, 58),
        Accent = rgb(238, 238, 245), Accent2 = rgb(132, 150, 196), OnAccent = rgb(10, 10, 12),
        Text = rgb(242, 242, 248), SubText = rgb(142, 142, 158),
        Glow = rgb(120, 130, 175), Glow2 = rgb(70, 82, 120),
        Snow = rgb(240, 245, 255), Dim = rgb(0, 0, 0),
        Halo = rgb(0, 0, 0), HaloT = 0.1,
    }),
    -- BlackOrg: plain, simple black everywhere (no tint, no colored glow)
    BlackOrg = makeTheme({
        Background = rgb(0, 0, 0), Background2 = rgb(0, 0, 0),
        Topbar = rgb(0, 0, 0), Section = rgb(0, 0, 0),
        Element = rgb(10, 10, 10), ElementHover = rgb(22, 22, 22), Stroke = rgb(36, 36, 36),
        Accent = rgb(255, 255, 255), Accent2 = rgb(255, 255, 255), OnAccent = rgb(0, 0, 0),
        Text = rgb(255, 255, 255), SubText = rgb(150, 150, 150),
        Glow = rgb(0, 0, 0), Glow2 = rgb(0, 0, 0),
        Snow = rgb(255, 255, 255), Dim = rgb(0, 0, 0),
        Halo = rgb(0, 0, 0), HaloT = 0.1,
    }),
    -- Linoria: flat dark grey with a blue accent (used by the Linoria window style; not in GetThemes)
    Linoria = makeTheme({
        Background = rgb(20, 20, 20), Background2 = rgb(20, 20, 20),
        Topbar = rgb(20, 20, 20), Section = rgb(28, 28, 28),
        Element = rgb(20, 20, 20), ElementHover = rgb(36, 36, 36), Stroke = rgb(50, 50, 50),
        Accent = rgb(0, 85, 255), Accent2 = rgb(0, 85, 255), OnAccent = rgb(255, 255, 255),
        Text = rgb(255, 255, 255), SubText = rgb(165, 165, 165),
        Glow = rgb(0, 0, 0), Glow2 = rgb(0, 0, 0),
        Snow = rgb(255, 255, 255), Dim = rgb(0, 0, 0),
        Halo = rgb(0, 0, 0), HaloT = 1,
    }),
    -- Obsidian: soft dark grey with a purple accent (used by the Obsidian style; not in GetThemes)
    Obsidian = makeTheme({
        Background = rgb(15, 15, 15), Background2 = rgb(15, 15, 15),
        Topbar = rgb(15, 15, 15), Section = rgb(25, 25, 25),
        Element = rgb(19, 19, 19), ElementHover = rgb(36, 36, 36), Stroke = rgb(42, 42, 42),
        Accent = rgb(125, 85, 255), Accent2 = rgb(125, 85, 255), OnAccent = rgb(255, 255, 255),
        Text = rgb(255, 255, 255), SubText = rgb(165, 165, 172),
        Glow = rgb(0, 0, 0), Glow2 = rgb(0, 0, 0),
        Snow = rgb(255, 255, 255), Dim = rgb(0, 0, 0),
        Halo = rgb(0, 0, 0), HaloT = 1,
    }),
    -- Terminal: black with green text (used by the Terminal style; not in GetThemes)
    Terminal = makeTheme({
        Background = rgb(5, 8, 5), Background2 = rgb(5, 8, 5),
        Topbar = rgb(5, 8, 5), Section = rgb(10, 15, 10),
        Element = rgb(8, 12, 8), ElementHover = rgb(18, 28, 18), Stroke = rgb(28, 70, 38),
        Accent = rgb(0, 255, 100), Accent2 = rgb(0, 255, 100), OnAccent = rgb(0, 10, 4),
        Text = rgb(190, 255, 205), SubText = rgb(88, 150, 102),
        Glow = rgb(0, 0, 0), Glow2 = rgb(0, 0, 0),
        Snow = rgb(190, 255, 205), Dim = rgb(0, 0, 0),
        Halo = rgb(0, 0, 0), HaloT = 1,
    }),
    Crimson = makeTheme({
        Background = rgb(11, 5, 7), Background2 = rgb(32, 9, 16),
        Topbar = rgb(18, 9, 12), Section = rgb(21, 10, 14),
        Element = rgb(31, 15, 20), ElementHover = rgb(47, 22, 30), Stroke = rgb(82, 34, 46),
        Accent = rgb(232, 28, 66), Accent2 = rgb(255, 112, 86), OnAccent = rgb(255, 255, 255),
        Text = rgb(248, 238, 240), SubText = rgb(172, 132, 142),
        Glow = rgb(222, 30, 72), Glow2 = rgb(255, 110, 60),
        Snow = rgb(255, 234, 238), Dim = rgb(22, 0, 5),
        Halo = rgb(232, 28, 66), HaloT = 0.4,
    }),
    Violet = makeTheme({
        Background = rgb(8, 5, 17), Background2 = rgb(26, 12, 50),
        Topbar = rgb(15, 9, 28), Section = rgb(18, 11, 33),
        Element = rgb(27, 17, 47), ElementHover = rgb(41, 26, 72), Stroke = rgb(74, 50, 124),
        Accent = rgb(154, 94, 255), Accent2 = rgb(216, 128, 255), OnAccent = rgb(255, 255, 255),
        Text = rgb(244, 239, 253), SubText = rgb(152, 138, 188),
        Glow = rgb(140, 80, 255), Glow2 = rgb(222, 110, 255),
        Snow = rgb(240, 232, 255), Dim = rgb(8, 0, 22),
        Halo = rgb(154, 94, 255), HaloT = 0.4,
    }),
    Ocean = makeTheme({
        Background = rgb(4, 9, 18), Background2 = rgb(8, 26, 48),
        Topbar = rgb(8, 15, 27), Section = rgb(9, 18, 32),
        Element = rgb(14, 27, 46), ElementHover = rgb(22, 42, 72), Stroke = rgb(36, 72, 120),
        Accent = rgb(56, 152, 255), Accent2 = rgb(80, 220, 255), OnAccent = rgb(255, 255, 255),
        Text = rgb(236, 244, 253), SubText = rgb(130, 156, 190),
        Glow = rgb(40, 130, 255), Glow2 = rgb(60, 210, 255),
        Snow = rgb(230, 244, 255), Dim = rgb(0, 6, 20),
        Halo = rgb(56, 152, 255), HaloT = 0.4,
    }),
    Emerald = makeTheme({
        Background = rgb(4, 13, 9), Background2 = rgb(8, 36, 24),
        Topbar = rgb(8, 20, 14), Section = rgb(9, 24, 17),
        Element = rgb(14, 36, 26), ElementHover = rgb(22, 56, 40), Stroke = rgb(36, 100, 70),
        Accent = rgb(52, 214, 128), Accent2 = rgb(150, 240, 100), OnAccent = rgb(4, 20, 10),
        Text = rgb(236, 252, 242), SubText = rgb(126, 176, 150),
        Glow = rgb(40, 200, 120), Glow2 = rgb(140, 235, 90),
        Snow = rgb(232, 255, 240), Dim = rgb(0, 16, 8),
        Halo = rgb(52, 214, 128), HaloT = 0.4,
    }),
    Rose = makeTheme({
        Background = rgb(16, 6, 12), Background2 = rgb(46, 12, 32),
        Topbar = rgb(24, 9, 18), Section = rgb(28, 10, 21),
        Element = rgb(40, 16, 30), ElementHover = rgb(62, 24, 46), Stroke = rgb(110, 44, 82),
        Accent = rgb(255, 92, 170), Accent2 = rgb(255, 150, 205), OnAccent = rgb(255, 255, 255),
        Text = rgb(253, 238, 246), SubText = rgb(190, 136, 164),
        Glow = rgb(255, 80, 160), Glow2 = rgb(255, 140, 210),
        Snow = rgb(255, 236, 246), Dim = rgb(22, 0, 12),
        Halo = rgb(255, 92, 170), HaloT = 0.4,
    }),
    Sunset = makeTheme({
        Background = rgb(16, 8, 4), Background2 = rgb(48, 20, 8),
        Topbar = rgb(24, 12, 7), Section = rgb(28, 14, 8),
        Element = rgb(40, 21, 12), ElementHover = rgb(62, 34, 18), Stroke = rgb(112, 58, 30),
        Accent = rgb(255, 128, 40), Accent2 = rgb(255, 196, 70), OnAccent = rgb(30, 12, 0),
        Text = rgb(253, 242, 232), SubText = rgb(190, 150, 120),
        Glow = rgb(255, 110, 30), Glow2 = rgb(255, 190, 60),
        Snow = rgb(255, 242, 226), Dim = rgb(22, 8, 0),
        Halo = rgb(255, 128, 40), HaloT = 0.4,
    }),
    Gold = makeTheme({
        Background = rgb(13, 11, 4), Background2 = rgb(40, 32, 8),
        Topbar = rgb(21, 18, 7), Section = rgb(25, 21, 8),
        Element = rgb(36, 30, 12), ElementHover = rgb(56, 47, 18), Stroke = rgb(104, 86, 30),
        Accent = rgb(255, 200, 50), Accent2 = rgb(255, 236, 130), OnAccent = rgb(24, 18, 0),
        Text = rgb(252, 248, 232), SubText = rgb(186, 172, 126),
        Glow = rgb(255, 196, 40), Glow2 = rgb(255, 232, 120),
        Snow = rgb(255, 250, 226), Dim = rgb(18, 13, 0),
        Halo = rgb(255, 200, 50), HaloT = 0.4,
    }),
    Cyber = makeTheme({
        Background = rgb(5, 6, 14), Background2 = rgb(22, 8, 44),
        Topbar = rgb(10, 10, 22), Section = rgb(13, 12, 28),
        Element = rgb(20, 18, 40), ElementHover = rgb(32, 28, 64), Stroke = rgb(60, 52, 120),
        Accent = rgb(0, 238, 255), Accent2 = rgb(255, 60, 220), OnAccent = rgb(0, 10, 16),
        Text = rgb(238, 250, 255), SubText = rgb(140, 150, 190),
        Glow = rgb(0, 220, 255), Glow2 = rgb(255, 60, 220),
        Snow = rgb(220, 250, 255), Dim = rgb(4, 0, 18),
        Halo = rgb(0, 238, 255), HaloT = 0.4,
    }),
}
Library.Themes = Themes

local Theme = {}
local function applyTheme(name)
    local src = Themes[name]
    if not src then
        return false
    end
    for k, v in pairs(src) do
        Theme[k] = v
    end
    return true
end
applyTheme("Crimson")

function Library:GetThemes()
    return {"Black", "BlackOrg", "Crimson", "Violet", "Ocean", "Emerald", "Rose", "Sunset", "Gold", "Cyber"}
end

---------------------------------------------------------------------
-- Window styles. Pick one in CreateWindow with  Style = "Name"  or  Styles = {Name = true}.
-- To add your own style, add an entry here (and list it in the usage file).
---------------------------------------------------------------------
local Styles = {
    -- Linoria: flat, square, blue accent, real tab row, check boxes
    Linoria = {
        Flat = true, Theme = "Linoria", Square = true, Font = Enum.Font.Code, Checkbox = true,
        NoGlow = true, NoOrbs = true, NoSnow = true, NoBlur = true, NoDim = true, HideTag = true,
        Top = 28, TabBar = 26, TitleSize = 14, BtnSize = 20,
    },
    -- Obsidian: like Linoria but with slightly rounded corners and a purple accent
    Obsidian = {
        Flat = true, Theme = "Obsidian", Radius = 4, Font = Enum.Font.Code, Checkbox = true,
        NoGlow = true, NoOrbs = true, NoSnow = true, NoBlur = true, NoDim = true, HideTag = true,
        Top = 32, TabBar = 28, TitleSize = 14, BtnSize = 22,
    },
    -- Terminal: black + green, square, hacker look
    Terminal = {
        Flat = true, Theme = "Terminal", Square = true, Font = Enum.Font.Code, Checkbox = true,
        NoGlow = true, NoOrbs = true, NoSnow = true, NoBlur = true, NoDim = true, HideTag = true,
        Top = 26, TabBar = 24, TitleSize = 13, BtnSize = 18,
    },
    -- Soft: very round and calm (keeps your theme colors, no glow / snow / blur)
    Soft = {
        RadiusMul = 1.7, NoGlow = true, NoOrbs = true, NoSnow = true, NoBlur = true,
    },
    -- Compact: slim title bar and tight corners (keeps your theme colors)
    Compact = {
        RadiusMul = 0.55, Top = 36, TitleSize = 15, BtnSize = 22,
    },
}
Library.Styles = Styles

function Library:GetStyles()
    local list = {}
    for name in pairs(Styles) do
        table.insert(list, name)
    end
    table.sort(list)
    return list
end

local function resolveStyle(c)
    if type(c.Styles) == "table" then
        for _, name in ipairs(Library:GetStyles()) do
            if c.Styles[name] == true then
                return name
            end
        end
    end
    if type(c.Style) == "string" and Styles[c.Style] then
        return c.Style
    end
    return nil
end

---------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------

local WHITE = Color3.new(1, 1, 1)

-- window style of the window that is being built (nil = the normal DH look)
local ActiveStyle = nil

local function styleFont(f)
    if ActiveStyle and ActiveStyle.Font and f then
        return ActiveStyle.Font
    end
    return f
end

local function create(className, props, children)
    local inst = Instance.new(className)
    local parent
    for k, v in pairs(props or {}) do
        if k == "Parent" then
            parent = v
        else
            if k == "Font" then
                v = styleFont(v)
            end
            inst[k] = v
        end
    end
    for _, child in ipairs(children or {}) do
        child.Parent = inst
    end
    if parent then
        inst.Parent = parent
    end
    return inst
end

local function tween(obj, props, time, style, dir)
    local tw = TweenService:Create(obj, TweenInfo.new(time or 0.25, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
    tw:Play()
    return tw
end

local function corner(r)
    r = r or 8
    if ActiveStyle then
        if ActiveStyle.Square then
            r = 0
        elseif ActiveStyle.Radius then
            r = math.min(r, ActiveStyle.Radius)
        elseif ActiveStyle.RadiusMul then
            r = r * ActiveStyle.RadiusMul
        end
    end
    return create("UICorner", {CornerRadius = UDim.new(0, r)})
end

local function round()
    if ActiveStyle then
        if ActiveStyle.Square then
            return create("UICorner", {CornerRadius = UDim.new(0, 0)})
        elseif ActiveStyle.Radius then
            return create("UICorner", {CornerRadius = UDim.new(0, ActiveStyle.Radius)})
        end
    end
    return create("UICorner", {CornerRadius = UDim.new(1, 0)})
end

local function safeCall(cb, ...)
    if type(cb) == "function" then
        local ok, err = pcall(cb, ...)
        if not ok then
            warn("[DH UI] " .. tostring(err))
        end
    end
end

local function getGuiParent()
    if gethui then
        local ok, hui = pcall(gethui)
        if ok and hui then
            return hui
        end
    end
    local ok = pcall(function() return CoreGui.Name end)
    if ok then
        return CoreGui
    end
    return Players.LocalPlayer:WaitForChild("PlayerGui")
end

local function pointer(input)
    return Vector2.new(input.Position.X, input.Position.Y) + GuiService:GetGuiInset()
end

local function isPress(input)
    return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
end

local function isMove(input)
    return input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch
end

local function textWidth(text, size, font)
    return TextService:GetTextSize(text, size, styleFont(font or Enum.Font.GothamMedium), Vector2.new(1000, 100)).X
end

local function textHeight(text, size, font, width)
    if text == nil or text == "" then
        return 0
    end
    return TextService:GetTextSize(text, size, styleFont(font or Enum.Font.Gotham), Vector2.new(width, 2000)).Y
end

local function ser(v)
    local t = typeof(v)
    if t == "Color3" then
        return {__t = "c", r = v.R, g = v.G, b = v.B}
    elseif t == "EnumItem" then
        return {__t = "e", n = v.Name}
    end
    return v
end

local function deser(v)
    if type(v) == "table" and v.__t == "c" then
        return Color3.new(v.r, v.g, v.b)
    elseif type(v) == "table" and v.__t == "e" then
        return Enum.KeyCode[v.n]
    end
    return v
end

local function decimalsOf(inc)
    local d = tostring(inc):match("%.(%d+)")
    return d and math.min(#d, 4) or 0
end


-- Real blur: BlurEffect + DepthOfField (focus distance 0 blurs the whole world)
local function newBackdropFx(name)
    local fx = {}
    fx.blur = Instance.new("BlurEffect")
    fx.blur.Name = name .. "_Blur"
    fx.blur.Size = 0
    fx.blur.Enabled = false
    fx.dof = Instance.new("DepthOfFieldEffect")
    fx.dof.Name = name .. "_DoF"
    fx.dof.FarIntensity = 0
    fx.dof.NearIntensity = 0
    fx.dof.FocusDistance = 0
    fx.dof.InFocusRadius = 0
    fx.dof.Enabled = false
    local function attach()
        pcall(function()
            fx.blur.Parent = Lighting
            fx.dof.Parent = Lighting
        end)
    end
    attach()
    function fx.apply(alpha, size, on)
        local enabled = on and alpha > 0.01
        if enabled and (fx.blur.Parent == nil or fx.dof.Parent == nil) then
            attach()
        end
        fx.blur.Enabled = enabled
        fx.blur.Size = size * alpha
        fx.dof.Enabled = enabled
        fx.dof.FarIntensity = alpha
    end
    function fx.destroy()
        pcall(function()
            fx.blur:Destroy()
            fx.dof:Destroy()
        end)
    end
    return fx
end


-- Colored glow made of stacked rounded frames (an image tint cannot recolor a black shadow image)
local function newGlow(parent, spread, layers, radius, color)
    local g = {layers = {}}
    g.holder = Instance.new("Frame")
    g.holder.Name = "Glow"
    g.holder.BackgroundTransparency = 1
    g.holder.BorderSizePixel = 0
    g.holder.Size = UDim2.fromScale(1, 1)
    g.holder.Parent = parent
    for i = 1, layers do
        local k = spread * (layers - i + 1) / layers
        local f = Instance.new("Frame")
        f.AnchorPoint = Vector2.new(0.5, 0.5)
        f.Position = UDim2.fromScale(0.5, 0.5)
        f.Size = UDim2.new(1, k * 2, 1, k * 2)
        f.BackgroundColor3 = color or Color3.new(0, 0, 0)
        f.BackgroundTransparency = 1
        f.BorderSizePixel = 0
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, radius + k)
        c.Parent = f
        f.Parent = g.holder
        g.layers[i] = {f = f, w = (i / layers) ^ 2.4}
    end
    function g.apply(strength)
        for _, l in ipairs(g.layers) do
            l.f.BackgroundTransparency = 1 - math.clamp(strength * 0.13 * l.w, 0, 1)
        end
    end
    function g.setColor(c, animate)
        for _, l in ipairs(g.layers) do
            if animate then
                TweenService:Create(l.f, TweenInfo.new(0.4), {BackgroundColor3 = c}):Play()
            else
                l.f.BackgroundColor3 = c
            end
        end
    end
    return g
end

---------------------------------------------------------------------
-- Snow field factory (used by the window, the whole screen, the round
-- toggle button and the loader)
---------------------------------------------------------------------

local function newSnowField(parent, w, h, layers)
    local field = {w = w, h = h, flakes = {}, wind = 0}
    for _, L in ipairs(layers) do
        for _ = 1, L.count do
            local size = L.minS + math.random() * (L.maxS - L.minS)
            local depth = (size - L.minS) / (L.maxS - L.minS + 0.001)
            local fr = create("Frame", {
                Size = UDim2.fromOffset(size, size),
                BackgroundColor3 = Theme.Snow,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Parent = parent,
            }, {round()})
            field.flakes[#field.flakes + 1] = {
                f = fr, on = true,
                x = math.random() * w, y = math.random() * h, size = size,
                base = L.minT + math.random() * (L.maxT - L.minT),
                depth = 0.35 + depth * 0.65,
                speed = (L.speed or 30) * (0.7 + size * 0.1) * (0.85 + math.random() * 0.3),
                drift = (math.random() - 0.5) * 8,
                amp = 5 + math.random() * 14,
                freq = 0.6 + math.random() * 1.4,
                ph = math.random() * 6.28,
                twinkle = math.random() < 0.25,
            }
        end
    end
    return field
end

local function stepSnowField(field, dt, t, windTarget, mx, my, fade)
    field.wind = field.wind + (windTarget - field.wind) * (1 - math.exp(-dt * 3))
    local w, h, wind = field.w, field.h, field.wind
    for _, s in ipairs(field.flakes) do
        if s.on then
            local x = s.x + (s.drift + wind * s.depth + math.sin(t * s.freq + s.ph) * s.amp) * dt
            local y = s.y + s.speed * dt
            if mx then
                local dx, dy = x - mx, y - my
                local d2 = dx * dx + dy * dy
                if d2 < 8100 and d2 > 1 then
                    local d = math.sqrt(d2)
                    local push = (90 - d) / 90 * 90 * dt
                    x = x + dx / d * push
                    y = y + dy / d * push
                end
            end
            if y > h + 10 then
                y = -10
                x = math.random() * w
            end
            if x > w + 12 then
                x = -12
            elseif x < -12 then
                x = w + 12
            end
            s.x, s.y = x, y
            s.f.Position = UDim2.fromOffset(x, y)
            local tr = s.base
            if s.twinkle then
                tr = tr + math.sin(t * 2.2 + s.ph) * 0.12
            end
            s.f.BackgroundTransparency = math.clamp(1 - (1 - tr) * fade, 0, 1)
        end
    end
end

---------------------------------------------------------------------
-- Window
---------------------------------------------------------------------

function Library:CreateWindow(userCfg)
    local cfg = {}
    for k, v in pairs(userCfg or {}) do
        cfg[k] = v
    end
    local styleName = resolveStyle(cfg)
    local StyleDef = styleName and Styles[styleName] or nil
    ActiveStyle = StyleDef
    if StyleDef then
        if StyleDef.NoSnow then
            cfg.Snow, cfg.ScreenSnow = false, false
        end
        if StyleDef.NoBlur then
            cfg.Blur = false
        end
        if StyleDef.NoDim then
            cfg.Dim = 0
        end
        if StyleDef.HideTag then
            cfg.Tag = false
        end
        if StyleDef.Theme and Themes[StyleDef.Theme] then
            cfg.Theme = StyleDef.Theme
        end
    end
    local startTheme = Themes[cfg.Theme or ""] and cfg.Theme or "Crimson"
    applyTheme(startTheme)

    local useLoader = cfg.Loader ~= false
    local Window = {
        Tabs = {}, Conns = {}, Hooks = {}, Updaters = {}, Setters = {},
        Minimized = false, Visible = not useLoader, Loading = useLoader,
        Active = nil, Destroyed = false, ThemeName = startTheme,
    }
    local updaters = Window.Updaters

    local W, H = cfg.Width or 680, cfg.Height or 460
    local TOP, FOOT = (StyleDef and StyleDef.Top) or 48, 46
    local TABBAR = (StyleDef and StyleDef.TabBar) or 0
    local Flat = (StyleDef and StyleDef.Flat) or false
    -- switches that the Information panel toggles control
    local UIFlags = {HighlightTabs = true, SpinBorder = true, Notifs = true}
    local title = cfg.Title or "DH"
    local logoText = cfg.LogoText or string.upper(string.sub(title, 1, 2))
    local toggleKey = cfg.ToggleKey or Enum.KeyCode.RightShift
    local folder = cfg.ConfigFolder or "DHUI"
    local ON_COLOR, OFF_COLOR = rgb(126, 240, 160), rgb(220, 20, 60)

    local function connect(signal, fn)
        local c = signal:Connect(fn)
        table.insert(Window.Conns, c)
        return c
    end

    -- theme binding -------------------------------------------------
    local function themed(fn)
        fn(false)
        table.insert(Window.Hooks, fn)
    end

    local function bind(inst, prop, key)
        themed(function(animate)
            if animate then
                tween(inst, {[prop] = Theme[key]}, 0.4)
            else
                inst[prop] = Theme[key]
            end
        end)
    end

    local function bgSeq()
        return ColorSequence.new(Theme.Background, Theme.Background2)
    end

    local function accentSeq()
        return ColorSequence.new(Theme.Accent, Theme.Accent2)
    end

    local function borderSeq()
        return ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.Accent),
            ColorSequenceKeypoint.new(0.5, Theme.Accent2),
            ColorSequenceKeypoint.new(1, Theme.Accent),
        })
    end

    -- a color moved toward the text color (keeps strokes / bars visible on pure black themes)
    local function lift(c, a)
        return c:Lerp(Theme.Text, a)
    end

    local function accentGrad(parent, rotation)
        local g = create("UIGradient", {Color = accentSeq(), Rotation = rotation or 0, Parent = parent})
        themed(function()
            g.Color = accentSeq()
        end)
        return g
    end

    local function label(parent, text, props, key)
        local l = create("TextLabel", {
            BackgroundTransparency = 1,
            Text = text,
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextColor3 = Theme[key or "Text"],
            Parent = parent,
        })
        for k, v in pairs(props or {}) do
            if k == "Font" then
                v = styleFont(v)
            end
            l[k] = v
        end
        bind(l, "TextColor3", key or "Text")
        return l
    end

    local function snowField(parent, w, h, layers)
        local fld = newSnowField(parent, w, h, layers)
        themed(function()
            for _, s in ipairs(fld.flakes) do
                s.f.BackgroundColor3 = Theme.Snow
            end
        end)
        return fld
    end

    -- screen / state --------------------------------------------------
    local gui = create("ScreenGui", {
        Name = cfg.Name or "DHUI",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999,
    })
    if syn and syn.protect_gui then
        pcall(syn.protect_gui, gui)
    end
    gui.Parent = getGuiParent()

    local function screenSize()
        local s = gui.AbsoluteSize
        if s.X < 100 or s.Y < 100 then
            local cam = workspace.CurrentCamera
            return cam and cam.ViewportSize or Vector2.new(1280, 720)
        end
        return s
    end

    local scr = screenSize()
    local posX, posY = (scr.X - W) / 2, (scr.Y - H) / 2
    local tgtX, tgtY = posX, posY
    local slideVal = Instance.new("NumberValue")   -- drives the window slide (time based, so it matches the fade exactly)
    slideVal.Value = 36
    local slide = 36
    local windowOn = not useLoader                -- true while the window itself is shown / showing (drives the glow)
    if not useLoader then
        tween(slideVal, {Value = 0}, 0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    end

    local function clampTarget(x, y)
        local s = screenSize()
        return math.clamp(x, 90 - W, s.X - 90), math.clamp(y, 0, s.Y - 60)
    end

    ---------------------------------------------------------------------
    -- Backdrop: dim + blur + screen-wide snow (only while the GUI is open)
    ---------------------------------------------------------------------
    local backdrop, backdropTarget = 0, useLoader and 0 or 1
    local dimAlpha = cfg.Dim or 0.45
    local blurSize = cfg.BlurSize or 40
    local blurOn = cfg.Blur ~= false
    local screenSnowOn = cfg.ScreenSnow ~= false

    local dim = create("Frame", {
        Name = "Dim", Size = UDim2.fromScale(1, 1), BackgroundColor3 = Theme.Dim,
        BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false, ZIndex = 1, Parent = gui,
    })
    bind(dim, "BackgroundColor3", "Dim")

    local screenHolder = create("Frame", {
        Name = "ScreenSnow", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
        Visible = false, ZIndex = 2, Parent = gui,
    })
    local sf = cfg.ScreenSnowCount or 1
    local screenField = snowField(screenHolder, scr.X, scr.Y, {
        {count = math.floor(55 * sf), minS = 1.5, maxS = 3, minT = 0.55, maxT = 0.85, speed = 26},
        {count = math.floor(45 * sf), minS = 2.5, maxS = 5, minT = 0.4, maxT = 0.75, speed = 46},
        {count = math.floor(18 * sf), minS = 6, maxS = 12, minT = 0.8, maxT = 0.93, speed = 90},
    })

    local bdFx = newBackdropFx(cfg.Name or "DHUI")

    -- root / main -----------------------------------------------------
    local root = create("Frame", {
        Name = "Root",
        Size = UDim2.fromOffset(W, H),
        Position = UDim2.fromOffset(posX, posY + 36),
        BackgroundTransparency = 1,
        Visible = not useLoader,
        ZIndex = 3,
        Parent = gui,
    })

    -- themed outer glow: black theme = black glow, crimson = crimson glow, violet = violet glow
    local dropFx = newGlow(root, 36, 10, 12, Color3.new(0, 0, 0))
    dropFx.holder.Position = UDim2.fromOffset(0, 14)
    local glowFx = newGlow(root, 46, 14, 12, Theme.Halo)
    themed(function(animate)
        glowFx.setColor(Theme.Halo, animate)
    end)
    local glowVis = 1
    local glowMul = (StyleDef and StyleDef.NoGlow) and 0 or 1

    local main = create("Frame", {
        Name = "Main",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = WHITE,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = root,
    }, {corner(12)})
    local bgGrad = create("UIGradient", {Color = bgSeq(), Rotation = 62, Parent = main})
    themed(function()
        bgGrad.Color = bgSeq()
    end)

    local borderStroke = create("UIStroke", {
        Color = WHITE, Thickness = 1.5, Transparency = 0.2,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = main,
    })
    local borderGrad = create("UIGradient", {Color = borderSeq(), Parent = borderStroke})
    themed(function()
        borderGrad.Color = borderSeq()
    end)

    -- slow drifting aurora orbs behind everything
    local orbs = {}
    local orbSpecs = {
        {size = 280, x = 0.12, y = 0.22, sx = 0.35, sy = 0.27, key = "Glow"},
        {size = 240, x = 0.86, y = 0.78, sx = 0.28, sy = 0.33, key = "Glow2"},
        {size = 190, x = 0.55, y = 0.08, sx = 0.41, sy = 0.23, key = "Glow"},
    }
    for i, spec in ipairs((StyleDef and StyleDef.NoOrbs) and {} or orbSpecs) do
        local orb = create("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(spec.x, spec.y),
            Size = UDim2.fromOffset(spec.size, spec.size), BackgroundColor3 = WHITE,
            BorderSizePixel = 0, ZIndex = 1, Parent = main,
        }, {round()})
        local og = create("UIGradient", {
            Rotation = 45 + i * 40,
            Color = ColorSequence.new(Theme[spec.key], Theme.Accent2),
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.84),
                NumberSequenceKeypoint.new(1, 1),
            }),
            Parent = orb,
        })
        themed(function()
            og.Color = ColorSequence.new(Theme[spec.key], Theme.Accent2)
        end)
        orbs[i] = {f = orb, spec = spec}
    end

    -- fade cover used for show / hide
    local cover = create("Frame", {
        Size = UDim2.fromScale(1, 1), BackgroundColor3 = Theme.Background, BackgroundTransparency = 1,
        BorderSizePixel = 0, Visible = false, ZIndex = 100, Parent = main,
    }, {corner(12)})
    bind(cover, "BackgroundColor3", "Background")

    ---------------------------------------------------------------------
    -- Snow inside the window (back = big and soft, front = small and crisp)
    ---------------------------------------------------------------------
    local snowCfg = type(cfg.Snow) == "table" and cfg.Snow or {}
    local snowBuilt = cfg.Snow ~= false
    local snowOn = snowBuilt and snowCfg.Enabled ~= false
    local snowFields, snowHolders = {}, {}
    local toggleSnowHolder

    if snowBuilt then
        local total = snowCfg.Count or 90
        local backHolder = create("Frame", {
            Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ClipsDescendants = true,
            ZIndex = 1, Visible = snowOn, Parent = main,
        })
        local frontHolder = create("Frame", {
            Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ClipsDescendants = true,
            ZIndex = 15, Visible = snowOn, Parent = main,
        })
        snowHolders = {backHolder, frontHolder}
        snowFields[1] = snowField(backHolder, W, H, {
            {count = math.floor(total * 0.45), minS = 3, maxS = 7, minT = 0.6, maxT = 0.88, speed = 24},
        })
        snowFields[2] = snowField(frontHolder, W, H, {
            {count = math.ceil(total * 0.55), minS = 1.6, maxS = 4, minT = 0.3, maxT = 0.7, speed = 34},
        })
    end

    function Window:SetSnow(on)
        if snowBuilt then
            snowOn = on and true or false
            for _, h in ipairs(snowHolders) do
                h.Visible = snowOn
            end
            if toggleSnowHolder then
                toggleSnowHolder.Visible = snowOn
            end
        end
    end

    function Window:SetSnowCount(n)
        local i = 0
        for _, fld in ipairs(snowFields) do
            for _, s in ipairs(fld.flakes) do
                i = i + 1
                s.on = i <= n
                s.f.Visible = s.on
            end
        end
    end

    function Window:SetScreenSnow(on)
        screenSnowOn = on and true or false
    end

    function Window:SetBlur(on)
        blurOn = on and true or false
    end

    function Window:SetBlurSize(n)
        blurSize = math.clamp(n, 0, 56)
    end

    function Window:SetDim(alpha)
        dimAlpha = math.clamp(alpha, 0, 1)
    end

    ---------------------------------------------------------------------
    -- Topbar: title, tag, tab button, minimize, close
    ---------------------------------------------------------------------
    local topbar = create("Frame", {
        Name = "Topbar",
        Size = UDim2.new(1, 0, 0, TOP),
        BackgroundColor3 = Theme.Topbar,
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = main,
    }, {corner(12)})
    bind(topbar, "BackgroundColor3", "Topbar")

    local topFiller = create("Frame", {
        Size = UDim2.new(1, 0, 0, 14), Position = UDim2.new(0, 0, 1, -14),
        BackgroundColor3 = Theme.Topbar, BorderSizePixel = 0, Parent = topbar,
    })
    bind(topFiller, "BackgroundColor3", "Topbar")

    -- title: heavy font with a shimmering gradient
    local titleLbl = create("TextLabel", {
        Position = UDim2.fromOffset(18, 0), Size = UDim2.new(0, 60, 1, 0),
        BackgroundTransparency = 1, Text = title, Font = Enum.Font.GothamBlack, TextSize = (StyleDef and StyleDef.TitleSize) or 18,
        TextColor3 = WHITE, TextXAlignment = Enum.TextXAlignment.Left, Parent = topbar,
    })
    local function titleSeq()
        return ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.Text),
            ColorSequenceKeypoint.new(0.5, Theme.Accent),
            ColorSequenceKeypoint.new(1, Theme.Accent2),
        })
    end
    local titleGrad = create("UIGradient", {Color = titleSeq(), Parent = titleLbl})
    themed(function()
        titleGrad.Color = titleSeq()
    end)

    -- tag: gradient pill with a pulsing dot and a shine that sweeps across it
    local tagPill, tagDot, tagShine
    if cfg.Tag ~= false and cfg.Subtitle ~= false then
        local tagText = cfg.Tag or cfg.Subtitle or ("v" .. Library.Version)
        local tgw = textWidth(tagText, 10, Enum.Font.GothamBlack) + 36
        tagPill = create("Frame", {
            Size = UDim2.fromOffset(tgw, 22), BackgroundColor3 = WHITE, BorderSizePixel = 0,
            ClipsDescendants = true, Parent = topbar,
        }, {round()})
        accentGrad(tagPill, 0)
        create("UIStroke", {
            Color = WHITE, Thickness = 1, Transparency = 0.7,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = tagPill,
        })
        tagDot = create("Frame", {
            AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 10, 0.5, 0),
            Size = UDim2.fromOffset(6, 6), BackgroundColor3 = Theme.OnAccent, BorderSizePixel = 0, Parent = tagPill,
        }, {round()})
        bind(tagDot, "BackgroundColor3", "OnAccent")
        label(tagPill, tagText, {
            Position = UDim2.fromOffset(22, 0), Size = UDim2.new(1, -26, 1, 0),
            Font = Enum.Font.GothamBlack, TextSize = 10,
        }, "OnAccent")
        tagShine = create("Frame", {
            AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(-0.7, 0, 0.5, 0), Size = UDim2.new(0, 22, 1.8, 0),
            Rotation = 20, BackgroundColor3 = WHITE, BorderSizePixel = 0, Parent = tagPill,
        }, {round()})
        create("UIGradient", {
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0.35), NumberSequenceKeypoint.new(1, 1),
            }),
            Parent = tagShine,
        })
    end

    local function layoutTop()
        local tw = math.min(130, textWidth(titleLbl.Text, (StyleDef and StyleDef.TitleSize) or 18, Enum.Font.GothamBlack))
        titleLbl.Size = UDim2.new(0, tw + 4, 1, 0)
        if tagPill then
            tagPill.Position = UDim2.fromOffset(18 + tw + 12, 13)
        end
    end
    layoutTop()

    -- center tab button (shows the current tab and its position, e.g. 2/6) ----
    local tabBtn = create("TextButton", {
        Name = "TabButton",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 40, 0.5, 0),
        Size = UDim2.fromOffset(214, 32),
        BackgroundColor3 = Theme.Element,
        Text = "", AutoButtonColor = false, Parent = topbar,
    }, {corner(8)})
    bind(tabBtn, "BackgroundColor3", "Element")
    local tabBtnStroke = create("UIStroke", {Color = Theme.Stroke, Transparency = 0.15, Parent = tabBtn})
    bind(tabBtnStroke, "Color", "Stroke")
    for i = 0, 2 do
        local bar = create("Frame", {
            Position = UDim2.fromOffset(13, 11 + i * 4), Size = UDim2.fromOffset(i == 1 and 9 or 13, 2),
            BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Parent = tabBtn,
        }, {round()})
        bind(bar, "BackgroundColor3", "Accent")
    end
    local tabBtnLbl = label(tabBtn, "Tabs", {
        Position = UDim2.fromOffset(36, 0), Size = UDim2.new(1, -106, 1, 0),
        Font = Enum.Font.GothamBold, TextSize = 12, TextTruncate = Enum.TextTruncate.AtEnd,
    })
    local tabCountPill = create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -30, 0.5, 0), Size = UDim2.fromOffset(34, 18),
        BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.86, BorderSizePixel = 0, Parent = tabBtn,
    }, {round()})
    bind(tabCountPill, "BackgroundColor3", "Accent")
    local tabCountLbl = label(tabCountPill, "0/0", {
        Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center, Font = Enum.Font.Code, TextSize = 10,
    }, "Accent")
    local chevron = label(tabBtn, ">", {
        Position = UDim2.new(1, -26, 0, 0), Size = UDim2.fromOffset(18, 32),
        TextXAlignment = Enum.TextXAlignment.Center, Font = Enum.Font.GothamBold, Rotation = 90,
    }, "Accent")

    -- minimize / close ---------------------------------------------------
    local BS = (StyleDef and StyleDef.BtnSize) or 28
    local function topBtn(xOff, hoverColor)
        local b = create("TextButton", {
            Size = UDim2.fromOffset(BS, BS), Position = UDim2.new(1, xOff, 0.5, -BS / 2),
            BackgroundColor3 = Theme.Element, Text = "", AutoButtonColor = false, Parent = topbar,
        }, {corner(8)})
        bind(b, "BackgroundColor3", "Element")
        connect(b.MouseEnter, function()
            tween(b, {BackgroundColor3 = Theme[hoverColor]}, 0.15)
        end)
        connect(b.MouseLeave, function()
            tween(b, {BackgroundColor3 = Theme.Element}, 0.2)
        end)
        return b
    end

    local closeBtn = topBtn(StyleDef and -(BS + 8) or -40, "Error")
    local minBtn = topBtn(StyleDef and -(2 * BS + 12) or -74, "Warning")
    if TABBAR > 0 then
        tabBtn.Visible = false   -- styles with a tab row do not use the tab menu button
    end

    for _, rot in ipairs({45, -45}) do
        create("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(12, 2), Rotation = rot,
            BackgroundColor3 = WHITE, BorderSizePixel = 0, Parent = closeBtn,
        }, {round()})
    end
    local minLine = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(11, 2), BackgroundColor3 = WHITE, BorderSizePixel = 0, Parent = minBtn,
    }, {round()})

    -- animated accent line under the topbar
    local line = create("Frame", {
        Size = UDim2.new(1, 0, 0, 1), Position = UDim2.fromOffset(0, TOP),
        BackgroundColor3 = WHITE, BorderSizePixel = 0, ZIndex = 4, Parent = main,
    }, {round()})
    local lineGrad = accentGrad(line, 0)
    local tabBar
    if Flat then
        lineGrad.Enabled = false
        bind(line, "BackgroundColor3", "Stroke")
        -- thin accent line across the very top of the window
        local topAccent = create("Frame", {
            Size = UDim2.new(1, 0, 0, 2), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, ZIndex = 6, Parent = main,
        })
        bind(topAccent, "BackgroundColor3", "Accent")
        borderGrad.Enabled = false
        borderStroke.Transparency = 0
        bind(borderStroke, "Color", "Stroke")
    end
    if TABBAR > 0 then
        tabBar = create("Frame", {
            Name = "TabBar", Position = UDim2.fromOffset(0, TOP + 1), Size = UDim2.new(1, 0, 0, TABBAR),
            BackgroundTransparency = 1, ZIndex = 4, Parent = main,
        }, {
            create("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4),
                SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center,
            }),
            create("UIPadding", {PaddingLeft = UDim.new(0, 8)}),
        })
        local tabLine = create("Frame", {
            Position = UDim2.fromOffset(0, TOP + TABBAR), Size = UDim2.new(1, 0, 0, 1),
            BackgroundColor3 = Theme.Stroke, BorderSizePixel = 0, ZIndex = 4, Parent = main,
        })
        bind(tabLine, "BackgroundColor3", "Stroke")
    end

    -- smooth window dragging (target position, eased every frame)
    do
        local dragging, grabX, grabY = false, 0, 0
        connect(topbar.InputBegan, function(input)
            if isPress(input) then
                dragging = true
                local p = pointer(input)
                grabX, grabY = p.X - tgtX, p.Y - tgtY
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        connect(UserInputService.InputChanged, function(input)
            if dragging and isMove(input) then
                local p = pointer(input)
                tgtX, tgtY = clampTarget(p.X - grabX, p.Y - grabY)
            end
        end)
    end

    ---------------------------------------------------------------------
    -- Body + dashboard (left side) + page area
    ---------------------------------------------------------------------
    local body = create("Frame", {
        Name = "Body",
        Position = UDim2.fromOffset(0, TOP + 1 + TABBAR),
        Size = UDim2.new(1, 0, 1, -(TOP + 1 + TABBAR)),
        BackgroundTransparency = 1,
        ZIndex = 2,
        Parent = main,
    })
    local pageArea = create("Frame", {
        Position = UDim2.fromOffset(10, 10),
        Size = UDim2.new(1, -20, 1, -20),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = body,
    })

    local function copyText(text)
        local fn = setclipboard or toclipboard or (syn and syn.write_clipboard)
        if fn then
            return (pcall(fn, tostring(text)))
        end
        return false
    end

    local lp = Players.LocalPlayer
    local dispName = lp and lp.DisplayName or "Player"
    local userName = lp and lp.Name or "unknown"
    local userId = lp and lp.UserId or 0

    -- The Dashboard tab is one full-size Information panel
    local dashPage = create("CanvasGroup", {
        Name = "DashboardPage", Position = UDim2.fromOffset(10, 10), Size = UDim2.new(1, -20, 1, -20),
        BackgroundTransparency = 1, GroupTransparency = 1, Visible = false, Parent = body,
    }, {
        create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder,
        }),
        create("UIPadding", {
            PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 2), PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 2),
        }),
    })

    local function makePanel(name, size, order)
        local pnl = create("ScrollingFrame", {
            Name = name, Size = size, LayoutOrder = order,
            BackgroundColor3 = Theme.Section, BackgroundTransparency = 0, BorderSizePixel = 0,
            ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.Accent, CanvasSize = UDim2.new(),
            AutomaticCanvasSize = Enum.AutomaticSize.Y, ClipsDescendants = true, Parent = dashPage,
        }, {
            corner(10),
            create("UIListLayout", {Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder}),
            create("UIPadding", {
                PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
                PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10),
            }),
        })
        bind(pnl, "BackgroundColor3", "Section")
        bind(pnl, "ScrollBarImageColor3", "Accent")
        local pst = create("UIStroke", {Color = Theme.Stroke, Transparency = 0.25, Parent = pnl})
        bind(pst, "Color", "Stroke")
        create("UIGradient", {Color = ColorSequence.new(WHITE, rgb(218, 218, 232)), Rotation = 90, Parent = pnl})
        return pnl
    end

    local dash = makePanel("Information", UDim2.new(1, 0, 1, 0), 1)

    local dashShown
    local function setDashboard(show, animate)
        if cfg.Dashboard == false then
            show = false
        end
        if show == dashShown then
            return
        end
        dashShown = show
        if show then
            dashPage.Visible = true
            if animate then
                dashPage.Position = UDim2.fromOffset(10, 26)
                dashPage.GroupTransparency = 1
                tween(dashPage, {GroupTransparency = 0, Position = UDim2.fromOffset(10, 10)}, 0.42)
            else
                dashPage.Position = UDim2.fromOffset(10, 10)
                dashPage.GroupTransparency = 0
            end
        else
            local t = tween(dashPage, {GroupTransparency = 1}, 0.15)
            t.Completed:Connect(function()
                if not dashShown then
                    dashPage.Visible = false
                end
            end)
        end
    end
    local dashTabName = type(cfg.Dashboard) == "string" and cfg.Dashboard or "Dashboard"

    local dashOrder = 0
    local function dashNext()
        dashOrder = dashOrder + 1
        return dashOrder
    end

    local function dashCard(height, parent, width, woff)
        local f = create("Frame", {
            Size = UDim2.new(width or 1, woff or 0, 0, height), BackgroundColor3 = Theme.Element, BorderSizePixel = 0,
            ClipsDescendants = true, LayoutOrder = dashNext(), Parent = parent or dash,
        }, {corner(8)})
        bind(f, "BackgroundColor3", "Element")
        local st = create("UIStroke", {Color = Theme.Stroke, Transparency = 0.45, Parent = f})
        bind(st, "Color", "Stroke")
        create("UIGradient", {Color = ColorSequence.new(WHITE, rgb(206, 206, 218)), Rotation = 90, Parent = f})
        return f
    end

    local function dashRow(parent, y, key, value, copyable, fullValue)
        local row = create("TextButton", {
            Position = UDim2.new(0, 8, 0, y), Size = UDim2.new(1, -16, 0, 24), BackgroundColor3 = Theme.Background,
            Text = "", AutoButtonColor = false, Parent = parent,
        }, {corner(6)})
        bind(row, "BackgroundColor3", "Background")
        label(row, key, {
            Position = UDim2.fromOffset(8, 0), Size = UDim2.new(0.4, 0, 1, 0), Font = Enum.Font.GothamBold, TextSize = 9,
        }, "SubText")
        local v = label(row, tostring(value), {
            Position = UDim2.new(0.3, 0, 0, 0), Size = UDim2.new(0.7, -8, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Right, Font = Enum.Font.Code, TextSize = 11,
            TextTruncate = Enum.TextTruncate.AtEnd,
        }, "Accent")
        if copyable then
            connect(row.MouseEnter, function()
                tween(row, {BackgroundColor3 = Theme.ElementHover}, 0.15)
            end)
            connect(row.MouseLeave, function()
                tween(row, {BackgroundColor3 = Theme.Background}, 0.2)
            end)
            connect(row.MouseButton1Click, function()
                local full = fullValue or v.Text
                local ok = copyText(full)
                Window:Notify({
                    Title = ok and "Copied" or "Could not copy",
                    Content = key .. "  " .. tostring(full), Duration = 2.5, Type = ok and "Success" or "Error",
                })
            end)
        end
        return v
    end

    local function panelHeader(panel, text, right)
        local h = create("Frame", {Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, LayoutOrder = dashNext(), Parent = panel})
        local hb = create("Frame", {
            Position = UDim2.fromOffset(0, 2), Size = UDim2.fromOffset(3, 12), BackgroundColor3 = WHITE,
            BorderSizePixel = 0, Parent = h,
        }, {round()})
        accentGrad(hb, 90)
        label(h, text, {
            Position = UDim2.fromOffset(11, 0), Size = UDim2.new(1, -11, 1, 0), Font = Enum.Font.GothamBold, TextSize = 11,
        }, "Accent")
        if right then
            label(h, right, {
                Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Right, Font = Enum.Font.Code, TextSize = 10,
            }, "SubText")
        end
        return h
    end
    panelHeader(dash, "INFORMATION", "DH UI v" .. Library.Version)

    -- player card: face, name, id
    local topRow = create("Frame", {
        Size = UDim2.new(1, 0, 0, 206), BackgroundTransparency = 1, LayoutOrder = dashNext(), Parent = dash,
    }, {create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder,
    })})
    local pCard = dashCard(206, topRow, 1 / 3, -7)
    local avHolder = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 12), Size = UDim2.fromOffset(70, 70),
        BackgroundTransparency = 1, Parent = pCard,
    })
    local avatar = create("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(60, 60),
        BackgroundColor3 = Theme.Stroke, BorderSizePixel = 0,
        Image = "rbxthumb://type=AvatarHeadShot&id=" .. userId .. "&w=150&h=150", Parent = avHolder,
    }, {round()})
    bind(avatar, "BackgroundColor3", "Stroke")
    local avRing = create("Frame", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Parent = avHolder,
    }, {round()})
    local avStroke = create("UIStroke", {
        Color = WHITE, Thickness = 2.5, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = avRing,
    })
    local avRingGrad = create("UIGradient", {Color = borderSeq(), Parent = avStroke})
    themed(function()
        avRingGrad.Color = borderSeq()
    end)
    local onlineDot = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 24, 0, 70), Size = UDim2.fromOffset(12, 12),
        BackgroundColor3 = ON_COLOR, BorderSizePixel = 0, ZIndex = 2, Parent = pCard,
    }, {round()})
    local onlineStroke = create("UIStroke", {Color = Theme.Element, Thickness = 2, Parent = onlineDot})
    bind(onlineStroke, "Color", "Element")
    label(pCard, dispName, {
        Position = UDim2.fromOffset(8, 88), Size = UDim2.new(1, -16, 0, 18), TextXAlignment = Enum.TextXAlignment.Center,
        Font = Enum.Font.GothamBold, TextSize = 13, TextTruncate = Enum.TextTruncate.AtEnd,
    })
    label(pCard, "@" .. userName, {
        Position = UDim2.fromOffset(8, 105), Size = UDim2.new(1, -16, 0, 14), TextXAlignment = Enum.TextXAlignment.Center,
        Font = Enum.Font.Code, TextSize = 10, TextTruncate = Enum.TextTruncate.AtEnd,
    }, "SubText")
    dashRow(pCard, 126, "USER ID", userId, true)
    dashRow(pCard, 156, "AGE", ((lp and lp.AccountAge) or 0) .. " days")

    do
    -- game card: image, name, place id, game id
    local gCard = dashCard(206, topRow, 1 / 3, -7)
    local gImg = create("ImageLabel", {
        Position = UDim2.fromOffset(8, 8), Size = UDim2.new(1, -16, 0, 88), BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0, ScaleType = Enum.ScaleType.Crop,
        Image = game.GameId ~= 0 and ("rbxthumb://type=GameIcon&id=" .. game.GameId .. "&w=150&h=150") or "",
        Parent = gCard,
    }, {corner(6)})
    bind(gImg, "BackgroundColor3", "Background")
    local gShade = create("Frame", {
        Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, Parent = gImg,
    }, {corner(6)})
    create("UIGradient", {Rotation = 90, Transparency = NumberSequence.new(0.92, 0.5), Parent = gShade})
    local gameNameLbl = label(gCard, game.Name, {
        Position = UDim2.fromOffset(10, 102), Size = UDim2.new(1, -20, 0, 32), TextWrapped = true,
        TextYAlignment = Enum.TextYAlignment.Top, Font = Enum.Font.GothamBold, TextSize = 12,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
    dashRow(gCard, 140, "PLACE ID", game.PlaceId, true)
    dashRow(gCard, 170, "GAME ID", game.GameId, true)
    task.spawn(function()
        local ok, info = pcall(function()
            return MarketplaceService:GetProductInfo(game.PlaceId)
        end)
        if ok and info and info.Name and gameNameLbl.Parent then
            gameNameLbl.Text = info.Name
        end
    end)

    -- server card: players, server age, job id, executor, device, country
    local vCard = dashCard(206, topRow, 1 / 3, -7)
    local plV = dashRow(vCard, 8, "PLAYERS", "--")
    local ageV = dashRow(vCard, 36, "SERVER AGE", "00:00:00")
    local jobFull = (game.JobId ~= "" and game.JobId) or "studio"
    dashRow(vCard, 64, "JOB ID", string.sub(jobFull, 1, 13), true, jobFull)
    local exName = "Unknown"
    pcall(function()
        exName = (identifyexecutor and identifyexecutor()) or "Unknown"
    end)
    dashRow(vCard, 92, "EXECUTOR", exName)
    local device = "PC"
    pcall(function()
        if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
            device = "Mobile"
        elseif UserInputService.GamepadEnabled and not UserInputService.KeyboardEnabled then
            device = "Console"
        end
    end)
    dashRow(vCard, 120, "DEVICE", device)
    local regV = dashRow(vCard, 148, "COUNTRY", "--")
    dashRow(vCard, 176, "SCRIPT", "DH UI v" .. Library.Version)
    task.spawn(function()
        local ok, code = pcall(function()
            return LocalizationService:GetCountryRegionForPlayerAsync(lp)
        end)
        if ok and code and regV.Parent then
            regV.Text = tostring(code)
        end
    end)
    do
        local acc2 = 0
        table.insert(updaters, function(dt)
            acc2 = acc2 + dt
            if acc2 < 0.5 then
                return
            end
            acc2 = 0
            pcall(function()
                plV.Text = #Players:GetPlayers() .. " / " .. Players.MaxPlayers
                local t = math.floor(workspace.DistributedGameTime)
                ageV.Text = string.format("%02d:%02d:%02d", t // 3600, (t % 3600) // 60, t % 60)
            end)
        end)
    end

    -- live stats: three big tiles (FPS / ping / session time)
    local statsRow = create("Frame", {
        Name = "StatsRow", Size = UDim2.new(1, 0, 0, 66), BackgroundTransparency = 1, LayoutOrder = dashNext(), Parent = dash,
    }, {create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder,
    })})
    local function statTile(caption, initial)
        local c = dashCard(66, statsRow, 1 / 3, -7)
        local val = label(c, initial, {
            Position = UDim2.fromOffset(0, 10), Size = UDim2.new(1, 0, 0, 28), TextXAlignment = Enum.TextXAlignment.Center,
            Font = Enum.Font.Code, TextSize = 22,
        }, "Accent")
        label(c, caption, {
            Position = UDim2.fromOffset(0, 42), Size = UDim2.new(1, 0, 0, 14), TextXAlignment = Enum.TextXAlignment.Center,
            Font = Enum.Font.GothamBold, TextSize = 9,
        }, "SubText")
        return val
    end
    local fpsV, pingV, sessV = statTile("FPS", "--"), statTile("PING", "--"), statTile("SESSION", "00:00:00")
    do
        local frames, acc, started = 0, 0, os.clock()
        table.insert(updaters, function(dt)
            frames = frames + 1
            acc = acc + dt
            if acc >= 0.5 then
                fpsV.Text = tostring(math.floor(frames / acc + 0.5))
                frames, acc = 0, 0
                local ping = "--"
                pcall(function()
                    ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValueString()
                end)
                pingV.Text = ping
                local t = math.floor(os.clock() - started)
                sessV.Text = string.format("%02d:%02d:%02d", t // 3600, (t % 3600) // 60, t % 60)
            end
        end)
    end

    end

    local hintLbl = label(dash, "", {
        Size = UDim2.new(1, 0, 0, 26), TextXAlignment = Enum.TextXAlignment.Center, TextWrapped = true,
        Font = Enum.Font.Code, TextSize = 10, LayoutOrder = 9999,
    }, "SubText")
    local function updateHint()
        hintLbl.Text = "[" .. toggleKey.Name .. "] hide / show"
    end
    updateHint()

    -- config files can restore the theme through the "UI_Theme" flag
    Window.Setters["UI_Theme"] = function(v)
        if Themes[v] and Window.ThemeName ~= v then
            Window:SetTheme(v)
        end
    end

    ---------------------------------------------------------------------
    -- Tab menu (popup under the center button)
    ---------------------------------------------------------------------
    local menuW = math.min(W - 40, 440)
    local menuHeight = 54
    local menuOpen = false

    local backdropBtn = create("TextButton", {
        Position = UDim2.fromOffset(0, TOP + 1), Size = UDim2.new(1, 0, 1, -(TOP + 1)),
        BackgroundTransparency = 1, Text = "", AutoButtonColor = false, Visible = false, ZIndex = 39, Parent = main,
    })

    local menu = create("CanvasGroup", {
        Name = "TabMenu",
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 40, 0, TOP + 8),
        Size = UDim2.fromOffset(menuW, 0),
        BackgroundColor3 = Theme.Topbar,
        BorderSizePixel = 0,
        GroupTransparency = 1,
        Visible = false,
        ZIndex = 40,
        Parent = main,
    }, {corner(10)})
    bind(menu, "BackgroundColor3", "Topbar")
    local menuStroke = create("UIStroke", {Color = Theme.Stroke, Transparency = 0.1, Parent = menu})
    bind(menuStroke, "Color", "Stroke")

    local function setMenu(open)
        menuOpen = open and true or false
        if menuOpen then
            menu.Visible = true
            backdropBtn.Visible = true
            tween(menu, {Size = UDim2.fromOffset(menuW, menuHeight), GroupTransparency = 0}, 0.34)
            tween(chevron, {Rotation = -90}, 0.32, Enum.EasingStyle.Back)
            tween(tabBtnStroke, {Color = Theme.Accent}, 0.2)
            for i, t in ipairs(Window.Tabs) do
                t.ChipScale.Scale = 0.6
                task.delay((i - 1) * 0.035, function()
                    if menuOpen then
                        tween(t.ChipScale, {Scale = 1}, 0.38, Enum.EasingStyle.Back)
                    end
                end)
            end
        else
            backdropBtn.Visible = false
            local t = tween(menu, {Size = UDim2.fromOffset(menuW, 0), GroupTransparency = 1}, 0.22)
            tween(chevron, {Rotation = 90}, 0.25)
            tween(tabBtnStroke, {Color = Theme.Stroke}, 0.25)
            t.Completed:Connect(function()
                if not menuOpen then
                    menu.Visible = false
                end
            end)
        end
    end
    connect(tabBtn.MouseButton1Click, function()
        setMenu(not menuOpen)
    end)
    connect(backdropBtn.MouseButton1Click, function()
        setMenu(false)
    end)
    connect(tabBtn.MouseEnter, function()
        tween(tabBtn, {BackgroundColor3 = Theme.ElementHover}, 0.15)
    end)
    connect(tabBtn.MouseLeave, function()
        tween(tabBtn, {BackgroundColor3 = Theme.Element}, 0.2)
    end)

    -- flow layout: chips fill the row, the next one wraps to a new row
    local function reflowTabs()
        if tabBar then
            return   -- the tab row lays itself out
        end
        local padX, padY, gap, rowH = 10, 10, 6, 30
        local inner = menuW - padX * 2
        local x, y = 0, 0
        for _, t in ipairs(Window.Tabs) do
            if x + t.ChipWidth > inner and x > 0 then
                x = 0
                y = y + rowH + gap
            end
            tween(t.Chip, {Position = UDim2.fromOffset(padX + x, padY + y)}, 0.32)
            x = x + t.ChipWidth + gap
        end
        menuHeight = padY * 2 + y + rowH
        if menuOpen then
            tween(menu, {Size = UDim2.fromOffset(menuW, menuHeight)}, 0.3)
        end
    end

    ---------------------------------------------------------------------
    -- Tooltips (any element with a Tooltip field)
    ---------------------------------------------------------------------
    local tipState = {text = nil, since = 0, shown = false}
    local tipFrame = create("Frame", {
        Size = UDim2.fromOffset(100, 24), BackgroundColor3 = Theme.Topbar, BackgroundTransparency = 1,
        BorderSizePixel = 0, Visible = false, ZIndex = 60, Parent = main,
    }, {corner(6)})
    bind(tipFrame, "BackgroundColor3", "Topbar")
    local tipStroke = create("UIStroke", {Color = Theme.Accent, Transparency = 0.4, Parent = tipFrame})
    bind(tipStroke, "Color", "Accent")
    local tipLbl = label(tipFrame, "", {
        Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center, TextSize = 11, TextTransparency = 1,
    })

    local function tipEnter(text)
        tipState.text = text
        tipState.since = os.clock()
    end
    local function tipLeave(text)
        if tipState.text == text then
            tipState.text = nil
        end
    end

    table.insert(updaters, function()
        if tipState.text and Window.Visible and os.clock() - tipState.since > 0.45 then
            if tipLbl.Text ~= tipState.text then
                tipLbl.Text = tipState.text
                tipFrame.Size = UDim2.fromOffset(textWidth(tipState.text, 11, Enum.Font.GothamMedium) + 22, 24)
            end
            local mp = UserInputService:GetMouseLocation()
            local org = main.AbsolutePosition
            local x = math.clamp(mp.X - org.X + 14, 6, W - tipFrame.Size.X.Offset - 6)
            local y = math.clamp(mp.Y - org.Y + 22, 6, H - 34)
            tipFrame.Position = UDim2.fromOffset(x, y)
            if not tipState.shown then
                tipState.shown = true
                tipFrame.Visible = true
                tween(tipFrame, {BackgroundTransparency = 0.05}, 0.18)
                tween(tipLbl, {TextTransparency = 0}, 0.18)
            end
        elseif tipState.shown then
            tipState.shown = false
            local t = tween(tipFrame, {BackgroundTransparency = 1}, 0.12)
            tween(tipLbl, {TextTransparency = 1}, 0.12)
            t.Completed:Connect(function()
                if not tipState.shown then
                    tipFrame.Visible = false
                end
            end)
        end
    end)

    ---------------------------------------------------------------------
    -- Minimize: the GUI turns into a small draggable button. Close / visibility.
    ---------------------------------------------------------------------
    local PH = 42
    local pillTitle = cfg.Title or "DH"
    local pillText = cfg.OpenText or ("Open " .. pillTitle)
    local PW = math.max(172, 58 + textWidth(pillText, 14, Enum.Font.GothamBold) + 46)
    local pillPos, pillTgt = Vector2.new(0, 0), Vector2.new(0, 0)
    local pillMoved = false

    local pillRoot = create("Frame", {
        Name = "MinimizedButton",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.fromOffset(PW, PH),
        Position = UDim2.fromOffset(0, 0),
        BackgroundTransparency = 1,
        Visible = false,
        ZIndex = 6,
        Parent = gui,
    })
    local pillScale = create("UIScale", {Scale = 1, Parent = pillRoot})

    -- shadow + themed glow behind the button
    local pillDropFx = newGlow(pillRoot, 26, 8, 14, Color3.new(0, 0, 0))
    pillDropFx.holder.Position = UDim2.fromOffset(0, 8)
    pillDropFx.apply(1.2)
    local pillGlowFx = newGlow(pillRoot, 28, 12, 14, Theme.Halo)
    themed(function(animate)
        pillGlowFx.setColor(Theme.Halo, animate)
    end)

    local pillBody = create("Frame", {
        Size = UDim2.fromScale(1, 1), BackgroundColor3 = WHITE, BorderSizePixel = 0,
        ClipsDescendants = true, Parent = pillRoot,
    }, {corner(14)})
    local pillBgGrad = create("UIGradient", {Color = bgSeq(), Rotation = 62, Parent = pillBody})
    themed(function()
        pillBgGrad.Color = bgSeq()
    end)
    local pillTint = create("Frame", {
        Size = UDim2.fromScale(1, 1), BackgroundColor3 = WHITE, BorderSizePixel = 0, Parent = pillBody,
    }, {corner(14)})
    local pillTintGrad = create("UIGradient", {
        Rotation = 20, Color = accentSeq(),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.55), NumberSequenceKeypoint.new(0.75, 1), NumberSequenceKeypoint.new(1, 1),
        }),
        Parent = pillTint,
    })
    themed(function()
        pillTintGrad.Color = accentSeq()
    end)

    -- bright logo capsule (gradient fill, monogram) so the button never looks empty
    local pLogo = create("Frame", {
        Position = UDim2.fromOffset(8, 7), Size = UDim2.fromOffset(28, 28), BackgroundColor3 = WHITE,
        BorderSizePixel = 0, Parent = pillBody,
    }, {corner(9)})
    local pLogoGrad = accentGrad(pLogo, 45)
    local pLogoTxt = create("TextLabel", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = logoText,
        Font = Enum.Font.GothamBlack, TextSize = 11, TextColor3 = Theme.OnAccent, Parent = pLogo,
    })
    bind(pLogoTxt, "TextColor3", "OnAccent")

    -- the name: "Open DEXPS" (solid color, always readable)
    local pTitle = label(pillBody, pillText, {
        Position = UDim2.fromOffset(46, 0), Size = UDim2.new(1, -78, 1, 0),
        Font = Enum.Font.GothamBold, TextSize = 14, TextTruncate = Enum.TextTruncate.AtEnd,
    })

    -- small "expand" icon
    local pOpen = create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -13, 0.5, 0), Size = UDim2.fromOffset(13, 13),
        BackgroundTransparency = 1, Parent = pillBody,
    }, {corner(3)})
    local pOpenStroke = create("UIStroke", {Color = Theme.Accent, Thickness = 1.8, Parent = pOpen})
    bind(pOpenStroke, "Color", "Accent")

    toggleSnowHolder = create("Frame", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = snowOn, Parent = pillBody,
    }, {corner(14)})
    local pillField
    if snowBuilt then
        pillField = snowField(toggleSnowHolder, PW, PH, {
            {count = 18, minS = 1.3, maxS = 3.2, minT = 0.35, maxT = 0.8, speed = 15},
        })
    end

    local pillRing = create("Frame", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, Parent = pillRoot,
    }, {corner(14)})
    local pillRingStroke = create("UIStroke", {
        Color = WHITE, Thickness = 2, Transparency = 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = pillRing,
    })
    local pRingGrad = create("UIGradient", {Color = borderSeq(), Parent = pillRingStroke})
    themed(function()
        pRingGrad.Color = borderSeq()
    end)

    local pillHit = create("TextButton", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", AutoButtonColor = false,
        ZIndex = 10, Parent = pillRoot,
    }, {corner(14)})

    -- Every show / hide step takes the same time, so the GUI and the toggle button
    -- always disappear in the same time and appear in the same time.
    local TRANS_T = 0.3

    local function showPill(state, done)
        if state then
            local s = screenSize()
            if not pillMoved then
                pillPos = Vector2.new(posX + W / 2 - PW / 2, posY + 10)
            end
            pillPos = Vector2.new(math.clamp(pillPos.X, 0, s.X - PW), math.clamp(pillPos.Y, 0, s.Y - PH))
            pillTgt = pillPos
            pillRoot.Position = UDim2.fromOffset(pillPos.X + PW / 2, pillPos.Y + PH / 2)
            pillScale.Scale = 0.001
            pillRoot.Visible = true
            tween(pillScale, {Scale = 1}, TRANS_T, Enum.EasingStyle.Back)
            task.delay(TRANS_T, function()
                if done then
                    done()
                end
            end)
        else
            if not pillRoot.Visible then
                if done then
                    done()
                end
                return
            end
            tween(pillScale, {Scale = 0.001}, TRANS_T, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
            task.delay(TRANS_T, function()
                pillRoot.Visible = false
                if done then
                    done()
                end
            end)
        end
    end

    do
        local dragging, moved, hovering = false, false, false
        local startP, grab = Vector2.new(), Vector2.new()
        connect(pillHit.MouseEnter, function()
            hovering = true
            tween(pillScale, {Scale = 1.06}, 0.2, Enum.EasingStyle.Back)
            tween(pillRingStroke, {Thickness = 3, Transparency = 0}, 0.15)
        end)
        connect(pillHit.MouseLeave, function()
            hovering = false
            tween(pillScale, {Scale = 1}, 0.2)
            tween(pillRingStroke, {Thickness = 2, Transparency = 0}, 0.2)
        end)
        connect(pillHit.InputBegan, function(input)
            if isPress(input) then
                dragging, moved = true, false
                startP = pointer(input)
                grab = startP - pillTgt
                tween(pillScale, {Scale = 0.95}, 0.12)
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                        tween(pillScale, {Scale = hovering and 1.06 or 1}, 0.25, Enum.EasingStyle.Back)
                        if not moved and not Window.Loading then
                            Window:SetVisible(true)
                        end
                    end
                end)
            end
        end)
        connect(UserInputService.InputChanged, function(input)
            if dragging and isMove(input) then
                local p = pointer(input)
                if (p - startP).Magnitude > 6 then
                    moved = true
                    pillMoved = true
                end
                if moved then
                    local s = screenSize()
                    local t = p - grab
                    pillTgt = Vector2.new(math.clamp(t.X, 0, s.X - PW), math.clamp(t.Y, 0, s.Y - PH))
                end
            end
        end)
    end

    -- Sequenced transition (one step at a time, never both at once):
    --   open : toggle button disappears  ->  GUI appears
    --   close: GUI disappears            ->  toggle button appears
    local transitionBusy = false
    local pendingState = nil

    local function openWindowAnim(done)
        windowOn = true
        backdropTarget = 1
        root.Visible = true
        slideVal.Value = 36
        tween(slideVal, {Value = 0}, TRANS_T, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        cover.Visible = true
        cover.BackgroundTransparency = 0
        tween(cover, {BackgroundTransparency = 1}, TRANS_T, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        task.delay(TRANS_T, function()
            cover.Visible = false
            done()
        end)
    end

    local function closeWindowAnim(done)
        setMenu(false)
        windowOn = false
        backdropTarget = 0
        tween(slideVal, {Value = 36}, TRANS_T, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        cover.Visible = true
        cover.BackgroundTransparency = 1
        tween(cover, {BackgroundTransparency = 0}, TRANS_T, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        task.delay(TRANS_T, function()
            root.Visible = false
            done()
        end)
    end

    function Window:SetVisible(state)
        state = state and true or false
        if Window.Loading or Window.Destroyed then
            return
        end
        if transitionBusy then
            pendingState = state   -- apply it right after the running transition finishes
            return
        end
        if Window.Visible == state then
            return
        end
        transitionBusy = true
        Window.Visible = state
        Window.Minimized = not state

        local function finish()
            transitionBusy = false
            if Window.Destroyed then
                return
            end
            if pendingState ~= nil then
                local p = pendingState
                pendingState = nil
                if p ~= Window.Visible then
                    Window:SetVisible(p)
                end
            end
        end

        if state then
            showPill(false, function()           -- 1) toggle button disappears
                if Window.Destroyed then return end
                openWindowAnim(finish)           -- 2) GUI appears
            end)
        else
            closeWindowAnim(function()           -- 1) GUI disappears
                if Window.Destroyed then return end
                showPill(true, finish)           -- 2) toggle button appears
            end)
        end
    end

    function Window:Minimize()
        Window:SetVisible(false)
    end

    function Window:Restore()
        Window:SetVisible(true)
    end

    function Window:Toggle()
        local current = Window.Visible
        if pendingState ~= nil then
            current = pendingState
        end
        Window:SetVisible(not current)
    end

    connect(minBtn.MouseButton1Click, function()
        Window:Minimize()
    end)

    function Window:Destroy()
        if Window.Destroyed then
            return
        end
        Window.Destroyed = true
        safeCall(cfg.OnClose)
        for _, c in ipairs(Window.Conns) do
            c:Disconnect()
        end
        Window.Conns = {}
        bdFx.destroy()
        cover.Visible = true
        tween(cover, {BackgroundTransparency = 0}, 0.25)
        glowFx.apply(0)
        dropFx.apply(0)
        tween(dim, {BackgroundTransparency = 1}, 0.25)
        tween(root, {Position = UDim2.fromOffset(root.Position.X.Offset, root.Position.Y.Offset + 40)}, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        pillRoot.Visible = false
        task.delay(0.32, function()
            gui:Destroy()
        end)
    end
    connect(closeBtn.MouseButton1Click, function()
        Window:Destroy()
    end)

    connect(UserInputService.InputBegan, function(input, processed)
        if not processed and input.KeyCode == toggleKey and not Window.Loading then
            Window:Toggle()
        end
    end)

    ---------------------------------------------------------------------
    -- Window methods
    ---------------------------------------------------------------------
    function Window:SetToggleKey(key)
        toggleKey = key
        updateHint()
    end

    function Window:SetTitle(text)
        titleLbl.Text = text
        layoutTop()
    end

    function Window:SetTheme(name)
        if Themes[name] and applyTheme(name) then
            Window.ThemeName = name
            Library.Flags.UI_Theme = name
            for _, hook in ipairs(Window.Hooks) do
                pcall(hook, true)
            end
        end
    end

    ---------------------------------------------------------------------
    -- Notifications: plain black cards, a seconds countdown instead of a bar
    ---------------------------------------------------------------------
    local NW = 320
    local notifs = {}
    local MAXN = cfg.MaxNotifications or 5
    local notifHolder = create("Frame", {
        Name = "Notifications", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 8, Parent = gui,
    })

    do
    local NOTIF_COLORS = {Info = "Accent", Success = "Success", Warning = "Warning", Error = "Error"}

    local function notifRelayout()
        local y = 0
        for i = #notifs, 1, -1 do
            local n = notifs[i]
            n.y = y
            tween(n.wrap, {Position = UDim2.new(1, -18, 1, -(18 + y))}, 0.45, Enum.EasingStyle.Quint)
            y = y + n.h + 10
        end
    end

    local function dismissNotif(n)
        if n.closing then
            return
        end
        n.closing = true
        for i, v in ipairs(notifs) do
            if v == n then
                table.remove(notifs, i)
                break
            end
        end
        notifRelayout()
        local t = tween(n.card, {Position = UDim2.new(1.25, 0, 0, 0)}, 0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        tween(n.shadow, {ImageTransparency = 1}, 0.3)
        t.Completed:Connect(function()
            n.wrap:Destroy()
        end)
    end

    -- little icons drawn from bars (no font / image needed)
    local function drawGlyph(parent, kind, color)
        local function bar(w, h, x, y, rot)
            create("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, x, 0.5, y), Size = UDim2.fromOffset(w, h),
                Rotation = rot or 0, BackgroundColor3 = color, BorderSizePixel = 0, Parent = parent,
            }, {round()})
        end
        if kind == "Success" then
            bar(2, 6, -3, 1, -45)
            bar(2, 11, 2, 0, 45)
        elseif kind == "Warning" then
            bar(2, 8, 0, -2, 0)
            bar(2, 2, 0, 5, 0)
        elseif kind == "Error" then
            bar(2, 11, 0, 0, 45)
            bar(2, 11, 0, 0, -45)
        else
            bar(2, 2, 0, -5, 0)
            bar(2, 8, 0, 1, 0)
        end
    end

    -- Window:Notify({Title, Content, Duration = 4, Type = "Info" | "Success" | "Warning" | "Error", Persistent, Sticky})
    function Window:Notify(o)
        o = o or {}
        if UIFlags.Notifs == false then
            return {Dismiss = function() end, Update = function() end}
        end
        local kind = "Info"
        if type(o.Type) == "string" then
            local t = string.lower(o.Type)
            kind = (t == "success" and "Success") or (t == "warning" and "Warning") or (t == "error" and "Error") or "Info"
        end
        local tcolor = Theme[NOTIF_COLORS[kind]]
        local titleText = o.Title or (kind == "Info" and "Notification" or kind)
        local bodyText = o.Content or ""
        local dur = tonumber(o.Duration) or 4
        local textX = 52
        local textW = NW - textX - 54
        local textH = textHeight(bodyText, 12, Enum.Font.Gotham, textW)
        local h = math.max(66, 14 + 18 + (textH > 0 and (4 + textH) or 0) + 20)

        while #notifs >= MAXN do
            dismissNotif(notifs[1])
        end

        local n = {
            h = h, y = 0, t = 0, dur = dur, closing = false, shownNum = -1, badgeHover = false,
            persistent = o.Persistent == true or dur <= 0,
        }

        n.wrap = create("Frame", {
            AnchorPoint = Vector2.new(1, 1), Size = UDim2.fromOffset(NW, h),
            Position = UDim2.new(1, -18, 1, -18), BackgroundTransparency = 1, Parent = notifHolder,
        })
        n.shadow = create("ImageLabel", {
            BackgroundTransparency = 1, Image = "rbxassetid://6014261993", ImageColor3 = Color3.new(0, 0, 0),
            ImageTransparency = 0.35, ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(49, 49, 450, 450),
            Size = UDim2.new(1, 50, 1, 50), Position = UDim2.fromOffset(-25, -16), Parent = n.wrap,
        })
        local edgeCol = lift(Theme.Stroke, 0.22)
        n.card = create("Frame", {
            Size = UDim2.fromScale(1, 1), Position = UDim2.new(1.25, 0, 0, 0), BackgroundColor3 = Theme.Topbar,
            BorderSizePixel = 0, ClipsDescendants = true, Parent = n.wrap,
        }, {corner(12)})
        local card = n.card
        local cardStroke = create("UIStroke", {Color = edgeCol, Thickness = 1, Parent = card})
        create("UIGradient", {Color = ColorSequence.new(WHITE, rgb(208, 208, 218)), Rotation = 90, Parent = card})

        -- colored bar on the left, type icon, title + text
        create("Frame", {
            Position = UDim2.fromOffset(7, 10), Size = UDim2.new(0, 3, 1, -20), BackgroundColor3 = tcolor,
            BorderSizePixel = 0, Parent = card,
        }, {round()})
        local icon = create("Frame", {
            Position = UDim2.fromOffset(18, 13), Size = UDim2.fromOffset(26, 26), BackgroundColor3 = tcolor,
            BackgroundTransparency = 0.84, BorderSizePixel = 0, Parent = card,
        }, {round(), create("UIStroke", {Color = tcolor, Transparency = 0.55, Thickness = 1})})
        local iconScale = create("UIScale", {Scale = 0.01, Parent = icon})
        drawGlyph(icon, kind, tcolor)

        local hit = create("TextButton", {
            Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, Parent = card,
        })
        connect(hit.MouseButton1Click, function()
            if o.Sticky ~= true then
                dismissNotif(n)
            end
        end)
        connect(hit.MouseEnter, function()
            tween(cardStroke, {Color = tcolor}, 0.18)
        end)
        connect(hit.MouseLeave, function()
            tween(cardStroke, {Color = edgeCol}, 0.25)
        end)

        local titleLbl2 = create("TextLabel", {
            Position = UDim2.fromOffset(textX, 12), Size = UDim2.fromOffset(textW, 18), BackgroundTransparency = 1,
            Text = titleText, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = card,
        })
        local bodyLbl = create("TextLabel", {
            Position = UDim2.fromOffset(textX, 34), Size = UDim2.fromOffset(textW, math.max(textH, 14)), BackgroundTransparency = 1,
            Text = bodyText, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Theme.SubText,
            TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true, Parent = card,
        })

        -- time left: a thin bar along the bottom + the seconds badge (turns into an X on hover)
        if not n.persistent then
            local barTrack = create("Frame", {
                Position = UDim2.new(0, 14, 1, -7), Size = UDim2.new(1, -28, 0, 2), BackgroundColor3 = edgeCol,
                BackgroundTransparency = 0.5, BorderSizePixel = 0, Parent = card,
            }, {round()})
            n.fill = create("Frame", {
                Size = UDim2.fromScale(1, 1), BackgroundColor3 = tcolor, BorderSizePixel = 0, Parent = barTrack,
            }, {round()})
        end
        n.badge = create("TextButton", {
            AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.5, -2), Size = UDim2.fromOffset(28, 28),
            BackgroundColor3 = Theme.Element, Text = n.persistent and "x" or tostring(math.ceil(dur)),
            Font = Enum.Font.Code, TextSize = 13, TextColor3 = Theme.Text, AutoButtonColor = false, Parent = card,
        }, {round(), create("UIStroke", {Color = edgeCol, Thickness = 1})})
        n.badgeScale = create("UIScale", {Parent = n.badge})
        connect(n.badge.MouseEnter, function()
            n.badgeHover = true
            n.badge.Text = "x"
            tween(n.badge, {BackgroundColor3 = Theme.ElementHover}, 0.12)
        end)
        connect(n.badge.MouseLeave, function()
            n.badgeHover = false
            n.badge.Text = n.persistent and "x" or tostring(math.max(0, math.ceil(n.dur - n.t)))
            tween(n.badge, {BackgroundColor3 = Theme.Element}, 0.15)
        end)
        connect(n.badge.MouseButton1Click, function()
            dismissNotif(n)
        end)

        table.insert(notifs, n)
        notifRelayout()
        tween(card, {Position = UDim2.new(0, 0, 0, 0)}, 0.55, Enum.EasingStyle.Back)
        task.delay(0.18, function()
            if iconScale.Parent then
                tween(iconScale, {Scale = 1}, 0.4, Enum.EasingStyle.Back)
            end
        end)

        local handle = {}
        function handle:Dismiss()
            dismissNotif(n)
        end
        function handle:Update(u)
            u = u or {}
            if u.Title then
                titleLbl2.Text = u.Title
            end
            if u.Content then
                bodyLbl.Text = u.Content
            end
        end
        return handle
    end

    table.insert(updaters, function(dt)
        if #notifs == 0 then
            return
        end
        local mp = UserInputService:GetMouseLocation()
        for i = #notifs, 1, -1 do
            local n = notifs[i]
            if n and not n.closing and not n.persistent then
                local p, s = n.wrap.AbsolutePosition, n.wrap.AbsoluteSize
                local inside = mp.X >= p.X and mp.X <= p.X + s.X and mp.Y >= p.Y and mp.Y <= p.Y + s.Y
                if not inside then
                    n.t = n.t + dt
                end
                if n.fill then
                    n.fill.Size = UDim2.fromScale(math.clamp(1 - n.t / n.dur, 0, 1), 1)
                end
                local remain = math.max(0, math.ceil(n.dur - n.t))
                if remain ~= n.shownNum then
                    n.shownNum = remain
                    if not n.badgeHover then
                        n.badge.Text = tostring(remain)
                    end
                    n.badgeScale.Scale = 1.28
                    tween(n.badgeScale, {Scale = 1}, 0.35, Enum.EasingStyle.Back)
                end
                if n.t >= n.dur then
                    dismissNotif(n)
                end
            end
        end
    end)

    end

    ---------------------------------------------------------------------
    -- Config save / load
    ---------------------------------------------------------------------
    function Window:SaveConfig(name)
        local data = {}
        for flag, val in pairs(Library.Flags) do
            data[flag] = ser(val)
        end
        local ok = pcall(function()
            if makefolder and isfolder and not isfolder(folder) then
                makefolder(folder)
            end
            writefile(folder .. "/" .. (name or "default") .. ".json", HttpService:JSONEncode(data))
        end)
        return ok
    end

    function Window:LoadConfig(name)
        local ok, data = pcall(function()
            return HttpService:JSONDecode(readfile(folder .. "/" .. (name or "default") .. ".json"))
        end)
        if not ok or type(data) ~= "table" then
            return false
        end
        for flag, val in pairs(data) do
            local setter = Window.Setters[flag]
            if setter then
                pcall(setter, deser(val))
            end
        end
        return true
    end

    ---------------------------------------------------------------------
    -- Loader: logo, typewriter title, status
    -- messages, shining progress bar, rotating tips, snow
    ---------------------------------------------------------------------
    local loader

    local function startLoader()
        local LW, LH = 480, 306
        local D = cfg.LoadingTime or 2.8
        local statuses = cfg.LoadingStatus or {
            "Initializing core", "Loading themes", "Building interface", "Syncing settings", "Finishing touches",
        }
        local tips = cfg.LoadingTips or {
            "Drag the title bar to move the window",
            "Click a section title to collapse it",
            "Drag the round button anywhere you like",
            "Press the toggle key to hide or show the GUI",
        }
        local fullTitle = cfg.LoadingTitle or title
        local subText = cfg.LoadingSubtitle or ("Welcome, " .. dispName)
        local nStages = math.max(1, #statuses)
        local TRACK_W = LW - 88

        backdropTarget = 1

        local panel = create("CanvasGroup", {
            Name = "Loader", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(LW - 70, LH - 50), BackgroundColor3 = WHITE, BorderSizePixel = 0,
            GroupTransparency = 1, ZIndex = 20, Parent = gui,
        }, {corner(16)})
        local panelGrad = create("UIGradient", {Color = bgSeq(), Rotation = 62, Parent = panel})
        themed(function()
            panelGrad.Color = bgSeq()
        end)

        -- visible edge (so the panel never disappears into a pure black screen)
        local edge = create("Frame", {
            Position = UDim2.fromOffset(2, 2), Size = UDim2.new(1, -4, 1, -4), BackgroundTransparency = 1,
            ZIndex = 12, Parent = panel,
        }, {corner(14)})
        local edgeStroke = create("UIStroke", {
            Color = lift(Theme.Stroke, 0.25), Thickness = 1.5, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = edge,
        })
        themed(function()
            edgeStroke.Color = lift(Theme.Stroke, 0.25)
        end)
        local topLine = create("Frame", {
            Position = UDim2.fromOffset(24, 0), Size = UDim2.new(1, -48, 0, 2), BackgroundColor3 = WHITE,
            BorderSizePixel = 0, ZIndex = 13, Parent = panel,
        }, {round()})
        accentGrad(topLine, 0)

        local glowOrb = create("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.16), Size = UDim2.fromOffset(340, 340),
            BackgroundColor3 = WHITE, BorderSizePixel = 0, ZIndex = 1, Parent = panel,
        }, {round()})
        local glowOrbGrad = create("UIGradient", {
            Rotation = 90, Color = accentSeq(),
            Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.82), NumberSequenceKeypoint.new(1, 1)}),
            Parent = glowOrb,
        })
        themed(function()
            glowOrbGrad.Color = accentSeq()
        end)

        local lfield
        if not (StyleDef and StyleDef.NoSnow) then
            local snowHolderL = create("Frame", {
                Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 2, Parent = panel,
            })
            lfield = snowField(snowHolderL, LW, LH, {
                {count = 34, minS = 1.5, maxS = 4.2, minT = 0.35, maxT = 0.8, speed = 28},
            })
        end

        -- logo (no rings: just a clean disc with the monogram)
        local ringHolder = create("Frame", {
            AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 26), Size = UDim2.fromOffset(70, 70),
            BackgroundTransparency = 1, ZIndex = 3, Parent = panel,
        })
        local ringScale = create("UIScale", {Parent = ringHolder})
        local rdisc = create("Frame", {
            Size = UDim2.fromScale(1, 1), BackgroundColor3 = Theme.Background, BorderSizePixel = 0, Parent = ringHolder,
        }, {round()})
        bind(rdisc, "BackgroundColor3", "Background")
        local rstroke = create("UIStroke", {
            Color = lift(Theme.Stroke, 0.35), Thickness = 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = rdisc,
        })
        themed(function()
            rstroke.Color = lift(Theme.Stroke, 0.35)
        end)
        local rinner = create("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(54, 54),
            BackgroundColor3 = WHITE, BackgroundTransparency = 0.78, BorderSizePixel = 0, Parent = rdisc,
        }, {round()})
        accentGrad(rinner, 45)
        local rmono = create("TextLabel", {
            Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = logoText,
            Font = Enum.Font.GothamBlack, TextSize = 22, TextColor3 = WHITE, Parent = rdisc,
        })
        accentGrad(rmono, 90)

        -- title (typewriter + shimmer) and welcome line
        local ltitle = create("TextLabel", {
            AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 108), Size = UDim2.fromOffset(LW, 32),
            BackgroundTransparency = 1, Text = "", Font = Enum.Font.GothamBlack, TextSize = 26,
            TextColor3 = WHITE, ZIndex = 3, Parent = panel,
        })
        local function ltSeq()
            return ColorSequence.new({
                ColorSequenceKeypoint.new(0, Theme.Text),
                ColorSequenceKeypoint.new(0.5, Theme.Accent),
                ColorSequenceKeypoint.new(1, Theme.Accent2),
            })
        end
        local ltGrad = create("UIGradient", {Color = ltSeq(), Parent = ltitle})
        themed(function()
            ltGrad.Color = ltSeq()
        end)
        label(panel, subText, {
            AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 142), Size = UDim2.fromOffset(LW - 60, 16),
            TextXAlignment = Enum.TextXAlignment.Center, Font = Enum.Font.Gotham, TextSize = 12, ZIndex = 3,
        }, "SubText")

        local statusLbl = label(panel, "", {
            Position = UDim2.fromOffset(44, 172), Size = UDim2.fromOffset(330, 16), ZIndex = 3,
            Font = Enum.Font.GothamMedium, TextSize = 12,
        }, "SubText")
        local pctLbl = label(panel, "0%", {
            AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromOffset(LW - 44, 170), Size = UDim2.fromOffset(80, 18),
            TextXAlignment = Enum.TextXAlignment.Right, Font = Enum.Font.Code, TextSize = 13, ZIndex = 3,
        }, "Accent")

        -- progress bar: a clearly visible track, accent fill, shine and a bright leading edge
        local track = create("Frame", {
            Position = UDim2.fromOffset(44, 194), Size = UDim2.fromOffset(TRACK_W, 10),
            BackgroundColor3 = lift(Theme.Stroke, 0.18), BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 3, Parent = panel,
        }, {round(), create("UIStroke", {Color = lift(Theme.Stroke, 0.34), Thickness = 1})})
        local trackStroke = track:FindFirstChildOfClass("UIStroke")
        themed(function()
            track.BackgroundColor3 = lift(Theme.Stroke, 0.18)
            trackStroke.Color = lift(Theme.Stroke, 0.34)
        end)
        local fill = create("Frame", {
            Size = UDim2.fromScale(0, 1), BackgroundColor3 = WHITE, BorderSizePixel = 0, ZIndex = 3, Parent = track,
        }, {round()})
        accentGrad(fill, 0)
        local shine = create("Frame", {
            Size = UDim2.new(0, 64, 1, 0), Position = UDim2.fromScale(-0.3, 0), BackgroundColor3 = WHITE,
            BorderSizePixel = 0, ZIndex = 4, Parent = track,
        }, {round()})
        create("UIGradient", {
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0.55), NumberSequenceKeypoint.new(1, 1),
            }),
            Parent = shine,
        })
        local spark = create("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.fromOffset(4, 10),
            BackgroundColor3 = Theme.Text, BorderSizePixel = 0, Visible = false, ZIndex = 5, Parent = track,
        }, {round()})
        bind(spark, "BackgroundColor3", "Text")

        -- one pip per stage, filled as each stage completes
        local pips = {}
        do
            local gap = 5
            local pw = (TRACK_W - gap * (nStages - 1)) / nStages
            for i = 1, nStages do
                pips[i] = create("Frame", {
                    Position = UDim2.fromOffset(44 + (i - 1) * (pw + gap), 212), Size = UDim2.fromOffset(pw, 4),
                    BackgroundColor3 = lift(Theme.Stroke, 0.18), BorderSizePixel = 0, ZIndex = 3, Parent = panel,
                }, {round()})
            end
        end

        local tipLbl2 = label(panel, "", {
            AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 238), Size = UDim2.fromOffset(LW - 60, 18),
            TextXAlignment = Enum.TextXAlignment.Center, Font = Enum.Font.Gotham, TextSize = 11, ZIndex = 3,
        }, "SubText")
        label(panel, "DH UI v" .. Library.Version .. (styleName and ("  |  " .. styleName .. " style") or ""), {
            AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 272), Size = UDim2.fromOffset(LW - 60, 14),
            TextXAlignment = Enum.TextXAlignment.Center, Font = Enum.Font.Code, TextSize = 10, ZIndex = 3,
            TextTransparency = 0.4,
        }, "SubText")

        tween(panel, {Size = UDim2.fromOffset(LW, LH), GroupTransparency = 0}, 0.55, Enum.EasingStyle.Back)

        -- uneven but smooth progress: every stage has its own length and eases out, like real loading
        local weights, bounds, totalW, accW = {}, {}, 0, 0
        local pattern = {1.0, 1.4, 1.1, 1.6, 0.9}
        for i = 1, nStages do
            weights[i] = pattern[(i - 1) % #pattern + 1]
            totalW = totalW + weights[i]
        end
        for i = 1, nStages do
            accW = accW + weights[i] / totalW
            bounds[i] = accW
        end
        local function progressAt(x)
            local prev = 0
            for i = 1, nStages do
                if x <= bounds[i] or i == nStages then
                    local u = math.clamp((x - prev) / math.max(bounds[i] - prev, 0.0001), 0, 1)
                    local eased = 1 - (1 - u) ^ 3
                    return (i - 1 + eased) / nStages, i
                end
                prev = bounds[i]
            end
            return 1, nStages
        end

        local phase, phaseT, statusIdx, tipIdx, lastTip = "in", 0, 0, 0, -10
        local finished = false

        local function paintPips(idx, clk, allDone)
            for i, pip in ipairs(pips) do
                if allDone or i < idx then
                    pip.BackgroundColor3 = Theme.Accent
                    pip.BackgroundTransparency = 0
                elseif i == idx then
                    pip.BackgroundColor3 = Theme.Accent
                    pip.BackgroundTransparency = 0.25 + (math.sin(clk * 7) + 1) / 2 * 0.4
                else
                    pip.BackgroundColor3 = lift(Theme.Stroke, 0.18)
                    pip.BackgroundTransparency = 0
                end
            end
        end

        loader = {panel = panel}
        function loader.step(dt, clk)
            phaseT = phaseT + dt
            ringScale.Scale = 1 + math.sin(clk * 2.4) * 0.03
            ltGrad.Offset = Vector2.new(math.sin(clk * 1.4) * 0.45, 0)
            if lfield then
                stepSnowField(lfield, dt, clk, math.sin(clk * 0.8) * 20, nil, nil, 1)
            end

            if phase == "in" then
                if phaseT >= 0.5 then
                    phase, phaseT = "run", 0
                end
            elseif phase == "run" then
                local x = math.clamp(phaseT / D, 0, 1)
                local p, idx = progressAt(x)
                fill.Size = UDim2.fromScale(p, 1)
                spark.Visible = p > 0.015 and p < 0.995
                spark.Position = UDim2.new(p, -2, 0.5, 0)
                pctLbl.Text = string.format("%d%%", math.floor(p * 100 + 0.5))
                local chars = math.floor(math.clamp(phaseT / 0.7, 0, 1) * #fullTitle + 0.5)
                ltitle.Text = string.sub(fullTitle, 1, chars)
                if idx ~= statusIdx then
                    statusIdx = idx
                    statusLbl.TextTransparency = 1
                    tween(statusLbl, {TextTransparency = 0}, 0.25)
                end
                statusLbl.Text = string.format("%d/%d   %s%s", idx, nStages, statuses[idx] or "", string.rep(".", math.floor(clk * 3) % 4))
                paintPips(idx, clk, false)
                if #tips > 0 and clk - lastTip > 1.3 then
                    lastTip = clk
                    tipIdx = tipIdx % #tips + 1
                    tipLbl2.Text = tips[tipIdx]
                    tipLbl2.TextTransparency = 1
                    tween(tipLbl2, {TextTransparency = 0}, 0.35)
                end
                shine.Position = UDim2.new(((clk * 0.9) % 1.5) - 0.3, 0, 0, 0)
                if x >= 1 then
                    phase, phaseT = "hold", 0
                    ltitle.Text = fullTitle
                    statusLbl.Text = "Ready"
                    pctLbl.Text = "100%"
                    fill.Size = UDim2.fromScale(1, 1)
                    spark.Visible = false
                    paintPips(nStages, clk, true)
                end
            elseif phase == "hold" then
                if phaseT >= 0.5 then
                    phase, phaseT = "out", 0
                    tween(panel, {GroupTransparency = 1, Size = UDim2.fromOffset(LW + 50, LH + 36)}, 0.5)
                end
            elseif phase == "out" then
                if phaseT >= 0.5 and not finished then
                    finished = true
                    panel:Destroy()
                    loader = nil
                    Window.Loading = false
                    Window:SetVisible(true)
                end
            end
        end
    end

    ---------------------------------------------------------------------
    -- Element toolkit
    ---------------------------------------------------------------------

    local function newElement(parent, height)
        local f = create("Frame", {
            Size = UDim2.new(1, 0, 0, height or 38),
            BackgroundColor3 = Theme.Element,
            BorderSizePixel = 0,
            ClipsDescendants = true,
            Parent = parent,
        }, {corner(7)})
        bind(f, "BackgroundColor3", "Element")
        local st = create("UIStroke", {
            Color = Theme.Stroke, Transparency = 0.45, Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = f,
        })
        bind(st, "Color", "Stroke")
        create("UIGradient", {
            Color = ColorSequence.new(WHITE, rgb(206, 206, 218)),
            Rotation = 90, Parent = f,
        })
        return f, st
    end

    local function hoverFx(btn, frame, stroke, extra)
        connect(btn.MouseEnter, function()
            tween(frame, {BackgroundColor3 = Theme.ElementHover}, 0.2)
            tween(stroke, {Color = Theme.Accent, Transparency = 0.2}, 0.2)
            if extra then
                extra(true)
            end
        end)
        connect(btn.MouseLeave, function()
            tween(frame, {BackgroundColor3 = Theme.Element}, 0.25)
            tween(stroke, {Color = Theme.Stroke, Transparency = 0.45}, 0.25)
            if extra then
                extra(false)
            end
        end)
    end

    local function ripple(frame, input)
        local p = pointer(input)
        local x = p.X - frame.AbsolutePosition.X
        local y = p.Y - frame.AbsolutePosition.Y
        local size = math.max(frame.AbsoluteSize.X, frame.AbsoluteSize.Y) * 2.4
        local c = create("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromOffset(x, y),
            Size = UDim2.fromOffset(0, 0),
            BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 0.7,
            BorderSizePixel = 0,
            Parent = frame,
        }, {round()})
        tween(c, {Size = UDim2.fromOffset(size, size), BackgroundTransparency = 1}, 0.6)
        task.delay(0.65, function()
            c:Destroy()
        end)
    end

    local function overlay(f, st, extra, o)
        local b = create("TextButton", {
            Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "",
            AutoButtonColor = false, ZIndex = 10, Parent = f,
        })
        hoverFx(b, f, st, extra)
        local tipText = o and o.Tooltip
        if tipText then
            connect(b.MouseEnter, function()
                tipEnter(tipText)
            end)
            connect(b.MouseLeave, function()
                tipLeave(tipText)
            end)
        end
        connect(b.InputBegan, function(input)
            if isPress(input) then
                ripple(f, input)
            end
        end)
        return b
    end

    local function commit(o, value, silent)
        if o.Flag then
            Library.Flags[o.Flag] = value
        end
        if not silent then
            safeCall(o.Callback, value)
        end
    end

    local function register(o, setter)
        if o.Flag then
            Window.Setters[o.Flag] = setter
        end
    end

    -- name + optional description laid out inside an element
    local function nameBlock(f, o, defaultName, rightPad)
        local hasDesc = o.Description ~= nil and o.Description ~= ""
        label(f, o.Name or defaultName, {
            Position = UDim2.fromOffset(12, hasDesc and 7 or 0),
            Size = UDim2.new(1, -(rightPad or 60), 0, hasDesc and 18 or 38),
            TextTruncate = Enum.TextTruncate.AtEnd,
        })
        if hasDesc then
            label(f, o.Description, {
                Position = UDim2.fromOffset(12, 26), Size = UDim2.new(1, -(rightPad or 60), 0, 16),
                TextSize = 11, Font = Enum.Font.Gotham, TextTruncate = Enum.TextTruncate.AtEnd,
            }, "SubText")
        end
        return hasDesc and 52 or 38
    end

    local E = {}

    -- Label ---------------------------------------------------------------
    function E.Label(parent, o)
        if type(o) == "string" then
            o = {Text = o}
        end
        local f = newElement(parent, 32)
        local l = label(f, o.Text or o.Name or "Label", {
            Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -24, 1, 0),
            TextSize = 12, TextTruncate = Enum.TextTruncate.AtEnd,
        }, "SubText")
        local obj = {}
        function obj:Set(t)
            l.Text = t
        end
        return obj
    end

    -- Paragraph -----------------------------------------------------------
    function E.Paragraph(parent, o)
        local f = newElement(parent, 40)
        f.AutomaticSize = Enum.AutomaticSize.Y
        f.Size = UDim2.new(1, 0, 0, 0)
        create("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = f})
        create("UIPadding", {
            PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 12),
            PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), Parent = f,
        })
        local t = label(f, o.Title or "Paragraph", {Size = UDim2.new(1, 0, 0, 18), Font = Enum.Font.GothamBold, LayoutOrder = 1})
        local c = label(f, o.Content or "", {
            Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, TextWrapped = true,
            TextYAlignment = Enum.TextYAlignment.Top, TextSize = 12, Font = Enum.Font.Gotham, LayoutOrder = 2,
        }, "SubText")
        local obj = {}
        function obj:Set(title, content)
            t.Text = title or t.Text
            c.Text = content or c.Text
        end
        return obj
    end

    -- Divider -------------------------------------------------------------
    function E.Divider(parent)
        local d = create("Frame", {Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = Theme.Stroke, BorderSizePixel = 0, Parent = parent}, {round()})
        bind(d, "BackgroundColor3", "Stroke")
        return {}
    end

    -- Button --------------------------------------------------------------
    function E.Button(parent, o)
        local f, st = newElement(parent, 38)
        local height = nameBlock(f, o, "Button", 56)
        f.Size = UDim2.new(1, 0, 0, height)
        local glyph = label(f, ">", {
            Size = UDim2.fromOffset(20, height), Position = UDim2.new(1, -30, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Center, Font = Enum.Font.GothamBold,
        }, "SubText")
        local b = overlay(f, st, function(on)
            tween(glyph, {
                Position = on and UDim2.new(1, -24, 0, 0) or UDim2.new(1, -30, 0, 0),
                TextColor3 = on and Theme.Accent or Theme.SubText,
            }, 0.2)
        end, o)
        connect(b.MouseButton1Click, function()
            safeCall(o.Callback)
        end)
        return {}
    end

    -- Toggle --------------------------------------------------------------
    function E.Toggle(parent, o)
        local state = o.Default == true
        local f, st = newElement(parent, 38)
        local height = nameBlock(f, o, "Toggle", 72)
        f.Size = UDim2.new(1, 0, 0, height)
        local track = create("Frame", {
            AnchorPoint = Vector2.new(0, 0.5), Size = UDim2.fromOffset(40, 20), Position = UDim2.new(1, -52, 0.5, 0),
            BackgroundColor3 = Theme.Stroke, BorderSizePixel = 0, Parent = f,
        }, {round()})
        bind(track, "BackgroundColor3", "Stroke")
        local fill = create("Frame", {
            Size = UDim2.fromScale(1, 1), BackgroundColor3 = WHITE, BackgroundTransparency = 1,
            BorderSizePixel = 0, Parent = track,
        }, {round()})
        accentGrad(fill, 0)
        local knob = create("Frame", {
            Size = UDim2.fromOffset(14, 14), Position = UDim2.new(0, 3, 0.5, -7),
            BackgroundColor3 = Theme.SubText, BorderSizePixel = 0, Parent = track,
        }, {round()})
        if StyleDef and StyleDef.Checkbox then
            track.Size = UDim2.fromOffset(16, 16)
            track.Position = UDim2.new(1, -30, 0.5, 0)
            knob.Visible = false
        end

        local function render(anim)
            if StyleDef and StyleDef.Checkbox then
                if anim then
                    tween(fill, {BackgroundTransparency = state and 0 or 1}, 0.15)
                else
                    fill.BackgroundTransparency = state and 0 or 1
                end
                return
            end
            local pos = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
            local kc = state and Theme.OnAccent or Theme.SubText
            if anim then
                knob.Size = UDim2.fromOffset(21, 14)
                tween(knob, {Size = UDim2.fromOffset(14, 14), Position = pos, BackgroundColor3 = kc}, 0.38, Enum.EasingStyle.Back)
                tween(fill, {BackgroundTransparency = state and 0 or 1}, 0.25)
            else
                knob.Position = pos
                knob.BackgroundColor3 = kc
                fill.BackgroundTransparency = state and 0 or 1
            end
        end

        local obj = {}
        function obj:Set(v, silent)
            state = v and true or false
            render(true)
            commit(o, state, silent)
        end
        function obj:Get()
            return state
        end

        local b = overlay(f, st, nil, o)
        connect(b.MouseButton1Click, function()
            obj:Set(not state)
        end)
        themed(function()
            render(false)
        end)
        register(o, function(v)
            obj:Set(v)
        end)
        -- fires the callback once at creation only when it starts enabled
        commit(o, state, (not state) or o.Silent)
        return obj
    end

    -- Slider: eased knob, hover growth, value bubble while dragging, ticks, typeable value ----
    function E.Slider(parent, o)
        local min = (o.Range and o.Range[1]) or 0
        local max = (o.Range and o.Range[2]) or 100
        local inc = o.Increment or 1
        local suffix = o.Suffix or ""
        local fmt = "%." .. decimalsOf(inc) .. "f"
        local value = math.clamp(o.Default or min, min, max)
        local BAR_Y = 44

        local function alphaOf(v)
            return (max == min) and 0 or (v - min) / (max - min)
        end
        local shownA = alphaOf(value)
        local dragging, hovered = false, false

        local f, st = newElement(parent, 68)
        label(f, o.Name or "Slider", {
            Position = UDim2.fromOffset(12, 6), Size = UDim2.new(1, -112, 0, 22), TextTruncate = Enum.TextTruncate.AtEnd,
        })

        local pill = create("Frame", {
            Position = UDim2.new(1, -92, 0, 6), Size = UDim2.fromOffset(80, 22), BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 0.86, BorderSizePixel = 0, ZIndex = 20, Parent = f,
        }, {corner(6)})
        bind(pill, "BackgroundColor3", "Accent")
        local pillStroke = create("UIStroke", {Color = Theme.Accent, Transparency = 0.7, Parent = pill})
        bind(pillStroke, "Color", "Accent")
        local valBox = create("TextBox", {
            Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", Font = Enum.Font.Code, TextSize = 12,
            TextColor3 = Theme.Accent, ClearTextOnFocus = true, ZIndex = 21, Parent = pill,
        })
        bind(valBox, "TextColor3", "Accent")

        local bar = create("Frame", {
            Position = UDim2.new(0, 14, 0, BAR_Y), Size = UDim2.new(1, -28, 0, 6),
            BackgroundColor3 = Theme.Stroke, BorderSizePixel = 0, Parent = f,
        }, {round()})
        bind(bar, "BackgroundColor3", "Stroke")
        for i = 0, 4 do
            local tick = create("Frame", {
                AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(i / 4, 0, 1, 5), Size = UDim2.fromOffset(1, 4),
                BackgroundColor3 = Theme.SubText, BackgroundTransparency = 0.6, BorderSizePixel = 0, Parent = bar,
            }, {round()})
            bind(tick, "BackgroundColor3", "SubText")
        end
        local fill = create("Frame", {
            Size = UDim2.fromScale(0, 1), BackgroundColor3 = WHITE, BorderSizePixel = 0, Parent = bar,
        }, {round()})
        accentGrad(fill, 0)
        local glow = create("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.fromOffset(28, 28),
            BackgroundColor3 = WHITE, BackgroundTransparency = 0.88, BorderSizePixel = 0, Parent = bar,
        }, {round()})
        accentGrad(glow, 45)
        local knob = create("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.fromOffset(14, 14),
            BackgroundColor3 = WHITE, BorderSizePixel = 0, Parent = bar,
        }, {round()})
        local knobStroke = create("UIStroke", {Color = Theme.Accent, Thickness = 2, Parent = knob})
        bind(knobStroke, "Color", "Accent")
        local knobDot = create("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(4, 4),
            BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Parent = knob,
        }, {round()})
        bind(knobDot, "BackgroundColor3", "Accent")
        local knobScale = create("UIScale", {Parent = knob})

        local bubble = create("Frame", {
            AnchorPoint = Vector2.new(0.5, 1), Size = UDim2.fromOffset(52, 22), BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false, ZIndex = 15, Parent = f,
        }, {corner(6)})
        bind(bubble, "BackgroundColor3", "Accent")
        local bubbleScale = create("UIScale", {Scale = 0.4, Parent = bubble})
        local bubbleLbl = label(bubble, "", {
            Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center,
            Font = Enum.Font.Code, TextSize = 11, TextTransparency = 1,
        }, "OnAccent")
        local bubblePtr = create("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 1, 0), Size = UDim2.fromOffset(8, 8),
            Rotation = 45, BackgroundColor3 = Theme.Accent, BackgroundTransparency = 1, BorderSizePixel = 0, Parent = bubble,
        })
        bind(bubblePtr, "BackgroundColor3", "Accent")

        local function applyVisual(a)
            fill.Size = UDim2.fromScale(a, 1)
            knob.Position = UDim2.fromScale(a, 0.5)
            glow.Position = UDim2.fromScale(a, 0.5)
            local half = bubble.Size.X.Offset / 2
            local x = 14 + a * bar.AbsoluteSize.X
            if f.AbsoluteSize.X > 0 then
                x = math.clamp(x, half + 2, f.AbsoluteSize.X - half - 2)
            end
            bubble.Position = UDim2.new(0, x, 0, BAR_Y - 8)
        end

        local obj = {}
        function obj:Set(v, silent)
            v = math.clamp(v, min, max)
            v = min + math.floor((v - min) / inc + 0.5) * inc
            v = math.clamp(tonumber(string.format(fmt, v)), min, max)
            value = v
            local txt = string.format(fmt, v) .. suffix
            valBox.Text = txt
            bubbleLbl.Text = txt
            bubble.Size = UDim2.fromOffset(math.max(44, textWidth(txt, 11, Enum.Font.Code) + 18), 22)
            commit(o, v, silent)
        end
        function obj:Get()
            return value
        end

        local function setDrag(on)
            dragging = on
            tween(knobScale, {Scale = on and 1.5 or (hovered and 1.18 or 1)}, 0.22, Enum.EasingStyle.Back)
            tween(glow, {BackgroundTransparency = on and 0.68 or 0.88, Size = on and UDim2.fromOffset(40, 40) or UDim2.fromOffset(28, 28)}, 0.22)
            if on then
                bubble.Visible = true
                tween(bubbleScale, {Scale = 1}, 0.24, Enum.EasingStyle.Back)
                tween(bubble, {BackgroundTransparency = 0}, 0.15)
                tween(bubblePtr, {BackgroundTransparency = 0}, 0.15)
                tween(bubbleLbl, {TextTransparency = 0}, 0.15)
            else
                local t = tween(bubbleScale, {Scale = 0.4}, 0.16)
                tween(bubble, {BackgroundTransparency = 1}, 0.14)
                tween(bubblePtr, {BackgroundTransparency = 1}, 0.14)
                tween(bubbleLbl, {TextTransparency = 1}, 0.14)
                t.Completed:Connect(function()
                    if not dragging then
                        bubble.Visible = false
                    end
                end)
            end
        end

        local function update(input)
            local a = math.clamp((pointer(input).X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            obj:Set(min + (max - min) * a)
        end

        local b = overlay(f, st, function(on)
            hovered = on
            tween(bar, {
                Size = UDim2.new(1, -28, 0, on and 8 or 6),
                Position = UDim2.new(0, 14, 0, on and BAR_Y - 1 or BAR_Y),
            }, 0.15)
            if not dragging then
                tween(knobScale, {Scale = on and 1.18 or 1}, 0.18, Enum.EasingStyle.Back)
            end
        end, o)
        connect(b.InputBegan, function(input)
            if isPress(input) and pointer(input).Y - f.AbsolutePosition.Y > 30 then
                setDrag(true)
                update(input)
            end
        end)
        connect(UserInputService.InputEnded, function(input)
            if dragging and isPress(input) then
                setDrag(false)
            end
        end)
        connect(UserInputService.InputChanged, function(input)
            if dragging and isMove(input) then
                update(input)
            end
        end)

        connect(valBox.Focused, function()
            tween(pillStroke, {Transparency = 0, Thickness = 1.5}, 0.15)
        end)
        connect(valBox.FocusLost, function()
            tween(pillStroke, {Transparency = 0.7, Thickness = 1}, 0.2)
            local n = tonumber((valBox.Text:gsub("[^%d%.%-]", "")))
            if n then
                obj:Set(n)
            else
                valBox.Text = string.format(fmt, value) .. suffix
            end
        end)

        -- eased knob: it glides toward the real value instead of snapping
        table.insert(updaters, function(dt)
            local target = alphaOf(value)
            if math.abs(target - shownA) > 0.0002 then
                shownA = shownA + (target - shownA) * (1 - math.exp(-dt * 20))
                applyVisual(shownA)
            elseif shownA ~= target then
                shownA = target
                applyVisual(shownA)
            end
        end)

        local startTxt = string.format(fmt, value) .. suffix
        valBox.Text = startTxt
        bubbleLbl.Text = startTxt
        bubble.Size = UDim2.fromOffset(math.max(44, textWidth(startTxt, 11, Enum.Font.Code) + 18), 22)
        applyVisual(shownA)
        register(o, function(v)
            obj:Set(v)
        end)
        commit(o, value, true)
        return obj
    end

    -- Dropdown (smooth open / close, multi select, optional search) --------------
    function E.Dropdown(parent, o)
        local multi = o.Multi == true
        local options = o.Options or {}
        local search = o.Search == true or (o.Search == nil and #options > 8)
        local IH, MAXV = 28, 6
        local selected
        if multi then
            selected = {}
            if type(o.Default) == "table" then
                for _, v in ipairs(o.Default) do
                    selected[v] = true
                end
            end
        else
            selected = o.Default or options[1]
        end
        local open = false
        local visibleCount = #options

        local f, st = newElement(parent, 38)
        label(f, o.Name or "Dropdown", {Position = UDim2.fromOffset(12, 0), Size = UDim2.new(0.42, -12, 0, 38)})
        local valLbl = label(f, "", {
            Position = UDim2.new(0.4, 0, 0, 0), Size = UDim2.new(0.6, -38, 0, 38),
            TextXAlignment = Enum.TextXAlignment.Right, TextTruncate = Enum.TextTruncate.AtEnd,
            TextSize = 12, Font = Enum.Font.Code,
        }, "SubText")
        local arrow = label(f, ">", {
            Position = UDim2.new(1, -28, 0, 0), Size = UDim2.fromOffset(18, 38),
            TextXAlignment = Enum.TextXAlignment.Center, Font = Enum.Font.GothamBold, Rotation = 90,
        }, "Accent")

        local listTop = 42
        local searchBox
        if search then
            local sw = create("Frame", {
                Position = UDim2.fromOffset(6, 42), Size = UDim2.new(1, -12, 0, 26),
                BackgroundColor3 = Theme.Background, BorderSizePixel = 0, Parent = f,
            }, {corner(6)})
            bind(sw, "BackgroundColor3", "Background")
            local sws = create("UIStroke", {Color = Theme.Stroke, Transparency = 0.2, Parent = sw})
            bind(sws, "Color", "Stroke")
            searchBox = create("TextBox", {
                Position = UDim2.fromOffset(9, 0), Size = UDim2.new(1, -18, 1, 0), BackgroundTransparency = 1,
                Text = "", PlaceholderText = "Search...", PlaceholderColor3 = Theme.SubText, TextColor3 = Theme.Text,
                Font = Enum.Font.Code, TextSize = 12, ClearTextOnFocus = false,
                TextXAlignment = Enum.TextXAlignment.Left, Parent = sw,
            })
            bind(searchBox, "TextColor3", "Text")
            bind(searchBox, "PlaceholderColor3", "SubText")
            connect(searchBox.Focused, function()
                tween(sws, {Color = Theme.Accent}, 0.15)
            end)
            connect(searchBox.FocusLost, function()
                tween(sws, {Color = Theme.Stroke}, 0.2)
            end)
            listTop = 72
        end

        local listWrap = create("ScrollingFrame", {
            Position = UDim2.fromOffset(6, listTop), Size = UDim2.new(1, -12, 0, 0),
            BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2,
            ScrollBarImageColor3 = Theme.Accent, CanvasSize = UDim2.new(),
            AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = f,
        }, {create("UIListLayout", {Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder})})
        bind(listWrap, "ScrollBarImageColor3", "Accent")

        local items = {}
        local function isSel(v)
            if multi then
                return selected[v] == true
            end
            return selected == v
        end
        local function getValue()
            if multi then
                local t = {}
                for _, v in ipairs(options) do
                    if selected[v] then
                        t[#t + 1] = v
                    end
                end
                return t
            end
            return selected
        end
        local function display()
            if multi then
                local names = {}
                for _, v in ipairs(getValue()) do
                    names[#names + 1] = tostring(v)
                end
                valLbl.Text = #names > 0 and table.concat(names, ", ") or "None"
            else
                valLbl.Text = tostring(selected or "None")
            end
        end
        local function paintItems()
            for v, it in pairs(items) do
                local on = isSel(v)
                tween(it.lbl, {TextColor3 = on and Theme.Accent or Theme.SubText}, 0.15)
                tween(it.mark, {BackgroundTransparency = on and 0 or 1}, 0.15)
                tween(it.btn, {BackgroundTransparency = on and 0.88 or 1}, 0.15)
            end
        end
        local function listHeight()
            return math.min(visibleCount, MAXV) * (IH + 2)
        end
        local function openHeight()
            return listTop + listHeight() + 6
        end
        local function resize()
            tween(f, {Size = UDim2.new(1, 0, 0, open and openHeight() or 38)}, open and 0.36 or 0.26)
            tween(arrow, {Rotation = open and -90 or 90}, 0.32, Enum.EasingStyle.Back)
        end
        local function staggerIn()
            local i = 0
            for _, opt in ipairs(options) do
                local it = items[opt]
                if it and it.btn.Visible then
                    it.lbl.TextTransparency = 1
                    task.delay(i * 0.022, function()
                        if open and it.lbl.Parent then
                            tween(it.lbl, {TextTransparency = 0}, 0.2)
                        end
                    end)
                    i = i + 1
                end
            end
        end
        local function applyFilter()
            local q = searchBox and string.lower(searchBox.Text) or ""
            local c = 0
            for _, opt in ipairs(options) do
                local it = items[opt]
                if it then
                    local show = q == "" or string.find(string.lower(tostring(opt)), q, 1, true) ~= nil
                    it.btn.Visible = show
                    if show then
                        c = c + 1
                    end
                end
            end
            visibleCount = c
            listWrap.Size = UDim2.new(1, -12, 0, listHeight())
            if open then
                tween(f, {Size = UDim2.new(1, 0, 0, openHeight())}, 0.22)
            end
        end

        local function build()
            for _, it in pairs(items) do
                it.btn:Destroy()
            end
            items = {}
            for _, opt in ipairs(options) do
                local ib = create("TextButton", {
                    Size = UDim2.new(1, 0, 0, IH), BackgroundColor3 = Theme.Accent, BackgroundTransparency = 1,
                    Text = "", AutoButtonColor = false, Parent = listWrap,
                }, {corner(5)})
                local mark = create("Frame", {
                    AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 4, 0.5, 0),
                    Size = UDim2.fromOffset(3, 14), BackgroundColor3 = Theme.Accent, BackgroundTransparency = 1,
                    BorderSizePixel = 0, Parent = ib,
                }, {round()})
                local il = create("TextLabel", {
                    Position = UDim2.fromOffset(16, 0), Size = UDim2.new(1, -24, 1, 0), BackgroundTransparency = 1,
                    Text = tostring(opt), Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Theme.SubText,
                    TextXAlignment = Enum.TextXAlignment.Left, Parent = ib,
                })
                items[opt] = {btn = ib, lbl = il, mark = mark}
                connect(ib.MouseEnter, function()
                    if not isSel(opt) then
                        tween(il, {TextColor3 = Theme.Text}, 0.12)
                    end
                end)
                connect(ib.MouseLeave, function()
                    if not isSel(opt) then
                        tween(il, {TextColor3 = Theme.SubText}, 0.15)
                    end
                end)
                connect(ib.MouseButton1Click, function()
                    if multi then
                        selected[opt] = (not selected[opt]) or nil
                    else
                        selected = opt
                        open = false
                        resize()
                    end
                    display()
                    paintItems()
                    commit(o, getValue())
                end)
            end
            visibleCount = #options
            listWrap.Size = UDim2.new(1, -12, 0, listHeight())
            display()
            paintItems()
            if searchBox then
                applyFilter()
            end
        end
        if searchBox then
            connect(searchBox:GetPropertyChangedSignal("Text"), applyFilter)
        end

        local obj = {}
        function obj:Set(v, silent)
            if multi then
                selected = {}
                for _, x in ipairs(type(v) == "table" and v or {}) do
                    selected[x] = true
                end
            else
                selected = v
            end
            display()
            paintItems()
            commit(o, getValue(), silent)
        end
        function obj:Get()
            return getValue()
        end
        function obj:Refresh(newOptions)
            options = newOptions or {}
            build()
            if open then
                resize()
            end
        end

        local b = overlay(f, st, nil, o)
        b.Size = UDim2.new(1, 0, 0, 38)
        connect(b.MouseButton1Click, function()
            open = not open
            resize()
            if open then
                staggerIn()
            end
        end)

        build()
        themed(function()
            paintItems()
        end)
        register(o, function(v)
            obj:Set(v)
        end)
        commit(o, getValue(), true)
        return obj
    end

    -- Textbox ---------------------------------------------------------------------
    function E.Textbox(parent, o)
        local f = newElement(parent, 38)
        label(f, o.Name or "Textbox", {Position = UDim2.fromOffset(12, 0), Size = UDim2.new(0.42, -12, 1, 0)})
        local wrapBox = create("Frame", {
            Position = UDim2.new(0.42, 0, 0.5, -14), Size = UDim2.new(0.58, -10, 0, 28),
            BackgroundColor3 = Theme.Background, BorderSizePixel = 0, Parent = f,
        }, {corner(6)})
        bind(wrapBox, "BackgroundColor3", "Background")
        local ws = create("UIStroke", {Color = Theme.Stroke, Transparency = 0.2, Parent = wrapBox})
        bind(ws, "Color", "Stroke")
        local box = create("TextBox", {
            Position = UDim2.fromOffset(9, 0), Size = UDim2.new(1, -18, 1, 0), BackgroundTransparency = 1,
            Text = o.Default or "", PlaceholderText = o.Placeholder or "Type here...",
            PlaceholderColor3 = Theme.SubText, TextColor3 = Theme.Text, Font = Enum.Font.Code,
            TextSize = 12, ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd, Parent = wrapBox,
        })
        bind(box, "TextColor3", "Text")
        bind(box, "PlaceholderColor3", "SubText")
        connect(box.Focused, function()
            tween(ws, {Color = Theme.Accent, Transparency = 0, Thickness = 1.5}, 0.2)
        end)
        connect(box.FocusLost, function()
            tween(ws, {Color = Theme.Stroke, Transparency = 0.2, Thickness = 1}, 0.25)
            commit(o, box.Text)
        end)
        local obj = {}
        function obj:Set(t, silent)
            box.Text = t
            commit(o, t, silent)
        end
        function obj:Get()
            return box.Text
        end
        register(o, function(v)
            obj:Set(v)
        end)
        commit(o, box.Text, true)
        return obj
    end

    -- Keybind ----------------------------------------------------------------------
    function E.Keybind(parent, o)
        local key = o.Default or Enum.KeyCode.F
        local listening = false
        local f = newElement(parent, 38)
        label(f, o.Name or "Keybind", {Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -110, 1, 0)})
        local kb = create("TextButton", {
            Position = UDim2.new(1, -94, 0.5, -13), Size = UDim2.fromOffset(82, 26),
            BackgroundColor3 = Theme.Background, Text = key.Name, Font = Enum.Font.Code,
            TextSize = 12, TextColor3 = Theme.Accent, AutoButtonColor = false, Parent = f,
        }, {corner(6)})
        bind(kb, "BackgroundColor3", "Background")
        bind(kb, "TextColor3", "Accent")
        local ks = create("UIStroke", {Color = Theme.Stroke, Transparency = 0.2, Parent = kb})
        bind(ks, "Color", "Stroke")

        connect(kb.MouseButton1Click, function()
            listening = true
            kb.Text = "..."
            tween(ks, {Color = Theme.Accent, Transparency = 0}, 0.2)
        end)
        connect(UserInputService.InputBegan, function(input, processed)
            if listening then
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    listening = false
                    if input.KeyCode ~= Enum.KeyCode.Escape then
                        key = input.KeyCode
                        if o.Flag then
                            Library.Flags[o.Flag] = key
                        end
                        safeCall(o.Changed, key)
                    end
                    kb.Text = key.Name
                    tween(ks, {Color = Theme.Stroke, Transparency = 0.2}, 0.25)
                end
            elseif not processed and input.KeyCode == key then
                safeCall(o.Callback, key)
            end
        end)
        local obj = {}
        function obj:Set(k)
            key = k
            kb.Text = k.Name
            if o.Flag then
                Library.Flags[o.Flag] = k
            end
            safeCall(o.Changed, k)
        end
        function obj:Get()
            return key
        end
        register(o, function(v)
            if v then
                obj:Set(v)
            end
        end)
        if o.Flag then
            Library.Flags[o.Flag] = key
        end
        return obj
    end

    ---------------------------------------------------------------------
    -- Tabs + collapsible sections
    ---------------------------------------------------------------------

    local ELEMENT_NAMES = {
        "Label", "Paragraph", "Button", "Toggle", "Slider",
        "Dropdown", "Textbox", "Keybind", "Divider",
    }

    local function paintChips(animate)
        for _, t in ipairs(Window.Tabs) do
            local on = Window.Active == t
            local bgColor = on and WHITE or Theme.Element
            local strokeColor = on and Theme.Accent or Theme.Stroke
            local textColor = on and Theme.OnAccent or Theme.SubText
            if tabBar then
                bgColor = on and Theme.Section or Theme.Topbar
                textColor = on and Theme.Text or Theme.SubText
            end
            local highlight = UIFlags.HighlightTabs ~= false
            if not highlight then
                -- "Highlight Tab" is off: the selected tab is only a little brighter, nothing is lit up
                bgColor = tabBar and (on and Theme.Section or Theme.Topbar) or Theme.Element
                strokeColor = Theme.Stroke
                textColor = on and Theme.Text or Theme.SubText
            end
            t.ChipGrad.Enabled = on and not tabBar and highlight
            if animate then
                tween(t.Chip, {BackgroundColor3 = bgColor}, 0.2)
                tween(t.ChipStroke, {Color = strokeColor}, 0.2)
                tween(t.ChipLbl, {TextColor3 = textColor}, 0.2)
            else
                t.Chip.BackgroundColor3 = bgColor
                t.ChipStroke.Color = strokeColor
                t.ChipLbl.TextColor3 = textColor
            end
        end
    end
    themed(function(animate)
        paintChips(animate)
    end)

    local function updateTabCount()
        local idx = 0
        for i, t in ipairs(Window.Tabs) do
            if t == Window.Active then
                idx = i
            end
        end
        tabCountLbl.Text = idx .. "/" .. #Window.Tabs
    end

    ---------------------------------------------------------------------
    -- Information: customize toggles (normal toggle elements inside a dashboard card)
    ---------------------------------------------------------------------
    do
        panelHeader(dash, "CUSTOMIZE", "toggles")
        local card = dashCard(150)
        local function column(xScale, xOff)
            return create("Frame", {
                Position = UDim2.new(xScale, xOff, 0, 10), Size = UDim2.new(0.5, -15, 1, -20), BackgroundTransparency = 1, Parent = card,
            }, {create("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder})})
        end
        local colL, colR = column(0, 10), column(0.5, 5)
        E.Toggle(colL, {
            Name = "Highlight Tab", Default = true, Flag = "UI_HighlightTab",
            Tooltip = "On: the selected tab button is lit up. Off: no highlight.",
            Callback = function(v)
                UIFlags.HighlightTabs = v
                paintChips(true)
            end,
        })
        E.Toggle(colL, {
            Name = "Window Glow", Default = glowMul == 1, Flag = "UI_Glow",
            Tooltip = "The soft colored glow around the window",
            Callback = function(v)
                glowMul = v and 1 or 0
            end,
        })
        E.Toggle(colL, {
            Name = "Title Line", Default = true, Flag = "UI_TitleLine",
            Tooltip = "The line under the title bar",
            Callback = function(v)
                line.Visible = v
            end,
        })
        E.Toggle(colR, {
            Name = "Animated Border", Default = true, Flag = "UI_SpinBorder",
            Tooltip = "The border color slowly rotates",
            Callback = function(v)
                UIFlags.SpinBorder = v
            end,
        })
        E.Toggle(colR, {
            Name = "Show Live Stats", Default = true, Flag = "UI_ShowStats",
            Tooltip = "FPS / ping / session tiles in this panel",
            Callback = function(v)
                local row = dash:FindFirstChild("StatsRow")
                if row then
                    row.Visible = v
                end
            end,
        })
        E.Toggle(colR, {
            Name = "Notifications", Default = true, Flag = "UI_Notifs",
            Tooltip = "Turn all notification cards on or off",
            Callback = function(v)
                UIFlags.Notifs = v
            end,
        })
    end

    function Window:CreateTab(name)
        name = name or "Tab"
        local Tab = {Name = name, Sections = {}, NextSide = "Left"}

        -- chip inside the top-center tab menu
        local chipW = textWidth(name, 12, Enum.Font.GothamMedium) + 30
        local chip = create("TextButton", {
            Size = UDim2.fromOffset(chipW, tabBar and (TABBAR - 6) or 30), Position = UDim2.fromOffset(10, 10),
            BackgroundColor3 = Theme.Element, Text = "", AutoButtonColor = false, Parent = tabBar or menu,
        }, {corner(6)})
        local chipStroke = create("UIStroke", {Color = Theme.Stroke, Transparency = 0.25, Parent = chip})
        local chipLbl = create("TextLabel", {
            Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = name,
            Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Theme.SubText, Parent = chip,
        })
        local chipScale = create("UIScale", {Parent = chip})
        local chipGrad = accentGrad(chip, 0)
        chipGrad.Enabled = false
        Tab.Chip, Tab.ChipWidth, Tab.ChipLbl, Tab.ChipStroke = chip, chipW, chipLbl, chipStroke
        Tab.ChipScale, Tab.ChipGrad = chipScale, chipGrad

        connect(chip.MouseEnter, function()
            if Window.Active ~= Tab then
                tween(chip, {BackgroundColor3 = Theme.ElementHover}, 0.15)
                tween(chipLbl, {TextColor3 = Theme.Text}, 0.15)
            end
        end)
        connect(chip.MouseLeave, function()
            if Window.Active ~= Tab then
                tween(chip, {BackgroundColor3 = Theme.Element}, 0.2)
                tween(chipLbl, {TextColor3 = Theme.SubText}, 0.2)
            end
        end)

        -- page: fading CanvasGroup with two columns
        local holder = create("CanvasGroup", {
            Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
            GroupTransparency = 1, Visible = false, Parent = pageArea,
        })
        local scroll = create("ScrollingFrame", {
            Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0,
            ScrollBarThickness = 3, ScrollBarImageColor3 = Theme.Accent, CanvasSize = UDim2.new(), Parent = holder,
        })
        bind(scroll, "ScrollBarImageColor3", "Accent")
        Tab.Holder = holder

        local function makeColumn(xScale, xOff)
            local col = create("Frame", {
                Position = UDim2.new(xScale, xOff, 0, 0), Size = UDim2.new(0.5, -8, 0, 0),
                BackgroundTransparency = 1, Parent = scroll,
            })
            local lay = create("UIListLayout", {Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder, Parent = col})
            return col, lay
        end
        local leftCol, leftLay = makeColumn(0, 0)
        local rightCol, rightLay = makeColumn(0.5, 2)

        local function updateCanvas()
            local h = math.max(leftLay.AbsoluteContentSize.Y, rightLay.AbsoluteContentSize.Y)
            scroll.CanvasSize = UDim2.fromOffset(0, h + 12)
        end
        connect(leftLay:GetPropertyChangedSignal("AbsoluteContentSize"), updateCanvas)
        connect(rightLay:GetPropertyChangedSignal("AbsoluteContentSize"), updateCanvas)

        function Tab:Select()
            if Window.Active == Tab then
                setMenu(false)
                return
            end
            local prev = Window.Active
            Window.Active = Tab
            updateTabCount()
            setDashboard(name == dashTabName, dashShown ~= nil)
            if prev then
                local ph = prev.Holder
                local t = tween(ph, {GroupTransparency = 1}, 0.15)
                t.Completed:Connect(function()
                    if Window.Active ~= prev then
                        ph.Visible = false
                    end
                end)
            end
            holder.Position = UDim2.fromOffset(0, 16)
            holder.GroupTransparency = 1
            holder.Visible = not (cfg.Dashboard ~= false and name == dashTabName)   -- the dashboard tab only shows the dashboards
            tween(holder, {GroupTransparency = 0, Position = UDim2.fromOffset(0, 0)}, 0.42)
            tabBtnLbl.Text = name
            tabBtnLbl.TextTransparency = 1
            tween(tabBtnLbl, {TextTransparency = 0}, 0.3)
            paintChips(true)
            setMenu(false)
        end
        connect(chip.MouseButton1Click, function()
            Tab:Select()
        end)

        -- sections ---------------------------------------------------------
        function Tab:CreateSection(o)
            if type(o) == "string" then
                o = {Name = o}
            end
            o = o or {}
            local side = o.Side
            if side ~= "Left" and side ~= "Right" then
                side = Tab.NextSide
                Tab.NextSide = (Tab.NextSide == "Left") and "Right" or "Left"
            end
            local col = (side == "Left") and leftCol or rightCol

            local Section = {Count = 0, Collapsed = o.Collapsed == true, Side = side}
            local HEADER = 36
            local collapsed = Section.Collapsed
            local animating, animToken = false, 0

            local frame = create("Frame", {
                Size = UDim2.new(1, 0, 0, HEADER), BackgroundColor3 = Theme.Section, BackgroundTransparency = 0.12,
                BorderSizePixel = 0, ClipsDescendants = true, Parent = col,
            }, {corner(8)})
            bind(frame, "BackgroundColor3", "Section")
            local frameStroke = create("UIStroke", {Color = Theme.Stroke, Transparency = 0.3, Parent = frame})
            bind(frameStroke, "Color", "Stroke")
            create("UIGradient", {Color = ColorSequence.new(WHITE, rgb(222, 222, 234)), Rotation = 90, Parent = frame})

            local hdr = create("TextButton", {
                Size = UDim2.new(1, 0, 0, HEADER), BackgroundColor3 = Theme.Element, BackgroundTransparency = 1,
                Text = "", AutoButtonColor = false, ClipsDescendants = true, Parent = frame,
            }, {corner(8)})
            connect(hdr.MouseEnter, function()
                tween(hdr, {BackgroundTransparency = 0.55}, 0.15)
                tween(frameStroke, {Color = Theme.Accent, Transparency = 0.35}, 0.2)
            end)
            connect(hdr.MouseLeave, function()
                tween(hdr, {BackgroundTransparency = 1}, 0.2)
                tween(frameStroke, {Color = Theme.Stroke, Transparency = 0.3}, 0.25)
            end)
            connect(hdr.InputBegan, function(input)
                if isPress(input) then
                    ripple(hdr, input)
                end
            end)

            local accentBar = create("Frame", {
                Position = UDim2.fromOffset(10, 11), Size = UDim2.fromOffset(3, 14),
                BackgroundColor3 = WHITE, BorderSizePixel = 0, Parent = hdr,
            }, {round()})
            accentGrad(accentBar, 90)
            local secTitle = label(hdr, o.Name or "Section", {
                Position = UDim2.fromOffset(22, 0), Size = UDim2.new(1, -90, 1, 0),
                Font = Enum.Font.GothamBold, TextSize = 13, TextTruncate = Enum.TextTruncate.AtEnd,
            })
            local countBox = create("Frame", {
                Position = UDim2.new(1, -58, 0.5, -8), Size = UDim2.fromOffset(24, 16),
                BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.86, BorderSizePixel = 0, Parent = hdr,
            }, {corner(4)})
            bind(countBox, "BackgroundColor3", "Accent")
            local countLbl = label(countBox, "0", {
                Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center,
                Font = Enum.Font.Code, TextSize = 11,
            }, "Accent")
            local chev = label(hdr, ">", {
                Position = UDim2.new(1, -28, 0, 0), Size = UDim2.fromOffset(18, HEADER),
                TextXAlignment = Enum.TextXAlignment.Center, Font = Enum.Font.GothamBold,
                Rotation = collapsed and 0 or 90,
            }, "Accent")

            local body = create("Frame", {
                Position = UDim2.fromOffset(0, HEADER), Size = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 1, Visible = not collapsed, Parent = frame,
            })
            local lay = create("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = body})
            create("UIPadding", {
                PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 2), Parent = body,
            })

            local hdrLine = create("Frame", {
                Position = UDim2.fromOffset(10, HEADER - 1), Size = UDim2.new(1, -20, 0, 1), BackgroundColor3 = WHITE,
                BackgroundTransparency = collapsed and 1 or 0.45, BorderSizePixel = 0, Parent = frame,
            }, {round()})
            local hlg = accentGrad(hdrLine, 0)
            hlg.Transparency = NumberSequence.new(0.1, 1)

            local function targetHeight()
                if collapsed then
                    return HEADER
                end
                return HEADER + lay.AbsoluteContentSize.Y + 12
            end
            local function refresh()
                if not animating then
                    frame.Size = UDim2.new(1, 0, 0, targetHeight())
                end
            end
            connect(lay:GetPropertyChangedSignal("AbsoluteContentSize"), refresh)

            function Section:SetCollapsed(state)
                state = state and true or false
                if state == collapsed then
                    return
                end
                collapsed = state
                Section.Collapsed = state
                animToken = animToken + 1
                local mine = animToken
                animating = true
                if not state then
                    body.Visible = true
                end
                tween(chev, {Rotation = state and 0 or 90}, 0.3, Enum.EasingStyle.Back)
                tween(hdrLine, {BackgroundTransparency = state and 1 or 0.45}, 0.3)
                local t = tween(frame, {Size = UDim2.new(1, 0, 0, targetHeight())}, 0.34)
                t.Completed:Connect(function()
                    if mine ~= animToken then
                        return
                    end
                    animating = false
                    if collapsed then
                        body.Visible = false
                    end
                    refresh()
                end)
            end
            function Section:Toggle()
                Section:SetCollapsed(not collapsed)
            end
            function Section:SetTitle(text)
                secTitle.Text = text
            end
            connect(hdr.MouseButton1Click, function()
                Section:Toggle()
            end)

            for _, elementName in ipairs(ELEMENT_NAMES) do
                Section["Create" .. elementName] = function(_, opts)
                    Section.Count = Section.Count + 1
                    countLbl.Text = tostring(Section.Count)
                    return E[elementName](body, opts or {})
                end
            end

            refresh()
            table.insert(Tab.Sections, Section)
            return Section
        end

        function Tab:CreateLeftSection(o)
            if type(o) == "string" then
                o = {Name = o}
            end
            o = o or {}
            o.Side = "Left"
            return Tab:CreateSection(o)
        end

        function Tab:CreateRightSection(o)
            if type(o) == "string" then
                o = {Name = o}
            end
            o = o or {}
            o.Side = "Right"
            return Tab:CreateSection(o)
        end

        table.insert(Window.Tabs, Tab)
        reflowTabs()
        paintChips(false)
        updateTabCount()
        if #Window.Tabs == 1 then
            Tab:Select()
        end
        return Tab
    end

    ---------------------------------------------------------------------
    -- Render loop: smooth dragging (window + minimized button), backdrop
    -- (dim / real blur / screen snow), glow, logo / title / tag animation
    ---------------------------------------------------------------------
    local clock = 0
    local lastX = posX
    local lastPX = pillPos.X
    local lastScr = 0
    local winVX = 0

    connect(RunService.RenderStepped, function(dt)
        dt = math.min(dt, 0.1)
        clock = clock + dt
        local a = 1 - math.exp(-dt * 16)

        -- minimized button: eased drag, pulsing glow, its own snow
        if pillRoot.Visible then
            pillPos = pillPos:Lerp(pillTgt, a)
            pillRoot.Position = UDim2.fromOffset(math.floor(pillPos.X + PW / 2 + 0.5), math.floor(pillPos.Y + PH / 2 + 0.5))
            local pvx = (pillPos.X - lastPX) / math.max(dt, 0.001)
            lastPX = pillPos.X
            pRingGrad.Rotation = (clock * 60) % 360
            pLogoGrad.Rotation = (clock * 100) % 360
            pillGlowFx.apply(math.max(0, (1 - Theme.HaloT) * 1.4 + math.sin(clock * 1.8) * 0.15))
            if snowOn and pillField then
                stepSnowField(pillField, dt, clock, math.clamp(-pvx * 0.15, -60, 60) + 6, nil, nil, 1)
            end
        end

        -- backdrop: dim, real blur and screen-wide snow only while the GUI is open
        backdrop = backdrop + (backdropTarget - backdrop) * (1 - math.exp(-dt * 9))
        if math.abs(backdropTarget - backdrop) < 0.003 then
            backdrop = backdropTarget
        end
        dim.Visible = backdrop > 0.004
        dim.BackgroundTransparency = 1 - dimAlpha * backdrop
        bdFx.apply(backdrop, blurSize, blurOn)
        local showScreen = screenSnowOn and backdrop > 0.01
        screenHolder.Visible = showScreen
        if showScreen then
            if clock - lastScr > 0.5 then
                lastScr = clock
                local s = screenSize()
                screenField.w, screenField.h = s.X, s.Y
            end
            local mp = UserInputService:GetMouseLocation()
            local windT = math.sin(clock * 0.4) * 14 + math.clamp(-winVX * 0.1, -80, 80)
            stepSnowField(screenField, dt, clock, windT, mp.X, mp.Y, backdrop)
        end

        -- element / notification / dashboard updaters
        for _, fn in ipairs(updaters) do
            local ok, err = pcall(fn, dt, clock)
            if not ok then
                warn("[DH UI] updater error: " .. tostring(err))
            end
        end

        -- loader
        if loader then
            local ok, err = pcall(loader.step, dt, clock)
            if not ok then
                warn("[DH UI] loader error: " .. tostring(err))
                pcall(function()
                    loader.panel:Destroy()
                end)
                loader = nil
                Window.Loading = false
                Window:SetVisible(true)
            end
        end

        if not root.Visible then
            return
        end

        -- window eases toward its target (smooth dragging) + show / hide slide
        posX = posX + (tgtX - posX) * a
        posY = posY + (tgtY - posY) * a
        slide = slideVal.Value
        root.Position = UDim2.fromOffset(math.floor(posX + 0.5), math.floor(posY + slide + 0.5))
        winVX = (posX - lastX) / math.max(dt, 0.001)
        lastX = posX

        -- outer glow pulses in the theme color
        glowVis = glowVis + ((windowOn and 1 or 0) - glowVis) * (1 - math.exp(-dt * 8))
        glowFx.apply(math.max(0, ((1 - Theme.HaloT) * 1.6 + math.sin(clock * 1.7) * 0.18) * glowVis * glowMul))
        dropFx.apply(1.2 * glowVis * glowMul)

        -- ambient animation
        for i, ob in ipairs(orbs) do
            local sp = ob.spec
            ob.f.Position = UDim2.fromScale(
                sp.x + math.sin(clock * sp.sx + i) * 0.07,
                sp.y + math.cos(clock * sp.sy + i * 1.7) * 0.07
            )
        end
        if UIFlags.SpinBorder then
            borderGrad.Rotation = (clock * 45) % 360
        end
        lineGrad.Offset = Vector2.new(math.sin(clock * 1.3) * 0.4, 0)
        titleGrad.Offset = Vector2.new(math.sin(clock * 1.2) * 0.45, 0)
        avRingGrad.Rotation = (clock * 70) % 360
        onlineDot.BackgroundTransparency = (math.sin(clock * 3) + 1) / 2 * 0.35
        if tagDot then
            tagDot.BackgroundTransparency = 0.05 + (math.sin(clock * 3) + 1) / 2 * 0.55
        end
        if tagShine then
            tagShine.Position = UDim2.new(((clock * 0.55) % 2.4) - 0.7, 0, 0.5, 0)
        end

        -- snow inside the window
        if snowOn then
            local mp = UserInputService:GetMouseLocation()
            local org = main.AbsolutePosition
            local windT = math.clamp(-winVX * 0.3, -150, 150) + math.sin(clock * 0.35) * 10 + (snowCfg.Wind or 0)
            for _, fld in ipairs(snowFields) do
                stepSnowField(fld, dt, clock, windT, mp.X - org.X, mp.Y - org.Y, 1)
            end
        end
    end)

    if useLoader then
        startLoader()
    end

    return Window
end

---------------------------------------------------------------------
-- Key system (ordinary key check, no game detection)
--
--   Library:KeySystem({
--       Title = "DEXPS", Subtitle = "KEY SYSTEM", Theme = "Black" | "Crimson" | "Violet",
--       CorrectKey = "...", MaxTries = 3, SaveKey = false, KeyFile = "Key.txt",
--       Url = { Lootlabs = "https://...", Linkvertise = "https://..." },   -- Get Key dropdown
--       BlurSize = 56,                                                      -- real blur strength (max 56)
--       OnSuccess = function() end  (or a link / code string),             -- runs after a correct key
--   })
--
-- Shows the key window (real blur, dim 0.45, snow, themed glow). Wrong keys shake the window and notify;
-- after MaxTries wrong keys the player is kicked. A correct key closes the window and runs OnSuccess.
---------------------------------------------------------------------
function Library:KeySystem(cfg)
    cfg = cfg or {}
    local CorrectKey = tostring(cfg.CorrectKey or "")
    local MaxTries = tonumber(cfg.MaxTries) or 3
    local SaveKey = cfg.SaveKey == true
    local KeyFile = cfg.KeyFile or "Key.txt"
    local Url = type(cfg.Url) == "table" and cfg.Url or {}
    local KS_TITLE = cfg.Title or "KEY SYSTEM"
    local KS_SUB = cfg.Subtitle or "VERIFICATION"
    local KS_NAME = cfg.Name or "DH_KeySystem"
    local T = Themes[cfg.Theme or ""] or Themes.Black
    local GOOD = rgb(88, 214, 141)
    local BAD = rgb(240, 84, 96)
    local WARN = rgb(240, 190, 80)

    ----------------------------------------------------------------
    -- SERVICES / HELPERS
    ----------------------------------------------------------------
    local Players            = game:GetService("Players")
    local TweenService       = game:GetService("TweenService")
    local RunService         = game:GetService("RunService")
    local Lighting           = game:GetService("Lighting")
    local StatsService       = game:GetService("Stats")
    local UIS                = game:GetService("UserInputService")
    local LocalPlayer        = Players.LocalPlayer

    local setclip = setclipboard or toclipboard or (syn and syn.write_clipboard) or (Clipboard and Clipboard.set)
    local rng = Random.new()
    local WHITE = Color3.new(1, 1, 1)
    local alive = true

    local Left, Center, Right = Enum.TextXAlignment.Left, Enum.TextXAlignment.Center, Enum.TextXAlignment.Right
    local Bold, Med, Reg = Enum.Font.GothamBold, Enum.Font.GothamMedium, Enum.Font.Gotham

    local function new(class, props, parent)
        local o = Instance.new(class)
        for k, v in pairs(props) do o[k] = v end
        if parent then o.Parent = parent end
        return o
    end

    local function tween(o, t, props, style, dir)
        local tw = TweenService:Create(o, TweenInfo.new(t, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
        tw:Play()
        return tw
    end

    local function corner(o, r) return new("UICorner", { CornerRadius = UDim.new(0, r) }, o) end
    local function stroke(o, color, th)
        return new("UIStroke", { Color = color, Thickness = th or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, o)
    end
    local function pad(o, l, r)
        return new("UIPadding", { PaddingLeft = UDim.new(0, l or 0), PaddingRight = UDim.new(0, r or 0) }, o)
    end

    local function label(parent, text, size, color, font, pos, sz, align)
        return new("TextLabel", {
            Text = text, TextSize = size, TextColor3 = color, Font = font or Reg,
            BackgroundTransparency = 1, Position = pos, Size = sz, TextXAlignment = align or Left,
        }, parent)
    end

    local function makeChevron(parent, pos, color)
        local c = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = pos, Size = UDim2.fromOffset(14, 14), BackgroundTransparency = 1,
        }, parent)
        for _, cfg in ipairs({ { 4, 45 }, { 10, -45 } }) do
            local b = new("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(cfg[1], 7),
                Size = UDim2.fromOffset(8, 2), Rotation = cfg[2], BackgroundColor3 = color or T.Text, BorderSizePixel = 0,
            }, c)
            corner(b, 1)
        end
        return c
    end

    -- Button: gradient fill (primary) or glass (ghost), hover lift, press squish, click ripple
    local function makeButton(parent, text, pos, size, style, noScale)
        local primary = style == "primary"
        local root = new("CanvasGroup", {
            Position = pos, Size = size, BorderSizePixel = 0,
            BackgroundColor3 = T.Element, BackgroundTransparency = primary and 1 or 0,
        }, parent)
        corner(root, 10)
        local st = stroke(root, primary and T.Accent2 or T.Stroke, 1)

        local grad
        if primary then
            local fill = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = WHITE, BorderSizePixel = 0 }, root)
            grad = new("UIGradient", { Color = ColorSequence.new(T.Accent, T.Accent2), Rotation = 0 }, fill)
            st.Transparency = 0.55
        end

        local lbl = new("TextLabel", {
            Text = text, Font = Bold, TextSize = 13, BackgroundTransparency = 1,
            TextColor3 = primary and T.OnAccent or T.Text, Size = UDim2.fromScale(1, 1),
        }, root)
        local hit = new("TextButton", { Text = "", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 10 }, root)
        local sc = new("UIScale", {}, root)
        local hovering = false

        hit.MouseEnter:Connect(function()
            hovering = true
            if not noScale then tween(sc, 0.2, { Scale = 1.025 }) end
            if primary then
                tween(grad, 0.35, { Offset = Vector2.new(0.3, 0) })
                tween(st, 0.2, { Transparency = 0 })
            else
                tween(root, 0.2, { BackgroundColor3 = T.ElementHover })
                tween(st, 0.2, { Color = T.Accent2 })
            end
        end)
        hit.MouseLeave:Connect(function()
            hovering = false
            tween(sc, 0.2, { Scale = 1 })
            if primary then
                tween(grad, 0.35, { Offset = Vector2.new(0, 0) })
                tween(st, 0.2, { Transparency = 0.55 })
            else
                tween(root, 0.2, { BackgroundColor3 = T.Element })
                tween(st, 0.2, { Color = T.Stroke })
            end
        end)
        hit.MouseButton1Down:Connect(function(x)
            tween(sc, 0.1, { Scale = 0.96 })
            local rx = math.clamp((x - root.AbsolutePosition.X) / math.max(root.AbsoluteSize.X, 1), 0, 1)
            local r = new("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(rx, 0.5),
                Size = UDim2.fromOffset(0, 0), BackgroundColor3 = primary and T.OnAccent or WHITE,
                BackgroundTransparency = 0.82, BorderSizePixel = 0, ZIndex = 6,
            }, root)
            corner(r, 400)
            tween(r, 0.55, { Size = UDim2.fromOffset(340, 340), BackgroundTransparency = 1 })
            task.delay(0.6, function() r:Destroy() end)
        end)
        hit.MouseButton1Up:Connect(function()
            tween(sc, 0.18, { Scale = (hovering and not noScale) and 1.025 or 1 }, Enum.EasingStyle.Back)
        end)

        return { Root = root, Hit = hit, Label = lbl, Stroke = st }
    end

    ----------------------------------------------------------------
    -- LINKS + SUCCESS ACTION
    ----------------------------------------------------------------
    local urlNames = {}
    for name in pairs(Url) do table.insert(urlNames, name) end
    table.sort(urlNames)

    local function runSuccess()
        local ok, err = pcall(function()
            local act = cfg.OnSuccess or cfg.Script
            if type(act) == "function" then
                act({ Key = CorrectKey })
            elseif type(act) == "string" then
                if act:match("^https?://") then loadstring(game:HttpGet(act))()
                else loadstring(act)() end
            end
        end)
        if not ok then warn("[KeySystem] script error: " .. tostring(err)) end
    end

    ----------------------------------------------------------------
    -- LAYOUT CONSTANTS
    ----------------------------------------------------------------
    local W, TOP_H, BODY_H = 440, 56, 228
    local H0 = TOP_H + BODY_H
    local ROWS = math.min(math.max(#urlNames, 1), 3)
    local DROP_H = 34 + ROWS * 36 + 6
    local DD = DROP_H + 8
    local HMAX = H0 + DD
    local TOP0 = (HMAX - H0) / 2
    local LOWER_Y = 158

    ----------------------------------------------------------------
    -- GUI ROOT + BACKGROUND (blur 30, dim 0.45)
    ----------------------------------------------------------------
    local host
    do
        local ok, r = pcall(function() return (gethui and gethui()) or game:GetService("CoreGui") end)
        host = (ok and r) or LocalPlayer:WaitForChild("PlayerGui")
    end
    do
        local old = host:FindFirstChild(KS_NAME)
        if old then old:Destroy() end
    end
    for _, v in ipairs(Lighting:GetChildren()) do
        if v.Name == KS_NAME .. "_Blur" or v.Name == KS_NAME .. "_DoF" then v:Destroy() end
    end

    local Gui = new("ScreenGui", {
        Name = KS_NAME, IgnoreGuiInset = true, ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999,
    })
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(Gui) end end)
    Gui.Parent = host

    local BlurFx = newBackdropFx(KS_NAME)
    local Dim = new("Frame", {
        Size = UDim2.fromScale(1, 1), BackgroundColor3 = T.Dim,
        BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 1,
    }, Gui)

    ----------------------------------------------------------------
    -- PARTICLES: glow orbs, snow, sparkles
    ----------------------------------------------------------------
    local function makeOrb(parent, color, diameter)
        local o = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(diameter, diameter), BackgroundTransparency = 1,
        }, parent)
        for i = 1, 10 do
            local k = 1 - (i - 1) * 0.09
            local c = new("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromScale(k, k), BackgroundColor3 = color,
                BackgroundTransparency = 0.978, BorderSizePixel = 0,
            }, o)
            corner(c, 2000)
        end
        return o
    end

    local orbs = {}
    local function addOrb(parent, color, diameter, ax, ay, sp, ph)
        table.insert(orbs, { o = makeOrb(parent, color, diameter), ax = ax, ay = ay, sp = sp, ph = ph })
    end
    local function stepOrbs(t)
        for _, b in ipairs(orbs) do
            b.o.Position = UDim2.fromScale(
                0.5 + math.cos(t * b.sp + b.ph) * b.ax,
                0.5 + math.sin(t * b.sp * 1.3 + b.ph) * b.ay
            )
        end
    end

    local function makeSnow(parent, count, minS, maxS, minSp, maxSp)
        local list = {}
        for i = 1, count do
            local d = rng:NextNumber()
            local size = minS + (maxS - minS) * d
            local base = 0.8 - 0.55 * d
            local f = new("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(size, size),
                BackgroundColor3 = T.Snow, BackgroundTransparency = base, BorderSizePixel = 0,
            }, parent)
            corner(f, 100)
            list[i] = {
                f = f, d = d, base = base, x = rng:NextNumber(), y = rng:NextNumber(),
                sp = minSp + (maxSp - minSp) * d, ph = rng:NextNumber(0, 6.28),
                fr = rng:NextNumber(0.6, 1.6), sw = rng:NextNumber(0.004, 0.016), tw = rng:NextNumber(1, 3),
            }
        end
        return list
    end

    local function stepSnow(list, dt, t)
        local wind = math.sin(t * 0.35) * 0.012 + 0.004
        for _, s in ipairs(list) do
            s.y += s.sp * dt
            s.x += wind * (0.5 + s.d) * dt
            if s.y > 1.04 then s.y = -0.04; s.x = rng:NextNumber() end
            if s.x > 1.05 then s.x = -0.05 elseif s.x < -0.05 then s.x = 1.05 end
            s.f.Position = UDim2.fromScale(s.x + math.sin(t * s.fr + s.ph) * s.sw, s.y)
            s.f.BackgroundTransparency = math.clamp(s.base + math.sin(t * s.tw + s.ph) * 0.12, 0, 1)
        end
    end

    local OrbsBG = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 2, ClipsDescendants = true }, Gui)
    addOrb(OrbsBG, T.Glow, 720, 0.30, 0.25, 0.11, 0)
    addOrb(OrbsBG, T.Glow2, 620, 0.38, 0.28, 0.08, 2.1)
    addOrb(OrbsBG, T.Accent2, 520, 0.28, 0.32, 0.06, 4.2)

    local SnowBG = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 3, ClipsDescendants = true }, Gui)
    local snowBG = makeSnow(SnowBG, 90, 2, 7, 0.04, 0.15)

    ----------------------------------------------------------------
    -- STAGE + MAIN WINDOW
    ----------------------------------------------------------------
    local Stage = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(W, HMAX), BackgroundTransparency = 1, ZIndex = 4,
    }, Gui)
    local Scale = new("UIScale", {}, Stage)
    local BASE_SCALE, introDone = 1, false
    local function rescale()
        local cam = workspace.CurrentCamera
        if cam then
            local vs = cam.ViewportSize
            BASE_SCALE = math.clamp(math.min(vs.Y / (HMAX + 50), vs.X / (W + 20)), 0.5, 1)
        end
        if introDone then Scale.Scale = BASE_SCALE end
    end
    rescale()
    Scale.Scale = BASE_SCALE * 0.9
    pcall(function()
        workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(rescale)
    end)

    local glowOn, glowK = false, 0
    local glowStrength = (1 - (T.HaloT or 0.4)) * 1.6
    local DropFx = newGlow(Stage, 36, 10, 12, Color3.new(0, 0, 0))
    local GlowFx = newGlow(Stage, 46, 14, 12, T.Halo)

    local Main = new("CanvasGroup", {
        Name = "Main", Position = UDim2.fromOffset(0, TOP0), Size = UDim2.fromOffset(W, H0),
        BackgroundTransparency = 1, BorderSizePixel = 0, GroupTransparency = 1,
    }, Stage)
    corner(Main, 16)
    local MainStroke = stroke(Main, WHITE, 1.5)
    local StrokeGrad = new("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, T.Glow), ColorSequenceKeypoint.new(0.5, T.Glow2), ColorSequenceKeypoint.new(1, T.Glow),
        }),
    }, MainStroke)

    local Bg = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = WHITE, BorderSizePixel = 0, ZIndex = 0 }, Main)
    local BgGrad = new("UIGradient", { Color = ColorSequence.new(T.Background, T.Background2), Rotation = 90 }, Bg)

    local OrbsIn = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 1, ClipsDescendants = true }, Main)
    addOrb(OrbsIn, T.Glow, 320, 0.35, 0.30, 0.20, 1)
    addOrb(OrbsIn, T.Glow2, 280, 0.30, 0.30, 0.16, 3.4)

    local SnowIn = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 2, ClipsDescendants = true }, Main)
    local snowIn = makeSnow(SnowIn, 36, 2, 5, 0.07, 0.22)

    -- sheen: a soft diagonal shine that sweeps across the window
    local Sheen = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.new(0, 130, 1.5, 0), Rotation = 18,
        BackgroundColor3 = WHITE, BorderSizePixel = 0, ZIndex = 50,
    }, Main)
    new("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0.93), NumberSequenceKeypoint.new(1, 1),
        }),
    }, Sheen)

    -- sparkles (little twinkling stars)
    local sparkles = {}
    for i = 1, 7 do
        local s = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 1 }, SnowIn)
        new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(1, 0, 0, 2), BackgroundColor3 = T.Accent2, BackgroundTransparency = 0.15, BorderSizePixel = 0 }, s)
        new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(0, 2, 1, 0), BackgroundColor3 = T.Accent2, BackgroundTransparency = 0.15, BorderSizePixel = 0 }, s)
        sparkles[i] = {
            f = s, t = rng:NextNumber(0, 2), life = rng:NextNumber(1.4, 2.6),
            x = rng:NextNumber(0.05, 0.95), y = rng:NextNumber(0.1, 0.95), size = rng:NextNumber(8, 15),
        }
    end
    local function stepSparkles(dt)
        for _, s in ipairs(sparkles) do
            s.t += dt
            if s.t >= s.life then
                s.t = 0
                s.life = rng:NextNumber(1.4, 2.6)
                s.x = rng:NextNumber(0.05, 0.95)
                s.y = rng:NextNumber(0.1, 0.95)
                s.size = rng:NextNumber(8, 15)
            end
            local k = math.sin(math.pi * s.t / s.life)
            local sz = s.size * k
            s.f.Size = UDim2.fromOffset(sz, sz)
            s.f.Position = UDim2.fromScale(s.x, s.y)
            s.f.Rotation = s.t * 80
        end
    end

    -- shine sweep across the window
    local Shine = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, -120, 0.5, 0), Size = UDim2.new(0, 70, 1.8, 0),
        Rotation = 18, BackgroundColor3 = WHITE, BackgroundTransparency = 0.93, BorderSizePixel = 0, ZIndex = 30,
    }, Main)
    new("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 1),
        }),
    }, Shine)
    task.spawn(function()
        while alive do
            task.wait(rng:NextNumber(5, 9))
            if not alive then break end
            Shine.Position = UDim2.new(0, -120, 0.5, 0)
            tween(Shine, 1.4, { Position = UDim2.new(0, W + 120, 0.5, 0) }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut).Completed:Wait()
        end
    end)

    ----------------------------------------------------------------
    -- TOPBAR (draggable)
    ----------------------------------------------------------------
    local Top = new("Frame", {
        Size = UDim2.new(1, 0, 0, TOP_H), BackgroundColor3 = T.Topbar, BackgroundTransparency = 0.15,
        BorderSizePixel = 0, ZIndex = 4, Active = true,
    }, Main)

    -- logo: spinning gradient diamond
    local Logo = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(32, 28), Size = UDim2.fromOffset(20, 20),
        BackgroundColor3 = WHITE, BorderSizePixel = 0, Rotation = 45,
    }, Top)
    corner(Logo, 5)
    new("UIGradient", { Color = ColorSequence.new(T.Accent, T.Accent2), Rotation = 45 }, Logo)
    local LogoIn = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(8, 8),
        BackgroundColor3 = T.Topbar, BorderSizePixel = 0,
    }, Logo)
    corner(LogoIn, 2)

    local Title = label(Top, KS_TITLE, 21, WHITE, Bold, UDim2.fromOffset(52, 9), UDim2.fromOffset(110, 26))
    local TitleGrad = new("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, T.Accent), ColorSequenceKeypoint.new(0.5, T.Accent2), ColorSequenceKeypoint.new(1, T.Accent),
        }),
    }, Title)
    label(Top, KS_SUB, 9, T.SubText, Bold, UDim2.fromOffset(53, 35), UDim2.fromOffset(110, 12))

    local TopLine = new("Frame", {
        Position = UDim2.new(0, 0, 1, -1), Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = T.Accent2, BorderSizePixel = 0,
    }, Top)
    new("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0.35), NumberSequenceKeypoint.new(1, 1),
        }),
    }, TopLine)

    -- drag the window by the topbar (mouse + touch)
    local dragging, dragStart, startPos
    Top.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = i.Position
            startPos = Stage.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    local dragConn = UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            Stage.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)

    ----------------------------------------------------------------
    -- NOTIFICATIONS, SHAKE, FX
    ----------------------------------------------------------------
    local Notes = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 18),
        Size = UDim2.fromOffset(320, 10), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1, ZIndex = 100,
    }, Gui)
    new("UIListLayout", {
        Padding = UDim.new(0, 8), HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, Notes)

    local function notify(text, good)
        local col = good and GOOD or BAD
        local dur = 2.6
        local wrap = new("Frame", { Size = UDim2.fromOffset(320, 48), BackgroundTransparency = 1 }, Notes)
        local n = new("CanvasGroup", {
            Position = UDim2.fromOffset(0, -18), Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = T.Section, BorderSizePixel = 0, GroupTransparency = 1,
        }, wrap)
        corner(n, 10)
        stroke(n, T.Stroke, 1)
        local dot = new("Frame", {
            Position = UDim2.fromOffset(16, 19), Size = UDim2.fromOffset(10, 10), BackgroundColor3 = col, BorderSizePixel = 0,
        }, n)
        corner(dot, 5)
        label(n, text, 13, T.Text, Bold, UDim2.fromOffset(38, 0), UDim2.new(1, -48, 1, -3))
        local bar = new("Frame", {
            AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, 2), BackgroundColor3 = col, BorderSizePixel = 0,
        }, n)
        tween(n, 0.4, { Position = UDim2.fromOffset(0, 0), GroupTransparency = 0 })
        tween(bar, dur, { Size = UDim2.new(0, 0, 0, 2) }, Enum.EasingStyle.Linear)
        task.delay(dur, function()
            tween(n, 0.3, { GroupTransparency = 1, Position = UDim2.fromOffset(0, -12) })
            task.wait(0.32)
            wrap:Destroy()
        end)
    end

    local shaking = false
    local function shake()
        if shaking then return end
        shaking = true
        for i = 1, 8 do
            local d = (i % 2 == 0 and 1 or -1) * (16 - i * 1.5)
            tween(Main, 0.045, { Position = UDim2.fromOffset(d, TOP0) }, Enum.EasingStyle.Sine).Completed:Wait()
        end
        Main.Position = UDim2.fromOffset(0, TOP0)
        shaking = false
    end

    local function redFlash()
        tween(Dim, 0.08, { BackgroundColor3 = BAD, BackgroundTransparency = 0.62 })
        task.delay(0.1, function()
            if alive then tween(Dim, 0.5, { BackgroundColor3 = T.Dim, BackgroundTransparency = 0.45 }) end
        end)
    end

    local FX = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 50 }, Gui)
    local function burst()
        local c = Main.AbsolutePosition + Main.AbsoluteSize / 2
        local cols = { T.Accent, T.Accent2, T.Glow, T.Snow, GOOD }
        for i = 1, 52 do
            local sz = rng:NextInteger(4, 8)
            local p = new("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(c.X, c.Y),
                Size = UDim2.fromOffset(sz, sz), BackgroundColor3 = cols[rng:NextInteger(1, #cols)],
                BorderSizePixel = 0, Rotation = rng:NextInteger(0, 90),
            }, FX)
            if i % 2 == 0 then corner(p, sz) end
            local a = rng:NextNumber(0, math.pi * 2)
            local dist = rng:NextNumber(120, 330) * (0.6 + 0.4 * BASE_SCALE)
            local dur = rng:NextNumber(0.7, 1.1)
            tween(p, dur, {
                Position = UDim2.fromOffset(c.X + math.cos(a) * dist, c.Y + math.sin(a) * dist + 60),
                BackgroundTransparency = 1, Rotation = p.Rotation + rng:NextInteger(-200, 200),
            }, Enum.EasingStyle.Quad)
            task.delay(dur + 0.05, function() p:Destroy() end)
        end
        local ring = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(c.X, c.Y),
            Size = UDim2.fromOffset(60, 60), BackgroundTransparency = 1, BorderSizePixel = 0,
        }, FX)
        corner(ring, 2000)
        local rs = stroke(ring, T.Accent, 3)
        tween(ring, 0.9, { Size = UDim2.fromOffset(900, 900) }, Enum.EasingStyle.Quad)
        tween(rs, 0.9, { Transparency = 1 }, Enum.EasingStyle.Quad)
        task.delay(1, function() ring:Destroy() end)
    end

    ----------------------------------------------------------------
    -- PAGES
    ----------------------------------------------------------------
    local function makePage()
        return new("CanvasGroup", {
            Position = UDim2.fromOffset(0, TOP_H), Size = UDim2.new(1, 0, 1, -TOP_H),
            BackgroundTransparency = 1, ZIndex = 3,
        }, Main)
    end

    ----------------------------------------------------------------
    -- KEY PAGE
    ----------------------------------------------------------------
    local KeyPage = makePage()

    label(KeyPage, "Verify your key", 17, T.Text, Bold, UDim2.fromOffset(30, 10), UDim2.fromOffset(250, 24))
    local SubLbl = label(KeyPage, "", 12, T.SubText, Med, UDim2.fromOffset(30, 34), UDim2.fromOffset(380, 16))

    -- tries pips
    local PipBox = new("Frame", {
        AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -30, 0, 17),
        Size = UDim2.fromOffset(MaxTries * 16, 12), BackgroundTransparency = 1,
    }, KeyPage)
    new("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 6),
    }, PipBox)
    local pips = {}
    for i = 1, MaxTries do
        local p = new("Frame", { Size = UDim2.fromOffset(10, 10), BackgroundColor3 = T.Accent2, BorderSizePixel = 0, LayoutOrder = i }, PipBox)
        corner(p, 5)
        pips[i] = p
    end

    -- Textbox
    local BoxWrap = new("Frame", {
        Position = UDim2.fromOffset(30, 58), Size = UDim2.fromOffset(380, 44),
        BackgroundColor3 = T.Element, BorderSizePixel = 0,
    }, KeyPage)
    corner(BoxWrap, 10)
    local BoxStroke = stroke(BoxWrap, T.Stroke, 1)

    local Pill = new("Frame", { Size = UDim2.fromOffset(52, 44), BackgroundColor3 = T.Section, BorderSizePixel = 0 }, BoxWrap)
    corner(Pill, 10)
    new("Frame", { Position = UDim2.fromOffset(26, 0), Size = UDim2.fromOffset(26, 44), BackgroundColor3 = T.Section, BorderSizePixel = 0 }, Pill)
    local PillTxt = label(Pill, "KEY", 11, T.Accent2, Bold, UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), Center)
    PillTxt.ZIndex = 2
    new("Frame", { Position = UDim2.fromOffset(52, 0), Size = UDim2.new(0, 1, 1, 0), BackgroundColor3 = T.Stroke, BorderSizePixel = 0 }, BoxWrap)

    local Box = new("TextBox", {
        Text = "", PlaceholderText = "Paste your key here...", PlaceholderColor3 = T.SubText,
        Font = Med, TextSize = 14, TextColor3 = T.Text, BackgroundTransparency = 1,
        ClearTextOnFocus = false, ClipsDescendants = true, TextXAlignment = Left,
        Position = UDim2.fromOffset(64, 0), Size = UDim2.new(1, -76, 1, 0),
    }, BoxWrap)

    local Underline = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, 0),
        Size = UDim2.new(0, 0, 0, 2), BackgroundColor3 = WHITE, BorderSizePixel = 0,
    }, BoxWrap)
    local UnderGrad = new("UIGradient", { Color = ColorSequence.new(T.Accent, T.Accent2) }, Underline)
    local boxLocked = false

    local function boxFocusVisual(on)
        if boxLocked then return end
        tween(BoxStroke, 0.25, { Color = on and T.Accent2 or T.Stroke })
        tween(BoxWrap, 0.25, { BackgroundColor3 = on and T.ElementHover or T.Element })
        tween(PillTxt, 0.25, { TextColor3 = on and T.Accent or T.Accent2 })
        tween(Underline, 0.4, { Size = on and UDim2.new(1, -24, 0, 2) or UDim2.new(0, 0, 0, 2) })
    end
    Box.Focused:Connect(function() boxFocusVisual(true) end)
    Box.FocusLost:Connect(function() boxFocusVisual(false) end)

    local function flashBox(good)
        local c = good and GOOD or BAD
        boxLocked = true
        BoxStroke.Color = c
        UnderGrad.Color = ColorSequence.new(c)
        tween(Underline, 0.3, { Size = UDim2.new(1, -24, 0, 2) })
        if good then return end
        task.delay(0.8, function()
            boxLocked = false
            UnderGrad.Color = ColorSequence.new(T.Accent, T.Accent2)
            boxFocusVisual(Box:IsFocused())
        end)
    end

    -- Buttons
    local VerifyBtn = makeButton(KeyPage, "Verify Key", UDim2.fromOffset(30, 110), UDim2.fromOffset(187, 40), "primary")
    local GetKeyBtn = makeButton(KeyPage, "Get Key", UDim2.fromOffset(223, 110), UDim2.fromOffset(187, 40), "ghost")
    local Chev = makeChevron(GetKeyBtn.Root, UDim2.new(1, -20, 0.5, 0), T.Text)

    -- Lower block (game card + footer) slides down when the dropdown opens
    local Lower = new("Frame", {
        Position = UDim2.fromOffset(30, LOWER_Y), Size = UDim2.fromOffset(380, 56), BackgroundTransparency = 1,
    }, KeyPage)

    -- Footer: avatar + name + live FPS / ping
    local Foot = new("Frame", { Position = UDim2.fromOffset(0, 0), Size = UDim2.fromOffset(380, 52), BackgroundTransparency = 1 }, Lower)
    local FootLine = new("Frame", { Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = T.Accent2, BorderSizePixel = 0 }, Foot)
    new("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0.6), NumberSequenceKeypoint.new(1, 1),
        }),
    }, FootLine)

    local Face = new("Frame", { Position = UDim2.fromOffset(0, 10), Size = UDim2.fromOffset(40, 40), BackgroundColor3 = T.Element, BorderSizePixel = 0 }, Foot)
    corner(Face, 20)
    local FaceImg = new("ImageLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Image = "" }, Face)
    corner(FaceImg, 20)
    local FaceStroke = stroke(Face, WHITE, 2)
    new("UIGradient", { Color = ColorSequence.new(T.Accent, T.Accent2), Rotation = 45 }, FaceStroke)
    local OnlineDot = new("Frame", {
        Position = UDim2.fromOffset(30, 40), Size = UDim2.fromOffset(10, 10), BackgroundColor3 = GOOD, BorderSizePixel = 0, ZIndex = 3,
    }, Foot)
    corner(OnlineDot, 5)
    stroke(OnlineDot, T.Background, 2)

    local NameLbl = label(Foot, LocalPlayer.DisplayName, 13, T.Text, Bold, UDim2.fromOffset(50, 13), UDim2.fromOffset(140, 18))
    NameLbl.TextTruncate = Enum.TextTruncate.AtEnd
    local UserLbl = label(Foot, "@" .. LocalPlayer.Name, 11, T.SubText, Reg, UDim2.fromOffset(50, 31), UDim2.fromOffset(140, 16))
    UserLbl.TextTruncate = Enum.TextTruncate.AtEnd

    task.spawn(function()
        local ok, img = pcall(function()
            return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
        end)
        if ok then FaceImg.Image = img end
    end)

    local function chip(x, title, w)
        local f = new("Frame", {
            Position = UDim2.fromOffset(x, 10), Size = UDim2.fromOffset(w, 40),
            BackgroundColor3 = T.Element, BorderSizePixel = 0,
        }, Foot)
        corner(f, 8)
        stroke(f, T.Stroke, 1)
        label(f, title, 9, T.SubText, Bold, UDim2.fromOffset(0, 5), UDim2.new(1, 0, 0, 12), Center)
        return label(f, "--", 13, T.Text, Bold, UDim2.fromOffset(0, 19), UDim2.new(1, 0, 0, 16), Center)
    end
    local FpsV  = chip(206, "FPS", 84)
    local PingV = chip(296, "PING (MS)", 84)

    ----------------------------------------------------------------
    -- GET KEY DROPDOWN (smooth collapse)
    ----------------------------------------------------------------
    local Drop = new("Frame", {
        Position = UDim2.fromOffset(30, LOWER_Y), Size = UDim2.fromOffset(380, 0),
        BackgroundColor3 = T.Section, BorderSizePixel = 0, ClipsDescendants = true, Visible = false, ZIndex = 5,
    }, KeyPage)
    corner(Drop, 10)
    stroke(Drop, T.Stroke, 1)

    label(Drop, "GET KEY  -  tap a link to copy it", 10, T.SubText, Bold, UDim2.fromOffset(14, 0), UDim2.fromOffset(280, 34))
    local CloseX = makeButton(Drop, "X", UDim2.fromOffset(380 - 34, 5), UDim2.fromOffset(24, 24), "ghost")
    CloseX.Label.TextSize = 11

    local List = new("ScrollingFrame", {
        Position = UDim2.fromOffset(8, 34), Size = UDim2.fromOffset(364, ROWS * 36),
        BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3,
        ScrollBarImageColor3 = T.Stroke, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, Drop)
    new("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, List)

    local dropRows = {}
    local dropOpen = false

    local function closeDrop()
        if not dropOpen then return end
        dropOpen = false
        for _, r in ipairs(dropRows) do tween(r.Root, 0.15, { GroupTransparency = 1 }) end
        tween(Main, 0.45, { Size = UDim2.fromOffset(W, H0) })
        tween(Drop, 0.45, { Size = UDim2.fromOffset(380, 0) })
        tween(Lower, 0.45, { Position = UDim2.fromOffset(30, LOWER_Y) })
        tween(Chev, 0.4, { Rotation = 0 })
        task.delay(0.46, function() if not dropOpen then Drop.Visible = false end end)
    end

    local function openDrop()
        if dropOpen then return end
        dropOpen = true
        Drop.Visible = true
        tween(Main, 0.45, { Size = UDim2.fromOffset(W, H0 + DD) })
        tween(Drop, 0.45, { Size = UDim2.fromOffset(380, DROP_H) })
        tween(Lower, 0.45, { Position = UDim2.fromOffset(30, LOWER_Y + DD) })
        tween(Chev, 0.4, { Rotation = 180 })
        for i, r in ipairs(dropRows) do
            r.Root.GroupTransparency = 1
            task.delay(0.12 + i * 0.06, function()
                if dropOpen then tween(r.Root, 0.3, { GroupTransparency = 0 }) end
            end)
        end
    end

    for _, name in ipairs(urlNames) do
        local link = Url[name]
        local domain = tostring(link):match("^https?://([^/]+)") or ""
        local row = makeButton(List, name, UDim2.new(), UDim2.new(1, -8, 0, 32), "ghost", true)
        row.Label.TextXAlignment = Left
        pad(row.Label, 14, 0)
        local dl = label(row.Root, domain, 10, T.SubText, Reg, UDim2.new(1, -176, 0, 0), UDim2.fromOffset(112, 32), Right)
        dl.TextTruncate = Enum.TextTruncate.AtEnd
        local tag = new("Frame", {
            AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0),
            Size = UDim2.fromOffset(46, 18), BackgroundColor3 = T.Section, BorderSizePixel = 0,
        }, row.Root)
        corner(tag, 5)
        stroke(tag, T.Stroke, 1)
        label(tag, "COPY", 9, T.Accent2, Bold, UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), Center)
        row.Root.GroupTransparency = 1
        row.Hit.MouseButton1Click:Connect(function()
            local ok = pcall(function() setclip(link) end)
            notify(ok and ("Copied " .. name .. " link") or "Clipboard not supported", ok)
            closeDrop()
        end)
        table.insert(dropRows, row)
    end

    GetKeyBtn.Hit.MouseButton1Click:Connect(function()
        if #urlNames == 0 then notify("No links set", false) return end
        if dropOpen then closeDrop() else openDrop() end
    end)
    CloseX.Hit.MouseButton1Click:Connect(closeDrop)

    ----------------------------------------------------------------
    -- VERIFY LOGIC
    ----------------------------------------------------------------
    local tries, busy = MaxTries, false

    local function setSub(text, color)
        SubLbl.Text = text
        SubLbl.TextColor3 = color or T.SubText
    end
    local function refreshSub() setSub("Unlock " .. KS_TITLE .. " to continue  -  " .. tries .. " tries left") end
    refreshSub()

    local function updatePips()
        for i, p in ipairs(pips) do
            if i <= tries then
                tween(p, 0.3, { BackgroundColor3 = T.Accent2, BackgroundTransparency = 0 })
            else
                tween(p, 0.3, { BackgroundColor3 = BAD, BackgroundTransparency = 0.55 })
            end
        end
    end

    local loop
    local function cleanup()
        alive = false
        if loop then loop:Disconnect() end
        if dragConn then dragConn:Disconnect() end
        introDone = false
        SnowBG.Visible = false
        OrbsBG.Visible = false
        tween(Main, 0.35, { GroupTransparency = 1 })
        tween(Scale, 0.4, { Scale = BASE_SCALE * 0.9 })
        tween(Dim, 0.35, { BackgroundTransparency = 1 })
        glowOn = false
        tween(BlurFx.blur, 0.35, { Size = 0 })
        tween(BlurFx.dof, 0.35, { FarIntensity = 0 })
        task.wait(0.42)
        BlurFx.destroy()
        Gui:Destroy()
    end

    local function verify(key)
        if busy then return end

        key = tostring(key or ""):match("^%s*(.-)%s*$")
        if key == "" then
            notify("Enter a key first", false)
            return
        end

        busy = true
        VerifyBtn.Label.Text = "Checking..."
        task.wait(0.35)

        if key == CorrectKey then
            flashBox(true)
            setSub("Key accepted", GOOD)
            VerifyBtn.Label.Text = "Unlocked"
            notify("Correct key", true)
            burst()
            if SaveKey then pcall(function() writefile(KeyFile, key) end) end
            task.wait(0.7)

            notify("Loading...", true)
            VerifyBtn.Label.Text = "Loading..."
            task.wait(0.6)
            cleanup()
            task.spawn(runSuccess)
            return
        end

        -- wrong key
        tries -= 1
        Box.Text = ""
        flashBox(false)
        redFlash()
        updatePips()
        task.spawn(shake)
        VerifyBtn.Label.Text = "Verify Key"
        if tries <= 0 then
            setSub("Wrong Key Pls Put An Valid One", BAD)
            notify("Wrong Key Pls Put An Valid One", false)
            task.wait(0.8)
            LocalPlayer:Kick("Wrong Key Pls Put An Valid One")
        else
            busy = false
            setSub("Wrong key  -  " .. tries .. " tries left", BAD)
            notify("Wrong Key (" .. tries .. " tries left)", false)
            task.delay(1.6, function() if alive and not busy then refreshSub() end end)
        end
    end

    VerifyBtn.Hit.MouseButton1Click:Connect(function() verify(Box.Text) end)
    Box.FocusLost:Connect(function(enter) if enter then verify(Box.Text) end end)

    ----------------------------------------------------------------
    -- LIVE LOOP (particles, glow, stats)
    ----------------------------------------------------------------
    local function getPing()
        local ok, v = pcall(function() return StatsService.Network.ServerStatsItem["Data Ping"]:GetValue() end)
        return ok and v and math.floor(v + 0.5) or nil
    end

    local acc, frames = 0, 0
    loop = RunService.Heartbeat:Connect(function(dt)
        local t = os.clock()

        stepSnow(snowBG, dt, t)
        stepSnow(snowIn, dt, t)
        stepOrbs(t)
        stepSparkles(dt)

        do
            GlowFx.holder.AnchorPoint = Main.AnchorPoint
            GlowFx.holder.Position = Main.Position
            GlowFx.holder.Size = Main.Size
            DropFx.holder.AnchorPoint = Main.AnchorPoint
            DropFx.holder.Position = UDim2.new(Main.Position.X.Scale, Main.Position.X.Offset, Main.Position.Y.Scale, Main.Position.Y.Offset + 14)
            DropFx.holder.Size = Main.Size
            glowK = glowK + ((glowOn and 1 or 0) - glowK) * math.min(1, dt * 5)
            GlowFx.apply((glowStrength + math.sin(t * 1.6) * 0.18) * glowK)
            DropFx.apply(1.2 * glowK)
            Sheen.Position = UDim2.new(-0.2 + ((t % 6) / 6) * 1.4, 0, 0.5, 0)
        end

        StrokeGrad.Rotation = (t * 45) % 360
        BgGrad.Rotation = 90 + math.sin(t * 0.3) * 25
        TitleGrad.Offset = Vector2.new(math.sin(t * 1.2) * 0.6, 0)
        Logo.Rotation = 45 + math.sin(t * 0.9) * 25

        frames += 1
        acc += dt
        if acc >= 0.5 then
            local fps = math.floor(frames / acc + 0.5)
            local ping = getPing()
            FpsV.Text = tostring(fps)
            tween(FpsV, 0.2, { TextColor3 = fps >= 50 and GOOD or (fps >= 30 and WARN or BAD) })
            PingV.Text = ping and (ping .. " ms") or "-- ms"
            if ping then tween(PingV, 0.2, { TextColor3 = ping <= 100 and GOOD or (ping <= 200 and WARN or BAD) }) end
            acc, frames = 0, 0
        end
    end)

    ----------------------------------------------------------------
    -- INTRO
    ----------------------------------------------------------------
    updatePips()
    tween(Dim, 0.4, { BackgroundTransparency = 0.45 })
    BlurFx.blur.Enabled = true
    BlurFx.dof.Enabled = true
    tween(BlurFx.blur, 0.6, { Size = cfg.BlurSize or 56 })
    tween(BlurFx.dof, 0.6, { FarIntensity = 1 })
    glowOn = true
    tween(Main, 0.4, { GroupTransparency = 0 })
    tween(Scale, 0.5, { Scale = BASE_SCALE }, Enum.EasingStyle.Back)
    task.delay(0.55, function() introDone = true; rescale() end)

    -- auto-verify a saved key
    if SaveKey then
        local ok, saved = pcall(function() return isfile and isfile(KeyFile) and readfile(KeyFile) end)
        if ok and saved and saved == CorrectKey then
            Box.Text = saved
            task.delay(0.7, verify, saved)
        end
    end

    return { Close = cleanup, Gui = Gui }

end

return Library
