# MYNEX LIB TERMINAL ( MODE BY ECO HUB )
```
local terminal = loadstring(game:HttpGet("https://pastebin.com/raw/z3uYzH0Q"))()

terminal.custom_print({
    message = "Sistema iniciado com sucesso",
    color = Color3.fromRGB(0, 255, 0)
})

terminal.custom_print({
    message = "Aviso importante",
    image = "rbxassetid://123456789",
    color = Color3.fromRGB(255, 165, 0)
})

terminal.custom_print("Mensagem simples", "", Color3.fromRGB(255, 255, 255))

local log = terminal.custom_print({
    message = "Processando dados",
    color = Color3.fromRGB(0, 200, 255)
})

task.wait(2)

log.update_message({
    message = "Dados processados com sucesso",
    color = Color3.fromRGB(0, 255, 0)
})

task.wait(2)
log.cleanup()

local progressbar = terminal.custom_console_progressbar({
    msg = "Carregando items",
    color = Color3.fromRGB(255, 255, 0),
    length = 10
})

for i = 0, 25, 5 do
    progressbar.update_progress(i)
    task.wait(0.5)
end

progressbar.cleanup()

local progressbar2 = terminal.custom_console_progressbar({
    msg = "Baixando arquivos",
    color = Color3.fromRGB(0, 255, 255),
    image = "rbxassetid://987654321"
})

for i = 0, 25 do
    progressbar2.update_progress(i)
    task.wait(0.1)
end

progressbar2.update_message_with_progress("Download completo", 25)
task.wait(2)
progressbar2.cleanup()

local log2 = terminal.custom_print({
    message = "Item coletado: Battery",
    color = Color3.fromRGB(255, 255, 0)
})

task.wait(1)

log2.update_message({
    message = "Item coletado: Flashlight",
    color = Color3.fromRGB(0, 255, 255),
    update_timestamp = true
})

task.wait(1)

log2.update_message("Item coletado: Camera", "", Color3.fromRGB(255, 0, 255), true)

task.wait(2)
log2.cleanup()

terminal.custom_print({
    message = "ERRO CRITICO NO SISTEMA",
    color = Color3.fromRGB(255, 0, 0)
})

terminal.custom_print({
    message = "Sistema finalizado",
    color = Color3.fromRGB(128, 128, 128)
})
```
