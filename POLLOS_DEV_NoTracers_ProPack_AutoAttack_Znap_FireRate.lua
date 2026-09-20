-- ==========================================
-- POLLOS DEV | Key System (GUI bloqueante)
-- La GUI no se cierra hasta validar una key correcta.
-- La key se guarda en pollos_dev_key.txt para no reescribirla.
-- ==========================================
local KEY_URL = "https://keydash-robux-magic.lovable.app/api/public/validate-key"
local KEY_FILE = "pollos_dev_key.txt"

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local HWID = "unknown"
pcall(function()
    HWID = game:GetService("RbxAnalyticsService"):GetClientId()
end)

local function ValidateKey(key)
    if not key or key == "" then
        return false, "Escribe tu key"
    end
    local ok, response = pcall(function()
        return game:HttpGet(KEY_URL .. "?key=" .. HttpService:UrlEncode(key) .. "&hwid=" .. HttpService:UrlEncode(HWID))
    end)
    if not ok then
        return false, "Error de conexion. Intenta de nuevo."
    end
    local decoded
    ok, decoded = pcall(function()
        return HttpService:JSONDecode(response)
    end)
    if not ok or type(decoded) ~= "table" then
        return false, "Respuesta invalida del servidor"
    end
    return decoded.success == true, decoded.message or ""
end

-- Auto-validar key guardada: si es valida, no se muestra la GUI
local savedKey = nil
pcall(function()
    if isfile and readfile and isfile(KEY_FILE) then
        savedKey = readfile(KEY_FILE)
    end
end)
if savedKey and savedKey ~= "" then
    savedKey = savedKey:gsub("%s+", "")
    local ok = ValidateKey(savedKey)
    if ok then
        -- Key guardada valida: saltar la GUI
        getgenv().POLLOS_DEV_KEY_VALIDATED = true
    end
end

if not getgenv().POLLOS_DEV_KEY_VALIDATED then
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "DMX_KeySystem"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function()
        ScreenGui.Parent = (gethui and gethui()) or LocalPlayer:WaitForChild("PlayerGui")
    end)
    if not ScreenGui.Parent then
        pcall(function() ScreenGui.Parent = CoreGui end)
    end
    if not ScreenGui.Parent then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.fromOffset(380, 220)
    Frame.AnchorPoint = Vector2.new(0.5, 0.5)
    Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    Frame.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
    Frame.BorderSizePixel = 0
    Frame.Active = true
    Frame.Draggable = true
    Frame.Parent = ScreenGui
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)
    local Stroke = Instance.new("UIStroke", Frame)
    Stroke.Color = Color3.fromRGB(70, 70, 78)
    Stroke.Thickness = 1.5

    local Header = Instance.new("Frame")
    Header.Name = "HeaderAccent"
    Header.Size = UDim2.new(1, -24, 0, 3)
    Header.Position = UDim2.new(0, 12, 0, 10)
    Header.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Header.BorderSizePixel = 0
    Header.Parent = Frame
    Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 2)

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundTransparency = 1
    Title.Text = "POLLOS DEV  |  Key System"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.Parent = Frame

    local Sub = Instance.new("TextLabel")
    Sub.Size = UDim2.new(1, -24, 0, 18)
    Sub.Position = UDim2.new(0, 12, 0, 38)
    Sub.BackgroundTransparency = 1
    Sub.Text = "Pega tu key para continuar"
    Sub.TextColor3 = Color3.fromRGB(150, 150, 170)
    Sub.Font = Enum.Font.Gotham
    Sub.TextSize = 12
    Sub.TextXAlignment = Enum.TextXAlignment.Left
    Sub.Parent = Frame

    local Box = Instance.new("TextBox")
    Box.Size = UDim2.new(1, -24, 0, 34)
    Box.Position = UDim2.new(0, 12, 0, 64)
    Box.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    Box.TextColor3 = Color3.fromRGB(255, 255, 255)
    Box.PlaceholderText = "XXXX-XXXX-XXXX-XXXX"
    Box.PlaceholderColor3 = Color3.fromRGB(90, 90, 110)
    Box.Font = Enum.Font.Code
    Box.TextSize = 14
    Box.Text = savedKey or ""
    Box.ClearTextOnFocus = false
    Box.Parent = Frame
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 8)
    local BoxStroke = Instance.new("UIStroke", Box)
    BoxStroke.Color = Color3.fromRGB(60, 60, 80)

    local Status = Instance.new("TextLabel")
    Status.Size = UDim2.new(1, -24, 0, 18)
    Status.Position = UDim2.new(0, 12, 0, 106)
    Status.BackgroundTransparency = 1
    Status.Text = ""
    Status.TextColor3 = Color3.fromRGB(255, 90, 90)
    Status.Font = Enum.Font.Gotham
    Status.TextSize = 12
    Status.TextXAlignment = Enum.TextXAlignment.Left
    Status.Parent = Frame

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -24, 0, 36)
    Button.Position = UDim2.new(0, 12, 0, 132)
    Button.BackgroundColor3 = Color3.fromRGB(99, 102, 241)
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Text = "Validar Key"
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 14
    Button.Parent = Frame
    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 8)

    local busy = false
    Button.MouseButton1Click:Connect(function()
        if busy then return end
        busy = true
        Button.Text = "Validando..."
        Status.Text = ""
        local key = Box.Text:gsub("%s+", "")
        task.spawn(function()
            local ok, msg = ValidateKey(key)
            busy = false
            Button.Text = "Validar Key"
            if ok then
                pcall(function()
                    if writefile then writefile(KEY_FILE, key) end
                end)
                Status.TextColor3 = Color3.fromRGB(90, 255, 140)
                Status.Text = "Key valida. Cargando POLLOS DEV..."
                task.wait(0.6)
                ScreenGui:Destroy()
                getgenv().POLLOS_DEV_KEY_VALIDATED = true
            else
                Status.TextColor3 = Color3.fromRGB(255, 90, 90)
                Status.Text = msg or "Key invalida"
            end
        end)
    end)

    -- Bloquear: el script principal no corre hasta validar
    repeat task.wait(0.2) until getgenv().POLLOS_DEV_KEY_VALIDATED == true
end

-- ==========================================
-- SCRIPT PRINCIPAL POLLOS DEV (solo corre con key valida)
-- ==========================================

-- ==========================================
-- POLLOS DEV | Block Spin (WindUI Indigo + English + Rainbow FOV)
-- Created by eldb0305 
-- ==========================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Camera = Workspace.CurrentCamera
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")

-- ==========================================
-- DROP ITEM ESP | VISUAL ONLY | SIEMPRE ACTIVO
-- ==========================================
local DropESP_Drawings = {}

local function DropESPRarityColor(model)
    local colors = {
        ["common"] = Color3.fromRGB(180,180,180),
        ["comun"] = Color3.fromRGB(180,180,180),
        ["común"] = Color3.fromRGB(180,180,180),
        ["uncommon"] = Color3.fromRGB(99,255,52),
        ["poco comun"] = Color3.fromRGB(99,255,52),
        ["poco común"] = Color3.fromRGB(99,255,52),
        ["rare"] = Color3.fromRGB(51,170,255),
        ["raro"] = Color3.fromRGB(51,170,255),
        ["epic"] = Color3.fromRGB(237,44,255),
        ["epico"] = Color3.fromRGB(237,44,255),
        ["épico"] = Color3.fromRGB(237,44,255),
        ["legendary"] = Color3.fromRGB(255,150,0),
        ["legendario"] = Color3.fromRGB(255,150,0),
        ["omega"] = Color3.fromRGB(255,20,51)
    }

    -- Lee distintas fuentes de rareza para que funcione con todas las armas.
    local rarity = model:GetAttribute("Rarity") or model:GetAttribute("RarityName")
    local rarityText = tostring(rarity or ""):lower():gsub("%s+", " ")
    rarityText = rarityText:gsub("^%s+", ""):gsub("%s+$", "")

    if colors[rarityText] then
        return colors[rarityText]
    end

    -- Algunos drops pueden guardar la rareza en un StringValue/Value.
    for _, obj in ipairs(model:GetDescendants()) do
        if obj:IsA("StringValue") or obj:IsA("IntValue") or obj:IsA("NumberValue") then
            local n = obj.Name:lower()
            if n == "rarity" or n == "rarityname" then
                local valueText = tostring(obj.Value):lower():gsub("%s+", " ")
                valueText = valueText:gsub("^%s+", ""):gsub("%s+$", "")
                if colors[valueText] then
                    return colors[valueText]
                end
            end
        end
    end

    -- Fallback específico para Draco, que es Épico.
    local nameText = tostring(model:GetAttribute("DisplayName") or model.Name or ""):lower()
    if nameText:find("draco", 1, true) then
        return colors["épico"]
    end

    return Color3.fromRGB(255,255,255)
end

local function DropESPRemove(model)
    local drawings = DropESP_Drawings[model]
    if drawings then
        for _, drawing in pairs(drawings) do
            pcall(function() drawing:Remove() end)
        end
        DropESP_Drawings[model] = nil
    end
end

