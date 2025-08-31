------====================================================================== --[ SERVICIOS DE ROBLOX ] --====================================================================== local Players= game:GetService("Players") local RunService= game:GetService("RunService") local CoreGui= game:GetService("CoreGui") local UserInputService= game:GetService("UserInputService") local Workspace= game:GetService("Workspace")

--====================================================================== --[ VARIABLES PRINCIPALES ] --====================================================================== local LocalPlayer= Players.LocalPlayer local Camera= Workspace.CurrentCamera local ESP_Container= Instance.new("ScreenGui") -- Contenedor para los dibujos

--====================================================================== --[ CONFIGURACIÓN DEL SCRIPT ] --====================================================================== local CONFIG= { Enabled = true, MaxDistance = 500,  -- Distancia máxima en studs ShowBoxes = true,   -- Mostrar cajas 2D ShowNames = true,   -- Mostrar nombres ShowDistance = true,-- Mostrar distancia TeamCheck = false,  -- Si es 'true', no mostrará el ESP en compañeros de equipo EnemyColor = Color3.fromRGB(255, 60, 60), TeamColor = Color3.fromRGB(60, 255, 60) }

--====================================================================== --[ INICIALIZACIÓN ] --====================================================================== ESP_Container.Name= "ESP_GUI_Container" ESP_Container.ResetOnSpawn= false ESP_Container.ZIndexBehavior= Enum.ZIndexBehavior.Sibling ESP_Container.Parent= CoreGui

--====================================================================== --[ FUNCIONES AUXILIARES ] --======================================================================

-- Función para crear un elemento de dibujo (UI) local function CreateDrawing(className,properties) local element = Instance.new(className) for property, value in pairs(properties or {}) do pcall(function() element[property] = value end) end element.Parent = ESP_Container return element end

-- Función para limpiar todos los dibujos de la pantalla local function ClearDrawings() ESP_Container:ClearAllChildren() end

--====================================================================== --[ LÓGICA PRINCIPAL DEL ESP ] --======================================================================

local function OnRenderStep() ClearDrawings()

end

--====================================================================== --[ CONEXIONES ] --======================================================================

-- Conectar la función al renderizado de cada fotograma RunService.RenderStepped:Connect(OnRenderStep)

-- Atajo de teclado para activar/desactivar el ESP UserInputService.InputBegan:Connect(function(input,gameProcessed) if gameProcessed then return end

end)

print("Script de ESP cargado correctamente.")

