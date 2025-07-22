-- ===================================================================
-- MÓDULO DE CAPTURA E DESOBFUSCAÇÃO PARA DELTA EXECUTOR
-- Versão: 2.0 - Otimizado para controle externo
-- Compatível com: Delta Executor e derivados
-- ===================================================================

local CaptureModule = {}
CaptureModule.__index = CaptureModule

-- ===================================================================
-- CONFIGURAÇÕES E VARIÁVEIS PRINCIPAIS
-- ===================================================================

-- Estado do módulo
local moduleState = {
    isActive = false,
    isCapturing = false,
    startTime = 0,
    connections = {},
    captureThread = nil
}

-- Serviços necessários
local services = {
    HttpService = game:GetService("HttpService"),
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    StarterGui = game:GetService("StarterGui"),
    TweenService = game:GetService("TweenService"),
    Lighting = game:GetService("Lighting")
}

-- Configurações padrão (podem ser alteradas externamente)
local CONFIG = {
    maxCaptureTime = 120,
    deepScanInterval = 5,
    duplicateFilter = true,
    autoDecrypt = true,
    captureRemotes = true,
    captureLocalScripts = true,
    captureModuleScripts = true,
    captureConnections = true,
    exportFormat = "detailed",
    enableRealTimeAnalysis = true,
    maxStringLength = 10000,
    advancedDeobfuscation = true,
    autoSave = false,
    debugMode = false
}

-- Armazenamento de dados capturados
local capturedData = {
    scripts = {},
    remotes = {},
    connections = {},
    variables = {},
    functions = {},
    deobfuscated = {},
    patterns = {},
    uniqueHashes = {},
    timeline = {},
    stats = {
        totalScripts = 0,
        totalRemotes = 0,
        totalDeobfuscated = 0,
        totalHooks = 0,
        captureStartTime = 0,
        lastScanTime = 0
    }
}

-- Padrões de obfuscação conhecidos
local obfuscationPatterns = {
    luraph = {
        pattern = "local%s+[%w_]+%s*=%s*{[^}]*}",
        identifier = "luraph",
        complexity = "high"
    },
    psu = {
        pattern = "getfenv%(%)",
        identifier = "psu",
        complexity = "medium"
    },
    ironbrew = {
        pattern = "bit32%.bxor",
        identifier = "ironbrew", 
        complexity = "high"
    },
    synapse = {
        pattern = "syn%.crypt",
        identifier = "synapse",
        complexity = "medium"
    },
    simple = {
        pattern = "local%s+[%w_]+%s*=%s*%d+",
        identifier = "simple_obfuscation",
        complexity = "low"
    },
    string_obfuscation = {
        pattern = "string%.char%([%d%s,]+%)",
        identifier = "string_obfuscation",
        complexity = "low"
    },
    function_obfuscation = {
        pattern = "function%s*%([%w%s,_]*%)%s*local%s+[%w_]+%s*=%s*{",
        identifier = "function_obfuscation",
        complexity = "medium"
    },
    moonscript = {
        pattern = "require%(['\"]moonscript['\"]%)",
        identifier = "moonscript",
        complexity = "medium"
    }
}

-- ===================================================================
-- FUNÇÕES UTILITÁRIAS
-- ===================================================================

local function debugPrint(message)
    if CONFIG.debugMode then
        print("[DEBUG] " .. tostring(message))
    end
end

local function safeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success and CONFIG.debugMode then
        warn("[ERRO] " .. tostring(result))
    end
    return success, result
end