local function DropESPUpdate()
    local droppedItems = Workspace:FindFirstChild("DroppedItems")
    if not droppedItems then return end

    for model, drawings in pairs(DropESP_Drawings) do
        if not model.Parent then
            DropESPRemove(model)
        else
            for _, drawing in pairs(drawings) do
                drawing.Visible = false
            end
        end
    end

    for _, model in ipairs(droppedItems:GetChildren()) do
        local zone = model:FindFirstChild("PickUpZone")
        if model:IsA("Model") and zone and not model:GetAttribute("Locked") then
            local pos, visible = Camera:WorldToViewportPoint(zone.Position)
            if visible then
                local color = DropESPRarityColor(model)
                local radius = math.clamp(100 / math.max(pos.Z, 0.1), 3, 6)

                if not DropESP_Drawings[model] then
                    DropESP_Drawings[model] = {
                        circle = Drawing.new("Circle"),
                        inner = Drawing.new("Circle"),
                        name = Drawing.new("Text"),
                        amount = Drawing.new("Text")
                    }

                    local d = DropESP_Drawings[model]
                    d.circle.Thickness = 2
                    d.circle.Transparency = 0.7
                    d.circle.Filled = false

                    d.inner.Thickness = 2
                    d.inner.Transparency = 1
                    d.inner.Filled = true

                    d.name.Outline = true
                    d.name.OutlineColor = Color3.new(0,0,0)
                    d.name.Center = true
                    d.name.Size = 16
                    d.name.Font = 4

                    d.amount.Outline = true
                    d.amount.OutlineColor = Color3.new(0,0,0)
                    d.amount.Center = true
                    d.amount.Size = 13
                end

                local d = DropESP_Drawings[model]
                d.circle.Position = Vector2.new(pos.X, pos.Y)
                d.circle.Radius = radius + 5
                d.circle.Color = color
                d.circle.Visible = true

                d.inner.Position = Vector2.new(pos.X, pos.Y)
                d.inner.Radius = radius
                d.inner.Color = color
                d.inner.Visible = true

                d.name.Position = Vector2.new(pos.X, pos.Y - radius - 20)
                d.name.Text = model.Name
                d.name.Color = color
                d.name.Visible = true

                local amount = model:GetAttribute("Amount") or 1
                d.amount.Position = Vector2.new(pos.X, pos.Y + radius + 15)
                d.amount.Text = amount > 1 and "[" .. tostring(amount) .. "]" or ""
                d.amount.Color = Color3.fromRGB(200,200,200)
                d.amount.Visible = amount > 1
            end
        end
    end
end

RunService.RenderStepped:Connect(DropESPUpdate)


local THIN_FONT = Enum.Font.SourceSansLight
local BOLD_FONT = Enum.Font.SourceSansBold

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "POLLOS DEV | Block Spin",
    Icon = "rbxassetid://72957354226500",
    Size = UDim2.fromOffset(820, 600),
    Theme = "Dark",
    Acrylic = false,
    Transparent = false,
    Background = "rbxassetid://9670994898",
    BackgroundImageTransparency = 0.20,
    HideSearchBar = false,
    OpenButton = {
        Title = "Open UI",
        Enabled = true,
        Color = ColorSequence.new(Color3.fromRGB(0, 0, 0), Color3.fromRGB(0, 0, 0)),
        StrokeThickness = 0,
    },
})

local TabMain = Window:Tab({ Title = "MAIN", Icon = "house" })
local TabCombat = Window:Tab({ Title = "COMBAT", Icon = "crosshair" })
local TabGuns = Window:Tab({ Title = "GUNS", Icon = "crosshair" })
local TabMovement = Window:Tab({ Title = "MOVEMENT", Icon = "move" })
local TabPlayer = Window:Tab({ Title = "PLAYER", Icon = "user" })
local TabVisual = Window:Tab({ Title = "VISUAL", Icon = "eye" })
local TabUtility = Window:Tab({ Title = "UTILITY", Icon = "settings" })

-- ==========================================
-- CREATOR INFO (MAIN TAB HEADER)
-- ==========================================
TabMain:Section({ Title = "Hub Information" })
TabMain:Paragraph({
    Title = "POLLOS DEV",
    Desc = "POLLOS DEV - Block Spin Edition",
})

-- ==========================================
-- REMOTE ENGINE HELPER
-- ==========================================
local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes", 10)
local SendRemote = RemotesFolder and RemotesFolder:FindFirstChild("Send")

local RemoteCounter
pcall(function()
    for _, obj in ipairs(getgc(true)) do
        if typeof(obj) == "table" and rawget(obj, "event") and rawget(obj, "func") then
            RemoteCounter = obj
            break
        end
    end
end)

local RawCallCount = 0
local function FireServerHook(...)
    if not SendRemote then return end
    local args = {...}
    if RemoteCounter and type(RemoteCounter.event) == "number" then
        RemoteCounter.event = RemoteCounter.event + 1
        pcall(function() SendRemote:FireServer(RemoteCounter.event, unpack(args)) end)
    else
        RawCallCount = RawCallCount + 1
        pcall(function() SendRemote:FireServer(RawCallCount, unpack(args)) end)
    end
end

