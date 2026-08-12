-- Obfuscated Lua source


local _1          = game:GetService("Players")
local _2     = game:GetService("TweenService")
local _3 = game:GetService("UserInputService")
local _4          = game:GetService("CoreGui")

local _5 = _1._5
task.wait(0.1)

local _6 = loadstring(game:HttpGet(
	"https://raw.githubusercontent.com/Therealtobu/Topbar-Plus-For-Executor/main/init.lua"
))()

local _7 = { ShowAllPlayers = false, ShowNPCs = false }
local _8 = 80

local _9 = { Outgoing = {}, Incoming = {} }
local _a = {}
local _b  = {}
local _c = {}

local _d = "Home"
local _e = "Outgoing"
local _f = nil
local _10 = false
local _11, dragStart, startPos
local _12 = {}
local _13 = false
local _14

local function _15(_16)
	if not _16 then return "?" end
	local _17, _60, _111 = _16.Name, _16.Parent, 0
	while _60 and _60 ~= game and _111 < 10 do _17 = _60.Name .. "." .. _17; _60 = _60.Parent; _111 += 1 end
	return _17
end

local function _18(_19)
	return _19 and string.match(tostring(_19), "(%d+)")
end

local function _1a(_1b, _1c)
	_1c = _1c or 0
	if _1c > 3 then return "..." end
	local _1d = typeof(_1b)
	if _1d == "string" then return string.format("%q", _1b)
	elseif _1d == "number" or _1d == "boolean" or _1d == "nil" then return tostring(_1b)
	elseif _1d == "Instance" then return _15(_1b)
	elseif _1d == "Vector3" then return string.format("Vector3.new(%.1f,%.1f,%.1f)", _1b.X, _1b.Y, _1b.Z)
	elseif _1d == "table" then
		local _1e, parts = 0, {}
		for k, val in pairs(_1b) do
			_1e += 1
			if _1e > 5 then parts[#parts+1] = "..." break end
			parts[#parts+1] = "[" .. _1a(k, _1c+1) .. "]=" .. _1a(val, _1c+1)
		end
		return "{" .. table.concat(parts, ",") .. "}"
	end
	return tostring(_1b)
end

local function _1f(_20)
	if not _20 or #_20 == 0 then return "()" end
	local _17 = {}
	for _5e = 1, math.min(#_20, 8) do _17[_5e] = _1a(_20[_5e]) end
	if #_20 > 8 then _17[#_17+1] = "..." end
	return "(" .. table.concat(_17, ", ") .. ")"
end

local function _22(_25, _20)
	local _17 = _15(_25)
	local _24 = _1f(_20)
	if _25:IsA("RemoteFunction") then return _17 .. ":InvokeServer" .. _24 end
	return _17 .. ":FireServer" .. _24
end

local function _27(_28)
	if setclipboard then setclipboard(tostring(_28)); if _12.setStatus then _12.setStatus("Copied") end end
end

local function _29()
	if _13 or not _10 then return end
	_13 = true
	task.defer(function()
		_13 = false
		if _12.refresh and _10 then _12.refresh() end
	end)
end

local function _2a(_1d)
	local _1e = 0
	for _ in pairs(_1d) do _1e += 1 end
	return _1e
end

local function _2c()
	if not _7.ShowAllPlayers then
		for _148 in pairs(_a) do if _148 ~= "You" then _a[_148] = nil end end
		for _148 in pairs(_b) do if _148 ~= "You" then _b[_148] = nil end end
	end
	if not _7.ShowNPCs then
		local _2e = { You = true }
		for _, _42 in ipairs(_1:GetPlayers()) do _2e[_42.Name] = true end
		for _148 in pairs(_a) do if not _2e[_148] then _a[_148] = nil end end
		for _148 in pairs(_b) do if not _2e[_148] then _b[_148] = nil end end
	end
	_29()
end

local function _2f(_25, _35, _20, _37)
	local _30 = _9[_35]
	local _31 = tostring(_25)
	if not _30[_31] then
		if _2a(_30) > _8 then return end
		_30[_31] = {
			_25 = _25, _55 = _25.Name, _61 = _25.ClassName,
			_10d = _15(_25), count = 0, lastArgs = _20, _37 = _37,
			blocked = false, ignored = false,
		}
	end
	local _32 = _30[_31]
	if _32.ignored then return end
	_32.count += 1; _32.lastArgs = _20; _32._37 = _37
	_29()
end

local _33
_33 = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
	local _37 = getnamecallmethod()
	if typeof(self) == "Instance" and (_37 == "FireServer" or _37 == "InvokeServer") then
		if self:IsA("RemoteEvent") or self:IsA("RemoteFunction") or self:IsA("UnreliableRemoteEvent") then
			local _32 = _9.Outgoing[tostring(self)]
			if _32 and _32.blocked then return end
			_2f(self, "Outgoing", {...}, _37)
		end
	end
	return _33(self, ...)
end))

local function _3a(_3b)
	if not _3b or not _3b.Parent then return end
	if _3b:IsA("RemoteEvent") or _3b:IsA("UnreliableRemoteEvent") then
		_3b.OnClientEvent:Connect(function(...) _2f(_3b, "Incoming", {...}, "OnClientEvent") end)
	elseif _3b:IsA("RemoteFunction") then
		local _3c = _3b.OnClientInvoke
		_3b.OnClientInvoke = function(...)
			_2f(_3b, "Incoming", {...}, "OnClientInvoke")
			if _3c then return _3c(...) end
		end
	end
end

task.spawn(function()
	for _, o in ipairs(game:GetDescendants()) do
		if o:IsA("RemoteEvent") or o:IsA("RemoteFunction") or o:IsA("UnreliableRemoteEvent") then _3a(o) end
	end
end)
game.DescendantAdded:Connect(function(o)
	if o:IsA("RemoteEvent") or o:IsA("RemoteFunction") or o:IsA("UnreliableRemoteEvent") then task.defer(_3a, o) end
end)

local function _3d(_3f)
	local _3e = _5.Character
	if _3e and _3f:IsDescendantOf(_3e) then return "You", "local" end
	local _40 = _5:FindFirstChild("PlayerGui")
	if _40 and _3f:IsDescendantOf(_40) then return "You", "local" end
	local _17 = _3f.Parent
	while _17 and _17 ~= workspace do
		local _42 = _1:GetPlayerFromCharacter(_17)
		if _42 then return _42.Name, "player" end
		if _17:IsA("Model") and _17:FindFirstChildOfClass("Humanoid") and not _1:GetPlayerFromCharacter(_17) then
			return _17.Name, "npc"
		end
		_17 = _17.Parent
	end
	return nil, nil
end

local function _43(_3f)
	local _44 = _18(_3f.SoundId)
	if not _44 then return end
	local _45, _4f = _3d(_3f)
	if not _45 then return end
	if _4f == "player" and not _7.ShowAllPlayers then return end
	if _4f == "npc" and not _7.ShowNPCs then return end
	if not _a[_45] then _a[_45] = {} end
	local _47 = _a[_45]
	if not _47[_44] then
		if _2a(_47) > _8 then return end
		_47[_44] = { _44 = _44, _55 = _3f.Name, soundId = _3f.SoundId, count = 0, _45 = _45 }
	end
	_47[_44].count += 1
	_29()
end

local function _48(_49)
	if not _49:IsA("Sound") then return end
	_49:GetPropertyChangedSignal("Playing"):Connect(function()
		if _49.Playing then _43(_49) end
	end)
end

task.spawn(function()
	for _, o in ipairs(game:GetDescendants()) do if o:IsA("Sound") then _48(o) end end
end)
game.DescendantAdded:Connect(function(o) if o:IsA("Sound") then task.defer(_48, o) end end)

local function _4a(_4d, _4e, _4f)
	local _4b = _4d.Animation
	if not _4b then return end
	local _44 = _18(_4b.AnimationId)
	if not _44 then return end
	if _4f == "player" and not _7.ShowAllPlayers then return end
	if _4f == "npc" and not _7.ShowNPCs then return end
	local _45 = _4e or "Unknown"
	if not _b[_45] then _b[_45] = {} end
	local _47 = _b[_45]
	if not _47[_44] then
		if _2a(_47) > _8 then return end
		_47[_44] = {
			_44 = _44, _55 = _4b.Name ~= "" and _4b.Name or _4d.Name,
			animId = _4b.AnimationId, _45 = _45, count = 0, length = _4d.Length,
		}
	end
	_47[_44].count += 1
	_29()
end

local function _52(_3e, _55, _4f)
	local _53 = _3e:FindFirstChildOfClass("Humanoid")
	if not _53 then return end
	local _57 = _53:FindFirstChildOfClass("Animator") or _53:WaitForChild("Animator", 2)
	if not _57 then return end
	_57.AnimationPlayed:Connect(function(_4d) _4a(_4d, _55, _4f) end)
end

local function _58(_42)
	local _59 = _42 == _5
	local _55 = _59 and "You" or _42.Name
	local _4f = _59 and "local" or "player"
	if _42.Character then _52(_42.Character, _55, _4f) end
	_42.CharacterAdded:Connect(function(_60) task.defer(_52, _60, _55, _4f) end)
end

for _, _17 in ipairs(_1:GetPlayers()) do _58(_17) end
_1.PlayerAdded:Connect(_58)

task.spawn(function()
	while true do
		if _7.ShowNPCs then
			for _, model in ipairs(workspace:GetChildren()) do
				if model:IsA("Model") and model:FindFirstChildOfClass("Humanoid") and not _1:GetPlayerFromCharacter(model) then
					if not model:GetAttribute("ES_Hooked") then
						model:SetAttribute("ES_Hooked", true)
						_52(model, model.Name, "npc")
					end
				end
			end
		end
		task.wait(3)
	end
end)

local function _5d(_61, _62)
	local _5e = Instance.new(_61)
	for k, _1b in pairs(_62 or {}) do _5e[k] = _1b end
	return _5e
end
local function _5f(_17, _3b)
	local _60 = Instance.new("UICorner"); _60.CornerRadius = UDim.new(0, _3b or 6); _60.Parent = _17
	return _60
end
local function _65(_17, _68, _69)
	local _49 = Instance.new("UIStroke")
	_49.Color = _68 or Color3.fromRGB(30, 30, 38)
	_49.Thickness = _69 or 1
	_49.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	_49.Parent = _17
	return _49
end
local function _6a(_6c, _6d, _6e, _6f, _70)
	_6d = _6d or _6c.BackgroundColor3
	_6e = _6e or Color3.fromRGB(
		math.min(255, _6d.R * 255 + 18),
		math.min(255, _6d.G * 255 + 18),
		math.min(255, _6d.B * 255 + 18)
	)
	_6c.MouseEnter:Connect(function()
		_2:Create(_6c, TweenInfo.new(0.14, Enum.EasingStyle.Quint), {
			BackgroundColor3 = _6e
		}):Play()
		if _70 then
			_2:Create(_6c, TweenInfo.new(0.14), {TextColor3 = _70}):Play()
		end
	end)
	_6c.MouseLeave:Connect(function()
		_2:Create(_6c, TweenInfo.new(0.14, Enum.EasingStyle.Quint), {
			BackgroundColor3 = _6d
		}):Play()
		if _6f then
			_2:Create(_6c, TweenInfo.new(0.14), {TextColor3 = _6f}):Play()
		end
	end)
end

local _6b = _5d("ScreenGui", {
	Name = "ErickzzzSpy", ResetOnSpawn = false, IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = _4,
})

local _71 = _5d("Frame", {
	Size = UDim2.fromOffset(0, 0), Position = UDim2.new(0.5, 0, 0.5, 0),
	AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.fromRGB(8, 8, 10),
	BorderSizePixel = 0, Visible = false, Parent = _6b,
})
_5f(_71, 12)
_65(_71, Color3.fromRGB(28, 28, 36), 1)

local _72 = _5d("Frame", {
	Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = Color3.fromRGB(11, 11, 14),
	BorderSizePixel = 0, Parent = _71,
})
_5f(_72, 12)

local _73 = _5d("Frame", {
	Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1),
	BackgroundColor3 = Color3.fromRGB(40, 48, 72), BorderSizePixel = 0, Parent = _72,
})