local function generateHash(content)
    local hash = 0
    for i = 1, math.min(#content, 1000) do -- Limita para performance
        hash = hash + string.byte(content, i) * i
    end
    return tostring(hash)
end

local function isAlreadyCaptured(content)
    if not CONFIG.duplicateFilter then return false end
    
    local hash = generateHash(content)
    if capturedData.uniqueHashes[hash] then
        return true
    end
    capturedData.uniqueHashes[hash] = true
    return false
end

-- ===================================================================
-- SISTEMA DE DESOBFUSCAÇÃO AVANÇADO
-- ===================================================================

local function advancedDeobfuscate(code)
    if not CONFIG.advancedDeobfuscation then return code, "none", {} end
    
    local deobfuscated = code
    local changes = {}
    local obfuscationType = "none"
    
    -- Detecta tipo de obfuscação
    for name, pattern in pairs(obfuscationPatterns) do
        if string.find(deobfuscated, pattern.pattern) then
            obfuscationType = pattern.identifier
            debugPrint("Detectado: " .. obfuscationType)
            break
        end
    end
    
    -- Desobfuscação de strings char
    local stringPattern = "string%.char%([%d%s,]+%)"
    deobfuscated = string.gsub(deobfuscated, stringPattern, function(match)
        local numbers = string.gsub(match, "string%.char%(([%d%s,]+)%)", "%1")
        local chars = {}
        for num in string.gmatch(numbers, "%d+") do
            local charCode = tonumber(num)
            if charCode and charCode >= 0 and charCode <= 255 then
                table.insert(chars, string.char(charCode))
            end
        end
        local result = table.concat(chars)
        table.insert(changes, {
            type = "string_deobfuscation",
            original = match,
            deobfuscated = result
        })
        return '"' .. result .. '"'
    end)
    
    -- Desobfuscação de variáveis numéricas
    local numPattern = "local%s+([%w_]+)%s*=%s*(%d+)"
    local variables = {}
    string.gsub(deobfuscated, numPattern, function(varName, value)
        variables[varName] = tonumber(value)
        return nil
    end)
    
    -- Substitui operações matemáticas simples
    for varName, value in pairs(variables) do
        local mathPattern = varName .. "%s*([%+%-%%*/])%s*(%d+)"
        deobfuscated = string.gsub(deobfuscated, mathPattern, function(op, num)
            local n = tonumber(num)
            if not n then return nil end
            
            local result = 0
            if op == "+" then result = value + n
            elseif op == "-" then result = value - n
            elseif op == "*" then result = value * n
            elseif op == "/" and n ~= 0 then result = value / n
            elseif op == "%" and n ~= 0 then result = value % n
            else return nil end
            
            table.insert(changes, {
                type = "math_simplification",
                original = varName .. op .. num,
                result = result
            })
            return tostring(result)
        end)
    end
    
    -- Desobfuscação de arrays de caracteres
    local charArrayPattern = "local%s+([%w_]+)%s*=%s*{([%d%s,]+)}"
    deobfuscated = string.gsub(deobfuscated, charArrayPattern, function(varName, values)
        local chars = {}
        for num in string.gmatch(values, "%d+") do
            local charCode = tonumber(num)
            if charCode and charCode >= 0 and charCode <= 255 then
                table.insert(chars, string.char(charCode))
            end
        end
        local result = table.concat(chars)
        table.insert(changes, {
            type = "char_array_deobfuscation",
            variable = varName,
            original = values,
            deobfuscated = result
        })
        return "local " .. varName .. ' = "' .. result .. '" -- Deobfuscated'
    end)
    
    return deobfuscated, obfuscationType, changes
end

-- ===================================================================
-- SISTEMA DE CAPTURA
-- ===================================================================

local function captureObjectProperties(obj)
    local properties = {}
    
    safeCall(function()
        properties.Name = obj.Name
        properties.ClassName = obj.ClassName
        properties.Parent = obj.Parent and obj.Parent.Name or "nil"
        properties.FullName = obj:GetFullName()
    end)
    
    if obj:IsA("Script") or obj:IsA("LocalScript") then
        safeCall(function()
            properties.Source = obj.Source
            properties.Enabled = obj.Enabled
            if obj.RunContext then
                properties.RunContext = obj.RunContext.Name
            end
        end)
    elseif obj:IsA("ModuleScript") then
        safeCall(function()
            properties.Source = obj.Source
            local success, moduleReturn = pcall(function()
                return require(obj)
            end)
            if success then
                properties.ModuleReturn = tostring(moduleReturn)
                properties.ModuleType = type(moduleReturn)
            end
        end)
    end
    
    return properties
end

local function captureScript(scriptObj)
    if not scriptObj or not scriptObj:IsA("LuaSourceContainer") then return end
    if not moduleState.isCapturing then return end
    
    local success, source = safeCall(function()
        return scriptObj.Source
    end)
    
    if not success or not source or source == "" then return end
    if #source > CONFIG.maxStringLength then
        debugPrint("Script muito grande, truncando: " .. scriptObj.Name)
        source = string.sub(source, 1, CONFIG.maxStringLength) .. "\n-- [TRUNCADO]"
    end
    
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
    capturedData.stats.totalScripts = capturedData.stats.totalScripts + 1
    
    if obfuscationType ~= "none" then
        capturedData.stats.totalDeobfuscated = capturedData.stats.totalDeobfuscated + 1
        capturedData.deobfuscated[scriptObj.Name] = {
            original = source,
            deobfuscated = deobfuscated,
            type = obfuscationType,
            changes = changes,
            timestamp = tick()
        }
    end
    
    table.insert(capturedData.timeline, {
        timestamp = tick(),
        type = "script_captured",
        object = scriptObj.Name,
        size = #source,
        obfuscated = obfuscationType ~= "none"
    })
    
    debugPrint("Script capturado: " .. scriptObj.Name .. " (" .. obfuscationType .. ")")
end

local function captureRemote(remoteObj)
    if not remoteObj or not (remoteObj:IsA("RemoteEvent") or remoteObj:IsA("RemoteFunction")) then return end
    if not moduleState.isCapturing or not CONFIG.captureRemotes then return end
    
    local remoteData = {
        timestamp = tick(),
        name = remoteObj.Name,
        className = remoteObj.ClassName,
        parent = remoteObj.Parent and remoteObj.Parent.Name or "nil",
        path = remoteObj:GetFullName(),
        callHistory = {},
        properties = captureObjectProperties(remoteObj)
    }
    
    -- Monitora chamadas
    if remoteObj:IsA("RemoteEvent") and CONFIG.captureConnections then
        local success, connection = safeCall(function()
            return remoteObj.OnClientEvent:Connect(function(...)
                if not moduleState.isCapturing then return end
                local args = {...}
                table.insert(remoteData.callHistory, {
                    timestamp = tick(),
                    type = "OnClientEvent",
                    args = args,
                    argCount = #args
                })
            end)
        end)
        
        if success and connection then
            table.insert(moduleState.connections, connection)
        end
    end
    
    table.insert(capturedData.remotes, remoteData)
    capturedData.stats.totalRemotes = capturedData.stats.totalRemotes + 1
    
    debugPrint("Remote capturado: " .. remoteObj.Name)
end

local function deepScan(container)
    if not container or not moduleState.isCapturing then return end
    
    local scannedObjects = {}
    
    local function scanRecursive(obj)
        if not moduleState.isCapturing then return end
        if scannedObjects[obj] then return end
        scannedObjects[obj] = true
        
        safeCall(function()
            if obj:IsA("LuaSourceContainer") then
                if (obj:IsA("LocalScript") and CONFIG.captureLocalScripts) or
                   (obj:IsA("ModuleScript") and CONFIG.captureModuleScripts) or
                   obj:IsA("Script") then
                    captureScript(obj)
                end
            elseif (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) and CONFIG.captureRemotes then
                captureRemote(obj)
            end
            
            for _, child in pairs(obj:GetChildren()) do
                scanRecursive(child)
            end
        end)
    end
    
    scanRecursive(container)
    capturedData.stats.lastScanTime = tick()
end

-- ===================================================================
-- API PRINCIPAL DO MÓDULO
-- ===================================================================

-- Inicializa o módulo (chamado automaticamente)
function CaptureModule:Init()
    if moduleState.isActive then
        return false, "Módulo já está ativo"
    end
    
    moduleState.isActive = true
    moduleState.startTime = tick()
    
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
        timeline = {},
        stats = {
            totalScripts = 0,
            totalRemotes = 0,
            totalDeobfuscated = 0,
            totalHooks = 0,
            captureStartTime = tick(),
            lastScanTime = 0
        }
    }
    
    debugPrint("Módulo inicializado com sucesso")
    return true, "Módulo inicializado"