-- ==========================================
-- VISUALS & TARGET LINE SETUP
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DMX_Visuals"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
pcall(function() ScreenGui.Parent = gethui and gethui() or CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local TargetLine = Instance.new("Frame")
TargetLine.Name = "TargetLine"
TargetLine.AnchorPoint = Vector2.new(0.5, 0.5)
TargetLine.BackgroundColor3 = Color3.fromRGB(255, 40, 40)
TargetLine.BackgroundTransparency = 0.05
TargetLine.BorderSizePixel = 0
TargetLine.Size = UDim2.fromOffset(0, 1.5)
TargetLine.Visible = false
TargetLine.ZIndex = 20
TargetLine.Parent = ScreenGui

local TargetMarker = Instance.new("Frame")
TargetMarker.Name = "TargetMarker"
TargetMarker.Size = UDim2.fromOffset(5, 5)
TargetMarker.AnchorPoint = Vector2.new(0.5, 0.5)
TargetMarker.BackgroundTransparency = 0.18
TargetMarker.BackgroundColor3 = Color3.fromRGB(185, 185, 190)
TargetMarker.BorderSizePixel = 0
TargetMarker.Visible = false
TargetMarker.ZIndex = 30
TargetMarker.Parent = ScreenGui

-- Marcador hueco en forma de diamante: ◇
local DiamondStroke = Instance.new("UIStroke")
DiamondStroke.Thickness = 0.75
DiamondStroke.Color = Color3.fromRGB(125, 125, 130)
DiamondStroke.Transparency = 0.15
DiamondStroke.Parent = TargetMarker
TargetMarker.Rotation = 45

local FOVCircleGui = Instance.new("Frame")
FOVCircleGui.Name = "StaticFOVCircle"
FOVCircleGui.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircleGui.Position = UDim2.fromScale(0.5, 0.5)
FOVCircleGui.BackgroundTransparency = 1
FOVCircleGui.Visible = false
FOVCircleGui.ZIndex = 50
FOVCircleGui.Parent = ScreenGui

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVCircleGui

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Thickness = 1.2
FOVStroke.Transparency = 0.2
FOVStroke.Color = Color3.fromRGB(135, 150, 255)
FOVStroke.Parent = FOVCircleGui

-- ==========================================
-- 16-LINE RAINBOW FOV CIRCLE & SILENT AIM UTILS
-- ==========================================
local fovLines = {}
local rainbowFovEnabled = false
local staticFovEnabled = false
local fovRadius = 120
local numLines = 16

local SilentAimEnabled = false
local TargetHitPart = "Head" -- First shot per locked target: Chest; following shots: Head
local CurrentLockedTarget = nil
local LastShotTarget = nil
local ShotCountForTarget = 0
local AutoAttackEnabled = false
local AutoAttackKnifeEnabled = false
local AutoAttackTargetPart = "Head"
local AutoAttackDelay = 0.10
local AutoAttackBusy = false

-- ==========================================
-- VISUALES DE DISPARO
-- Tracers rojo/azul eliminados a petición.
-- ==========================================

pcall(function()
    if Drawing and Drawing.new then
        for i = 1, numLines do
            local line = Drawing.new("Line")
            line.Visible = false
            line.Thickness = 2
            table.insert(fovLines, line)
        end
    end
end)

local RaycastParamsCache = RaycastParams.new()
RaycastParamsCache.FilterType = Enum.RaycastFilterType.Exclude
RaycastParamsCache.IgnoreWater = true

local function isInCarOrVehicle(char, targetPart)
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.SeatPart then return true end
    local parent = char.Parent
    while parent and parent ~= workspace do
        local pName = parent.Name:lower()
        if pName:find("vehicle") or pName:find("car") or pName:find("auto") or pName:find("moto") then
            return true
        end
        parent = parent.Parent
    end
    return false
end

local function isTargetVisibleOrInCar(targetPart)
    local char = LocalPlayer.Character
    local targetChar = targetPart and targetPart.Parent
    local head = char and char:FindFirstChild("Head")
    if not head or not targetPart or not targetChar then return false end

    if isInCarOrVehicle(targetChar, targetPart) then
        return true
    end

    local origin = head.Position
    local targetPos = targetPart.Position
    local direction = targetPos - origin

    RaycastParamsCache.FilterDescendantsInstances = {char, targetChar}
    local result = workspace:Raycast(origin, direction, RaycastParamsCache)

    if not result then
        return true
    else
        local hitPart = result.Instance
        if hitPart then
            local mat = hitPart.Material
            local name = hitPart.Name:lower()
            if mat == Enum.Material.Glass or name:find("glass") or name:find("window") or name:find("cristal") or name:find("vidrio") then
                RaycastParamsCache.FilterDescendantsInstances = {char, targetChar, hitPart}
                local secondResult = workspace:Raycast(result.Position + (direction.Unit * 0.5), targetPos - (result.Position + (direction.Unit * 0.5)), RaycastParamsCache)
                if not secondResult then return true end
            end
        end
        return false
    end
end

local VelocityCache = {}
RunService.Heartbeat:Connect(function()
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer and pl.Character then
            local root = pl.Character:FindFirstChild("HumanoidRootPart")
            local hum = pl.Character:FindFirstChild("Humanoid")
            if root and hum and hum.Health > 0 then
                VelocityCache[pl] = VelocityCache[pl] or {}
                table.insert(VelocityCache[pl], {time = os.clock(), pos = root.Position})
                if #VelocityCache[pl] > 8 then table.remove(VelocityCache[pl], 1) end
            else
                VelocityCache[pl] = nil
            end
        end
    end
end)

local function getCalculatedVelocity(pl, rootPart)
    if rootPart and rootPart.AssemblyLinearVelocity.Magnitude > 22 then
        return rootPart.AssemblyLinearVelocity
    end
    local data = VelocityCache[pl]
    if not data or #data < 2 then return Vector3.zero end
    local vel = Vector3.zero
    local count = 0
    for i = 2, #data do
        local dt = data[i].time - data[i - 1].time
        if dt > 0 then
            vel = vel + (data[i].pos - data[i - 1].pos) / dt
            count = count + 1
        end
    end
    return count > 0 and (vel / count) or Vector3.zero
end

local function getPing()
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if pGui and pGui:FindFirstChild("NetworkStats") and pGui.NetworkStats:FindFirstChild("PingLabel") then
        local ms = tonumber(pGui.NetworkStats.PingLabel.Text:match("%d+"))
        if ms then return math.clamp(ms / 1000, 0.04, 1.2) end
    end
    return 0.08
end

local function getSilentAimTargetPart(character)
    if not character then return nil end

    if TargetHitPart == "Head" then
        return character:FindFirstChild("Head")
            or character:FindFirstChild("UpperTorso")
            or character:FindFirstChild("Torso")
            or character:FindFirstChild("HumanoidRootPart")
    end

    return character:FindFirstChild("UpperTorso")
        or character:FindFirstChild("Torso")
        or character:FindFirstChild("HumanoidRootPart")
        or character:FindFirstChild("Head")
end

local function predictTargetPos(targetPart)
    if not targetPart then return Vector3.zero end
    local char = targetPart.Parent
    local pl = char and Players:GetPlayerFromCharacter(char)
    if not pl then return targetPart.Position end
    local vel = getCalculatedVelocity(pl, char:FindFirstChild("HumanoidRootPart"))
    local ping = getPing()
    return targetPart.Position + (vel * (ping + 0.15) * 1.5)
end

local function getClosestPlayerInFOV()
    local bestTarget = nil
    local shortestDist = 999999
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer and pl.Character then
            local char = pl.Character
            local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChild("Humanoid")
            if head and hum and hum.Health > 0 then
                if isTargetVisibleOrInCar(head) then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen and screenPos.Z > 0 then
                        local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        if screenDist <= fovRadius and screenDist < shortestDist then
                            shortestDist = screenDist
                            bestTarget = pl
                        end
                    end
                end
            end
        end
    end
    return bestTarget
end

local function updateTargetLineVisual()
    -- Solo marcador del objetivo: no dibuja líneas/tracers.
    if not SilentAimEnabled or not CurrentLockedTarget then
        TargetLine.Visible = false
        TargetMarker.Visible = false
        return
    end

    local targetChar = CurrentLockedTarget.Character
    if not targetChar then
        TargetLine.Visible = false
        TargetMarker.Visible = false
        return
    end

    local targetPart = getSilentAimTargetPart(targetChar)
    if not targetPart then
        TargetLine.Visible = false
        TargetMarker.Visible = false
        return
    end

    local targetPos, targetVis = Camera:WorldToViewportPoint(targetPart.Position)
    if not targetVis or targetPos.Z <= 0 then
        TargetLine.Visible = false
        TargetMarker.Visible = false
        return
    end

    TargetLine.Visible = false
    TargetMarker.Position = UDim2.fromOffset(targetPos.X, targetPos.Y)
    TargetMarker.Visible = true
end

-- Hook para Silent Aim con wallbang inteligente y alcance lejano
if SendRemote and hookfunction then
    local originalFireServer
    originalFireServer = hookfunction(SendRemote.FireServer, function(self, ...)
        if self ~= SendRemote then return originalFireServer(self, ...) end
        local args = {...}
        
        if args[2] == "shoot_gun" then
            local autoPart = getgenv().AstraTargetPart
            local hitPart = nil
            local activeTarget = nil

            if AutoAttackEnabled and autoPart and autoPart.Parent then
                hitPart = autoPart
                activeTarget = Players:GetPlayerFromCharacter(autoPart.Parent)
            elseif SilentAimEnabled and CurrentLockedTarget then
                activeTarget = CurrentLockedTarget
                local targetChar = activeTarget.Character
                if activeTarget ~= LastShotTarget then
                    LastShotTarget = activeTarget
                    ShotCountForTarget = 0
                end
                ShotCountForTarget += 1
                local aimPart = TargetHitPart
                hitPart = targetChar and (aimPart == "Head" and (targetChar:FindFirstChild("Head") or targetChar:FindFirstChild("UpperTorso") or targetChar:FindFirstChild("Torso") or targetChar:FindFirstChild("HumanoidRootPart")) or (targetChar:FindFirstChild("UpperTorso") or targetChar:FindFirstChild("Torso") or targetChar:FindFirstChild("HumanoidRootPart") or targetChar:FindFirstChild("Head")))
            end

            local myHead = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
            if hitPart and activeTarget and myHead and isTargetVisibleOrInCar(hitPart) then
                local predPos = predictTargetPos(hitPart)
                local startOrigin = myHead.Position
                args[4] = CFrame.new(startOrigin, predPos)
                args[5] = {
                    [1] = {
                        [1] = {
                            Instance = hitPart,
                            Normal = Vector3.new(0, 1, 0),
                            Position = predPos
                        }
                    }
                }
            end
        end
        return originalFireServer(self, unpack(args))
    end)
end

RunService.RenderStepped:Connect(function()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    -- Rainbow FOV
    if rainbowFovEnabled and #fovLines > 0 then
        pcall(function()
            local timeVal = tick() * 0.6
            for i, line in ipairs(fovLines) do
                local angle1 = math.rad((i - 1) * (360 / numLines))
                local angle2 = math.rad(i * (360 / numLines))
                
                local p1 = center + Vector2.new(math.cos(angle1), math.sin(angle1)) * fovRadius
                local p2 = center + Vector2.new(math.cos(angle2), math.sin(angle2)) * fovRadius
                
                line.From = p1
                line.To = p2
                
                local hue = (timeVal + (i / numLines)) % 1
                line.Color = Color3.fromHSV(hue, 1, 1)
                line.Visible = true
            end
        end)
    else
        for _, line in ipairs(fovLines) do
            line.Visible = false
        end
    end

    -- Static FOV Circle
    if staticFovEnabled then
        FOVCircleGui.Visible = true
        FOVCircleGui.Size = UDim2.fromOffset(fovRadius * 2, fovRadius * 2)
    else
        FOVCircleGui.Visible = false
    end

    CurrentLockedTarget = SilentAimEnabled and getClosestPlayerInFOV() or nil
    updateTargetLineVisual()
end)

TabCombat:Section({ Title = "Silent Aim & FOV" })
TabCombat:Toggle({
    Title = "Enable Silent Aim",
    Default = false,
    Callback = function(state)
        SilentAimEnabled = state
        WindUI:Notify({ Title = "POLLOS DEV", Content = state and "Silent Aim ENABLED" or "Silent Aim DISABLED", Duration = 1.5 })
    end
})
TabCombat:Dropdown({
    Title = "Silent Aim Target (default Head)",
    Values = {"Chest", "Head"},
    Value = "Head",
    AllowNone = false,
    Callback = function(value)
        if type(value) == "table" then
            value = value[1]
        end
        if value == "Head" or value == "Chest" then
            TargetHitPart = value
            WindUI:Notify({
                Title = "POLLOS DEV",
                Content = "Objetivo: " .. TargetHitPart,
                Duration = 1.2
            })
        end
    end
})


TabCombat:Section({ Title = "iOS" })
TabCombat:Toggle({
    Title = "Mostrar FOV",
    Default = false,
    Callback = function(state)
        staticFovEnabled = state
    end
})

TabCombat:Section({ Title = "CELS / Android" })
TabCombat:Toggle({
    Title = "Enable Rainbow FOV",
    Default = false,
    Callback = function(state)
        rainbowFovEnabled = state
    end
})
TabCombat:Slider({
    Title = "FOV Radius",
    Step = 5,
    Value = { Min = 30, Max = 400, Default = 120 },
    Callback = function(value)
        fovRadius = value
    end
})

-- ==========================================
-- AUTO ATTACK | integrado desde el script de referencia
-- ==========================================
local function isGunTool(tool)
    if not tool or not tool:IsA("Tool") then return false end
    if tool:FindFirstChild("Throw", true) or tool:FindFirstChild("KnifeClient", true) or tool:FindFirstChild("KnifeServer", true) then
        return false
    end
    local name = string.lower(tool.Name)
    local ignored = {"combat", "fist", "wallet", "phone", "punch", "boombox", "radio", "knife", "blade", "cuchillo", "dagger", "kunai", "sword", "toy", "juguete", "pizza", "burger", "teddy", "balloon", "drink", "food"}
    for _, word in ipairs(ignored) do
        if string.find(name, word, 1, true) then return false end
    end
    return true
end

local function getAutoAttackPart(character)
    if not character then return nil end
    if AutoAttackTargetPart == "Head" then
        return character:FindFirstChild("Head")
            or character:FindFirstChild("UpperTorso")
            or character:FindFirstChild("Torso")
            or character:FindFirstChild("HumanoidRootPart")
    end
    return character:FindFirstChild("UpperTorso")
        or character:FindFirstChild("Torso")
        or character:FindFirstChild("HumanoidRootPart")
        or character:FindFirstChild("Head")
end

local function findAutoAttackTarget()
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHead = myChar and myChar:FindFirstChild("Head")
    if not myRoot then return nil end

    local origin = myHead and myHead.Position or myRoot.Position
    local bestPart, bestDist, bestChar = nil, math.huge, nil
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local part = getAutoAttackPart(plr.Character)
            if hum and hum.Health > 0 and part then
                params.FilterDescendantsInstances = {myChar, plr.Character}
                local direction = part.Position - origin
                local visible = not workspace:Raycast(origin, direction, params)
                if visible then
                    local dist = direction.Magnitude
                    if dist < bestDist then
                        bestDist = dist
                        bestPart = part
                        bestChar = plr.Character
                    end
                end
            end
        end
    end
    return bestPart, bestChar
end

TabCombat:Section({ Title = "Auto Attack" })
TabCombat:Toggle({
    Title = "Auto Attack",
    Default = false,
    Callback = function(state)
        AutoAttackEnabled = state
        WindUI:Notify({
            Title = "POLLOS DEV",
            Content = state and "Auto Attack ENABLED" or "Auto Attack DISABLED",
            Duration = 1.5
        })
    end
})

TabCombat:Toggle({
    Title = "Auto Attack Knife",
    Default = false,
    Callback = function(state)
        AutoAttackKnifeEnabled = state
        WindUI:Notify({
            Title = "POLLOS DEV",
            Content = state and "Auto Attack Knife ENABLED" or "Auto Attack Knife DISABLED",
            Duration = 1.5
        })
    end
})

TabCombat:Dropdown({
    Title = "Auto Attack Target",
    Values = {"Head", "Chest"},
    Value = "Head",
    AllowNone = false,
    Callback = function(value)
        if type(value) == "table" then value = value[1] end
        if value == "Head" or value == "Chest" then
            AutoAttackTargetPart = value
        end
    end
})

TabCombat:Slider({
    Title = "Auto Attack Delay",
    Step = 0.01,
    Value = { Min = 0.03, Max = 0.50, Default = 0.10 },
    Callback = function(value)
        AutoAttackDelay = tonumber(value) or 0.10
    end
})

task.spawn(function()
    while task.wait(0.03) do
        if (AutoAttackEnabled or AutoAttackKnifeEnabled) and not AutoAttackBusy then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local tool = char and char:FindFirstChildOfClass("Tool")
            if hum and hum.Health > 0 and tool and tool:FindFirstChild("Handle") then
                local gun = isGunTool(tool)
                local allowed = (gun and AutoAttackEnabled) or ((not gun) and AutoAttackKnifeEnabled)
                if allowed then
                    local targetPart = findAutoAttackTarget()
                    if targetPart then
                        AutoAttackBusy = true
                        getgenv().AstraTargetPart = targetPart
                        pcall(function()
                            tool:Activate()
                            task.delay(0.02, function()
                                if tool and tool.Parent == char then
                                    pcall(function() tool:Deactivate() end)
                                end
                            end)
                        end)
                        task.delay(AutoAttackDelay, function()
                            AutoAttackBusy = false
                        end)
                    end
                end
            end
        end
    end
end)

-- ==========================================
-- GUNS CHANNEL (NO RECOIL + FIRE RATE)
-- ==========================================
TabGuns:Section({ Title = "Gun Options" })
local noRecoilEnabled = false
local FireRate = 100

TabGuns:Toggle({
    Title = "No Recoil / Spread",
    Default = false,
    Callback = function(state)
        noRecoilEnabled = state
        WindUI:Notify({ Title = "POLLOS DEV", Content = state and "No Recoil ENABLED" or "No Recoil DISABLED", Duration = 1.5 })
    end
})

TabGuns:Slider({
    Title = "Fire Rate",
    Step = 1,
    Value = { Min = 1, Max = 1000, Default = 100 },
    Callback = function(value)
        FireRate = tonumber(value) or 100
    end
})

local function applyFireRate(tool)
    if not tool or not tool:IsA("Tool") then
        return
    end
    for _, v in ipairs(tool:GetDescendants()) do
        if v:IsA("NumberValue") or v:IsA("IntValue") then
            local name = v.Name:lower()
            if name:find("firerate") or name:find("fire_rate") then
                v.Value = FireRate
            end
        end
    end
end

task.spawn(function()
    while true do
        pcall(function()
            local char = LocalPlayer.Character
            local backpack = LocalPlayer:FindFirstChild("Backpack")

            if char then
                for _, tool in ipairs(char:GetChildren()) do
                    if tool:IsA("Tool") then
                        if noRecoilEnabled then
                            for _, v in ipairs(tool:GetDescendants()) do
                                if (v:IsA("NumberValue") or v:IsA("IntValue")) and (v.Name:lower():find("recoil") or v.Name:lower():find("spread") or v.Name:lower():find("shake")) then
                                    v.Value = 0
                                end
                            end
                        end
                        applyFireRate(tool)
                    end
                end
            end

            if backpack then
                for _, tool in ipairs(backpack:GetChildren()) do
                    if tool:IsA("Tool") then
                        if noRecoilEnabled then
                            for _, v in ipairs(tool:GetDescendants()) do
                                if (v:IsA("NumberValue") or v:IsA("IntValue")) and (v.Name:lower():find("recoil") or v.Name:lower():find("spread") or v.Name:lower():find("shake")) then
                                    v.Value = 0
                                end
                            end
                        end
                        applyFireRate(tool)
                    end
                end
            end
        end)
        task.wait(0.5)
    end
end)

-- ==========================================
-- MAIN SECTION: OPTIMIZATION & CRATE SKIP
-- ==========================================
TabUtility:Section({ Title = "Performance & Crates" })

TabUtility:Toggle({
    Title = "Auto Player Optimization",
    Default = false,
    Callback = function(state)
        pcall(function()
            local lighting = game:GetService("Lighting")
            if state then
                lighting.GlobalShadows = false
                lighting.FogEnd = 9e9
                for _, v in ipairs(Workspace:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.Material = Enum.Material.SmoothPlastic
                        v.Reflectance = 0
                    end
                end
            else
                lighting.GlobalShadows = true
            end
        end)
    end
})

local enabledSkip = false
TabUtility:Toggle({
    Title = "Crate Skip",
    Default = false,
    Callback = function(state)
        enabledSkip = state
    end
})

task.spawn(function()
    while true do
        if enabledSkip then
            pcall(function()
                local modules = ReplicatedStorage:FindFirstChild("Modules")
                local crateMod = modules and modules:FindFirstChild("Game") and modules.Game:FindFirstChild("CrateSystem") and modules.Game.CrateSystem:FindFirstChild("Crate")
                if crateMod then
                    local CrateController = require(crateMod)
                    if CrateController and CrateController.class and CrateController.class.objects then
                        for _, crate in pairs(CrateController.class.objects) do
                            if crate.states and crate.states.open then crate.states.open.set(true) end
                            if CrateController.skipping and CrateController.skipping.set then CrateController.skipping.set(true) end
                        end
                    end
                end
            end)
            task.wait(0.1)
        else
            task.wait(1)
        end
    end
end)

-- ==========================================
-- ==========================================
-- BUTTON ZNAP | UNDER-GROUND MOVEMENT (V3)
-- Znap estilo "snap": conserva la posición X/Z y orientación,
-- baja exactamente la cantidad indicada y permite volver al punto original.
-- El movimiento del jugador en X/Z continúa normalmente mientras está abajo.
-- ==========================================
TabMovement:Section({ Title = "Znap" })

local SnapEnabled = false
local SnapDown = false
local SnapDepth = 0
local ButtonZnapEnabled = false
local SnapSavedPivot = nil
local SnapSavedHumanoidState = nil

local ZnapButton = Instance.new("TextButton")
ZnapButton.Name = "ButtonZnap"
ZnapButton.Size = UDim2.fromOffset(132, 48)
ZnapButton.Position = UDim2.new(0, 120, 0.24, 0)
ZnapButton.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
ZnapButton.BackgroundTransparency = 0.04
ZnapButton.TextColor3 = Color3.fromRGB(245, 245, 248)
ZnapButton.Text = "Znap"
ZnapButton.Font = Enum.Font.GothamBold
ZnapButton.TextSize = 17
ZnapButton.Visible = false
ZnapButton.ZIndex = 100
ZnapButton.Active = true
ZnapButton.Draggable = true
ZnapButton.Parent = ScreenGui

local zc = Instance.new("UICorner", ZnapButton)
zc.CornerRadius = UDim.new(0, 14)
local zs = Instance.new("UIStroke", ZnapButton)
zs.Color = Color3.fromRGB(90, 90, 105)
zs.Thickness = 1.5

local function getCharacter()
    local char = LocalPlayer.Character
    if not char or not char.Parent then return nil end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then return nil end
    return char, humanoid, root
end

local function setCharacterCollision(enabled)
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = enabled
        end
    end
end

local function restoreSnap()
    local char, humanoid, root = getCharacter()
    if not char then
        SnapSavedPivot = nil
        SnapDown = false
        return
    end

    if SnapSavedPivot then
        pcall(function()
            char:PivotTo(SnapSavedPivot)
        end)
    end

    pcall(function()
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        local v = root.AssemblyLinearVelocity
        root.AssemblyLinearVelocity = Vector3.new(v.X, 0, v.Z)
    end)

    setCharacterCollision(true)
    SnapSavedPivot = nil
    SnapDown = false
    ZnapButton.Text = "Znap"
    ZnapButton.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
end

local function activateSnap()
    if SnapDepth <= 0 then
        WindUI:Notify({
            Title = "POLLOS DEV",
            Content = "Pon una cantidad en Znap Depth primero.",
            Duration = 2
        })
        return
    end

    if not SnapEnabled then
        WindUI:Notify({
            Title = "POLLOS DEV",
            Content = "Activa Znap primero.",
            Duration = 1.5
        })
        return
    end

    local char, humanoid, root = getCharacter()
    if not char then return end

    if SnapDown then
        restoreSnap()
        return
    end

    -- Guardamos el pivote EXACTO para regresar al mismo sitio.
    SnapSavedPivot = char:GetPivot()

    -- Bajamos solo en Y; X/Z y orientación permanecen iguales.
    local undergroundPivot = SnapSavedPivot * CFrame.new(0, -SnapDepth, 0)
    pcall(function()
        char:PivotTo(undergroundPivot)
    end)

    SnapDown = true
    setCharacterCollision(false)
    ZnapButton.Text = "Znap • DOWN"
    ZnapButton.BackgroundColor3 = Color3.fromRGB(55, 70, 92)
end

ZnapButton.MouseButton1Click:Connect(function()
    if not ButtonZnapEnabled then return end
    activateSnap()
end)

-- PRIMERO: Button Znap
TabMovement:Toggle({
    Title = "Button Znap",
    Default = false,
    Callback = function(state)
        ButtonZnapEnabled = state
        ZnapButton.Visible = state
        if not state and SnapDown then
            restoreSnap()
        end
    end
})

-- SEGUNDO: opción Znap
TabMovement:Toggle({
    Title = "Znap",
    Default = false,
    Callback = function(state)
        SnapEnabled = state
        if not state and SnapDown then
            restoreSnap()
        end
    end
})

-- TERCERO: cantidad/profundidad
TabMovement:Slider({
    Title = "Znap Depth (Studs)",
    Step = 1,
    Value = { Min = 1, Max = 100, Default = 10 },
    Callback = function(value)
        SnapDepth = math.max(0, tonumber(value) or 0)
    end
})

-- Si el personaje reaparece, limpiamos el estado para evitar un pivote viejo.
LocalPlayer.CharacterAdded:Connect(function()
    SnapSavedPivot = nil
    SnapDown = false
    task.wait(0.5)
    if ZnapButton then
        ZnapButton.Text = "Znap"
        ZnapButton.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
    end
end)

-- PLAYER SECTION (AUTO PICK, STAMINA, SPEED, ANTI KILL, JUMP, HIDE NAME)
-- ==========================================
TabPlayer:Section({ Title = "Items & Protection" })

-- Auto Pickup Items
local AutoPickupEnabled = false
task.spawn(function()
    while true do
        if AutoPickupEnabled then
            pcall(function()
                local character = LocalPlayer.Character
                local root = character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso"))
                if root then
                    local droppedFolder = Workspace:FindFirstChild("DroppedItems")
                    if droppedFolder then
                        for _, item in ipairs(droppedFolder:GetChildren()) do
                            local targetPart = item:IsA("Model") and (item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")) or item
                            if targetPart then
                                local prompt = item:FindFirstChildOfClass("ProximityPrompt") or targetPart:FindFirstChildOfClass("ProximityPrompt")
                                if prompt then fireproximityprompt(prompt) end
                                local touchPart = item:FindFirstChild("PickUpZone") or targetPart
                                if touchPart then
                                    firetouchinterest(root, touchPart, 0)
                                    firetouchinterest(root, touchPart, 1)
                                end
                            end
                        end
                    end
                end
            end)
            task.wait(0.2)
        else
            task.wait(1)
        end
    end
end)

TabPlayer:Toggle({
    Title = "Auto Pickup Items",
    Default = false,
    Callback = function(state)
        AutoPickupEnabled = state
        WindUI:Notify({ Title = "POLLOS DEV", Content = state and "Auto Pick ENABLED" or "Auto Pick DISABLED", Duration = 1.5 })
    end
})

-- Infinite Stamina (100% Funcional - Dual Module + Remote Sync)
local InfStaminaEnabled = false
local OriginalSprintUpdate = nil
local AutoSprintLoop = nil

local function toggleInfStamina(enable)
    InfStaminaEnabled = enable
    pcall(function()
        local success, sprintModule = pcall(function()
            return require(ReplicatedStorage.Modules.Game.Sprint)
        end)
        if success and sprintModule then
            local consumeFunc = sprintModule.consume_stamina
            local upvalues = getupvalues(consumeFunc)
            local sprintBar
            for _, uv in ipairs(upvalues) do
                if type(uv) == "table" and rawget(uv, "sprint_bar") then
                    sprintBar = uv.sprint_bar
                    break
                end
            end
            
            if sprintBar then
                if enable then
                    local originalUpdate = sprintBar.update
                    sprintBar.update = function(...)
                        return originalUpdate(function() return 1 end)
                    end
                    OriginalSprintUpdate = originalUpdate
                    
                    if AutoSprintLoop then task.cancel(AutoSprintLoop) end
                    AutoSprintLoop = task.spawn(function()
                        while InfStaminaEnabled do
                            pcall(function()
                                FireServerHook("set_sprinting_1", true)
                                task.wait(0.5)
                                FireServerHook("set_sprinting_1", false)
                            end)
                            task.wait(0.1)
                        end
                        pcall(function() FireServerHook("set_sprinting_1", false) end)
                    end)
                else
                    if AutoSprintLoop then
                        task.cancel(AutoSprintLoop)
                        AutoSprintLoop = nil
                    end
                    pcall(function() FireServerHook("set_sprinting_1", false) end)
                    if OriginalSprintUpdate and sprintBar then
                        sprintBar.update = OriginalSprintUpdate
                        OriginalSprintUpdate = nil
                    end
                end
            end
        end
    end)
end

TabMovement:Section({ Title = "Stamina & Speed" })

TabMovement:Toggle({
    Title = "Infinite Stamina",
    Default = false,
    Callback = function(state)
        toggleInfStamina(state)
        WindUI:Notify({ Title = "POLLOS DEV", Content = state and "Inf Stamina ENABLED" or "Inf Stamina DISABLED", Duration = 1.5 })
    end
})

-- Speed Hack
local SpeedHackEnabled = false
local SpeedValue = 4
TabMovement:Toggle({
    Title = "Speed Hack",
    Default = false,
    Callback = function(state)
        SpeedHackEnabled = state
    end
})
TabMovement:Slider({
    Title = "Speed Level",
    Step = 1,
    Value = { Min = 1, Max = 20, Default = 4 },
    Callback = function(value)
        SpeedValue = value
    end
})

RunService.RenderStepped:Connect(function(dt)
    if SpeedHackEnabled and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hum and root and hum.MoveDirection.Magnitude > 0 then
            local factor = (SpeedValue / 20) * 1.8
            local moveVec = hum.MoveDirection.Unit * (factor * 14 * dt)
            root.CFrame = root.CFrame + Vector3.new(moveVec.X, 0, moveVec.Z)
        end
    end
end)

-- Anti Kill Engine (reemplazado por el sistema Auto-Safe) 
local antiKillEnabled = false
local AutoSafeActive = false
local AutoSafeDepth = 25
local SavedAutoSafeY = nil
local TargetAutoSafeY = nil
local FrozenCameraCFrame = nil

local function resetAntiKill()
    AutoSafeActive = false
    TargetAutoSafeY = nil
    SavedAutoSafeY = nil
    FrozenCameraCFrame = nil
end

RunService.RenderStepped:Connect(function()
    if not antiKillEnabled or not LocalPlayer.Character then return end

    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end

    if hum.Health > 0 then
        if hum.Health <= 30 and not AutoSafeActive then
            AutoSafeActive = true
            SavedAutoSafeY = root.Position.Y
            TargetAutoSafeY = SavedAutoSafeY - AutoSafeDepth
            FrozenCameraCFrame = Camera.CFrame
        end

        if AutoSafeActive then
            if TargetAutoSafeY then
                local offsetX = math.sin(os.clock() * 35) * 3.5
                local offsetZ = math.cos(os.clock() * 35) * 3.5
                root.CFrame = CFrame.new(
                    root.Position.X + offsetX,
                    TargetAutoSafeY,
                    root.Position.Z + offsetZ
                )
                root.AssemblyLinearVelocity = Vector3.zero
            end

            if FrozenCameraCFrame then
                Camera.CFrame = FrozenCameraCFrame
            end

            if hum.Health >= 40 then
                AutoSafeActive = false
                if SavedAutoSafeY then
                    root.CFrame = CFrame.new(
                        root.Position.X,
                        SavedAutoSafeY + 1.5,
                        root.Position.Z
                    )
                end
                TargetAutoSafeY = nil
                SavedAutoSafeY = nil
                FrozenCameraCFrame = nil
            end
        end
    else
        resetAntiKill()
    end
end)

LocalPlayer.CharacterAdded:Connect(resetAntiKill)

TabPlayer:Toggle({
    Title = "Anti Kill",
    Default = false,
    Callback = function(state)
        antiKillEnabled = state
        if not state then
            resetAntiKill()
        end
        WindUI:Notify({
            Title = "POLLOS DEV",
            Content = state and "Anti Kill ENABLED" or "Anti Kill DISABLED",
            Duration = 1.5
        })
    end
})

-- Jump Power & Infinite Jump
local InfiniteJumpEnabled = false
local JumpPowerBypassValue = 50

TabMovement:Section({ Title = "Jump" })

TabMovement:Toggle({
    Title = "Infinite Jump",
    Default = false,
    Callback = function(state)
        InfiniteJumpEnabled = state
        WindUI:Notify({ Title = "POLLOS DEV", Content = state and "Infinite Jump ENABLED" or "Infinite Jump DISABLED", Duration = 1.5 })
    end
})

TabMovement:Slider({
    Title = "Jump Power",
    Step = 5,
    Value = { Min = 40, Max = 150, Default = 50 },
    Callback = function(value)
        JumpPowerBypassValue = value
    end
})

UserInputService.JumpRequest:Connect(function()
    if InfiniteJumpEnabled then
        pcall(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if hum and root then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
                root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, JumpPowerBypassValue, root.AssemblyLinearVelocity.Z)
            end
        end)
    end
end)

-- Hide Name (Quitar Nombre)
local HideNameEnabled = false
local function updateNameVisibility(hidden)
    pcall(function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local bb = root and root:FindFirstChild("CharacterBillboardGui")
        if bb and bb:FindFirstChild("PlayerName") then
            bb.PlayerName.Visible = not hidden
        end
    end)
end

TabPlayer:Toggle({
    Title = "Hide Name",
    Default = false,
    Callback = function(state)
        HideNameEnabled = state
        updateNameVisibility(state)
        WindUI:Notify({ Title = "POLLOS DEV", Content = state and "Hide Name ENABLED" or "Hide Name DISABLED", Duration = 1.5 })
    end
})

LocalPlayer.CharacterAdded:Connect(function()
    if HideNameEnabled then
        task.wait(1)
        updateNameVisibility(true)
    end
end)

-- ==========================================
-- VISUAL SECTION (NAMES, INVENTORY ESP, ESP ARMAS)
-- ==========================================
TabVisual:Section({ Title = "Player ESP" })

local namesESPEnabled = false
local healthBarESPEnabled = false
local inventoryESPEnabled = false
local weaponESPEnabled = false

local WeaponRegistry = {}
local PlayerBillboards = {}
local WeaponBillboards = {}
local WeaponCacheTokens = {}

local RarityColors = {
    Common = Color3.fromRGB(180, 180, 180),
    Uncommon = Color3.fromRGB(0, 255, 0),
    Rare = Color3.fromRGB(0, 112, 221),
    Epic = Color3.fromRGB(163, 53, 238),
    Legendary = Color3.fromRGB(255, 128, 0)
}

local function registerItems(folder)
    if not folder then return end
    for _, tool in ipairs(folder:GetChildren()) do
        if tool:IsA("Tool") then
            local handle      = tool:FindFirstChild("Handle")
            local displayName = tool:GetAttribute("DisplayName") or tool.Name
            local itemId      = tool:GetAttribute("ItemId") or tool:GetAttribute("Id") or tool.Name
            local rarity      = tool:GetAttribute("RarityName") or "Common"
            local imageId     = tool:GetAttribute("ImageId") or "rbxassetid://7072725737"
            local key
            if handle then
                local mesh = handle:FindFirstChildOfClass("SpecialMesh")
                if mesh and mesh.MeshId ~= "" then
                    key = mesh.MeshId .. (mesh.TextureId or "") .. "_RARITY_" .. rarity
                elseif handle:IsA("MeshPart") and handle.MeshId ~= "" then
                    key = handle.MeshId .. (handle.TextureID or "") .. "_RARITY_" .. rarity
                end
            end
            if not key and itemId and itemId ~= "" and itemId ~= tool.Name then
                key = "ITEMID_" .. itemId .. "_RARITY_" .. rarity
            end
            if not key then
                key = "NAME_" .. displayName .. "_" .. tool.Name .. "_RARITY_" .. rarity
            end
            WeaponRegistry[key] = { Name = displayName, Rarity = rarity, ImageId = imageId, ToolName = tool.Name }
        end
    end
end

local function getItemKey(tool)
    local handle      = tool:FindFirstChild("Handle")
    local displayName = tool:GetAttribute("DisplayName") or tool.Name
    local itemId      = tool:GetAttribute("ItemId") or tool:GetAttribute("Id") or tool.Name
    local rarity      = tool:GetAttribute("RarityName") or "Common"
    if handle then
        local mesh = handle:FindFirstChildOfClass("SpecialMesh")
        if mesh and mesh.MeshId ~= "" then return mesh.MeshId .. (mesh.TextureId or "") .. "_RARITY_" .. rarity end
        if handle:IsA("MeshPart") and handle.MeshId ~= "" then return handle.MeshId .. (handle.TextureID or "") .. "_RARITY_" .. rarity end
    end
    if itemId and itemId ~= "" and itemId ~= tool.Name then return "ITEMID_" .. itemId .. "_RARITY_" .. rarity end
    return "NAME_" .. displayName .. "_" .. tool.Name .. "_RARITY_" .. rarity
end

local function getWeaponInfo(tool)
    if not tool or not tool:IsA("Tool") then return nil end
    return WeaponRegistry[getItemKey(tool)]
end

local function createBillboardForPlayer(player)
    if not namesESPEnabled and not healthBarESPEnabled and not inventoryESPEnabled then return end
    if player == LocalPlayer then return end
    local char = player.Character
    if not char then return end
    local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
    if not head then return end
    if PlayerBillboards[player] then
        PlayerBillboards[player]:Destroy()
        PlayerBillboards[player] = nil
    end
    
    local gui = Instance.new("BillboardGui")
    gui.Name        = "DMX_ESP"
    gui.Adornee     = head
    gui.Size        = UDim2.new(0, 160, 0, 88)
    gui.StudsOffset = Vector3.new(0, 2.8, 0)
    gui.AlwaysOnTop = true
    gui.Parent      = char
    
    local layout = Instance.new("UIListLayout", gui)
    layout.FillDirection       = Enum.FillDirection.Vertical
    layout.SortOrder           = Enum.SortOrder.LayoutOrder
    layout.Padding             = UDim.new(0, 4)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    if namesESPEnabled then
        local nameLbl = Instance.new("TextLabel", gui)
        nameLbl.Size = UDim2.new(1, 0, 0, 16)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text = player.Name
        nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLbl.TextStrokeTransparency = 0
        nameLbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLbl.Font = Enum.Font.GothamBold
        nameLbl.TextSize = 14
        nameLbl.LayoutOrder = 1
    end
    
    if healthBarESPEnabled then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            -- Health Bar PRO: cápsula redondeada, borde fino, brillo y porcentaje.
            local healthRow = Instance.new("Frame", gui)
            healthRow.Name = "HealthRow"
            healthRow.Size = UDim2.new(0, 148, 0, 24)
            healthRow.BackgroundTransparency = 1
            healthRow.LayoutOrder = 2

            local healthBg = Instance.new("Frame", healthRow)
            healthBg.Name = "HealthBar"
            healthBg.Size = UDim2.new(0, 118, 0, 12)
            healthBg.Position = UDim2.new(0, 0, 0.5, -6)
            healthBg.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
            healthBg.BorderSizePixel = 0
            Instance.new("UICorner", healthBg).CornerRadius = UDim.new(1, 0)
            local bgStroke = Instance.new("UIStroke", healthBg)
            bgStroke.Color = Color3.fromRGB(115, 115, 125)
            bgStroke.Thickness = 1
            bgStroke.Transparency = 0.15

            local healthFill = Instance.new("Frame", healthBg)
            healthFill.Name = "HealthFill"
            healthFill.Size = UDim2.new(math.clamp(humanoid.Health / math.max(humanoid.MaxHealth, 1), 0, 1), 0, 1, 0)
            healthFill.BackgroundColor3 = Color3.fromRGB(75, 235, 115)
            healthFill.BorderSizePixel = 0
            Instance.new("UICorner", healthFill).CornerRadius = UDim.new(1, 0)
            local fillGradient = Instance.new("UIGradient", healthFill)
            fillGradient.Rotation = 0
            fillGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(70, 255, 125)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 185, 85))
            })

            local healthText = Instance.new("TextLabel", healthRow)
            healthText.Name = "HealthText"
            healthText.Size = UDim2.new(0, 30, 1, 0)
            healthText.Position = UDim2.new(0, 120, 0, 0)
            healthText.BackgroundTransparency = 1
            healthText.Text = tostring(math.floor(humanoid.Health)) .. "%"
            healthText.TextColor3 = Color3.fromRGB(235, 235, 240)
            healthText.TextStrokeTransparency = 0.55
            healthText.Font = Enum.Font.GothamBold
            healthText.TextSize = 11
            healthText.TextXAlignment = Enum.TextXAlignment.Left
        end
    end

    if inventoryESPEnabled then
        local toolsContainer = Instance.new("Frame", gui)
        toolsContainer.Name = "InventoryIcons"
        toolsContainer.Size = UDim2.new(1, -8, 0, 44)
        toolsContainer.BackgroundTransparency = 1
        toolsContainer.LayoutOrder = 3

        -- Inventory ESP: 2 filas, hasta 5 iconos por fila.
        local grid = Instance.new("UIGridLayout", toolsContainer)
        grid.CellSize = UDim2.fromOffset(22, 22)
        grid.CellPadding = UDim2.fromOffset(4, 2)
        grid.FillDirection = Enum.FillDirection.Horizontal
        grid.FillDirectionMaxCells = 5
        grid.SortOrder = Enum.SortOrder.LayoutOrder
        grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
        grid.VerticalAlignment = Enum.VerticalAlignment.Center

        local tools = {}
        for _, bag in ipairs({ "Backpack", "StarterGear", "StarterPack" }) do
            local b = player:FindFirstChild(bag)
            if b then
                for _, t in ipairs(b:GetChildren()) do
                    if t:IsA("Tool") and t.Name ~= "Fists" then table.insert(tools, t) end
                end
            end
        end
        for _, t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") and t.Name ~= "Fists" then table.insert(tools, t) end
        end
        for _, tool in ipairs(tools) do
            local info = getWeaponInfo(tool)
            if info then
                local img = Instance.new("ImageLabel", toolsContainer)
                img.Size                   = UDim2.fromOffset(22, 22)
                img.BackgroundTransparency = 0.1
                img.Image                  = info.ImageId
                img.BackgroundColor3       = Color3.fromRGB(240, 248, 255)
                Instance.new("UICorner", img).CornerRadius = UDim.new(0, 10)
                local stroke = Instance.new("UIStroke", img)
                stroke.Color    = RarityColors[info.Rarity] or Color3.new(1, 1, 1)
                stroke.Thickness = 2
            end
        end
    end
    
    PlayerBillboards[player] = gui
