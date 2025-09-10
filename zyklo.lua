--[[ -------------------------------------------------
    Zyklo hub - Fixed & Enhanced ESP
    ------------------------------------------------- ]]
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Stats = game:GetService("Stats")
local StarterGui = game:GetService("StarterGui")
local localPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- >> [MODIFICADO] Caché para estadísticas de mascotas para evitar recálculos.
-- Se usa una tabla débil para prevenir fugas de memoria.
local statsCache = setmetatable({}, {__mode = "k"})

-- >> [MODIFICADO] Centralización de IDs de assets para fácil mantenimiento.
local ASSETS = {
    BRAND_LOGO = "rbxassetid://116553067824026",
    MINIMIZE_ICON = "rbxassetid://110574729016386",
    EXPAND_ICON = "rbxassetid://137817849385475",
    CLOSE_ICON = "rbxassetid://71175513861523",
    SEARCH_ICON = "rbxassetid://86260290442059",
    MAIN_ICON = "rbxassetid://126824018085646",
    FINDER_ICON = "rbxassetid://138747379236071",
    HELPER_ICON = "rbxassetid://127952337220041",
    PLAYER_ICON = "rbxassetid://108687066722354",
    STEALER_ICON = "rbxassetid://124049568380938",
    SERVER_JOINER_ICON = "rbxassetid://126623774280529",
    SETTINGS_ICON = "rbxassetid://102670975114034"
}

-- Webhook URLs for different value tiers
local WEBHOOKS = {
    TEN_MILLION_PLUS = "https://discord.com/api/webhooks/1411174226878005271/BhdfM1aLBV0Go-TKZZsRyk4lpcciJN4tOdS2bp0i7dPDd74JfjRHkjtnwBQxmx-QBNNt",
    FIVE_MILLION_PLUS = "https://discord.com/api/webhooks/1411181526401683528/jW57_g-8L2jVBo0mRm9LrSqS3nc045hXPyhDMe6MX2iB0U4FhJSpK9HOuWcNMwjMXP5H",
    ONE_MILLION_PLUS = "https://discord.com/api/webhooks/1411181070912585830/Ib1e-S4lw8XWxwFJjV_AfpKczqTRojQxTVbuYUotft_wdQrFtQL827_LG08FrGl_4GFV",
    UNDER_ONE_MILLION = "https://discord.com/api/webhooks/1411181708178493523/95P0uZ7CVFAbUKV6IhUE9GLCPqndjTEjCvQSFK7cuTnn8g_0O88PakWbVmBEpp5aXxh0"
}
local reportedPetsThisSession = {}

-- >> [MODIFICADO] El tema ahora usa colores rojos
local THEMES = {
    Dark = {
        bg = Color3.fromRGB(18, 12, 14),
        panel = Color3.fromRGB(24, 16, 18),
        panel2 = Color3.fromRGB(30, 22, 24),
        text = Color3.fromRGB(240, 230, 235),
        textDim = Color3.fromRGB(186, 170, 176),
        accentA = Color3.fromRGB(255, 64, 64), -- Rojo primario
        accentB = Color3.fromRGB(204, 0, 0),   -- Rojo secundario
        btn = Color3.fromRGB(36, 28, 30),
        btnHover = Color3.fromRGB(46, 36, 38),
        btnActive = Color3.fromRGB(56, 42, 44),
        gold = Color3.fromRGB(255, 215, 0),
        success = Color3.fromRGB(40, 167, 69),
        successHover = Color3.fromRGB(60, 187, 89),
        scrollBar = Color3.fromRGB(96, 80, 84),
        dragBase = Color3.fromRGB(218, 210, 214),
        dragBright = Color3.fromRGB(250, 245, 248),
        sidebarActive = Color3.fromRGB(46, 35, 38),
        sidebarHighlight = Color3.fromRGB(255, 64, 64) -- Rojo para la línea
    }
    -- Se omite el tema Light ya que no se usa y simplifica el código
}

local currentTheme = "Dark"
local THEME = THEMES[currentTheme]

