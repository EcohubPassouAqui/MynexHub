# MYNEX LIB ( MODE BY ECO HUB )
```
-- // Mynex Hub
local MynexHub = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/EcohubPassouAqui/MynexHub/main/MynexHub%20Lib/Lib.luau"
))()

-- // Window
local Window = MynexHub:CreateWindow({
    Title    = "Universal",
    SubTitle = "discord.gg/?",
})

-- // Tabs
local Tab = Window:AddTab({ Name = "Hub", Sub = "menu", Icon = "home" })

local secLeft  = Tab:AddSection("left",  "Geral")
local secRight = Tab:AddSection("right", "Visual")

-- LEFT - 1 de cada elemento
local togSpeedhack = secLeft:AddToggle("Speedhack", false, "mx_speedhack", function(v) print("Speedhack:", v) end)
local chkSilencioso = secLeft:AddCheckbox("Modo Silencioso", false, "mx_silencioso", function(v) print("Silencioso:", v) end)
local lblStatus = secLeft:AddLabel("Status", "Inativo", "mx_status")
local btnRecarregar = secLeft:AddButton("Recarregar", "mx_recarregar", function() lblStatus:Set("Recarregado") end)
local sldWalkSpeed = secLeft:AddSlider("Walk Speed", 16, 500, 16, "mx_walkspeed", function(v) print("WalkSpeed:", v) end, 1)
local cpESP = secLeft:AddColorPicker("Cor ESP", Color3.fromRGB(255, 100, 50), "mx_cor_esp", function(c) print("CorESP:", c) end)
local ddParte = secLeft:AddDropdown("Parte do Corpo", { "Head", "Torso", "HumanoidRootPart", "LeftArm", "RightArm" }, "Head", "mx_parte_corpo", function(v) print("Parte:", v) end)

-- RIGHT - 1 de cada elemento
local togESP = secRight:AddToggle("ESP Ativo", false, "mx_esp", function(v) print("ESP:", v) end)
local chkSilentAim = secRight:AddCheckbox("Silent Aim", false, "mx_silent_aim", function(v) print("SilentAim:", v) end)
local lblKills = secRight:AddLabel("Kills", "0", "mx_kills")
local btnResetAim = secRight:AddButton("Reset Aim", "", function() print("Reset!") end)
local sldFOV = secRight:AddSlider("FOV", 10, 500, 120, "mx_fov", function(v) print("FOV:", v) end, 5)
local cpAimColor = secRight:AddColorPicker("Cor Aimbot", Color3.fromRGB(255, 50, 50), "mx_aim_color", function(c) print("AimColor:", c) end)
local ddChamsMode = secRight:AddDropdown("Modo Chams", { "Flat", "Neon", "Glass" }, "Flat", "mx_chams_mode", function(v) print("ChamsMode:", v) end)
```