end

task.spawn(function()
    while true do
        task.wait(0.1)

        if healthBarESPEnabled then
            for player, gui in pairs(PlayerBillboards) do
                local char = player.Character
                local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                local healthRow = gui and gui:FindFirstChild("HealthRow")
                local healthBg = healthRow and healthRow:FindFirstChild("HealthBar")
                local healthFill = healthBg and healthBg:FindFirstChild("HealthFill")
                local healthText = healthRow and healthRow:FindFirstChild("HealthText")
                if humanoid and healthFill then
                    local ratio = math.clamp(humanoid.Health / math.max(humanoid.MaxHealth, 1), 0, 1)
                    healthFill.Size = UDim2.new(ratio, 0, 1, 0)
                    if healthText then healthText.Text = tostring(math.floor(ratio * 100)) .. "%" end

                    -- Verde -> amarillo -> rojo según la vida restante.
                    if ratio > 0.5 then
                        local t = (ratio - 0.5) * 2
                        healthFill.BackgroundColor3 = Color3.fromRGB(
                            math.floor(255 - (210 * t)),
                            220,
                            70
                        )
                    else
                        local t = ratio * 2
                        healthFill.BackgroundColor3 = Color3.fromRGB(
                            255,
                            math.floor(55 + (165 * t)),
                            55
                        )
                    end
                end
            end
        end

        if weaponESPEnabled then
            for _, pl in ipairs(Players:GetPlayers()) do
                if pl ~= LocalPlayer and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
                    local char = pl.Character
                    local root = char.HumanoidRootPart
                    local tools = {}
                    local token = ""
                    local bp = pl:FindFirstChild("Backpack")
                    if bp then
                        for _, t in ipairs(bp:GetChildren()) do 
                            if t:IsA("Tool") and t.Name ~= "Fists" then 
                                table.insert(tools, t) 
                                token = token .. t.Name .. "_"
                            end 
                        end
                    end
                    for _, t in ipairs(char:GetChildren()) do 
                        if t:IsA("Tool") and t.Name ~= "Fists" then 
                            table.insert(tools, t) 
                            token = token .. t.Name .. "_E_"
                        end 
                    end
                    
                    local bg = WeaponBillboards[pl]
                    if not bg or not bg.Parent or bg.Adornee ~= root then
                        if bg then pcall(function() bg:Destroy() end) end
                        bg = Instance.new("BillboardGui")
                        bg.Name = "WeaponESP_" .. pl.Name
                        bg.Adornee = root
                        bg.Size = UDim2.new(0, 140, 0, 24)
                        bg.StudsOffset = Vector3.new(0, -3.8, 0)
                        bg.AlwaysOnTop = true
                        bg.Parent = CoreGui
                        
                        local layout = Instance.new("UIListLayout", bg)
                        layout.FillDirection = Enum.FillDirection.Horizontal
                        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                        layout.Padding = UDim.new(0, 4)
                        
                        WeaponBillboards[pl] = bg
                        WeaponCacheTokens[pl] = nil
                    end

                    if WeaponCacheTokens[pl] ~= token then
                        WeaponCacheTokens[pl] = token
                        bg:ClearAllChildren()
                        local layout = Instance.new("UIListLayout", bg)
                        layout.FillDirection = Enum.FillDirection.Horizontal
                        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                        layout.Padding = UDim.new(0, 4)
                        
                        for _, t in ipairs(tools) do
                            local info = getWeaponInfo(t)
                            if info then
                                local icon = Instance.new("ImageLabel", bg)
                                icon.Size = UDim2.new(0, 22, 0, 22)
                                icon.BackgroundTransparency = 0.2
                                icon.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
                                icon.Image = info.ImageId
                                Instance.new("UICorner", icon).CornerRadius = UDim.new(0, 6)
                                local stroke = Instance.new("UIStroke", icon)
                                stroke.Color = RarityColors[info.Rarity] or Color3.fromRGB(255, 255, 255)
                                stroke.Thickness = 1.5
                            end
                        end
                    end
                end
            end
        else
            for _, bg in pairs(WeaponBillboards) do bg:Destroy() end
            WeaponBillboards = {}
            WeaponCacheTokens = {}
        end
    end
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if namesESPEnabled or healthBarESPEnabled or inventoryESPEnabled then
            task.wait(0.2)
            createBillboardForPlayer(player)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    if PlayerBillboards[player] then
        PlayerBillboards[player]:Destroy()
        PlayerBillboards[player] = nil
    end
    if WeaponBillboards[player] then
        WeaponBillboards[player]:Destroy()
        WeaponBillboards[player] = nil
    end
    WeaponCacheTokens[player] = nil
end)