_5d("ImageLabel", {
	Size = UDim2.fromOffset(16, 16), Position = UDim2.fromOffset(14, 11),
	BackgroundTransparency = 1, Image = "rbxassetid://10734949856",
	ImageColor3 = Color3.fromRGB(160, 175, 230), Parent = _72,
})
_5d("TextLabel", {
	Size = UDim2.new(1, -40, 1, 0), Position = UDim2.fromOffset(36, 0), BackgroundTransparency = 1,
	Text = "Erickzzz Spy", Font = Enum.Font.GothamMedium, TextSize = 14,
	TextColor3 = Color3.fromRGB(200, 200, 215), TextXAlignment = Enum.TextXAlignment.Left, Parent = _72,
})

local _74 = {
	server   = "rbxassetid://10734949856",
	radio    = "rbxassetid://10734931596",
	volume   = "rbxassetid://10747375679",
	film     = "rbxassetid://10723374981",
	settings = "rbxassetid://10734950309",
	_86   = "rbxassetid://10734943674",
	_27     = "rbxassetid://10709812159",
	trash    = "rbxassetid://10747362393",
	play     = "rbxassetid://10734923549",
	terminal = "rbxassetid://10734982144",
	home     = "rbxassetid://10723407389",
	user     = "rbxassetid://10747373176",
}

local _75 = _5d("Frame", {
	Size = UDim2.new(1, -12, 0, 34), Position = UDim2.fromOffset(6, 44), BackgroundTransparency = 1, Parent = _71,
})
local _76 = {}
local function _77(_55, _7a, _7b, _7c)
	_7c = _7c or 90
	local _78 = _5d("TextButton", {
		Size = UDim2.fromOffset(_7c, 32), Position = UDim2.fromOffset(_7a, 0),
		BackgroundColor3 = Color3.fromRGB(14, 14, 18), Text = "",
		AutoButtonColor = false, Parent = _75,
	})
	_5f(_78, 7)
	_65(_78, Color3.fromRGB(26, 26, 34), 1)

	local _7d = _5d("ImageLabel", {
		Size = UDim2.fromOffset(14, 14), Position = UDim2.fromOffset(8, 9),
		BackgroundTransparency = 1, Image = _7b,
		ImageColor3 = Color3.fromRGB(130, 130, 150), Parent = _78,
	})
	local _7e = _5d("TextLabel", {
		Size = UDim2.new(1, -28, 1, 0), Position = UDim2.fromOffset(26, 0),
		BackgroundTransparency = 1, Text = _55,
		Font = Enum.Font.GothamMedium, TextSize = 12,
		TextColor3 = Color3.fromRGB(140, 140, 160),
		TextXAlignment = Enum.TextXAlignment.Left, Parent = _78,
	})
	_78.MouseEnter:Connect(function()
		_2:Create(_78, TweenInfo.new(0.14, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(22, 24, 34)}):Play()
		_2:Create(_7d, TweenInfo.new(0.14), {ImageColor3 = Color3.fromRGB(200, 205, 230)}):Play()
		_2:Create(_7e, TweenInfo.new(0.14), {TextColor3 = Color3.fromRGB(200, 205, 230)}):Play()
	end)
	_78.MouseLeave:Connect(function()
		local _7f = _d == _55
		local _80 = _7f and Color3.fromRGB(30, 40, 65) or Color3.fromRGB(14, 14, 18)
		local _81 = _7f and Color3.fromRGB(190, 205, 255) or Color3.fromRGB(140, 140, 160)
		_2:Create(_78, TweenInfo.new(0.14, Enum.EasingStyle.Quint), {BackgroundColor3 = _80}):Play()
		_2:Create(_7d, TweenInfo.new(0.14), {ImageColor3 = _81}):Play()
		_2:Create(_7e, TweenInfo.new(0.14), {TextColor3 = _81}):Play()
	end)
	_76[_55] = {_6c = _78, _7d = _7d, _7e = _7e}
end

_77("Home", 0, _74.home, 76)
_77("Config", 80, _74.settings, 80)
_77("Player", 164, _74.play, 80)
_77("Remote", 248, _74.radio, 84)
_77("Sound", 336, _74.volume, 78)
_77("Animation", 418, _74.film, 94)

local _82 = _5d("Frame", {
	Size = UDim2.new(1, -20, 1, -122), Position = UDim2.fromOffset(10, 86), BackgroundTransparency = 1, Parent = _71,
})