-- Brainrot dictionary (sin cambios)
local brainrotDict = {
    ['Cocofanto Elefanto'] = { rarity = 'Brainrot God', dps = 10000 },
    ['Coco Elefanto'] = { rarity = 'Brainrot God', dps = 10000 },
    ['Girafa Celestre'] = { rarity = 'Brainrot God', dps = 20000 },
    ['Gattatino Neonino'] = { rarity = 'Brainrot God', dps = 35000 },
    ['Gattatino Nyanino'] = { rarity = 'Brainrot God', dps = 35000 },
    ['Matteo'] = { rarity = 'Brainrot God', dps = 50000 },
    ['Tralalero Tralala'] = { rarity = 'Brainrot God', dps = 50000 },
    ['Los Crocodillitos'] = { rarity = 'Brainrot God', dps = 55000 },
    ['Tigroligre Frutonni'] = { rarity = 'Brainrot God', dps = 60000 },
    ['Trigoligre Frutonni'] = { rarity = 'Brainrot God', dps = 60000 },
    ['Tipi Topi Taco'] = { rarity = 'Brainrot God', dps = 74900 },
    ['Unclito Samito'] = { rarity = 'Brainrot God', dps = 75000 },
    ['Odin Din Din Dun'] = { rarity = 'Brainrot God', dps = 75000 },
    ['Espresso Signora'] = { rarity = 'Brainrot God', dps = 75000 },
    ['Statutino Libertino'] = { rarity = 'Brainrot God', dps = 75000 },
    ['Trenostruzzo Turbo 3000'] = { rarity = 'Brainrot God', dps = 75000 },
    ['Alessio'] = { rarity = 'Brainrot God', dps = 85000 },
    ['Tralalita Tralala'] = { rarity = 'Brainrot God', dps = 100000 },
    ['Tukanno Bananno'] = { rarity = 'Brainrot God', dps = 100000 },
    ['Orcalero Orcala'] = { rarity = 'Brainrot God', dps = 100000 },
    ['Pakrahmatmamat'] = { rarity = 'Brainrot God', dps = 145000 },
    ['Urubini Flamenguini'] = { rarity = 'Brainrot God', dps = 150000 },
    ['Brr es Teh Patipum'] = { rarity = 'Brainrot God', dps = 150000 },
    ['Trippi Troppi Troppa Trippa'] = { rarity = 'Brainrot God', dps = 175000 },
    ['Ballerino Lololo'] = { rarity = 'Brainrot God', dps = 200000 },
    ['Bulbito Bandito Traktorito'] = { rarity = 'Brainrot God', dps = 205000 },
    ['Los TungTungTungCitos'] = { rarity = 'Brainrot God', dps = 210000 },
    ['Los Tungtungtungcitos'] = { rarity = 'Brainrot God', dps = 210000 },
    ['Los Bombinitos'] = { rarity = 'Brainrot God', dps = 220000 },
    ['Piccione Macchina'] = { rarity = 'Brainrot God', dps = 225000 },
    ['Bombardini Tortinii'] = { rarity = 'Brainrot God', dps = 225000 },
    ['Los Orcalitos'] = { rarity = 'Brainrot God', dps = 235000 },
    ['Tartaruga Cisterna'] = { rarity = 'Brainrot God', dps = 250000 },
    ['Brainrot God Lucky Block'] = { rarity = 'Brainrot God', dps = 0 },
    ['Tigroligre Frutonni (Lucky)'] = { rarity = 'Brainrot God', dps = 60000 },
    ['La Vacca Saturno Saturnita'] = { rarity = 'Secret', dps = 250000 },
    ['La Vacca Staturno Saturnita'] = { rarity = 'Secret', dps = 250000 },
    ['Karkerkar Kurkur'] = { rarity = 'Secret', dps = 275000 },
    ['Sammyni Spyderini'] = { rarity = 'Secret', dps = 300000 },
    ['Chimpanzini Spiderini'] = { rarity = 'Secret', dps = 325000 },
    ['Torrtuginni Dragonfrutini'] = { rarity = 'Secret', dps = 350000 },
    ['Tortuginni Dragonfruitini'] = { rarity = 'Secret', dps = 350000 },
    ['Agarrini La Palini'] = { rarity = 'Secret', dps = 425000 },
    ['Los Tralaleritos'] = { rarity = 'Secret', dps = 500000 },
    ['Las Tralaleritas'] = { rarity = 'Secret', dps = 650000 },
    ['Job Job Job Sahur (New)'] = { rarity = 'Secret', dps = 700000 },
    ['Las Vaquitas Saturnitas'] = { rarity = 'Secret', dps = 750000 },
    ['Graipusseni Medussini'] = { rarity = 'Secret', dps = 1000000 },
    ['Graipuss Medussi'] = { rarity = 'Secret', dps = 1000000 },
    ['Pot Hotspot'] = { rarity = 'Secret', dps = 2500000 },
    ['Chicleteira Bicicleteira'] = { rarity = 'Secret', dps = 3500000 },
    ['La Grande Combinasion'] = { rarity = 'Secret', dps = 10000000 },
    ['La Grande Combinassion'] = { rarity = 'Secret', dps = 10000000 },
    ['Nuclearo Dinossauro'] = { rarity = 'Secret', dps = 15000000 },
    ['Los Combinasionas'] = { rarity = 'Secret', dps = 15000000 },
    ['Los Hotspotsitos'] = { rarity = 'Secret', dps = 25000000 },
    ['Esok Sekolah'] = { rarity = 'Secret', dps = 30000000 },
    ['Garama And Mandundung'] = { rarity = 'Secret', dps = 50000000 },
    ['Garama And Madundung'] = { rarity = 'Secret', dps = 50000000 },
    ['Dragon Cannelloni'] = { rarity = 'Secret', dps = 100000000 },
    ['Secret Lucky Block'] = { rarity = 'Secret', dps = 0 }
}

-- Multiplicadores (sin cambios)
local mutationMultipliers = {
    Gold = 1.25, Diamond = 1.5, Rainbow = 10, Lava = 6, Bloodrot = 2,
    Celestial = 4, Candy = 4, Galaxy = 6
}
local traitMultipliers = {
    Taco = 2.5, ["Nyan Cat"] = 3, Glitch = 5, Rain = 2.5, Snow = 3, Starfall = 3.5,
    ["Golden Shine"] = 6, Galactic = 4, Explosive = 4, Bubblegum = 4, Zombie = 5,
    Glitched = 5, Claws = 5, Fireworks = 6, Nyan = 6, Fire = 5, Wet = 2.5, Snowy = 3,
    Cometstruck = 3.5, Disco = 5, ["La Vacca Saturno Saturnita"] = 4, Bombardiro = 4,
    ["Raining Tacos"] = 3, ["Tung Tung Attack"] = 4, ["Crab Rave"] = 5, ["4th of July"] = 6,
    ["Nyan Cats"] = 6, Concert = 5, ["10B"] = 3, Shark = 3, Matteo = 5, Brazil = 6,
    UFO = 3, Sleepy = 3
}

-- Configuración y estado
local SETTINGS_FILE = "ZykloHub_Settings.json"
local settings = {
    autoLoad = false, autoSave = false, speedHackEnabled = false, speedHackValue = 1.5,
    flyHackEnabled = false, highJumpEnabled = false, highJumpValue = 60,
    playerESPEnabled = false, hotbarESPEnabled = false, instaBrainrotEnabled = false,
    baseTimerESPEnabled = false, itemESPEnabled = false,
    -- mostExpensiveOnly ya no es una opción, es por defecto.
    betterGraphicsEnabled = false, infJumpEnabled = false, freezerKillerEnabled = false,
    antiMedusaEnabled = false, autoMedusaCounterEnabled = false, serverInfoEnabled = false,
    activeFunctionsEnabled = false, keybindsEnabled = false, killAllEnabled = false, keybinds = {}
}

-- Variables de estado
local playerESPEnabled = false
local hotbarESPEnabled = false
local instaBrainrotEnabled = false
local baseTimerESPEnabled = false
local itemESPEnabled = false
local betterGraphicsEnabled = false
local infJumpEnabled = false
local freezerKillerEnabled = false
local antiMedusaEnabled = false
local autoMedusaCounterEnabled = false
local serverInfoEnabled = false
local activeFunctionsEnabled = false
local keybindsEnabled = false
local killAllEnabled = false
local freezerKillerConnection = nil
local killAllConnection = nil
local antiMedusaDebounce = false
local activeConnections = {} -- >> [NUEVO] Para gestionar y limpiar conexiones

-- Elementos visuales
local secretVisuals = {}
local itemVisuals = {}
local playerHighlights = {}
local playerEsps = {}
local playerUpdateConns = {}
local hotbarGuis = {}