task.spawn(function()
    local Items = ReplicatedStorage:WaitForChild("Items", 15)
    if Items then
        for _, folderName in ipairs({ "gun", "melee", "throwable", "consumable", "farming", "misc", "rod", "fish" }) do
            local folder = Items:FindFirstChild(folderName)
            if folder then
                registerItems(folder)
            end
        end
    end
end)

local function refreshAll()
    for _, p in ipairs(Players:GetPlayers()) do
        if namesESPEnabled or healthBarESPEnabled or inventoryESPEnabled then
            createBillboardForPlayer(p)
        else
            if PlayerBillboards[p] then
                PlayerBillboards[p]:Destroy()
                PlayerBillboards[p] = nil
            end
        end
    end
end

TabVisual:Toggle({
    Title = "Player Names",
    Default = false,
    Callback = function(state)
        namesESPEnabled = state
        refreshAll()
    end
})

TabVisual:Toggle({
    Title = "Health Bar",
    Default = false,
    Callback = function(state)
        healthBarESPEnabled = state
        refreshAll()
    end
})

TabVisual:Section({ Title = "Item & Weapon ESP" })

TabVisual:Toggle({
    Title = "Inventory ESP",
    Default = false,
    Callback = function(state)
        inventoryESPEnabled = state
        refreshAll()
    end
})