local _83 = _5d("Frame", {Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, Parent = _82})
local _84 = _5d("TextButton", {
	Size = UDim2.fromOffset(78, 22), BackgroundColor3 = Color3.fromRGB(30, 38, 58), Text = "Outgoing",
	Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = Color3.fromRGB(170, 185, 230), AutoButtonColor = false, Parent = _83,
})
_5f(_84, 6)
_65(_84, Color3.fromRGB(45, 55, 85), 1)
_6a(_84, Color3.fromRGB(30, 38, 58), Color3.fromRGB(40, 50, 75))

local _85 = _5d("TextButton", {
	Size = UDim2.fromOffset(78, 22), Position = UDim2.fromOffset(84, 0), BackgroundColor3 = Color3.fromRGB(14, 14, 18),
	Text = "Incoming", Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = Color3.fromRGB(120, 120, 138), AutoButtonColor = false, Parent = _83,
})
_5f(_85, 6)
_65(_85, Color3.fromRGB(26, 26, 34), 1)
_6a(_85, Color3.fromRGB(14, 14, 18), Color3.fromRGB(22, 22, 30))

local _86 = _5d("TextBox", {
	Size = UDim2.new(1, 0, 0, 28), Position = UDim2.fromOffset(0, 30), BackgroundColor3 = Color3.fromRGB(12, 12, 15),
	BorderSizePixel = 0, PlaceholderText = "  Search...", PlaceholderColor3 = Color3.fromRGB(55, 55, 70),
	Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Color3.fromRGB(200, 200, 215), Text = "", ClearTextOnFocus = false, Parent = _82,
})
_5f(_86, 7)
_65(_86, Color3.fromRGB(28, 28, 36), 1)

local _87 = _5d("ScrollingFrame", {
	Size = UDim2.new(0.42, 0, 1, -68), Position = UDim2.fromOffset(0, 66), BackgroundColor3 = Color3.fromRGB(10, 10, 13),
	BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = Color3.fromRGB(40, 40, 55), CanvasSize = UDim2.new(0,0,0,0), Parent = _82,
})
_5f(_87, 7)
_65(_87, Color3.fromRGB(24, 24, 32), 1)
_5d("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 3), Parent = _87})
_5d("UIPadding", {PaddingTop = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4), Parent = _87})

local _88 = _5d("Frame", {
	Size = UDim2.new(0.58, -10, 1, -68), Position = UDim2.new(0.42, 10, 0, 66), BackgroundColor3 = Color3.fromRGB(10, 10, 13),
	BorderSizePixel = 0, Parent = _82,
})
_5f(_88, 7)
_65(_88, Color3.fromRGB(24, 24, 32), 1)