-- Estado de la UI
local isMinimized = false
local isExpanded = false
local savedPreMinimizeSize = nil
local savedPreExpandSize = nil
local savedNormalSize = nil

-- Elementos UI (declaraciones)
local mainGui, rootFrame, minimizeBtn, expandBtn, closeBtn, sidebar, contentHost,
mainPanel, helperPanel, playerPanel, bfPanel, stealerPanel, serverJoinerPanel, settingsPanel,
speedRow, flyHackRow, jumpRow, playerESPRow, hotbarESPRow, baseTimerESPRow, itemESPRow,
instaBrainrotRow, betterGraphicsRow, infJumpRow, freezerKillerRow, antiMedusaRow,
autoMedusaCounterRow, killAllRow, autoLoadRow, autoSaveRow, serverInfoRow, activeFunctionsRow,
keybindsRow, toggleMap, brandContainer, serverInfoGui, activeFunctionsGui, keybindsGui, flyButtonGui
toggleMap = {}

-- Variables de movimiento
local HighJump = { Enabled = false, JumpPower = 50 }
local Character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local camera = workspace.CurrentCamera
local characterConnections = {}

-- Configuración de Speed/Fly
local ITEM_NAME = "Grapple Hook"
local USE_ITEM_ARG = 2
local GROUND_SPEED = 30
local SPEED_MULTIPLIER = settings.speedHackValue
local FLY_SPEED = 150
local GODMODE_HEALTH = 100
local FLY_KEY = Enum.KeyCode.F
local lastEquippedTime = 0
local GRACE_PERIOD_DURATION = 3.0

local useItemRemote
pcall(function()
    useItemRemote = ReplicatedStorage:WaitForChild("Packages", 9e9):WaitForChild("Net", 9e9):WaitForChild("RE/UseItem", 9e9)
end)

local movementActive = false
local movementConnection = nil
local speedActive = false
local flyActive = false
local flying = false
local mouseLook = false
local godmodeActive = false
local healthConnection
local keysDown = {}

-- Auto Medusa Counter
local MEDUSA_TOOL_NAME = "Medusa's Head"
local MEDUSA_DETECTION_RADIUS = 13
local MEDUSA_REACT_COOLDOWN = 0.35
local MEDUSA_POST_USE_COOLDOWN = 25
local MEDUSA_DOUBLE_ACTIVATE_DELAY = 0.03
local medusaLastReactTime = 0
local medusaReacting = false
local medusaLongCooldownUntil = 0

-- Buscador de Brainrot
local BACKEND_URL = 'https://brainrotss.up.railway.app/brainrots'
local autoJoinMode = nil
local searchActive = false
local searchTarget = nil
local moneyFilter = 0
local filterDropdownOpen = false
local joinedServers = {}
local joinAttemptCount = 0
local secretBtn, godBtn, searchBox, searchToggle, filterBtn, dropdownFrame, scroll

-- Funciones de ayuda (sin cambios)
local function clean(str) return tostring(str or ""):gsub("%+", ""):gsub("^%s(.-)%s*$", "%1") end
local function toTitleCase(s) return (s:gsub("(%a)([%w_']*)", function(first, rest) return first:upper() .. rest:lower() end)) end
local function parseMoney(moneyStr)
    if not moneyStr or moneyStr == "TBA" then return 0 end
    moneyStr = clean(moneyStr)
    local num, suffix = moneyStr:match("^%$?([%d%.]+)([MKBT]?)")
    if not num then return 0 end
    num = tonumber(num)
    if not num then return 0 end
    if suffix == "B" then return num * 1e9
    elseif suffix == "M" then return num * 1e6
    elseif suffix == "K" then return num * 1e3
    elseif suffix == "T" then return num * 1e12
    else return num end
end
local function formatMoney(num)
    if num == 0 then return "TBA" end
    if num >= 1e9 then return string.format("$%.1fB", num / 1e9)
    elseif num >= 1e6 then return string.format("$%.1fM", num / 1e6)
    elseif num >= 1e3 then return string.format("$%.0fK", num / 1e3)
    else return "$" .. tostring(num) end
end

-- Funciones de guardado (sin cambios)
local function saveSettings()
    pcall(function() if writefile then writefile(SETTINGS_FILE, HttpService:JSONEncode(settings)) end end)
end
local function loadSettings()
    local success, data = pcall(function()
        if readfile and isfile and isfile(SETTINGS_FILE) then
            return HttpService:JSONDecode(readfile(SETTINGS_FILE))
        end
    end)
    if success and type(data) == "table" then
        for k,v in pairs(data) do settings[k] = v end
        return settings
    end
    return nil
end

-- Funciones de cálculo (sin cambios estructurales)
local function getMutationAndTraits(model)
    local mutation, traits
    pcall(function() mutation = model:GetAttribute("Mutation") end)
    if not mutation then local v = model:FindFirstChild("Mutation") if v and v:IsA("StringValue") then mutation = v.Value end end
    pcall(function() if model:GetAttribute("Traits") then traits = model:GetAttribute("Traits") elseif model:GetAttribute("Trait") then traits = { model:GetAttribute("Trait") } end end)
    if not traits then local t = model:FindFirstChild("Traits") or model:FindFirstChild("TraitsFolder") if t and t:IsA("Folder") then traits = {} for _, v in ipairs(t:GetChildren()) do if v:IsA("StringValue") then table.insert(traits, v.Value) end end end end
    if type(traits) == "string" then traits = { traits } end
    return mutation, traits
end
local function calculateMultiplier(mutation, traits)
    local multipliers, N = {}, 0
    if mutation and mutationMultipliers[mutation] then table.insert(multipliers, mutationMultipliers[mutation]); N = N + 1 else table.insert(multipliers, 1); N = N + 1 end
    if traits then for _, trait in ipairs(traits) do if traitMultipliers[trait] then table.insert(multipliers, traitMultipliers[trait]); N = N + 1 end end end
    if N == 0 then return 1 end
    local sum = 0
    for _, mult in ipairs(multipliers) do sum = sum + mult end
    local total = sum - (N - 1)
    return total < 1 and 1 or total
end

-- >> [MODIFICADO] Funciones de cálculo con caché
local function _calculateBrainrotStats_internal(model)
    local baseDPS = brainrotDict[model.Name] and brainrotDict[model.Name].dps or 0
    local baseMoney = baseDPS
    local mutation, traits = getMutationAndTraits(model)
    local multiplier = calculateMultiplier(mutation, traits)
    local finalMoneyPerSec = baseMoney * multiplier
    return finalMoneyPerSec, multiplier, mutation or "None", traits or {}