TabVisual:Toggle({
    Title = "ESP Armas",
    Default = false,
    Callback = function(state)
        weaponESPEnabled = state
        if not state then
            for _, bg in pairs(WeaponBillboards) do bg:Destroy() end
            WeaponBillboards = {}
            WeaponCacheTokens = {}
        end
        WindUI:Notify({ Title = "POLLOS DEV", Content = state and "ESP Armas ENABLED" or "ESP Armas DISABLED", Duration = 1.5 })
    end
})


-- ==========================================
-- CROSSHAIR + TARGET HIGHLIGHT
-- ==========================================
TabVisual:Section({ Title = "Combat Visuals" })

local crosshairEnabled = false
local crosshairSize = 8
local crosshairGap = 4
local crosshairParts = {}
local targetHighlightEnabled = false
local targetHighlight = nil

local crosshairGui = Instance.new("ScreenGui")
crosshairGui.Name = "POLLOS_DEV_Crosshair"
crosshairGui.ResetOnSpawn = false
crosshairGui.IgnoreGuiInset = true
crosshairGui.DisplayOrder = 9999
crosshairGui.Parent = CoreGui

local function makeCrossPart(name)
    local f = Instance.new("Frame")
    f.Name = name
    f.BorderSizePixel = 0
    f.BackgroundColor3 = Color3.fromRGB(245, 245, 250)
    f.AnchorPoint = Vector2.new(0.5, 0.5)
    f.Parent = crosshairGui
    return f
