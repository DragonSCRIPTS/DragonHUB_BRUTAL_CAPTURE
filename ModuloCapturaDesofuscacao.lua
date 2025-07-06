local CaptureModule = {}

-- Serviços necessários
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

-- Configurações do módulo
local CONFIG = {
    maxCaptureTime = 120, -- 2 minutos de captura máxima
    deepScanInterval = 5, -- Scan profundo a cada 5 segundos
    duplicateFilter = true, -- Filtra duplicatas
    autoDecrypt = true, -- Tenta desencriptar automaticamente
    captureRemotes = true, -- Captura RemoteEvents/Functions
    captureLocalScripts = true, -- Captura LocalScripts
    captureModuleScripts = true, -- Captura ModuleScripts
    captureConnections = true, -- Captura conexões de eventos
    exportFormat = "detailed", -- "simple" ou "detailed"
    enableRealTimeAnalysis = true, -- Análise em tempo real
    maxStringLength = 10000, -- Máximo de caracteres para strings
    advancedDeobfuscation = true, -- Desobfuscação avançada
}

-- Armazenamento inteligente com filtragem de duplicatas
local capturedData = {
    scripts = {},
    remotes = {},
    connections = {},
    variables = {},
    functions = {},
    deobfuscated = {},
    patterns = {},
    uniqueHashes = {}, -- Para evitar duplicatas
    timeline = {} -- Linha do tempo de captura
}

-- Padrões de obfuscação conhecidos
local obfuscationPatterns = {
    -- Padrões comuns de obfuscação
    luraph = {
        pattern = "local%s+[%w_]+%s*=%s*{[^}]*}",
        identifier = "luraph"
    },
    psu = {
        pattern = "getfenv%(%)",
        identifier = "psu"
    },
    ironbrew = {
        pattern = "bit32%.bxor",
        identifier = "ironbrew"
    },
    synapse = {
        pattern = "syn%.crypt",
        identifier = "synapse"
    },
    simple = {
        pattern = "local%s+[%w_]+%s*=%s*%d+",
        identifier = "simple_obfuscation"
    },
    -- Padrões de string obfuscada
    string_obfuscation = {
        pattern = "string%.char%([%d%s,]+%)",
        identifier = "string_obfuscation"
    },
    -- Padrões de função obfuscada
    function_obfuscation = {
        pattern = "function%s*%([%w%s,_]*%)%s*local%s+[%w_]+%s*=%s*{",
        identifier = "function_obfuscation"
    }
}

-- Função para gerar hash único
local function generateHash(content)
    local hash = 0
    for i = 1, #content do
        hash = hash + string.byte(content, i) * i
    end
    return tostring(hash)
end

-- Função para verificar se já foi capturado
local function isAlreadyCaptured(content)
    if not CONFIG.duplicateFilter then return false end
    
    local hash = generateHash(content)
    if capturedData.uniqueHashes[hash] then
        return true
    end
    capturedData.uniqueHashes[hash] = true
    return false
end

-- Função avançada de desobfuscação
local function advancedDeobfuscate(code)
    if not CONFIG.advancedDeobfuscation then return code end
    
    local deobfuscated = code
    local changes = {}
    
    -- Detecta e marca tipo de obfuscação
    local obfuscationType = "none"
    for name, pattern in pairs(obfuscationPatterns) do
        if string.find(deobfuscated, pattern.pattern) then
            obfuscationType = pattern.identifier
            break
        end
    end
    
    -- Desobfuscação de strings
    local stringPattern = "string%.char%([%d%s,]+%)"
    deobfuscated = string.gsub(deobfuscated, stringPattern, function(match)
        local numbers = string.gsub(match, "string%.char%(([%d%s,]+)%)", "%1")
        local chars = {}
        for num in string.gmatch(numbers, "%d+") do
            table.insert(chars, string.char(tonumber(num)))
        end
        local result = table.concat(chars)
        table.insert(changes, {
            type = "string_deobfuscation",
            original = match,
            deobfuscated = result
        })
        return '"' .. result .. '"'
    end)
    
    -- Desobfuscação de variáveis numéricas simples
    local numPattern = "local%s+([%w_]+)%s*=%s*(%d+)"
    deobfuscated = string.gsub(deobfuscated, numPattern, function(varName, value)
        -- Procura por uso da variável em operações matemáticas
        local mathPattern = varName .. "%s*([%+%-%%*/])%s*(%d+)"
        local mathResult = string.gsub(deobfuscated, mathPattern, function(op, num)
            local result = 0
            local val = tonumber(value)
            local n = tonumber(num)
            if op == "+" then result = val + n
            elseif op == "-" then result = val - n
            elseif op == "*" then result = val * n
            elseif op == "/" then result = val / n
            elseif op == "%" then result = val % n
            end
            return tostring(result)
        end)
        return "local " .. varName .. " = " .. value .. " -- Deobfuscated"
    end)
    
    -- Desobfuscação de arrays de caracteres
    local charArrayPattern = "local%s+([%w_]+)%s*=%s*{([%d%s,]+)}"
    deobfuscated = string.gsub(deobfuscated, charArrayPattern, function(varName, values)
        local chars = {}
        for num in string.gmatch(values, "%d+") do
            table.insert(chars, string.char(tonumber(num)))
        end
        local result = table.concat(chars)
        table.insert(changes, {
            type = "char_array_deobfuscation",
            variable = varName,
            original = values,
            deobfuscated = result
        })
        return "local " .. varName .. ' = "' .. result .. '" -- Deobfuscated from char array'
    end)
    
    return deobfuscated, obfuscationType, changes