end
function calculateBrainrotStats(model)
    if statsCache[model] then return unpack(statsCache[model]) end
    local finalMoneyPerSec, multiplier, mutation, traits = _calculateBrainrotStats_internal(model)
    statsCache[model] = {finalMoneyPerSec, multiplier, mutation, traits}
    return finalMoneyPerSec, multiplier, mutation, traits
end

-- Funciones visuales (ESP)
local function cleanupVisuals(visualTable, model)
    if not visualTable[model] then return end
    for _, visual in pairs(visualTable[model]) do
        if visual and visual.Parent then pcall(function() visual:Destroy() end) end
    end
    visualTable[model] = nil
end

-- >> [MODIFICADO] Colores del ESP cambiados a rojo
local function createSecretVisuals(model)
    if secretVisuals[model] then return end
    local root = model:FindFirstChild("RootPart")
    if not root then return end
    local visuals = {}
    local hl = Instance.new("Highlight")
    hl.FillColor = THEME.accentA
    hl.OutlineColor = THEME.accentB
    hl.FillTransparency = 0.35
    hl.OutlineTransparency = 0.1
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = model
    visuals.hl = hl
    local bp = Instance.new("BillboardGui")
    bp.Name = "ESPName"
    bp.Size = UDim2.new(0, 280, 0, 50)
    bp.AlwaysOnTop = true
    bp.Adornee = root
    bp.StudsOffset = Vector3.new(0, 4, 0)
    bp.Parent = model
    visuals.esp = bp
    local bgFrame = Instance.new("Frame", bp)
    bgFrame.Size = UDim2.new(1, 0, 1, 0)
    bgFrame.BackgroundColor3 = THEME.panel2
    bgFrame.BackgroundTransparency = 0.15
    bgFrame.BorderSizePixel = 0
    Instance.new("UICorner", bgFrame).CornerRadius = UDim.new(0, 6)
    local bgStroke = Instance.new("UIStroke", bgFrame)
    bgStroke.Color = THEME.accentA
    bgStroke.Thickness = 1
    bgStroke.Transparency = 0.1
    bgStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    local label = Instance.new("TextLabel", bgFrame)
    label.Size = UDim2.new(1, -10, 1, -10)
    label.Position = UDim2.new(0, 5, 0, 5)
    label.BackgroundTransparency = 1
    label.TextColor3 = THEME.text
    label.TextStrokeTransparency = 0.6
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    local updateConn
    updateConn = RunService.RenderStepped:Connect(function()
        if not model or not model.Parent or not root or not root.Parent then
            if updateConn then updateConn:Disconnect() end
            return
        end
        local hum = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
        local dist = hum and (hum.Position - root.Position).Magnitude or 0
        local moneyPerSec, _, _, _ = calculateBrainrotStats(model)
        local rarity = brainrotDict[model.Name] and brainrotDict[model.Name].rarity or "?"
        label.Text = string.format("%s (%s)\n[%.1fm] | %s/s", toTitleCase(model.Name), rarity, dist, formatMoney(moneyPerSec))
        bp.StudsOffset = Vector3.new(0, math.clamp(4 + (dist / 25), 4, 12), 0)
    end)
    visuals.updateConn = updateConn
    local att0 = Instance.new("Attachment")
    att0.Name = "CharAttach"
    att0.Parent = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") or workspace.Terrain
    visuals.att0 = att0
    local att1 = Instance.new("Attachment", root)
    att1.Name = "TargetAttach"
    visuals.att1 = att1
    local beam = Instance.new("Beam", root)
    beam.Name = "ESPTracer"
    beam.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, THEME.accentA), ColorSequenceKeypoint.new(1, THEME.accentB)})
    beam.Width0, beam.Width1 = 0.2, 0.1
    beam.FaceCamera = true
    beam.Transparency = NumberSequence.new(0.35)
    beam.Attachment0, beam.Attachment1 = att0, att1
    visuals.tracer = beam
    local tracerUpdateConn
    tracerUpdateConn = RunService.RenderStepped:Connect(function()
        if not model or not model.Parent or not att0 or not att0.Parent then
            if tracerUpdateConn then tracerUpdateConn:Disconnect() end
            return
        end
        local newHum = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
        if newHum and att0.Parent ~= newHum then
            att0.Parent = newHum
        end
    end)
    visuals.tracerUpdateConn = tracerUpdateConn
    secretVisuals[model] = visuals
end

-- >> [MODIFICADO] Función de ESP ahora solo busca el más caro
local function updateBrainrotESP()
    local currentModels = {}
    local allFoundBrainrots = {}

    for _, instance in ipairs(workspace:GetDescendants()) do
        if instance:IsA("Model") and instance:FindFirstChild("RootPart") and brainrotDict[instance.Name] then
            local data = brainrotDict[instance.Name]
            if data.rarity == "Secret" or data.rarity == "Brainrot God" then
                table.insert(allFoundBrainrots, instance)
            end
        end
    end

    local bestModel, maxMoney = nil, -1
    for _, model in ipairs(allFoundBrainrots) do
        local moneyPerSec, _, _, _ = calculateBrainrotStats(model)
        if moneyPerSec > maxMoney then
            maxMoney = moneyPerSec
            bestModel = model
        end
    end
    if bestModel then
        currentModels[bestModel] = true
    end

    for model, _ in pairs(secretVisuals) do
        if not currentModels[model] or not model.Parent then
            cleanupVisuals(secretVisuals, model)
        end
    end
    for model, _ in pairs(currentModels) do
        if not secretVisuals[model] then
            createSecretVisuals(model)
        end
    end
end

-- El resto de las funciones (ESP de ítems, jugadores, etc.) permanecen igual...
-- ...hasta llegar a startInstaBrainrot...

-- >> [MODIFICADO] Insta Brainrot optimizado
local function startInstaBrainrot()
    task.spawn(function()
        while true do
            if instaBrainrotEnabled and mainGui and mainGui.Parent then
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("ProximityPrompt") then
                        v.HoldDuration = 0
                        v:InputHoldBegin()
                        v:InputHoldEnd()
                    end
                end
            end
            task.wait(0.1)
        end
    end)
end

-- ...el resto de las funciones hasta la UI...

