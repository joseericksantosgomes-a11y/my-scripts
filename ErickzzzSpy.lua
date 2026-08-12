--[[
	Erickzzz Spy
	Dark • Professional • Zero Lag
]]

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui          = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
task.wait(0.1)

local Icon = loadstring(game:HttpGet(
	"https://raw.githubusercontent.com/Therealtobu/Topbar-Plus-For-Executor/main/init.lua"
))()

local Settings = { ShowAllPlayers = false, ShowNPCs = false }
local MAX_STACK = 80

local RemoteStack = { Outgoing = {}, Incoming = {} }
local SoundGroups = {}
local AnimGroups  = {}
local Expanded = {}

local CurrentTab = "Home"
local SelectedType = "Outgoing"
local SelectedKey = nil
local isOpen = false
local dragging, dragStart, startPos
local UI = {}
local refreshQueued = false
local topIcon

local function pathOf(obj)
	if not obj then return "?" end
	local p, c, d = obj.Name, obj.Parent, 0
	while c and c ~= game and d < 10 do p = c.Name .. "." .. p; c = c.Parent; d += 1 end
	return p
end

local function assetId(str)
	return str and string.match(tostring(str), "(%d+)")
end

local function serialize(v, depth)
	depth = depth or 0
	if depth > 3 then return "..." end
	local t = typeof(v)
	if t == "string" then return string.format("%q", v)
	elseif t == "number" or t == "boolean" or t == "nil" then return tostring(v)
	elseif t == "Instance" then return pathOf(v)
	elseif t == "Vector3" then return string.format("Vector3.new(%.1f,%.1f,%.1f)", v.X, v.Y, v.Z)
	elseif t == "table" then
		local n, parts = 0, {}
		for k, val in pairs(v) do
			n += 1
			if n > 5 then parts[#parts+1] = "..." break end
			parts[#parts+1] = "[" .. serialize(k, depth+1) .. "]=" .. serialize(val, depth+1)
		end
		return "{" .. table.concat(parts, ",") .. "}"
	end
	return tostring(v)
end

local function argsStr(args)
	if not args or #args == 0 then return "()" end
	local p = {}
	for i = 1, math.min(#args, 8) do p[i] = serialize(args[i]) end
	if #args > 8 then p[#p+1] = "..." end
	return "(" .. table.concat(p, ", ") .. ")"
end

local function fireCode(remote, args)
	local p = pathOf(remote)
	local a = argsStr(args)
	if remote:IsA("RemoteFunction") then return p .. ":InvokeServer" .. a end
	return p .. ":FireServer" .. a
end

local function copy(text)
	if setclipboard then setclipboard(tostring(text)); if UI.setStatus then UI.setStatus("Copied") end end
end

local function queueRefresh()
	if refreshQueued or not isOpen then return end
	refreshQueued = true
	task.defer(function()
		refreshQueued = false
		if UI.refresh and isOpen then UI.refresh() end
	end)
end

local function countKeys(t)
	local n = 0
	for _ in pairs(t) do n += 1 end
	return n
end

local function purgeOtherSources()
	if not Settings.ShowAllPlayers then
		for src in pairs(SoundGroups) do if src ~= "You" then SoundGroups[src] = nil end end
		for src in pairs(AnimGroups) do if src ~= "You" then AnimGroups[src] = nil end end
	end
	if not Settings.ShowNPCs then
		local names = { You = true }
		for _, plr in ipairs(Players:GetPlayers()) do names[plr.Name] = true end
		for src in pairs(SoundGroups) do if not names[src] then SoundGroups[src] = nil end end
		for src in pairs(AnimGroups) do if not names[src] then AnimGroups[src] = nil end end
	end
	queueRefresh()
end

-- REMOTE
local function stackRemote(remote, dir, args, method)
	local bucket = RemoteStack[dir]
	local key = tostring(remote)
	if not bucket[key] then
		if countKeys(bucket) > MAX_STACK then return end
		bucket[key] = {
			remote = remote, name = remote.Name, class = remote.ClassName,
			path = pathOf(remote), count = 0, lastArgs = args, method = method,
			blocked = false, ignored = false,
		}
	end
	local e = bucket[key]
	if e.ignored then return end
	e.count += 1; e.lastArgs = args; e.method = method
	queueRefresh()
end

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
	local method = getnamecallmethod()
	if typeof(self) == "Instance" and (method == "FireServer" or method == "InvokeServer") then
		if self:IsA("RemoteEvent") or self:IsA("RemoteFunction") or self:IsA("UnreliableRemoteEvent") then
			local e = RemoteStack.Outgoing[tostring(self)]
			if e and e.blocked then return end
			stackRemote(self, "Outgoing", {...}, method)
		end
	end
	return oldNamecall(self, ...)
end))

local function hookIncoming(r)
	if not r or not r.Parent then return end
	if r:IsA("RemoteEvent") or r:IsA("UnreliableRemoteEvent") then
		r.OnClientEvent:Connect(function(...) stackRemote(r, "Incoming", {...}, "OnClientEvent") end)
	elseif r:IsA("RemoteFunction") then
		local old = r.OnClientInvoke
		r.OnClientInvoke = function(...)
			stackRemote(r, "Incoming", {...}, "OnClientInvoke")
			if old then return old(...) end
		end
	end
end

task.spawn(function()
	for _, o in ipairs(game:GetDescendants()) do
		if o:IsA("RemoteEvent") or o:IsA("RemoteFunction") or o:IsA("UnreliableRemoteEvent") then hookIncoming(o) end
	end
end)
game.DescendantAdded:Connect(function(o)
	if o:IsA("RemoteEvent") or o:IsA("RemoteFunction") or o:IsA("UnreliableRemoteEvent") then task.defer(hookIncoming, o) end
end)

-- SOUND
local function resolveSoundSource(sound)
	local char = LocalPlayer.Character
	if char and sound:IsDescendantOf(char) then return "You", "local" end
	local pg = LocalPlayer:FindFirstChild("PlayerGui")
	if pg and sound:IsDescendantOf(pg) then return "You", "local" end
	local p = sound.Parent
	while p and p ~= workspace do
		local plr = Players:GetPlayerFromCharacter(p)
		if plr then return plr.Name, "player" end
		if p:IsA("Model") and p:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(p) then
			return p.Name, "npc"
		end
		p = p.Parent
	end
	return nil, nil
end

local function stackSound(sound)
	local id = assetId(sound.SoundId)
	if not id then return end
	local source, kind = resolveSoundSource(sound)
	if not source then return end
	if kind == "player" and not Settings.ShowAllPlayers then return end
	if kind == "npc" and not Settings.ShowNPCs then return end
	if not SoundGroups[source] then SoundGroups[source] = {} end
	local g = SoundGroups[source]
	if not g[id] then
		if countKeys(g) > MAX_STACK then return end
		g[id] = { id = id, name = sound.Name, soundId = sound.SoundId, count = 0, source = source }
	end
	g[id].count += 1
	queueRefresh()
end

local function hookSound(s)
	if not s:IsA("Sound") then return end
	s:GetPropertyChangedSignal("Playing"):Connect(function()
		if s.Playing then stackSound(s) end
	end)
end

task.spawn(function()
	for _, o in ipairs(game:GetDescendants()) do if o:IsA("Sound") then hookSound(o) end end
end)
game.DescendantAdded:Connect(function(o) if o:IsA("Sound") then task.defer(hookSound, o) end end)

-- ANIM
local function stackAnim(track, sourceName, kind)
	local anim = track.Animation
	if not anim then return end
	local id = assetId(anim.AnimationId)
	if not id then return end
	if kind == "player" and not Settings.ShowAllPlayers then return end
	if kind == "npc" and not Settings.ShowNPCs then return end
	local source = sourceName or "Unknown"
	if not AnimGroups[source] then AnimGroups[source] = {} end
	local g = AnimGroups[source]
	if not g[id] then
		if countKeys(g) > MAX_STACK then return end
		g[id] = {
			id = id, name = anim.Name ~= "" and anim.Name or track.Name,
			animId = anim.AnimationId, source = source, count = 0, length = track.Length,
		}
	end
	g[id].count += 1
	queueRefresh()
end

local function hookChar(char, name, kind)
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	local animator = hum:FindFirstChildOfClass("Animator") or hum:WaitForChild("Animator", 2)
	if not animator then return end
	animator.AnimationPlayed:Connect(function(track) stackAnim(track, name, kind) end)
end

local function setupPlayer(plr)
	local isLocal = plr == LocalPlayer
	local name = isLocal and "You" or plr.Name
	local kind = isLocal and "local" or "player"
	if plr.Character then hookChar(plr.Character, name, kind) end
	plr.CharacterAdded:Connect(function(c) task.defer(hookChar, c, name, kind) end)
end

for _, p in ipairs(Players:GetPlayers()) do setupPlayer(p) end
Players.PlayerAdded:Connect(setupPlayer)

task.spawn(function()
	while true do
		if Settings.ShowNPCs then
			for _, model in ipairs(workspace:GetChildren()) do
				if model:IsA("Model") and model:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(model) then
					if not model:GetAttribute("ES_Hooked") then
						model:SetAttribute("ES_Hooked", true)
						hookChar(model, model.Name, "npc")
					end
				end
			end
		end
		task.wait(3)
	end
end)

-- UI
local function C(class, props)
	local i = Instance.new(class)
	for k, v in pairs(props or {}) do i[k] = v end
	return i
end
local function corner(p, r)
	local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 6); c.Parent = p
	return c
