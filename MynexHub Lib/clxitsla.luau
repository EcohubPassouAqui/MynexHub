local setthreadidentity = setthreadidentity or syn and syn.set_thread_identity
if setthreadidentity then pcall(setthreadidentity, 8) end

local Notifications = loadstring(game:HttpGet(
	"https://raw.githubusercontent.com/EcohubPassouAqui/EcoHub/refs/heads/main/Notifications/EcoHub.lua"
))()
local Notify = Notifications.Notify

local HttpService = game:GetService("HttpService")

local placeId = game.PlaceId
local gameName = "game_" .. placeId
pcall(function()
	local info = game:GetService("MarketplaceService"):GetProductInfoAsync(placeId)
	if info and info.Name then
		gameName = info.Name:gsub('[<>:"/\\|?*%z%c]', "_"):sub(1, 60)
	end
end)

local ROOT    = gameName
local SCRIPTS = ROOT .. "/Scripts"
local REMOTES = ROOT .. "/Remotes"
local INFO    = ROOT .. "/Info"

for _, f in ipairs({ROOT, SCRIPTS, REMOTES, INFO}) do
	if not isfolder(f) then makefolder(f) end
end

local mt = getrawmetatable(game)
local oldNC, oldIdx

pcall(function()
	setreadonly(mt, false)
	oldNC = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
		if not checkcaller() then
			local m = getnamecallmethod()
			if m == "Kick" or m == "Ban" or m == "Shutdown" then
				return nil
			end
		end
		return oldNC(self, ...)
	end))
	oldIdx = hookmetamethod(game, "__index", newcclosure(function(self, k)
		return oldIdx(self, k)
	end))
	setreadonly(mt, true)
end)

local function restore()
	pcall(function()
		setreadonly(getrawmetatable(game), false)
		if oldNC then hookmetamethod(game, "__namecall", oldNC) end
		if oldIdx then hookmetamethod(game, "__index", oldIdx) end
		setreadonly(getrawmetatable(game), true)
	end)
end

