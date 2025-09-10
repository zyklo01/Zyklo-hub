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
}

local currentTheme = "Dark"
local THEME = THEMES[currentTheme]

-- Brainrot dictionary (sin cambios)
local brainrotDict = {['Cocofanto Elefanto']={rarity='Brainrot God',dps=10000},['Coco Elefanto']={rarity='Brainrot God',dps=10000},['Girafa Celestre']={rarity='Brainrot God',dps=20000},['Gattatino Neonino']={rarity='Brainrot God',dps=35000},['Gattatino Nyanino']={rarity='Brainrot God',dps=35000},['Matteo']={rarity='Brainrot God',dps=50000},['Tralalero Tralala']={rarity='Brainrot God',dps=50000},['Los Crocodillitos']={rarity='Brainrot God',dps=55000},['Tigroligre Frutonni']={rarity='Brainrot God',dps=60000},['Trigoligre Frutonni']={rarity='Brainrot God',dps=60000},['Tipi Topi Taco']={rarity='Brainrot God',dps=74900},['Unclito Samito']={rarity='Brainrot God',dps=75000},['Odin Din Din Dun']={rarity='Brainrot God',dps=75000},['Espresso Signora']={rarity='Brainrot God',dps=75000},['Statutino Libertino']={rarity='Brainrot God',dps=75000},['Trenostruzzo Turbo 3000']={rarity='Brainrot God',dps=75000},['Alessio']={rarity='Brainrot God',dps=85000},['Tralalita Tralala']={rarity='Brainrot God',dps=100000},['Tukanno Bananno']={rarity='Brainrot God',dps=100000},['Orcalero Orcala']={rarity='Brainrot God',dps=100000},['Pakrahmatmamat']={rarity='Brainrot God',dps=145000},['Urubini Flamenguini']={rarity='Brainrot God',dps=150000},['Brr es Teh Patipum']={rarity='Brainrot God',dps=150000},['Trippi Troppi Troppa Trippa']={rarity='Brainrot God',dps=175000},['Ballerino Lololo']={rarity='Brainrot God',dps=200000},['Bulbito Bandito Traktorito']={rarity='Brainrot God',dps=205000},['Los TungTungTungCitos']={rarity='Brainrot God',dps=210000},['Los Tungtungtungcitos']={rarity='Brainrot God',dps=210000},['Los Bombinitos']={rarity='Brainrot God',dps=220000},['Piccione Macchina']={rarity='Brainrot God',dps=225000},['Bombardini Tortinii']={rarity='Brainrot God',dps=225000},['Los Orcalitos']={rarity='Brainrot God',dps=235000},['Tartaruga Cisterna']={rarity='Brainrot God',dps=250000},['Brainrot God Lucky Block']={rarity='Brainrot God',dps=0},['Tigroligre Frutonni (Lucky)']={rarity='Brainrot God',dps=60000},['La Vacca Saturno Saturnita']={rarity='Secret',dps=250000},['La Vacca Staturno Saturnita']={rarity='Secret',dps=250000},['Karkerkar Kurkur']={rarity='Secret',dps=275000},['Sammyni Spyderini']={rarity='Secret',dps=300000},['Chimpanzini Spiderini']={rarity='Secret',dps=325000},['Torrtuginni Dragonfrutini']={rarity='Secret',dps=350000},['Tortuginni Dragonfruitini']={rarity='Secret',dps=350000},['Agarrini La Palini']={rarity='Secret',dps=425000},['Los Tralaleritos']={rarity='Secret',dps=500000},['Las Tralaleritas']={rarity='Secret',dps=650000},['Job Job Job Sahur (New)']={rarity='Secret',dps=700000},['Las Vaquitas Saturnitas']={rarity='Secret',dps=750000},['Graipusseni Medussini']={rarity='Secret',dps=1000000},['Graipuss Medussi']={rarity='Secret',dps=1000000},['Pot Hotspot']={rarity='Secret',dps=2500000},['Chicleteira Bicicleteira']={rarity='Secret',dps=3500000},['La Grande Combinasion']={rarity='Secret',dps=10000000},['La Grande Combinassion']={rarity='Secret',dps=10000000},['Nuclearo Dinossauro']={rarity='Secret',dps=15000000},['Los Combinasionas']={rarity='Secret',dps=15000000},['Los Hotspotsitos']={rarity='Secret',dps=25000000},['Esok Sekolah']={rarity='Secret',dps=30000000},['Garama And Mandundung']={rarity='Secret',dps=50000000},['Garama And Madundung']={rarity='Secret',dps=50000000},['Dragon Cannelloni']={rarity='Secret',dps=100000000},['Secret Lucky Block']={rarity='Secret',dps=0}}

-- Multiplicadores (sin cambios)
local mutationMultipliers = {Gold=1.25,Diamond=1.5,Rainbow=10,Lava=6,Bloodrot=2,Celestial=4,Candy=4,Galaxy=6}
local traitMultipliers = {Taco=2.5,["Nyan Cat"]=3,Glitch=5,Rain=2.5,Snow=3,Starfall=3.5,["Golden Shine"]=6,Galactic=4,Explosive=4,Bubblegum=4,Zombie=5,Glitched=5,Claws=5,Fireworks=6,Nyan=6,Fire=5,Wet=2.5,Snowy=3,Cometstruck=3.5,Disco=5,["La Vacca Saturno Saturnita"]=4,Bombardiro=4,["Raining Tacos"]=3,["Tung Tung Attack"]=4,["Crab Rave"]=5,["4th of July"]=6,["Nyan Cats"]=6,Concert=5,["10B"]=3,Shark=3,Matteo=5,Brazil=6,UFO=3,Sleepy=3}