end
local function stroke(p, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color or Color3.fromRGB(30, 30, 38)
	s.Thickness = thickness or 1
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = p
	return s
end
local function hover(btn, base, over, textBase, textOver)
	base = base or btn.BackgroundColor3
	over = over or Color3.fromRGB(
		math.min(255, base.R * 255 + 18),
		math.min(255, base.G * 255 + 18),
		math.min(255, base.B * 255 + 18)
	)
	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.14, Enum.EasingStyle.Quint), {
			BackgroundColor3 = over
		}):Play()
		if textOver then
			TweenService:Create(btn, TweenInfo.new(0.14), {TextColor3 = textOver}):Play()
		end
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.14, Enum.EasingStyle.Quint), {
			BackgroundColor3 = base
		}):Play()
		if textBase then
			TweenService:Create(btn, TweenInfo.new(0.14), {TextColor3 = textBase}):Play()
		end
	end)
end

local gui = C("ScreenGui", {
	Name = "ErickzzzSpy", ResetOnSpawn = false, IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = CoreGui,
})

local win = C("Frame", {
	Size = UDim2.fromOffset(0, 0), Position = UDim2.new(0.5, 0, 0.5, 0),
	AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.fromRGB(8, 8, 10),
	BorderSizePixel = 0, Visible = false, Parent = gui,
})
corner(win, 12)
stroke(win, Color3.fromRGB(28, 28, 36), 1)

local title = C("Frame", {
	Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = Color3.fromRGB(11, 11, 14),
	BorderSizePixel = 0, Parent = win,
})
corner(title, 12)

-- accent line under title
local accent = C("Frame", {
	Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1),
	BackgroundColor3 = Color3.fromRGB(40, 48, 72), BorderSizePixel = 0, Parent = title,
})

C("ImageLabel", {
	Size = UDim2.fromOffset(16, 16), Position = UDim2.fromOffset(14, 11),
	BackgroundTransparency = 1, Image = "rbxassetid://10734949856",
	ImageColor3 = Color3.fromRGB(160, 175, 230), Parent = title,
})
C("TextLabel", {
	Size = UDim2.new(1, -40, 1, 0), Position = UDim2.fromOffset(36, 0), BackgroundTransparency = 1,
	Text = "Erickzzz Spy", Font = Enum.Font.GothamMedium, TextSize = 14,
	TextColor3 = Color3.fromRGB(200, 200, 215), TextXAlignment = Enum.TextXAlignment.Left, Parent = title,
})

