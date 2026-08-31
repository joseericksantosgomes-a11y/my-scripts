--[[
    ╔══════════════════════════════════════════════════════════╗
    ║                      BLΛCKR UI Library                   ║
    ║              Ultra-inteligente • Dark Theme              ║
    ║         Performance + Animações + Sistema completo       ║
    ╚══════════════════════════════════════════════════════════╝
    
    Uso:
        local BLΛCKR = loadstring(game:HttpGet("SEU_LINK"))()
        -- ou
        local BLΛCKR = require(script.BLΛCKR)
]]

local BLΛCKR = {}
BLΛCKR.__index = BLΛCKR
BLΛCKR.Version = "1.0.0"

-- Services
local Players           = game:GetService("Players")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local CoreGui           = game:GetService("CoreGui")
local HttpService       = game:GetService("HttpService")
local TextService       = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

--══════════════════════════════════════════════
-- THEME
--══════════════════════════════════════════════
local Theme = {
    Background  = Color3.fromRGB(10, 10, 10),
    Secondary   = Color3.fromRGB(18, 18, 18),
    Tertiary    = Color3.fromRGB(28, 28, 28),
    Hover       = Color3.fromRGB(38, 38, 38),
    Accent      = Color3.fromRGB(180, 35, 35),
    AccentDark  = Color3.fromRGB(130, 25, 25),
    Text        = Color3.fromRGB(245, 245, 245),
    TextDark    = Color3.fromRGB(155, 155, 155),
    TextMuted   = Color3.fromRGB(100, 100, 100),
    Border      = Color3.fromRGB(42, 42, 42),
    Success     = Color3.fromRGB(45, 180, 85),
    Warning     = Color3.fromRGB(220, 160, 35),
    Error       = Color3.fromRGB(210, 45, 45),
    Slider      = Color3.fromRGB(180, 35, 35),
}

--══════════════════════════════════════════════
-- UTILS
--══════════════════════════════════════════════
local function Create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then
            obj[k] = v
        end
    end
    if props and props.Parent then
        obj.Parent = props.Parent
    end
    return obj
end

local function Tween(obj, props, duration, style, direction)
    local info = TweenInfo.new(
        duration or 0.25,
        style or Enum.EasingStyle.Quint,
        direction or Enum.EasingDirection.Out
    )
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

local function MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local function Round(num, places)
    local mult = 10 ^ (places or 0)
    return math.floor(num * mult + 0.5) / mult
end

--══════════════════════════════════════════════
-- NOTIFICATION SYSTEM
--══════════════════════════════════════════════
local NotifContainer

local function InitNotifications()
    if NotifContainer and NotifContainer.Parent then return end

    NotifContainer = Create("Frame", {
        Name = "BLΛCKR_Notifications",
        Parent = CoreGui,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 300, 1, 0),
        Position = UDim2.new(1, -320, 0, 20),
        ZIndex = 99999
    })

    Create("UIListLayout", {
        Parent = NotifContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        VerticalAlignment = Enum.VerticalAlignment.Top,
        HorizontalAlignment = Enum.HorizontalAlignment.Right
    })
end