-- >> [NUEVA FUNCIÓN DE AYUDA] para la UI
local function createPanelHeader(parent, text, iconAsset)
    local header = Instance.new("Frame", parent)
    header.Size, header.Position, header.BackgroundTransparency = UDim2.new(0,220,0,36), UDim2.new(0,10,0,10), 1
    local icon = Instance.new("ImageLabel", header)
    icon.Size, icon.Position, icon.BackgroundTransparency, icon.Image, icon.ImageColor3 = UDim2.new(0,24,0,24), UDim2.new(0,0,0.5,-12), 1, iconAsset, Color3.fromRGB(248,250,255)
    local label = Instance.new("TextLabel", header)
    label.Size, label.Position, label.BackgroundTransparency, label.Text, label.TextColor3, label.TextSize, label.Font, label.TextXAlignment = UDim2.new(1,-30,1,0), UDim2.new(0,30,0,0), 1, text, Color3.fromRGB(248,250,255), 22, Enum.Font.GothamBlack, Enum.TextXAlignment.Left
    return header
end

-- >> [MODIFICADO] Keybind Setter optimizado
local keybindSetterFrame = nil
local keybindInputConnection = nil
local function createKeybindSetter(id, titleText, position)
    if not keybindSetterFrame then
        keybindSetterFrame = Instance.new("Frame")
        keybindSetterFrame.Name = "KeybindSetter"
        keybindSetterFrame.Size = UDim2.new(0, 250, 0, 120)
        keybindSetterFrame.BackgroundColor3 = THEME.panel2
        keybindSetterFrame.ZIndex = 100
        Instance.new("UICorner", keybindSetterFrame).CornerRadius = UDim.new(0, 10)
        local stroke = Instance.new("UIStroke", keybindSetterFrame)
        stroke.Color = THEME.accentA -- Color rojo
        local title = Instance.new("TextLabel", keybindSetterFrame)
        title.Name = "Title"; title.Size = UDim2.new(1, -20, 0, 30); title.Position = UDim2.new(0, 10, 0, 5); title.BackgroundTransparency = 1; title.TextColor3 = THEME.text; title.Font = Enum.Font.GothamBold; title.TextSize = 14
        local prompt = Instance.new("TextLabel", keybindSetterFrame)
        prompt.Name = "Prompt"; prompt.Size = UDim2.new(1, -20, 0, 30); prompt.Position = UDim2.new(0, 10, 0, 35); prompt.BackgroundTransparency = 1; prompt.TextColor3 = THEME.textDim; prompt.Font = Enum.Font.Gotham; prompt.TextSize = 13
        local clearBtn = Instance.new("TextButton", keybindSetterFrame)
        clearBtn.Name = "ClearButton"; clearBtn.Size = UDim2.new(1, -20, 0, 30); clearBtn.Position = UDim2.new(0, 10, 0, 75); clearBtn.BackgroundColor3 = THEME.btnActive; clearBtn.TextColor3 = THEME.text; clearBtn.Text = "Clear Keybind"; clearBtn.Font = Enum.Font.GothamBold; clearBtn.TextSize = 14; clearBtn.ZIndex = 101
        Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0, 6)
    end
    local frame = keybindSetterFrame
    frame.Position = UDim2.new(0, position.X, 0, position.Y)
    frame.Parent = mainGui
    local title = frame.Title
    local prompt = frame.Prompt
    local clearBtn = frame.ClearButton
    title.Text = "Set Keybind for: " .. titleText
    prompt.Text = "Press any key... (ESC to cancel)"
    if keybindInputConnection and keybindInputConnection.Connected then keybindInputConnection:Disconnect() end
    local function closePopup()
        if keybindInputConnection and keybindInputConnection.Connected then keybindInputConnection:Disconnect() end
        if frame and frame.Parent then frame.Parent = nil end
    end
    clearBtn.Activated:Connect(function()
        settings.keybinds[id] = nil
        prompt.Text = "Keybind Cleared."
        if settings.autoSave then saveSettings() end
        task.wait(0.5); closePopup()
    end)
    keybindInputConnection = UserInputService.InputBegan:Connect(function(input, gp)
        if input.KeyCode == Enum.KeyCode.Escape then prompt.Text = "Cancelled."; task.wait(0.2); closePopup(); return end
        if gp then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            settings.keybinds[id] = input.KeyCode.Name
            prompt.Text = "Set to: " .. input.KeyCode.Name
            if settings.autoSave then saveSettings() end
            task.wait(0.5); closePopup()
        end
    end)
end

-- ...el resto de las funciones de la UI hasta createUI...