-- Configuración y estado
local SETTINGS_FILE = "ZykloHub_Settings.json"
local settings = {autoLoad=false,autoSave=false,speedHackEnabled=false,speedHackValue=1.5,flyHackEnabled=false,highJumpEnabled=false,highJumpValue=60,playerESPEnabled=false,hotbarESPEnabled=false,instaBrainrotEnabled=false,baseTimerESPEnabled=false,itemESPEnabled=false,betterGraphicsEnabled=false,infJumpEnabled=false,freezerKillerEnabled=false,antiMedusaEnabled=false,autoMedusaCounterEnabled=false,serverInfoEnabled=false,activeFunctionsEnabled=false,keybindsEnabled=false,killAllEnabled=false,keybinds={}}

-- Variables de estado
local playerESPEnabled,hotbarESPEnabled,instaBrainrotEnabled,baseTimerESPEnabled,itemESPEnabled,betterGraphicsEnabled,infJumpEnabled,freezerKillerEnabled,antiMedusaEnabled,autoMedusaCounterEnabled,serverInfoEnabled,activeFunctionsEnabled,keybindsEnabled,killAllEnabled=false,false,false,false,false,false,false,false,false,false,false,false,false,false
local freezerKillerConnection,killAllConnection,antiMedusaDebounce=nil,nil,false
local activeConnections={}

-- Elementos visuales
local secretVisuals,itemVisuals,playerHighlights,playerEsps,playerUpdateConns,hotbarGuis={},{},{},{},{},{}

-- Estado de la UI
local isMinimized,isExpanded,savedPreMinimizeSize,savedPreExpandSize,savedNormalSize=false,false,nil,nil,nil

-- Elementos UI (declaraciones)
local mainGui,rootFrame,minimizeBtn,expandBtn,closeBtn,sidebar,contentHost,mainPanel,helperPanel,playerPanel,bfPanel,stealerPanel,serverJoinerPanel,settingsPanel,speedRow,flyHackRow,jumpRow,playerESPRow,hotbarESPRow,baseTimerESPRow,itemESPRow,instaBrainrotRow,betterGraphicsRow,infJumpRow,freezerKillerRow,antiMedusaRow,autoMedusaCounterRow,killAllRow,autoLoadRow,autoSaveRow,serverInfoRow,activeFunctionsRow,keybindsRow,toggleMap,brandContainer,serverInfoGui,activeFunctionsGui,keybindsGui,flyButtonGui
toggleMap={}

-- Variables de movimiento
local HighJump={Enabled=false,JumpPower=50}
local Character=localPlayer.Character or localPlayer.CharacterAdded:Wait()
local Humanoid=Character:WaitForChild("Humanoid")
local HumanoidRootPart=Character:WaitForChild("HumanoidRootPart")
local camera=workspace.CurrentCamera

-- Configuración de Speed/Fly
local ITEM_NAME="Grapple Hook"
local USE_ITEM_ARG=2
local GROUND_SPEED=30
local SPEED_MULTIPLIER=settings.speedHackValue
local FLY_SPEED=150
local GODMODE_HEALTH=100
local FLY_KEY=Enum.KeyCode.F
local lastEquippedTime=0
local GRACE_PERIOD_DURATION=3.0
local useItemRemote
pcall(function()useItemRemote=ReplicatedStorage:WaitForChild("Packages",9e9):WaitForChild("Net",9e9):WaitForChild("RE/UseItem",9e9)end)
local movementActive,movementConnection,speedActive,flyActive,flying,mouseLook,godmodeActive,healthConnection=false,nil,false,false,false,false,false,nil
local keysDown={}

-- Auto Medusa Counter
local MEDUSA_TOOL_NAME="Medusa's Head"
local MEDUSA_DETECTION_RADIUS=13
local MEDUSA_REACT_COOLDOWN=0.35
local MEDUSA_POST_USE_COOLDOWN=25
local MEDUSA_DOUBLE_ACTIVATE_DELAY=0.03
local medusaLastReactTime,medusaReacting,medusaLongCooldownUntil=0,false,0

-- Buscador de Brainrot
local BACKEND_URL='https://brainrotss.up.railway.app/brainrots'
local autoJoinMode,searchActive,searchTarget,moneyFilter,filterDropdownOpen,joinAttemptCount=nil,false,nil,0,false,0
local joinedServers={}
local secretBtn,godBtn,searchBox,searchToggle,filterBtn,dropdownFrame,scroll

-- Funciones de ayuda
local function clean(str)return tostring(str or ""):gsub("%+",""):gsub("^%s(.-)%s*$","%1")end
local function toTitleCase(s)return(s:gsub("(%a)([%w_']*)",function(f,r)return f:upper()..r:lower()end))end
local function parseMoney(s)if not s or s=="TBA"then return 0 end;s=clean(s);local n,x=s:match("^%$?([%d%.]+)([MKBT]?)")if not n then return 0 end;n=tonumber(n)if not n then return 0 end;if x=="B"then return n*1e9 elseif x=="M"then return n*1e6 elseif x=="K"then return n*1e3 elseif x=="T"then return n*1e12 else return n end end
local function formatMoney(n)if n==0 then return"TBA"end;if n>=1e9 then return string.format("$%.1fB",n/1e9)elseif n>=1e6 then return string.format("$%.1fM",n/1e6)elseif n>=1e3 then return string.format("$%.0fK",n/1e3)else return"$"..tostring(n)end end

