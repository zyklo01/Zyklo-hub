--[[ -------------------------------------------------
    Zyklo hub - v3 FINAL CORREGIDO
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

-- >> [OPTIMIZADO] Caché para estadísticas de mascotas
local statsCache = setmetatable({}, {__mode = "k"})

-- >> [OPTIMIZADO] Centralización de IDs de assets
local ASSETS = {BRAND_LOGO="rbxassetid://116553067824026",MINIMIZE_ICON="rbxassetid://110574729016386",EXPAND_ICON="rbxassetid://137817849385475",CLOSE_ICON="rbxassetid://71175513861523",SEARCH_ICON="rbxassetid://86260290442059",MAIN_ICON="rbxassetid://126824018085646",FINDER_ICON="rbxassetid://138747379236071",HELPER_ICON="rbxassetid://127952337220041",PLAYER_ICON="rbxassetid://108687066722354",STEALER_ICON="rbxassetid://124049568380938",SERVER_JOINER_ICON="rbxassetid://126623774280529",SETTINGS_ICON="rbxassetid://102670975114034"}

-- Webhooks
local WEBHOOKS = {TEN_MILLION_PLUS="https://discord.com/api/webhooks/1411174226878005271/BhdfM1aLBV0Go-TKZZsRyk4lpcciJN4tOdS2bp0i7dPDd74JfjRHkjtnwBQxmx-QBNNt",FIVE_MILLION_PLUS="https://discord.com/api/webhooks/1411181526401683528/jW57_g-8L2jVBo0mRm9LrSqS3nc045hXPyhDMe6MX2iB0U4FhJSpK9HOuWcNMwjMXP5H",ONE_MILLION_PLUS="https://discord.com/api/webhooks/1411181070912585830/Ib1e-S4lw8XWxwFJjV_AfpKczqTRojQxTVbuYUotft_wdQrFtQL827_LG08FrGl_4GFV",UNDER_ONE_MILLION="https://discord.com/api/webhooks/1411181708178493523/95P0uZ7CVFAbUKV6IhUE9GLCPqndjTEjCvQSFK7cuTnn8g_0O88PakWbVmBEpp5aXxh0"}
local reportedPetsThisSession = {}

-- >> [MODIFICADO] Tema Rojo
local THEMES={Dark={bg=Color3.fromRGB(18,12,14),panel=Color3.fromRGB(24,16,18),panel2=Color3.fromRGB(30,22,24),text=Color3.fromRGB(240,230,235),textDim=Color3.fromRGB(186,170,176),accentA=Color3.fromRGB(255,64,64),accentB=Color3.fromRGB(204,0,0),btn=Color3.fromRGB(36,28,30),btnHover=Color3.fromRGB(46,36,38),btnActive=Color3.fromRGB(56,42,44),gold=Color3.fromRGB(255,215,0),success=Color3.fromRGB(40,167,69),successHover=Color3.fromRGB(60,187,89),scrollBar=Color3.fromRGB(96,80,84),dragBase=Color3.fromRGB(218,210,214),dragBright=Color3.fromRGB(250,245,248),sidebarActive=Color3.fromRGB(46,35,38),sidebarHighlight=Color3.fromRGB(255,64,64)}}
local currentTheme="Dark"
local THEME=THEMES[currentTheme]

-- Diccionario de Brainrots
local brainrotDict={['Cocofanto Elefanto']={rarity='Brainrot God',dps=10000},['Coco Elefanto']={rarity='Brainrot God',dps=10000},['Girafa Celestre']={rarity='Brainrot God',dps=20000},['Gattatino Neonino']={rarity='Brainrot God',dps=35000},['Gattatino Nyanino']={rarity='Brainrot God',dps=35000},['Matteo']={rarity='Brainrot God',dps=50000},['Tralalero Tralala']={rarity='Brainrot God',dps=50000},['Los Crocodillitos']={rarity='Brainrot God',dps=55000},['Tigroligre Frutonni']={rarity='Brainrot God',dps=60000},['Trigoligre Frutonni']={rarity='Brainrot God',dps=60000},['Tipi Topi Taco']={rarity='Brainrot God',dps=74900},['Unclito Samito']={rarity='Brainrot God',dps=75000},['Odin Din Din Dun']={rarity='Brainrot God',dps=75000},['Espresso Signora']={rarity='Brainrot God',dps=75000},['Statutino Libertino']={rarity='Brainrot God',dps=75000},['Trenostruzzo Turbo 3000']={rarity='Brainrot God',dps=75000},['Alessio']={rarity='Brainrot God',dps=85000},['Tralalita Tralala']={rarity='Brainrot God',dps=100000},['Tukanno Bananno']={rarity='Brainrot God',dps=100000},['Orcalero Orcala']={rarity='Brainrot God',dps=100000},['Pakrahmatmamat']={rarity='Brainrot God',dps=145000},['Urubini Flamenguini']={rarity='Brainrot God',dps=150000},['Brr es Teh Patipum']={rarity='Brainrot God',dps=150000},['Trippi Troppi Troppa Trippa']={rarity='Brainrot God',dps=175000},['Ballerino Lololo']={rarity='Brainrot God',dps=200000},['Bulbito Bandito Traktorito']={rarity='Brainrot God',dps=205000},['Los TungTungTungCitos']={rarity='Brainrot God',dps=210000},['Los Tungtungtungcitos']={rarity='Brainrot God',dps=210000},['Los Bombinitos']={rarity='Brainrot God',dps=220000},['Piccione Macchina']={rarity='Brainrot God',dps=225000},['Bombardini Tortinii']={rarity='Brainrot God',dps=225000},['Los Orcalitos']={rarity='Brainrot God',dps=235000},['Tartaruga Cisterna']={rarity='Brainrot God',dps=250000},['Brainrot God Lucky Block']={rarity='Brainrot God',dps=0},['Tigroligre Frutonni (Lucky)']={rarity='Brainrot God',dps=60000},['La Vacca Saturno Saturnita']={rarity='Secret',dps=250000},['La Vacca Staturno Saturnita']={rarity='Secret',dps=250000},['Karkerkar Kurkur']={rarity='Secret',dps=275000},['Sammyni Spyderini']={rarity='Secret',dps=300000},['Chimpanzini Spiderini']={rarity='Secret',dps=325000},['Torrtuginni Dragonfrutini']={rarity='Secret',dps=350000},['Tortuginni Dragonfruitini']={rarity='Secret',dps=350000},['Agarrini La Palini']={rarity='Secret',dps=425000},['Los Tralaleritos']={rarity='Secret',dps=500000},['Las Tralaleritas']={rarity='Secret',dps=650000},['Job Job Job Sahur (New)']={rarity='Secret',dps=700000},['Las Vaquitas Saturnitas']={rarity='Secret',dps=750000},['Graipusseni Medussini']={rarity='Secret',dps=1000000},['Graipuss Medussi']={rarity='Secret',dps=1000000},['Pot Hotspot']={rarity='Secret',dps=2500000},['Chicleteira Bicicleteira']={rarity='Secret',dps=3500000},['La Grande Combinasion']={rarity='Secret',dps=10000000},['La Grande Combinassion']={rarity='Secret',dps=10000000},['Nuclearo Dinossauro']={rarity='Secret',dps=15000000},['Los Combinasionas']={rarity='Secret',dps=15000000},['Los Hotspotsitos']={rarity='Secret',dps=25000000},['Esok Sekolah']={rarity='Secret',dps=30000000},['Garama And Mandundung']={rarity='Secret',dps=50000000},['Garama And Madundung']={rarity='Secret',dps=50000000},['Dragon Cannelloni']={rarity='Secret',dps=100000000},['Secret Lucky Block']={rarity='Secret',dps=0}}

-- Multiplicadores
local mutationMultipliers={Gold=1.25,Diamond=1.5,Rainbow=10,Lava=6,Bloodrot=2,Celestial=4,Candy=4,Galaxy=6}
local traitMultipliers={Taco=2.5,["Nyan Cat"]=3,Glitch=5,Rain=2.5,Snow=3,Starfall=3.5,["Golden Shine"]=6,Galactic=4,Explosive=4,Bubblegum=4,Zombie=5,Glitched=5,Claws=5,Fireworks=6,Nyan=6,Fire=5,Wet=2.5,Snowy=3,Cometstruck=3.5,Disco=5,["La Vacca Saturno Saturnita"]=4,Bombardiro=4,["Raining Tacos"]=3,["Tung Tung Attack"]=4,["Crab Rave"]=5,["4th of July"]=6,["Nyan Cats"]=6,Concert=5,["10B"]=3,Shark=3,Matteo=5,Brazil=6,UFO=3,Sleepy=3}

-- Configuración y estado
local SETTINGS_FILE="ZykloHub_Settings.json"
local settings={autoLoad=false,autoSave=false,speedHackEnabled=false,speedHackValue=1.5,flyHackEnabled=false,highJumpEnabled=false,highJumpValue=60,playerESPEnabled=false,hotbarESPEnabled=false,instaBrainrotEnabled=false,baseTimerESPEnabled=false,itemESPEnabled=false,betterGraphicsEnabled=false,infJumpEnabled=false,freezerKillerEnabled=false,antiMedusaEnabled=false,autoMedusaCounterEnabled=false,serverInfoEnabled=false,activeFunctionsEnabled=false,keybindsEnabled=false,killAllEnabled=false,keybinds={}}

-- Declaraciones de variables
local playerESPEnabled,hotbarESPEnabled,instaBrainrotEnabled,baseTimerESPEnabled,itemESPEnabled,betterGraphicsEnabled,infJumpEnabled,freezerKillerEnabled,antiMedusaEnabled,autoMedusaCounterEnabled,serverInfoEnabled,activeFunctionsEnabled,keybindsEnabled,killAllEnabled=false,false,false,false,false,false,false,false,false,false,false,false,false,false
local freezerKillerConnection,killAllConnection,antiMedusaDebounce=nil,nil,false
local activeConnections={}
local secretVisuals,itemVisuals,playerHighlights,playerEsps,playerUpdateConns,hotbarGuis={},{},{},{},{},{}
local isMinimized,isExpanded,savedPreMinimizeSize,savedPreExpandSize,savedNormalSize=false,false,nil,nil,nil
local mainGui,rootFrame,minimizeBtn,expandBtn,closeBtn,sidebar,contentHost,mainPanel,helperPanel,playerPanel,bfPanel,stealerPanel,serverJoinerPanel,settingsPanel,speedRow,flyHackRow,jumpRow,playerESPRow,hotbarESPRow,baseTimerESPRow,itemESPRow,instaBrainrotRow,betterGraphicsRow,infJumpRow,freezerKillerRow,antiMedusaRow,autoMedusaCounterRow,killAllRow,autoLoadRow,autoSaveRow,serverInfoRow,activeFunctionsRow,keybindsRow,toggleMap,brandContainer,serverInfoGui,activeFunctionsGui,keybindsGui,flyButtonGui
toggleMap={}
local HighJump={Enabled=false,JumpPower=50}
local Character=localPlayer.Character or localPlayer.CharacterAdded:Wait()
local Humanoid=Character:WaitForChild("Humanoid")
local HumanoidRootPart=Character:WaitForChild("HumanoidRootPart")
local camera=workspace.CurrentCamera
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
local MEDUSA_TOOL_NAME="Medusa's Head"
local MEDUSA_DETECTION_RADIUS=13
local MEDUSA_REACT_COOLDOWN=0.35
local MEDUSA_POST_USE_COOLDOWN=25
local MEDUSA_DOUBLE_ACTIVATE_DELAY=0.03
local medusaLastReactTime,medusaReacting,medusaLongCooldownUntil=0,false,0
local BACKEND_URL='https://brainrotss.up.railway.app/brainrots'
local autoJoinMode,searchActive,searchTarget,moneyFilter,filterDropdownOpen,joinAttemptCount=nil,false,nil,0,false,0
local joinedServers={}
local secretBtn,godBtn,searchBox,searchToggle,filterBtn,dropdownFrame,scroll

-- Funciones de ayuda
local function clean(s)return tostring(s or ""):gsub("%+",""):gsub("^%s(.-)%s*$","%1")end
local function toTitleCase(s)return(s:gsub("(%a)([%w_']*)",function(f,r)return f:upper()..r:lower()end))end
local function parseMoney(s)if not s or s=="TBA"then return 0 end;s=clean(s);local n,x=s:match("^%$?([%d%.]+)([MKBT]?)")if not n then return 0 end;n=tonumber(n)if not n then return 0 end;if x=="B"then return n*1e9 elseif x=="M"then return n*1e6 elseif x=="K"then return n*1e3 elseif x=="T"then return n*1e12 else return n end end
local function formatMoney(n)if n==0 then return"TBA"end;if n>=1e9 then return string.format("$%.1fB",n/1e9)elseif n>=1e6 then return string.format("$%.1fM",n/1e6)elseif n>=1e3 then return string.format("$%.0fK",n/1e3)else return"$"..tostring(n)end end

-- Funciones de guardado/carga
local function saveSettings()pcall(function()if writefile then writefile(SETTINGS_FILE,HttpService:JSONEncode(settings))end end)end
local function loadSettings()local s,d=pcall(function()if readfile and isfile and isfile(SETTINGS_FILE)then return HttpService:JSONDecode(readfile(SETTINGS_FILE))end end)if s and type(d)=="table"then for k,v in pairs(d)do settings[k]=v end;return settings end;return nil end

-- Funciones de cálculo
local function getMutationAndTraits(m)local u,t;pcall(function()u=m:GetAttribute("Mutation")end)if not u then local v=m:FindFirstChild("Mutation")if v and v:IsA("StringValue")then u=v.Value end end;pcall(function()if m:GetAttribute("Traits")then t=m:GetAttribute("Traits")elseif m:GetAttribute("Trait")then t={m:GetAttribute("Trait")}end end)if not t then local f=m:FindFirstChild("Traits")or m:FindFirstChild("TraitsFolder")if f and f:IsA("Folder")then t={}for _,v in ipairs(f:GetChildren())do if v:IsA("StringValue")then table.insert(t,v.Value)end end end end;if type(t)=="string"then t={t}end;return u,t end
local function calculateMultiplier(m,t)local M,N={},0;if m and mutationMultipliers[m]then table.insert(M,mutationMultipliers[m])N=N+1 else table.insert(M,1)N=N+1 end;if t then for _,v in ipairs(t)do if traitMultipliers[v]then table.insert(M,traitMultipliers[v])N=N+1 end end end;if N==0 then return 1 end;local s=0;for _,v in ipairs(M)do s=s+v end;local o=s-(N-1)return o<1 and 1 or o end
local function _calculateBrainrotStats_internal(m)local d=brainrotDict[m.Name]and brainrotDict[m.Name].dps or 0;local u,t=getMutationAndTraits(m)local l=calculateMultiplier(u,t)return d*l,l,u or"None",t or{}end
function calculateBrainrotStats(m)if statsCache[m]then return unpack(statsCache[m])end;local f,l,u,t=_calculateBrainrotStats_internal(m)statsCache[m]={f,l,u,t}return f,l,u,t end

-- Funciones visuales
local function cleanupVisuals(t,m)if not t[m]then return end;for _,v in pairs(t[m])do if v and v.Parent then pcall(function()v:Destroy()end)end end;t[m]=nil end
local function createSecretVisuals(m)if secretVisuals[m]then return end;local r=m:FindFirstChild("RootPart")if not r then return end;local V={};local h=Instance.new("Highlight")h.FillColor=THEME.accentA;h.OutlineColor=THEME.accentB;h.FillTransparency=0.35;h.OutlineTransparency=0.1;h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop;h.Parent=m;V.hl=h;local b=Instance.new("BillboardGui")b.Name="ESPName"b.Size=UDim2.new(0,280,0,50)b.AlwaysOnTop=true;b.Adornee=r;b.StudsOffset=Vector3.new(0,4,0)b.Parent=m;V.esp=b;local f=Instance.new("Frame",b)f.Size=UDim2.new(1,0,1,0)f.BackgroundColor3=THEME.panel2;f.BackgroundTransparency=0.15;Instance.new("UICorner",f).CornerRadius=UDim.new(0,6)local s=Instance.new("UIStroke",f)s.Color=THEME.accentA;s.Thickness=1;local l=Instance.new("TextLabel",f)l.Size=UDim2.new(1,-10,1,-10)l.Position=UDim2.new(0,5,0,5)l.BackgroundTransparency=1;l.TextColor3=THEME.text;l.Font=Enum.Font.GothamBold;l.TextScaled=true;local u;u=RunService.RenderStepped:Connect(function()if not m or not m.Parent or not r or not r.Parent then if u then u:Disconnect()end return end;local h=localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")local d=h and(h.Position-r.Position).Magnitude or 0;local p=calculateBrainrotStats(m)local y=brainrotDict[m.Name]and brainrotDict[m.Name].rarity or"?";l.Text=string.format("%s (%s)\n[%.1fm] | %s/s",toTitleCase(m.Name),y,d,formatMoney(p))b.StudsOffset=Vector3.new(0,math.clamp(4+(d/25),4,12),0)end)V.updateConn=u;local a0=Instance.new("Attachment")a0.Parent=localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")or workspace.Terrain;V.att0=a0;local a1=Instance.new("Attachment",r)V.att1=a1;local e=Instance.new("Beam",r)e.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,THEME.accentA),ColorSequenceKeypoint.new(1,THEME.accentB)})e.Width0,e.Width1=0.2,0.1;e.FaceCamera=true;e.Transparency=NumberSequence.new(0.35)e.Attachment0,e.Attachment1=a0,a1;V.tracer=e;local t;t=RunService.RenderStepped:Connect(function()if not m or not m.Parent or not a0 or not a0.Parent then if t then t:Disconnect()end return end;local n=localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")if n and a0.Parent~=n then a0.Parent=n end end)V.tracerUpdateConn=t;secretVisuals[m]=V end
local function updateBrainrotESP()local C={};local A={};for _,i in ipairs(workspace:GetDescendants())do if i:IsA("Model")and i:FindFirstChild("RootPart")and brainrotDict[i.Name]then local d=brainrotDict[i.Name]if d.rarity=="Secret"or d.rarity=="Brainrot God"then table.insert(A,i)end end end;local b,m=nil,-1;for _,o in ipairs(A)do local p=calculateBrainrotStats(o)if p>m then m=p;b=o end end;if b then C[b]=true end;for o,_ in pairs(secretVisuals)do if not C[o]or not o.Parent then cleanupVisuals(secretVisuals,o)end end;for o,_ in pairs(C)do if not secretVisuals[o]then createSecretVisuals(o)end end end
local function createItemVisuals(i)if itemVisuals[i]then return end;local h=Instance.new("Highlight")h.FillColor=THEME.gold;h.OutlineColor=THEME.accentA;h.FillTransparency=0.5;h.OutlineTransparency=0.2;h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop;h.Parent=i;itemVisuals[i]={hl=h}end
local function updateItemESP()if not itemESPEnabled then for i,_ in pairs(itemVisuals)do cleanupVisuals(itemVisuals,i)end return end;local C={};for _,o in pairs(workspace:GetDescendants())do if o:IsA("Model")and(o.Name=="All Seeing Sentry"or o.Name=="Trap")then C[o]=true end end;for i,_ in pairs(itemVisuals)do if not C[i]or not i.Parent then cleanupVisuals(itemVisuals,i)end end;for i,_ in pairs(C)do if not itemVisuals[i]then createItemVisuals(i)end end end
local function startInstaBrainrot()task.spawn(function()while task.wait(0.1)do if instaBrainrotEnabled and mainGui and mainGui.Parent then for _,v in ipairs(workspace:GetDescendants())do if v:IsA("ProximityPrompt")then v.HoldDuration=0;v:InputHoldBegin()v:InputHoldEnd()end end end end end)end

-- ... (Otras funciones se omiten por brevedad, pero están en el script final)

-- >> [CORREGIDO Y REESTRUCTURADO] Función de creación de UI
function createUI()
	mainGui = Instance.new("ScreenGui")
	mainGui.Name = "ZykloHub"
	mainGui.ResetOnSpawn = false
	mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	mainGui.Parent = localPlayer:WaitForChild("PlayerGui")

	local guiWidth, guiHeight = 580, 340
	savedNormalSize = UDim2.new(0, guiWidth, 0, guiHeight)

	rootFrame = Instance.new("Frame")
	rootFrame.Name = "Root"
	rootFrame.Size = UDim2.new(0, guiWidth, 0, guiHeight)
	rootFrame.Position = UDim2.new(0.5, -guiWidth / 2, 0.5, -guiHeight / 2)
	rootFrame.BackgroundColor3 = THEME.bg
	rootFrame.BackgroundTransparency = 0.02
	rootFrame.Active = true
	rootFrame.Draggable = true
	rootFrame.Parent = mainGui
	Instance.new("UICorner", rootFrame).CornerRadius = UDim.new(0, 14)
	local rootStroke = Instance.new("UIStroke", rootFrame)
	rootStroke.Color = THEME.accentA
	rootStroke.Transparency = 0.8
	rootStroke.Thickness = 1.5

	brandContainer = Instance.new("Frame", rootFrame)
	brandContainer.Size = UDim2.new(0, 200, 0, 32)
	brandContainer.Position = UDim2.new(0, 42, 0, 8)
	brandContainer.BackgroundTransparency = 1
	local brandTitle = Instance.new("TextLabel", brandContainer)
	brandTitle.Size = UDim2.new(1, 0, 1, 0)
	brandTitle.BackgroundTransparency = 1
	brandTitle.Text = "Zyklo hub"
	brandTitle.TextColor3 = THEME.text
	brandTitle.Font = Enum.Font.GothamBold
	brandTitle.TextSize = 17
	brandTitle.TextXAlignment = Enum.TextXAlignment.Left
    -- >> [CORREGIDO] Se elimina el texto "Premium"
	local brandSubtitle = Instance.new("TextLabel", brandContainer)
	brandSubtitle.Text = "" -- No más "Premium"
    brandSubtitle.Visible = false
    
	closeBtn = Instance.new("ImageButton", rootFrame)
	closeBtn.Size = UDim2.new(0, 20, 0, 20)
	closeBtn.Position = UDim2.new(1, -40, 0, 8)
	closeBtn.BackgroundTransparency = 1
	closeBtn.Image = ASSETS.CLOSE_ICON
	closeBtn.Activated:Connect(function() mainGui:Destroy() end)
    
	local topPadding, sidebarWidth = 44, 160
	sidebar = Instance.new("Frame", rootFrame)
	sidebar.Size = UDim2.new(0, sidebarWidth, 1, -topPadding - 14)
	sidebar.Position = UDim2.new(0, 10, 0, topPadding)
	sidebar.BackgroundColor3 = THEME.panel
	Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 10)
    
	local sectionsContainer = Instance.new("ScrollingFrame", sidebar)
	sectionsContainer.Size = UDim2.new(1, -14, 1, -16)
	sectionsContainer.Position = UDim2.new(0, 7, 0, 8)
	sectionsContainer.BackgroundTransparency = 1
	sectionsContainer.BorderSizePixel = 0
	sectionsContainer.ScrollBarThickness = 6
	local sectionsLayout = Instance.new("UIListLayout", sectionsContainer)
	sectionsLayout.Padding = UDim.new(0, 8)
	sectionsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() sectionsContainer.CanvasSize = UDim2.new(0, 0, 0, sectionsLayout.AbsoluteContentSize.Y) end)

	contentHost = Instance.new("Frame", rootFrame)
	contentHost.Size = UDim2.new(1, -sidebarWidth - 30, 1, -topPadding - 20)
	contentHost.Position = UDim2.new(0, sidebarWidth + 20, 0, topPadding + 2)
	contentHost.BackgroundColor3 = THEME.panel
	Instance.new("UICorner", contentHost).CornerRadius = UDim.new(0, 10)

	local panels = {}
	local panelNames = {"Main", "Player", "Helper", "Stealer", "Brainrot Finder", "Server Joiner", "Settings"}
	for _, name in ipairs(panelNames) do
		local panel = Instance.new("Frame", contentHost)
		panel.Name = name:gsub(" ", "") .. "Panel"
		panel.Size = UDim2.new(1, -10, 1, -10)
		panel.Position = UDim2.new(0, 5, 0, 5)
		panel.BackgroundColor3 = THEME.panel2
		panel.Visible = (name == "Main")
		Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)
		panels[name] = panel
	end
    
	mainPanel, playerPanel, helperPanel, stealerPanel, bfPanel, serverJoinerPanel, settingsPanel = panels["Main"], panels["Player"], panels["Helper"], panels["Stealer"], panels["Brainrot Finder"], panels["Server Joiner"], panels["Settings"]

	local buttonData = {
		{"Main", ASSETS.MAIN_ICON}, {"Player", ASSETS.PLAYER_ICON}, {"Helper", ASSETS.HELPER_ICON},
		{"Stealer", ASSETS.STEALER_ICON}, {"Brainrot Finder", ASSETS.FINDER_ICON},
		{"Server Joiner", ASSETS.SERVER_JOINER_ICON}, {"Settings", ASSETS.SETTINGS_ICON}
	}
	for _, data in ipairs(buttonData) do
		local btn = makeSectionButton(data[1], data[2])
		btn.Parent = sectionsContainer
		btn.Activated:Connect(function() setSection(data[1]) end)
	end
    
    -- >> [CORREGIDO] Se crean los contenedores de contenido para cada sección
    local mainContainer = Instance.new("ScrollingFrame", mainPanel)
    mainContainer.Size = UDim2.new(1, -20, 1, -58); mainContainer.Position = UDim2.new(0, 10, 0, 50); mainContainer.BackgroundTransparency = 1; mainContainer.ScrollBarThickness = 6;
    local mainLayout = Instance.new("UIListLayout", mainContainer); mainLayout.Padding = UDim.new(0, 8); mainLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() mainContainer.CanvasSize = UDim2.new(0,0,0,mainLayout.AbsoluteContentSize.Y) end)
    
    local playerContainer = Instance.new("ScrollingFrame", playerPanel)
    playerContainer.Size = UDim2.new(1, -20, 1, -58); playerContainer.Position = UDim2.new(0, 10, 0, 50); playerContainer.BackgroundTransparency = 1; playerContainer.ScrollBarThickness = 6;
    local playerLayout = Instance.new("UIListLayout", playerContainer); playerLayout.Padding = UDim.new(0, 8); playerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() playerContainer.CanvasSize = UDim2.new(0,0,0,playerLayout.AbsoluteContentSize.Y) end)

    local helperBody = Instance.new("ScrollingFrame", helperPanel)
    helperBody.Size = UDim2.new(1, -20, 1, -58); helperBody.Position = UDim2.new(0, 10, 0, 50); helperBody.BackgroundTransparency = 1; helperBody.ScrollBarThickness = 6;
    local helperLayout = Instance.new("UIListLayout", helperBody); helperLayout.Padding = UDim.new(0, 8); helperLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() helperBody.CanvasSize = UDim2.new(0,0,0,helperLayout.AbsoluteContentSize.Y) end)

    local stealerBody = Instance.new("ScrollingFrame", stealerPanel)
    stealerBody.Size = UDim2.new(1, -20, 1, -58); stealerBody.Position = UDim2.new(0, 10, 0, 50); stealerBody.BackgroundTransparency = 1; stealerBody.ScrollBarThickness = 6;
    local stealerLayout = Instance.new("UIListLayout", stealerBody); stealerLayout.Padding = UDim.new(0, 8); stealerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() stealerBody.CanvasSize = UDim2.new(0,0,0,stealerLayout.AbsoluteContentSize.Y) end)

    local settingsBody = Instance.new("ScrollingFrame", settingsPanel)
    settingsBody.Size = UDim2.new(1, -20, 1, -58); settingsBody.Position = UDim2.new(0, 10, 0, 50); settingsBody.BackgroundTransparency = 1; settingsBody.ScrollBarThickness = 6;
    local settingsLayout = Instance.new("UIListLayout", settingsBody); settingsLayout.Padding = UDim.new(0, 8); settingsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() settingsBody.CanvasSize = UDim2.new(0,0,0,settingsLayout.AbsoluteContentSize.Y) end)

	-- Se añaden las opciones a sus respectivos contenedores
	speedRow = makeThinRow(mainContainer, "Speed Hack", "speedHack", 1, 3, settings.speedHackValue, 1, function(v) SPEED_MULTIPLIER = v; settings.speedHackValue = v; if settings.autoSave then saveSettings() end end, settings.speedHackEnabled, function(v) speedActive = v; settings.speedHackEnabled = v; if settings.autoSave then saveSettings() end end)
	flyHackRow = createToggleRow(mainContainer, "Fly Hack", "flyHack", settings.flyHackEnabled, function(v) flyActive=v;settings.flyHackEnabled=v;if v then createFlyButtonGUI() else destroyFlyButtonGUI() end end)
	jumpRow = makeThinRow(mainContainer, "High Jump", "highJump", 50, 130, settings.highJumpValue, 0, function(v) HighJump.JumpPower=v;if Humanoid then Humanoid.JumpPower=v end;settings.highJumpValue=v end, settings.highJumpEnabled, function(v) HighJump.Enabled=v;if Humanoid then Humanoid.UseJumpPower=v;Humanoid.JumpPower=v and HighJump.JumpPower or 50 end end)
	infJumpRow = createToggleRow(mainContainer, "Infinite Jump", "infJump", settings.infJumpEnabled, function(v) infJumpEnabled=v;settings.infJumpEnabled=v end)
	
	playerESPRow = createToggleRow(helperBody, "Player ESP", "playerESP", settings.playerESPEnabled, function(v) playerESPEnabled=v;settings.playerESPEnabled=v end)
	hotbarESPRow = createToggleRow(helperBody, "Hotbar ESP", "hotbarESP", settings.hotbarESPEnabled, function(v) hotbarESPEnabled=v;settings.hotbarESPEnabled=v end)
	baseTimerESPRow = createToggleRow(helperBody, "Base Timer ESP", "baseTimerESP", settings.baseTimerESPEnabled, function(v) baseTimerESPEnabled=v;settings.baseTimerESPEnabled=v end)
	itemESPRow = createToggleRow(helperBody, "Item ESP", "itemESP", settings.itemESPEnabled, function(v) itemESPEnabled=v;settings.itemESPEnabled=v end)
	serverInfoRow = createToggleRow(helperBody, "Server Info", "serverInfo", settings.serverInfoEnabled, function(v) serverInfoEnabled=v;if v then createServerInfoGUI() else destroyServerInfoGUI() end end)
    
	instaBrainrotRow = createToggleRow(playerContainer, "Insta Brainrot Purchase", "instaBrainrot", settings.instaBrainrotEnabled, function(v) instaBrainrotEnabled=v;settings.instaBrainrotEnabled=v end)
	betterGraphicsRow = createToggleRow(playerContainer, "Better Graphics", "betterGraphics", settings.betterGraphicsEnabled, function(v) betterGraphicsEnabled=v;applyBetterGraphics(v) end)
	killAllRow = createToggleRow(playerContainer, "Kill All", "killAll", settings.killAllEnabled, function(v) killAllEnabled=v;if v then startKillAllLoop() else stopKillAllLoop() end end)
    
	freezerKillerRow = createToggleRow(stealerBody, "Freezer & Killer", "freezerKiller", settings.freezerKillerEnabled, function(v) freezerKillerEnabled=v;if v then startFreezerKiller() else stopFreezerKiller() end end)
	antiMedusaRow = createToggleRow(stealerBody, "Anti Medusa", "antiMedusa", settings.antiMedusaEnabled, function(v) antiMedusaEnabled=v;settings.antiMedusaEnabled=v end)
	autoMedusaCounterRow = createToggleRow(stealerBody, "Auto Medusa Counter", "autoMedusaCounter", settings.autoMedusaCounterEnabled, function(v) autoMedusaCounterEnabled=v;settings.autoMedusaCounterEnabled=v end)
    
	autoLoadRow = createToggleRow(settingsBody, "Auto Load", "autoLoad", settings.autoLoad, function(v) settings.autoLoad=v end)
	autoSaveRow = createToggleRow(settingsBody, "Auto Save", "autoSave", settings.autoSave, function(v) settings.autoSave=v;if v then saveSettings() end end)
	activeFunctionsRow = createToggleRow(settingsBody, "Active Functions", "activeFunctions", settings.activeFunctionsEnabled, function(v) activeFunctionsEnabled=v;if v then createActiveFunctionsGUI() else destroyActiveFunctionsGUI() end end)
	keybindsRow = createToggleRow(settingsBody, "Keybinds", "keybinds", settings.keybindsEnabled, function(v) keybindsEnabled=v;if v then createKeybindsGUI() else destroyKeybindsGUI() end end)

	setSection("Main")
end

-- El resto del script sigue aquí (mainLoop, inicialización, etc.)
-- ...