-- Lucide icons (asset ids)
local ICONS = {
	server   = "rbxassetid://10734949856",
	radio    = "rbxassetid://10734931596",
	volume   = "rbxassetid://10747375679",
	film     = "rbxassetid://10723374981",
	settings = "rbxassetid://10734950309",
	search   = "rbxassetid://10734943674",
	copy     = "rbxassetid://10709812159",
	trash    = "rbxassetid://10747362393",
	play     = "rbxassetid://10734923549",
	terminal = "rbxassetid://10734982144",
	home     = "rbxassetid://10709810948", -- cog fallback; using home-like
	user     = "rbxassetid://10747373176",
}

-- home icon (house) - use server as home-ish if needed; better: activity
ICONS.home = "rbxassetid://10709752035" -- activity as home accent, or use house if available

local tabBar = C("Frame", {
	Size = UDim2.new(1, -16, 0, 32), Position = UDim2.fromOffset(8, 46), BackgroundTransparency = 1, Parent = win,
})
local tabBtns = {}
local function makeTab(name, x, iconId, width)
	width = width or 96
	local b = C("TextButton", {
		Size = UDim2.fromOffset(width, 30), Position = UDim2.fromOffset(x, 0),
		BackgroundColor3 = Color3.fromRGB(14, 14, 18), Text = "",
		AutoButtonColor = false, Parent = tabBar,
	})
	corner(b, 7)
	stroke(b, Color3.fromRGB(26, 26, 34), 1)

	local icon = C("ImageLabel", {
		Size = UDim2.fromOffset(13, 13), Position = UDim2.fromOffset(8, 8.5),
		BackgroundTransparency = 1, Image = iconId,
		ImageColor3 = Color3.fromRGB(120, 120, 138), Parent = b,
	})
	local label = C("TextLabel", {
		Size = UDim2.new(1, -28, 1, 0), Position = UDim2.fromOffset(24, 0),
		BackgroundTransparency = 1, Text = name,
		Font = Enum.Font.GothamMedium, TextSize = 11,
		TextColor3 = Color3.fromRGB(120, 120, 138),
		TextXAlignment = Enum.TextXAlignment.Left, Parent = b,
	})
	b.MouseEnter:Connect(function()
		TweenService:Create(b, TweenInfo.new(0.14, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(20, 22, 30)}):Play()
		TweenService:Create(icon, TweenInfo.new(0.14), {ImageColor3 = Color3.fromRGB(180, 185, 210)}):Play()
		TweenService:Create(label, TweenInfo.new(0.14), {TextColor3 = Color3.fromRGB(180, 185, 210)}):Play()
	end)
	b.MouseLeave:Connect(function()
		local on = CurrentTab == name
		local bg = on and Color3.fromRGB(28, 36, 58) or Color3.fromRGB(14, 14, 18)
		local col = on and Color3.fromRGB(175, 190, 240) or Color3.fromRGB(120, 120, 138)
		TweenService:Create(b, TweenInfo.new(0.14, Enum.EasingStyle.Quint), {BackgroundColor3 = bg}):Play()
		TweenService:Create(icon, TweenInfo.new(0.14), {ImageColor3 = col}):Play()
		TweenService:Create(label, TweenInfo.new(0.14), {TextColor3 = col}):Play()
	end)
	tabBtns[name] = {btn = b, icon = icon, label = label}
end

-- Order: Home, Config, Remote, Sound, Animation
makeTab("Home", 0, ICONS.home, 78)
makeTab("Config", 82, ICONS.settings, 86)
makeTab("Remote", 172, ICONS.radio, 90)
makeTab("Sound", 266, ICONS.volume, 86)
makeTab("Animation", 356, ICONS.film, 100)

local content = C("Frame", {
	Size = UDim2.new(1, -20, 1, -118), Position = UDim2.fromOffset(10, 84), BackgroundTransparency = 1, Parent = win,
})

local subBar = C("Frame", {Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, Parent = content})
local outBtn = C("TextButton", {
	Size = UDim2.fromOffset(78, 22), BackgroundColor3 = Color3.fromRGB(30, 38, 58), Text = "Outgoing",
	Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = Color3.fromRGB(170, 185, 230), AutoButtonColor = false, Parent = subBar,
})
corner(outBtn, 6)
stroke(outBtn, Color3.fromRGB(45, 55, 85), 1)
hover(outBtn, Color3.fromRGB(30, 38, 58), Color3.fromRGB(40, 50, 75))

local inBtn = C("TextButton", {
	Size = UDim2.fromOffset(78, 22), Position = UDim2.fromOffset(84, 0), BackgroundColor3 = Color3.fromRGB(14, 14, 18),
	Text = "Incoming", Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = Color3.fromRGB(120, 120, 138), AutoButtonColor = false, Parent = subBar,
})
corner(inBtn, 6)
stroke(inBtn, Color3.fromRGB(26, 26, 34), 1)
hover(inBtn, Color3.fromRGB(14, 14, 18), Color3.fromRGB(22, 22, 30))

local search = C("TextBox", {
	Size = UDim2.new(1, 0, 0, 28), Position = UDim2.fromOffset(0, 30), BackgroundColor3 = Color3.fromRGB(12, 12, 15),
	BorderSizePixel = 0, PlaceholderText = "  Search...", PlaceholderColor3 = Color3.fromRGB(55, 55, 70),
	Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Color3.fromRGB(200, 200, 215), Text = "", ClearTextOnFocus = false, Parent = content,
})
corner(search, 7)
stroke(search, Color3.fromRGB(28, 28, 36), 1)

local list = C("ScrollingFrame", {
	Size = UDim2.new(0.42, 0, 1, -68), Position = UDim2.fromOffset(0, 66), BackgroundColor3 = Color3.fromRGB(10, 10, 13),
	BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = Color3.fromRGB(40, 40, 55), CanvasSize = UDim2.new(0,0,0,0), Parent = content,
})
corner(list, 7)
stroke(list, Color3.fromRGB(24, 24, 32), 1)
C("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 3), Parent = list})
C("UIPadding", {PaddingTop = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4), Parent = list})