function BLΛCKR:Notify(config)
    InitNotifications()

    config = typeof(config) == "table" and config or {
        Title = tostring(config) or "Notification",
        Text = "",
        Duration = 4,
        Type = "Info"
    }

    local title    = config.Title or "Notification"
    local text     = config.Text or ""
    local duration = config.Duration or 4
    local nType    = config.Type or "Info"

    local colors = {
        Info    = Theme.Accent,
        Success = Theme.Success,
        Warning = Theme.Warning,
        Error   = Theme.Error
    }
    local accentColor = colors[nType] or Theme.Accent

    local notif = Create("Frame", {
        Parent = NotifContainer,
        BackgroundColor3 = Theme.Secondary,
        Size = UDim2.new(0, 0, 0, 0),
        ClipsDescendants = true,
        BorderSizePixel = 0,
        LayoutOrder = -tick()
    })
    Create("UICorner", { Parent = notif, CornerRadius = UDim.new(0, 7) })
    Create("UIStroke", { Parent = notif, Color = accentColor, Thickness = 1.2, Transparency = 0.3 })

    local bar = Create("Frame", {
        Parent = notif,
        BackgroundColor3 = accentColor,
        Size = UDim2.new(0, 3, 1, 0),
        BorderSizePixel = 0,
        ZIndex = 2
    })
    Create("UICorner", { Parent = bar, CornerRadius = UDim.new(0, 2) })

    local titleL = Create("TextLabel", {
        Parent = notif,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 8),
        Size = UDim2.new(1, -28, 0, 16),
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd
    })

    local textL = Create("TextLabel", {
        Parent = notif,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 26),
        Size = UDim2.new(1, -28, 0, 32),
        Font = Enum.Font.Gotham,
        Text = text,
        TextColor3 = Theme.TextDark,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true
    })

    -- Animação de entrada
    Tween(notif, { Size = UDim2.new(0, 290, 0, 68) }, 0.35, Enum.EasingStyle.Back)

    -- Progress bar inferior
    local progress = Create("Frame", {
        Parent = notif,
        BackgroundColor3 = accentColor,
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        BorderSizePixel = 0,
        ZIndex = 3
    })

    Tween(progress, { Size = UDim2.new(0, 0, 0, 2) }, duration, Enum.EasingStyle.Linear)

    task.delay(duration, function()
        local t = Tween(notif, { Size = UDim2.new(0, 0, 0, 0) }, 0.3)
        t.Completed:Wait()
        notif:Destroy()
    end)

    return notif
end