local _89 = _5d("TextLabel", {
	Size = UDim2.new(1, -16, 0, 22), Position = UDim2.fromOffset(10, 8), BackgroundTransparency = 1, Text = "Select",
	Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Color3.fromRGB(155, 155, 175),
	TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = _88,
})
local _8a = _5d("ScrollingFrame", {
	Size = UDim2.new(1, -14, 1, -68), Position = UDim2.fromOffset(7, 32), BackgroundTransparency = 1,
	ScrollBarThickness = 3, ScrollBarImageColor3 = Color3.fromRGB(40, 40, 55), CanvasSize = UDim2.new(0,0,0,0), Parent = _88,
})
_5d("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4), Parent = _8a})

local _8b = _5d("Frame", {
	Size = UDim2.new(1, -14, 0, 28), Position = UDim2.new(0, 7, 1, -36), BackgroundTransparency = 1, Parent = _88,
})
local function _8c(_8e, _7a, _80, _91, _92)
	local _78 = _5d("TextButton", {
		Size = UDim2.fromOffset(_92 or 58, 26), Position = UDim2.fromOffset(_7a, 0), BackgroundColor3 = _80 or Color3.fromRGB(16, 16, 22),
		Text = _8e, Font = Enum.Font.GothamMedium, TextSize = 10, TextColor3 = Color3.fromRGB(185, 185, 200), AutoButtonColor = false, Parent = _8b,
	})
	_5f(_78, 6)
	_65(_78, Color3.fromRGB(
		math.min(255, (_80 or Color3.fromRGB(16,16,22)).R * 255 + 12),
		math.min(255, (_80 or Color3.fromRGB(16,16,22)).G * 255 + 12),
		math.min(255, (_80 or Color3.fromRGB(16,16,22)).B * 255 + 12)
	), 1)
	_6a(_78, _80 or Color3.fromRGB(16, 16, 22), _91 or Color3.fromRGB(26, 26, 34))
	return _78
end
local _93 = _8c("Copy ID", 0, Color3.fromRGB(24, 32, 52), Color3.fromRGB(34, 44, 70), 60)
local _94 = _8c("Copy rbx", 64, Color3.fromRGB(20, 28, 42), Color3.fromRGB(30, 40, 58), 64)
local _95 = _8c("Copy Path", 132, Color3.fromRGB(22, 30, 40), Color3.fromRGB(32, 42, 55), 70)
local _96 = _8c("Block", 206, Color3.fromRGB(42, 20, 26), Color3.fromRGB(56, 28, 34), 52)
local _97 = _8c("Clear", 262, Color3.fromRGB(18, 18, 24), Color3.fromRGB(28, 28, 36), 48)

local _98 = _5d("ScrollingFrame", {
	Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false,
	ScrollBarThickness = 2, CanvasSize = UDim2.new(0, 0, 0, 260), Parent = _82,
})
local function _99(_1d, _9b)
	_5d("TextLabel", {
		Size = UDim2.new(1, 0, 0, 16), Position = UDim2.fromOffset(0, _9b), BackgroundTransparency = 1,
		Text = _1d, Font = Enum.Font.GothamMedium, TextSize = 10, TextColor3 = Color3.fromRGB(100, 100, 120),
		TextXAlignment = Enum.TextXAlignment.Left, Parent = _98,
	})
end
local function _9c(_7e, _9f, _9b, _31)
	local _9d = _5d("Frame", {
		Size = UDim2.new(1, 0, 0, 48), Position = UDim2.fromOffset(0, _9b),
		BackgroundColor3 = Color3.fromRGB(12, 12, 15), BorderSizePixel = 0, Parent = _98,
	})
	_5f(_9d, 6)
	_5d("TextLabel", {
		Size = UDim2.new(1, -56, 0, 16), Position = UDim2.fromOffset(12, 8), BackgroundTransparency = 1,
		Text = _7e, Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Color3.fromRGB(190, 190, 205),
		TextXAlignment = Enum.TextXAlignment.Left, Parent = _9d,
	})
	_5d("TextLabel", {
		Size = UDim2.new(1, -56, 0, 14), Position = UDim2.fromOffset(12, 26), BackgroundTransparency = 1,
		Text = _9f, Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = Color3.fromRGB(85, 85, 100),
		TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = _9d,
	})
	local _a2 = _5d("TextButton", {
		Size = UDim2.fromOffset(36, 18), Position = UDim2.new(1, -48, 0.5, -9),
		BackgroundColor3 = Color3.fromRGB(26, 26, 34), Text = "", AutoButtonColor = false, Parent = _9d,
	})
	_5f(_a2, 9)
	local _a3 = _5d("Frame", {
		Size = UDim2.fromOffset(14, 14), Position = UDim2.fromOffset(2, 2),
		BackgroundColor3 = Color3.fromRGB(100, 100, 120), BorderSizePixel = 0, Parent = _a2,
	})
	_5f(_a3, 7)
	local function _a4()
		local _7f = _7[_31]
		_2:Create(_a2, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {
			BackgroundColor3 = _7f and Color3.fromRGB(42, 58, 100) or Color3.fromRGB(26, 26, 34)
		}):Play()
		_2:Create(_a3, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {
			Position = _7f and UDim2.fromOffset(20, 2) or UDim2.fromOffset(2, 2),
			BackgroundColor3 = _7f and Color3.fromRGB(170, 190, 255) or Color3.fromRGB(100, 100, 120)
		}):Play()
	end
	_a4()
	_a2.MouseButton1Click:Connect(function()
		_7[_31] = not _7[_31]
		_a4()
		_2c()
	end)
end
_99("LOGGERS", 0)
_9c("Show All Players Logs", "On: show every player with expandable groups. Off: only your logs.", 20, "ShowAllPlayers")
_9c("Show NPCs Logs", "On: show NPC logs with groups. Off: hide all NPC logs.", 74, "ShowNPCs")
_99("DANGER ZONE", 140)
local _a6 = _5d("TextButton", {
	Size = UDim2.new(1, 0, 0, 34), Position = UDim2.fromOffset(0, 160),
	BackgroundColor3 = Color3.fromRGB(38, 16, 18), Text = "Unload Script",
	Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Color3.fromRGB(220, 140, 140), AutoButtonColor = false, Parent = _98,
})
_5f(_a6, 7)
_65(_a6, Color3.fromRGB(60, 28, 32), 1)
_6a(_a6, Color3.fromRGB(38, 16, 18), Color3.fromRGB(52, 22, 26))

local _a7 = _5d("TextButton", {
	Size = UDim2.new(1, 0, 0, 34), Position = UDim2.fromOffset(0, 202),
	BackgroundColor3 = Color3.fromRGB(16, 16, 22), Text = "Clear All Logs",
	Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Color3.fromRGB(175, 175, 195), AutoButtonColor = false, Parent = _98,
})
_5f(_a7, 7)
_65(_a7, Color3.fromRGB(30, 30, 40), 1)
_6a(_a7, Color3.fromRGB(16, 16, 22), Color3.fromRGB(26, 26, 34))

local _a8 = _5d("ScrollingFrame", {
	Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false,
	ScrollBarThickness = 2, CanvasSize = UDim2.new(0, 0, 0, 280), Parent = _82,
})

local _a9 = _5d("Frame", {
	Size = UDim2.new(1, 0, 0, 270), BackgroundColor3 = Color3.fromRGB(12, 12, 15),
	BorderSizePixel = 0, Parent = _a8,
})
_5f(_a9, 8)
_65(_a9, Color3.fromRGB(28, 28, 36), 1)

_5d("TextLabel", {
	Size = UDim2.new(1, -24, 0, 18), Position = UDim2.fromOffset(14, 14), BackgroundTransparency = 1,
	Text = "Script Version", Font = Enum.Font.GothamMedium, TextSize = 12,
	TextColor3 = Color3.fromRGB(120, 120, 140), TextXAlignment = Enum.TextXAlignment.Left, Parent = _a9,
})
_5d("TextLabel", {
	Size = UDim2.new(1, -24, 0, 22), Position = UDim2.fromOffset(14, 34), BackgroundTransparency = 1,
	Text = "v1", Font = Enum.Font.GothamBold, TextSize = 20,
	TextColor3 = Color3.fromRGB(185, 200, 255), TextXAlignment = Enum.TextXAlignment.Left, Parent = _a9,
})

_5d("TextLabel", {
	Size = UDim2.new(1, -24, 0, 18), Position = UDim2.fromOffset(14, 68), BackgroundTransparency = 1,
	Text = "Made By", Font = Enum.Font.GothamMedium, TextSize = 12,
	TextColor3 = Color3.fromRGB(120, 120, 140), TextXAlignment = Enum.TextXAlignment.Left, Parent = _a9,
})
_5d("TextLabel", {
	Size = UDim2.new(1, -24, 0, 22), Position = UDim2.fromOffset(14, 88), BackgroundTransparency = 1,
	Text = "Erickzzz", Font = Enum.Font.GothamBold, TextSize = 18,
	TextColor3 = Color3.fromRGB(220, 220, 235), TextXAlignment = Enum.TextXAlignment.Left, Parent = _a9,
})

_5d("TextLabel", {
	Size = UDim2.new(1, -24, 0, 18), Position = UDim2.fromOffset(14, 122), BackgroundTransparency = 1,
	Text = "Note", Font = Enum.Font.GothamMedium, TextSize = 12,
	TextColor3 = Color3.fromRGB(120, 120, 140), TextXAlignment = Enum.TextXAlignment.Left, Parent = _a9,
})
_5d("TextLabel", {
	Size = UDim2.new(1, -24, 0, 72), Position = UDim2.fromOffset(14, 142), BackgroundTransparency = 1,
	Text = "Hello fella! I'm glad you're using my script. If you want to help me make it better or add more features, go to my RScripts profile, open the Logger and leave a comment. Thanks for using it!",
	Font = Enum.Font.Gotham, TextSize = 12,
	TextColor3 = Color3.fromRGB(175, 175, 195), TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true, Parent = _a9,
})

local _aa = _5d("TextButton", {
	Size = UDim2.fromOffset(140, 32), Position = UDim2.fromOffset(14, 224),
	BackgroundColor3 = Color3.fromRGB(24, 32, 52), Text = "", AutoButtonColor = false, Parent = _a9,
})
_5f(_aa, 6)
_65(_aa, Color3.fromRGB(40, 50, 80), 1)
_6a(_aa, Color3.fromRGB(24, 32, 52), Color3.fromRGB(34, 44, 70))

_5d("ImageLabel", {
	Size = UDim2.fromOffset(14, 14), Position = UDim2.fromOffset(12, 8),
	BackgroundTransparency = 1, Image = _74._27,
	ImageColor3 = Color3.fromRGB(170, 185, 230), Parent = _aa,
})
_5d("TextLabel", {
	Size = UDim2.new(1, -34, 1, 0), Position = UDim2.fromOffset(30, 0), BackgroundTransparency = 1,
	Text = "Copy Link", Font = Enum.Font.GothamMedium, TextSize = 12,
	TextColor3 = Color3.fromRGB(175, 190, 240), TextXAlignment = Enum.TextXAlignment.Left, Parent = _aa,
})
_aa.MouseButton1Click:Connect(function()
	_27("https://rscripts.net/@Erickzzz")
	_12.setStatus("Profile link copied")
end)

local _ab = _5d("Frame", {
	Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false, Parent = _82,
})

local _ac = _5d("Frame", {
	Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1, Parent = _ab,
})

local _ad = {}
local _ae = "Animation"
local function _af(_55, _7a, _92)
	local _78 = _5d("TextButton", {
		Size = UDim2.fromOffset(_92, 26), Position = UDim2.fromOffset(_7a, 0),
		BackgroundColor3 = Color3.fromRGB(14, 14, 18), Text = _55,
		Font = Enum.Font.GothamMedium, TextSize = 11,
		TextColor3 = Color3.fromRGB(140, 140, 160), AutoButtonColor = false, Parent = _ac,
	})
	_5f(_78, 6)
	_65(_78, Color3.fromRGB(26, 26, 34), 1)
	_6a(_78, Color3.fromRGB(14, 14, 18), Color3.fromRGB(22, 24, 34))
	_ad[_55] = _78
	return _78
end
_af("Animation", 0, 100)
_af("Sound", 106, 80)
_af("Remote", 192, 80)

local _b4 = _5d("ScrollingFrame", {
	Size = UDim2.new(1, 0, 1, -36), Position = UDim2.fromOffset(0, 34),
	BackgroundColor3 = Color3.fromRGB(11, 11, 14), BorderSizePixel = 0,
	ScrollBarThickness = 3, ScrollBarImageColor3 = Color3.fromRGB(40, 40, 55),
	CanvasSize = UDim2.new(0, 0, 0, 420), Parent = _ab,
})
_5f(_b4, 8)
_65(_b4, Color3.fromRGB(24, 24, 32), 1)
_5d("UIPadding", {PaddingTop = UDim.new(0, 12), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), Parent = _b4})

local _b5 = {
	AnimId = "",
	AnimSpeed = 1,
	AnimLoop = false,
	AnimTrack = nil,
	SoundId = "",
	SoundVol = 1,
	SoundSpeed = 1,
	SoundLoop = false,
	SoundObj = nil,
	RemotePath = "",
	RemoteArgs = "",
	RemoteDelay = 1,
	RemoteLooping = false,
	RemoteLoopThread = nil,
}

local function _b6(_28, _9b)
	return _5d("TextLabel", {
		Size = UDim2.new(1, -8, 0, 16), Position = UDim2.fromOffset(0, _9b), BackgroundTransparency = 1,
		Text = _28, Font = Enum.Font.GothamMedium, TextSize = 12,
		TextColor3 = Color3.fromRGB(150, 150, 170), TextXAlignment = Enum.TextXAlignment.Left, Parent = _b4,
	})
end