end

-- Função para capturar propriedades de objetos
local function captureObjectProperties(obj)
    local properties = {}
    
    -- Propriedades básicas
    pcall(function()
        properties.Name = obj.Name
        properties.ClassName = obj.ClassName
        properties.Parent = obj.Parent and obj.Parent.Name or "nil"
    end)
    
    -- Propriedades específicas por tipo
    if obj:IsA("Script") or obj:IsA("LocalScript") then
        pcall(function()
            properties.Source = obj.Source
            properties.Enabled = obj.Enabled
            properties.RunContext = obj.RunContext and obj.RunContext.Name or "Legacy"
        end)
    elseif obj:IsA("ModuleScript") then
        pcall(function()
            properties.Source = obj.Source
            local success, moduleReturn = pcall(function()
                return require(obj)
            end)
            if success then
                properties.ModuleReturn = tostring(moduleReturn)
                properties.ModuleType = type(moduleReturn)
            end
        end)
    elseif obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
        pcall(function()
            properties.RemoteType = obj.ClassName
            -- Tenta capturar argumentos de chamadas
            properties.CallHistory = {}
        end)
    end
    
    return properties
end

-- Função para capturar scripts
local function captureScript(scriptObj)
    if not scriptObj or not scriptObj:IsA("LuaSourceContainer") then return end
    
    local success, source = pcall(function()
        return scriptObj.Source
    end)
    
    if not success or not source or source == "" then return end
    if isAlreadyCaptured(source) then return end
    
    -- Desobfuscação
    local deobfuscated, obfuscationType, changes = advancedDeobfuscate(source)
    
    local scriptData = {
        timestamp = tick(),
        name = scriptObj.Name,
        className = scriptObj.ClassName,
        parent = scriptObj.Parent and scriptObj.Parent.Name or "nil",
        path = scriptObj:GetFullName(),
        source = source,
        deobfuscated = deobfuscated,
        obfuscationType = obfuscationType,
        changes = changes,
        size = #source,
        lines = select(2, string.gsub(source, '\n', '\n')) + 1,
        properties = captureObjectProperties(scriptObj)
    }
    
    table.insert(capturedData.scripts, scriptData)
    table.insert(capturedData.timeline, {
        timestamp = tick(),
        type = "script_captured",
        object = scriptObj.Name,
        size = #source
    })
    
    -- Se foi desobfuscado, adiciona à lista de desobfuscados
    if obfuscationType ~= "none" then
        capturedData.deobfuscated[scriptObj.Name] = {
            original = source,
            deobfuscated = deobfuscated,
            type = obfuscationType,
            changes = changes
        }
    end
end

-- Função para capturar RemoteEvents/Functions
local function captureRemote(remoteObj)
    if not remoteObj or not (remoteObj:IsA("RemoteEvent") or remoteObj:IsA("RemoteFunction")) then return end
    
    local remoteData = {
        timestamp = tick(),
        name = remoteObj.Name,
        className = remoteObj.ClassName,
        parent = remoteObj.Parent and remoteObj.Parent.Name or "nil",
        path = remoteObj:GetFullName(),
        callHistory = {},
        properties = captureObjectProperties(remoteObj)
    }
    
    -- Monitora chamadas para este remote
    if remoteObj:IsA("RemoteEvent") then
        local connection = remoteObj.OnClientEvent:Connect(function(...)
            local args = {...}
            table.insert(remoteData.callHistory, {
                timestamp = tick(),
                type = "OnClientEvent",
                args = args,
                argCount = #args
            })
        end)
        
        -- Guarda a conexão para limpeza posterior
        table.insert(capturedData.connections, connection)
    end
    
    table.insert(capturedData.remotes, remoteData)
end

-- Função para scan profundo em busca de código
local function deepScan(container)
    if not container then return end
    
    local scannedObjects = {}
    
    -- Scan recursivo
    local function scanRecursive(obj)
        if scannedObjects[obj] then return end
        scannedObjects[obj] = true
        
        -- Captura scripts
        if obj:IsA("LuaSourceContainer") then
            captureScript(obj)
        end
        
        -- Captura remotes
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            captureRemote(obj)
        end
        
        -- Verifica filhos
        for _, child in pairs(obj:GetChildren()) do
            scanRecursive(child)
        end
    end
    
    scanRecursive(container)
