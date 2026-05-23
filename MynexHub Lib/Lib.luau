-- Anti-Detection System
local v_u_1, v_u_2, v_u_3, v_u_4, v_u_5, v_u_6, v_u_7, v_u_8, v_u_9, v_u_10
local v_u_11, v_u_12, v_u_13, v_u_14, v_u_15, v_u_16, v_u_17, v_u_18

do
	local v_u_mt = getrawmetatable(game)
	local v_u_nc = v_u_mt.__namecall
	local v_u_ni = v_u_mt.__index

	setreadonly(v_u_mt, false)

	v_u_mt.__namecall = newcclosure(function(...)
		local v_u_args   = {...}
		local v_u_self   = v_u_args[1]
		local v_u_method = getnamecallmethod()

		if v_u_method == "Kick" or v_u_method == "kick" then
			return
		end

		if v_u_method == "FireServer" or v_u_method == "InvokeServer" then
			if tostring(v_u_self):find("AntiCheat") or tostring(v_u_self):find("Security") then
				return
			end
		end

		return v_u_nc(...)
	end)

	v_u_mt.__index = newcclosure(function(v_u_t, v_u_k)
		return v_u_ni(v_u_t, v_u_k)
	end)

	setreadonly(v_u_mt, true)
end

local EcoHub = {}
EcoHub.__index = EcoHub

-- Services
v_u_1  = game:GetService("TweenService")
v_u_2  = game:GetService("UserInputService")
v_u_3  = game:GetService("RunService")
v_u_4  = game:GetService("Players")
v_u_5  = game.CoreGui
v_u_6  = Instance.new
v_u_7  = UDim2.new
v_u_8  = UDim2.fromScale
v_u_9  = UDim.new
v_u_10 = Color3.fromRGB
v_u_11 = Color3.fromHSV
v_u_12 = Color3.toHSV
v_u_13 = TweenInfo.new
v_u_14 = Enum.EasingStyle
v_u_15 = Enum.Font
v_u_16 = math.clamp
v_u_17 = math.round
v_u_18 = string.format

local Icons         = {}
local Notifications = {}

local _ok1, _res1 = pcall(function()
	return loadstring(game:HttpGet("https://raw.githubusercontent.com/EcohubPassouAqui/EcoHub/main/Databases/Icons.lua"))()
end)
if _ok1 and _res1 then Icons = _res1 end

local _ok2, _res2 = pcall(function()
	return loadstring(game:HttpGet("https://raw.githubusercontent.com/EcohubPassouAqui/EcoHub/refs/heads/main/Notifications/EcoHub.lua"))()
end)
if _ok2 and _res2 then Notifications = _res2 end

-- Save System
local SaveData  = {}
local _saveFile = nil
local _dirty    = false

local function _getSavePath()
	if _saveFile then return _saveFile end
	local raw = tostring(game.Name or "unknown")
	raw = raw:gsub("[^%w%s%-_]", ""):gsub("%s+", "_"):sub(1, 40)
	if raw == "" then raw = "unknown" end
	_saveFile = "EcoHub/" .. raw .. "_config.json"
	return _saveFile
end

local function _ensureFolder()
	pcall(function()
		if not isfolder("EcoHub") then makefolder("EcoHub") end
	end)
end

local function _encodeValue(v)
	if type(v) == "boolean" then
		return v and "true" or "false"
	elseif type(v) == "number" then
		return tostring(v)
	elseif type(v) == "string" then
		return '"' .. v:gsub('\\', '\\\\'):gsub('"', '\\"') .. '"'
	elseif typeof(v) == "Color3" then
		return '"__color3__' .. v_u_17(v.R*255) .. ',' .. v_u_17(v.G*255) .. ',' .. v_u_17(v.B*255) .. '"'
	end
	return '"[unsupported]"'
end

local function _buildJson()
	local saves   = {}
	for k, v in pairs(SaveData) do
		table.insert(saves, '"' .. tostring(k) .. '":' .. _encodeValue(v))
	end
	local gameId   = tostring(game.PlaceId or 0)
	local gameName = tostring(game.Name or "unknown"):gsub('"', '\\"')
	return '{"nome":"' .. gameName .. '","id":"' .. gameId .. '","saves":{' .. table.concat(saves, ",") .. '}}'
end

local function _parseJson(str)
	local result = {}
	if not str or str == "" then return result end
	local block = str:match('"saves"%s*:%s*({[^}]*})')
	if not block then return result end
	block = block:match("^%s*{(.+)}%s*$")
	if not block then return result end
	for key, val in block:gmatch('"([^"]+)"%s*:%s*([^,}]+)') do
		val = val:match("^%s*(.-)%s*$")
		if val == "true" then
			result[key] = true
		elseif val == "false" then
			result[key] = false
		elseif val:match('^"__color3__(%d+),(%d+),(%d+)"$') then
			local r, g, b = val:match('^"__color3__(%d+),(%d+),(%d+)"$')
			result[key] = v_u_10(tonumber(r), tonumber(g), tonumber(b))
		elseif val:match('^"(.*)"$') then
			result[key] = val:match('^"(.*)"$')
		else
			local n = tonumber(val)
			if n then result[key] = n end
		end
	end
	return result
end

local function _loadSave()
	_ensureFolder()
	pcall(function()
		local path = _getSavePath()
		if isfile(path) then
			local decoded = _parseJson(readfile(path))
			for k, v in pairs(decoded) do SaveData[k] = v end
		end
	end)
end

local function _flushSave()
	if not _dirty then return end
	_dirty = false
	_ensureFolder()
	pcall(function()
		writefile(_getSavePath(), _buildJson())
	end)
end

local function SaveGet(id)
	if not id or id == "" then return nil end
	return SaveData[id]
end

local function SaveSet(id, val)
	if not id or id == "" then return end
	SaveData[id] = val
	_dirty       = true
	task.defer(_flushSave)
end

_loadSave()

-- Helpers
local function Tw(obj, props, t, style)
	if not obj or not obj.Parent then return end
	v_u_1:Create(obj, v_u_13(t or 0.15, style or v_u_14.Quad), props):Play()
end

local function Corner(obj, r)
	local c = v_u_6("UICorner")
	c.CornerRadius = v_u_9(0, r or 6)
	c.Parent = obj
	return c
end

local function Stroke(obj, color, thickness, transparency)
	local s = v_u_6("UIStroke")
	s.Color        = color
	s.Thickness    = thickness    or 1
	s.Transparency = transparency or 0
	s.Parent       = obj
	return s
end

local function N(class, props)
	local inst = v_u_6(class)
	for k, v in pairs(props or {}) do
		if k ~= "Parent" then inst[k] = v end
	end
	if props and props.Parent then inst.Parent = props.Parent end
	return inst
end

local function GetIcon(name)
	if not name or name == "" then return "" end
	if not Icons or not Icons.assets then return "" end
	local asset = Icons.assets["lucide-" .. name]
	if not asset then asset = Icons.assets[name] or "" end
	return asset
end

local function NotifyError(title, desc)
	pcall(function()
		if Notifications and Notifications.Notify then
			Notifications.Notify({ Title = "[ERRO] " .. tostring(title), Description = tostring(desc), Duration = 5 })
		end
	end)
end

local function ColorToHex(c)
	return v_u_18("%02X%02X%02X", v_u_17(c.R*255), v_u_17(c.G*255), v_u_17(c.B*255))
end

local function HexToColor(hex)
	hex = hex:gsub("[^%x]", ""):upper()
	if #hex == 6 then
		local r = tonumber(hex:sub(1,2), 16)
		local g = tonumber(hex:sub(3,4), 16)
		local b = tonumber(hex:sub(5,6), 16)
		if r and g and b then return v_u_10(r, g, b) end
	end
	return nil
end

-- Theme
local T = {
	bg          = v_u_10(13,  13,  13),
	topbar      = v_u_10(20,  20,  20),
	tabbar      = v_u_10(13,  13,  13),
	card        = v_u_10(22,  22,  22),
	elBg        = v_u_10(24,  24,  24),
	elBgHov     = v_u_10(34,  34,  34),
	elBgPress   = v_u_10(16,  16,  16),
	elemHover   = v_u_10(34,  34,  34),
	border      = v_u_10(45,  45,  45),
	divider     = v_u_10(35,  35,  35),
	textPri     = v_u_10(255, 255, 255),
	textSec     = v_u_10(185, 185, 185),
	textDim     = v_u_10(100, 100, 100),
	muted       = v_u_10(100, 100, 100),
	dim         = v_u_10(50,  50,  50),
	accentDark  = v_u_10(38,  38,  42),
	white       = v_u_10(255, 255, 255),
	secBg       = v_u_10(18,  18,  18),
	secBord     = v_u_10(38,  38,  38),
	secText     = v_u_10(210, 210, 210),
	togOn       = v_u_10(225, 225, 230),
	togOff      = v_u_10(26,  26,  30),
	togKnobOn   = v_u_10(20,  20,  24),
	togKnobOff  = v_u_10(80,  80,  86),
	togBordOn   = v_u_10(210, 210, 215),
	togBordOff  = v_u_10(48,  48,  54),
	chkOn       = v_u_10(225, 225, 230),
	chkOff      = v_u_10(22,  22,  26),
	chkBordOn   = v_u_10(210, 210, 215),
	chkBordOff  = v_u_10(48,  48,  54),
	chkKnobOn   = v_u_10(20,  20,  24),
	chkKnobOff  = v_u_10(255, 255, 255),
	dropBg      = v_u_10(16,  16,  19),
	dropBorder  = v_u_10(42,  42,  50),
	dropSel     = v_u_10(38,  38,  46),
	dropItem    = v_u_10(30,  30,  36),
	elBorder    = v_u_10(38,  38,  44),
	disabled    = v_u_10(28,  28,  30),
	disabledTxt = v_u_10(60,  60,  64),
	labelVal    = v_u_10(180, 180, 188),
}