local function _b9(_bb, _9b, _bd)
	local _ba = _5d("TextBox", {
		Size = UDim2.new(1, -8, 0, 30), Position = UDim2.fromOffset(0, _9b),
		BackgroundColor3 = Color3.fromRGB(14, 14, 18), BorderSizePixel = 0,
		PlaceholderText = _bb, PlaceholderColor3 = Color3.fromRGB(70, 70, 90),
		Text = _bd or "", Font = Enum.Font.Gotham, TextSize = 12,
		TextColor3 = Color3.fromRGB(210, 210, 225), ClearTextOnFocus = false, Parent = _b4,
	})
	_5f(_ba, 6)
	_65(_ba, Color3.fromRGB(30, 30, 40), 1)
	return _ba
end

local function _be(_28, _9b, _80, _91)
	local _78 = _5d("TextButton", {
		Size = UDim2.new(1, -8, 0, 32), Position = UDim2.fromOffset(0, _9b),
		BackgroundColor3 = _80 or Color3.fromRGB(24, 32, 52), Text = _28,
		Font = Enum.Font.GothamMedium, TextSize = 12,
		TextColor3 = Color3.fromRGB(190, 200, 230), AutoButtonColor = false, Parent = _b4,
	})
	_5f(_78, 6)
	_65(_78, Color3.fromRGB(40, 50, 75), 1)
	_6a(_78, _80 or Color3.fromRGB(24, 32, 52), _91 or Color3.fromRGB(34, 44, 70))
	return _78
end

local function _c4(_7e, _9b, _31)
	local _9d = _5d("Frame", {
		Size = UDim2.new(1, -8, 0, 34), Position = UDim2.fromOffset(0, _9b),
		BackgroundColor3 = Color3.fromRGB(14, 14, 18), BorderSizePixel = 0, Parent = _b4,
	})
	_5f(_9d, 6)
	_5d("TextLabel", {
		Size = UDim2.new(1, -50, 1, 0), Position = UDim2.fromOffset(12, 0), BackgroundTransparency = 1,
		Text = _7e, Font = Enum.Font.GothamMedium, TextSize = 12,
		TextColor3 = Color3.fromRGB(180, 180, 200), TextXAlignment = Enum.TextXAlignment.Left, Parent = _9d,
	})
	local _a2 = _5d("TextButton", {
		Size = UDim2.fromOffset(36, 18), Position = UDim2.new(1, -46, 0.5, -9),
		BackgroundColor3 = Color3.fromRGB(28, 28, 36), Text = "", AutoButtonColor = false, Parent = _9d,
	})
	_5f(_a2, 9)
	local _a3 = _5d("Frame", {
		Size = UDim2.fromOffset(14, 14), Position = UDim2.fromOffset(2, 2),
		BackgroundColor3 = Color3.fromRGB(110, 110, 130), BorderSizePixel = 0, Parent = _a2,
	})
	_5f(_a3, 7)
	local function _a4()
		local _7f = _b5[_31]
		_2:Create(_a2, TweenInfo.new(0.15), {BackgroundColor3 = _7f and Color3.fromRGB(42, 58, 100) or Color3.fromRGB(28, 28, 36)}):Play()
		_2:Create(_a3, TweenInfo.new(0.15), {
			Position = _7f and UDim2.fromOffset(20, 2) or UDim2.fromOffset(2, 2),
			BackgroundColor3 = _7f and Color3.fromRGB(170, 190, 255) or Color3.fromRGB(110, 110, 130)
		}):Play()
	end
	_a4()
	_a2.MouseButton1Click:Connect(function()
		_b5[_31] = not _b5[_31]
		_a4()
	end)
	return _9d
end

local _cd = _b6("Animation ID", 0)
local _ce = _b9("e.g. 507766388", 20)
local _cf = _b6("Animation Speed", 58)
local _d0 = _b9("1", 78, "1")
local _d1 = _c4("Play in Loop", 118, "AnimLoop")
local _d2 = _be("Play Animation", 162, Color3.fromRGB(28, 48, 40), Color3.fromRGB(36, 60, 50))
local _d3 = _be("Stop Animation", 200, Color3.fromRGB(42, 22, 26), Color3.fromRGB(56, 30, 36))
local _d4 = _be("Copy Edited Animation Script", 238, Color3.fromRGB(24, 32, 52), Color3.fromRGB(34, 44, 70))
local _d5 = _5d("TextLabel", {
	Size = UDim2.new(1, -8, 0, 36), Position = UDim2.fromOffset(0, 276), BackgroundTransparency = 1,
	Text = "Copies a ready-to-use script that plays this animation with your current speed and loop settings.",
	Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = Color3.fromRGB(110, 110, 130),
	TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, Parent = _b4,
})

local _d6 = _b6("Sound ID", 0)
local _d7 = _b9("e.g. 1848354536", 20)
local _d8 = _b6("Volume (0-10)", 58)
local _d9 = _b9("1", 78, "1")
local _da = _b6("Playback Speed", 118)
local _db = _b9("1", 138, "1")
local _dc = _c4("Play in Loop", 178, "SoundLoop")
local _dd = _be("Play Sound", 222, Color3.fromRGB(28, 48, 40), Color3.fromRGB(36, 60, 50))
local _de = _be("Stop Sound", 260, Color3.fromRGB(42, 22, 26), Color3.fromRGB(56, 30, 36))
local _df = _be("Copy Edited Sound Script", 298, Color3.fromRGB(24, 32, 52), Color3.fromRGB(34, 44, 70))
local _e0 = _5d("TextLabel", {
	Size = UDim2.new(1, -8, 0, 36), Position = UDim2.fromOffset(0, 336), BackgroundTransparency = 1,
	Text = "Copies a ready-to-use script that plays this sound with your current volume, speed and loop settings.",
	Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = Color3.fromRGB(110, 110, 130),
	TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, Parent = _b4,
})

local _e1 = _b6("Remote Path or Name", 0)
local _e2 = _b9("game.ReplicatedStorage.RemoteEvent", 20)
local _e3 = _b6("Arguments (Lua table)", 58)
local _e4 = _b9('{1, "hello"}', 78, "{}")
local _e5 = _b6("Loop Delay (seconds)", 118)
local _e6 = _b9("1", 138, "1")
local _e7 = _c4("Play in Loop", 178, "RemoteLooping")
local _e8 = _be("Fire Remote", 222, Color3.fromRGB(28, 48, 40), Color3.fromRGB(36, 60, 50))
local _e9 = _be("Stop Loop", 260, Color3.fromRGB(42, 22, 26), Color3.fromRGB(56, 30, 36))
local _ea = _be("Copy Remote Fire Script", 298, Color3.fromRGB(24, 32, 52), Color3.fromRGB(34, 44, 70))
local _eb = _5d("TextLabel", {
	Size = UDim2.new(1, -8, 0, 36), Position = UDim2.fromOffset(0, 336), BackgroundTransparency = 1,
	Text = "Copies a script that fires this remote with your arguments. Loop delay is included if enabled.",
	Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = Color3.fromRGB(110, 110, 130),
	TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, Parent = _b4,
})

local _ec = {
	_cd, _ce, _cf, _d0, _d1, _d2, _d3, _d4, _d5,
	_d6, _d7, _d8, _d9, _da, _db, _dc, _dd, _de, _df, _e0,
	_e1, _e2, _e3, _e4, _e5, _e6, _e7, _e8, _e9, _ea, _eb,
}

local function _ed(_55)
	_ae = _55
	for _1e, _78 in pairs(_ad) do
		local _7f = _1e == _55
		_2:Create(_78, TweenInfo.new(0.12), {
			BackgroundColor3 = _7f and Color3.fromRGB(30, 40, 65) or Color3.fromRGB(14, 14, 18),
			TextColor3 = _7f and Color3.fromRGB(190, 205, 255) or Color3.fromRGB(140, 140, 160)
		}):Play()
	end
	local _ef = _55 == "Animation"
	local _f1 = _55 == "Sound"
	local _f2 = _55 == "Remote"
	for _, _92 in ipairs({_cd, _ce, _cf, _d0, _d1, _d2, _d3, _d4, _d5}) do
		_92.Visible = _ef
	end
	for _, _92 in ipairs({_d6, _d7, _d8, _d9, _da, _db, _dc, _dd, _de, _df, _e0}) do
		_92.Visible = _f1
	end
	for _, _92 in ipairs({_e1, _e2, _e3, _e4, _e5, _e6, _e7, _e8, _e9, _ea, _eb}) do
		_92.Visible = _f2
	end
end

for _1e, _78 in pairs(_ad) do
	_78.MouseButton1Click:Connect(function() _ed(_1e) end)
end
_ed("Animation")