end

-- Função para capturar variáveis globais
local function captureGlobalVariables()
    local globals = {}
    
    -- Captura variáveis do ambiente global
    for name, value in pairs(getfenv()) do
        if type(value) == "function" then
            globals[name] = {
                type = "function",
                value = tostring(value),
                info = debug.getinfo(value, "S")
            }
        elseif type(value) == "table" then
            globals[name] = {
                type = "table",
                size = #value,
                keys = {}
            }
            -- Captura algumas chaves da tabela
            local keyCount = 0
            for k, v in pairs(value) do
                if keyCount < 10 then -- Limita a 10 chaves
                    globals[name].keys[k] = type(v)
                    keyCount = keyCount + 1
                end
            end
        else
            globals[name] = {
                type = type(value),
                value = tostring(value)
            }
        end
    end
    
    capturedData.variables = globals
end

-- Função para monitorar metamethods
local function monitorMetamethods()
    local mt = getrawmetatable(game)
    if not mt then return end
    
    local metamethods = {}
    
    -- Captura metamethods existentes
    for method, func in pairs(mt) do
        if type(func) == "function" then
            metamethods[method] = {
                type = "metamethod",
                function_info = debug.getinfo(func, "S"),
                source = debug.getinfo(func, "S").source
            }
        end
    end
    
    capturedData.metamethods = metamethods
end

-- Função para detectar hooks
local function detectHooks()
    local hooks = {}
    
    -- Verifica hooks comuns
    local commonFunctions = {
        "print", "warn", "error", "loadstring", "require",
        "game.HttpGet", "game.HttpPost", "readfile", "writefile"
    }
    
    for _, funcName in pairs(commonFunctions) do
        local func = getfenv()[funcName]
        if func and type(func) == "function" then
            local info = debug.getinfo(func, "S")
            if info.source ~= "=[C]" then
                hooks[funcName] = {
                    source = info.source,
                    line = info.linedefined,
                    is_hooked = true
                }
            end
        end
    end
    
    capturedData.hooks = hooks
end

-- Função para exportar dados capturados
local function exportCapturedData()
    local exportData = {
        metadata = {
            timestamp = os.time(),
            captureTime = tick(),
            gameId = game.GameId,
            placeId = game.PlaceId,
            playerId = Players.LocalPlayer.UserId,
            playerName = Players.LocalPlayer.Name,
            totalScripts = #capturedData.scripts,
            totalRemotes = #capturedData.remotes,
            totalDeobfuscated = 0,
            config = CONFIG
        },
        scripts = capturedData.scripts,
        remotes = capturedData.remotes,
        variables = capturedData.variables,
        deobfuscated = capturedData.deobfuscated,
        hooks = capturedData.hooks,
        metamethods = capturedData.metamethods,
        timeline = capturedData.timeline,
        analysis = {
            obfuscation_types = {},
            code_patterns = {},
            security_features = {}
        }
    }
    
    -- Análise dos dados capturados
    for _, scriptData in pairs(capturedData.scripts) do
        if scriptData.obfuscationType ~= "none" then
            exportData.metadata.totalDeobfuscated = exportData.metadata.totalDeobfuscated + 1
            exportData.analysis.obfuscation_types[scriptData.obfuscationType] = 
                (exportData.analysis.obfuscation_types[scriptData.obfuscationType] or 0) + 1
        end
    end
    
    return exportData
end

-- Função principal de captura
function CaptureModule:StartCapture(options)
    options = options or {}
    
    -- Atualiza configurações
    for key, value in pairs(options) do
        if CONFIG[key] ~= nil then
            CONFIG[key] = value
        end
    end
    
    print("🎯 Iniciando captura avançada...")
    print("⚙️ Configurações:", HttpService:JSONEncode(CONFIG))
    
    -- Limpa dados anteriores
    capturedData = {
        scripts = {},
        remotes = {},
        connections = {},
        variables = {},
        functions = {},
        deobfuscated = {},
        patterns = {},
        uniqueHashes = {},
        timeline = {}
    }
    
    -- Captura inicial
    captureGlobalVariables()
    monitorMetamethods()
    detectHooks()
    
    -- Scan profundo inicial
    deepScan(game)
    
    -- Configura monitoramento contínuo
    local scanConnection = RunService.Heartbeat:Connect(function()
        spawn(function()
            -- Scan periódico
            if tick() % CONFIG.deepScanInterval < 0.1 then
                deepScan(ReplicatedStorage)
                deepScan(workspace)
                deepScan(Players.LocalPlayer)
            end
        end)
    end)
    
    -- Monitora novos objetos
    local addedConnection = game.DescendantAdded:Connect(function(obj)
        if obj:IsA("LuaSourceContainer") then
            captureScript(obj)
        elseif obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            captureRemote(obj)
        end
    end)
    
    -- Guarda conexões para limpeza
    table.insert(capturedData.connections, scanConnection)
    table.insert(capturedData.connections, addedConnection)
    
    -- Auto-stop após tempo máximo
    spawn(function()
        wait(CONFIG.maxCaptureTime)
        CaptureModule:StopCapture()
    end)
    
    print("✅ Captura iniciada! Tempo máximo:", CONFIG.maxCaptureTime, "segundos")
    
    return true