local detail = C("Frame", {
	Size = UDim2.new(0.58, -10, 1, -68), Position = UDim2.new(0.42, 10, 0, 66), BackgroundColor3 = Color3.fromRGB(10, 10, 13),
	BorderSizePixel = 0, Parent = content,
})
corner(detail, 7)
stroke(detail, Color3.fromRGB(24, 24, 32), 1)

local dTitle = C("TextLabel", {
	Size = UDim2.new(1, -16, 0, 22), Position = UDim2.fromOffset(10, 8), BackgroundTransparency = 1, Text = "Select",
	Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Color3.fromRGB(155, 155, 175),
	TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = detail,
})
local dScroll = C("ScrollingFrame", {
	Size = UDim2.new(1, -14, 1, -68), Position = UDim2.fromOffset(7, 32), BackgroundTransparency = 1,
	ScrollBarThickness = 3, ScrollBarImageColor3 = Color3.fromRGB(40, 40, 55), CanvasSize = UDim2.new(0,0,0,0), Parent = detail,
})
C("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4), Parent = dScroll})

local actBar = C("Frame", {
	Size = UDim2.new(1, -14, 0, 28), Position = UDim2.new(0, 7, 1, -36), BackgroundTransparency = 1, Parent = detail,
})
local function act(txt, x, bg, hoverBg, w)
	local b = C("TextButton", {
		Size = UDim2.fromOffset(w or 58, 26), Position = UDim2.fromOffset(x, 0), BackgroundColor3 = bg or Color3.fromRGB(16, 16, 22),
		Text = txt, Font = Enum.Font.GothamMedium, TextSize = 10, TextColor3 = Color3.fromRGB(185, 185, 200), AutoButtonColor = false, Parent = actBar,
	})
	corner(b, 6)
	stroke(b, Color3.fromRGB(
		math.min(255, (bg or Color3.fromRGB(16,16,22)).R * 255 + 12),
		math.min(255, (bg or Color3.fromRGB(16,16,22)).G * 255 + 12),
		math.min(255, (bg or Color3.fromRGB(16,16,22)).B * 255 + 12)
	), 1)
	hover(b, bg or Color3.fromRGB(16, 16, 22), hoverBg or Color3.fromRGB(26, 26, 34))
	return b
end
local a1 = act("Copy ID", 0, Color3.fromRGB(24, 32, 52), Color3.fromRGB(34, 44, 70), 60)
local a2 = act("Copy rbx", 64, Color3.fromRGB(20, 28, 42), Color3.fromRGB(30, 40, 58), 64)
local a3 = act("Copy Path", 132, Color3.fromRGB(22, 30, 40), Color3.fromRGB(32, 42, 55), 70)
local a4 = act("Block", 206, Color3.fromRGB(42, 20, 26), Color3.fromRGB(56, 28, 34), 52)
local a5 = act("Clear", 262, Color3.fromRGB(18, 18, 24), Color3.fromRGB(28, 28, 36), 48)

local configPanel = C("ScrollingFrame", {
	Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false,
	ScrollBarThickness = 2, CanvasSize = UDim2.new(0, 0, 0, 260), Parent = content,
})
local function section(t, y)
	C("TextLabel", {
		Size = UDim2.new(1, 0, 0, 16), Position = UDim2.fromOffset(0, y), BackgroundTransparency = 1,
		Text = t, Font = Enum.Font.GothamMedium, TextSize = 10, TextColor3 = Color3.fromRGB(100, 100, 120),
		TextXAlignment = Enum.TextXAlignment.Left, Parent = configPanel,
	})
end
local function toggle(label, desc, y, key)
	local row = C("Frame", {
		Size = UDim2.new(1, 0, 0, 48), Position = UDim2.fromOffset(0, y),
		BackgroundColor3 = Color3.fromRGB(12, 12, 15), BorderSizePixel = 0, Parent = configPanel,
	})
	corner(row, 6)
	C("TextLabel", {
		Size = UDim2.new(1, -56, 0, 16), Position = UDim2.fromOffset(12, 8), BackgroundTransparency = 1,
		Text = label, Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Color3.fromRGB(190, 190, 205),
		TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
	})
	C("TextLabel", {
		Size = UDim2.new(1, -56, 0, 14), Position = UDim2.fromOffset(12, 26), BackgroundTransparency = 1,
		Text = desc, Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = Color3.fromRGB(85, 85, 100),
		TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = row,
	})
	local tg = C("TextButton", {
		Size = UDim2.fromOffset(36, 18), Position = UDim2.new(1, -48, 0.5, -9),
		BackgroundColor3 = Color3.fromRGB(26, 26, 34), Text = "", AutoButtonColor = false, Parent = row,
	})
	corner(tg, 9)
	local knob = C("Frame", {
		Size = UDim2.fromOffset(14, 14), Position = UDim2.fromOffset(2, 2),
		BackgroundColor3 = Color3.fromRGB(100, 100, 120), BorderSizePixel = 0, Parent = tg,
	})
	corner(knob, 7)
	local function upd()
		local on = Settings[key]
		TweenService:Create(tg, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {
			BackgroundColor3 = on and Color3.fromRGB(42, 58, 100) or Color3.fromRGB(26, 26, 34)
		}):Play()
		TweenService:Create(knob, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {
			Position = on and UDim2.fromOffset(20, 2) or UDim2.fromOffset(2, 2),
			BackgroundColor3 = on and Color3.fromRGB(170, 190, 255) or Color3.fromRGB(100, 100, 120)
		}):Play()
	end
	upd()
	tg.MouseButton1Click:Connect(function()
		Settings[key] = not Settings[key]
		upd()
		purgeOtherSources()
	end)
end
section("LOGGERS", 0)
toggle("Show All Players Logs", "On: show every player with expandable groups. Off: only your logs.", 20, "ShowAllPlayers")
toggle("Show NPCs Logs", "On: show NPC logs with groups. Off: hide all NPC logs.", 74, "ShowNPCs")
section("DANGER ZONE", 140)
local unloadBtn = C("TextButton", {
	Size = UDim2.new(1, 0, 0, 34), Position = UDim2.fromOffset(0, 160),
	BackgroundColor3 = Color3.fromRGB(38, 16, 18), Text = "Unload Script",
	Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Color3.fromRGB(220, 140, 140), AutoButtonColor = false, Parent = configPanel,
})
corner(unloadBtn, 7)
stroke(unloadBtn, Color3.fromRGB(60, 28, 32), 1)
hover(unloadBtn, Color3.fromRGB(38, 16, 18), Color3.fromRGB(52, 22, 26))

local clearAllBtn = C("TextButton", {
	Size = UDim2.new(1, 0, 0, 34), Position = UDim2.fromOffset(0, 202),
	BackgroundColor3 = Color3.fromRGB(16, 16, 22), Text = "Clear All Logs",
	Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Color3.fromRGB(175, 175, 195), AutoButtonColor = false, Parent = configPanel,
})
corner(clearAllBtn, 7)
stroke(clearAllBtn, Color3.fromRGB(30, 30, 40), 1)
hover(clearAllBtn, Color3.fromRGB(16, 16, 22), Color3.fromRGB(26, 26, 34))

-- HOME PANEL
local homePanel = C("ScrollingFrame", {
	Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false,
	ScrollBarThickness = 2, CanvasSize = UDim2.new(0, 0, 0, 280), Parent = content,
})

local homeCard = C("Frame", {
	Size = UDim2.new(1, 0, 0, 250), BackgroundColor3 = Color3.fromRGB(12, 12, 15),
	BorderSizePixel = 0, Parent = homePanel,
})
corner(homeCard, 8)
stroke(homeCard, Color3.fromRGB(28, 28, 36), 1)

C("TextLabel", {
	Size = UDim2.new(1, -24, 0, 18), Position = UDim2.fromOffset(14, 14), BackgroundTransparency = 1,
	Text = "Script Version", Font = Enum.Font.GothamMedium, TextSize = 11,
	TextColor3 = Color3.fromRGB(100, 100, 120), TextXAlignment = Enum.TextXAlignment.Left, Parent = homeCard,
})
C("TextLabel", {
	Size = UDim2.new(1, -24, 0, 20), Position = UDim2.fromOffset(14, 32), BackgroundTransparency = 1,
	Text = "v1", Font = Enum.Font.GothamBold, TextSize = 16,
	TextColor3 = Color3.fromRGB(175, 190, 240), TextXAlignment = Enum.TextXAlignment.Left, Parent = homeCard,
})

C("TextLabel", {
	Size = UDim2.new(1, -24, 0, 18), Position = UDim2.fromOffset(14, 62), BackgroundTransparency = 1,
	Text = "Made By", Font = Enum.Font.GothamMedium, TextSize = 11,
	TextColor3 = Color3.fromRGB(100, 100, 120), TextXAlignment = Enum.TextXAlignment.Left, Parent = homeCard,
})
C("TextLabel", {
	Size = UDim2.new(1, -24, 0, 20), Position = UDim2.fromOffset(14, 80), BackgroundTransparency = 1,
	Text = "Erickzzz", Font = Enum.Font.GothamBold, TextSize = 15,
	TextColor3 = Color3.fromRGB(200, 200, 215), TextXAlignment = Enum.TextXAlignment.Left, Parent = homeCard,
})

C("TextLabel", {
	Size = UDim2.new(1, -24, 0, 18), Position = UDim2.fromOffset(14, 112), BackgroundTransparency = 1,
	Text = "Note", Font = Enum.Font.GothamMedium, TextSize = 11,
	TextColor3 = Color3.fromRGB(100, 100, 120), TextXAlignment = Enum.TextXAlignment.Left, Parent = homeCard,
})
C("TextLabel", {
	Size = UDim2.new(1, -24, 0, 70), Position = UDim2.fromOffset(14, 130), BackgroundTransparency = 1,
	Text = "Hello Fella!, im glad that your using my script! if u wanna help me making this script better or adding more things go on my Rscript Profile Go To The Logger And Comment! thanks for using",
	Font = Enum.Font.Gotham, TextSize = 11,
	TextColor3 = Color3.fromRGB(150, 150, 165), TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true, Parent = homeCard,
})

local copyLinkBtn = C("TextButton", {
	Size = UDim2.fromOffset(130, 30), Position = UDim2.fromOffset(14, 208),
	BackgroundColor3 = Color3.fromRGB(24, 32, 52), Text = "", AutoButtonColor = false, Parent = homeCard,
})
corner(copyLinkBtn, 6)
stroke(copyLinkBtn, Color3.fromRGB(40, 50, 80), 1)
hover(copyLinkBtn, Color3.fromRGB(24, 32, 52), Color3.fromRGB(34, 44, 70))

C("ImageLabel", {
	Size = UDim2.fromOffset(14, 14), Position = UDim2.fromOffset(12, 8),
	BackgroundTransparency = 1, Image = ICONS.copy,
	ImageColor3 = Color3.fromRGB(170, 185, 230), Parent = copyLinkBtn,
})
C("TextLabel", {
	Size = UDim2.new(1, -34, 1, 0), Position = UDim2.fromOffset(30, 0), BackgroundTransparency = 1,
	Text = "Copy Link", Font = Enum.Font.GothamMedium, TextSize = 12,
	TextColor3 = Color3.fromRGB(175, 190, 240), TextXAlignment = Enum.TextXAlignment.Left, Parent = copyLinkBtn,
})
copyLinkBtn.MouseButton1Click:Connect(function()
	copy("https://rscripts.net/@Erickzzz")
	UI.setStatus("Profile link copied")
end)

local modalBg = C("Frame", {
	Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	BackgroundTransparency = 1, Visible = false, ZIndex = 25, Parent = gui,
})
local modal = C("Frame", {
	Size = UDim2.fromOffset(0, 0), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = Color3.fromRGB(12, 12, 15), BorderSizePixel = 0, Visible = false, ZIndex = 30, Parent = gui,
})
corner(modal, 8)
C("UIStroke", {Color = Color3.fromRGB(42, 24, 28), Thickness = 1, Parent = modal})
C("TextLabel", {
	Size = UDim2.new(1, -20, 0, 50), Position = UDim2.fromOffset(10, 14), BackgroundTransparency = 1,
	Text = "Do you really want to unload the script?\nThis will remove the script completely.",
	Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Color3.fromRGB(180, 180, 195), TextWrapped = true, Parent = modal,
})
local yesBtn = C("TextButton", {
	Size = UDim2.fromOffset(100, 30), Position = UDim2.fromOffset(20, 78),
	BackgroundColor3 = Color3.fromRGB(48, 20, 24), Text = "Yes", Font = Enum.Font.GothamMedium,
	TextSize = 12, TextColor3 = Color3.fromRGB(230, 150, 150), AutoButtonColor = false, Parent = modal,
})
corner(yesBtn, 6)
stroke(yesBtn, Color3.fromRGB(70, 32, 38), 1)
hover(yesBtn, Color3.fromRGB(48, 20, 24), Color3.fromRGB(62, 28, 32))

local noBtn = C("TextButton", {
	Size = UDim2.fromOffset(100, 30), Position = UDim2.fromOffset(150, 78),
	BackgroundColor3 = Color3.fromRGB(18, 18, 24), Text = "No", Font = Enum.Font.GothamMedium,
	TextSize = 12, TextColor3 = Color3.fromRGB(175, 175, 195), AutoButtonColor = false, Parent = modal,
})
corner(noBtn, 6)
stroke(noBtn, Color3.fromRGB(32, 32, 42), 1)
hover(noBtn, Color3.fromRGB(18, 18, 24), Color3.fromRGB(28, 28, 36))

local status = C("TextLabel", {
	Size = UDim2.new(1, -16, 0, 16), Position = UDim2.new(0, 8, 1, -22), BackgroundTransparency = 1,
	Text = "Ready", Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = Color3.fromRGB(65, 65, 80),
	TextXAlignment = Enum.TextXAlignment.Left, Parent = win,
})
function UI.setStatus(t) status.Text = t end

local function clearList()
	for _, c in ipairs(list:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
end

local function makeRow(text, order, selected, indent, onClick)
	local base = selected and Color3.fromRGB(22, 28, 44) or Color3.fromRGB(13, 13, 17)
	local over = selected and Color3.fromRGB(28, 36, 56) or Color3.fromRGB(18, 18, 24)
	local btn = C("TextButton", {
		Size = UDim2.new(1, -2, 0, 28),
		BackgroundColor3 = base,
		Text = "", AutoButtonColor = false, LayoutOrder = order, Parent = list,
	})
	corner(btn, 6)
	if selected then
		stroke(btn, Color3.fromRGB(40, 50, 80), 1)
	end
	C("TextLabel", {
		Size = UDim2.new(1, -12, 1, 0), Position = UDim2.fromOffset(indent or 10, 0),
		BackgroundTransparency = 1, Text = text, Font = Enum.Font.Gotham, TextSize = 11,
		TextColor3 = selected and Color3.fromRGB(195, 200, 230) or Color3.fromRGB(165, 165, 185),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = btn,
	})
	hover(btn, base, over)
	btn.MouseButton1Click:Connect(onClick)
end

function UI.refresh()
	clearList()
	local filter = string.lower(search.Text or "")
	local order = 0

	if CurrentTab == "Remote" then
		for key, e in pairs(RemoteStack[SelectedType]) do
			if filter == "" or string.find(string.lower(e.name), filter, 1, true) then
				order += 1
				makeRow(e.name .. "  ×" .. e.count, order, SelectedKey == key, 8, function()
					SelectedKey = key
					dTitle.Text = e.name .. "  ·  " .. e.class
					for _, c in ipairs(dScroll:GetChildren()) do if c:IsA("TextLabel") then c:Destroy() end end
					local lbl = C("TextLabel", {
						Size = UDim2.new(1, -4, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
						BackgroundColor3 = Color3.fromRGB(13, 13, 16),
						Text = e.method .. "\n" .. argsStr(e.lastArgs) .. "\n\nCount: " .. e.count .. "\n" .. e.path,
						Font = Enum.Font.Code, TextSize = 10, TextColor3 = Color3.fromRGB(145, 150, 170),
						TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, Parent = dScroll,
					})
					corner(lbl, 4)
					C("UIPadding", {PaddingLeft=UDim.new(0,6), PaddingTop=UDim.new(0,5), PaddingBottom=UDim.new(0,5), Parent=lbl})
					UI.refresh()
				end)
			end
		end
	elseif CurrentTab == "Sound" or CurrentTab == "Animation" then
		local groups = CurrentTab == "Sound" and SoundGroups or AnimGroups
		local sources = {}
		for src in pairs(groups) do table.insert(sources, src) end
		table.sort(sources, function(a, b)
			if a == "You" then return true end
			if b == "You" then return false end
			return a < b
		end)
		local useGroups = Settings.ShowAllPlayers or Settings.ShowNPCs

		for _, src in ipairs(sources) do
			if src ~= "You" then
				local isPlayer = false
				for _, plr in ipairs(Players:GetPlayers()) do if plr.Name == src then isPlayer = true break end end
				if isPlayer and not Settings.ShowAllPlayers then continue end
				if not isPlayer and not Settings.ShowNPCs then continue end
			end
			local group = groups[src]
			if not group then continue end
			local hasMatch = filter == ""
			if not hasMatch then
				for _, e in pairs(group) do
					if string.find(string.lower(e.name), filter, 1, true) or string.find(e.id, filter) or string.find(string.lower(src), filter, 1, true) then
						hasMatch = true break
					end
				end
			end
			if not hasMatch then continue end

			local total = 0
			for _, e in pairs(group) do total += e.count end

			if src == "You" and not useGroups then
				for id, e in pairs(group) do
					if filter == "" or string.find(string.lower(e.name), filter, 1, true) or string.find(e.id, filter) then
						order += 1
						local key = src .. "::" .. id
						makeRow(e.name .. "  [" .. e.id .. "]  ×" .. e.count, order, SelectedKey == key, 8, function()
							SelectedKey = key
							dTitle.Text = e.name
							for _, c in ipairs(dScroll:GetChildren()) do if c:IsA("TextLabel") then c:Destroy() end end
							local text = CurrentTab == "Sound"
								and ("ID: " .. e.id .. "\nSoundId: " .. e.soundId .. "\nCount: " .. e.count)
								or ("ID: " .. e.id .. "\nAnimationId: " .. e.animId .. "\nLength: " .. string.format("%.2f", e.length or 0) .. "s\nCount: " .. e.count)
							local lbl = C("TextLabel", {
								Size = UDim2.new(1, -4, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
								BackgroundColor3 = Color3.fromRGB(13, 13, 16), Text = text,
								Font = Enum.Font.Code, TextSize = 10, TextColor3 = Color3.fromRGB(145, 150, 170),
								TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, Parent = dScroll,
							})
							corner(lbl, 4)
							C("UIPadding", {PaddingLeft=UDim.new(0,6), PaddingTop=UDim.new(0,5), PaddingBottom=UDim.new(0,5), Parent=lbl})
							UI.refresh()
						end)
					end
				end
			else
				local expanded = Expanded[src] == true
				local arrow = expanded and "v" or ">"
				order += 1
				makeRow(string.format("%s  %s  (%d)", src, arrow, total), order, false, 8, function()
					Expanded[src] = not Expanded[src]
					UI.refresh()
				end)
				if expanded then
					for id, e in pairs(group) do
						if filter == "" or string.find(string.lower(e.name), filter, 1, true) or string.find(e.id, filter) then
							order += 1
							local key = src .. "::" .. id
							makeRow(e.name .. "  [" .. e.id .. "]  ×" .. e.count, order, SelectedKey == key, 20, function()
								SelectedKey = key
								dTitle.Text = e.name .. "  ·  " .. src
								for _, c in ipairs(dScroll:GetChildren()) do if c:IsA("TextLabel") then c:Destroy() end end
								local text = CurrentTab == "Sound"
									and ("ID: " .. e.id .. "\nSoundId: " .. e.soundId .. "\nSource: " .. src .. "\nCount: " .. e.count)
									or ("ID: " .. e.id .. "\nAnimationId: " .. e.animId .. "\nSource: " .. src .. "\nLength: " .. string.format("%.2f", e.length or 0) .. "s\nCount: " .. e.count)
								local lbl = C("TextLabel", {
									Size = UDim2.new(1, -4, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
									BackgroundColor3 = Color3.fromRGB(13, 13, 16), Text = text,
									Font = Enum.Font.Code, TextSize = 10, TextColor3 = Color3.fromRGB(145, 150, 170),
									TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, Parent = dScroll,
								})
								corner(lbl, 4)
								C("UIPadding", {PaddingLeft=UDim.new(0,6), PaddingTop=UDim.new(0,5), PaddingBottom=UDim.new(0,5), Parent=lbl})
								UI.refresh()
							end)
						end
					end
				end
			end
		end
	end
	list.CanvasSize = UDim2.new(0, 0, 0, order * 28)
	status.Text = order .. " rows"
end

local function styleTab(name)
	for n, data in pairs(tabBtns) do
		local on = n == name
		local bg = on and Color3.fromRGB(28, 36, 58) or Color3.fromRGB(14, 14, 18)
		local col = on and Color3.fromRGB(175, 190, 240) or Color3.fromRGB(120, 120, 138)
		TweenService:Create(data.btn, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {BackgroundColor3 = bg}):Play()
		TweenService:Create(data.icon, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {ImageColor3 = col}):Play()
		TweenService:Create(data.label, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {TextColor3 = col}):Play()
	end
end

local function setTab(name)
	CurrentTab = name
	styleTab(name)
	SelectedKey = nil
	dTitle.Text = "Select"
	for _, c in ipairs(dScroll:GetChildren()) do if c:IsA("TextLabel") then c:Destroy() end end

	local isHome = name == "Home"
	local isCfg = name == "Config"
	local isRem = name == "Remote"
	local isLogger = name == "Remote" or name == "Sound" or name == "Animation"

	homePanel.Visible = isHome
	configPanel.Visible = isCfg
	subBar.Visible = isRem
	search.Visible = isLogger
	list.Visible = isLogger
	detail.Visible = isLogger

	if name == "Remote" then
		a1.Text = "Copy Code"; a2.Text = "Copy Path"; a3.Text = "Ignore"; a4.Text = "Block"; a5.Text = "Clear"
	elseif name == "Sound" then
		a1.Text = "Copy ID"; a2.Text = "Copy rbx"; a3.Text = "Copy Path"; a4.Text = "Play"; a5.Text = "Clear"
	elseif name == "Animation" then
		a1.Text = "Copy ID"; a2.Text = "Copy rbx"; a3.Text = "Copy Path"; a4.Text = "—"; a5.Text = "Clear"
	end

	if isLogger then UI.refresh() end
end

for n, data in pairs(tabBtns) do
	data.btn.MouseButton1Click:Connect(function() setTab(n) end)
end

outBtn.MouseButton1Click:Connect(function()
	SelectedType = "Outgoing"
	TweenService:Create(outBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(28, 34, 52), TextColor3 = Color3.fromRGB(160, 170, 215)}):Play()
	TweenService:Create(inBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(14, 14, 18), TextColor3 = Color3.fromRGB(115, 115, 130)}):Play()
	SelectedKey = nil; UI.refresh()
end)
inBtn.MouseButton1Click:Connect(function()
	SelectedType = "Incoming"
	TweenService:Create(inBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(28, 34, 52), TextColor3 = Color3.fromRGB(160, 170, 215)}):Play()
	TweenService:Create(outBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(14, 14, 18), TextColor3 = Color3.fromRGB(115, 115, 130)}):Play()
	SelectedKey = nil; UI.refresh()
end)

local function getSelectedEntry()
	if not SelectedKey then return nil end
	if CurrentTab == "Remote" then return RemoteStack[SelectedType][SelectedKey] end
	local src, id = string.match(SelectedKey, "^(.-)::(.+)$")
	if not src then return nil end
	local groups = CurrentTab == "Sound" and SoundGroups or AnimGroups
	return groups[src] and groups[src][id]
end

-- a1: Copy Code (Remote) / Copy ID (Sound/Anim)
a1.MouseButton1Click:Connect(function()
	local e = getSelectedEntry()
	if not e then return end
	if CurrentTab == "Remote" then copy(fireCode(e.remote, e.lastArgs))
	else copy(e.id) end
end)

-- a2: Copy Path (Remote) / Copy rbx (Sound/Anim)
a2.MouseButton1Click:Connect(function()
	local e = getSelectedEntry()
	if not e then return end
	if CurrentTab == "Remote" then copy(e.path or pathOf(e.remote))
	else copy("rbxassetid://" .. e.id) end
end)

-- a3: Ignore (Remote) / Copy Path (Sound/Anim)
a3.MouseButton1Click:Connect(function()
	local e = getSelectedEntry()
	if not e then return end
	if CurrentTab == "Remote" then
		e.ignored = not e.ignored
		UI.setStatus(e.ignored and "Ignored" or "Unignored")
		UI.refresh()
	else
		-- path not stored for sound/anim groups simply; copy name + id
		copy(tostring(e.source or "") .. " | " .. tostring(e.name) .. " | " .. tostring(e.id))
	end
end)

-- a4: Block (Remote) / Play (Sound)
a4.MouseButton1Click:Connect(function()
	local e = getSelectedEntry()
	if not e then return end
	if CurrentTab == "Remote" then
		e.blocked = not e.blocked
		UI.setStatus(e.blocked and "Blocked" or "Unblocked")
		UI.refresh()
	elseif CurrentTab == "Sound" then
		local s = Instance.new("Sound")
		s.SoundId = "rbxassetid://" .. e.id
		s.Parent = workspace
		s:Play()
		task.delay(4, function() s:Destroy() end)
		UI.setStatus("Playing")
	end
end)

-- a5: Clear selected
a5.MouseButton1Click:Connect(function()
	if CurrentTab == "Remote" and SelectedKey then
		RemoteStack[SelectedType][SelectedKey] = nil
	elseif SelectedKey then
		local src, id = string.match(SelectedKey, "^(.-)::(.+)$")
		local groups = CurrentTab == "Sound" and SoundGroups or AnimGroups
		if src and groups[src] then
			groups[src][id] = nil
			if countKeys(groups[src]) == 0 then groups[src] = nil end
		end
	end
	SelectedKey = nil
	dTitle.Text = "Select"
	UI.refresh()
end)

clearAllBtn.MouseButton1Click:Connect(function()
	RemoteStack = { Outgoing = {}, Incoming = {} }; SoundGroups = {}; AnimGroups = {}; Expanded = {}
	SelectedKey = nil; UI.setStatus("Cleared"); UI.refresh()
end)

local function openModal()
	modalBg.Visible = true; modal.Visible = true
	modal.Size = UDim2.fromOffset(0, 0); modalBg.BackgroundTransparency = 1
	TweenService:Create(modalBg, TweenInfo.new(0.2), {BackgroundTransparency = 0.45}):Play()
	TweenService:Create(modal, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(280, 120)}):Play()
