-- ESPManager.lua
-- LocalScript для Roblox, можно запускать через loadstring

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local ESPEnabled = true
local ESPTags = {}

-- Создание ESP над игроком
local function createESP(player)
    local character = player.Character
    if not character then return end
    local head = character:FindFirstChild("Head")
    if not head then return end

    if ESPTags[player] then
        ESPTags[player]:Destroy()
    end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESPTag"
    billboard.Size = UDim2.new(0, 100, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = head

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 204, 0)
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.Text = player.Name
    label.Parent = billboard

    ESPTags[player] = billboard
end

-- Удаление ESP
local function removeESP(player)
    if ESPTags[player] then
        ESPTags[player]:Destroy()
        ESPTags[player] = nil
    end
end

-- Обновление ESP для всех игроков
local function updateAll()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if ESPEnabled then
                createESP(player)
            else
                removeESP(player)
            end
        end
    end
end

-- Обработка респавна персонажей
local function onCharacterAdded(player, character)
    if ESPEnabled then
        createESP(player)
    end
    character:WaitForChild("Humanoid").Died:Connect(function()
        removeESP(player)
    end)
end

-- Подписка на игроков
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        onCharacterAdded(player, character)
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

-- Инициализация для всех текущих игроков
for _, player in pairs(Players:GetPlayers()) do
    if player.Character then
        onCharacterAdded(player, player.Character)
    end
    player.CharacterAdded:Connect(function(character)
        onCharacterAdded(player, character)
    end)
end

-- --- GUI ---
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 180, 0, 80)
frame.Position = UDim2.new(0, 10, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Parent = screenGui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "ESP Manager"
title.TextColor3 = Color3.fromRGB(255, 204, 0)
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.Parent = frame

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.8, 0, 0, 30)
toggleButton.Position = UDim2.new(0.1, 0, 0, 40)
toggleButton.Text = "Выкл"
toggleButton.BackgroundColor3 = Color3.fromRGB(255, 204, 0)
toggleButton.TextColor3 = Color3.fromRGB(0, 0, 0)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextScaled = true
toggleButton.BorderSizePixel = 0
toggleButton.Parent = frame
Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(0, 8)

-- Логика кнопки ESP
toggleButton.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    toggleButton.Text = ESPEnabled and "Выкл" or "Вкл"
    updateAll()
end)

-- --- Drag & Drop GUI ---
local dragging = false
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                               startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)
