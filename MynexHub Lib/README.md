# MYNEX LIB ( MODE BY ECO HUB )
```
-- // Mynex Hub
local MynexHub = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/EcohubPassouAqui/MynexHub/main/MynexHub%20Lib/Lib.luau"
))()

-- // Window
local Window = EcoHub:CreateWindow({
	Title    = "Universal",
	SubTitle = "discord.gg/?",
})

-- // Tabs
local Tab = Window:AddTab({
	Name = "Hub",
	Sub  = "menu",
	Icon = "home",
})

local secLeft  = Tab:AddSection({ Box = "left",  Name = "Geral",  Icon = "home" })
local secRight = Tab:AddSection({ Box = "right", Name = "Visual", Icon = "eye" })

-- // Left
local togSpeedhack = secLeft:AddToggle({
	Title    = "Speedhack",
	Default  = false,
	SaveId   = "mx_speedhack",
	Callback = function(v)
		print("Speedhack:", v)
	end,
})

local chkSilencioso = secLeft:AddCheckbox({
	Title    = "Modo Silencioso",
	Default  = false,
	SaveId   = "mx_silencioso",
	Callback = function(v)
		print("Silencioso:", v)
	end,
})

local lblStatus = secLeft:AddLabel({
	Title  = "Status",
	Value  = "Inativo",
	SaveId = "mx_status",
})

local btnRecarregar = secLeft:AddButton({
	Title    = "Recarregar",
	Callback = function()
		lblStatus:Set("Recarregado")
	end,
})

local sldWalkSpeed = secLeft:AddSlider({
	Title    = "Walk Speed",
	Min      = 16,
	Max      = 500,
	Default  = 16,
	Rounding = 1,
	SaveId   = "mx_walkspeed",
	Callback = function(v)
		print("WalkSpeed:", v)
	end,
})

local cpESP = secLeft:AddColorPicker({
	Title    = "Cor ESP",
	Default  = Color3.fromRGB(255, 100, 50),
	SaveId   = "mx_cor_esp",
	Callback = function(c)
		print("CorESP:", c)
	end,
})

local ddParte = secLeft:AddDropdown({
	Title    = "Parte do Corpo",
	Options  = { "Head", "Torso", "HumanoidRootPart", "LeftArm", "RightArm" },
	Default  = "Head",
	SaveId   = "mx_parte_corpo",
	Callback = function(v)
		print("Parte:", v)
	end,
})

-- // Right
local togESP = secRight:AddToggle({
	Title    = "ESP Ativo",
	Default  = false,
	SaveId   = "mx_esp",
	Callback = function(v)
		print("ESP:", v)
	end,
})

local chkSilentAim = secRight:AddCheckbox({
	Title    = "Silent Aim",
	Default  = false,
	SaveId   = "mx_silent_aim",
	Callback = function(v)
		print("SilentAim:", v)
	end,
})

local lblKills = secRight:AddLabel({
	Title  = "Kills",
	Value  = "0",
	SaveId = "mx_kills",
})

local btnResetAim = secRight:AddButton({
	Title    = "Reset Aim",
	Callback = function()
		print("Reset!")
	end,
})

local sldFOV = secRight:AddSlider({
	Title    = "FOV",
	Min      = 10,
	Max      = 500,
	Default  = 120,
	Rounding = 5,
	SaveId   = "mx_fov",
	Callback = function(v)
		print("FOV:", v)
	end,
})

local cpAimColor = secRight:AddColorPicker({
	Title    = "Cor Aimbot",
	Default  = Color3.fromRGB(255, 50, 50),
	SaveId   = "mx_aim_color",
	Callback = function(c)
		print("AimColor:", c)
	end,
})

local ddChamsMode = secRight:AddDropdown({
	Title    = "Modo Chams",
	Options  = { "Flat", "Neon", "Glass" },
	Default  = "Flat",
	SaveId   = "mx_chams_mode",
	Callback = function(v)
		print("ChamsMode:", v)
	end,
})
```