end

crosshairParts.Top = makeCrossPart("Top")
crosshairParts.Bottom = makeCrossPart("Bottom")
crosshairParts.Left = makeCrossPart("Left")
crosshairParts.Right = makeCrossPart("Right")

local function updateCrosshair()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local s = crosshairSize
    local g = crosshairGap
    local t = 2
    crosshairParts.Top.Size = UDim2.fromOffset(t, s)
    crosshairParts.Bottom.Size = UDim2.fromOffset(t, s)
    crosshairParts.Left.Size = UDim2.fromOffset(s, t)
    crosshairParts.Right.Size = UDim2.fromOffset(s, t)
    crosshairParts.Top.Position = UDim2.fromOffset(center.X, center.Y - g - s/2)
    crosshairParts.Bottom.Position = UDim2.fromOffset(center.X, center.Y + g + s/2)
    crosshairParts.Left.Position = UDim2.fromOffset(center.X - g - s/2, center.Y)
    crosshairParts.Right.Position = UDim2.fromOffset(center.X + g + s/2, center.Y)
    for _, part in pairs(crosshairParts) do part.Visible = crosshairEnabled end
end

TabVisual:Toggle({
    Title = "Custom Crosshair",
    Default = false,
    Callback = function(state)
        crosshairEnabled = state
        updateCrosshair()
    end
})

