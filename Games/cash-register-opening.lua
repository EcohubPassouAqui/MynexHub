-- // Fluent
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- // Window
local MarketplaceService = game:GetService("MarketplaceService")
local gameInfo = MarketplaceService:GetProductInfo(game.PlaceId)
local gameName = gameInfo.Name

local Window = Fluent:CreateWindow({
    Title = "Mynex Hub | " .. gameName,
    SubTitle = "by rip_sheldoohz",
    TabWidth = 120,
    Size = UDim2.fromOffset(550, 350),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightAlt
})

-- // Tabs
local Tabs = {
    Main  = Window:AddTab({ Title = "Main",      Icon = "layout-dashboard" }),
    Dice  = Window:AddTab({ Title = "Dice",       Icon = "dices" }),
    Gold  = Window:AddTab({ Title = "Baus Gold",  Icon = "gem" }),
    Zones = Window:AddTab({ Title = "Zones",      Icon = "navigation" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- // Main
Tabs.Main:AddSection("Farm Cases")

Tabs.Main:AddParagraph({
    Title = "Embreve",
    Content = "by rip_sheldoohz",
})

-- // Zones
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local v_u_player = Players.LocalPlayer
local autoZoneConn = nil
local noclipConn = nil
local copyTargetName = nil

local ZONES = {
    { name = "Zone 1", cf = CFrame.new(119,  -418, -1163) },
    { name = "Zone 2", cf = CFrame.new(273,  -418, -1146) },
    { name = "Zone 3", cf = CFrame.new(392,  -416, -1151) },
    { name = "Zone 4", cf = CFrame.new(511,  -417, -1153) },
    { name = "Zone 5", cf = CFrame.new(633,  -417, -1151) },
    { name = "Zone 6", cf = CFrame.new(752,  -417, -1149) },
    { name = "Zone 7", cf = CFrame.new(872,  -417, -1151) },
    { name = "Zone 8", cf = CFrame.new(992,  -417, -1152) },
    { name = "Zone 9", cf = CFrame.new(1112, -423, -1158) },
}

local ZONE_NAMES = {}
for _, z in ipairs(ZONES) do table.insert(ZONE_NAMES, z.name) end

local selectedZone = ZONES[1]

local function getRootPart()
    local char = v_u_player.Character
    if char then return char:FindFirstChild("HumanoidRootPart") end
    return nil
end

local function teleportTo(cf)
    local root = getRootPart()
    if not root then print("[ERRO] HumanoidRootPart nao encontrado") return false end
    root.CFrame = cf + Vector3.new(0, 4, 0)
    return true
end

local function getZoneByName(name)
    for _, z in ipairs(ZONES) do
        if z.name == name then return z end
    end
    return nil
end

local function passAllZones()
    if not getRootPart() then print("[ERRO] HumanoidRootPart nao encontrado") return end
    for _, z in ipairs(ZONES) do
        teleportTo(z.cf)
        task.wait(0.3)
        print("[ZONE] Passou: " .. z.name)
    end
    print("[ZONE] Todas as zonas atravessadas: " .. v_u_player.Name)
end

local function stopAutoZone()
    if autoZoneConn then autoZoneConn:Disconnect() autoZoneConn = nil end
end

local function startAutoZone()
    stopAutoZone()
    local lastRun = 0
    autoZoneConn = RunService.Heartbeat:Connect(function()
        local now = tick()
        if now - lastRun < 2 then return end
        lastRun = now
        task.spawn(passAllZones)
    end)
end

local function stopNoclip()
    if noclipConn then noclipConn:Disconnect() noclipConn = nil end
    local char = v_u_player.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end
end

local function startNoclip()
    stopNoclip()
    noclipConn = RunService.Stepped:Connect(function()
        local char = v_u_player.Character
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end)
end

local function getPlayerList()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= v_u_player then table.insert(list, p.Name) end
    end
    return list
end

local function teleportToPlayer(targetName)
    local target = Players:FindFirstChild(targetName)
    if not target then print("[ERRO] Jogador nao encontrado: " .. tostring(targetName)) return end
    local char = target.Character
    if not char then print("[ERRO] Personagem nao encontrado") return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then print("[ERRO] HumanoidRootPart do alvo nao encontrado") return end
    local myRoot = getRootPart()
    if not myRoot then print("[ERRO] Seu HumanoidRootPart nao encontrado") return end
    myRoot.CFrame = root.CFrame + Vector3.new(0, 3, 0)
    print("[TP] Teleportado para: " .. targetName .. " | XYZ: " .. tostring(root.Position))
end

Tabs.Zones:AddSection("Zones")

local zoneDropdown = Tabs.Zones:AddDropdown("ZoneSelect", {
    Title = "Escolher Zone",
    Description = "Selecione a zone para teleportar",
    Values = ZONE_NAMES,
    Default = ZONE_NAMES[1],
    Callback = function(v)
        selectedZone = getZoneByName(v)
    end
})

Tabs.Zones:AddToggle("InstantZone", {
    Title = "Teleporte Instantaneo na Zone",
    Description = "Teleporta imediatamente na zone selecionada",
    Default = false,
    Callback = function(v)
        if v and selectedZone then teleportTo(selectedZone.cf) end
    end
})

Tabs.Zones:AddToggle("AutoZone", {
    Title = "Auto Passar Todas as Zones",
    Description = "Atravessa todas as zones automaticamente",
    Default = false,
    Callback = function(v)
        if v then startAutoZone() else stopAutoZone() end
    end
})

Tabs.Zones:AddButton({
    Title = "Passar Todas as Zones Agora",
    Description = "Atravessa todas as zones uma vez",
    Callback = function()
        task.spawn(passAllZones)
    end
})

Tabs.Zones:AddSection("Local Player")

Tabs.Zones:AddToggle("Noclip", {
    Title = "Noclip",
    Description = "Atravessa paredes e objetos fisicos",
    Default = false,
    Callback = function(v)
        if v then startNoclip() else stopNoclip() end
    end
})

Tabs.Zones:AddSlider("WalkSpeed", {
    Title = "Velocidade",
    Description = "Velocidade de caminhada do personagem",
    Default = 16,
    Min = 16,
    Max = 500,
    Rounding = 0,
    Callback = function(v)
        local char = v_u_player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = tonumber(v) end
        end
    end
})

Tabs.Zones:AddSection("Teleporte para Jogador")

local playerList = getPlayerList()

local playerDropdown = Tabs.Zones:AddDropdown("PlayerSelect", {
    Title = "Escolher Jogador",
    Description = "Selecione o jogador para se teleportar",
    Values = #playerList > 0 and playerList or {"Nenhum jogador"},
    Default = playerList[1] or "Nenhum jogador",
    Callback = function(v)
        if v ~= "Nenhum jogador" then copyTargetName = v end
    end
})

Tabs.Zones:AddButton({
    Title = "Ir para Jogador",
    Description = "Teleporta uma vez para onde o jogador esta",
    Callback = function()
        if not copyTargetName then print("[ERRO] Selecione um jogador primeiro") return end
        teleportToPlayer(copyTargetName)
    end
})

task.spawn(function()
    while true do
        task.wait(5)
        local newPlayers = getPlayerList()
        if #newPlayers > 0 then
            playerDropdown:SetValues(newPlayers)
            if not copyTargetName or not table.find(newPlayers, copyTargetName) then
                copyTargetName = newPlayers[1]
                playerDropdown:SetValue(newPlayers[1])
            end
        else
            playerDropdown:SetValues({"Nenhum jogador"})
            playerDropdown:SetValue("Nenhum jogador")
            copyTargetName = nil
        end
    end
end)

-- // Baus Gold
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace  = game:GetService("Workspace")

local v_u_player = Players.LocalPlayer

local flyConn        = nil
local noclipConn     = nil
local antiAfkConn    = nil
local autoTpConn     = nil
local antiEscapeConn = nil
local cargoTrackConn = nil

local isFarming      = false
local isCargoFarming = false
local isAutoTp       = false
local isRageMode     = false

local FLY_SPEED      = 300
local FARM_RADIUS    = 3000
local SAFE_HEIGHT    = 80
local MAX_TRACK_TIME = 30

local flyBodyVel  = nil
local flyBodyGyro = nil

local statusGold  = "Inativo"
local statusCargo = "Inativo"
local goldCollected  = 0
local cargoCollected = 0
local StatusParagraph = nil

local cachedCharParts = {}
local lastCharCache   = 0
local CHAR_CACHE_TTL  = 2

local goldPotCache   = nil
local lastGoldSearch = 0
local GOLD_CACHE_TTL = 0.5

local carePackFolder   = nil
local lastFolderSearch = 0
local FOLDER_CACHE_TTL = 5

local farmBasePos = nil

local function safeSetIdentity(id)
    if setthreadidentity then pcall(setthreadidentity, id or 6) end
end
safeSetIdentity(6)

local G = getgenv and getgenv() or _G
G._GoldState = G._GoldState or { antiKickHooked = false }
local GState = G._GoldState

local function safeClone(obj)
    if not obj then return nil end
    if not cloneref then return obj end
    local ok, r = pcall(cloneref, obj)
    return (ok and r) or obj
end

local function safeGet(fn)
    local ok, v = pcall(fn)
    return ok and v or nil
end

local function updateStatus()
    pcall(function()
        if StatusParagraph then
            StatusParagraph:SetContent(
                "GoldPot: " .. statusGold  .. " | Coletados: " .. goldCollected  ..
                "\nCargo: "  .. statusCargo .. " | Coletados: " .. cargoCollected
            )
        end
    end)
end

local function getRootPart()
    local char = safeGet(function() return v_u_player.Character end)
    if char then return safeGet(function() return char:FindFirstChild("HumanoidRootPart") end) end
end

local function getHumanoid()
    local char = safeGet(function() return v_u_player.Character end)
    if char then return safeGet(function() return char:FindFirstChildOfClass("Humanoid") end) end
end

local function isCharacterAlive()
    local hum = getHumanoid()
    if not hum then return false end
    local ok, hp = pcall(function() return hum.Health end)
    return ok and hp > 0
end

local function waitForRespawn(timeout)
    timeout = timeout or 15
    local t = tick()
    repeat task.wait(0.3) until isCharacterAlive() or (tick() - t > timeout)
    task.wait(0.8)
end

local function getCharParts()
    local now = tick()
    if now - lastCharCache < CHAR_CACHE_TTL and #cachedCharParts > 0 then
        return cachedCharParts
    end
    cachedCharParts = {}
    local char = safeGet(function() return v_u_player.Character end)
    if not char then return cachedCharParts end
    local ok, descs = pcall(function() return char:GetDescendants() end)
    if not ok then return cachedCharParts end
    for _, p in ipairs(descs) do
        local isok, isBP = pcall(function() return p:IsA("BasePart") end)
        if isok and isBP then cachedCharParts[#cachedCharParts + 1] = p end
    end
    lastCharCache = now
    return cachedCharParts
end

local function stopNoclip()
    if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
    for _, p in ipairs(cachedCharParts) do pcall(function() p.CanCollide = true end) end
    cachedCharParts = {}
end

local function startNoclip()
    stopNoclip()
    noclipConn = RunService.Stepped:Connect(function()
        safeSetIdentity(6)
        local parts = getCharParts()
        for i = 1, #parts do
            local p = parts[i]
            if p and p.Parent then pcall(function() p.CanCollide = false end) end
        end
    end)
end

local function stopFly()
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    if flyBodyVel  then pcall(function() flyBodyVel:Destroy()  end); flyBodyVel  = nil end
    if flyBodyGyro then pcall(function() flyBodyGyro:Destroy() end); flyBodyGyro = nil end
    local root = getRootPart()
    if root then
        local bg = safeGet(function() return root:FindFirstChild("_GoldBG") end)
        local bv = safeGet(function() return root:FindFirstChild("_GoldBV") end)
        if bg then pcall(function() bg:Destroy() end) end
        if bv then pcall(function() bv:Destroy() end) end
    end
    local hum = getHumanoid()
    if hum then pcall(function() hum.PlatformStand = false end) end
end

local function flyToPosition(targetPos, onArrived)
    stopFly()
    local root = getRootPart()
    local hum  = getHumanoid()
    if not root or not hum then return end
    safeSetIdentity(6)
    pcall(function() hum.PlatformStand = true end)

    local bv = Instance.new("BodyVelocity")
    bv.Name = "_GoldBV"; bv.MaxForce = Vector3.new(9e9,9e9,9e9)
    bv.Velocity = Vector3.zero; bv.Parent = root; flyBodyVel = bv

    local bg = Instance.new("BodyGyro")
    bg.Name = "_GoldBG"; bg.MaxTorque = Vector3.new(9e9,9e9,9e9)
    bg.P = 1e4; bg.D = 100; bg.CFrame = root.CFrame; bg.Parent = root; flyBodyGyro = bg

    flyConn = RunService.Heartbeat:Connect(function()
        local r = getRootPart()
        if not r or not bv or not bv.Parent then stopFly(); return end
        local dir  = targetPos - r.Position
        local dist = dir.Magnitude
        if dist < 3 then
            stopFly()
            local hm = getHumanoid()
            if hm then pcall(function() hm.PlatformStand = false end) end
            if onArrived then task.spawn(onArrived) end
            return
        end
        pcall(function()
            bv.Velocity = dir.Unit * math.min(FLY_SPEED, dist * 10)
            bg.CFrame   = CFrame.lookAt(r.Position, r.Position + dir)
        end)
    end)
end

local function stopAntiAfk()
    if antiAfkConn then antiAfkConn:Disconnect(); antiAfkConn = nil end
end

local function patchAntiKick()
    if GState.antiKickHooked then return end
    if not (getrawmetatable and setreadonly and newcclosure and getnamecallmethod) then return end
    pcall(function()
        local mt = getrawmetatable(game)
        if not mt then return end
        local old = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local ok, method = pcall(getnamecallmethod)
            if ok and method == "Kick" then
                local okC, isSame = pcall(function()
                    return compareinstances and compareinstances(self, v_u_player) or self == v_u_player
                end)
                if okC and isSame then return end
            end
            return old(self, ...)
        end)
        setreadonly(mt, true)
        GState.antiKickHooked = true
    end)
end

local function startAntiAfk()
    stopAntiAfk()
    patchAntiKick()
    local toggle = false
    local lastMove = tick()
    antiAfkConn = RunService.Heartbeat:Connect(function()
        local now = tick()
        if now - lastMove < 0.5 then return end
        local hum = getHumanoid()
        if not hum then return end
        if safeGet(function() return hum.PlatformStand end) then return end
        toggle = not toggle
        lastMove = now
        pcall(function()
            hum:Move(toggle and Vector3.new(0.01,0,0) or Vector3.new(-0.01,0,0), false)
        end)
    end)
end

local function stopAntiEscape()
    if antiEscapeConn then antiEscapeConn:Disconnect(); antiEscapeConn = nil end
end

local function startAntiEscape()
    stopAntiEscape()
    local lastCheck = 0
    antiEscapeConn = RunService.Heartbeat:Connect(function()
        local now = tick()
        if now - lastCheck < 0.5 then return end
        lastCheck = now
        if not isFarming and not isCargoFarming and not isAutoTp then return end
        if not farmBasePos then return end
        local root = getRootPart()
        if not root then return end
        local ok, dist = pcall(function() return (root.Position - farmBasePos).Magnitude end)
        if ok and dist > FARM_RADIUS then
            pcall(function() root.CFrame = CFrame.new(farmBasePos + Vector3.new(0, 5, 0)) end)
        end
    end)
end

local function saveBasePos()
    if farmBasePos then return end
    local root = getRootPart()
    if root then
        local ok, pos = pcall(function() return root.Position end)
        if ok then farmBasePos = pos end
    end
end

local function doTouchInterest(part, root)
    if not part or not root then return end
    pcall(firetouchinterest, part, root, 0)
    task.wait(0.02)
    pcall(firetouchinterest, part, root, 1)
end

local function doFirePrompt(prompt)
    if not prompt then return end
    safeSetIdentity(6)
    if isRageMode then
        pcall(function() prompt.MaxActivationDistance = 10000 end)
        pcall(function() prompt.RequiresLineOfSight    = false end)
    end
    local ok = pcall(fireproximityprompt, prompt)
    if not ok and firesignal and getconnections then
        pcall(function()
            local conns = getconnections(prompt.Triggered)
            if conns then
                for _, c in ipairs(conns) do pcall(function() c:Fire() end) end
            end
        end)
    end
end

local function findGoldPot()
    local now = tick()
    if goldPotCache and safeGet(function() return goldPotCache.Parent end)
       and now - lastGoldSearch < GOLD_CACHE_TTL then
        return goldPotCache
    end
    goldPotCache   = nil
    lastGoldSearch = now

    local function check(obj)
        if not obj then return end
        local ok, par  = pcall(function() return obj.Parent end)
        if not ok or not par then return end
        local ok2, name = pcall(function() return obj.Name end)
        if not ok2 then return end
        if name ~= "GoldPot" and name ~= "[MOVING] GoldPot" then return end
        local ok3, isBP = pcall(function() return obj:IsA("BasePart") end)
        local ok4, isM  = pcall(function() return obj:IsA("Model")    end)
        if (ok3 and isBP) or (ok4 and isM) then
            goldPotCache = safeClone(obj)
        end
    end

    local ok, descs = pcall(function() return Workspace:GetDescendants() end)
    if ok then
        for _, obj in ipairs(descs) do
            check(obj)
            if goldPotCache then return goldPotCache end
        end
    end

    if not goldPotCache and getinstances then
        local ok2, all = pcall(getinstances)
        if ok2 then
            for _, inst in ipairs(all) do
                check(inst)
                if goldPotCache then return goldPotCache end
            end
        end
    end

    return goldPotCache
end

local function getGoldPart()
    local pot = findGoldPot()
    if not pot then return nil end
    local ok1, isBP = pcall(function() return pot:IsA("BasePart") end)
    if ok1 and isBP then return pot end
    local ok2, pp   = pcall(function() return pot.PrimaryPart end)
    if ok2 and pp   then return pp end
    local ok3, found = pcall(function() return pot:FindFirstChildWhichIsA("BasePart", true) end)
    if ok3 then return found end
end

local function interactGoldPot()
    safeSetIdentity(6)
    local pot  = findGoldPot()
    local root = getRootPart()
    if not pot or not root then return end
    local ok, descs = pcall(function() return pot:GetDescendants() end)
    if ok then
        for _, v in ipairs(descs) do
            local isok, isBP = pcall(function() return v:IsA("BasePart") end)
            if isok and isBP then doTouchInterest(v, root) end
        end
    end
    local ok1, isBP = pcall(function() return pot:IsA("BasePart") end)
    if ok1 and isBP then doTouchInterest(pot, root) end
    goldCollected = goldCollected + 1
    statusGold    = "Coletado #" .. goldCollected
    updateStatus()
end

local function getCarePackagesFolder()
    local now = tick()
    if carePackFolder and safeGet(function() return carePackFolder.Parent end)
       and now - lastFolderSearch < FOLDER_CACHE_TTL then
        return carePackFolder
    end
    carePackFolder   = nil
    lastFolderSearch = now

    local f = safeGet(function() return Workspace:FindFirstChild("CarePackages") end)
    if f then carePackFolder = f; return f end

    if getinstances then
        local ok, all = pcall(getinstances)
        if ok then
            for _, inst in ipairs(all) do
                local name = safeGet(function() return inst.Name end)
                local par  = safeGet(function() return inst.Parent end)
                if name == "CarePackages" and par then
                    carePackFolder = safeClone(inst)
                    return carePackFolder
                end
            end
        end
    end
end

local function findCargos()
    local list   = {}
    local folder = getCarePackagesFolder()
    if not folder then return list end
    local ok, children = pcall(function() return folder:GetChildren() end)
    if not ok then return list end
    for _, model in ipairs(children) do
        local ok1, isM = pcall(function() return model:IsA("Model")  end)
        local ok2, isF = pcall(function() return model:IsA("Folder") end)
        if (ok1 and isM) or (ok2 and isF) then
            list[#list + 1] = safeClone(model)
        end
    end
    return list
end

local function getCargoPayload(cargoModel)
    local p1 = safeGet(function() return cargoModel:FindFirstChild("Payload") end)
    if p1 then
        local ok, isBP = pcall(function() return p1:IsA("BasePart") end)
        if ok and isBP then return p1 end
    end
    local pp = safeGet(function() return cargoModel.PrimaryPart end)
    if pp then return pp end
    local ok, found = pcall(function() return cargoModel:FindFirstChildWhichIsA("BasePart", true) end)
    if ok then return found end
end

local function getCargoPrompt(cargoModel)
    local payload = safeGet(function() return cargoModel:FindFirstChild("Payload") end)
    if payload then
        local p1 = safeGet(function() return payload:FindFirstChildOfClass("ProximityPrompt") end)
        if p1 then return p1 end
        local p2 = safeGet(function() return payload:FindFirstChildWhichIsA("ProximityPrompt", true) end)
        if p2 then return p2 end
    end
    local ok, descs = pcall(function() return cargoModel:GetDescendants() end)
    if ok then
        for _, v in ipairs(descs) do
            local isok, isPP = pcall(function() return v:IsA("ProximityPrompt") end)
            if isok and isPP then return v end
        end
    end
end

local function getCargoYPos(cargoModel)
    local payload = getCargoPayload(cargoModel)
    if not payload then return nil end
    local ok, pos = pcall(function() return payload.Position end)
    if ok then return pos.Y, pos end
    return nil
end

local function forceMaxHealth()
    local hum = getHumanoid()
    if not hum then return end
    pcall(function()
        local max = hum.MaxHealth
        hum.Health = max
    end)
end

local function safeSetStat(statName, value)
    pcall(function()
        local ls = v_u_player:FindFirstChild("leaderstats")
        if ls then
            local stat = ls:FindFirstChild(statName)
            if stat then stat.Value = value end
        end
    end)
end

local function interactCargoFull(cargoModel)
    safeSetIdentity(6)
    local root = getRootPart()
    if not root then return false end

    local payload = getCargoPayload(cargoModel)
    if not payload then return false end

    local okPos, payloadPos = pcall(function() return payload.Position end)
    if not okPos then return false end

    pcall(function() root.CFrame = CFrame.new(payloadPos + Vector3.new(0, 2, 0)) end)
    task.wait(0.05)

    local prompt = getCargoPrompt(cargoModel)
    if prompt then
        if isRageMode then
            pcall(function() prompt.MaxActivationDistance = 10000 end)
            pcall(function() prompt.RequiresLineOfSight    = false end)
        else
            pcall(function() prompt.MaxActivationDistance = 50 end)
            pcall(function() prompt.RequiresLineOfSight    = false end)
        end
        pcall(fireproximityprompt, prompt)
        task.wait(0.05)
        if firesignal and getconnections then
            pcall(function()
                local conns = getconnections(prompt.Triggered)
                if conns then
                    for _, c in ipairs(conns) do pcall(function() c:Fire() end) end
                end
            end)
        end
        task.wait(0.05)
    end

    local okD, descs = pcall(function() return cargoModel:GetDescendants() end)
    if okD then
        for _, v in ipairs(descs) do
            local isok, isBP = pcall(function() return v:IsA("BasePart") end)
            if isok and isBP then doTouchInterest(v, root) end
        end
    end

    pcall(function()
        local targets = {
            cargoModel,
            safeGet(function() return cargoModel:FindFirstChild("Payload") end)
        }
        for _, t in ipairs(targets) do
            if not t then continue end
            local sig = safeGet(function() return t:FindFirstChild("CarePackageKillSomething") end)
                     or safeGet(function() return t:FindFirstChild("Collect")   end)
                     or safeGet(function() return t:FindFirstChild("Collected") end)
            if sig and firesignal then pcall(firesignal, sig) end
        end
    end)

    cargoCollected = cargoCollected + 1
    statusCargo    = "Coletado #" .. cargoCollected
    updateStatus()
    return true
end

local function waitCargoLand(cargoModel, timeoutSecs)
    timeoutSecs = timeoutSecs or MAX_TRACK_TIME
    local startTime = tick()
    local lastY = nil
    local stableCount = 0

    while tick() - startTime < timeoutSecs do
        local okPar = safeGet(function() return cargoModel.Parent end)
        if not okPar then return false, "removed" end

        local yPos, fullPos = getCargoYPos(cargoModel)
        if not yPos then task.wait(0.2); continue end

        if lastY then
            local delta = math.abs(yPos - lastY)
            if delta < 0.5 then
                stableCount = stableCount + 1
            else
                stableCount = 0
            end
            if stableCount >= 3 then
                return true, fullPos
            end
        end

        lastY = yPos
        task.wait(0.15)
    end

    local yPos, fullPos = getCargoYPos(cargoModel)
    if yPos then return true, fullPos end
    return false, nil
end

local function trackAndCollectCargo(cargoModel)
    safeSetIdentity(6)
    local root = getRootPart()
    if not root then return false end

    local okPar = safeGet(function() return cargoModel.Parent end)
    if not okPar then return false end

    local yPos, fullPos = getCargoYPos(cargoModel)
    if not yPos then return false end

    if yPos > SAFE_HEIGHT then
        statusCargo = "Rastreando queda..."
        updateStatus()

        startNoclip()

        local trackStart = tick()
        local arrived = false

        while not arrived and (tick() - trackStart < MAX_TRACK_TIME) do
            local okPar2 = safeGet(function() return cargoModel.Parent end)
            if not okPar2 then break end

            local curY, curPos = getCargoYPos(cargoModel)
            if not curY then task.wait(0.1); continue end

            if not isCharacterAlive() then
                statusCargo = "Respawnando..."
                updateStatus()
                waitForRespawn()
                if not isCargoFarming then return false end
                startNoclip()
                root = getRootPart()
                if not root then return false end
                task.wait(0.2)
                continue
            end

            forceMaxHealth()

            local r = getRootPart()
            if r and curPos then
                local safePos = Vector3.new(curPos.X, curY + 3, curPos.Z)
                pcall(function() r.CFrame = CFrame.new(safePos) end)
            end

            if curY <= SAFE_HEIGHT then
                arrived = true
            end

            task.wait(0.1)
        end
    end

    if not isCharacterAlive() then
        statusCargo = "Respawnando..."
        updateStatus()
        waitForRespawn()
        if not isCargoFarming then return false end
        startNoclip()
        root = getRootPart()
        if not root then return false end
        task.wait(0.2)
    end

    local okPar3 = safeGet(function() return cargoModel.Parent end)
    if not okPar3 then return false end

    statusCargo = "Coletando Cargo..."
    updateStatus()

    local success = false
    for attempt = 1, 3 do
        safeSetIdentity(6)
        local yNow, posNow = getCargoYPos(cargoModel)
        if not yNow then break end

        local r = getRootPart()
        if r and posNow then
            pcall(function() r.CFrame = CFrame.new(posNow + Vector3.new(0, 2, 0)) end)
        end
        task.wait(0.05)

        success = interactCargoFull(cargoModel)
        if success then break end
        task.wait(0.2)
    end

    return success
end

local function stopAutoFarm()
    isFarming  = false
    statusGold = "Inativo"
    stopFly()
    updateStatus()
end

local function startAutoFarm()
    if isFarming then return end
    isFarming = true
    saveBasePos()
    startNoclip()
    startAntiAfk()
    startAntiEscape()

    task.spawn(function()
        while isFarming do
            safeSetIdentity(6)

            if not isCharacterAlive() then
                statusGold = "Aguardando respawn..."
                updateStatus()
                waitForRespawn()
                if not isFarming then break end
                startNoclip()
                task.wait(0.3)
                continue
            end

            local goldPart = getGoldPart()
            if not goldPart then
                statusGold = "Aguardando GoldPot..."
                updateStatus()
                task.wait(1)
                continue
            end

            local ok, goldPos = pcall(function() return goldPart.Position end)
            if not ok then task.wait(0.5); continue end

            statusGold = "Teleportando..."
            updateStatus()

            local root = getRootPart()
            if root then
                pcall(function() root.CFrame = CFrame.new(goldPos + Vector3.new(0, 3, 0)) end)
            end

            task.wait(0.1)
            if not isFarming then break end

            statusGold = "Interagindo..."
            updateStatus()
            interactGoldPot()
            goldPotCache = nil
            task.wait(0.3)
        end

        stopFly()
        stopNoclip()
        stopAntiEscape()
        statusGold = "Inativo"
        updateStatus()
    end)
end

local function stopCargoFarm()
    isCargoFarming = false
    statusCargo    = "Inativo"
    if cargoTrackConn then cargoTrackConn:Disconnect(); cargoTrackConn = nil end
    stopFly()
    updateStatus()
end

local function startCargoFarm()
    if isCargoFarming then return end
    isCargoFarming = true
    saveBasePos()
    startNoclip()
    startAntiAfk()
    startAntiEscape()

    task.spawn(function()
        while isCargoFarming do
            safeSetIdentity(6)

            if not isCharacterAlive() then
                statusCargo = "Aguardando respawn..."
                updateStatus()
                waitForRespawn()
                if not isCargoFarming then break end
                startNoclip()
                task.wait(0.3)
                continue
            end

            local cargos = findCargos()
            if #cargos == 0 then
                statusCargo = "Aguardando Cargo..."
                updateStatus()
                task.wait(1)
                continue
            end

            for _, cargoModel in ipairs(cargos) do
                if not isCargoFarming then break end

                local okPar = safeGet(function() return cargoModel.Parent end)
                if not okPar then continue end

                local payload = getCargoPayload(cargoModel)
                if not payload then continue end

                trackAndCollectCargo(cargoModel)

                task.wait(0.25)
            end

            task.wait(0.3)
        end

        stopFly()
        stopNoclip()
        stopAntiEscape()
        statusCargo = "Inativo"
        updateStatus()
    end)
end

local function stopAutoTp()
    isAutoTp = false
    if autoTpConn then autoTpConn:Disconnect(); autoTpConn = nil end
end

local function startAutoTp()
    stopAutoTp()
    isAutoTp = true
    saveBasePos()
    startAntiEscape()
    local lastTp = 0
    autoTpConn = RunService.Heartbeat:Connect(function()
        if not isAutoTp then return end
        safeSetIdentity(6)
        local now = tick()
        if now - lastTp < 0.4 then return end
        local part = getGoldPart()
        if not part then return end
        local root = getRootPart()
        if not root then return end
        local ok, partPos = pcall(function() return part.Position end)
        if not ok then return end
        local ok2, dist = pcall(function() return (root.Position - partPos).Magnitude end)
        if ok2 and dist > 3 then
            lastTp = now
            pcall(function() root.CFrame = part.CFrame + Vector3.new(0, 4, 0) end)
        end
    end)
end

local function onCharacterRemoving()
    stopFly()
    stopNoclip()
    cachedCharParts = {}
    lastCharCache   = 0
end

local function onCharacterAdded()
    cachedCharParts = {}
    lastCharCache   = 0
    task.wait(1)
    safeSetIdentity(6)
    if isFarming      then isFarming = false;      task.wait(0.2); startAutoFarm()  end
    if isCargoFarming then isCargoFarming = false;  task.wait(0.2); startCargoFarm() end
    if isAutoTp       then task.wait(0.2); startAutoTp() end
end

v_u_player.CharacterRemoving:Connect(onCharacterRemoving)
v_u_player.CharacterAdded:Connect(onCharacterAdded)

task.spawn(function()
    local playerGui = v_u_player:WaitForChild("PlayerGui", 15)
    if not playerGui then return end

    local function fixCanvasGroup(obj)
        pcall(function()
            if obj:IsA("CanvasGroup") then
                obj.Active = false; obj.Modal = false; obj.Interactable = false
            end
        end)
    end

    local function fixScreenGui(sg)
        pcall(function()
            if not sg:IsA("ScreenGui") then return end
            local name = sg.Name
            if name == "Chat" or name == "RobloxBubbleChat" or name == "TopbarPlus" then return end
            sg.ResetOnSpawn = false
            sg.DisplayOrder = 50
        end)
        for _, child in ipairs(sg:GetDescendants()) do fixCanvasGroup(child) end
        sg.DescendantAdded:Connect(function(child) task.defer(function() fixCanvasGroup(child) end) end)
    end

    for _, sg in ipairs(playerGui:GetChildren()) do fixScreenGui(sg) end
    playerGui.ChildAdded:Connect(function(child) task.defer(function() fixScreenGui(child) end) end)

    local chatGui = playerGui:FindFirstChild("Chat") or playerGui:FindFirstChild("RobloxBubbleChat")
    if chatGui then
        pcall(function() chatGui.DisplayOrder = 9999; chatGui.Enabled = true end)
    end

    playerGui.ChildAdded:Connect(function(child)
        pcall(function()
            if child.Name == "Chat" or child.Name == "RobloxBubbleChat" then
                child.DisplayOrder = 9999; child.Enabled = true
            end
        end)
    end)
end)

Tabs.Gold:AddSection("Status")

StatusParagraph = Tabs.Gold:AddParagraph({
    Title   = "Monitor",
    Content = "GoldPot: Inativo | Coletados: 0\nCargo: Inativo | Coletados: 0",
})

Tabs.Gold:AddSection("Configuracoes")

Tabs.Gold:AddSlider("FlySpeed", {
    Title       = "Velocidade do Voo",
    Description = "Velocidade usada no modo de voo opcional",
    Default     = 300,
    Min         = 300,
    Max         = 10000,
    Rounding    = 0,
    Callback    = function(v) FLY_SPEED = tonumber(v) end
})

Tabs.Gold:AddSlider("SafeHeight", {
    Title       = "Altura Segura Cargo",
    Description = "Altura maxima para tentar coletar sem rastrear queda",
    Default     = 80,
    Min         = 20,
    Max         = 500,
    Rounding    = 0,
    Callback    = function(v) SAFE_HEIGHT = tonumber(v) end
})

Tabs.Gold:AddSection("GoldPot")

Tabs.Gold:AddToggle("AutoFarm", {
    Title       = "Auto Farm GoldPot",
    Description = "Teleporta no GoldPot, interage via touch e repete",
    Default     = false,
    Callback    = function(v)
        if v then isFarming = false; startAutoFarm()
        else stopAutoFarm(); stopNoclip(); stopAntiAfk(); stopAntiEscape() end
    end
})

Tabs.Gold:AddToggle("AutoTeleport", {
    Title       = "Auto Teleport GoldPot",
    Description = "Teleporta continuamente no GoldPot",
    Default     = false,
    Callback    = function(v)
        if v then startAutoTp() else stopAutoTp(); stopAntiEscape() end
    end
})

Tabs.Gold:AddButton({
    Title       = "Teleportar no GoldPot Agora",
    Description = "Teleporte unico e imediato no GoldPot",
    Callback    = function()
        safeSetIdentity(6)
        local part = getGoldPart()
        if not part then return end
        local root = getRootPart()
        if not root then return end
        pcall(function() root.CFrame = part.CFrame + Vector3.new(0, 4, 0) end)
    end
})

Tabs.Gold:AddSection("CarePackages")

Tabs.Gold:AddToggle("RageMode", {
    Title       = "Rage Mode Prompt",
    Description = "MaxActivationDistance 10000 e sem LineOfSight no ProximityPrompt",
    Default     = false,
    Callback    = function(v) isRageMode = v end
})

Tabs.Gold:AddToggle("AutoCargo", {
    Title       = "Auto Farm Cargo",
    Description = "Rastreia queda do Cargo e coleta sem morrer",
    Default     = false,
    Callback    = function(v)
        if v then isCargoFarming = false; startCargoFarm()
        else stopCargoFarm(); stopNoclip(); stopAntiAfk(); stopAntiEscape() end
    end
})


-- // Dados
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local v_u_player = Players.LocalPlayer

local autoPromptConn = nil
local selectedDice = nil
local promptSpeed = 0.05
local detectRange = 99999
local autoPromptEnabled = false
local autoTpEnabled = false

if setthreadidentity then setthreadidentity(6) end

local G = getgenv and getgenv() or _G
G._EntropyState = G._EntropyState or { diceCache = {}, watchActive = false }
local State = G._EntropyState

local function safeClone(obj)
    if not cloneref then return obj end
    local ok, result = pcall(cloneref, obj)
    if ok and result then return result end
    return obj
end

local function getRootPart()
    local char = v_u_player.Character
    if char then return char:FindFirstChild("HumanoidRootPart") end
    return nil
end

local function getEntropyCubesFolder()
    local direct = Workspace:FindFirstChild("EntropyCubes")
    if direct then return direct end
    if getinstances then
        local ok, all = pcall(getinstances)
        if ok then
            for _, inst in ipairs(all) do
                local ok1, name = pcall(function() return inst.Name end)
                local ok2, cls = pcall(function() return inst.ClassName end)
                if ok1 and ok2 and name == "EntropyCubes" and cls == "Folder" then
                    return inst
                end
            end
        end
    end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name == "EntropyCubes" and obj:IsA("Folder") then return obj end
    end
    return nil
end

local function getDiceList()
    local list = {}
    local seen = {}
    local folder = getEntropyCubesFolder()
    local candidates = {}

    if folder then
        local ok, children = pcall(function() return folder:GetChildren() end)
        if ok then
            for _, obj in ipairs(children) do
                table.insert(candidates, obj)
            end
        end
    end

    if getinstances then
        local ok, all = pcall(getinstances)
        if ok then
            for _, inst in ipairs(all) do
                local ok1, name = pcall(function() return inst.Name end)
                local ok2, p = pcall(function() return inst.Parent end)
                if ok1 and ok2 and name and p and (name:match("^Dice_") or name:match("^CompanionCube_")) then
                    if p.Name == "EntropyCubes" or p == Workspace then
                        table.insert(candidates, inst)
                    end
                end
            end
        end
    end

    for _, obj in ipairs(candidates) do
        local ok1, parent = pcall(function() return obj.Parent end)
        local ok2, name = pcall(function() return obj.Name end)
        if ok1 and ok2 and parent and name and not seen[name] then
            seen[name] = true
            local hasPrompt = false
            local ok3, descs = pcall(function() return obj:GetDescendants() end)
            if ok3 then
                for _, v in ipairs(descs) do
                    local ok4, vname = pcall(function() return v.Name end)
                    local ok5, isPP = pcall(function() return v:IsA("ProximityPrompt") end)
                    if ok4 and ok5 and (vname == "EntropyCubePrompt" or isPP) then
                        hasPrompt = true
                        break
                    end
                end
            end
            if hasPrompt or name:match("^Dice_") or name:match("^CompanionCube_") then
                table.insert(list, name)
            end
        end
    end

    State.diceCache = list
    return list
end

local function findDice(diceName)
    if not diceName then return nil end
    local folder = getEntropyCubesFolder()
    if folder then
        local ok1, children = pcall(function() return folder:GetChildren() end)
        if ok1 then
            for _, obj in ipairs(children) do
                local ok2, name = pcall(function() return obj.Name end)
                if ok2 and name == diceName then return safeClone(obj) end
            end
        end
        local ok3, descs = pcall(function() return folder:GetDescendants() end)
        if ok3 then
            for _, obj in ipairs(descs) do
                local ok4, name = pcall(function() return obj.Name end)
                if ok4 and name == diceName then return safeClone(obj) end
            end
        end
    end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        local ok, name = pcall(function() return obj.Name end)
        if ok and name == diceName then return safeClone(obj) end
    end
    if getinstances then
        local ok, all = pcall(getinstances)
        if ok then
            for _, inst in ipairs(all) do
                local ok2, name = pcall(function() return inst.Name end)
                if ok2 and name == diceName then return safeClone(inst) end
            end
        end
    end
    return nil
end

local function getPrompt(dice)
    if not dice then return nil end
    local ok, descs = pcall(function() return dice:GetDescendants() end)
    if not ok then return nil end
    for _, v in ipairs(descs) do
        local ok1, vname = pcall(function() return v.Name end)
        local ok2, isPP = pcall(function() return v:IsA("ProximityPrompt") end)
        if ok1 and ok2 and vname == "EntropyCubePrompt" and isPP then return v end
    end
    for _, v in ipairs(descs) do
        local ok1, isPP = pcall(function() return v:IsA("ProximityPrompt") end)
        if ok1 and isPP then return v end
    end
    return nil
end

local function boostPrompt(prompt)
    if not prompt then return end
    pcall(function() prompt.MaxActivationDistance = detectRange end)
    pcall(function() prompt.HoldDuration = 0 end)
    pcall(function() prompt.RequiresLineOfSight = false end)
    if sethiddenproperty then
        pcall(sethiddenproperty, prompt, "MaxActivationDistance", detectRange)
        pcall(sethiddenproperty, prompt, "RequiresLineOfSight", false)
        pcall(sethiddenproperty, prompt, "HoldDuration", 0)
    end
    if setscriptable then
        pcall(setscriptable, prompt, "MaxActivationDistance", true)
    end
    if setrenderproperty then
        pcall(setrenderproperty, prompt, "HoldDuration", 0)
    end
end

local function doFirePrompt(prompt)
    if not prompt then return end
    if setthreadidentity then pcall(setthreadidentity, 6) end
    local ok = pcall(fireproximityprompt, prompt)
    if not ok and firesignal and getconnections then
        pcall(function()
            local conns = getconnections(prompt.Triggered)
            if conns then
                for _, c in ipairs(conns) do
                    pcall(function() c:Fire() end)
                end
            end
        end)
    end
end

local function stopAutoPrompt()
    if autoPromptConn then autoPromptConn:Disconnect(); autoPromptConn = nil end
    autoPromptEnabled = false
end

local function stopAutoTp()
    autoTpEnabled = false
end

local function getPartFromDice(dice)
    if not dice then return nil end
    local ok1, isBP = pcall(function() return dice:IsA("BasePart") end)
    if ok1 and isBP then return dice end
    local ok2, found = pcall(function() return dice:FindFirstChildWhichIsA("BasePart", true) end)
    if ok2 then return found end
    return nil
end

local function startAutoPrompt()
    stopAutoPrompt()
    autoPromptEnabled = true
    local lastFire = 0
    local lastTp = 0
    local tpInterval = 0.5

    autoPromptConn = RunService.Heartbeat:Connect(function()
        if not autoPromptEnabled then return end
        if not selectedDice then return end

        local now = tick()

        pcall(function()
            local root = getRootPart()
            if not root then return end

            local dice = findDice(selectedDice)
            if not dice then return end

            local part = getPartFromDice(dice)

            if part then
                local okPos, partPos = pcall(function() return part.Position end)
                local okRoot, rootPos = pcall(function() return root.Position end)

                if okPos and okRoot then
                    local dist = (rootPos - partPos).Magnitude
                    if dist > 3 and now - lastTp >= tpInterval then
                        lastTp = now
                        pcall(function()
                            root.CFrame = part.CFrame + Vector3.new(0, 3, 0)
                        end)
                    end
                end
            end

            if now - lastFire >= promptSpeed then
                lastFire = now
                local prompt = getPrompt(dice)
                if prompt then
                    boostPrompt(prompt)
                    doFirePrompt(prompt)
                end
            end
        end)
    end)
end

local diceDropdown = Tabs.Dice:AddDropdown("DiceSelect", {
    Title = "Escolher Dado",
    Description = "Detectado em tempo real da pasta EntropyCubes",
    Values = {"Nenhum dado"},
    Default = "Nenhum dado",
    Callback = function(v)
        if v == "Nenhum dado" then
            selectedDice = nil
            return
        end
        selectedDice = v
    end
})

Tabs.Dice:AddToggle("AutoPrompt", {
    Title = "Auto Prompt",
    Description = "Gruda no dado e aperta o prompt. Se sumir, aguarda e retoma automatico",
    Default = false,
    Callback = function(v)
        if v then
            autoPromptEnabled = true
            if selectedDice then
                startAutoPrompt()
            end
        else
            stopAutoPrompt()
        end
    end
})

Tabs.Dice:AddToggle("AutoTeleport", {
    Title = "Auto Teleport",
    Description = "Fica grudado no dado continuamente",
    Default = false,
    Callback = function(v)
        autoTpEnabled = v
    end
})

Tabs.Dice:AddSlider("PromptSpeed", {
    Title = "Velocidade do Prompt",
    Description = "Menor = mais rapido",
    Default = 5,
    Min = 1,
    Max = 20,
    Rounding = 0,
    Callback = function(v)
        promptSpeed = tonumber(v) / 100
    end
})

Tabs.Dice:AddSlider("DetectRange", {
    Title = "Range do Prompt",
    Description = "Distancia maxima para ativar o prompt",
    Default = 9999,
    Min = 10,
    Max = 9999,
    Rounding = 0,
    Callback = function(v)
        detectRange = tonumber(v)
    end
})

task.spawn(function()
    repeat task.wait(0.5) until v_u_player.Character

    v_u_player.CharacterRemoving:Connect(function()
        stopAutoPrompt()
        stopAutoTp()
        autoPromptEnabled = false
        autoTpEnabled = false
    end)

    v_u_player.CharacterAdded:Connect(function()
        task.wait(1)
        if setthreadidentity then pcall(setthreadidentity, 6) end
    end)

    local function watchFolder(folder)
        if State.watchActive then return end
        State.watchActive = true
        pcall(function()
            folder.DescendantAdded:Connect(function(inst)
                local ok1, isPP = pcall(function() return inst:IsA("ProximityPrompt") end)
                local ok2, name = pcall(function() return inst.Name end)
                if (ok1 and isPP) or (ok2 and name == "EntropyCubePrompt") then
                    boostPrompt(inst)
                end
            end)
        end)
        pcall(function()
            folder.DescendantRemoving:Connect(function(inst)
                local ok, name = pcall(function() return inst.Name end)
                if ok and name == selectedDice then
                    selectedDice = nil
                    if autoPromptConn then
                        autoPromptConn:Disconnect()
                        autoPromptConn = nil
                    end
                end
            end)
        end)
    end

    local lastListStr = ""

    while true do
        task.wait(1)

        local ok, diceList = pcall(getDiceList)
        if not ok then diceList = {} end

        local listStr = table.concat(diceList, ",")
        local listChanged = listStr ~= lastListStr

        if listChanged then
            lastListStr = listStr

            if #diceList > 0 then
                for _, name in ipairs(diceList) do
                    pcall(function()
                        local dice = findDice(name)
                        if dice then
                            local prompt = getPrompt(dice)
                            if prompt then boostPrompt(prompt) end
                        end
                    end)
                end

                pcall(function() diceDropdown:SetValues(diceList) end)

                if not selectedDice or not table.find(diceList, selectedDice) then
                    selectedDice = diceList[1]
                    pcall(function() diceDropdown:SetValue(diceList[1]) end)
                end

                if autoPromptEnabled and not autoPromptConn then
                    startAutoPrompt()
                end
            else
                pcall(function() diceDropdown:SetValues({"Nenhum dado"}) end)
                pcall(function() diceDropdown:SetValue("Nenhum dado") end)

                if autoPromptConn then
                    autoPromptConn:Disconnect()
                    autoPromptConn = nil
                end
                selectedDice = nil
            end
        end

        if not listChanged and #diceList > 0 then
            if autoPromptEnabled and not autoPromptConn and selectedDice then
                startAutoPrompt()
            end
        end

        if autoTpEnabled and selectedDice then
            pcall(function()
                local dice = findDice(selectedDice)
                if not dice then return end
                local part = getPartFromDice(dice)
                local root = getRootPart()
                if part and root then
                    local okPos, partPos = pcall(function() return part.Position end)
                    local okRoot, rootPos = pcall(function() return root.Position end)
                    if okPos and okRoot and (rootPos - partPos).Magnitude > 3 then
                        pcall(function() root.CFrame = part.CFrame + Vector3.new(0, 3, 0) end)
                    end
                end
            end)
        end

        local folder = getEntropyCubesFolder()
        if folder and not State.watchActive then
            watchFolder(folder)
        end

        if selectedDice then
            pcall(function()
                local dice = findDice(selectedDice)
                if dice then
                    local prompt = getPrompt(dice)
                    if prompt then boostPrompt(prompt) end
                end
            end)
        end
    end
end)

-- // SaveManager
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("MynexHub")
SaveManager:SetFolder("MynexHubGames/Settings")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
Window:SelectTab(1)

Fluent:Notify({
    Title = "Mynex Hub ",
    Content = "V1.0.0",
    Duration = 8
})

SaveManager:LoadAutoloadConfig()
