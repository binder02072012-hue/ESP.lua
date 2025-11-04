local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local ESPEnabled = true
local ESPTags = {}
local savedPosition = nil
local flying = false
local correctKey = "123"

-- =========================================
-- Вход по ключу
-- =========================================
local screenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))

local keyFrame = Instance.new("Frame", screenGui)
keyFrame.Size = UDim2.new(0, 300, 0, 150)
keyFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
keyFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
keyFrame.BorderSizePixel = 0
Instance.new("UICorner", keyFrame).CornerRadius = UDim.new(0,12)

local keyLabel = Instance.new("TextLabel", keyFrame)
keyLabel.Size = UDim2.new(1, -20, 0, 50)
keyLabel.Position = UDim2.new(0, 10, 0, 10)
keyLabel.BackgroundTransparency = 1
keyLabel.Text = "Введите ключ:"
keyLabel.TextColor3 = Color3.fromRGB(255,255,255)
keyLabel.Font = Enum.Font.GothamBold
keyLabel.TextScaled = true

local keyBox = Instance.new("TextBox", keyFrame)
keyBox.Size = UDim2.new(0.8, 0, 0, 40)
keyBox.Position = UDim2.new(0.1, 0, 0, 60)
keyBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
keyBox.TextColor3 = Color3.fromRGB(255,255,255)
keyBox.ClearTextOnFocus = false
keyBox.PlaceholderText = "Введите ключ здесь"
keyBox.Font = Enum.Font.GothamBold
keyBox.TextScaled = true
Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0,8)

local keyButton = Instance.new("TextButton", keyFrame)
keyButton.Size = UDim2.new(0.5,0,0,30)
keyButton.Position = UDim2.new(0.25,0,0,110)
keyButton.BackgroundColor3 = Color3.fromRGB(70,70,70)
keyButton.TextColor3 = Color3.fromRGB(255,255,255)
keyButton.Font = Enum.Font.GothamBold
keyButton.TextScaled = true
keyButton.Text = "Войти"
Instance.new("UICorner", keyButton).CornerRadius = UDim.new(0,8)

-- =========================================
-- Функции ESP
-- =========================================
local function createESP(player)
    local character = player.Character
    if not character then return end
    local head = character:FindFirstChild("Head")
    if not head then return end

    if ESPTags[player] then ESPTags[player]:Destroy() end

    local billboard = Instance.new("BillboardGui", head)
    billboard.Name = "ESPTag"
    billboard.Size = UDim2.new(0, 100, 0, 30)
    billboard.StudsOffset = Vector3.new(0,2,0)
    billboard.AlwaysOnTop = true

    local label = Instance.new("TextLabel", billboard)
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.Text = player.Name

    ESPTags[player] = billboard
end

local function removeESP(player)
    if ESPTags[player] then
        ESPTags[player]:Destroy()
        ESPTags[player] = nil
    end
end

local function updateAllESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if ESPEnabled then createESP(player) else removeESP(player) end
        end
    end
end

-- Подписка на игроков
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        if ESPEnabled then createESP(player) end
        character:WaitForChild("Humanoid").Died:Connect(function() removeESP(player) end)
    end)
end)
Players.PlayerRemoving:Connect(removeESP)

for _, player in pairs(Players:GetPlayers()) do
    if player.Character then
        if ESPEnabled then createESP(player) end
        player.CharacterAdded:Connect(function(character)
            if ESPEnabled then createESP(player) end
        end)
    end
end

-- =========================================
-- Основной GUI
-- =========================================
local function createMainGUI()
    keyFrame:Destroy()

    local mainFrame = Instance.new("Frame", screenGui)
    mainFrame.Size = UDim2.new(0, 250, 0, 200)
    mainFrame.Position = UDim2.new(0.5, -125, 0.5, -100)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
    mainFrame.BorderSizePixel = 0
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0,12)

    local title = Instance.new("TextLabel", mainFrame)
    title.Size = UDim2.new(1,0,0,30)
    title.Position = UDim2.new(0,0,0,0)
    title.BackgroundTransparency = 1
    title.Text = "Меню"
    title.TextColor3 = Color3.fromRGB(255,255,255)
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true

    -- ESP toggle
    local toggleESP = Instance.new("TextButton", mainFrame)
    toggleESP.Size = UDim2.new(0.8,0,0,30)
    toggleESP.Position = UDim2.new(0.1,0,0,40)
    toggleESP.BackgroundColor3 = Color3.fromRGB(50,50,50)
    toggleESP.TextColor3 = Color3.fromRGB(255,255,255)
    toggleESP.Font = Enum.Font.GothamBold
    toggleESP.TextScaled = true
    toggleESP.Text = "ESP: Вкл"
    Instance.new("UICorner", toggleESP).CornerRadius = UDim.new(0,8)

    toggleESP.MouseButton1Click:Connect(function()
        ESPEnabled = not ESPEnabled
        toggleESP.Text = ESPEnabled and "ESP: Вкл" or "ESP: Выкл"
        updateAllESP()
    end)

    -- Сохранить позицию
    local saveButton = Instance.new("TextButton", mainFrame)
    saveButton.Size = UDim2.new(0.8,0,0,30)
    saveButton.Position = UDim2.new(0.1,0,0,80)
    saveButton.BackgroundColor3 = Color3.fromRGB(50,50,50)
    saveButton.TextColor3 = Color3.fromRGB(255,255,255)
    saveButton.Font = Enum.Font.GothamBold
    saveButton.TextScaled = true
    saveButton.Text = "Сохранить позицию"
    Instance.new("UICorner", saveButton).CornerRadius = UDim.new(0,8)

    saveButton.MouseButton1Click:Connect(function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            savedPosition = char.HumanoidRootPart.Position
            print("Позиция сохранена:", savedPosition)
        end
    end)

    -- Лететь
    local flyButton = Instance.new("TextButton", mainFrame)
    flyButton.Size = UDim2.new(0.8,0,0,30)
    flyButton.Position = UDim2.new(0.1,0,0,120)
    flyButton.BackgroundColor3 = Color3.fromRGB(50,50,50)
    flyButton.TextColor3 = Color3.fromRGB(255,255,255)
    flyButton.Font = Enum.Font.GothamBold
    flyButton.TextScaled = true
    flyButton.Text = "Лететь"
    Instance.new("UICorner", flyButton).CornerRadius = UDim.new(0,8)

    flyButton.MouseButton1Click:Connect(function()
        if not savedPosition then return end
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        flying = true

        local hrp = char.HumanoidRootPart
        local velocity = Instance.new("BodyVelocity")
        velocity.MaxForce = Vector3.new(1e5,1e5,1e5)
        velocity.Velocity = Vector3.new(0,0,0)
        velocity.Parent = hrp

        spawn(function()
            while flying and hrp do
                local direction = (savedPosition - hrp.Position)
                if direction.Magnitude < 1 then break end
                velocity.Velocity = direction.Unit * 50
                wait(0.03)
            end
            velocity:Destroy()
            flying = false
        end)
    end)

    -- =========================================
    -- Drag & Drop
    -- =========================================
    local dragging = false
    local dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                       startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    mainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- =========================================
-- Проверка ключа
-- =========================================
keyButton.MouseButton1Click:Connect(function()
    if keyBox.Text == correctKey then
        createMainGUI()
    else
        keyBox.Text = ""
        warn("Неверный ключ!")
    end
end)