TabVisual:Slider({
    Title = "Crosshair Size",
    Step = 1,
    Value = { Min = 3, Max = 18, Default = 8 },
    Callback = function(value)
        crosshairSize = tonumber(value) or 8
        updateCrosshair()
    end
})

TabVisual:Slider({
    Title = "Crosshair Gap",
    Step = 1,
    Value = { Min = 0, Max = 15, Default = 4 },
    Callback = function(value)
        crosshairGap = tonumber(value) or 4
        updateCrosshair()
    end
})

TabVisual:Toggle({
    Title = "Target Highlight",
    Default = false,
    Callback = function(state)
        targetHighlightEnabled = state
        if not state and targetHighlight then
            pcall(function() targetHighlight:Destroy() end)
            targetHighlight = nil
        end
    end
})

RunService.RenderStepped:Connect(function()
    if crosshairEnabled then updateCrosshair() end
    if targetHighlightEnabled and SilentAimEnabled and CurrentLockedTarget and CurrentLockedTarget.Character then
        local char = CurrentLockedTarget.Character
        if not targetHighlight or targetHighlight.Adornee ~= char then
            if targetHighlight then pcall(function() targetHighlight:Destroy() end) end
            targetHighlight = Instance.new("Highlight")
            targetHighlight.Name = "POLLOS_TargetHighlight"
            targetHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            targetHighlight.FillTransparency = 0.72
            targetHighlight.OutlineTransparency = 0.05
            targetHighlight.FillColor = Color3.fromRGB(255, 210, 80)
            targetHighlight.OutlineColor = Color3.fromRGB(255, 240, 150)
            targetHighlight.Adornee = char
            targetHighlight.Parent = Workspace
        end
    elseif targetHighlight then
        pcall(function() targetHighlight:Destroy() end)
        targetHighlight = nil
    end
end)

-- Anti-AFK: evita que Roblox marque al jugador como inactivo.
local antiAFKEnabled = false
TabUtility:Section({ Title = "Quality of Life" })
TabUtility:Toggle({
    Title = "Anti AFK",
    Default = false,
    Callback = function(state)
        antiAFKEnabled = state
        WindUI:Notify({ Title = "POLLOS DEV", Content = state and "Anti AFK ENABLED" or "Anti AFK DISABLED", Duration = 1.5 })
    end
})

pcall(function()
    LocalPlayer.Idled:Connect(function()
        if antiAFKEnabled then
            local VirtualUser = game:GetService("VirtualUser")
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
        end
    end)
end)


-- ==========================================
-- CONFIGURACIONES (solo ajustes visuales)
-- ==========================================
local ConfigFolder = "POLLOS_DEV"
local ConfigName = "Default"
local SelectedConfig = "Default"

local function configPath(name)
    name = tostring(name or "Default"):gsub("[^%w_%-]", "_")
    if name == "" then name = "Default" end
    return ConfigFolder .. "/" .. name .. ".json"
end

local function ensureConfigFolder()
    pcall(function()
        if makefolder and not isfolder(ConfigFolder) then
            makefolder(ConfigFolder)
        end
    end)
end

local function getVisualConfig()
    return {
        NamesESP = namesESPEnabled == true,
        HealthBarESP = healthBarESPEnabled == true,
        InventoryESP = inventoryESPEnabled == true,
        WeaponESP = weaponESPEnabled == true,
    }
end

local function applyVisualConfig(cfg)
    if type(cfg) ~= "table" then return false end

    namesESPEnabled = cfg.NamesESP == true
    healthBarESPEnabled = cfg.HealthBarESP == true
    inventoryESPEnabled = cfg.InventoryESP == true
    weaponESPEnabled = cfg.WeaponESP == true

    refreshAll()

    if not weaponESPEnabled then
        for _, bg in pairs(WeaponBillboards) do
            pcall(function() bg:Destroy() end)
        end
        WeaponBillboards = {}
        WeaponCacheTokens = {}
    end

    return true
end

local function saveConfig(name)
    ensureConfigFolder()
    name = tostring(name or ConfigName or "Default")
    if name == "" then name = "Default" end
    ConfigName = name
    SelectedConfig = name

    if not writefile or not HttpService then
        WindUI:Notify({
            Title = "POLLOS DEV",
            Content = "Tu executor no permite guardar configuraciones.",
            Duration = 2.5
        })
        return
    end

    local ok, data = pcall(function()
        return HttpService:JSONEncode(getVisualConfig())
    end)

    if ok then
        local wrote = pcall(function()
            writefile(configPath(name), data)
        end)

        WindUI:Notify({
            Title = "POLLOS DEV",
            Content = wrote and ("Configuración guardada: " .. name) or "No se pudo guardar la configuración.",
            Duration = 2
        })
    end
end

local function loadConfig(name)
    ensureConfigFolder()
    name = tostring(name or SelectedConfig or "Default")
    if name == "" then name = "Default" end
    SelectedConfig = name
    ConfigName = name

    if not isfile or not readfile or not HttpService or not isfile(configPath(name)) then
        WindUI:Notify({
            Title = "POLLOS DEV",
            Content = "No existe la configuración: " .. name,
            Duration = 2
        })
        return
    end

    local ok, cfg = pcall(function()
        return HttpService:JSONDecode(readfile(configPath(name)))
    end)

    if ok and applyVisualConfig(cfg) then
        WindUI:Notify({
            Title = "POLLOS DEV",
            Content = "Configuración cargada: " .. name,
            Duration = 2
        })
    else
        WindUI:Notify({
            Title = "POLLOS DEV",
            Content = "La configuración está dañada o no es válida.",
            Duration = 2
        })
    end
end

local function getConfigNames()
    local names = {"Default"}
    if listfiles then
        pcall(function()
            for _, path in ipairs(listfiles(ConfigFolder)) do
                local name = tostring(path):match("([^/\\]+)%.json$")
                if name and name ~= "" then
                    local exists = false
                    for _, current in ipairs(names) do
                        if current == name then
                            exists = true
                            break
                        end
                    end
                    if not exists then
                        table.insert(names, name)
                    end
                end
            end
        end)
    end
    table.sort(names)
    return names
end

TabUtility:Section({ Title = "Configurations (Visual)" })

TabUtility:Input({
    Title = "Nombre de configuración",
    Desc = "Escribe el nombre para guardar.",
    Placeholder = "Ej: MiESP",
    Value = "Default",
    Callback = function(value)
        ConfigName = tostring(value or "Default")
        if ConfigName == "" then ConfigName = "Default" end
    end
})

TabUtility:Dropdown({
    Title = "Seleccionar configuración",
    Values = getConfigNames(),
    Value = "Default",
    AllowNone = false,
    Callback = function(value)
        if type(value) == "table" then
            value = value[1]
        end
        SelectedConfig = tostring(value or "Default")
        ConfigName = SelectedConfig
    end
})

TabUtility:Button({
    Title = "Guardar configuración",
    Callback = function()
        saveConfig(ConfigName)
    end
})

TabUtility:Button({
    Title = "Cargar configuración",
    Callback = function()
        loadConfig(SelectedConfig)
    end
})

-- ==========================================

-- Startup Notification with Creator Credit
WindUI:Notify({
    Title = "POLLOS DEV | eldb0305 ",
    Content = "Menu loaded successfully",
    Duration = 4
})