local EL_H  = 36
local WIN_W = 620
local WIN_H = 370

-- Search
local AllElements = {}

local function RegEl(frame, label)
	table.insert(AllElements, { frame = frame, label = string.lower(label or "") })
end

local function RunSearch(query)
	query = string.lower(query or "")
	for _, el in ipairs(AllElements) do
		if el.frame and el.frame.Parent then
			el.frame.Visible = (query == "") or (string.find(el.label, query, 1, true) ~= nil)
		end
	end
end

-- Window Creation
function EcoHub:CreateWindow(config)
	config = config or {}
	local winTitle    = config.Title    or "EcoHub"
	local winSubTitle = config.SubTitle or "v1"

	if v_u_5:FindFirstChild("EcoHub") then
		v_u_5:FindFirstChild("EcoHub"):Destroy()
	end

	local ScreenGui = N("ScreenGui", {
		Name = "EcoHub", Parent = v_u_5,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling, ResetOnSpawn = false,
	})

	local MainFrame = N("Frame", {
		Name = "MainFrame", Parent = ScreenGui,
		BackgroundColor3 = T.bg,
		Position = v_u_7(0.5, -WIN_W/2, 0.5, -WIN_H/2),
		Size = v_u_7(0, WIN_W, 0, WIN_H),
		Active = true, Draggable = true, ClipsDescendants = false,
	})
	Corner(MainFrame, 10)
	Stroke(MainFrame, v_u_10(52, 52, 58), 1.2)

	local ClipFrame = N("Frame", {
		Name = "ClipFrame", Parent = MainFrame,
		BackgroundTransparency = 1, Size = v_u_8(1, 1),
		ClipsDescendants = true, BorderSizePixel = 0, ZIndex = 1,
	})

	-- TopBar
	local TopBar = N("Frame", {
		Name = "TopBar", Parent = ClipFrame,
		BackgroundColor3 = T.topbar, Size = v_u_7(1, 0, 0, 58),
		BorderSizePixel = 0, ZIndex = 2,
	})
	Corner(TopBar, 10)
	N("Frame", {
		Parent = TopBar, BackgroundColor3 = T.topbar,
		Position = v_u_7(0, 0, 1, -10), Size = v_u_7(1, 0, 0, 10), BorderSizePixel = 0,
	})
	N("Frame", {
		Parent = TopBar, BackgroundColor3 = T.divider,
		Position = v_u_7(0, 0, 1, -1), Size = v_u_7(1, 0, 0, 1), BorderSizePixel = 0, ZIndex = 3,
	})
	N("TextLabel", {
		Parent = TopBar, BackgroundTransparency = 1,
		Position = v_u_7(0, 18, 0, 8), Size = v_u_7(0, 300, 0, 22),
		Font = v_u_15.Code, Text = winTitle,
		TextColor3 = T.textPri, TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 3,
	})
	N("TextLabel", {
		Parent = TopBar, BackgroundTransparency = 1,
		Position = v_u_7(0, 18, 0, 32), Size = v_u_7(0, 300, 0, 16),
		Font = v_u_15.Code, Text = winSubTitle,
		TextColor3 = T.muted, TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 3,
	})

	-- Search Box
	local SearchHolder = N("Frame", {
		Parent = TopBar, BackgroundColor3 = v_u_10(26, 26, 26),
		Position = v_u_7(1, -206, 0.5, -14), Size = v_u_7(0, 155, 0, 28),
		BorderSizePixel = 0, ZIndex = 3,
	})
	Corner(SearchHolder, 6)
	Stroke(SearchHolder, v_u_10(44, 44, 50), 1)
	N("ImageLabel", {
		Parent = SearchHolder, BackgroundTransparency = 1,
		Position = v_u_7(0, 8, 0.5, -6), Size = v_u_7(0, 13, 0, 13),
		Image = GetIcon("search"), ImageColor3 = v_u_10(75, 75, 80), ZIndex = 4,
	})
	local SearchBox = N("TextBox", {
		Parent = SearchHolder, BackgroundTransparency = 1,
		Position = v_u_7(0, 27, 0, 0), Size = v_u_7(1, -31, 1, 0),
		Font = v_u_15.Code, PlaceholderText = "pesquisar...",
		PlaceholderColor3 = v_u_10(60, 60, 65),
		Text = "", TextColor3 = v_u_10(220, 220, 225),
		TextSize = 11, ClearTextOnFocus = false, BorderSizePixel = 0, ZIndex = 4,
	})
	SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
		RunSearch(SearchBox.Text)
	end)

	-- Minimize Button
	local MoveBtn = N("TextButton", {
		Parent = TopBar, BackgroundTransparency = 1,
		Position = v_u_7(1, -40, 0.5, -12), Size = v_u_7(0, 24, 0, 24),
		Text = "", ZIndex = 3,
	})
	N("ImageLabel", {
		Parent = MoveBtn, BackgroundTransparency = 1, Size = v_u_8(1, 1),
		Image = GetIcon("move"), ImageColor3 = v_u_10(95, 95, 100), ZIndex = 4,
	})

	-- Page Area
	local PageArea = N("Frame", {
		Name = "PageArea", Parent = ClipFrame, BackgroundTransparency = 1,
		Position = v_u_7(0, 0, 0, 58), Size = v_u_7(1, 0, 1, -116),
		ClipsDescendants = false,
	})

	-- Tab Bar
	local TabBar = N("Frame", {
		Name = "TabBar", Parent = ClipFrame,
		BackgroundColor3 = T.tabbar,
		Position = v_u_7(0, 0, 1, -58), Size = v_u_7(1, 0, 0, 58),
		BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 5,
	})
	Corner(TabBar, 10)
	N("Frame", {
		Parent = TabBar, BackgroundColor3 = T.tabbar,
		Position = v_u_7(0, 0, 0, 0), Size = v_u_7(1, 0, 0, 10), BorderSizePixel = 0,
	})
	N("Frame", {
		Parent = TabBar, BackgroundColor3 = T.divider,
		Position = v_u_7(0, 0, 0, 0), Size = v_u_7(1, 0, 0, 1), BorderSizePixel = 0, ZIndex = 6,
	})

	local TAB_SML = 48
	local TAB_EXP = 124
	local ISMALL  = 17
	local tabList = {}
	local tabBtns = {}
	local pages   = {}
	local curTab  = nil

	local function calcPos(ai)
		local n    = math.max(1, #tabList)
		local expW = TAB_EXP
		if expW + (n-1)*TAB_SML > WIN_W - 18 then
			expW = math.max(TAB_SML + 14, WIN_W - 18 - (n-1)*TAB_SML)
		end
		local off = math.max(2, math.floor((WIN_W - (expW + (n-1)*TAB_SML)) / 2))
		local pos, x = {}, off
		for i = 1, n do
			local w = (i == ai) and expW or TAB_SML
			pos[i] = { x = x, w = w }
			x = x + w
		end
		return pos
	end

	local function applyPos(ai, animate)
		local pos = calcPos(ai)
		for i, tb in ipairs(tabBtns) do
			local p = pos[i]
			if animate then
				v_u_1:Create(tb.bg, v_u_13(0.26, v_u_14.Quint), {
					Position = v_u_7(0, p.x, 0, 0),
					Size     = v_u_7(0, p.w, 1, 0),
				}):Play()
			else
				tb.bg.Position = v_u_7(0, p.x, 0, 0)
				tb.bg.Size     = v_u_7(0, p.w, 1, 0)
			end
		end
	end

	local function switchTab(name)
		if curTab == name then return end
		if curTab and pages[curTab] then pages[curTab].pg.Visible = false end
		curTab = name
		pages[name].pg.Visible = true
		local ai = 1
		for i, t in ipairs(tabList) do
			if t.name == name then ai = i; break end
		end
		applyPos(ai, true)
		for i, tb in ipairs(tabBtns) do
			local on = tabList[i].name == name
			if on then
				Tw(tb.sq,  { BackgroundColor3 = T.accentDark }, 0.2)
				Tw(tb.str, { Color = T.white, Thickness = 1.5 }, 0.2)
				Tw(tb.img, { ImageColor3 = T.white }, 0.2)
				Tw(tb.lbl, { TextColor3 = T.textPri, TextTransparency = 0 }, 0.2)
				Tw(tb.sub, { TextColor3 = T.muted,   TextTransparency = 0 }, 0.2)
			else
				Tw(tb.sq,  { BackgroundColor3 = T.card }, 0.2)
				Tw(tb.str, { Color = T.border, Thickness = 1 }, 0.2)
				Tw(tb.img, { ImageColor3 = T.dim }, 0.2)
				Tw(tb.lbl, { TextTransparency = 1 }, 0.15)
				Tw(tb.sub, { TextTransparency = 1 }, 0.15)
			end
		end
	end

	local winApi = {}

	function winApi:AddTab(cfg)
		cfg = cfg or {}
		local name    = cfg.Name or ("Tab" .. tostring(#tabList + 1))
		local subText = cfg.Sub  or ""
		local iconKey = cfg.Icon or "home"

		if #tabList >= 10 then
			NotifyError("AddTab", "Limite de 10 tabs atingido.")
			return nil
		end

		local pg = N("Frame", {
			Name = name, Parent = PageArea, BackgroundTransparency = 1,
			Size = v_u_7(1, 0, 1, 0), Visible = false, ClipsDescendants = false,
		})

		local function makeScroll(posX, sizeW)
			local scroll = N("ScrollingFrame", {
				Parent   = pg,
				Position = v_u_7(posX, posX == 0 and 8 or 4, 0, 5),
				Size     = v_u_7(sizeW, -12, 1, -10),
				BackgroundTransparency = 1, BorderSizePixel = 0,
				ScrollBarThickness = 2, ScrollBarImageColor3 = v_u_10(70, 70, 76),
				CanvasSize = v_u_7(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ScrollingDirection = Enum.ScrollingDirection.Y, ScrollingEnabled = true,
			})
			local layout = N("UIListLayout", {
				Parent = scroll, SortOrder = Enum.SortOrder.LayoutOrder, Padding = v_u_9(0, 4),
			})
			N("UIPadding", {
				Parent       = scroll,
				PaddingTop    = v_u_9(0, 3),
				PaddingBottom = v_u_9(0, 8),
				PaddingLeft   = v_u_9(0, 3),
				PaddingRight  = v_u_9(0, 3),
			})
			layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				scroll.CanvasSize = v_u_7(0, 0, 0, layout.AbsoluteContentSize.Y + 16)
			end)
			return scroll
		end

		local leftScroll  = makeScroll(0,   0.5)
		local rightScroll = makeScroll(0.5, 0.5)

		N("Frame", {
			Parent = pg, Position = v_u_7(0.5, -1, 0, 5), Size = v_u_7(0, 1, 1, -10),
			BackgroundColor3 = T.divider, BorderSizePixel = 0,
		})

		pages[name] = { pg = pg, left = leftScroll, right = rightScroll }
		table.insert(tabList, { name = name, sub = subText })
		local idx = #tabList

		local bg = N("Frame", {
			Parent = TabBar, BackgroundTransparency = 1, BorderSizePixel = 0,
			ClipsDescendants = true, ZIndex = 6,
			Size = v_u_7(0, TAB_SML, 1, 0),
		})
		local sq = N("Frame", {
			Parent = bg, Size = v_u_7(0, 35, 0, 35), Position = v_u_7(0, 6, 0.5, -17.5),
			BackgroundColor3 = T.card, BorderSizePixel = 0, ZIndex = 7,
		})
		Corner(sq, 8)
		local sqStr = Stroke(sq, T.border, 1)
		local img = N("ImageLabel", {
			Parent = sq, BackgroundTransparency = 1,
			Size = v_u_7(0, ISMALL, 0, ISMALL),
			Position = v_u_7(0.5, -ISMALL/2, 0.5, -ISMALL/2),
			Image = GetIcon(iconKey), ImageColor3 = T.dim, ZIndex = 9,
		})
		local lbl = N("TextLabel", {
			Parent = bg, BackgroundTransparency = 1,
			Size = v_u_7(1, -48, 0, 14), Position = v_u_7(0, 46, 0.5, -12),
			Font = v_u_15.GothamBold, Text = name,
			TextColor3 = T.textPri, TextSize = 9,
			TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1, ZIndex = 7,
		})
		local sub_lbl = N("TextLabel", {
			Parent = bg, BackgroundTransparency = 1,
			Size = v_u_7(1, -48, 0, 10), Position = v_u_7(0, 46, 0.5, 2),
			Font = v_u_15.Gotham, Text = subText,
			TextColor3 = T.muted, TextSize = 7,
			TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1, ZIndex = 7,
		})
		local btn = N("TextButton", {
			Parent = bg, Size = v_u_8(1, 1),
			BackgroundTransparency = 1, Text = "", ZIndex = 12,
		})

		tabBtns[idx] = { name = name, bg = bg, sq = sq, str = sqStr, img = img, lbl = lbl, sub = sub_lbl }

		local function getActiveIdx()
			for i, t in ipairs(tabList) do
				if t.name == curTab then return i end
			end
			return idx
		end
		applyPos(curTab and getActiveIdx() or idx, false)

		btn.MouseButton1Click:Connect(function() switchTab(name) end)
		btn.MouseEnter:Connect(function()
			if curTab ~= name then
				Tw(sq,  { BackgroundColor3 = T.elemHover }, 0.1)
				Tw(img, { ImageColor3 = T.muted }, 0.1)
			end
		end)
		btn.MouseLeave:Connect(function()
			if curTab ~= name then
				Tw(sq,  { BackgroundColor3 = T.card }, 0.1)
				Tw(img, { ImageColor3 = T.dim }, 0.1)
			end
		end)

		if #tabList == 1 then
			curTab              = name
			pg.Visible          = true
			applyPos(1, false)
			local tb            = tabBtns[1]
			tb.sq.BackgroundColor3  = T.accentDark
			tb.str.Color            = T.white
			tb.str.Thickness        = 1.5
			tb.img.ImageColor3      = T.white
			tb.lbl.TextTransparency = 0
			tb.lbl.TextColor3       = T.textPri
			tb.sub.TextTransparency = 0
			tb.sub.TextColor3       = T.muted
		end

		local tabApi       = {}
		local sectionOrder = { left = 0, right = 0 }

		function tabApi:AddSection(side, text)
			side = (side == "right") and "right" or "left"
			local par = (side == "left") and leftScroll or rightScroll
			sectionOrder[side] = sectionOrder[side] + 1

			local wrap = N("Frame", {
				Size = v_u_7(1, 0, 0, 24), BackgroundColor3 = T.secBg,
				BorderSizePixel = 0, LayoutOrder = sectionOrder[side],
				ZIndex = 2, ClipsDescendants = true, Parent = par,
			})
			Corner(wrap, 6)
			Stroke(wrap, T.secBord, 1, 0.5)

			local shimmer = N("Frame", {
				Size = v_u_7(0, 80, 1, 0), Position = v_u_7(-0.4, 0, 0, 0),
				BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 5, Parent = wrap,
			})
			N("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0,   v_u_10(13,  13,  13)),
					ColorSequenceKeypoint.new(0.5, v_u_10(130, 130, 148)),
					ColorSequenceKeypoint.new(1,   v_u_10(13,  13,  13)),
				}),
				Parent = shimmer,
			})
			local secTitleLbl = N("TextLabel", {
				Size = v_u_7(1, -18, 1, 0), Position = v_u_7(0, 10, 0, 0),
				BackgroundTransparency = 1, Text = string.upper(tostring(text or "")),
				TextColor3 = T.secText, TextSize = 9, Font = v_u_15.GothamBold,
				TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6, Parent = wrap,
			})

			task.spawn(function()
				while wrap and wrap.Parent do
					pcall(function() shimmer.Position = v_u_7(-0.4, 0, 0, 0) end)
					task.wait(0.08)
					Tw(shimmer, { Position = v_u_7(1.4, 0, 0, 0) }, 1.6, v_u_14.Linear)
					task.wait(4.5)
				end
			end)

			local secApi = {}

			local function mkBase(h)
				sectionOrder[side] = sectionOrder[side] + 1
				local f = N("Frame", {
					Size = v_u_7(1, 0, 0, h), BackgroundColor3 = T.elBg,
					BorderSizePixel = 0, LayoutOrder = sectionOrder[side], ZIndex = 3, Parent = par,
				})
				Corner(f, 7)
				Stroke(f, T.elBorder, 1, 0.25)
				return f
			end

			local function applyDisabled(f, isDisabled)
				if not f then return end
				Tw(f, { BackgroundColor3 = isDisabled and T.disabled or T.elBg }, 0.15)
			end

			-- Label
			function secApi:AddLabel(titulo, value, saveId)
				local f = mkBase(EL_H)
				RegEl(f, titulo or "")

				local titleLbl = N("TextLabel", {
					Size     = v_u_7(0.55, -12, 1, 0),
					Position = v_u_7(0, 12, 0, 0),
					BackgroundTransparency = 1,
					Text = titulo or "",
					TextColor3 = T.textPri, TextSize = 11, Font = v_u_15.Gotham,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 4, Parent = f,
				})
				local valueLbl = N("TextLabel", {
					Size     = v_u_7(0.45, -14, 1, 0),
					Position = v_u_7(0.55, 0, 0, 0),
					BackgroundTransparency = 1,
					Text = tostring(value or ""),
					TextColor3 = T.labelVal, TextSize = 10, Font = v_u_15.GothamSemibold,
					TextXAlignment = Enum.TextXAlignment.Right,
					TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 4, Parent = f,
				})

				if saveId and saveId ~= "" then
					local saved = SaveGet(saveId)
					if saved ~= nil then valueLbl.Text = tostring(saved) end
				end

				return {
					Set           = function(_, v)
						if valueLbl then valueLbl.Text = tostring(v) end
						if saveId and saveId ~= "" then SaveSet(saveId, tostring(v)) end
					end,
					Get           = function(_) return valueLbl and valueLbl.Text or "" end,
					SetTitle      = function(_, v) if titleLbl then titleLbl.Text = tostring(v) end end,
					SetValue      = function(_, v)
						if valueLbl then valueLbl.Text = tostring(v) end
						if saveId and saveId ~= "" then SaveSet(saveId, tostring(v)) end
					end,
					SetColor      = function(_, c) if valueLbl then valueLbl.TextColor3 = c end end,
					SetTitleColor = function(_, c) if titleLbl then titleLbl.TextColor3 = c end end,
					SetColorTween = function(_, c, t)
						if valueLbl then Tw(valueLbl, { TextColor3 = c }, t or 0.2) end
					end,
					SetVisible = function(_, v) if f then f.Visible = v ~= false end end,
					Destroy    = function(_) pcall(function() f:Destroy() end) end,
				}
			end

			-- Toggle
			function secApi:AddToggle(titulo, default, saveId, callback)
				local state   = default == true
				local enabled = true

				if saveId and saveId ~= "" then
					local saved = SaveGet(saveId)
					if saved ~= nil then state = (saved == true) end
				end

				local f = mkBase(EL_H)
				RegEl(f, titulo)

				local titleLbl = N("TextLabel", {
					Size = v_u_7(1, -70, 1, 0), Position = v_u_7(0, 12, 0, 0),
					BackgroundTransparency = 1, Text = titulo,
					TextColor3 = T.textPri, TextSize = 11, Font = v_u_15.Gotham,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 4, Parent = f,
				})
				local descLbl = N("TextLabel", {
					Size = v_u_7(1, -70, 0, 11), Position = v_u_7(0, 12, 1, -12),
					BackgroundTransparency = 1, Text = "",
					TextColor3 = T.muted, TextSize = 9, Font = v_u_15.Gotham,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTruncate = Enum.TextTruncate.AtEnd,
					Visible = false, ZIndex = 4, Parent = f,
				})

				local TW, TH = 34, 18
				local track = N("Frame", {
					Size     = v_u_7(0, TW, 0, TH),
					Position = v_u_7(1, -(TW+11), 0.5, -TH/2),
					BackgroundColor3 = state and T.togOn or T.togOff,
					BorderSizePixel = 0, ZIndex = 5, Parent = f,
				})
				Corner(track, TH)
				local tStr = Stroke(track, state and T.togBordOn or T.togBordOff, 1, 0.05)
				local KSZ  = 12
				local knob = N("Frame", {
					Size     = v_u_7(0, KSZ, 0, KSZ),
					Position = state and v_u_7(1, -(KSZ+3), 0.5, -KSZ/2) or v_u_7(0, 3, 0.5, -KSZ/2),
					BackgroundColor3 = state and T.togKnobOn or T.togKnobOff,
					BorderSizePixel = 0, ZIndex = 6, Parent = track,
				})
				Corner(knob, KSZ)

				local function refresh(s)
					Tw(track, { BackgroundColor3 = s and T.togOn or T.togOff }, 0.15)
					Tw(knob, {
						Position         = s and v_u_7(1, -(KSZ+3), 0.5, -KSZ/2) or v_u_7(0, 3, 0.5, -KSZ/2),
						BackgroundColor3 = s and T.togKnobOn or T.togKnobOff,
					}, 0.15, v_u_14.Back)
					Tw(tStr, { Color = s and T.togBordOn or T.togBordOff }, 0.13)
				end

				local btn2 = N("TextButton", {
					Size = v_u_8(1, 1), BackgroundTransparency = 1, Text = "", ZIndex = 7, Parent = f,
				})
				btn2.MouseButton1Click:Connect(function()
					if not enabled then return end
					state = not state
					refresh(state)
					SaveSet(saveId, state)
					local ok, err = pcall(function() if callback then callback(state) end end)
					if not ok then NotifyError("Toggle", err) end
				end)
				btn2.MouseEnter:Connect(function() if enabled then Tw(f, { BackgroundColor3 = T.elBgHov }, 0.1) end end)
				btn2.MouseLeave:Connect(function() if enabled then Tw(f, { BackgroundColor3 = T.elBg },    0.1) end end)

				if saveId and saveId ~= "" and SaveGet(saveId) ~= nil then
					pcall(function() if callback then callback(state) end end)
				end

				return {
					Set = function(_, v)
						state = v == true
						refresh(state)
						SaveSet(saveId, state)
					end,
					Get        = function(_) return state end,
					SetEnabled = function(_, v)
						enabled = v ~= false
						applyDisabled(f, not enabled)
						Tw(titleLbl, { TextColor3 = enabled and T.textPri or T.disabledTxt }, 0.15)
						Tw(track,    { BackgroundTransparency = enabled and 0 or 0.6 }, 0.15)
						Tw(knob,     { BackgroundTransparency = enabled and 0 or 0.6 }, 0.15)
					end,
					SetVisible  = function(_, v) if f then f.Visible = v ~= false end end,
					SetTitle    = function(_, v) if titleLbl then titleLbl.Text = tostring(v) end end,
					SetDescription = function(_, v)
						if descLbl then
							descLbl.Text    = tostring(v or "")
							descLbl.Visible = (v and v ~= "")
							local h = (v and v ~= "") and 48 or EL_H
							Tw(f, { Size = v_u_7(1, 0, 0, h) }, 0.15)
						end
					end,
					SetCallback = function(_, fn) callback = fn end,
					Toggle      = function(_)
						state = not state
						refresh(state)
						SaveSet(saveId, state)
						pcall(function() if callback then callback(state) end end)
					end,
					Destroy = function(_) pcall(function() f:Destroy() end) end,
				}
			end

			-- Checkbox
			function secApi:AddCheckbox(titulo, default, saveId, callback)
				local state   = default == true
				local enabled = true

				if saveId and saveId ~= "" then
					local saved = SaveGet(saveId)
					if saved ~= nil then state = (saved == true) end
				end

				local f = mkBase(EL_H)
				RegEl(f, titulo)

				local BSZ = 16
				local box = N("Frame", {
					Size     = v_u_7(0, BSZ, 0, BSZ),
					Position = v_u_7(0, 12, 0.5, -BSZ/2),
					BackgroundColor3 = state and T.chkOn or T.chkOff,
					BorderSizePixel = 0, ZIndex = 5, Parent = f,
				})
				Corner(box, 4)
				local bStr = Stroke(box, state and T.chkBordOn or T.chkBordOff, 1.5)
				local chk  = N("ImageLabel", {
					Size     = v_u_7(0, BSZ-6, 0, BSZ-6),
					Position = v_u_7(0.5, -(BSZ-6)/2, 0.5, -(BSZ-6)/2),
					BackgroundTransparency = 1, Image = GetIcon("check"),
					ImageColor3 = state and T.chkKnobOn or T.chkKnobOff,
					ImageTransparency = state and 0 or 1, ZIndex = 6, Parent = box,
				})
				local titleLbl = N("TextLabel", {
					Size     = v_u_7(1, -(BSZ+26), 1, 0),
					Position = v_u_7(0, BSZ+20, 0, 0),
					BackgroundTransparency = 1, Text = titulo,
					TextColor3 = T.textPri, TextSize = 11, Font = v_u_15.Gotham,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 4, Parent = f,
				})
				local descLbl = N("TextLabel", {
					Size     = v_u_7(1, -(BSZ+26), 0, 11),
					Position = v_u_7(0, BSZ+20, 1, -12),
					BackgroundTransparency = 1, Text = "",
					TextColor3 = T.muted, TextSize = 9, Font = v_u_15.Gotham,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTruncate = Enum.TextTruncate.AtEnd,
					Visible = false, ZIndex = 4, Parent = f,
				})

				local function refresh(s)
					Tw(box,  { BackgroundColor3 = s and T.chkOn or T.chkOff }, 0.14)
					Tw(bStr, { Color = s and T.chkBordOn or T.chkBordOff }, 0.13)
					Tw(chk,  { ImageTransparency = s and 0 or 1, ImageColor3 = s and T.chkKnobOn or T.chkKnobOff }, 0.11)
				end

				local btn2 = N("TextButton", {
					Size = v_u_8(1, 1), BackgroundTransparency = 1, Text = "", ZIndex = 7, Parent = f,
				})
				btn2.MouseButton1Click:Connect(function()
					if not enabled then return end
					state = not state
					refresh(state)
					SaveSet(saveId, state)
					local ok, err = pcall(function() if callback then callback(state) end end)
					if not ok then NotifyError("Checkbox", err) end
				end)
				btn2.MouseEnter:Connect(function() if enabled then Tw(f, { BackgroundColor3 = T.elBgHov }, 0.1) end end)
				btn2.MouseLeave:Connect(function() if enabled then Tw(f, { BackgroundColor3 = T.elBg },    0.1) end end)

				if saveId and saveId ~= "" and SaveGet(saveId) ~= nil then
					pcall(function() if callback then callback(state) end end)
				end

				return {
					Set        = function(_, v)
						state = v == true
						refresh(state)
						SaveSet(saveId, state)
					end,
					Get        = function(_) return state end,
					SetEnabled = function(_, v)
						enabled = v ~= false
						applyDisabled(f, not enabled)
						Tw(titleLbl, { TextColor3 = enabled and T.textPri or T.disabledTxt }, 0.15)
						Tw(bStr,     { Color = enabled and (state and T.chkBordOn or T.chkBordOff) or T.disabled }, 0.15)
						Tw(box,      { BackgroundTransparency = enabled and 0 or 0.5 }, 0.15)
					end,
					SetVisible     = function(_, v) if f then f.Visible = v ~= false end end,
					SetTitle       = function(_, v) if titleLbl then titleLbl.Text = tostring(v) end end,
					SetDescription = function(_, v)
						if descLbl then
							descLbl.Text    = tostring(v or "")
							descLbl.Visible = (v and v ~= "")
							local h = (v and v ~= "") and 48 or EL_H
							Tw(f, { Size = v_u_7(1, 0, 0, h) }, 0.15)
						end
					end,
					SetCallback = function(_, fn) callback = fn end,
					Toggle      = function(_)
						state = not state
						refresh(state)
						SaveSet(saveId, state)
						pcall(function() if callback then callback(state) end end)
					end,
					Destroy = function(_) pcall(function() f:Destroy() end) end,
				}
			end

			-- Button
			function secApi:AddButton(titulo, saveId, callback)
				local enabled = true
				local loading = false
				local f = mkBase(EL_H)
				RegEl(f, titulo)

				local titleLbl = N("TextLabel", {
					Size     = v_u_7(1, -40, 1, 0), Position = v_u_7(0, 12, 0, 0),
					BackgroundTransparency = 1, Text = titulo,
					TextColor3 = T.textPri, TextSize = 11, Font = v_u_15.GothamSemibold,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 5, Parent = f,
				})
				local arrow = N("ImageLabel", {
					Size     = v_u_7(0, 10, 0, 10), Position = v_u_7(1, -20, 0.5, -5),
					BackgroundTransparency = 1, Image = GetIcon("chevron-right"),
					ImageColor3 = T.textDim, ZIndex = 5, Parent = f,
				})

				local spinnerLbl = N("TextLabel", {
					Size     = v_u_7(0, 13, 0, 13), Position = v_u_7(1, -20, 0.5, -6.5),
					BackgroundTransparency = 1, Text = "○",
					TextColor3 = T.muted, TextSize = 12, Font = v_u_15.GothamBold,
					TextXAlignment = Enum.TextXAlignment.Center,
					Visible = false, ZIndex = 5, Parent = f,
				})

				local spinConn  = nil
				local spinChars = {"◜","◝","◞","◟"}
				local spinIdx   = 1

				local function startSpin()
					spinnerLbl.Visible = true
					arrow.Visible      = false
					spinConn = v_u_3.Heartbeat:Connect(function()
						spinIdx             = (spinIdx % #spinChars) + 1
						spinnerLbl.Text     = spinChars[spinIdx]
					end)
				end

				local function stopSpin()
					if spinConn then spinConn:Disconnect(); spinConn = nil end
					spinnerLbl.Visible = false
					arrow.Visible      = enabled
				end

				local btn2 = N("TextButton", {
					Size = v_u_8(1, 1), BackgroundTransparency = 1, Text = "", ZIndex = 7, Parent = f,
				})
				btn2.MouseEnter:Connect(function()
					if not enabled or loading then return end
					Tw(f,     { BackgroundColor3 = T.elBgHov }, 0.1)
					Tw(arrow, { ImageColor3 = T.white }, 0.1)
				end)
				btn2.MouseLeave:Connect(function()
					if not enabled or loading then return end
					Tw(f,     { BackgroundColor3 = T.elBg }, 0.1)
					Tw(arrow, { ImageColor3 = T.textDim }, 0.1)
				end)
				btn2.MouseButton1Down:Connect(function()
					if enabled and not loading then Tw(f, { BackgroundColor3 = T.elBgPress }, 0.06) end
				end)
				btn2.MouseButton1Up:Connect(function()
					if enabled and not loading then Tw(f, { BackgroundColor3 = T.elBgHov }, 0.06) end
				end)
				btn2.MouseButton1Click:Connect(function()
					if not enabled or loading then return end
					local ok, err = pcall(function() if callback then callback() end end)
					if not ok then NotifyError("Button", err) end
				end)

				return {
					SetTitle    = function(_, v) if titleLbl then titleLbl.Text = tostring(v) end end,
					SetCallback = function(_, fn) callback = fn end,
					SetEnabled  = function(_, v)
						enabled = v ~= false
						applyDisabled(f, not enabled)
						Tw(titleLbl, { TextColor3 = enabled and T.textPri or T.disabledTxt }, 0.15)
						Tw(arrow,    { ImageColor3 = enabled and T.textDim or T.dim }, 0.15)
					end,
					SetVisible = function(_, v) if f then f.Visible = v ~= false end end,
					SetLoading = function(_, v)
						loading = v == true
						if loading then
							startSpin()
							Tw(titleLbl, { TextColor3 = T.muted }, 0.15)
						else
							stopSpin()
							Tw(titleLbl, { TextColor3 = enabled and T.textPri or T.disabledTxt }, 0.15)
						end
					end,
					SetIcon = function(_, iconName)
						if arrow then arrow.Image = GetIcon(iconName) end
					end,
					Fire    = function(_)
						if enabled and not loading then
							pcall(function() if callback then callback() end end)
						end
					end,
					Destroy = function(_)
						if spinConn then spinConn:Disconnect() end
						pcall(function() f:Destroy() end)
					end,
				}
			end

			-- Slider
			function secApi:AddSlider(titulo, minV, maxV, defV, saveId, callback, step)
				minV = minV or 0
				maxV = maxV or 100
				step = step or 1

				local val     = v_u_16(defV or minV, minV, maxV)
				local enabled = true
				local drag    = false
				local suffix  = ""

				if saveId and saveId ~= "" then
					local saved = SaveGet(saveId)
					if saved ~= nil then
						val = v_u_16(tonumber(saved) or val, minV, maxV)
					end
				end

				local PAD    = 12
				local RAIL_H = 18
				local pct    = (val - minV) / math.max(maxV - minV, 0.001)

				local f = mkBase(44)
				RegEl(f, titulo)

				local function fmtVal(vv)
					local base = (step < 1) and v_u_18("%.2f", vv) or tostring(v_u_17(vv))
					return base .. suffix
				end

				local titleLbl = N("TextLabel", {
					Size     = v_u_7(1, -(PAD * 2), 0, 12),
					Position = v_u_7(0, PAD, 0, 6),
					BackgroundTransparency = 1, Text = titulo,
					TextColor3 = T.textPri, TextSize = 10, Font = v_u_15.Gotham,
					TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4, Parent = f,
				})

				local rail = N("Frame", {
					Size     = v_u_7(1, -(PAD * 2), 0, RAIL_H),
					Position = v_u_7(0, PAD, 0, 21),
					BackgroundColor3 = v_u_10(38, 38, 42),
					BorderSizePixel = 0, ZIndex = 4, Parent = f,
				})
				Corner(rail, 5)
				Stroke(rail, v_u_10(50, 50, 56), 1, 0.5)

				local fill = N("Frame", {
					Size = v_u_7(pct, 0, 1, 0),
					BackgroundColor3 = v_u_10(255, 255, 255),
					BorderSizePixel = 0, ZIndex = 5, Parent = rail,
				})
				Corner(fill, 5)

				local valLbl = N("TextLabel", {
					Size = v_u_8(1, 1),
					BackgroundTransparency = 1,
					Text = fmtVal(val) .. " / " .. fmtVal(maxV),
					TextColor3 = v_u_10(110, 110, 116),
					TextSize = 9, Font = v_u_15.GothamBold,
					TextXAlignment = Enum.TextXAlignment.Center,
					TextYAlignment = Enum.TextYAlignment.Center,
					ZIndex = 7, Parent = rail,
				})

				local function updateLabel()
					if valLbl then
						valLbl.Text = fmtVal(val) .. " / " .. fmtVal(maxV)
					end
				end

				local function setVal(vv, silent)
					if not enabled then return end
					if step > 0 then vv = v_u_17(vv / step) * step end
					val         = v_u_16(v_u_17(vv * 1000) / 1000, minV, maxV)
					local p     = (val - minV) / math.max(maxV - minV, 0.001)
					fill.Size   = v_u_7(p, 0, 1, 0)
					updateLabel()
					if not silent then SaveSet(saveId, val) end
					if not silent then
						local ok, err = pcall(function() if callback then callback(val) end end)
						if not ok then NotifyError("Slider", err) end
					end
				end

				local hit = N("TextButton", {
					Size     = v_u_7(1, 0, 0, RAIL_H + 14),
					Position = v_u_7(0, 0, 0.5, -(RAIL_H + 14) / 2),
					BackgroundTransparency = 1, Text = "", ZIndex = 8, Parent = rail,
				})

				hit.InputBegan:Connect(function(inp)
					if not enabled then return end
					if inp.UserInputType ~= Enum.UserInputType.MouseButton1
						and inp.UserInputType ~= Enum.UserInputType.Touch then return end
					drag = true
					if not rail or not rail.Parent then return end
					local ab, sz = rail.AbsolutePosition, rail.AbsoluteSize
					setVal(minV + (maxV - minV) * v_u_16((inp.Position.X - ab.X) / sz.X, 0, 1))
				end)
				hit.MouseEnter:Connect(function()
					if enabled then Tw(f, { BackgroundColor3 = T.elBgHov }, 0.1) end
				end)
				hit.MouseLeave:Connect(function()
					if enabled then Tw(f, { BackgroundColor3 = T.elBg }, 0.1) end
				end)

				local slMoveConn = v_u_2.InputChanged:Connect(function(inp)
					if not drag or not enabled then return end
					if inp.UserInputType ~= Enum.UserInputType.MouseMovement
						and inp.UserInputType ~= Enum.UserInputType.Touch then return end
					if not rail or not rail.Parent then return end
					local ab, sz = rail.AbsolutePosition, rail.AbsoluteSize
					setVal(minV + (maxV - minV) * v_u_16((inp.Position.X - ab.X) / sz.X, 0, 1))
				end)

				local slEndConn = v_u_2.InputEnded:Connect(function(inp)
					if inp.UserInputType == Enum.UserInputType.MouseButton1
						or inp.UserInputType == Enum.UserInputType.Touch then
						drag = false
					end
				end)

				if saveId and saveId ~= "" and SaveGet(saveId) ~= nil then
					pcall(function() if callback then callback(val) end end)
				end

				return {
					Set     = function(_, vv) setVal(vv) end,
					Get     = function(_) return val end,
					SetMin  = function(_, vv)
						minV = vv
						setVal(math.max(val, minV), true)
						updateLabel()
					end,
					SetMax  = function(_, vv)
						maxV = vv
						setVal(math.min(val, maxV), true)
						updateLabel()
					end,
					SetStep = function(_, vv)
						step = vv or 1
						setVal(val, true)
					end,
					SetSuffix = function(_, s)
						suffix = tostring(s or "")
						updateLabel()
					end,
					SetEnabled  = function(_, vv)
						enabled = vv ~= false
						drag    = false
						applyDisabled(f, not enabled)
						Tw(titleLbl, { TextColor3 = enabled and T.textPri or T.disabledTxt }, 0.15)
						Tw(fill,     { BackgroundColor3 = enabled and v_u_10(255, 255, 255) or T.dim }, 0.15)
						Tw(valLbl,   { TextColor3 = enabled and v_u_10(110, 110, 116) or T.disabledTxt }, 0.15)
					end,
					SetVisible  = function(_, vv) if f then f.Visible = vv ~= false end end,
					SetTitle    = function(_, vv) if titleLbl then titleLbl.Text = tostring(vv) end end,
					SetCallback = function(_, fn) callback = fn end,
					Destroy     = function(_)
						pcall(function() slMoveConn:Disconnect() end)
						pcall(function() slEndConn:Disconnect() end)
						drag = false
						pcall(function() f:Destroy() end)
					end,
				}
			end

			-- Dropdown
			function secApi:AddDropdown(titulo, options, defV, saveId, callback)
				options = options or {}
				local selected    = defV or options[1] or ""
				local enabled     = true
				local open        = false
				local placeholder = ""
				local ITEM_H      = 30
				local MAX_VISIBLE = 5
				local GAP         = 4

				if saveId and saveId ~= "" then
					local saved = SaveGet(saveId)
					if saved ~= nil then selected = tostring(saved) end
				end

				sectionOrder[side] = sectionOrder[side] + 1
				local wrap = N("Frame", {
					Size = v_u_7(1, 0, 0, EL_H),
					BackgroundTransparency = 1, ClipsDescendants = false,
					LayoutOrder = sectionOrder[side], ZIndex = 10, Parent = par,
				})
				RegEl(wrap, titulo)

				local header = N("Frame", {
					Size = v_u_7(1, 0, 0, EL_H),
					BackgroundColor3 = T.elBg,
					BorderSizePixel = 0, ZIndex = 11, Parent = wrap,
				})
				Corner(header, 7)

				local titleLbl = N("TextLabel", {
					Size     = v_u_7(0.55, -16, 1, 0), Position = v_u_7(0, 12, 0, 0),
					BackgroundTransparency = 1, Text = titulo,
					TextColor3 = T.textPri, TextSize = 11, Font = v_u_15.Gotham,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 12, Parent = header,
				})
				local selLbl = N("TextLabel", {
					Size     = v_u_7(0.45, -28, 1, 0), Position = v_u_7(0.55, 0, 0, 0),
					BackgroundTransparency = 1, Text = selected,
					TextColor3 = T.textSec, TextSize = 10, Font = v_u_15.Gotham,
					TextXAlignment = Enum.TextXAlignment.Right,
					TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 12, Parent = header,
				})
				local arrowIcon = N("ImageLabel", {
					Size     = v_u_7(0, 10, 0, 10),
					Position = v_u_7(1, -19, 0.5, -5),
					BackgroundTransparency = 1, Image = GetIcon("chevron-down"),
					ImageColor3 = v_u_10(80, 80, 88), ZIndex = 13, Parent = header,
				})

				local panel = N("Frame", {
					Size     = v_u_7(1, 0, 0, 0),
					Position = v_u_7(0, 0, 0, EL_H + GAP),
					BackgroundColor3 = v_u_10(19, 19, 22),
					BorderSizePixel = 0, ClipsDescendants = true,
					ZIndex = 20, Parent = wrap,
				})
				Corner(panel, 8)

				local listScroll = N("ScrollingFrame", {
					Size = v_u_8(1, 1),
					BackgroundTransparency = 1,
					ScrollBarThickness = 2,
					ScrollBarImageColor3 = v_u_10(50, 50, 58),
					ScrollingDirection = Enum.ScrollingDirection.Y,
					CanvasSize = v_u_7(0, 0, 0, 0),
					AutomaticCanvasSize = Enum.AutomaticSize.Y,
					ElasticBehavior = Enum.ElasticBehavior.Never,
					ZIndex = 21, Parent = panel,
				})
				N("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = v_u_9(0, 0),
					Parent = listScroll,
				})
				N("UIPadding", {
					PaddingTop    = v_u_9(0, 4),
					PaddingBottom = v_u_9(0, 4),
					PaddingLeft   = v_u_9(0, 4),
					PaddingRight  = v_u_9(0, 4),
					Parent = listScroll,
				})

				local function getExpandedH()
					return math.min(#options, MAX_VISIBLE) * ITEM_H + 8
				end

				local function closeDropdown()
					open = false
					Tw(panel,     { Size = v_u_7(1, 0, 0, 0) },    0.2, v_u_14.Quint)
					Tw(wrap,      { Size = v_u_7(1, 0, 0, EL_H) }, 0.2, v_u_14.Quint)
					Tw(arrowIcon, { Rotation = 0,   ImageColor3 = v_u_10(80, 80, 88) }, 0.16)
					Tw(header,    { BackgroundColor3 = T.elBg }, 0.14)
				end

				local function buildItems()
					for _, c in ipairs(listScroll:GetChildren()) do
						if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then
							pcall(function() c:Destroy() end)
						end
					end
					for i, opt in ipairs(options) do
						local isSel   = opt == selected
						local BG_SEL  = v_u_10(32, 32, 38)
						local BG_IDLE = v_u_10(19, 19, 22)
						local BG_HOV  = v_u_10(27, 27, 33)

						local row = N("Frame", {
							Size = v_u_7(1, 0, 0, ITEM_H),
							BackgroundColor3 = isSel and BG_SEL or BG_IDLE,
							BackgroundTransparency = 0,
							BorderSizePixel = 0, LayoutOrder = i, ZIndex = 22, Parent = listScroll,
						})
						Corner(row, 5)

						N("TextLabel", {
							Size     = v_u_7(1, -24, 1, 0),
							Position = UDim2.fromOffset(12, 0),
							BackgroundTransparency = 1, Text = opt,
							TextColor3 = isSel and v_u_10(242, 242, 248) or v_u_10(148, 148, 158),
							TextSize = 10,
							Font = isSel and v_u_15.GothamSemibold or v_u_15.Gotham,
							TextXAlignment = Enum.TextXAlignment.Left,
							TextTruncate = Enum.TextTruncate.AtEnd,
							ZIndex = 23, Parent = row,
						})

						local ob = N("TextButton", {
							Size = v_u_8(1, 1), BackgroundTransparency = 1,
							Text = "", ZIndex = 24, Parent = row,
						})
						ob.MouseEnter:Connect(function()
							Tw(row, { BackgroundColor3 = isSel and BG_SEL or BG_HOV }, 0.08)
						end)
						ob.MouseLeave:Connect(function()
							Tw(row, { BackgroundColor3 = isSel and BG_SEL or BG_IDLE }, 0.1)
						end)
						ob.MouseButton1Down:Connect(function()
							Tw(row, { BackgroundColor3 = v_u_10(20, 20, 24) }, 0.05)
						end)
						ob.MouseButton1Click:Connect(function()
							if not enabled then return end
							selected = opt
							if selLbl then
								selLbl.Text       = selected
								selLbl.TextColor3 = T.textSec
							end
							SaveSet(saveId, selected)
							buildItems()
							local ok, err = pcall(function() if callback then callback(selected) end end)
							if not ok then NotifyError("Dropdown", err) end
							closeDropdown()
						end)
					end
				end
				buildItems()

				local togBtn = N("TextButton", {
					Size = v_u_8(1, 1), BackgroundTransparency = 1,
					Text = "", ZIndex = 15, Parent = header,
				})
				togBtn.MouseButton1Click:Connect(function()
					if not enabled then return end
					open = not open
					if open then
						buildItems()
						local fH = getExpandedH()
						Tw(panel,     { Size = v_u_7(1, 0, 0, fH) },               0.22, v_u_14.Quint)
						Tw(wrap,      { Size = v_u_7(1, 0, 0, EL_H + GAP + fH) },  0.22, v_u_14.Quint)
						Tw(arrowIcon, { Rotation = 180, ImageColor3 = T.white },    0.18)
						Tw(header,    { BackgroundColor3 = T.elBgHov },             0.12)
					else
						closeDropdown()
					end
				end)
				togBtn.MouseEnter:Connect(function()
					if not open and enabled then Tw(header, { BackgroundColor3 = T.elBgHov }, 0.1) end
				end)
				togBtn.MouseLeave:Connect(function()
					if not open and enabled then Tw(header, { BackgroundColor3 = T.elBg },    0.1) end
				end)

				if saveId and saveId ~= "" and SaveGet(saveId) ~= nil then
					pcall(function() if callback then callback(selected) end end)
				end

				return {
					Set = function(_, v)
						selected = v
						if selLbl then
							selLbl.Text       = (v and v ~= "") and v or placeholder
							selLbl.TextColor3 = (v and v ~= "") and T.textSec or T.muted
						end
						SaveSet(saveId, v)
						buildItems()
					end,
					Get        = function(_) return selected end,
					SetOptions = function(_, o)
						options = o or {}
						if not table.find(options, selected) then
							selected = options[1] or ""
							if selLbl then
								selLbl.Text       = (selected ~= "") and selected or placeholder
								selLbl.TextColor3 = (selected ~= "") and T.textSec or T.muted
							end
						end
						if open then buildItems() end
					end,
					AddOption = function(_, opt)
						if not table.find(options, opt) then
							table.insert(options, opt)
							if open then buildItems() end
						end
					end,
					RemoveOption = function(_, opt)
						for i, v in ipairs(options) do
							if v == opt then
								table.remove(options, i)
								if selected == opt then
									selected = options[1] or ""
									if selLbl then
										selLbl.Text       = (selected ~= "") and selected or placeholder
										selLbl.TextColor3 = (selected ~= "") and T.textSec or T.muted
									end
									SaveSet(saveId, selected)
									pcall(function() if callback then callback(selected) end end)
								end
								if open then buildItems() end
								break
							end
						end
					end,
					SetPlaceholder = function(_, txt)
						placeholder = tostring(txt or "")
						if (not selected or selected == "") and selLbl then
							selLbl.Text       = placeholder
							selLbl.TextColor3 = T.muted
						end
					end,
					SetEnabled = function(_, v)
						enabled = v ~= false
						if not enabled and open then closeDropdown() end
						applyDisabled(header, not enabled)
						Tw(titleLbl,  { TextColor3 = enabled and T.textPri or T.disabledTxt }, 0.15)
						Tw(arrowIcon, { ImageColor3 = enabled and v_u_10(80,80,88) or T.dim }, 0.15)
					end,
					SetVisible  = function(_, v) if wrap then wrap.Visible = v ~= false end end,
					SetTitle    = function(_, v) if titleLbl then titleLbl.Text = tostring(v) end end,
					SetCallback = function(_, fn) callback = fn end,
					Destroy     = function(_) pcall(function() wrap:Destroy() end) end,
				}
			end

			-- ============================================================
			-- COLOR PICKER — v3 limpo, cursores sem bug de clip
			-- ============================================================
			function secApi:AddColorPicker(titulo, defaultColor, saveId, callback)
				local currentColor = defaultColor or v_u_10(255, 100, 50)
				local enabled      = true
				local open         = false

				if saveId and saveId ~= "" then
					local saved = SaveGet(saveId)
					if saved ~= nil and typeof(saved) == "Color3" then
						currentColor = saved
					end
				end

				local hh, ss, vv = v_u_12(currentColor)

				-- Dimensões
				local GAP      = 6
				local PAD_H    = 10   -- padding horizontal
				local SV_H     = 116
				local HUE_H    = 12
				local ROW_H    = 26
				local GAP_SV   = 8
				local GAP_HUE  = 8
				local PAD_BOT  = 10
				local PANEL_H  = PAD_H + SV_H + GAP_SV + HUE_H + GAP_HUE + ROW_H + PAD_BOT

				-- Wrapper
				sectionOrder[side] = sectionOrder[side] + 1
				local wrap = N("Frame", {
					Size = v_u_7(1, 0, 0, EL_H),
					BackgroundTransparency = 1,
					ClipsDescendants = false,
					LayoutOrder = sectionOrder[side],
					ZIndex = 10, Parent = par,
				})
				RegEl(wrap, titulo)

				-- Header
				local header = N("Frame", {
					Size = v_u_7(1, 0, 0, EL_H),
					BackgroundColor3 = T.elBg,
					BorderSizePixel = 0, ZIndex = 11, Parent = wrap,
				})
				Corner(header, 7)
				Stroke(header, T.elBorder, 1, 0.25)

				local titleLbl = N("TextLabel", {
					Size = v_u_7(0.5, -16, 1, 0), Position = v_u_7(0, 12, 0, 0),
					BackgroundTransparency = 1, Text = titulo,
					TextColor3 = T.textPri, TextSize = 11, Font = v_u_15.Gotham,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 12, Parent = header,
				})

				-- swatch (barra de cor) no header
				local swatchOuter = N("Frame", {
					Size     = v_u_7(0, 52, 0, 20),
					Position = v_u_7(1, -76, 0.5, -10),
					BackgroundColor3 = v_u_10(35, 35, 40),
					BorderSizePixel = 0, ZIndex = 12, Parent = header,
				})
				Corner(swatchOuter, 5)
				Stroke(swatchOuter, v_u_10(55, 55, 62), 1, 0)
				local swatch = N("Frame", {
					Size = v_u_7(1, -4, 1, -4), Position = v_u_7(0, 2, 0, 2),
					BackgroundColor3 = currentColor,
					BorderSizePixel = 0, ZIndex = 13, Parent = swatchOuter,
				})
				Corner(swatch, 4)

				local chevron = N("ImageLabel", {
					Size     = v_u_7(0, 9, 0, 9),
					Position = v_u_7(1, -17, 0.5, -4.5),
					BackgroundTransparency = 1,
					Image = GetIcon("chevron-down"),
					ImageColor3 = v_u_10(70, 70, 78), ZIndex = 13, Parent = header,
				})

				-- Panel background (apenas visual, sem clip)
				local panel = N("Frame", {
					Size     = v_u_7(1, 0, 0, 0),
					Position = v_u_7(0, 0, 0, EL_H + GAP),
					BackgroundColor3 = v_u_10(18, 18, 21),
					BorderSizePixel = 0,
					ClipsDescendants = false,
					ZIndex = 20, Parent = wrap,
				})
				Corner(panel, 8)
				Stroke(panel, v_u_10(38, 38, 44), 1, 0.4)

				-- Container interno (para clipar conteúdo, mas NÃO os cursores)
				local content = N("Frame", {
					Size = v_u_8(1, 1),
					BackgroundTransparency = 1,
					ClipsDescendants = true,
					ZIndex = 20, Parent = panel,
				})
				Corner(content, 8)

				-- SV Frame (sem ClipsDescendants — cursores ficam visíveis)
				local svY = PAD_H
				local svFrame = N("Frame", {
					Size     = v_u_7(1, -(PAD_H * 2), 0, SV_H),
					Position = v_u_7(0, PAD_H, 0, svY),
					BackgroundColor3 = v_u_11(hh, 1, 1),
					BorderSizePixel = 0,
					ClipsDescendants = false,
					ZIndex = 22, Parent = content,
				})
				Corner(svFrame, 6)

				-- Fundo branco -> transparente (saturação)
				local svW = N("Frame", {
					Size = v_u_8(1, 1), BackgroundColor3 = v_u_10(255,255,255),
					BorderSizePixel = 0, ZIndex = 23, Parent = svFrame,
				})
				Corner(svW, 6)
				N("UIGradient", {
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0),
						NumberSequenceKeypoint.new(1, 1),
					}), Parent = svW,
				})

				-- Fundo preto -> transparente (valor)
				local svB = N("Frame", {
					Size = v_u_8(1, 1), BackgroundColor3 = v_u_10(0,0,0),
					BorderSizePixel = 0, ZIndex = 24, Parent = svFrame,
				})
				Corner(svB, 6)
				N("UIGradient", {
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 1),
						NumberSequenceKeypoint.new(1, 0),
					}), Rotation = 90, Parent = svB,
				})

				-- Cursor SV — filho de svFrame (ClipsDescendants=false, logo não é cortado)
				local SV_R = 8
				local svCur = N("Frame", {
					Size        = v_u_7(0, SV_R*2, 0, SV_R*2),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position    = v_u_7(ss, 0, 1-vv, 0),
					BackgroundColor3 = currentColor,
					BorderSizePixel = 0, ZIndex = 28, Parent = svFrame,
				})
				Corner(svCur, SV_R)
				Stroke(svCur, v_u_10(255,255,255), 2, 0)

				-- Hitbox SV
				local svHit = N("TextButton", {
					Size = v_u_8(1, 1),
					BackgroundTransparency = 1, Text = "", ZIndex = 27, Parent = svFrame,
				})

				-- Hue Rail (sem ClipsDescendants)
				local hueY2 = svY + SV_H + GAP_SV
				local hueFrame = N("Frame", {
					Size     = v_u_7(1, -(PAD_H*2), 0, HUE_H),
					Position = v_u_7(0, PAD_H, 0, hueY2),
					BorderSizePixel = 0,
					ClipsDescendants = false,
					ZIndex = 22, Parent = content,
				})
				Corner(hueFrame, HUE_H/2)
				N("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0,     v_u_10(255,0,0)),
						ColorSequenceKeypoint.new(0.166, v_u_10(255,255,0)),
						ColorSequenceKeypoint.new(0.333, v_u_10(0,255,0)),
						ColorSequenceKeypoint.new(0.5,   v_u_10(0,255,255)),
						ColorSequenceKeypoint.new(0.666, v_u_10(0,0,255)),
						ColorSequenceKeypoint.new(0.833, v_u_10(255,0,255)),
						ColorSequenceKeypoint.new(1,     v_u_10(255,0,0)),
					}), Parent = hueFrame,
				})

				-- Cursor Hue — filho de hueFrame (ClipsDescendants=false)
				local HC_W  = 5
				local HC_H  = HUE_H + 6
				local hueCur = N("Frame", {
					Size        = v_u_7(0, HC_W, 0, HC_H),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position    = v_u_7(hh, 0, 0.5, 0),
					BackgroundColor3 = v_u_10(255,255,255),
					BorderSizePixel = 0, ZIndex = 26, Parent = hueFrame,
				})
				Corner(hueCur, 3)
				Stroke(hueCur, v_u_10(15,15,18), 1.5, 0)

				-- Hitbox Hue
				local hueHit = N("TextButton", {
					Size     = v_u_7(1, 0, 1, 10),
					Position = v_u_7(0, 0, 0, -5),
					BackgroundTransparency = 1, Text = "", ZIndex = 27, Parent = hueFrame,
				})

				-- Info Row
				local infoY2  = hueY2 + HUE_H + GAP_HUE
				local infoRow = N("Frame", {
					Size     = v_u_7(1, -(PAD_H*2), 0, ROW_H),
					Position = v_u_7(0, PAD_H, 0, infoY2),
					BackgroundTransparency = 1, ZIndex = 22, Parent = content,
				})

				-- Preview box
				local prevBox = N("Frame", {
					Size     = v_u_7(0, ROW_H, 0, ROW_H),
					BackgroundColor3 = currentColor,
					BorderSizePixel = 0, ZIndex = 23, Parent = infoRow,
				})
				Corner(prevBox, 5)
				Stroke(prevBox, v_u_10(50,50,58), 1, 0)

				-- Hex input
				local hexHolder = N("Frame", {
					Size     = v_u_7(0, 82, 1, 0),
					Position = v_u_7(0, ROW_H+6, 0, 0),
					BackgroundColor3 = v_u_10(13,13,16),
					BorderSizePixel = 0, ZIndex = 23, Parent = infoRow,
				})
				Corner(hexHolder, 5)
				Stroke(hexHolder, T.elBorder, 1, 0.35)
				N("TextLabel", {
					Size = v_u_7(0, 16, 1, 0), Position = v_u_7(0, 5, 0, 0),
					BackgroundTransparency = 1, Text = "#",
					TextColor3 = T.muted, TextSize = 9, Font = v_u_15.GothamBold,
					TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 24, Parent = hexHolder,
				})
				local hexBox = N("TextBox", {
					Size     = v_u_7(1, -20, 1, 0),
					Position = v_u_7(0, 20, 0, 0),
					BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 24,
					Text = ColorToHex(currentColor),
					TextColor3 = T.textPri,
					PlaceholderText = "FFFFFF", PlaceholderColor3 = T.muted,
					TextSize = 9, Font = v_u_15.Code,
					TextXAlignment = Enum.TextXAlignment.Left,
					ClearTextOnFocus = false, Parent = hexHolder,
				})

				-- RGB blocks
				local function mkRGB(lbl, xOff)
					local blk = N("Frame", {
						Size     = v_u_7(0, 40, 1, 0),
						Position = v_u_7(0, xOff, 0, 0),
						BackgroundColor3 = v_u_10(13,13,16),
						BorderSizePixel = 0, ZIndex = 23, Parent = infoRow,
					})
					Corner(blk, 5)
					Stroke(blk, T.elBorder, 1, 0.35)
					N("TextLabel", {
						Size = v_u_7(0, 12, 1, 0), Position = v_u_7(0, 4, 0, 0),
						BackgroundTransparency = 1, Text = lbl,
						TextColor3 = T.muted, TextSize = 7, Font = v_u_15.GothamBold,
						TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 24, Parent = blk,
					})
					local nl = N("TextLabel", {
						Size     = v_u_7(1, -16, 1, 0),
						Position = v_u_7(0, 16, 0, 0),
						BackgroundTransparency = 1, Text = "255",
						TextColor3 = T.textSec, TextSize = 8, Font = v_u_15.Code,
						TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 24, Parent = blk,
					})
					return nl
				end
				local baseRX = ROW_H + 6 + 82 + 6
				local rLbl   = mkRGB("R", baseRX)
				local gLbl   = mkRGB("G", baseRX + 46)
				local bLbl   = mkRGB("B", baseRX + 92)

				-- Atualização
				local function updateAll(fireCallback)
					currentColor = v_u_11(hh, ss, vv)

					swatch.BackgroundColor3   = currentColor
					prevBox.BackgroundColor3  = currentColor
					svFrame.BackgroundColor3  = v_u_11(hh, 1, 1)

					-- cursores (posição escalar relativa ao pai — funciona sem AbsoluteSize)
					svCur.Position  = v_u_7(ss, 0, 1-vv, 0)
					svCur.BackgroundColor3 = currentColor
					hueCur.Position = v_u_7(hh, 0, 0.5, 0)

					local hexStr = ColorToHex(currentColor)
					if not hexBox:IsFocused() then hexBox.Text = hexStr end

					if rLbl then rLbl.Text = tostring(v_u_17(currentColor.R*255)) end
					if gLbl then gLbl.Text = tostring(v_u_17(currentColor.G*255)) end
					if bLbl then bLbl.Text = tostring(v_u_17(currentColor.B*255)) end

					SaveSet(saveId, currentColor)
					if fireCallback then
						local ok, err = pcall(function() if callback then callback(currentColor) end end)
						if not ok then NotifyError("ColorPicker", err) end
					end
				end

				updateAll(false)

				-- Drag
				local svDrag  = false
				local hueDrag = false

				local function sampleSV(x, y)
					if not svFrame or not svFrame.Parent then return end
					local ab = svFrame.AbsolutePosition
					local sz = svFrame.AbsoluteSize
					if sz.X <= 0 or sz.Y <= 0 then return end
					ss = v_u_16((x - ab.X) / sz.X, 0, 1)
					vv = 1 - v_u_16((y - ab.Y) / sz.Y, 0, 1)
					updateAll(true)
				end

				local function sampleHue(x)
					if not hueFrame or not hueFrame.Parent then return end
					local ab = hueFrame.AbsolutePosition
					local sz = hueFrame.AbsoluteSize
					if sz.X <= 0 then return end
					hh = v_u_16((x - ab.X) / sz.X, 0, 1)
					updateAll(true)
				end

				svHit.InputBegan:Connect(function(inp)
					if not enabled then return end
					if inp.UserInputType ~= Enum.UserInputType.MouseButton1
						and inp.UserInputType ~= Enum.UserInputType.Touch then return end
					svDrag = true
					sampleSV(inp.Position.X, inp.Position.Y)
				end)

				hueHit.InputBegan:Connect(function(inp)
					if not enabled then return end
					if inp.UserInputType ~= Enum.UserInputType.MouseButton1
						and inp.UserInputType ~= Enum.UserInputType.Touch then return end
					hueDrag = true
					sampleHue(inp.Position.X)
				end)

				local cpMoveConn = v_u_2.InputChanged:Connect(function(inp)
					if not enabled then return end
					if inp.UserInputType ~= Enum.UserInputType.MouseMovement
						and inp.UserInputType ~= Enum.UserInputType.Touch then return end
					if svDrag  then sampleSV(inp.Position.X, inp.Position.Y) end
					if hueDrag then sampleHue(inp.Position.X) end
				end)

				local cpEndConn = v_u_2.InputEnded:Connect(function(inp)
					if inp.UserInputType == Enum.UserInputType.MouseButton1
						or inp.UserInputType == Enum.UserInputType.Touch then
						svDrag  = false
						hueDrag = false
					end
				end)

				hexBox.FocusLost:Connect(function()
					if not enabled then return end
					local c = HexToColor(hexBox.Text)
					if c then
						currentColor = c
						hh, ss, vv   = v_u_12(c)
						updateAll(true)
					else
						hexBox.Text = ColorToHex(currentColor)
					end
				end)

				-- Abrir / Fechar
				local function closeCP()
					open = false
					Tw(panel,   { Size = v_u_7(1, 0, 0, 0) },    0.2, v_u_14.Quint)
					Tw(wrap,    { Size = v_u_7(1, 0, 0, EL_H) }, 0.2, v_u_14.Quint)
					Tw(chevron, { Rotation = 0,   ImageColor3 = v_u_10(70,70,78) }, 0.15)
					Tw(header,  { BackgroundColor3 = T.elBg }, 0.14)
				end

				local togBtn = N("TextButton", {
					Size = v_u_8(1, 1),
					BackgroundTransparency = 1, Text = "", ZIndex = 15, Parent = header,
				})
				togBtn.MouseButton1Click:Connect(function()
					if not enabled then return end
					open = not open
					if open then
						Tw(panel,   { Size = v_u_7(1, 0, 0, PANEL_H) },              0.22, v_u_14.Quint)
						Tw(wrap,    { Size = v_u_7(1, 0, 0, EL_H+GAP+PANEL_H) },     0.22, v_u_14.Quint)
						Tw(chevron, { Rotation = 180, ImageColor3 = T.white }, 0.18)
						Tw(header,  { BackgroundColor3 = T.elBgHov }, 0.12)
					else
						closeCP()
					end
				end)
				togBtn.MouseEnter:Connect(function()
					if not open and enabled then Tw(header, { BackgroundColor3 = T.elBgHov }, 0.1) end
				end)
				togBtn.MouseLeave:Connect(function()
					if not open and enabled then Tw(header, { BackgroundColor3 = T.elBg },    0.1) end
				end)

				if saveId and saveId ~= "" and SaveGet(saveId) ~= nil then
					pcall(function() if callback then callback(currentColor) end end)
				end

				return {
					Set = function(_, c)
						if typeof(c) ~= "Color3" then return end
						currentColor = c
						hh, ss, vv   = v_u_12(c)
						updateAll(false)
						SaveSet(saveId, c)
					end,
					Get    = function(_) return currentColor end,
					SetHex = function(_, hexStr)
						local c = HexToColor(tostring(hexStr or ""))
						if c then
							currentColor = c
							hh, ss, vv   = v_u_12(c)
							updateAll(false)
							SaveSet(saveId, c)
						end
					end,
					GetHex     = function(_) return ColorToHex(currentColor) end,
					SetEnabled = function(_, val2)
						enabled = val2 ~= false
						if not enabled and open then closeCP() end
						applyDisabled(header, not enabled)
						svDrag  = false
						hueDrag = false
					end,
					SetVisible  = function(_, vval) if wrap then wrap.Visible = vval ~= false end end,
					SetTitle    = function(_, val2) if titleLbl then titleLbl.Text = tostring(val2) end end,
					SetCallback = function(_, fn) callback = fn end,
					Destroy     = function(_)
						pcall(function() cpMoveConn:Disconnect() end)
						pcall(function() cpEndConn:Disconnect() end)
						svDrag  = false
						hueDrag = false
						pcall(function() wrap:Destroy() end)
					end,
				}
			end
			-- ============================================================
			-- FIM DO COLOR PICKER
			-- ============================================================

			local sectionHandle = setmetatable({}, { __index = secApi })

			function sectionHandle:SetTitle(newText)
				if secTitleLbl then
					secTitleLbl.Text = string.upper(tostring(newText or ""))
				end
			end

			function sectionHandle:SetVisible(v)
				if wrap then wrap.Visible = v ~= false end
			end

			function sectionHandle:Destroy()
				pcall(function() wrap:Destroy() end)
			end

			return sectionHandle
		end

		return tabApi
	end

	-- Minimize System
	local MinQuad = N("ImageButton", {
		Name = "MinQuad", Parent = ScreenGui,
		BackgroundColor3 = v_u_10(18, 18, 18),
		Position = v_u_7(1, -60, 1, -60), Size = v_u_7(0, 44, 0, 44),
		BorderSizePixel = 0, Image = "",
		ImageTransparency = 0.35, ImageColor3 = v_u_10(180, 180, 180),
		Active = true, Draggable = true, Visible = false,
	})
	Corner(MinQuad, 8)
	Stroke(MinQuad, v_u_10(60, 60, 65), 1.2)

	local _mqDragged   = false
	local _mqDragStart = nil

	MinQuad.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then
			_mqDragged   = false
			_mqDragStart = inp.Position
		end
	end)
	MinQuad.InputChanged:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseMovement and _mqDragStart then
			if (inp.Position - _mqDragStart).Magnitude > 4 then _mqDragged = true end
		end
	end)
	MinQuad.MouseButton1Up:Connect(function()
		if not _mqDragged then
			MinQuad.Visible   = false
			MainFrame.Visible = true
			MainFrame.Size    = v_u_7(0, WIN_W, 0, 0)
			Tw(MainFrame, { Size = v_u_7(0, WIN_W, 0, WIN_H) }, 0.25, v_u_14.Quint)
		end
	end)

	MoveBtn.MouseButton1Click:Connect(function()
		Tw(MainFrame, { Size = v_u_7(0, WIN_W, 0, 0) }, 0.2, v_u_14.Quint)
		task.delay(0.22, function()
			MainFrame.Visible = false
			MinQuad.Visible   = true
		end)
	end)

	return winApi
end

return EcoHub