_d2.MouseButton1Click:Connect(function()
	local _44 = _ce.Text:match("(%d+)")
	if not _44 then _12.setStatus("Invalid animation ID") return end
	local _f4 = tonumber(_d0.Text) or 1
	local _3e = _5.Character
	if not _3e then return end
	local _53 = _3e:FindFirstChildOfClass("Humanoid")
	if not _53 then return end
	local _57 = _53:FindFirstChildOfClass("Animator") or Instance.new("Animator", _53)
	if _b5.AnimTrack then pcall(function() _b5.AnimTrack:Stop() end) end
	local _4b = Instance.new("Animation")
	_4b.AnimationId = "rbxassetid://" .. _44
	local _4d = _57:LoadAnimation(_4b)
	_4d.Looped = _b5.AnimLoop
	_4d:AdjustSpeed(_f4)
	_4d:Play()
	_b5.AnimTrack = _4d
	_b5.AnimId = _44
	_b5.AnimSpeed = _f4
	_12.setStatus("Playing animation")
end)

_d3.MouseButton1Click:Connect(function()
	if _b5.AnimTrack then
		pcall(function() _b5.AnimTrack:Stop() end)
		_b5.AnimTrack = nil
		_12.setStatus("Animation stopped")
	end
end)

_d4.MouseButton1Click:Connect(function()
	local _44 = _ce.Text:match("(%d+)") or _b5.AnimId
	if not _44 or _44 == "" then _12.setStatus("No animation ID") return end
	local _f4 = tonumber(_d0.Text) or 1
	local _fc = _b5.AnimLoop and "true" or "false"
	local _fd = string.format([[local _4b = Instance.new("Animation")
_4b.AnimationId = "rbxassetid://%s"
local _53 = game._1._5.Character and game._1._5.Character:FindFirstChildOfClass("Humanoid")
if _53 then
	local _57 = _53:FindFirstChildOfClass("Animator") or Instance.new("Animator", _53)
	local _4d = _57:LoadAnimation(_4b)
	_4d.Looped = %_49
	_4d:AdjustSpeed(%.2f)
	_4d:Play()
end]], _44, _fc, _f4)
	_27(_fd)
	_12.setStatus("Animation script copied")
end)

_dd.MouseButton1Click:Connect(function()
	local _44 = _d7.Text:match("(%d+)")
	if not _44 then _12.setStatus("Invalid sound ID") return end
	local _103 = tonumber(_d9.Text) or 1
	local _f4 = tonumber(_db.Text) or 1
	if _b5.SoundObj then pcall(function() _b5.SoundObj:Stop() _b5.SoundObj:Destroy() end) end
	local _49 = Instance.new("Sound")
	_49.SoundId = "rbxassetid://" .. _44
	_49.Volume = _103
	_49.PlaybackSpeed = _f4
	_49.Looped = _b5.SoundLoop
	_49.Parent = workspace
	_49:Play()
	_b5.SoundObj = _49
	_b5.SoundId = _44
	_12.setStatus("Playing sound")
end)

_de.MouseButton1Click:Connect(function()
	if _b5.SoundObj then
		pcall(function() _b5.SoundObj:Stop() _b5.SoundObj:Destroy() end)
		_b5.SoundObj = nil
		_12.setStatus("Sound stopped")
	end
end)

_df.MouseButton1Click:Connect(function()
	local _44 = _d7.Text:match("(%d+)") or _b5.SoundId
	if not _44 or _44 == "" then _12.setStatus("No sound ID") return end
	local _103 = tonumber(_d9.Text) or 1
	local _f4 = tonumber(_db.Text) or 1
	local _fc = _b5.SoundLoop and "true" or "false"
	local _fd = string.format([[local _49 = Instance.new("Sound")
_49.SoundId = "rbxassetid://%s"
_49.Volume = %.2f
_49.PlaybackSpeed = %.2f
_49.Looped = %_49
_49.Parent = workspace
_49:Play()]], _44, _103, _f4, _fc)
	_27(_fd)
	_12.setStatus("Sound script copied")
end)

local function _10c()
	local _10d = _e2.Text
	if _10d == "" then _12.setStatus("No remote path") return false end
	local _10e = _e4.Text
	if _10e == "" then _10e = "{}" end
	local _10f, _20 = pcall(function()
		return loadstring("return " .. _10e)()
	end)
	if not _10f or type(_20) ~= "table" then _12.setStatus("Invalid arguments") return false end
	local _110, _25 = pcall(function()
		return loadstring("return " .. _10d)()
	end)
	if not _110 or typeof(_25) ~= "Instance" then
		
		for _, o in ipairs(game:GetDescendants()) do
			if (o:IsA("RemoteEvent") or o:IsA("RemoteFunction") or o:IsA("UnreliableRemoteEvent")) and o.Name == _10d then
				_25 = o
				break
			end
		end
	end
	if typeof(_25) ~= "Instance" then _12.setStatus("Remote not found") return false end
	if _25:IsA("RemoteEvent") or _25:IsA("UnreliableRemoteEvent") then
		_25:FireServer(unpack(_20))
	elseif _25:IsA("RemoteFunction") then
		task.spawn(function() _25:InvokeServer(unpack(_20)) end)
	end
	return true
end

_e8.MouseButton1Click:Connect(function()
	if _b5.RemoteLooping then
		if _b5.RemoteLoopThread then return end
		_b5.RemoteLoopThread = task.spawn(function()
			while _b5.RemoteLooping do
				if not _10c() then break end
				local _111 = tonumber(_e6.Text) or 1
				task.wait(math.max(0.05, _111))
			end
			_b5.RemoteLoopThread = nil
		end)
		_12.setStatus("Remote loop started")
	else
		if _10c() then _12.setStatus("Remote fired") end
	end
end)

_e9.MouseButton1Click:Connect(function()
	_b5.RemoteLooping = false
	_b5.RemoteLoopThread = nil
	_12.setStatus("Remote loop stopped")
end)

_ea.MouseButton1Click:Connect(function()
	local _10d = _e2.Text
	if _10d == "" then _12.setStatus("No remote path") return end
	local _10e = _e4.Text
	if _10e == "" then _10e = "{}" end
	local _114 = tonumber(_e6.Text) or 1
	local _fd
	if _b5.RemoteLooping then
		_fd = string.format([[local _25 = %_49
local _20 = %_49
while true do
	if _25:IsA("RemoteEvent") or _25:IsA("UnreliableRemoteEvent") then
		_25:FireServer(unpack(_20))
	elseif _25:IsA("RemoteFunction") then
		_25:InvokeServer(unpack(_20))
	end
	task.wait(%.2f)
end]], _10d, _10e, _114)
	else
		_fd = string.format([[local _25 = %_49
local _20 = %_49
if _25:IsA("RemoteEvent") or _25:IsA("UnreliableRemoteEvent") then
	_25:FireServer(unpack(_20))
elseif _25:IsA("RemoteFunction") then
	_25:InvokeServer(unpack(_20))
end]], _10d, _10e)
	end
	_27(_fd)
	_12.setStatus("Remote script copied")
end)

local _11a = _5d("Frame", {
	Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	BackgroundTransparency = 1, Visible = false, ZIndex = 25, Parent = _6b,
})
local _11b = _5d("Frame", {
	Size = UDim2.fromOffset(0, 0), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = Color3.fromRGB(12, 12, 15), BorderSizePixel = 0, Visible = false, ZIndex = 30, Parent = _6b,
})
_5f(_11b, 8)
_5d("UIStroke", {Color = Color3.fromRGB(42, 24, 28), Thickness = 1, Parent = _11b})
_5d("TextLabel", {
	Size = UDim2.new(1, -20, 0, 50), Position = UDim2.fromOffset(10, 14), BackgroundTransparency = 1,
	Text = "Do you really want to unload the script?\nThis will remove the script completely.",
	Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Color3.fromRGB(180, 180, 195), TextWrapped = true, Parent = _11b,
})
local _11c = _5d("TextButton", {
	Size = UDim2.fromOffset(100, 30), Position = UDim2.fromOffset(20, 78),
	BackgroundColor3 = Color3.fromRGB(48, 20, 24), Text = "Yes", Font = Enum.Font.GothamMedium,
	TextSize = 12, TextColor3 = Color3.fromRGB(230, 150, 150), AutoButtonColor = false, Parent = _11b,
})
_5f(_11c, 6)
_65(_11c, Color3.fromRGB(70, 32, 38), 1)
_6a(_11c, Color3.fromRGB(48, 20, 24), Color3.fromRGB(62, 28, 32))