end
local function closeModal()
	TweenService:Create(modalBg, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
	local t = TweenService:Create(modal, TweenInfo.new(0.15), {Size = UDim2.fromOffset(0, 0)})
	t:Play(); t.Completed:Connect(function() modal.Visible = false; modalBg.Visible = false end)
end
unloadBtn.MouseButton1Click:Connect(openModal)
noBtn.MouseButton1Click:Connect(closeModal)
yesBtn.MouseButton1Click:Connect(function()
	closeModal()
	task.delay(0.2, function()
		pcall(function() if topIcon and topIcon.destroy then topIcon:destroy() end end)
		pcall(function() gui:Destroy() end)
	end)
end)

search:GetPropertyChangedSignal("Text"):Connect(function() if UI.refresh then UI.refresh() end end)

local function openUI()
	if isOpen then return end
	isOpen = true
	win.Visible = true
	win.Size = UDim2.fromOffset(0, 0)
	win.BackgroundTransparency = 0.4
	TweenService:Create(win, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.fromOffset(600, 450), BackgroundTransparency = 0,
	}):Play()
	setTab(CurrentTab)
end

local function closeUI()
	if not isOpen then return end
	isOpen = false
	local t = TweenService:Create(win, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
		Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 0.5,
	})
	t:Play()
	t.Completed:Connect(function() if not isOpen then win.Visible = false end end)
end

title.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
		dragging = true; dragStart = i.Position; startPos = win.Position
	end
end)
title.InputEnded:Connect(function() dragging = false end)
UserInputService.InputChanged:Connect(function(i)
	if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
		local d = i.Position - dragStart
		win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
	end
end)

-- TopbarPlus (more reliable init)
task.spawn(function()
	task.wait(0.3)
	local ok, err = pcall(function()
		topIcon = Icon.new()
		topIcon:setName("ErickzzzSpy")
		topIcon:align("Right")
		topIcon:setOrder(1)
		topIcon:setImage(10734949856) -- lucide-server
		topIcon:setLabel("Spy")
		topIcon:setCaption("Erickzzz Spy")
		topIcon:bindEvent("selected", openUI)
		topIcon:bindEvent("deselected", closeUI)
	end)
	if not ok then
		warn("[Erickzzz Spy] TopbarPlus error:", err)
	end
end)

setTab("Home")
print("[Erickzzz Spy] Ready")