end

-- Inicia a captura
function CaptureModule:StartCapture(options)
    if not moduleState.isActive then
        return false, "Módulo não foi inicializado"
    end
    
    if moduleState.isCapturing then
        return false, "Captura já está ativa"
    end
    
    -- Aplica opções se fornecidas
    if options and type(options) == "table" then
        for key, value in pairs(options) do
            if CONFIG[key] ~= nil then
                CONFIG[key] = value
            end
        end
    end
    
    moduleState.isCapturing = true
    capturedData.stats.captureStartTime = tick()
    
    debugPrint("Iniciando captura...")
    
    -- Scan inicial
    spawn(function()
        deepScan(game)
    end)
    
    -- Configura monitoramento contínuo
    local scanConnection = services.RunService.Heartbeat:Connect(function()
        if not moduleState.isCapturing then return end
        
        if tick() % CONFIG.deepScanInterval < 0.1 then
            spawn(function()
                deepScan(services.ReplicatedStorage)
                deepScan(workspace)
                if services.Players.LocalPlayer then
                    deepScan(services.Players.LocalPlayer)
                end
            end)
        end
    end)
    
    -- Monitora novos objetos
    local addedConnection = game.DescendantAdded:Connect(function(obj)
        if not moduleState.isCapturing then return end
        
        spawn(function()
            if obj:IsA("LuaSourceContainer") then
                captureScript(obj)
            elseif obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                captureRemote(obj)
            end
        end)
    end)
    
    table.insert(moduleState.connections, scanConnection)
    table.insert(moduleState.connections, addedConnection)
    
    -- Auto-stop se configurado
    if CONFIG.maxCaptureTime > 0 then
        spawn(function()
            wait(CONFIG.maxCaptureTime)
            if moduleState.isCapturing then
                CaptureModule:StopCapture()
            end
        end)
    end
    
    debugPrint("Captura iniciada com sucesso")
    return true, "Captura iniciada"