-- Funciones de guardado
local function saveSettings()pcall(function()if writefile then writefile(SETTINGS_FILE,HttpService:JSONEncode(settings))end end)end
local function loadSettings()local s,d=pcall(function()if readfile and isfile and isfile(SETTINGS_FILE)then return HttpService:JSONDecode(readfile(SETTINGS_FILE))end end)if s and type(d)=="table"then for k,v in pairs(d)do settings[k]=v end;return settings end;return nil end

-- Funciones de cálculo
local function getMutationAndTraits(m)local u,t;pcall(function()u=m:GetAttribute("Mutation")end)if not u then local v=m:FindFirstChild("Mutation")if v and v:IsA("StringValue")then u=v.Value end end;pcall(function()if m:GetAttribute("Traits")then t=m:GetAttribute("Traits")elseif m:GetAttribute("Trait")then t={m:GetAttribute("Trait")}end end)if not t then local f=m:FindFirstChild("Traits")or m:FindFirstChild("TraitsFolder")if f and f:IsA("Folder")then t={}for _,v in ipairs(f:GetChildren())do if v:IsA("StringValue")then table.insert(t,v.Value)end end end end;if type(t)=="string"then t={t}end;return u,t end
local function calculateMultiplier(m,t)local M,N={},0;if m and mutationMultipliers[m]then table.insert(M,mutationMultipliers[m])N=N+1 else table.insert(M,1)N=N+1 end;if t then for _,v in ipairs(t)do if traitMultipliers[v]then table.insert(M,traitMultipliers[v])N=N+1 end end end;if N==0 then return 1 end;local s=0;for _,v in ipairs(M)do s=s+v end;local o=s-(N-1)return o<1 and 1 or o end
local function _calculateBrainrotStats_internal(m)local d=brainrotDict[m.Name]and brainrotDict[m.Name].dps or 0;local b=d;local u,t=getMutationAndTraits(m)local l=calculateMultiplier(u,t)local f=b*l;return f,l,u or"None",t or{}end
function calculateBrainrotStats(m)if statsCache[m]then return unpack(statsCache[m])end;local f,l,u,t=_calculateBrainrotStats_internal(m)statsCache[m]={f,l,u,t}return f,l,u,t end