-- >> [MODIFICADO] createUI totalmente reestructurado y con el nuevo tema
function createUI()
    mainGui = Instance.new("ScreenGui")
    mainGui.Name = "ZykloHub"
    mainGui.ResetOnSpawn = false
    mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    mainGui.Parent = localPlayer:WaitForChild("PlayerGui")
    local loadSound = Instance.new("Sound", mainGui)
    loadSound.SoundId = "rbxassetid://84596244576386"
    loadSound:Play()
    loadSound.Ended:Connect(function() loadSound:Destroy() end)
    local guiWidth, guiHeight = 580, 340
    savedNormalSize = UDim2.new(0, guiWidth, 0, guiHeight)
    rootFrame = Instance.new("Frame")
    rootFrame.Name = "Root"
    rootFrame.Size = UDim2.new(0, guiWidth, 0, guiHeight)
    rootFrame.Position = UDim2.new(0.5, -guiWidth / 2, 0.5, -guiHeight / 2)
    rootFrame.BackgroundColor3 = THEME.bg
    rootFrame.BackgroundTransparency = 0.02
    rootFrame.BorderSizePixel = 0
    rootFrame.Active = true
    rootFrame.Draggable = true
    rootFrame.ZIndex = 1
    rootFrame.Parent = mainGui
    Instance.new("UICorner", rootFrame).CornerRadius = UDim.new(0, 14)
    local rootStroke = Instance.new("UIStroke", rootFrame)
    rootStroke.Color = THEME.accentA; rootStroke.Transparency = 0.8; rootStroke.Thickness = 1.5
    local brandLogo = Instance.new("ImageLabel", rootFrame)
    brandLogo.Name = "BrandLogo"
    brandLogo.Size = UDim2.new(0, 24, 0, 24)
    brandLogo.Position = UDim2.new(0, 12, 0, 10)
    brandLogo.BackgroundTransparency = 1
    brandLogo.Image = ASSETS.BRAND_LOGO
    brandLogo.ScaleType = Enum.ScaleType.Fit
    brandLogo.ZIndex = 2
    brandContainer = Instance.new("Frame", rootFrame)
    brandContainer.Name = "BrandContainer"
    brandContainer.Size = UDim2.new(0, 200, 0, 32)
    brandContainer.Position = UDim2.new(0, 42, 0, 8)
    brandContainer.BackgroundTransparency = 1
    brandContainer.ZIndex = 2
    local brandTitlePrimary = Instance.new("TextLabel", brandContainer)
    brandTitlePrimary.Name = "BrandTitle"
    brandTitlePrimary.Size = UDim2.new(1, 0, 0, 17)
    brandTitlePrimary.BackgroundTransparency = 1
    brandTitlePrimary.Text = "Zyklo hub"
    brandTitlePrimary.TextColor3 = THEME.text
    brandTitlePrimary.TextSize = 17
    brandTitlePrimary.Font = Enum.Font.GothamBold
    brandTitlePrimary.TextXAlignment = Enum.TextXAlignment.Left
    brandTitlePrimary.ZIndex = 2
    local brandSubtitle = Instance.new("TextLabel", brandContainer)
    brandSubtitle.Name = "BrandSubtitle"
    brandSubtitle.Size = UDim2.new(1, 0, 0, 13)
    brandSubtitle.Position = UDim2.new(0, 0, 0, 17)
    brandSubtitle.BackgroundTransparency = 1
    brandSubtitle.Text = "Premium"
    brandSubtitle.TextColor3 = THEME.textDim
    brandSubtitle.TextSize = 11
    brandSubtitle.Font = Enum.Font.GothamSemibold
    brandSubtitle.TextXAlignment = Enum.TextXAlignment.Left
    brandSubtitle.ZIndex = 2
    minimizeBtn = Instance.new("ImageButton", rootFrame)
    minimizeBtn.Name = "Minimize"; minimizeBtn.Size = UDim2.new(0, 20, 0, 20); minimizeBtn.Position = UDim2.new(1, -100, 0, 8); minimizeBtn.BackgroundTransparency = 1; minimizeBtn.Image = ASSETS.MINIMIZE_ICON; minimizeBtn.ImageColor3 = THEME.textDim; minimizeBtn.ScaleType = Enum.ScaleType.Fit; minimizeBtn.ZIndex = 2
    expandBtn = Instance.new("ImageButton", rootFrame)
    expandBtn.Name = "Expand"; expandBtn.Size = UDim2.new(0, 20, 0, 20); expandBtn.Position = UDim2.new(1, -70, 0, 8); expandBtn.BackgroundTransparency = 1; expandBtn.Image = ASSETS.EXPAND_ICON; expandBtn.ImageColor3 = THEME.textDim; expandBtn.ScaleType = Enum.ScaleType.Fit; expandBtn.ZIndex = 2
    closeBtn = Instance.new("ImageButton", rootFrame)
    closeBtn.Name = "Close"; closeBtn.Size = UDim2.new(0, 20, 0, 20); closeBtn.Position = UDim2.new(1, -40, 0, 8); closeBtn.BackgroundTransparency = 1; closeBtn.Image = ASSETS.CLOSE_ICON; closeBtn.ImageColor3 = THEME.textDim; closeBtn.ScaleType = Enum.ScaleType.Fit; closeBtn.ZIndex = 2
    closeBtn.Activated:Connect(function() mainGui:Destroy() end)
    minimizeBtn.Activated:Connect(toggleMinimize)
    expandBtn.Activated:Connect(toggleExpand)
    
    local topPadding, sidebarWidth = 44, 160
    sidebar = Instance.new("Frame", rootFrame); sidebar.Name = "Sidebar"; sidebar.Size = UDim2.new(0, sidebarWidth, 1, -topPadding - 14); sidebar.Position = UDim2.new(0, 10, 0, topPadding); sidebar.BackgroundColor3 = THEME.panel; sidebar.BackgroundTransparency = 0.06; sidebar.ZIndex = 2; Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 10)
    local sectionsContainer = Instance.new("ScrollingFrame", sidebar); sectionsContainer.Name = "Sections"; sectionsContainer.Size = UDim2.new(1, -14, 1, -16); sectionsContainer.Position = UDim2.new(0, 7, 0, 8); sectionsContainer.BackgroundTransparency = 1; sectionsContainer.BorderSizePixel = 0; sectionsContainer.ScrollBarThickness = 6; sectionsContainer.ScrollBarImageColor3 = THEME.scrollBar; sectionsContainer.ZIndex = 3
    local sectionsLayout = Instance.new("UIListLayout", sectionsContainer); sectionsLayout.Padding = UDim.new(0, 8)
    sectionsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() sectionsContainer.CanvasSize = UDim2.new(0, 0, 0, sectionsLayout.AbsoluteContentSize.Y) end)
    
    contentHost = Instance.new("Frame", rootFrame); contentHost.Name = "ContentHost"; contentHost.Size = UDim2.new(1, -sidebarWidth - 30, 1, -topPadding - 20); contentHost.Position = UDim2.new(0, sidebarWidth + 20, 0, topPadding + 2); contentHost.BackgroundColor3 = THEME.panel; contentHost.BackgroundTransparency = 0.06; contentHost.ZIndex = 2; Instance.new("UICorner", contentHost).CornerRadius = UDim.new(0, 10)
    mainPanel = Instance.new("Frame", contentHost); mainPanel.Name = "MainPanel"; mainPanel.Size = UDim2.new(1, -10, 1, -10); mainPanel.Position = UDim2.new(0, 5, 0, 5); mainPanel.BackgroundColor3 = THEME.panel2; mainPanel.BackgroundTransparency = 0.06; mainPanel.Visible = true; mainPanel.ZIndex = 3; Instance.new("UICorner", mainPanel).CornerRadius = UDim.new(0, 10)
    helperPanel = Instance.new("Frame", contentHost); helperPanel.Name = "HelperPanel"; helperPanel.Size = UDim2.new(1, -10, 1, -10); helperPanel.Position = UDim2.new(0, 5, 0, 5); helperPanel.BackgroundColor3 = THEME.panel2; helperPanel.BackgroundTransparency = 0.06; helperPanel.Visible = false; helperPanel.ZIndex = 3; Instance.new("UICorner", helperPanel).CornerRadius = UDim.new(0, 10)
    playerPanel = Instance.new("Frame", contentHost); playerPanel.Name = "PlayerPanel"; playerPanel.Size = UDim2.new(1, -10, 1, -10); playerPanel.Position = UDim2.new(0, 5, 0, 5); playerPanel.BackgroundColor3 = THEME.panel2; playerPanel.BackgroundTransparency = 0.06; playerPanel.Visible = false; playerPanel.ZIndex = 3; Instance.new("UICorner", playerPanel).CornerRadius = UDim.new(0, 10)
    bfPanel = Instance.new("Frame", contentHost); bfPanel.Name = "BrainrotFinderPanel"; bfPanel.Size = UDim2.new(1, -10, 1, -10); bfPanel.Position = UDim2.new(0, 5, 0, 5); bfPanel.BackgroundColor3 = THEME.panel2; bfPanel.BackgroundTransparency = 0.06; bfPanel.Visible = false; bfPanel.ZIndex = 3; Instance.new("UICorner", bfPanel).CornerRadius = UDim.new(0, 10)
    stealerPanel = Instance.new("Frame", contentHost); stealerPanel.Name = "StealerPanel"; stealerPanel.Size = UDim2.new(1, -10, 1, -10); stealerPanel.Position = UDim2.new(0, 5, 0, 5); stealerPanel.BackgroundColor3 = THEME.panel2; stealerPanel.BackgroundTransparency = 0.06; stealerPanel.Visible = false; stealerPanel.ZIndex = 3; Instance.new("UICorner", stealerPanel).CornerRadius = UDim.new(0, 10)
    serverJoinerPanel = Instance.new("Frame", contentHost); serverJoinerPanel.Name = "ServerJoinerPanel"; serverJoinerPanel.Size = UDim2.new(1, -10, 1, -10); serverJoinerPanel.Position = UDim2.new(0, 5, 0, 5); serverJoinerPanel.BackgroundColor3 = THEME.panel2; serverJoinerPanel.BackgroundTransparency = 0.06; serverJoinerPanel.Visible = false; serverJoinerPanel.ZIndex = 3; Instance.new("UICorner", serverJoinerPanel).CornerRadius = UDim.new(0, 10)
    settingsPanel = Instance.new("Frame", contentHost); settingsPanel.Name = "SettingsPanel"; settingsPanel.Size = UDim2.new(1, -10, 1, -10); settingsPanel.Position = UDim2.new(0, 5, 0, 5); settingsPanel.BackgroundColor3 = THEME.panel2; settingsPanel.BackgroundTransparency = 0.06; settingsPanel.Visible = false; settingsPanel.ZIndex = 3; Instance.new("UICorner", settingsPanel).CornerRadius = UDim.new(0, 10)
    
    local mainBtn = makeSectionButton("Main", ASSETS.MAIN_ICON)
    local helperBtn = makeSectionButton("Helper", ASSETS.HELPER_ICON)
    local playerBtn = makeSectionButton("Player", ASSETS.PLAYER_ICON)
    local stealerBtn = makeSectionButton("Stealer", ASSETS.STEALER_ICON)
    local finderBtn = makeSectionButton("Brainrot Finder", ASSETS.FINDER_ICON)
    local serverJoinerBtn = makeSectionButton("Server Joiner", ASSETS.SERVER_JOINER_ICON)
    local settingsBtn = makeSectionButton("Settings", ASSETS.SETTINGS_ICON)

    createPanelHeader(mainPanel, "Main", ASSETS.MAIN_ICON)
    createPanelHeader(playerPanel, "Player", ASSETS.PLAYER_ICON)
    createPanelHeader(helperPanel, "Helper", ASSETS.HELPER_ICON)
    createPanelHeader(stealerPanel, "Stealer", ASSETS.STEALER_ICON)
    createPanelHeader(serverJoinerPanel, "Server Joiner", ASSETS.SERVER_JOINER_ICON)
    createPanelHeader(settingsPanel, "Settings", ASSETS.SETTINGS_ICON)
    
    local mainContainer = Instance.new("ScrollingFrame", mainPanel); mainContainer.Size, mainContainer.Position, mainContainer.BackgroundTransparency = UDim2.new(1,-20,1,-58), UDim2.new(0,10,0,50), 1; mainContainer.BorderSizePixel = 0; mainContainer.ScrollBarThickness = 6; mainContainer.ScrollBarImageColor3 = THEME.scrollBar; local mainLayout = Instance.new("UIListLayout", mainContainer); mainLayout.Padding = UDim.new(0,8); mainLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() mainContainer.CanvasSize = UDim2.new(0,0,0, mainLayout.AbsoluteContentSize.Y) end)
    local helperBody = Instance.new("ScrollingFrame", helperPanel); helperBody.Name = "HelperBody"; helperBody.Size = UDim2.new(1, -20, 1, -58); helperBody.Position = UDim2.new(0, 10, 0, 50); helperBody.BackgroundTransparency = 1; helperBody.BorderSizePixel = 0; helperBody.ScrollBarThickness = 6; helperBody.ScrollBarImageColor3 = THEME.scrollBar; local helperBodyLayout = Instance.new("UIListLayout", helperBody); helperBodyLayout.Padding = UDim.new(0, 10); helperBodyLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() helperBody.CanvasSize = UDim2.new(0, 0, 0, helperBodyLayout.AbsoluteContentSize.Y) end)
    local playerContainer = Instance.new("Frame", playerPanel); playerContainer.Size, playerContainer.Position, playerContainer.BackgroundTransparency = UDim2.new(1,-20,1,-58), UDim2.new(0,10,0,50), 1; Instance.new("UIListLayout", playerContainer).Padding = UDim.new(0,8)
    local stealerBody = Instance.new("Frame", stealerPanel); stealerBody.Size, stealerBody.Position, stealerBody.BackgroundTransparency = UDim2.new(1,-20,1,-58), UDim2.new(0,10,0,50), 1; Instance.new("UIListLayout", stealerBody).Padding = UDim.new(0, 10)
    
    speedRow = makeThinRow(mainContainer, "Speed Hack", "speedHack", 1, 3, settings.speedHackValue, 1, function(v) SPEED_MULTIPLIER = v; settings.speedHackValue = v; if settings.autoSave then saveSettings() end end, settings.speedHackEnabled, function(v) speedActive = v; settings.speedHackEnabled = v; if settings.autoSave then saveSettings() end end)
    flyHackRow = createToggleRow(mainContainer, "Fly Hack", "flyHack", settings.flyHackEnabled, function(v) flyActive = v; settings.flyHackEnabled = v; if settings.autoSave then saveSettings() end; if v then if not isGrappleHookEquipped() and (time() - lastEquippedTime) > GRACE_PERIOD_DURATION then pcall(function() StarterGui:SetCore("SendNotification", { Title = "Zyklo hub", Text = "Please equip the Grapple Hook to use Fly/Speed!", Duration = 5 }) end) end; flying = true; createFlyButtonGUI() else flying = false; destroyFlyButtonGUI() end; updateFlyButtonText() end)
    jumpRow = makeThinRow(mainContainer, "High Jump", "highJump", 50, 130, settings.highJumpValue, 0, function(v) HighJump.JumpPower = v; if HighJump.Enabled and Humanoid then Humanoid.JumpPower = v end; settings.highJumpValue = v; if settings.autoSave then saveSettings() end end, settings.highJumpEnabled, function(v) HighJump.Enabled = v; if Humanoid then Humanoid.UseJumpPower = v; Humanoid.JumpPower = v and HighJump.JumpPower or 50 end; settings.highJumpEnabled = v; if settings.autoSave then saveSettings() end end)
    infJumpRow = createToggleRow(mainContainer, "Infinite Jump", "infJump", settings.infJumpEnabled, function(v) infJumpEnabled = v; settings.infJumpEnabled = v; if settings.autoSave then saveSettings() end end)
    playerESPRow = createToggleRow(helperBody, "Player ESP", "playerESP", settings.playerESPEnabled, function(v) playerESPEnabled = v; settings.playerESPEnabled = v; if settings.autoSave then saveSettings() end; if not v then for _, p in ipairs(Players:GetPlayers()) do removePlayerESP(p) end else updateAllPlayers() end end)
    hotbarESPRow = createToggleRow(helperBody, "Hotbar ESP", "hotbarESP", settings.hotbarESPEnabled, function(v) hotbarESPEnabled = v; settings.hotbarESPEnabled = v; if settings.autoSave then saveSettings() end; if not v then for p in pairs(hotbarGuis) do removeHotbarGuis(p) end else updateAllPlayers() end end)
    baseTimerESPRow = createToggleRow(helperBody, "Base Timer ESP", "baseTimerESP", settings.baseTimerESPEnabled, function(v) baseTimerESPEnabled = v; settings.baseTimerESPEnabled = v; if settings.autoSave then saveSettings() end; updateBaseTimerESP() end)
    itemESPRow = createToggleRow(helperBody, "Item ESP", "itemESP", settings.itemESPEnabled, function(v) itemESPEnabled = v; settings.itemESPEnabled = v; if settings.autoSave then saveSettings() end; updateItemESP() end)
    serverInfoRow = createToggleRow(helperBody, "Server Info", "serverInfo", settings.serverInfoEnabled, function(v) serverInfoEnabled = v; settings.serverInfoEnabled = v; if settings.autoSave then saveSettings() end; if v then createServerInfoGUI() else destroyServerInfoGUI() end end)
    instaBrainrotRow = createToggleRow(playerContainer, "Insta Brainrot Purchase", "instaBrainrot", settings.instaBrainrotEnabled, function(v) instaBrainrotEnabled = v; settings.instaBrainrotEnabled = v; if settings.autoSave then saveSettings() end end)
    betterGraphicsRow = createToggleRow(playerContainer, "Better Graphics", "betterGraphics", settings.betterGraphicsEnabled, function(v) betterGraphicsEnabled = v; settings.betterGraphicsEnabled = v; if settings.autoSave then saveSettings() end; applyBetterGraphics(v) end)
    killAllRow = createToggleRow(playerContainer, "Kill All", "killAll", settings.killAllEnabled, function(v) killAllEnabled = v; settings.killAllEnabled = v; if settings.autoSave then saveSettings() end; if v then startKillAllLoop() else stopKillAllLoop() end end)
    freezerKillerRow = createToggleRow(stealerBody, "Freezer & Killer", "freezerKiller", settings.freezerKillerEnabled, function(v) freezerKillerEnabled = v; settings.freezerKillerEnabled = v; if settings.autoSave then saveSettings() end; if v then startFreezerKiller() else stopFreezerKiller() end end)
    antiMedusaRow = createToggleRow(stealerBody, "Anti Medusa", "antiMedusa", settings.antiMedusaEnabled, function(v) antiMedusaEnabled = v; settings.antiMedusaEnabled = v; if settings.autoSave then saveSettings() end end)
    autoMedusaCounterRow = createToggleRow(stealerBody, "Auto Medusa Counter", "autoMedusaCounter", settings.autoMedusaCounterEnabled, function(v) autoMedusaCounterEnabled = v; settings.autoMedusaCounterEnabled = v; if settings.autoSave then saveSettings() end end)
    
    -- El resto de la UI, como Server Joiner y Buscador, se mantiene pero usa los nuevos colores.
    -- ...