end

-- Para a captura
function CaptureModule:StopCapture()
    if not moduleState.isCapturing then
        return false, "Captura não está ativa"
    end
    
    moduleState.isCapturing = false
    
    -- Limpa todas as conexões
    for _, connection in pairs(moduleState.connections) do
        safeCall(function()
            if connection and connection.Connected then
                connection:Disconnect()
            end
        end)
    end
    moduleState.connections = {}
    
    debugPrint("Captura parada com sucesso")
    return true, "Captura parada"
end

-- Desativa o módulo completamente
function CaptureModule:Shutdown()
    CaptureModule:StopCapture()
    moduleState.isActive = false
    moduleState.startTime = 0
    
    -- Limpa todos os dados
    capturedData = {
        scripts = {},
        remotes = {},
        connections = {},
        variables = {},
        functions = {},
        deobfuscated = {},
        patterns = {},
        uniqueHashes = {},
        timeline = {},
        stats = {
            totalScripts = 0,
            totalRemotes = 0,
            totalDeobfuscated = 0,
            totalHooks = 0,
            captureStartTime = 0,
            lastScanTime = 0
        }
    }
    
    debugPrint("Módulo desativado completamente")
    return true, "Módulo desativado"
end

-- Verifica se está capturando
function CaptureModule:IsCapturing()
    return moduleState.isCapturing
end

-- Verifica se está ativo
function CaptureModule:IsActive()
    return moduleState.isActive
end

-- Obtém dados capturados
function CaptureModule:GetData()
    return {
        scripts = capturedData.scripts,
        remotes = capturedData.remotes,
        deobfuscated = capturedData.deobfuscated,
        timeline = capturedData.timeline,
        stats = capturedData.stats
    }
end

-- Obtém estatísticas resumidas
function CaptureModule:GetStats()
    return {
        isActive = moduleState.isActive,
        isCapturing = moduleState.isCapturing,
        uptime = moduleState.isActive and (tick() - moduleState.startTime) or 0,
        captureTime = moduleState.isCapturing and (tick() - capturedData.stats.captureStartTime) or 0,
        totalScripts = capturedData.stats.totalScripts,
        totalRemotes = capturedData.stats.totalRemotes,
        totalDeobfuscated = capturedData.stats.totalDeobfuscated,
        memoryUsage = math.floor(collectgarbage("count")),
        lastScanTime = capturedData.stats.lastScanTime
    }
end

-- Configura o módulo
function CaptureModule:Configure(newConfig)
    if not newConfig or type(newConfig) ~= "table" then
        return false, "Configuração inválida"
    end
    
    for key, value in pairs(newConfig) do
        if CONFIG[key] ~= nil then
            CONFIG[key] = value
        end
    end
    
    return true, "Configuração atualizada"
end

-- Obtém configuração atual
function CaptureModule:GetConfig()
    return CONFIG
end

-- Desobfuscação manual de código
function CaptureModule:DeobfuscateCode(code)
    if not code or type(code) ~= "string" then
        return nil, "Código inválido"
    end
    
    local deobfuscated, obfuscationType, changes = advancedDeobfuscate(code)
    
    return {
        original = code,
        deobfuscated = deobfuscated,
        obfuscationType = obfuscationType,
        changes = changes,
        timestamp = tick()
    }
end

-- Exporta dados em JSON
function CaptureModule:ExportData(filename)
    local exportData = {
        metadata = {
            timestamp = os.time(),
            captureTime = tick(),
            gameId = game.GameId,
            placeId = game.PlaceId,
            executor = "Delta",
            version = "2.0",
            config = CONFIG
        },
        data = CaptureModule:GetData(),
        stats = CaptureModule:GetStats()
    }
    
    local jsonData = services.HttpService:JSONEncode(exportData)
    
    if filename and writefile then
        local success, err = safeCall(function()
            writefile(filename, jsonData)
        end)
        
        if success then
            return true, "Dados exportados para: " .. filename
        else
            return false, "Erro ao salvar arquivo: " .. tostring(err)
        end
    end
    
    return jsonData
end

-- ===================================================================
-- INICIALIZAÇÃO AUTOMÁTICA
-- ===================================================================

-- Inicializa automaticamente quando carregado
spawn(function()
    local success, message = CaptureModule:Init()
    if success then
        print("🔧 Módulo de Captura Delta carregado com sucesso!")
        print("📋 Use CaptureModule:StartCapture() para iniciar")
        print("🛑 Use CaptureModule:StopCapture() para parar")
        print("📊 Use CaptureModule:GetStats() para estatísticas")
    else
        warn("❌ Erro ao inicializar módulo: " .. message)
    end
end)

return CaptureModule