local b64encode = base64_encode or function(data)
	local b = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	return ((data:gsub(".", function(x)
		local r, byte = "", x:byte()
		for i = 8, 1, -1 do
			r = r .. (byte % 2^i - byte % 2^(i-1) > 0 and "1" or "0")
		end
		return r
	end) .. "0000"):gsub("%d%d%d?%d?%d?%d?", function(x)
		if #x < 6 then return "" end
		local c = 0
		for i = 1, 6 do
			c = c + (x:sub(i,i) == "1" and 2^(6-i) or 0)
		end
		return b:sub(c+1, c+1)
	end) .. ({"", "==", "="})[#data % 3 + 1])
end

local lastRequest = 0
local apiCache = {}
local apiSuccess = 0
local apiFailed = 0

local function decompileAPI(bc)
	local encoded = b64encode(bc)

	if apiCache[encoded] then
		return apiCache[encoded], "api_cached"
	end

	local elapsed = os.clock() - lastRequest
	if elapsed < 0.6 then
		task.wait(0.6 - elapsed)
	end

	local ok, res = pcall(request, {
		Url    = "https://api.lua.expert/decompile",
		Method = "POST",
		Headers = {["content-type"] = "application/json"},
		Body   = HttpService:JSONEncode({script = encoded}),
	})

	lastRequest = os.clock()

	if not ok or not res or res.StatusCode ~= 200 then
		apiFailed = apiFailed + 1
		return nil
	end

	local src = res.Body
	if not src or src == "" or src:find("error", 1, true) then
		apiFailed = apiFailed + 1
		return nil
	end

	apiCache[encoded] = src
	apiSuccess = apiSuccess + 1
	return src, "api_v9"
end

local function san(s)
	return tostring(s):gsub('[<>:"/\\|?*%z%c]', "_"):sub(1, 80)
end

local function buildpath(obj)
	local t = {}
	local c = obj
	while c and c ~= game do
		table.insert(t, 1, san(c.Name))
		c = c.Parent
	end
	return table.concat(t, "/")
end

local function getext(s)
	if s.ClassName == "LocalScript" then return ".client.lua" end
	if s.ClassName == "ModuleScript" then return ".lua" end
	return ".server.lua"
end

local function mkdirs(base, fpath)
	local parts = string.split(fpath, "/")
	local cur = base
	for i = 1, #parts - 1 do
		cur = cur .. "/" .. parts[i]
		if not isfolder(cur) then makefolder(cur) end
	end
end

local function getbc(script)
	local ok, bc = pcall(getscriptbytecode, script)
	if not ok or not bc or bc == "" then return nil end
	return bc
end

local function extractstrings(bc)
	local result, seen, cur = {}, {}, ""
	for i = 1, #bc do
		local b = string.byte(bc, i)
		if b >= 32 and b <= 126 then
			cur = cur .. string.char(b)
		else
			if #cur >= 3 and not seen[cur] then
				seen[cur] = true
				table.insert(result, cur)
			end
			cur = ""
		end
	end
	if #cur >= 3 and not seen[cur] then
		table.insert(result, cur)
	end
	return result
end

local function trydecompile(script, bc)
	local ver = string.byte(bc, 1)

	local ok1, src1 = pcall(decompile, script)
	if ok1 and src1 and src1 ~= ""
		and not src1:find("Unsupported")
		and not src1:find("decompiler error")
		and not src1:find("failed") then
		return src1, "local_direct", ver
	end

	local ok2, cl = pcall(getscriptclosure, script)
	if ok2 and cl then
		local ok3, src2 = pcall(decompile, cl)
		if ok3 and src2 and src2 ~= ""
			and not src2:find("Unsupported")
			and not src2:find("error") then
			return src2, "local_closure", ver
		end
	end

	local ok4, env = pcall(getsenv, script)
	if ok4 and env then
		for _, v in pairs(env) do
			if type(v) == "function" then
				local ok5, src3 = pcall(decompile, v)
				if ok5 and src3 and src3 ~= ""
					and not src3:find("Unsupported")
					and not src3:find("error") then
					return src3, "local_senv", ver
				end
			end
		end
	end

	local api_src, api_method = decompileAPI(bc)
	if api_src then
		return api_src, api_method, ver
	end

	local strs = extractstrings(bc)
	if #strs > 0 then
		local lines = {"bytecode v" .. ver .. " | strings: " .. #strs, string.rep("-", 40)}
		for _, s in ipairs(strs) do table.insert(lines, s) end
		return table.concat(lines, "\n"), "strings_v" .. ver, ver
	end

	return nil, nil, ver
end

local function scanremotes(src)
	local found, seen = {}, {}
	local pats = {
		":FireServer", ":InvokeServer", ":FireClient",
		":FireAllClients", ".OnServerEvent", ".OnClientEvent",
		".OnServerInvoke", ".OnClientInvoke",
		"RemoteEvent", "RemoteFunction", "UnreliableRemoteEvent",
	}
	for _, p in ipairs(pats) do
		if src:find(p, 1, true) and not seen[p] then
			seen[p] = true
			table.insert(found, p)
		end
	end
	return found
end

local stats = {total=0, decompiled=0, api=0, strings=0, empty=0, versions={}}
local remoteLogs = {}
local scriptList = {}
local scripts = getscripts()
stats.total = #scripts

print("jogo: " .. gameName)
print("scripts: " .. stats.total)

Notify({
	Title = "ScriptDump Iniciado",
	Description = gameName .. " | " .. stats.total .. " scripts",
	Duration = 5,
})

for i, script in ipairs(scripts) do
	pcall(function()
		local fpath = buildpath(script)
		if fpath == "" then return end

		local bc = getbc(script)
		local ver = bc and string.byte(bc, 1) or 0
		local vkey = "v" .. ver

		stats.versions[vkey] = (stats.versions[vkey] or 0) + 1
		table.insert(scriptList, "[" .. vkey .. "] [" .. script.ClassName .. "] " .. script:GetFullName())

		if not bc then
			stats.empty = stats.empty + 1
			return
		end

		if i % 20 == 0 then
			Notify({
				Title = "Progresso",
				Description = i .. "/" .. stats.total
					.. " | API: " .. apiSuccess
					.. " | Local: " .. stats.decompiled,
				Duration = 3,
			})
		end

		local src, method, version = trydecompile(script, bc)

		if src then
			local isStr = method and method:find("strings")
			local isAPI = method and method:find("api")
			local fileExt = isStr and ".txt" or getext(script)
			local filePath = SCRIPTS .. "/" .. fpath .. fileExt

			mkdirs(SCRIPTS, fpath)

			local header = "-- " .. script:GetFullName()
				.. "\n-- " .. script.ClassName
				.. "\n-- bytecode: v" .. (version or ver)
				.. "\n-- metodo: " .. (method or "?")
				.. "\n\n"

			writefile(filePath, header .. src)

			local calls = scanremotes(src)
			if #calls > 0 then
				remoteLogs[script:GetFullName()] = calls
			end

			if isStr then
				stats.strings = stats.strings + 1
				print("strings [" .. vkey .. "] " .. fpath)
			elseif isAPI then
				stats.api = stats.api + 1
				stats.decompiled = stats.decompiled + 1
				print("api [" .. vkey .. "] " .. fpath)
			else
				stats.decompiled = stats.decompiled + 1
				print("ok [" .. vkey .. "] [" .. method .. "] " .. fpath)
			end
		else
			stats.empty = stats.empty + 1
		end
	end)
end

writefile(INFO .. "/scripts.txt", table.concat(scriptList, "\n"))

Notify({
	Title = "Scripts Concluido",
	Description = "Decompilados: " .. stats.decompiled
		.. " (API: " .. stats.api .. ")"
		.. " | Strings: " .. stats.strings
		.. " | Total: " .. stats.total,
	Duration = 8,
})

do
	local classes = {
		"RemoteEvent", "RemoteFunction",
		"UnreliableRemoteEvent", "BindableEvent", "BindableFunction",
	}
	local allLines = {"remotes: " .. gameName .. "\n"}
	local totalRemotes = 0

	for _, class in ipairs(classes) do
		local found = {}
		for _, inst in ipairs(game:GetDescendants()) do
			if inst.ClassName == class then
				table.insert(found, inst:GetFullName())
				totalRemotes = totalRemotes + 1
			end
		end
		if #found > 0 then
			local lines = {class .. " (" .. #found .. ")"}
			for _, p in ipairs(found) do table.insert(lines, "  " .. p) end
			local content = table.concat(lines, "\n")
			writefile(REMOTES .. "/" .. class .. ".txt", content)
			table.insert(allLines, content)
			print(class .. ": " .. #found)
		end
	end

	writefile(REMOTES .. "/todos.txt", table.concat(allLines, "\n\n"))

	if next(remoteLogs) then
		local lines = {"calls detectados em scripts\n"}
		for path, calls in pairs(remoteLogs) do
			table.insert(lines, path)
			for _, c in ipairs(calls) do table.insert(lines, "  " .. c) end
			table.insert(lines, "")
		end
		writefile(REMOTES .. "/calls.txt", table.concat(lines, "\n"))
	end

	Notify({
		Title = "Remotes",
		Description = "Total: " .. totalRemotes .. " remotes encontrados",
		Duration = 5,
	})
end

do
	local vlist = {}
	local dominant, max = "nenhum", 0
	for v, count in pairs(stats.versions) do
		table.insert(vlist, v .. ": " .. count)
		if count > max then max = count dominant = v end
	end
	table.sort(vlist)

	local report = "jogo: " .. gameName
		.. "\nplaceid: " .. placeId
		.. "\nversao dominante: " .. dominant
		.. "\n\n" .. table.concat(vlist, "\n")
		.. "\n\ndecompilados: " .. stats.decompiled
		.. "\n  via api: " .. stats.api
		.. "\n  via local: " .. (stats.decompiled - stats.api)
		.. "\nstrings: " .. stats.strings
		.. "\nfazios: " .. stats.empty
		.. "\ntotal: " .. stats.total
		.. "\n\napi requests: " .. apiSuccess
		.. "\napi falhas: " .. apiFailed

	writefile(ROOT .. "/report.txt", report)
	print("\n" .. report)
end

restore()

Notify({
	Title = "Concluido",
	Description = "Pasta: " .. gameName
		.. " | API: " .. stats.api
		.. " | Local: " .. (stats.decompiled - stats.api)
		.. " | Total: " .. stats.total,
	Duration = 10,
})