end


-- ...el resto de las funciones (mainLoop, applySettingsManually, etc.) permanecen en su mayoría igual.

-- >> [NUEVO] Función de limpieza
function cleanup()
    stopFreezerKiller()
    stopKillAllLoop()
    applyBetterGraphics(false)
    for _, conn in ipairs(activeConnections) do
        if conn.Connected then conn:Disconnect() end
    end
    -- Limpiar otras GUIs
    destroyServerInfoGUI()
    destroyActiveFunctionsGUI()
    destroyKeybindsGUI()
    destroyFlyButtonGUI()
end

-- >> [MODIFICADO] Bucle principal para usar la función de limpieza
function mainLoop()
    mainGui.Destroying:Connect(cleanup) -- Conectar limpieza al cierre de la GUI

    -- ... el resto de la función mainLoop ...
end

-- Código de inicialización
loadedSettings = loadSettings()
if loadedSettings and loadedSettings.autoLoad then
    settings = loadedSettings
end

createUI()
mainLoop()

if settings.autoLoad then
    task.spawn(function()
        task.wait(1)
        applySettingsManually()
    end)
end

task.spawn(function()
    while task.wait(30) do
        if mainGui and mainGui.Parent then
            scanAndReportBrainrots()
        else
            break
        end
    end
end)

print("Zyklo hub loaded successfully!")
 