local _11d = _5d("TextButton", {
	Size = UDim2.fromOffset(100, 30), Position = UDim2.fromOffset(150, 78),
	BackgroundColor3 = Color3.fromRGB(18, 18, 24), Text = "No", Font = Enum.Font.GothamMedium,
	TextSize = 12, TextColor3 = Color3.fromRGB(175, 175, 195), AutoButtonColor = false, Parent = _11b,
})
_5f(_11d, 6)
_65(_11d, Color3.fromRGB(32, 32, 42), 1)
_6a(_11d, Color3.fromRGB(18, 18, 24), Color3.fromRGB(28, 28, 36))

local _11e = _5d("TextLabel", {
	Size = UDim2.new(1, -16, 0, 16), Position = UDim2.new(0, 8, 1, -22), BackgroundTransparency = 1,
	Text = "Ready", Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = Color3.fromRGB(65, 65, 80),
	TextXAlignment = Enum.TextXAlignment.Left, Parent = _71,
})
function _12.setStatus(_1d) _11e.Text = _1d end

local function _11f()
	for _, _60 in ipairs(_87:GetChildren()) do if _60:IsA("TextButton") then _60:Destroy() end end
end

local function _120(_28, _125, _126, _127, _128)
	local _6d = _126 and Color3.fromRGB(22, 28, 44) or Color3.fromRGB(13, 13, 17)
	local _6e = _126 and Color3.fromRGB(28, 36, 56) or Color3.fromRGB(18, 18, 24)
	local _6c = _5d("TextButton", {
		Size = UDim2.new(1, -2, 0, 28),
		BackgroundColor3 = _6d,
		Text = "", AutoButtonColor = false, LayoutOrder = _125, Parent = _87,
	})
	_5f(_6c, 6)
	if _126 then
		_65(_6c, Color3.fromRGB(40, 50, 80), 1)
	end
	_5d("TextLabel", {
		Size = UDim2.new(1, -12, 1, 0), Position = UDim2.fromOffset(_127 or 10, 0),
		BackgroundTransparency = 1, Text = _28, Font = Enum.Font.Gotham, TextSize = 11,
		TextColor3 = _126 and Color3.fromRGB(195, 200, 230) or Color3.fromRGB(165, 165, 185),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = _6c,
	})
	_6a(_6c, _6d, _6e)
	_6c.MouseButton1Click:Connect(_128)
end

function _12.refresh()
	_11f()
	local _129 = string.lower(_86.Text or "")
	local _125 = 0

	if _d == "Remote" then
		for _31, _32 in pairs(_9[_e]) do
			if _129 == "" or string.find(string.lower(_32._55), _129, 1, true) then
				_125 += 1
				_120(_32._55 .. "  ×" .. _32.count, _125, _f == _31, 8, function()
					_f = _31
					_89.Text = _32._55 .. "  ·  " .. _32._61
					for _, _60 in ipairs(_8a:GetChildren()) do if _60:IsA("TextLabel") then _60:Destroy() end end
					local _12b = _5d("TextLabel", {
						Size = UDim2.new(1, -4, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
						BackgroundColor3 = Color3.fromRGB(13, 13, 16),
						Text = _32._37 .. "\n" .. _1f(_32.lastArgs) .. "\n\nCount: " .. _32.count .. "\n" .. _32._10d,
						Font = Enum.Font.Code, TextSize = 10, TextColor3 = Color3.fromRGB(145, 150, 170),
						TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, Parent = _8a,
					})
					_5f(_12b, 4)
					_5d("UIPadding", {PaddingLeft=UDim.new(0,6), PaddingTop=UDim.new(0,5), PaddingBottom=UDim.new(0,5), Parent=_12b})
					_12.refresh()
				end)
			end
		end
	elseif _d == "Sound" or _d == "Animation" then
		local _12c = _d == "Sound" and _a or _b
		local _12d = {}
		for _148 in pairs(_12c) do table.insert(_12d, _148) end
		table.sort(_12d, function(_24, _78)
			if _24 == "You" then return true end
			if _78 == "You" then return false end
			return _24 < _78
		end)
		local _12e = _7.ShowAllPlayers or _7.ShowNPCs

		for _, _148 in ipairs(_12d) do
			if _148 ~= "You" then
				local _12f = false
				for _, _42 in ipairs(_1:GetPlayers()) do if _42.Name == _148 then _12f = true break end end
				if _12f and not _7.ShowAllPlayers then continue end
				if not _12f and not _7.ShowNPCs then continue end
			end
			local _130 = _12c[_148]
			if not _130 then continue end
			local _131 = _129 == ""
			if not _131 then
				for _, _32 in pairs(_130) do
					if string.find(string.lower(_32._55), _129, 1, true) or string.find(_32._44, _129) or string.find(string.lower(_148), _129, 1, true) then
						_131 = true break
					end
				end
			end
			if not _131 then continue end

			local _132 = 0
			for _, _32 in pairs(_130) do _132 += _32.count end

			if _148 == "You" and not _12e then
				for _44, _32 in pairs(_130) do
					if _129 == "" or string.find(string.lower(_32._55), _129, 1, true) or string.find(_32._44, _129) then
						_125 += 1
						local _31 = _148 .. "::" .. _44
						_120(_32._55 .. "  [" .. _32._44 .. "]  ×" .. _32.count, _125, _f == _31, 8, function()
							_f = _31
							_89.Text = _32._55
							for _, _60 in ipairs(_8a:GetChildren()) do if _60:IsA("TextLabel") then _60:Destroy() end end
							local _28 = _d == "Sound"
								and ("ID: " .. _32._44 .. "\nSoundId: " .. _32.soundId .. "\nCount: " .. _32.count)
								or ("ID: " .. _32._44 .. "\nAnimationId: " .. _32.animId .. "\nLength: " .. string.format("%.2f", _32.length or 0) .. "s\nCount: " .. _32.count)
							local _12b = _5d("TextLabel", {
								Size = UDim2.new(1, -4, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
								BackgroundColor3 = Color3.fromRGB(13, 13, 16), Text = _28,
								Font = Enum.Font.Code, TextSize = 10, TextColor3 = Color3.fromRGB(145, 150, 170),
								TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, Parent = _8a,
							})
							_5f(_12b, 4)
							_5d("UIPadding", {PaddingLeft=UDim.new(0,6), PaddingTop=UDim.new(0,5), PaddingBottom=UDim.new(0,5), Parent=_12b})
							_12.refresh()
						end)
					end
				end
			else
				local _136 = _c[_148] == true
				local _137 = _136 and "v" or ">"
				_125 += 1
				_120(string.format("%s  %s  (%d)", _148, _137, _132), _125, false, 8, function()
					_c[_148] = not _c[_148]
					_12.refresh()
				end)
				if _136 then
					for _44, _32 in pairs(_130) do
						if _129 == "" or string.find(string.lower(_32._55), _129, 1, true) or string.find(_32._44, _129) then
							_125 += 1
							local _31 = _148 .. "::" .. _44
							_120(_32._55 .. "  [" .. _32._44 .. "]  ×" .. _32.count, _125, _f == _31, 20, function()
								_f = _31
								_89.Text = _32._55 .. "  ·  " .. _148
								for _, _60 in ipairs(_8a:GetChildren()) do if _60:IsA("TextLabel") then _60:Destroy() end end
								local _28 = _d == "Sound"
									and ("ID: " .. _32._44 .. "\nSoundId: " .. _32.soundId .. "\nSource: " .. _148 .. "\nCount: " .. _32.count)
									or ("ID: " .. _32._44 .. "\nAnimationId: " .. _32.animId .. "\nSource: " .. _148 .. "\nLength: " .. string.format("%.2f", _32.length or 0) .. "s\nCount: " .. _32.count)
								local _12b = _5d("TextLabel", {
									Size = UDim2.new(1, -4, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
									BackgroundColor3 = Color3.fromRGB(13, 13, 16), Text = _28,
									Font = Enum.Font.Code, TextSize = 10, TextColor3 = Color3.fromRGB(145, 150, 170),
									TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, Parent = _8a,
								})
								_5f(_12b, 4)
								_5d("UIPadding", {PaddingLeft=UDim.new(0,6), PaddingTop=UDim.new(0,5), PaddingBottom=UDim.new(0,5), Parent=_12b})
								_12.refresh()
							end)
						end
					end
				end
			end
		end
	end
	_87.CanvasSize = UDim2.new(0, 0, 0, _125 * 28)
	_11e.Text = _125 .. " rows"
end

local function _13b(_55)
	for _1e, data in pairs(_76) do
		local _7f = _1e == _55
		local _80 = _7f and Color3.fromRGB(30, 40, 65) or Color3.fromRGB(14, 14, 18)
		local _81 = _7f and Color3.fromRGB(190, 205, 255) or Color3.fromRGB(140, 140, 160)
		_2:Create(data._6c, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {BackgroundColor3 = _80}):Play()
		_2:Create(data._7d, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {ImageColor3 = _81}):Play()
		_2:Create(data._7e, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {TextColor3 = _81}):Play()
	end
end

local function _13f(_55)
	_d = _55
	_13b(_55)
	_f = nil
	_89.Text = "Select"
	for _, _60 in ipairs(_8a:GetChildren()) do if _60:IsA("TextLabel") then _60:Destroy() end end

	local _142 = _55 == "Home"
	local _143 = _55 == "Config"
	local _12f = _55 == "Player"
	local _145 = _55 == "Remote"
	local _146 = _55 == "Remote" or _55 == "Sound" or _55 == "Animation"

	_a8.Visible = _142
	_98.Visible = _143
	_ab.Visible = _12f
	_83.Visible = _145
	_86.Visible = _146
	_87.Visible = _146
	_88.Visible = _146

	if _55 == "Remote" then
		_93.Text = "Copy Code"; _94.Text = "Copy Path"; _95.Text = "Ignore"; _96.Text = "Block"; _97.Text = "Clear"
	elseif _55 == "Sound" then
		_93.Text = "Copy ID"; _94.Text = "Copy rbx"; _95.Text = "Copy Path"; _96.Text = "Play"; _97.Text = "Clear"
	elseif _55 == "Animation" then
		_93.Text = "Copy ID"; _94.Text = "Copy rbx"; _95.Text = "Copy Path"; _96.Text = "—"; _97.Text = "Clear"
	end

	if _146 then _12.refresh() end
end

for _1e, data in pairs(_76) do
	data._6c.MouseButton1Click:Connect(function() _13f(_1e) end)
end

_84.MouseButton1Click:Connect(function()
	_e = "Outgoing"
	_2:Create(_84, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(28, 34, 52), TextColor3 = Color3.fromRGB(160, 170, 215)}):Play()
	_2:Create(_85, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(14, 14, 18), TextColor3 = Color3.fromRGB(115, 115, 130)}):Play()
	_f = nil; _12.refresh()
end)
_85.MouseButton1Click:Connect(function()
	_e = "Incoming"
	_2:Create(_85, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(28, 34, 52), TextColor3 = Color3.fromRGB(160, 170, 215)}):Play()
	_2:Create(_84, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(14, 14, 18), TextColor3 = Color3.fromRGB(115, 115, 130)}):Play()
	_f = nil; _12.refresh()