--══════════════════════════════════════════════
-- WINDOW
--══════════════════════════════════════════════
function BLΛCKR:CreateWindow(config)
    config = config or {}

    local windowTitle = config.Title or "BLΛCKR"
    local windowSize  = config.Size or UDim2.new(0, 620, 0, 450)
    local windowPos   = config.Position or UDim2.new(0.5, -310, 0.5, -225)
    local accent      = config.Accent or Theme.Accent

    -- Override accent se o usuário passar
    if config.Accent then
        Theme.Accent = config.Accent
        Theme.AccentDark = Color3.new(
            math.clamp(config.Accent.R * 0.7, 0, 1),
            math.clamp(config.Accent.G * 0.7, 0, 1),
            math.clamp(config.Accent.B * 0.7, 0, 1)
        )
    end

    -- ScreenGui
    local ScreenGui = Create("ScreenGui", {
        Name = "BLΛCKR_" .. HttpService:GenerateGUID(false):sub(1, 8),
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        IgnoreGuiInset = true
    })

    -- Main Frame
    local Main = Create("Frame", {
        Name = "Main",
        Parent = ScreenGui,
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Position = windowPos,
        Size = UDim2.new(0, 0, 0, 0),
        ClipsDescendants = true
    })
    Create("UICorner", { Parent = Main, CornerRadius = UDim.new(0, 10) })
    Create("UIStroke", {
        Parent = Main,
        Color = Theme.Border,
        Thickness = 1,
        Transparency = 0.4
    })

    -- Animação de abertura
    Tween(Main, { Size = windowSize }, 0.45, Enum.EasingStyle.Back)

    -- Title Bar
    local TitleBar = Create("Frame", {
        Name = "TitleBar",
        Parent = Main,
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 38)
    })
    Create("UICorner", { Parent = TitleBar, CornerRadius = UDim.new(0, 10) })

    -- Fix cantos inferiores do titlebar
    Create("Frame", {
        Parent = TitleBar,
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -10),
        Size = UDim2.new(1, 0, 0, 10)
    })

    -- Accent line no topo
    Create("Frame", {
        Parent = TitleBar,
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 2),
        ZIndex = 2
    })

    local TitleLabel = Create("TextLabel", {
        Parent = TitleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, 0),
        Size = UDim2.new(1, -100, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = windowTitle,
        TextColor3 = Theme.Text,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Botão Fechar
    local CloseBtn = Create("TextButton", {
        Parent = TitleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -38, 0, 0),
        Size = UDim2.new(0, 38, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "✕",
        TextColor3 = Theme.TextDark,
        TextSize = 14,
        AutoButtonColor = false
    })

    CloseBtn.MouseEnter:Connect(function()
        Tween(CloseBtn, { TextColor3 = Theme.Error }, 0.15)
    end)
    CloseBtn.MouseLeave:Connect(function()
        Tween(CloseBtn, { TextColor3 = Theme.TextDark }, 0.15)
    end)
    CloseBtn.MouseButton1Click:Connect(function()
        Tween(Main, {
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1
        }, 0.3).Completed:Wait()
        ScreenGui:Destroy()
    end)

    -- Botão Minimizar
    local MinBtn = Create("TextButton", {
        Parent = TitleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -72, 0, 0),
        Size = UDim2.new(0, 34, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "–",
        TextColor3 = Theme.TextDark,
        TextSize = 18,
        AutoButtonColor = false
    })

    local minimized = false
    local originalSize = windowSize

    MinBtn.MouseEnter:Connect(function()
        Tween(MinBtn, { TextColor3 = Theme.Text }, 0.15)
    end)
    MinBtn.MouseLeave:Connect(function()
        Tween(MinBtn, { TextColor3 = Theme.TextDark }, 0.15)
    end)
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Tween(Main, { Size = UDim2.new(0, originalSize.X.Offset, 0, 38) }, 0.3)
        else
            Tween(Main, { Size = originalSize }, 0.3)
        end
    end)

    MakeDraggable(Main, TitleBar)

    -- Sidebar
    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Parent = Main,
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 38),
        Size = UDim2.new(0, 148, 1, -38)
    })

    local TabList = Create("ScrollingFrame", {
        Parent = Sidebar,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, -10),
        Position = UDim2.new(0, 0, 0, 6),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Accent,
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    })

    Create("UIListLayout", {
        Parent = TabList,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
        HorizontalAlignment = Enum.HorizontalAlignment.Center
    })
    Create("UIPadding", {
        Parent = TabList,
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 8)
    })

    -- Content Area
    local Content = Create("Frame", {
        Name = "Content",
        Parent = Main,
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 148, 0, 38),
        Size = UDim2.new(1, -148, 1, -38),
        ClipsDescendants = true
    })

    local Pages = {}
    local CurrentPage = nil
    local TabButtons = {}

    local Window = {
        ScreenGui = ScreenGui,
        Main = Main,
        Theme = Theme,
        Notify = function(_, cfg) return BLΛCKR:Notify(cfg) end
    }

    --════════════════════════════════════════
    -- CREATE TAB
    --════════════════════════════════════════
    function Window:CreateTab(name, icon)
        icon = icon or "•"

        local tabBtn = Create("TextButton", {
            Parent = TabList,
            BackgroundColor3 = Theme.Tertiary,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 132, 0, 34),
            Font = Enum.Font.GothamMedium,
            Text = "  " .. icon .. "  " .. name,
            TextColor3 = Theme.TextDark,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false
        })
        Create("UICorner", { Parent = tabBtn, CornerRadius = UDim.new(0, 6) })

        local indicator = Create("Frame", {
            Parent = tabBtn,
            BackgroundColor3 = Theme.Accent,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 3, 0.6, 0),
            Position = UDim2.new(0, 0, 0.2, 0),
            Visible = false
        })
        Create("UICorner", { Parent = indicator, CornerRadius = UDim.new(0, 2) })

        local page = Create("ScrollingFrame", {
            Parent = Content,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Accent,
            Visible = false,
            AutomaticCanvasSize = Enum.AutomaticSize.Y
        })

        local pageLayout = Create("UIListLayout", {
            Parent = page,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10)
        })
        Create("UIPadding", {
            Parent = page,
            PaddingTop = UDim.new(0, 12),
            PaddingLeft = UDim.new(0, 14),
            PaddingRight = UDim.new(0, 14),
            PaddingBottom = UDim.new(0, 16)
        })

        local function SelectTab()
            if CurrentPage == page then return end

            for _, p in pairs(Pages) do
                p.Visible = false
            end
            for _, data in pairs(TabButtons) do
                Tween(data.Btn, {
                    BackgroundColor3 = Theme.Tertiary,
                    TextColor3 = Theme.TextDark
                }, 0.2)
                data.Indicator.Visible = false
            end

            page.Visible = true
            CurrentPage = page
            Tween(tabBtn, {
                BackgroundColor3 = Theme.Hover,
                TextColor3 = Theme.Text
            }, 0.2)
            indicator.Visible = true
        end

        tabBtn.MouseButton1Click:Connect(SelectTab)
        tabBtn.MouseEnter:Connect(function()
            if CurrentPage ~= page then
                Tween(tabBtn, { BackgroundColor3 = Theme.Hover }, 0.15)
            end
        end)
        tabBtn.MouseLeave:Connect(function()
            if CurrentPage ~= page then
                Tween(tabBtn, { BackgroundColor3 = Theme.Tertiary }, 0.15)
            end
        end)

        table.insert(Pages, page)
        table.insert(TabButtons, { Btn = tabBtn, Indicator = indicator })

        -- Auto-seleciona a primeira tab
        if #Pages == 1 then
            SelectTab()
        end

        local Tab = { Page = page }

        --════════════════════════════════════
        -- CREATE SECTION
        --════════════════════════════════════
        function Tab:CreateSection(sectionTitle)
            local section = Create("Frame", {
                Parent = page,
                BackgroundColor3 = Theme.Secondary,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 40),
                AutomaticSize = Enum.AutomaticSize.Y
            })
            Create("UICorner", { Parent = section, CornerRadius = UDim.new(0, 8) })
            Create("UIStroke", {
                Parent = section,
                Color = Theme.Border,
                Thickness = 1,
                Transparency = 0.6
            })

            local header = Create("TextLabel", {
                Parent = section,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 14, 0, 0),
                Size = UDim2.new(1, -28, 0, 36),
                Font = Enum.Font.GothamBold,
                Text = sectionTitle or "Section",
                TextColor3 = Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local holder = Create("Frame", {
                Parent = section,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 36),
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y
            })

            local holderLayout = Create("UIListLayout", {
                Parent = holder,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 6)
            })
            Create("UIPadding", {
                Parent = holder,
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
                PaddingBottom = UDim.new(0, 12)
            })

            local Section = {}

            --────────────────────────────────
            -- BUTTON
            --────────────────────────────────
            function Section:CreateButton(cfg)
                cfg = cfg or {}
                local btn = Create("TextButton", {
                    Parent = holder,
                    BackgroundColor3 = Theme.Tertiary,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 34),
                    Font = Enum.Font.GothamMedium,
                    Text = cfg.Text or "Button",
                    TextColor3 = Theme.Text,
                    TextSize = 13,
                    AutoButtonColor = false
                })
                Create("UICorner", { Parent = btn, CornerRadius = UDim.new(0, 6) })

                btn.MouseEnter:Connect(function()
                    Tween(btn, { BackgroundColor3 = Theme.Accent }, 0.18)
                end)
                btn.MouseLeave:Connect(function()
                    Tween(btn, { BackgroundColor3 = Theme.Tertiary }, 0.18)
                end)
                btn.MouseButton1Click:Connect(function()
                    if cfg.Callback then
                        task.spawn(cfg.Callback)
                    end
                end)

                return {
                    Instance = btn,
                    SetText = function(_, t) btn.Text = t end
                }
            end

            --────────────────────────────────
            -- TOGGLE
            --────────────────────────────────
            function Section:CreateToggle(cfg)
                cfg = cfg or {}
                local state = cfg.Default or false

                local frame = Create("Frame", {
                    Parent = holder,
                    BackgroundColor3 = Theme.Tertiary,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 36)
                })
                Create("UICorner", { Parent = frame, CornerRadius = UDim.new(0, 6) })

                local label = Create("TextLabel", {
                    Parent = frame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 0),
                    Size = UDim2.new(1, -70, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = cfg.Text or "Toggle",
                    TextColor3 = Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local track = Create("Frame", {
                    Parent = frame,
                    BackgroundColor3 = state and Theme.Accent or Theme.Hover,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -52, 0.5, -10),
                    Size = UDim2.new(0, 40, 0, 20)
                })
                Create("UICorner", { Parent = track, CornerRadius = UDim.new(1, 0) })

                local knob = Create("Frame", {
                    Parent = track,
                    BackgroundColor3 = Theme.Text,
                    BorderSizePixel = 0,
                    Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                    Size = UDim2.new(0, 16, 0, 16)
                })
                Create("UICorner", { Parent = knob, CornerRadius = UDim.new(1, 0) })

                local function SetState(val, fire)
                    state = val
                    Tween(track, {
                        BackgroundColor3 = state and Theme.Accent or Theme.Hover
                    }, 0.2)
                    Tween(knob, {
                        Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                    }, 0.2)
                    if fire and cfg.Callback then
                        task.spawn(cfg.Callback, state)
                    end
                end

                local click = Create("TextButton", {
                    Parent = frame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    AutoButtonColor = false
                })
                click.MouseButton1Click:Connect(function()
                    SetState(not state, true)
                end)

                return {
                    Instance = frame,
                    Set = function(_, val) SetState(val, true) end,
                    Get = function() return state end,
                    SetText = function(_, t) label.Text = t end
                }
            end

            --────────────────────────────────
            -- SLIDER
            --────────────────────────────────
            function Section:CreateSlider(cfg)
                cfg = cfg or {}
                local min = cfg.Min or 0
                local max = cfg.Max or 100
                local default = cfg.Default or min
                local increment = cfg.Increment or 1
                local value = default

                local frame = Create("Frame", {
                    Parent = holder,
                    BackgroundColor3 = Theme.Tertiary,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 52)
                })
                Create("UICorner", { Parent = frame, CornerRadius = UDim.new(0, 6) })

                local label = Create("TextLabel", {
                    Parent = frame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 4),
                    Size = UDim2.new(0.65, 0, 0, 18),
                    Font = Enum.Font.Gotham,
                    Text = cfg.Text or "Slider",
                    TextColor3 = Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local valueLabel = Create("TextLabel", {
                    Parent = frame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0.65, 0, 0, 4),
                    Size = UDim2.new(0.35, -12, 0, 18),
                    Font = Enum.Font.GothamMedium,
                    Text = tostring(value),
                    TextColor3 = Theme.Accent,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Right
                })

                local barBg = Create("Frame", {
                    Parent = frame,
                    BackgroundColor3 = Theme.Hover,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 12, 0, 30),
                    Size = UDim2.new(1, -24, 0, 6)
                })
                Create("UICorner", { Parent = barBg, CornerRadius = UDim.new(1, 0) })

                local barFill = Create("Frame", {
                    Parent = barBg,
                    BackgroundColor3 = Theme.Accent,
                    BorderSizePixel = 0,
                    Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                })
                Create("UICorner", { Parent = barFill, CornerRadius = UDim.new(1, 0) })

                local knob = Create("Frame", {
                    Parent = barBg,
                    BackgroundColor3 = Theme.Text,
                    BorderSizePixel = 0,
                    Position = UDim2.new((value - min) / (max - min), -7, 0.5, -7),
                    Size = UDim2.new(0, 14, 0, 14),
                    ZIndex = 2
                })
                Create("UICorner", { Parent = knob, CornerRadius = UDim.new(1, 0) })

                local sliding = false

                local function Update(val, fire)
                    value = math.clamp(Round(val / increment) * increment, min, max)
                    local pct = (value - min) / (max - min)
                    Tween(barFill, { Size = UDim2.new(pct, 0, 1, 0) }, 0.1)
                    Tween(knob, { Position = UDim2.new(pct, -7, 0.5, -7) }, 0.1)
                    valueLabel.Text = tostring(value)
                    if fire and cfg.Callback then
                        task.spawn(cfg.Callback, value)
                    end
                end

                barBg.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        sliding = true
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        sliding = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        local rel = math.clamp((input.Position.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
                        Update(min + (max - min) * rel, true)
                    end
                end)

                -- Clique direto na barra
                barBg.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local rel = math.clamp((input.Position.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
                        Update(min + (max - min) * rel, true)
                    end
                end)

                Update(default, false)

                return {
                    Instance = frame,
                    Set = function(_, v) Update(v, true) end,
                    Get = function() return value end
                }
            end

            --────────────────────────────────
            -- TEXTBOX
            --────────────────────────────────
            function Section:CreateTextbox(cfg)
                cfg = cfg or {}

                local frame = Create("Frame", {
                    Parent = holder,
                    BackgroundColor3 = Theme.Tertiary,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 36)
                })
                Create("UICorner", { Parent = frame, CornerRadius = UDim.new(0, 6) })

                local label = Create("TextLabel", {
                    Parent = frame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 0),
                    Size = UDim2.new(0.4, 0, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = cfg.Text or "Input",
                    TextColor3 = Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local box = Create("TextBox", {
                    Parent = frame,
                    BackgroundColor3 = Theme.Hover,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0.42, 0, 0.5, -12),
                    Size = UDim2.new(0.55, -8, 0, 24),
                    Font = Enum.Font.Gotham,
                    Text = cfg.Default or "",
                    PlaceholderText = cfg.Placeholder or "...",
                    PlaceholderColor3 = Theme.TextMuted,
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    ClearTextOnFocus = false
                })
                Create("UICorner", { Parent = box, CornerRadius = UDim.new(0, 5) })

                box.FocusLost:Connect(function(enter)
                    if cfg.Callback then
                        task.spawn(cfg.Callback, box.Text, enter)
                    end
                end)

                return {
                    Instance = frame,
                    Set = function(_, t) box.Text = t end,
                    Get = function() return box.Text end
                }
            end

            --────────────────────────────────
            -- DROPDOWN
            --────────────────────────────────
            function Section:CreateDropdown(cfg)
                cfg = cfg or {}
                local options = cfg.Options or { "Option 1", "Option 2" }
                local selected = cfg.Default or options[1]
                local open = false

                local frame = Create("Frame", {
                    Parent = holder,
                    BackgroundColor3 = Theme.Tertiary,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 36),
                    ClipsDescendants = true,
                    ZIndex = 5
                })
                Create("UICorner", { Parent = frame, CornerRadius = UDim.new(0, 6) })

                local label = Create("TextLabel", {
                    Parent = frame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 0),
                    Size = UDim2.new(0.45, 0, 0, 36),
                    Font = Enum.Font.Gotham,
                    Text = cfg.Text or "Dropdown",
                    TextColor3 = Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local selectedLabel = Create("TextLabel", {
                    Parent = frame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0.45, 0, 0, 0),
                    Size = UDim2.new(0.45, 0, 0, 36),
                    Font = Enum.Font.GothamMedium,
                    Text = selected,
                    TextColor3 = Theme.Accent,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    TextTruncate = Enum.TextTruncate.AtEnd
                })

                local arrow = Create("TextLabel", {
                    Parent = frame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -28, 0, 0),
                    Size = UDim2.new(0, 24, 0, 36),
                    Font = Enum.Font.GothamBold,
                    Text = "▾",
                    TextColor3 = Theme.TextDark,
                    TextSize = 14
                })

                local optionHolder = Create("Frame", {
                    Parent = frame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 36),
                    Size = UDim2.new(1, 0, 0, 0)
                })
                Create("UIListLayout", {
                    Parent = optionHolder,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 2)
                })
                Create("UIPadding", {
                    Parent = optionHolder,
                    PaddingLeft = UDim.new(0, 6),
                    PaddingRight = UDim.new(0, 6),
                    PaddingBottom = UDim.new(0, 6)
                })

                local function Toggle()
                    open = not open
                    if open then
                        local height = #options * 28 + 10
                        Tween(frame, { Size = UDim2.new(1, 0, 0, 36 + height) }, 0.25)
                        Tween(arrow, { Rotation = 180 }, 0.2)
                    else
                        Tween(frame, { Size = UDim2.new(1, 0, 0, 36) }, 0.25)
                        Tween(arrow, { Rotation = 0 }, 0.2)
                    end
                end

                local clickArea = Create("TextButton", {
                    Parent = frame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 36),
                    Text = "",
                    ZIndex = 6,
                    AutoButtonColor = false
                })
                clickArea.MouseButton1Click:Connect(Toggle)

                for _, opt in ipairs(options) do
                    local optBtn = Create("TextButton", {
                        Parent = optionHolder,
                        BackgroundColor3 = Theme.Hover,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, 26),
                        Font = Enum.Font.Gotham,
                        Text = opt,
                        TextColor3 = Theme.TextDark,
                        TextSize = 12,
                        AutoButtonColor = false
                    })
                    Create("UICorner", { Parent = optBtn, CornerRadius = UDim.new(0, 4) })

                    optBtn.MouseEnter:Connect(function()
                        Tween(optBtn, { BackgroundColor3 = Theme.Accent, TextColor3 = Theme.Text }, 0.15)
                    end)
                    optBtn.MouseLeave:Connect(function()
                        Tween(optBtn, { BackgroundColor3 = Theme.Hover, TextColor3 = Theme.TextDark }, 0.15)
                    end)
                    optBtn.MouseButton1Click:Connect(function()
                        selected = opt
                        selectedLabel.Text = opt
                        Toggle()
                        if cfg.Callback then
                            task.spawn(cfg.Callback, opt)
                        end
                    end)
                end

                return {
                    Instance = frame,
                    Set = function(_, v)
                        selected = v
                        selectedLabel.Text = v
                    end,
                    Get = function() return selected end
                }
            end

            --────────────────────────────────
            -- KEYBIND
            --────────────────────────────────
            function Section:CreateKeybind(cfg)
                cfg = cfg or {}
                local key = cfg.Default or Enum.KeyCode.E
                local listening = false

                local frame = Create("Frame", {
                    Parent = holder,
                    BackgroundColor3 = Theme.Tertiary,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 36)
                })
                Create("UICorner", { Parent = frame, CornerRadius = UDim.new(0, 6) })

                local label = Create("TextLabel", {
                    Parent = frame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 0),
                    Size = UDim2.new(0.5, 0, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = cfg.Text or "Keybind",
                    TextColor3 = Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local keyBtn = Create("TextButton", {
                    Parent = frame,
                    BackgroundColor3 = Theme.Hover,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -90, 0.5, -12),
                    Size = UDim2.new(0, 78, 0, 24),
                    Font = Enum.Font.GothamMedium,
                    Text = key.Name,
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    AutoButtonColor = false
                })
                Create("UICorner", { Parent = keyBtn, CornerRadius = UDim.new(0, 5) })

                keyBtn.MouseButton1Click:Connect(function()
                    listening = true
                    keyBtn.Text = "..."
                    Tween(keyBtn, { BackgroundColor3 = Theme.Accent }, 0.15)
                end)

                local connection
                connection = UserInputService.InputBegan:Connect(function(input, gpe)
                    if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                        key = input.KeyCode
                        keyBtn.Text = key.Name
                        listening = false
                        Tween(keyBtn, { BackgroundColor3 = Theme.Hover }, 0.15)
                        if cfg.Callback then
                            task.spawn(cfg.Callback, key)
                        end
                    end
                end)

                -- Executar keybind
                UserInputService.InputBegan:Connect(function(input, gpe)
                    if not gpe and input.KeyCode == key and not listening then
                        if cfg.Callback then
                            task.spawn(cfg.Callback, key)
                        end
                    end
                end)

                return {
                    Instance = frame,
                    Get = function() return key end,
                    Set = function(_, k)
                        key = k
                        keyBtn.Text = k.Name
                    end
                }
            end

            --────────────────────────────────
            -- LABEL / PARAGRAPH
            --────────────────────────────────
            function Section:CreateLabel(cfg)
                cfg = cfg or {}
                local label = Create("TextLabel", {
                    Parent = holder,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 22),
                    Font = Enum.Font.Gotham,
                    Text = cfg.Text or "Label",
                    TextColor3 = cfg.Color or Theme.TextDark,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true,
                    AutomaticSize = Enum.AutomaticSize.Y
                })

                return {
                    Instance = label,
                    SetText = function(_, t) label.Text = t end
                }
            end

            --────────────────────────────────
            -- DIVIDER
            --────────────────────────────────
            function Section:CreateDivider()
                local div = Create("Frame", {
                    Parent = holder,
                    BackgroundColor3 = Theme.Border,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 1)
                })
                return div
            end

            return Section
        end

        return Tab
    end

    -- Função global da window
    function Window:SetVisible(vis)
        Main.Visible = vis
    end

    function Window:Destroy()
        ScreenGui:Destroy()
    end

    return Window
end

--══════════════════════════════════════════════
-- CHANGE THEME (runtime)
--══════════════════════════════════════════════
function BLΛCKR:SetTheme(newTheme)
    for k, v in pairs(newTheme) do
        if Theme[k] then
            Theme[k] = v
        end
    end
end

function BLΛCKR:GetTheme()
    return Theme
end

return BLΛCKR