end

-- Função para parar captura
function CaptureModule:StopCapture()
    print("🛑 Parando captura...")
    
    -- Limpa todas as conexões
    for _, connection in pairs(capturedData.connections) do
        if connection and connection.Connected then
            connection:Disconnect()
        end
    end
    
    -- Exporta dados
    local exportData = exportCapturedData()
    
    -- Salva arquivo
    local fileName = "roblox_capture_" .. os.time() .. ".json"
    local success, err = pcall(function()
        writefile(fileName, HttpService:JSONEncode(exportData))
    end)
    
    if success then
        print("💾 Dados salvos em:", fileName)
        print("📊 Estatísticas:")
        print("   Scripts capturados:", #capturedData.scripts)
        print("   Remotes capturados:", #capturedData.remotes)
        print("   Códigos desobfuscados:", exportData.metadata.totalDeobfuscated)
        print("   Hooks detectados:", exportData.hooks and #exportData.hooks or 0)
    else
        warn("❌ Erro ao salvar:", err)
    end
    
    return exportData
end

-- Função para obter dados em tempo real
function CaptureModule:GetCapturedData()
    return capturedData
end

-- Função para desobfuscar código manualmente
function CaptureModule:DeobfuscateCode(code)
    if not code or type(code) ~= "string" then return nil end
    
    local deobfuscated, obfuscationType, changes = advancedDeobfuscate(code)
    
    return {
        original = code,
        deobfuscated = deobfuscated,
        obfuscationType = obfuscationType,
        changes = changes
    }
end

-- Função para análise de código
function CaptureModule:AnalyzeCode(code)
    if not code or type(code) ~= "string" then return nil end
    
    local analysis = {
        size = #code,
        lines = select(2, string.gsub(code, '\n', '\n')) + 1,
        functions = {},
        variables = {},
        patterns = {},
        security = {}
    }
    
    -- Detecta funções
    for funcName in string.gmatch(code, "function%s+([%w_]+)%s*%(") do
        table.insert(analysis.functions, funcName)
    end
    
    -- Detecta variáveis
    for varName in string.gmatch(code, "local%s+([%w_]+)%s*=") do
        table.insert(analysis.variables, varName)
    end
    
    -- Detecta padrões de segurança
    local securityPatterns = {
        anticheat = {"anticheat", "anti%-cheat", "cheat.*detect"},
        antiexploit = {"antiexploit", "anti%-exploit", "exploit.*detect"},
        obfuscation = {"obfuscat", "encrypt", "decode", "deobfus"},
        hooks = {"hook", "getrawmetatable", "newcclosure"},
        remotes = {"RemoteEvent", "RemoteFunction", "FireServer", "InvokeServer"}
    }
    
    for category, patterns in pairs(securityPatterns) do
        analysis.security[category] = 0
        for _, pattern in pairs(patterns) do
            local matches = select(2, string.gsub(code:lower(), pattern, ""))
            analysis.security[category] = analysis.security[category] + matches
        end
    end
    
    return analysis
end

-- Função para configurar o módulo
function CaptureModule:Configure(newConfig)
    for key, value in pairs(newConfig) do
        if CONFIG[key] ~= nil then
            CONFIG[key] = value
        end
    end
    return CONFIG
end

-- Função para obter configurações atuais
function CaptureModule:GetConfig()
    return CONFIG
end

-- Função para obter estatísticas
function CaptureModule:GetStats()
    return {
        scriptsCount = #capturedData.scripts,
        remotesCount = #capturedData.remotes,
        deobfuscatedCount = 0, -- Será calculado
        uniqueHashes = 0,
        timelineEvents = #capturedData.timeline,
        memoryUsage = collectgarbage("count")
    }
end

print("🔧 Módulo de Captura e Desencriptação carregado com sucesso!")
print("📋 Métodos disponíveis:")
print("   - StartCapture(options)")
print("   - StopCapture()")
print("   - GetCapturedData()")
print("   - DeobfuscateCode(code)")
print("   - AnalyzeCode(code)")
print("   - Configure(config)")
print("   - GetConfig()")
print("   - GetStats()")

return CaptureModule