end)

local function _147()
	if not _f then return nil end
	if _d == "Remote" then return _9[_e][_f] end
	local _148, _44 = string.match(_f, "^(.-)::(.+)$")
	if not _148 then return nil end
	local _12c = _d == "Sound" and _a or _b
	return _12c[_148] and _12c[_148][_44]
end

_93.MouseButton1Click:Connect(function()
	local _32 = _147()
	if not _32 then return end
	if _d == "Remote" then _27(_22(_32._25, _32.lastArgs))
	else _27(_32._44) end
end)

_94.MouseButton1Click:Connect(function()
	local _32 = _147()
	if not _32 then return end
	if _d == "Remote" then _27(_32._10d or _15(_32._25))
	else _27("rbxassetid://" .. _32._44) end
end)

_95.MouseButton1Click:Connect(function()
	local _32 = _147()
	if not _32 then return end
	if _d == "Remote" then
		_32.ignored = not _32.ignored
		_12.setStatus(_32.ignored and "Ignored" or "Unignored")
		_12.refresh()
	else
		
		_27(tostring(_32._45 or "") .. " | " .. tostring(_32._55) .. " | " .. tostring(_32._44))
	end
end)

_96.MouseButton1Click:Connect(function()
	local _32 = _147()
	if not _32 then return end
	if _d == "Remote" then
		_32.blocked = not _32.blocked
		_12.setStatus(_32.blocked and "Blocked" or "Unblocked")
		_12.refresh()
	elseif _d == "Sound" then
		local _49 = Instance.new("Sound")
		_49.SoundId = "rbxassetid://" .. _32._44
		_49.Parent = workspace
		_49:Play()
		task._114(4, function() _49:Destroy() end)
		_12.setStatus("Playing")
	end
end)

_97.MouseButton1Click:Connect(function()
	if _d == "Remote" and _f then
		_9[_e][_f] = nil
	elseif _f then
		local _148, _44 = string.match(_f, "^(.-)::(.+)$")
		local _12c = _d == "Sound" and _a or _b
		if _148 and _12c[_148] then
			_12c[_148][_44] = nil
			if _2a(_12c[_148]) == 0 then _12c[_148] = nil end
		end
	end
	_f = nil
	_89.Text = "Select"
	_12.refresh()
end)

_a7.MouseButton1Click:Connect(function()
	_9 = { Outgoing = {}, Incoming = {} }; _a = {}; _b = {}; _c = {}
	_f = nil; _12.setStatus("Cleared"); _12.refresh()
end)

local function _151()
	_11a.Visible = true; _11b.Visible = true
	_11b.Size = UDim2.fromOffset(0, 0); _11a.BackgroundTransparency = 1
	_2:Create(_11a, TweenInfo.new(0.2), {BackgroundTransparency = 0.45}):Play()
	_2:Create(_11b, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(280, 120)}):Play()
end
local function _152()
	_2:Create(_11a, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
	local _1d = _2:Create(_11b, TweenInfo.new(0.15), {Size = UDim2.fromOffset(0, 0)})
	_1d:Play(); _1d.Completed:Connect(function() _11b.Visible = false; _11a.Visible = false end)
end
_a6.MouseButton1Click:Connect(_151)
_11d.MouseButton1Click:Connect(_152)
_11c.MouseButton1Click:Connect(function()
	_152()
	task._114(0.2, function()
		pcall(function() if _14 and _14.destroy then _14:destroy() end end)
		pcall(function() _6b:Destroy() end)
	end)
end)

_86:GetPropertyChangedSignal("Text"):Connect(function() if _12.refresh then _12.refresh() end end)

local function _154()
	if _10 then return end
	_10 = true
	_71.Visible = true
	_71.Size = UDim2.fromOffset(0, 0)
	_71.BackgroundTransparency = 0.4
	_2:Create(_71, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.fromOffset(620, 460), BackgroundTransparency = 0,
	}):Play()
	_13f(_d)
end

local function _155()
	if not _10 then return end
	_10 = false
	local _1d = _2:Create(_71, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
		Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 0.5,
	})
	_1d:Play()
	_1d.Completed:Connect(function() if not _10 then _71.Visible = false end end)
end

_72.InputBegan:Connect(function(_5e)
	if _5e.UserInputType == Enum.UserInputType.MouseButton1 or _5e.UserInputType == Enum.UserInputType.Touch then
		_11 = true; dragStart = _5e.Position; startPos = _71.Position
	end
end)
_72.InputEnded:Connect(function() _11 = false end)
_3.InputChanged:Connect(function(_5e)
	if _11 and (_5e.UserInputType == Enum.UserInputType.MouseMovement or _5e.UserInputType == Enum.UserInputType.Touch) then
		local _111 = _5e.Position - dragStart
		_71.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + _111.X, startPos.Y.Scale, startPos.Y.Offset + _111.Y)
	end
end)

task.spawn(function()
	task.wait(0.3)
	local _10f, err = pcall(function()
		_14 = _6.new()
		_14:setName("ErickzzzSpy")
		_14:align("Right")
		_14:setOrder(1)
		_14:setImage(10734949856) 
		_14:setLabel("Spy")
		_14:setCaption("Erickzzz Spy")
		_14:bindEvent("selected", _154)
		_14:bindEvent("deselected", _155)
	end)
	if not _10f then
		warn("[Erickzzz Spy] TopbarPlus error:", err)
	end
end)

_13f("Home")
print("[Erickzzz Spy] Ready")