-- Funciones visuales
local function cleanupVisuals(t,m)if not t[m]then return end;for _,v in pairs(t[m])do if v and v.Parent then pcall(function()v:Destroy()end)end end;t[m]=nil end
local function createSecretVisuals(m)if secretVisuals[m]then return end;local r=m:FindFirstChild("RootPart")if not r then return end;local V={};local h=Instance.new("Highlight")h.FillColor=THEME.accentA;h.OutlineColor=THEME.accentB;h.FillTransparency=0.35;h.OutlineTransparency=0.1;h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop;h.Parent=m;V.hl=h;local b=Instance.new("BillboardGui")b.Name="ESPName"b.Size=UDim2.new(0,280,0,50)b.AlwaysOnTop=true;b.Adornee=r;b.StudsOffset=Vector3.new(0,4,0)b.Parent=m;V.esp=b;local f=Instance.new("Frame",b)f.Size=UDim2.new(1,0,1,0)f.BackgroundColor3=THEME.panel2;f.BackgroundTransparency=0.15;f.BorderSizePixel=0;Instance.new("UICorner",f).CornerRadius=UDim.new(0,6)local s=Instance.new("UIStroke",f)s.Color=THEME.accentA;s.Thickness=1;s.Transparency=0.1;s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border;local l=Instance.new("TextLabel",f)l.Size=UDim2.new(1,-10,1,-10)l.Position=UDim2.new(0,5,0,5)l.BackgroundTransparency=1;l.TextColor3=THEME.text;l.TextStrokeTransparency=0.6;l.Font=Enum.Font.GothamBold;l.TextScaled=true;local u;u=RunService.RenderStepped:Connect(function()if not m or not m.Parent or not r or not r.Parent then if u then u:Disconnect()end;return end;local h=localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")local d=h and(h.Position-r.Position).Magnitude or 0;local p,_,_,_=calculateBrainrotStats(m)local y=brainrotDict[m.Name]and brainrotDict[m.Name].rarity or"?";l.Text=string.format("%s (%s)\n[%.1fm] | %s/s",toTitleCase(m.Name),y,d,formatMoney(p))b.StudsOffset=Vector3.new(0,math.clamp(4+(d/25),4,12),0)end)V.updateConn=u;local a0=Instance.new("Attachment")a0.Name="CharAttach"a0.Parent=localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")or workspace.Terrain;V.att0=a0;local a1=Instance.new("Attachment",r)a1.Name="TargetAttach"V.att1=a1;local e=Instance.new("Beam",r)e.Name="ESPTracer"e.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,THEME.accentA),ColorSequenceKeypoint.new(1,THEME.accentB)})e.Width0,e.Width1=0.2,0.1;e.FaceCamera=true;e.Transparency=NumberSequence.new(0.35)e.Attachment0,e.Attachment1=a0,a1;V.tracer=e;local t;t=RunService.RenderStepped:Connect(function()if not m or not m.Parent or not a0 or not a0.Parent then if t then t:Disconnect()end;return end;local n=localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")if n and a0.Parent~=n then a0.Parent=n end end)V.tracerUpdateConn=t;secretVisuals[m]=V end
local function updateBrainrotESP()local C={};local A={};for _,i in ipairs(workspace:GetDescendants())do if i:IsA("Model")and i:FindFirstChild("RootPart")and brainrotDict[i.Name]then local d=brainrotDict[i.Name]if d.rarity=="Secret"or d.rarity=="Brainrot God"then table.insert(A,i)end end end;local b,m=nil,-1;for _,o in ipairs(A)do local p,_,_,_=calculateBrainrotStats(o)if p>m then m=p;b=o end end;if b then C[b]=true end;for o,_ in pairs(secretVisuals)do if not C[o]or not o.Parent then cleanupVisuals(secretVisuals,o)end end;for o,_ in pairs(C)do if not secretVisuals[o]then createSecretVisuals(o)end end end
local function createItemVisuals(i)if itemVisuals[i]then return end;local V={};local h=Instance.new("Highlight")h.FillColor=THEME.gold;h.OutlineColor=THEME.accentA;h.FillTransparency=0.5;h.OutlineTransparency=0.2;h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop;h.Parent=i;V.hl=h;itemVisuals[i]=V end
local function updateItemESP()if not itemESPEnabled then for i,_ in pairs(itemVisuals)do cleanupVisuals(itemVisuals,i)end;return end;local C={};for _,o in pairs(workspace:GetDescendants())do if o:IsA("Model")and(o.Name=="All Seeing Sentry"or o.Name=="Trap")then C[o]=true end end;for i,_ in pairs(itemVisuals)do if not C[i]or not i or not i.Parent then cleanupVisuals(itemVisuals,i)end end;for i,_ in pairs(C)do if not itemVisuals[i]then createItemVisuals(i)end end end

-- ... (Otras funciones de ESP, movimiento, etc. aquí)

local function startInstaBrainrot()task.spawn(function()while task.wait(0.1)do if instaBrainrotEnabled and mainGui and mainGui.Parent then for _,v in ipairs(workspace:GetDescendants())do if v:IsA("ProximityPrompt")then v.HoldDuration=0;v:InputHoldBegin()v:InputHoldEnd()end end end end end)end

-- ... (Más funciones hasta la UI)

local function createPanelHeader(p,t,i)local h=Instance.new("Frame",p)h.Size,h.Position,h.BackgroundTransparency=UDim2.new(0,220,0,36),UDim2.new(0,10,0,10),1;local c=Instance.new("ImageLabel",h)c.Size,c.Position,c.BackgroundTransparency,c.Image,c.ImageColor3=UDim2.new(0,24,0,24),UDim2.new(0,0,0.5,-12),1,i,Color3.fromRGB(248,250,255)local l=Instance.new("TextLabel",h)l.Size,l.Position,l.BackgroundTransparency,l.Text,l.TextColor3,l.TextSize,l.Font,l.TextXAlignment=UDim2.new(1,-30,1,0),UDim2.new(0,30,0,0),1,t,Color3.fromRGB(248,250,255),22,Enum.Font.GothamBlack,Enum.TextXAlignment.Left;return h end
local keybindSetterFrame,keybindInputConnection=nil,nil
function createKeybindSetter(id,t,p)if not keybindSetterFrame then keybindSetterFrame=Instance.new("Frame")keybindSetterFrame.Name="KeybindSetter"keybindSetterFrame.Size=UDim2.new(0,250,0,120)keybindSetterFrame.BackgroundColor3=THEME.panel2;keybindSetterFrame.ZIndex=100;Instance.new("UICorner",keybindSetterFrame).CornerRadius=UDim.new(0,10)local s=Instance.new("UIStroke",keybindSetterFrame)s.Color=THEME.accentA;local i=Instance.new("TextLabel",keybindSetterFrame)i.Name="Title"i.Size=UDim2.new(1,-20,0,30)i.Position=UDim2.new(0,10,0,5)i.BackgroundTransparency=1;i.TextColor3=THEME.text;i.Font=Enum.Font.GothamBold;i.TextSize=14;local o=Instance.new("TextLabel",keybindSetterFrame)o.Name="Prompt"o.Size=UDim2.new(1,-20,0,30)o.Position=UDim2.new(0,10,0,35)o.BackgroundTransparency=1;o.TextColor3=THEME.textDim;o.Font=Enum.Font.Gotham;o.TextSize=13;local c=Instance.new("TextButton",keybindSetterFrame)c.Name="ClearButton"c.Size=UDim2.new(1,-20,0,30)c.Position=UDim2.new(0,10,0,75)c.BackgroundColor3=THEME.btnActive;c.TextColor3=THEME.text;c.Text="Clear Keybind"c.Font=Enum.Font.GothamBold;c.TextSize=14;c.ZIndex=101;Instance.new("UICorner",c).CornerRadius=UDim.new(0,6)end;local f=keybindSetterFrame;f.Position=UDim2.new(0,p.X,0,p.Y)f.Parent=mainGui;local i=f.Title;local o=f.Prompt;local c=f.ClearButton;i.Text="Set Keybind for: "..t;o.Text="Press any key... (ESC to cancel)"if keybindInputConnection and keybindInputConnection.Connected then keybindInputConnection:Disconnect()end;local function close()if keybindInputConnection and keybindInputConnection.Connected then keybindInputConnection:Disconnect()end;if f and f.Parent then f.Parent=nil end end;c.Activated:Connect(function()settings.keybinds[id]=nil;o.Text="Keybind Cleared."if settings.autoSave then saveSettings()end;task.wait(0.5)close()end)keybindInputConnection=UserInputService.InputBegan:Connect(function(n,g)if n.KeyCode==Enum.KeyCode.Escape then o.Text="Cancelled."task.wait(0.2)close()return end;if g then return end;if n.UserInputType==Enum.UserInputType.Keyboard then settings.keybinds[id]=n.KeyCode.Name;o.Text="Set to: "..n.KeyCode.Name;if settings.autoSave then saveSettings()end;task.wait(0.5)close()end end)end

function createUI()
    -- >> [CORREGIDO] Se declaran las variables de contenido aquí para que sean accesibles en toda la función
    local mainContainer, helperBody, playerContainer, stealerBody, settingsBody
    
    mainGui=Instance.new("ScreenGui")mainGui.Name="ZykloHub"mainGui.ResetOnSpawn=false;mainGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;mainGui.Parent=localPlayer:WaitForChild("PlayerGui")
    local w,h=580,340;savedNormalSize=UDim2.new(0,w,0,h)rootFrame=Instance.new("Frame")rootFrame.Name="Root"rootFrame.Size=UDim2.new(0,w,0,h)rootFrame.Position=UDim2.new(0.5,-w/2,0.5,-h/2)rootFrame.BackgroundColor3=THEME.bg;rootFrame.BackgroundTransparency=0.02;rootFrame.BorderSizePixel=0;rootFrame.Active=true;rootFrame.Draggable=true;rootFrame.ZIndex=1;rootFrame.Parent=mainGui;Instance.new("UICorner",rootFrame).CornerRadius=UDim.new(0,14)local s=Instance.new("UIStroke",rootFrame)s.Color=THEME.accentA;s.Transparency=0.8;s.Thickness=1.5;local l=Instance.new("ImageLabel",rootFrame)l.Name="BrandLogo"l.Size=UDim2.new(0,24,0,24)l.Position=UDim2.new(0,12,0,10)l.BackgroundTransparency=1;l.Image=ASSETS.BRAND_LOGO;l.ScaleType=Enum.ScaleType.Fit;l.ZIndex=2;brandContainer=Instance.new("Frame",rootFrame)brandContainer.Name="BrandContainer"brandContainer.Size=UDim2.new(0,200,0,32)brandContainer.Position=UDim2.new(0,42,0,8)brandContainer.BackgroundTransparency=1;brandContainer.ZIndex=2;local t=Instance.new("TextLabel",brandContainer)t.Name="BrandTitle"t.Size=UDim2.new(1,0,1,0)t.BackgroundTransparency=1;t.Text="Zyklo hub"t.TextColor3=THEME.text;t.TextSize=17;t.Font=Enum.Font.GothamBold;t.TextXAlignment=Enum.TextXAlignment.Left;t.ZIndex=2;local u=Instance.new("TextLabel",brandContainer)u.Name="BrandSubtitle"u.Size=UDim2.new(1,0,0,0)u.Position=UDim2.new(0,0,0,17)u.BackgroundTransparency=1;u.Text=""u.TextColor3=THEME.textDim;u.TextSize=11;u.Font=Enum.Font.GothamSemibold;u.TextXAlignment=Enum.TextXAlignment.Left;u.ZIndex=2;
    minimizeBtn=Instance.new("ImageButton",rootFrame)minimizeBtn.Name="Minimize"minimizeBtn.Size=UDim2.new(0,20,0,20)minimizeBtn.Position=UDim2.new(1,-100,0,8)minimizeBtn.BackgroundTransparency=1;minimizeBtn.Image=ASSETS.MINIMIZE_ICON;minimizeBtn.ImageColor3=THEME.textDim;minimizeBtn.ScaleType=Enum.ScaleType.Fit;minimizeBtn.ZIndex=2;expandBtn=Instance.new("ImageButton",rootFrame)expandBtn.Name="Expand"expandBtn.Size=UDim2.new(0,20,0,20)expandBtn.Position=UDim2.new(1,-70,0,8)expandBtn.BackgroundTransparency=1;expandBtn.Image=ASSETS.EXPAND_ICON;expandBtn.ImageColor3=THEME.textDim;expandBtn.ScaleType=Enum.ScaleType.Fit;expandBtn.ZIndex=2;closeBtn=Instance.new("ImageButton",rootFrame)closeBtn.Name="Close"closeBtn.Size=UDim2.new(0,20,0,20)closeBtn.Position=UDim2.new(1,-40,0,8)closeBtn.BackgroundTransparency=1;closeBtn.Image=ASSETS.CLOSE_ICON;closeBtn.ImageColor3=THEME.textDim;closeBtn.ScaleType=Enum.ScaleType.Fit;closeBtn.ZIndex=2;closeBtn.Activated:Connect(function()mainGui:Destroy()end)minimizeBtn.Activated:Connect(toggleMinimize)expandBtn.Activated:Connect(toggleExpand)
    local p,d=44,160;sidebar=Instance.new("Frame",rootFrame)sidebar.Name="Sidebar"sidebar.Size=UDim2.new(0,d,1,-p-14)sidebar.Position=UDim2.new(0,10,0,p)sidebar.BackgroundColor3=THEME.panel;sidebar.BackgroundTransparency=0.06;sidebar.ZIndex=2;Instance.new("UICorner",sidebar).CornerRadius=UDim.new(0,10)local c=Instance.new("ScrollingFrame",sidebar)c.Name="Sections"c.Size=UDim2.new(1,-14,1,-16)c.Position=UDim2.new(0,7,0,8)c.BackgroundTransparency=1;c.BorderSizePixel=0;c.ScrollBarThickness=6;c.ScrollBarImageColor3=THEME.scrollBar;c.ZIndex=3;local y=Instance.new("UIListLayout",c)y.Padding=UDim.new(0,8)y:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()c.CanvasSize=UDim2.new(0,0,0,y.AbsoluteContentSize.Y)end)
    contentHost=Instance.new("Frame",rootFrame)contentHost.Name="ContentHost"contentHost.Size=UDim2.new(1,-d-30,1,-p-20)contentHost.Position=UDim2.new(0,d+20,0,p+2)contentHost.BackgroundColor3=THEME.panel;contentHost.BackgroundTransparency=0.06;contentHost.ZIndex=2;Instance.new("UICorner",contentHost).CornerRadius=UDim.new(0,10)
    mainPanel=Instance.new("Frame",contentHost)mainPanel.Name="MainPanel"mainPanel.Size=UDim2.new(1,-10,1,-10)mainPanel.Position=UDim2.new(0,5,0,5)mainPanel.BackgroundColor3=THEME.panel2;mainPanel.BackgroundTransparency=0.06;mainPanel.Visible=true;mainPanel.ZIndex=3;Instance.new("UICorner",mainPanel).CornerRadius=UDim.new(0,10)
    helperPanel=Instance.new("Frame",contentHost)helperPanel.Name="HelperPanel"helperPanel.Size=UDim2.new(1,-10,1,-10)helperPanel.Position=UDim2.new(0,5,0,5)helperPanel.BackgroundColor3=THEME.panel2;helperPanel.BackgroundTransparency=0.06;helperPanel.Visible=false;helperPanel.ZIndex=3;Instance.new("UICorner",helperPanel).CornerRadius=UDim.new(0,10)
    playerPanel=Instance.new("Frame",contentHost)playerPanel.Name="PlayerPanel"playerPanel.Size=UDim2.new(1,-10,1,-10)playerPanel.Position=UDim2.new(0,5,0,5)playerPanel.BackgroundColor3=THEME.panel2;playerPanel.BackgroundTransparency=0.06;playerPanel.Visible=false;playerPanel.ZIndex=3;Instance.new("UICorner",playerPanel).CornerRadius=UDim.new(0,10)
    bfPanel=Instance.new("Frame",contentHost)bfPanel.Name="BrainrotFinderPanel"bfPanel.Size=UDim2.new(1,-10,1,-10)bfPanel.Position=UDim2.new(0,5,0,5)bfPanel.BackgroundColor3=THEME.panel2;bfPanel.BackgroundTransparency=0.06;bfPanel.Visible=false;bfPanel.ZIndex=3;Instance.new("UICorner",bfPanel).CornerRadius=UDim.new(0,10)
    stealerPanel=Instance.new("Frame",contentHost)stealerPanel.Name="StealerPanel"stealerPanel.Size=UDim2.new(1,-10,1,-10)stealerPanel.Position=UDim2.new(0,5,0,5)stealerPanel.BackgroundColor3=THEME.panel2;stealerPanel.BackgroundTransparency=0.06;stealerPanel.Visible=false;stealerPanel.ZIndex=3;Instance.new("UICorner",stealerPanel).CornerRadius=UDim.new(0,10)
    serverJoinerPanel=Instance.new("Frame",contentHost)serverJoinerPanel.Name="ServerJoinerPanel"serverJoinerPanel.Size=UDim2.new(1,-10,1,-10)serverJoinerPanel.Position=UDim2.new(0,5,0,5)serverJoinerPanel.BackgroundColor3=THEME.panel2;serverJoinerPanel.BackgroundTransparency=0.06;serverJoinerPanel.Visible=false;serverJoinerPanel.ZIndex=3;Instance.new("UICorner",serverJoinerPanel).CornerRadius=UDim.new(0,10)
    settingsPanel=Instance.new("Frame",contentHost)settingsPanel.Name="SettingsPanel"settingsPanel.Size=UDim2.new(1,-10,1,-10)settingsPanel.Position=UDim2.new(0,5,0,5)settingsPanel.BackgroundColor3=THEME.panel2;settingsPanel.BackgroundTransparency=0.06;settingsPanel.Visible=false;settingsPanel.ZIndex=3;Instance.new("UICorner",settingsPanel).CornerRadius=UDim.new(0,10)
    
    local mainBtn=makeSectionButton("Main",ASSETS.MAIN_ICON)
    local helperBtn=makeSectionButton("Helper",ASSETS.HELPER_ICON)
    local playerBtn=makeSectionButton("Player",ASSETS.PLAYER_ICON)
    local stealerBtn=makeSectionButton("Stealer",ASSETS.STEALER_ICON)
    local finderBtn=makeSectionButton("Brainrot Finder",ASSETS.FINDER_ICON)
    local serverJoinerBtn=makeSectionButton("Server Joiner",ASSETS.SERVER_JOINER_ICON)
    local settingsBtn=makeSectionButton("Settings",ASSETS.SETTINGS_ICON)

    createPanelHeader(mainPanel,"Main",ASSETS.MAIN_ICON)
    createPanelHeader(playerPanel,"Player",ASSETS.PLAYER_ICON)
    createPanelHeader(helperPanel,"Helper",ASSETS.HELPER_ICON)
    createPanelHeader(stealerPanel,"Stealer",ASSETS.STEALER_ICON)
    createPanelHeader(serverJoinerPanel,"Server Joiner",ASSETS.SERVER_JOINER_ICON)
    createPanelHeader(settingsPanel,"Settings",ASSETS.SETTINGS_ICON)
    
    mainContainer=Instance.new("ScrollingFrame",mainPanel)mainContainer.Size,mainContainer.Position,mainContainer.BackgroundTransparency=UDim2.new(1,-20,1,-58),UDim2.new(0,10,0,50),1;mainContainer.BorderSizePixel=0;mainContainer.ScrollBarThickness=6;mainContainer.ScrollBarImageColor3=THEME.scrollBar;local mainLayout=Instance.new("UIListLayout",mainContainer)mainLayout.Padding=UDim.new(0,8)mainLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()mainContainer.CanvasSize=UDim2.new(0,0,0,mainLayout.AbsoluteContentSize.Y)end)
    helperBody=Instance.new("ScrollingFrame",helperPanel)helperBody.Name="HelperBody"helperBody.Size=UDim2.new(1,-20,1,-58)helperBody.Position=UDim2.new(0,10,0,50)helperBody.BackgroundTransparency=1;helperBody.BorderSizePixel=0;helperBody.ScrollBarThickness=6;helperBody.ScrollBarImageColor3=THEME.scrollBar;local helperBodyLayout=Instance.new("UIListLayout",helperBody)helperBodyLayout.Padding=UDim.new(0,10)helperBodyLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()helperBody.CanvasSize=UDim2.new(0,0,0,helperBodyLayout.AbsoluteContentSize.Y)end)
    playerContainer=Instance.new("ScrollingFrame",playerPanel)playerContainer.Size,playerContainer.Position,playerContainer.BackgroundTransparency=UDim2.new(1,-20,1,-58),UDim2.new(0,10,0,50),1;Instance.new("UIListLayout",playerContainer).Padding=UDim.new(0,8)
    stealerBody=Instance.new("ScrollingFrame",stealerPanel)stealerBody.Size,stealerBody.Position,stealerBody.BackgroundTransparency=UDim2.new(1,-20,1,-58),UDim2.new(0,10,0,50),1;Instance.new("UIListLayout",stealerBody).Padding=UDim.new(0,10)
    settingsBody=Instance.new("ScrollingFrame",settingsPanel)settingsBody.Size=UDim2.new(1,-20,1,-58)settingsBody.Position=UDim2.new(0,10,0,50)settingsBody.BackgroundTransparency=1;settingsBody.BorderSizePixel=0;settingsBody.ScrollBarThickness=6;settingsBody.ScrollBarImageColor3=THEME.scrollBar;Instance.new("UIListLayout",settingsBody).Padding=UDim.new(0,10)

    speedRow=makeThinRow(mainContainer,"Speed Hack","speedHack",1,3,settings.speedHackValue,1,function(v)SPEED_MULTIPLIER=v;settings.speedHackValue=v;if settings.autoSave then saveSettings()end end,settings.speedHackEnabled,function(v)speedActive=v;settings.speedHackEnabled=v;if settings.autoSave then saveSettings()end end)
    flyHackRow=createToggleRow(mainContainer,"Fly Hack","flyHack",settings.flyHackEnabled,function(v)flyActive=v;settings.flyHackEnabled=v;if settings.autoSave then saveSettings()end;if v then if not isGrappleHookEquipped()and(time()-lastEquippedTime)>GRACE_PERIOD_DURATION then pcall(function()StarterGui:SetCore("SendNotification",{Title="Zyklo hub",Text="Please equip the Grapple Hook to use Fly/Speed!",Duration=5})end)end;flying=true;createFlyButtonGUI()else flying=false;destroyFlyButtonGUI()end;updateFlyButtonText()end)
    jumpRow=makeThinRow(mainContainer,"High Jump","highJump",50,130,settings.highJumpValue,0,function(v)HighJump.JumpPower=v;if HighJump.Enabled and Humanoid then Humanoid.JumpPower=v end;settings.highJumpValue=v;if settings.autoSave then saveSettings()end end,settings.highJumpEnabled,function(v)HighJump.Enabled=v;if Humanoid then Humanoid.UseJumpPower=v;Humanoid.JumpPower=v and HighJump.JumpPower or 50 end;settings.highJumpEnabled=v;if settings.autoSave then saveSettings()end end)
    infJumpRow=createToggleRow(mainContainer,"Infinite Jump","infJump",settings.infJumpEnabled,function(v)infJumpEnabled=v;settings.infJumpEnabled=v;if settings.autoSave then saveSettings()end end)
    playerESPRow=createToggleRow(helperBody,"Player ESP","playerESP",settings.playerESPEnabled,function(v)playerESPEnabled=v;settings.playerESPEnabled=v;if settings.autoSave then saveSettings()end;if not v then for _,p in ipairs(Players:GetPlayers())do removePlayerESP(p)end else updateAllPlayers()end end)
    hotbarESPRow=createToggleRow(helperBody,"Hotbar ESP","hotbarESP",settings.hotbarESPEnabled,function(v)hotbarESPEnabled=v;settings.hotbarESPEnabled=v;if settings.autoSave then saveSettings()end;if not v then for p in pairs(hotbarGuis)do removeHotbarGuis(p)end else updateAllPlayers()end end)
    baseTimerESPRow=createToggleRow(helperBody,"Base Timer ESP","baseTimerESP",settings.baseTimerESPEnabled,function(v)baseTimerESPEnabled=v;settings.baseTimerESPEnabled=v;if settings.autoSave then saveSettings()end;updateBaseTimerESP()end)
    itemESPRow=createToggleRow(helperBody,"Item ESP","itemESP",settings.itemESPEnabled,function(v)itemESPEnabled=v;settings.itemESPEnabled=v;if settings.autoSave then saveSettings()end;updateItemESP()end)
    serverInfoRow=createToggleRow(helperBody,"Server Info","serverInfo",settings.serverInfoEnabled,function(v)serverInfoEnabled=v;settings.serverInfoEnabled=v;if settings.autoSave then saveSettings()end;if v then createServerInfoGUI()else destroyServerInfoGUI()end end)
    instaBrainrotRow=createToggleRow(playerContainer,"Insta Brainrot Purchase","instaBrainrot",settings.instaBrainrotEnabled,function(v)instaBrainrotEnabled=v;settings.instaBrainrotEnabled=v;if settings.autoSave then saveSettings()end end)
    betterGraphicsRow=createToggleRow(playerContainer,"Better Graphics","betterGraphics",settings.betterGraphicsEnabled,function(v)betterGraphicsEnabled=v;settings.betterGraphicsEnabled=v;if settings.autoSave then saveSettings()end;applyBetterGraphics(v)end)
    killAllRow=createToggleRow(playerContainer,"Kill All","killAll",settings.killAllEnabled,function(v)killAllEnabled=v;settings.killAllEnabled=v;if settings.autoSave then saveSettings()end;if v then startKillAllLoop()else stopKillAllLoop()end end)
    freezerKillerRow=createToggleRow(stealerBody,"Freezer & Killer","freezerKiller",settings.freezerKillerEnabled,function(v)freezerKillerEnabled=v;settings.freezerKillerEnabled=v;if settings.autoSave then saveSettings()end;if v then startFreezerKiller()else stopFreezerKiller()end end)
    antiMedusaRow=createToggleRow(stealerBody,"Anti Medusa","antiMedusa",settings.antiMedusaEnabled,function(v)antiMedusaEnabled=v;settings.antiMedusaEnabled=v;if settings.autoSave then saveSettings()end end)
    autoMedusaCounterRow=createToggleRow(stealerBody,"Auto Medusa Counter","autoMedusaCounter",settings.autoMedusaCounterEnabled,function(v)autoMedusaCounterEnabled=v;settings.autoMedusaCounterEnabled=v;if settings.autoSave then saveSettings()end end)
    autoLoadRow=createToggleRow(settingsBody,"Auto Load","autoLoad",settings.autoLoad,function(v)settings.autoLoad=v;if settings.autoSave then saveSettings()end end)
    autoSaveRow=createToggleRow(settingsBody,"Auto Save","autoSave",settings.autoSave,function(v)settings.autoSave=v;if v then saveSettings()end end)
    activeFunctionsRow=createToggleRow(settingsBody,"Active Functions","activeFunctions",settings.activeFunctionsEnabled,function(v)activeFunctionsEnabled=v;settings.activeFunctionsEnabled=v;if settings.autoSave then saveSettings()end;if v then createActiveFunctionsGUI()else destroyActiveFunctionsGUI()end end)
    keybindsRow=createToggleRow(settingsBody,"Keybinds","keybinds",settings.keybindsEnabled,function(v)keybindsEnabled=v;settings.keybindsEnabled=v;if settings.autoSave then saveSettings()end;if v then createKeybindsGUI()else destroyKeybindsGUI()end end)

    -- (El resto de la UI como el buscador de brainrot se crea aquí)
end

-- ... (Todas las demás funciones, bucle principal, etc.)

function mainLoop()
    mainGui.Destroying:Connect(cleanup)
    -- ...
end

-- Código de inicialización
loadedSettings=loadSettings()
if loadedSettings and loadedSettings.autoLoad then settings=loadedSettings end
createUI()
mainLoop()
if settings.autoLoad then task.spawn(function()task.wait(1)applySettingsManually()end)end
task.spawn(function()while task.wait(30)do if mainGui and mainGui.Parent then scanAndReportBrainrots()else break end end end)
print("Zyklo hub loaded successfully!")
